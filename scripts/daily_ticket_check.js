// scripts/daily_ticket_check.js
//
// Tägliche Ticket-Routine für CoDriver.
//
// Liest alle offenen Feedback-Tickets aus Firestore, schreibt einen
// Tagesbericht nach ~/CoDriver-Tickets/ und meldet sich per macOS-
// Mitteilung, wenn etwas offen ist. Wird von launchd einmal täglich
// gestartet (siehe scripts/com.codriver.tickets.plist).
//
// Manuell:  node scripts/daily_ticket_check.js

const fs = require('fs');
const os = require('os');
const path = require('path');
const { execFile } = require('child_process');

const admin = require(path.join(
  __dirname,
  '..',
  'firebase',
  'functions',
  'node_modules',
  'firebase-admin',
));

admin.initializeApp({ projectId: 'codriver-eu' });
const db = admin.firestore();

const CLOSED = new Set(['done', 'resolved', 'closed', 'rejected']);
const OUT_DIR = path.join(os.homedir(), 'CoDriver-Tickets');

function notify(title, message) {
  // Nur macOS; Fehler bewusst schlucken (Routine soll nie hängen).
  execFile(
    'osascript',
    ['-e', `display notification ${JSON.stringify(message)} with title ${JSON.stringify(title)}`],
    () => {},
  );
}

(async () => {
  const snap = await db.collection('feedback').get();
  const open = [];
  snap.forEach((doc) => {
    const d = doc.data();
    const status = (d.status || 'open').toLowerCase();
    if (CLOSED.has(status)) return;
    const created =
      d.createdAt && d.createdAt.toDate ? d.createdAt.toDate() : null;
    open.push({
      id: doc.id,
      status,
      title: (d.title || '(ohne Titel)').toString(),
      message: (d.message || d.text || '').toString(),
      by: (d.createdByEmail || d.userEmail || '').toString(),
      created,
      ageDays: created
        ? Math.floor((Date.now() - created.getTime()) / 86400000)
        : null,
    });
  });

  open.sort((a, b) => (a.created?.getTime() || 0) - (b.created?.getTime() || 0));

  const today = new Date().toISOString().slice(0, 10);
  const lines = [];
  lines.push(`# Offene CoDriver-Tickets — ${today}`);
  lines.push('');
  lines.push(`Gesamt: ${open.length}`);
  lines.push('');

  const stale = open.filter((t) => (t.ageDays ?? 0) >= 7);
  if (stale.length) {
    lines.push(`## Älter als 7 Tage (${stale.length})`);
    for (const t of stale) {
      lines.push(`- **${t.title}** (${t.ageDays} Tage, ${t.status}) — ${t.id}`);
      lines.push(`  ${t.message.replace(/\n+/g, ' ').slice(0, 200)}`);
    }
    lines.push('');
  }

  lines.push('## Alle offenen Tickets');
  for (const t of open) {
    const age = t.ageDays != null ? `${t.ageDays}d` : '?';
    lines.push(`\n### ${t.title}  \`${t.id}\``);
    lines.push(`Status: ${t.status} · Alter: ${age} · von: ${t.by}`);
    lines.push('');
    lines.push(t.message.slice(0, 800));
  }

  fs.mkdirSync(OUT_DIR, { recursive: true });
  const outFile = path.join(OUT_DIR, `offene-tickets-${today}.md`);
  fs.writeFileSync(outFile, lines.join('\n'), 'utf8');
  // Stabiler Pfad für den schnellen Zugriff:
  fs.writeFileSync(path.join(OUT_DIR, 'aktuell.md'), lines.join('\n'), 'utf8');

  console.log(`${open.length} offene Tickets → ${outFile}`);
  for (const t of open) {
    console.log(`  [${t.status}] ${t.title} (${t.ageDays ?? '?'}d) ${t.id}`);
  }

  if (open.length > 0) {
    const oldest = open[0];
    notify(
      `CoDriver: ${open.length} offene Tickets`,
      stale.length
        ? `${stale.length} älter als 7 Tage. Ältestes: ${oldest.title}`
        : `Ältestes: ${oldest.title} (${oldest.ageDays ?? '?'} Tage)`,
    );
  }
  process.exit(0);
})().catch((e) => {
  console.error('Ticket-Routine fehlgeschlagen:', e.message);
  notify('CoDriver Ticket-Routine', `Fehler: ${e.message}`);
  process.exit(1);
});
