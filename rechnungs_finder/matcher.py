"""Abbuchungen aus dem Kontoauszug den gefundenen Rechnungs-PDFs zuordnen.

Bewertung pro Kandidat (Punkte, max. ~110):
  +50  Betrag der Abbuchung steht im PDF-Text
  +15  Betrag steht im Mailtext/Betreff
  +30  Name des Zahlungsempfängers passt zum Mail-Absender
  +15  Name des Zahlungsempfängers steht im PDF-Text
  +10  Maildatum liegt nah am Buchungsdatum (linear abfallend)

Ab `min_score` (Standard 60) gilt ein Treffer als "sicher" — das
erfordert praktisch immer den Betrag im PDF plus ein zweites Signal.
"""

from __future__ import annotations

import io
import logging
import re
from dataclasses import dataclass, field

from imap_client import PdfAttachment
from statement_parser import Transaction

log = logging.getLogger(__name__)

# Rechtsformen etc., die für den Namensvergleich keine Aussagekraft haben
_STOPWORDS = {
    "gmbh", "ag", "kg", "ug", "ohg", "gbr", "co", "und", "the", "inc", "ltd",
    "se", "ev", "e.v", "mbh", "haftungsbeschraenkt", "haftungsbeschränkt",
    "sepa", "lastschrift", "ueberweisung", "überweisung", "dauerauftrag",
    "basislastschrift", "kartenzahlung", "girocard",
}


def _tokens(text: str) -> set[str]:
    words = re.split(r"[^a-zäöüß0-9]+", text.lower())
    return {w for w in words if len(w) >= 3 and w not in _STOPWORDS}


def amount_variants(amount: float) -> list[str]:
    """Schreibweisen eines Betrags, wie sie in Rechnungen vorkommen."""
    value = abs(amount)
    german = f"{value:,.2f}".replace(",", "X").replace(".", ",").replace("X", ".")
    english = f"{value:,.2f}"
    variants = {german, english}
    if value >= 1000:
        variants.add(german.replace(".", ""))   # 1234,56
        variants.add(english.replace(",", ""))  # 1234.56
    return sorted(variants)


def extract_pdf_text(data: bytes) -> str:
    import pdfplumber

    try:
        with pdfplumber.open(io.BytesIO(data)) as pdf:
            return "\n".join((page.extract_text() or "") for page in pdf.pages[:8])
    except Exception as exc:
        log.warning("PDF-Text nicht lesbar: %s", exc)
        return ""


@dataclass
class Match:
    transaction: Transaction
    attachment: PdfAttachment
    score: int
    reasons: list[str] = field(default_factory=list)
    min_score: int = 60

    @property
    def confident(self) -> bool:
        return self.score >= self.min_score


def score_pair(tx: Transaction, att: PdfAttachment, days_before: int, days_after: int) -> tuple[int, list[str]]:
    score = 0
    reasons: list[str] = []

    if att.mail_date is not None:
        delta = (tx.booking_date - att.mail_date).days
        # Mail muss im Suchfenster liegen, sonst kein Kandidat
        if not (-days_after <= delta <= days_before):
            return 0, []
        window = max(days_before, days_after)
        proximity = max(0, 10 - round(abs(delta) * 10 / window)) if window else 10
        score += proximity
        if proximity:
            reasons.append(f"Datum passt ({abs(delta)} Tage Abstand)")

    variants = amount_variants(tx.amount)
    if any(v in att.text for v in variants):
        score += 50
        reasons.append("Betrag im PDF gefunden")
    mail_text = f"{att.subject}\n{att.body_text}"
    if any(v in mail_text for v in variants):
        score += 15
        reasons.append("Betrag in der E-Mail gefunden")

    tx_tokens = _tokens(f"{tx.counterparty} {tx.purpose}")
    sender_tokens = _tokens(f"{att.sender_name} {att.sender_address}")
    if tx_tokens & sender_tokens:
        score += 30
        reasons.append(f"Absender passt ({', '.join(sorted(tx_tokens & sender_tokens)[:3])})")
    pdf_tokens = _tokens(att.text[:4000])
    if tx_tokens & pdf_tokens:
        score += 15
        reasons.append("Empfängername im PDF gefunden")

    return score, reasons


def match_transactions(
    debits: list[Transaction],
    attachments: list[PdfAttachment],
    days_before: int,
    days_after: int,
    min_score: int,
) -> tuple[list[Match], list[Transaction]]:
    """Beste Zuordnung je Abbuchung. Ein PDF darf mehrere Abbuchungen
    abdecken (z. B. Sammelrechnung), bevorzugt wird aber 1:1."""
    for att in attachments:
        if not att.text:
            att.text = extract_pdf_text(att.data)

    matches: list[Match] = []
    unmatched: list[Transaction] = []
    used_attachments: set[int] = set()

    for tx in debits:
        candidates: list[tuple[int, list[str], int, PdfAttachment]] = []
        for idx, att in enumerate(attachments):
            score, reasons = score_pair(tx, att, days_before, days_after)
            if score > 0:
                # Noch nicht verwendete PDFs leicht bevorzugen
                bonus = 0 if idx in used_attachments else 1
                candidates.append((score + bonus, reasons, idx, att))
        if not candidates:
            unmatched.append(tx)
            continue
        candidates.sort(key=lambda c: c[0], reverse=True)
        best_score, reasons, idx, att = candidates[0]
        if best_score < 30:  # zu schwach, lieber als "ohne Beleg" ausweisen
            unmatched.append(tx)
            continue
        used_attachments.add(idx)
        matches.append(
            Match(transaction=tx, attachment=att, score=best_score,
                  reasons=reasons, min_score=min_score)
        )

    return matches, unmatched


def safe_filename(text: str, max_length: int = 60) -> str:
    cleaned = re.sub(r"[^\w\-. ]", "_", text, flags=re.UNICODE).strip(" ._")
    cleaned = re.sub(r"\s+", "_", cleaned)
    return cleaned[:max_length] or "unbenannt"


def target_filename(match: Match) -> str:
    tx = match.transaction
    vendor = safe_filename(tx.counterparty or match.attachment.sender_name or "unbekannt", 40)
    amount = f"{tx.amount:.2f}".replace(".", ",")
    return f"{tx.booking_date.isoformat()}_{vendor}_{amount}EUR.pdf"
