"""Rechnungs-Finder — lokale Web-Oberfläche.

Ablauf:
  1. Kontoauszug hochladen (CSV empfohlen, PDF als Best-Effort)
  2. Suche starten: alle konfigurierten IMAP-Postfächer (IONOS) werden
     einmal über den relevanten Zeitraum nach PDF-Anhängen durchsucht
  3. Treffer prüfen und mit einem Klick speichern:
     alle PDFs flach in den Ausgabeordner + zuordnung.csv

Start:  uvicorn app:app --port 8765
Danach: http://127.0.0.1:8765
"""

from __future__ import annotations

import csv
import logging
import threading
from datetime import date, timedelta
from pathlib import Path

import yaml
from fastapi import FastAPI, File, Request, UploadFile
from fastapi.responses import HTMLResponse, RedirectResponse, Response
from fastapi.templating import Jinja2Templates

from imap_client import MailboxConfig, fetch_pdf_attachments
from matcher import (
    Match,
    folder_for,
    match_transactions,
    relative_target_path,
    target_filename,
)
from statement_parser import Transaction, parse_statement

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
log = logging.getLogger("rechnungs_finder")

BASE_DIR = Path(__file__).resolve().parent
CONFIG_PATH = BASE_DIR / "config.yaml"

app = FastAPI(title="Rechnungs-Finder")
templates = Jinja2Templates(directory=str(BASE_DIR / "templates"))


class State:
    """Zustand des aktuellen Durchlaufs (lokales Ein-Personen-Tool)."""

    def __init__(self) -> None:
        self.lock = threading.Lock()
        self.reset()

    def reset(self) -> None:
        self.statement_name: str = ""
        self.transactions: list[Transaction] = []
        self.matches: list[Match] = []
        self.unmatched: list[Transaction] = []
        self.search_running: bool = False
        self.search_done: bool = False
        self.progress: list[str] = []
        self.errors: list[str] = []
        self.saved_to: str = ""

    def log_progress(self, message: str) -> None:
        log.info(message)
        with self.lock:
            self.progress.append(message)


state = State()


def load_config() -> dict:
    if not CONFIG_PATH.exists():
        return {}
    with CONFIG_PATH.open(encoding="utf-8") as fh:
        return yaml.safe_load(fh) or {}


def mailboxes_from_config(config: dict) -> list[MailboxConfig]:
    boxes = []
    for entry in config.get("mailboxes", []):
        boxes.append(
            MailboxConfig(
                name=entry.get("name") or entry.get("user", "Postfach"),
                host=entry.get("host", "imap.ionos.de"),
                port=int(entry.get("port", 993)),
                user=entry["user"],
                password=entry["password"],
                folders=entry.get("folders") or ["INBOX"],
            )
        )
    return boxes


def search_settings(config: dict) -> tuple[int, int, int]:
    search = config.get("search", {})
    return (
        int(search.get("days_before", 45)),
        int(search.get("days_after", 10)),
        int(search.get("min_score", 60)),
    )


def output_directory(config: dict) -> Path:
    raw = config.get("output", {}).get("directory", "./belege")
    path = Path(raw)
    return path if path.is_absolute() else (BASE_DIR / path).resolve()


@app.get("/", response_class=HTMLResponse)
def index(request: Request):
    config = load_config()
    return templates.TemplateResponse(
        request,
        "index.html",
        {
            "config_exists": CONFIG_PATH.exists(),
            "mailboxes": [m.name for m in mailboxes_from_config(config)] if config else [],
            "output_dir": str(output_directory(config)),
            "state": state,
            "transactions": state.transactions,
            "ausgaben": [t for t in state.transactions if t.is_debit],
            "einnahmen": [t for t in state.transactions if not t.is_debit],
            "confident": [m for m in state.matches if m.confident],
            "uncertain": [m for m in state.matches if not m.confident],
            "target_filename": target_filename,
            "folder_for": folder_for,
        },
    )


@app.post("/upload")
async def upload_statement(file: UploadFile = File(...)):
    data = await file.read()
    state.reset()
    state.statement_name = file.filename or "kontoauszug"
    try:
        state.transactions = parse_statement(state.statement_name, data)
    except Exception as exc:
        state.errors.append(f"Kontoauszug konnte nicht gelesen werden: {exc}")
        return RedirectResponse("/", status_code=303)
    if not state.transactions:
        state.errors.append("Es wurden keine Buchungen im Auszug gefunden.")
    return RedirectResponse("/", status_code=303)


