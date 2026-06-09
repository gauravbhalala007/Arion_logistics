"""PDF-Anhänge aus IMAP-Postfächern (z. B. IONOS) einsammeln.

Strategie: EIN Durchlauf pro Postfach über den gesamten relevanten
Zeitraum, alle Mails mit PDF-Anhängen einsammeln. Das Matching gegen
die einzelnen Abbuchungen passiert danach lokal (matcher.py) — so wird
jedes Postfach nur einmal durchsucht, egal wie viele Abbuchungen es gibt.
"""

from __future__ import annotations

import email
import imaplib
import logging
from dataclasses import dataclass, field
from datetime import date, datetime
from email.header import decode_header, make_header
from email.utils import parseaddr, parsedate_to_datetime

log = logging.getLogger(__name__)

IMAP_DATE_FORMAT = "%d-%b-%Y"  # IMAP verlangt englische Monatskürzel


@dataclass
class PdfAttachment:
    mailbox_name: str
    folder: str
    message_uid: str
    sender_name: str
    sender_address: str
    subject: str
    mail_date: date | None
    filename: str
    data: bytes
    text: str = ""  # extrahierter PDF-Text, wird vom Matcher befüllt
    body_text: str = ""  # Mailtext (für zusätzliche Treffer-Signale)


@dataclass
class MailboxConfig:
    name: str
    host: str
    user: str
    password: str
    port: int = 993
    folders: list[str] = field(default_factory=lambda: ["INBOX"])


def _decode_mime(value: str | None) -> str:
    if not value:
        return ""
    try:
        return str(make_header(decode_header(value)))
    except Exception:
        return value


def _decode_filename(part) -> str:
    return _decode_mime(part.get_filename())


def _is_pdf_part(part) -> bool:
    if part.get_content_type() == "application/pdf":
        return True
    filename = _decode_filename(part)
    return bool(filename) and filename.lower().endswith(".pdf")


def _extract_body_text(message) -> str:
    chunks: list[str] = []
    for part in message.walk():
        if part.get_content_type() == "text/plain" and not part.get_filename():
            payload = part.get_payload(decode=True)
            if payload:
                charset = part.get_content_charset() or "utf-8"
                try:
                    chunks.append(payload.decode(charset, errors="replace"))
                except LookupError:
                    chunks.append(payload.decode("utf-8", errors="replace"))
    return "\n".join(chunks)[:20000]


def fetch_pdf_attachments(
    mailbox: MailboxConfig,
    since: date,
    before: date,
    progress=None,
) -> list[PdfAttachment]:
    """Alle PDF-Anhänge im Zeitraum [since, before] aus einem Postfach holen."""
    attachments: list[PdfAttachment] = []
    conn = imaplib.IMAP4_SSL(mailbox.host, mailbox.port)
    try:
        conn.login(mailbox.user, mailbox.password)
        for folder in mailbox.folders or ["INBOX"]:
            status, _ = conn.select(f'"{folder}"', readonly=True)
            if status != "OK":
                log.warning("%s: Ordner %s nicht lesbar, übersprungen", mailbox.name, folder)
                continue
            criteria = (
                f'(SINCE "{since.strftime(IMAP_DATE_FORMAT)}" '
                f'BEFORE "{before.strftime(IMAP_DATE_FORMAT)}")'
            )
            status, data = conn.uid("search", None, criteria)
            if status != "OK":
                continue
            uids = data[0].split()
            if progress:
                progress(f"{mailbox.name}/{folder}: {len(uids)} Mails im Zeitraum")
            for i, uid in enumerate(uids):
                uid_str = uid.decode()
                # Erst nur die Struktur prüfen, damit Mails ohne PDF
                # nicht komplett geladen werden müssen.
                status, structure = conn.uid("fetch", uid_str, "(BODYSTRUCTURE)")
                if status != "OK" or not structure or structure[0] is None:
                    continue
                structure_raw = b" ".join(
                    part if isinstance(part, bytes) else b"" for part in structure
                ).upper()
                if b"PDF" not in structure_raw:
                    continue

                status, msg_data = conn.uid("fetch", uid_str, "(BODY.PEEK[])")
                if status != "OK" or not msg_data or msg_data[0] is None:
                    continue
                message = email.message_from_bytes(msg_data[0][1])
                sender_name, sender_address = parseaddr(_decode_mime(message.get("From")))
                try:
                    mail_date = parsedate_to_datetime(message.get("Date")).date()
                except (TypeError, ValueError):
                    mail_date = None
                subject = _decode_mime(message.get("Subject"))
                body_text = _extract_body_text(message)
                for part in message.walk():
                    if not _is_pdf_part(part):
                        continue
                    payload = part.get_payload(decode=True)
                    if not payload or payload[:5] != b"%PDF-":
                        continue
                    attachments.append(
                        PdfAttachment(
                            mailbox_name=mailbox.name,
                            folder=folder,
                            message_uid=uid_str,
                            sender_name=sender_name,
                            sender_address=sender_address.lower(),
                            subject=subject,
                            mail_date=mail_date,
                            filename=_decode_filename(part) or f"anhang_{uid_str}.pdf",
                            data=payload,
                            body_text=body_text,
                        )
                    )
                if progress and (i + 1) % 25 == 0:
                    progress(
                        f"{mailbox.name}/{folder}: {i + 1}/{len(uids)} Mails geprüft, "
                        f"{len(attachments)} PDFs bisher"
                    )
    finally:
        try:
            conn.logout()
        except Exception:
            pass
    return attachments
