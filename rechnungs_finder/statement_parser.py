"""Kontoauszug einlesen: CSV (Hauptweg) oder PDF (Best-Effort-Fallback).

Liefert eine Liste von Transaktionen. Für die Belegsuche sind nur
Abbuchungen (negative Beträge) relevant.
"""

from __future__ import annotations

import csv
import io
import re
from dataclasses import dataclass, field
from datetime import date, datetime


@dataclass
class Transaction:
    booking_date: date
    amount: float  # negativ = Abbuchung
    counterparty: str
    purpose: str
    raw: dict = field(default_factory=dict)

    @property
    def is_debit(self) -> bool:
        return self.amount < 0

    @property
    def amount_abs(self) -> float:
        return abs(self.amount)


# Spaltennamen, wie sie in CSV-Exporten deutscher Banken üblich sind
DATE_HEADERS = [
    "buchungstag", "buchungsdatum", "buchung", "datum", "valutadatum",
    "wertstellung", "valuta", "date", "booking date",
]
AMOUNT_HEADERS = [
    "betrag", "betrag (eur)", "umsatz", "amount", "betrag in eur",
    "umsatz in eur", "amount (eur)",
]
COUNTERPARTY_HEADERS = [
    "empfaenger", "empfänger", "beguenstigter/zahlungspflichtiger",
    "begünstigter/zahlungspflichtiger", "auftraggeber/empfänger",
    "auftraggeber/empfaenger", "name zahlungsbeteiligter", "zahlungsbeteiligter",
    "empfänger/auftraggeber", "payee", "partner", "name", "beguenstigter",
    "begünstigter",
]
PURPOSE_HEADERS = [
    "verwendungszweck", "buchungstext", "umsatztext", "beschreibung",
    "zweck", "purpose", "description", "reference",
]

DATE_FORMATS = ["%d.%m.%Y", "%d.%m.%y", "%Y-%m-%d", "%d-%m-%Y", "%m/%d/%Y", "%d/%m/%Y"]


def parse_german_amount(value: str) -> float | None:
    """Beträge wie '-1.234,56', '49,99', '−49.99 €' robust parsen."""
    if value is None:
        return None
    text = str(value).strip().replace("−", "-").replace("€", "").replace("EUR", "").strip()
    if not text:
        return None
    negative = text.startswith("-") or text.endswith("-")
    text = text.strip("+-").strip()
    if not re.search(r"\d", text):
        return None
    # Deutsches Format: Punkt = Tausender, Komma = Dezimal
    if "," in text and (text.rfind(",") > text.rfind(".")):
        text = text.replace(".", "").replace(",", ".")
    else:
        # Englisches Format oder ohne Dezimaltrenner
        text = text.replace(",", "")
    try:
        amount = float(text)
    except ValueError:
        return None
    return -amount if negative else amount


def parse_date(value: str) -> date | None:
    if not value:
        return None
    text = str(value).strip()
    for fmt in DATE_FORMATS:
        try:
            return datetime.strptime(text, fmt).date()
        except ValueError:
            continue
    return None


def _decode(data: bytes) -> str:
    for encoding in ("utf-8-sig", "utf-8", "cp1252", "latin-1"):
        try:
            return data.decode(encoding)
        except UnicodeDecodeError:
            continue
    return data.decode("utf-8", errors="replace")


def _find_column(headers: list[str], candidates: list[str]) -> str | None:
    normalized = {h.strip().lower(): h for h in headers}
    for candidate in candidates:
        if candidate in normalized:
            return normalized[candidate]
    for candidate in candidates:
        for norm, original in normalized.items():
            if candidate in norm:
                return original
    return None


def parse_csv_statement(data: bytes) -> list[Transaction]:
    text = _decode(data)
    # Manche Banken stellen Metazeilen vor die eigentliche Tabelle:
    # die Kopfzeile ist die erste Zeile, die ein bekanntes Datums- UND Betragsfeld enthält.
    lines = text.splitlines()
    delimiter = ";" if text.count(";") >= text.count(",") else ","
    header_idx = None
    for i, line in enumerate(lines[:30]):
        lowered = line.lower()
        if any(h in lowered for h in DATE_HEADERS) and any(h in lowered for h in AMOUNT_HEADERS):
            header_idx = i
            break
    if header_idx is None:
        raise ValueError(
            "Keine Kopfzeile mit Datums- und Betragsspalte gefunden. "
            "Bitte einen CSV-Export mit Spaltenüberschriften verwenden."
        )

    reader = csv.DictReader(io.StringIO("\n".join(lines[header_idx:])), delimiter=delimiter)
    headers = reader.fieldnames or []
    date_col = _find_column(headers, DATE_HEADERS)
    amount_col = _find_column(headers, AMOUNT_HEADERS)
    counterparty_col = _find_column(headers, COUNTERPARTY_HEADERS)
    purpose_col = _find_column(headers, PURPOSE_HEADERS)
    if not date_col or not amount_col:
        raise ValueError(f"Datums-/Betragsspalte nicht erkannt. Gefundene Spalten: {headers}")

    transactions: list[Transaction] = []
    for row in reader:
        if not row:
            continue
        booking_date = parse_date(row.get(date_col, ""))
        amount = parse_german_amount(row.get(amount_col, ""))
        if booking_date is None or amount is None:
            continue
        transactions.append(
            Transaction(
                booking_date=booking_date,
                amount=amount,
                counterparty=(row.get(counterparty_col) or "").strip() if counterparty_col else "",
                purpose=(row.get(purpose_col) or "").strip() if purpose_col else "",
                raw={k: v for k, v in row.items() if k},
            )
        )
    return transactions


# Zeilen wie "12.05.2026 ... -49,99" in PDF-Auszügen
_PDF_LINE = re.compile(
    r"(?P<date>\d{2}\.\d{2}\.\d{2,4})\s+(?P<text>.+?)\s+(?P<amount>-?\d{1,3}(?:\.\d{3})*,\d{2}-?)\s*$"
)


def parse_pdf_statement(data: bytes) -> list[Transaction]:
    """Best-Effort-Parser für PDF-Kontoauszüge (bank-spezifische Layouts variieren)."""
    import pdfplumber

    transactions: list[Transaction] = []
    with pdfplumber.open(io.BytesIO(data)) as pdf:
        for page in pdf.pages:
            for line in (page.extract_text() or "").splitlines():
                match = _PDF_LINE.search(line.strip())
                if not match:
                    continue
                booking_date = parse_date(match.group("date"))
                amount = parse_german_amount(match.group("amount"))
                if booking_date is None or amount is None:
                    continue
                text = match.group("text").strip()
                transactions.append(
                    Transaction(
                        booking_date=booking_date,
                        amount=amount,
                        counterparty=text[:60],
                        purpose=text,
                        raw={"zeile": line.strip()},
                    )
                )
    return transactions


def parse_statement(filename: str, data: bytes) -> list[Transaction]:
    if filename.lower().endswith(".pdf") or data[:5] == b"%PDF-":
        return parse_pdf_statement(data)
    return parse_csv_statement(data)