def _run_search() -> None:
    config = load_config()
    mailboxes = mailboxes_from_config(config)
    days_before, days_after, min_score = search_settings(config)
    transactions = state.transactions

    try:
        earliest = min(t.booking_date for t in transactions) - timedelta(days=days_before)
        latest = min(
            max(t.booking_date for t in transactions) + timedelta(days=days_after + 1),
            date.today() + timedelta(days=1),
        )
        attachments = []
        for mailbox in mailboxes:
            state.log_progress(f"Durchsuche Postfach „{mailbox.name}“ ({mailbox.user}) …")
            try:
                found = fetch_pdf_attachments(
                    mailbox, since=earliest, before=latest, progress=state.log_progress
                )
                attachments.extend(found)
                state.log_progress(f"„{mailbox.name}“: {len(found)} PDF-Anhänge gefunden")
            except Exception as exc:
                state.errors.append(f"Postfach „{mailbox.name}“: {exc}")

        state.log_progress(
            f"Lese {len(attachments)} PDFs und ordne {len(transactions)} Buchungen zu …"
        )
        matches, unmatched = match_transactions(
            transactions, attachments, days_before, days_after, min_score
        )
        with state.lock:
            state.matches = matches
            state.unmatched = unmatched
        state.log_progress(
            f"Fertig: {sum(1 for m in matches if m.confident)} sichere Treffer, "
            f"{sum(1 for m in matches if not m.confident)} unsichere, "
            f"{len(unmatched)} ohne Beleg."
        )
    except Exception as exc:
        log.exception("Suche fehlgeschlagen")
        state.errors.append(f"Suche fehlgeschlagen: {exc}")
    finally:
        state.search_running = False
        state.search_done = True


@app.post("/search")
def start_search():
    config = load_config()
    if not mailboxes_from_config(config):
        state.errors.append(
            "Keine Postfächer konfiguriert. Bitte config.example.yaml nach "
            "config.yaml kopieren und ausfüllen."
        )
        return RedirectResponse("/", status_code=303)
    if not state.transactions:
        state.errors.append("Bitte zuerst einen Kontoauszug hochladen.")
        return RedirectResponse("/", status_code=303)
    if state.search_running:
        return RedirectResponse("/", status_code=303)
    state.search_running = True
    state.search_done = False
    state.matches = []
    state.unmatched = []
    state.progress = []
    threading.Thread(target=_run_search, daemon=True).start()
    return RedirectResponse("/", status_code=303)


@app.get("/pdf/{index}")
def view_pdf(index: int):
    if index < 0 or index >= len(state.matches):
        return Response(status_code=404)
    match = state.matches[index]
    return Response(
        content=match.attachment.data,
        media_type="application/pdf",
        headers={"Content-Disposition": f'inline; filename="{target_filename(match)}"'},
    )


@app.post("/save")
def save_results():
    config = load_config()
    out_dir = output_directory(config)
    out_dir.mkdir(parents=True, exist_ok=True)

    rows = []
    used_paths: set[str] = set()
    for match in state.matches:
        # Ablage: <ausgabeordner>/<JJJJ-MM>/<Ausgaben|Einnahmen>/<datei>.pdf
        rel_path = relative_target_path(match)
        stem, suffix = rel_path.rsplit(".", 1)
        counter = 2
        while rel_path in used_paths:
            rel_path = f"{stem}_{counter}.{suffix}"
            counter += 1
        used_paths.add(rel_path)
        target = out_dir / rel_path
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(match.attachment.data)
        tx = match.transaction
        rows.append({
            "Buchungsdatum": tx.booking_date.isoformat(),
            "Art": "Ausgabe" if tx.is_debit else "Einnahme",
            "Betrag": f"{tx.amount:.2f}".replace(".", ","),
            "Empfänger": tx.counterparty,
            "Verwendungszweck": tx.purpose,
            "Status": "sicher" if match.confident else "unsicher – bitte prüfen",
            "Punkte": match.score,
            "Datei": rel_path,
            "Postfach": match.attachment.mailbox_name,
            "Mail-Absender": match.attachment.sender_address,
            "Mail-Betreff": match.attachment.subject,
            "Mail-Datum": match.attachment.mail_date.isoformat() if match.attachment.mail_date else "",
        })
    for tx in state.unmatched:
        rows.append({
            "Buchungsdatum": tx.booking_date.isoformat(),
            "Art": "Ausgabe" if tx.is_debit else "Einnahme",
            "Betrag": f"{tx.amount:.2f}".replace(".", ","),
            "Empfänger": tx.counterparty,
            "Verwendungszweck": tx.purpose,
            "Status": "KEIN BELEG GEFUNDEN",
            "Punkte": "",
            "Datei": "",
            "Postfach": "",
            "Mail-Absender": "",
            "Mail-Betreff": "",
            "Mail-Datum": "",
        })
    rows.sort(key=lambda r: (r["Buchungsdatum"], r["Art"]))

    csv_path = out_dir / "zuordnung.csv"
    with csv_path.open("w", newline="", encoding="utf-8-sig") as fh:
        writer = csv.DictWriter(fh, fieldnames=list(rows[0].keys()) if rows else ["Status"],
                                delimiter=";")
        writer.writeheader()
        writer.writerows(rows)

    state.saved_to = str(out_dir)
    state.log_progress(f"{len(state.matches)} PDFs + zuordnung.csv gespeichert in {out_dir}")
    return RedirectResponse("/", status_code=303)


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="127.0.0.1", port=8765)
