// scripts/upload_regenerated_certs.js
//
// Lädt die neu gestalteten Nachweis-PDFs (/tmp/regen/new/{idx}.pdf) auf
// die BESTEHENDEN Storage-Pfade der alten PDFs hoch (Ersatz im neuen
// Design, vom Kunden angefordert). Der vorhandene Download-Token wird
// beibehalten, damit alle in Firestore gespeicherten downloadUrls
// weiter funktionieren. Anschließend wird nur das size-Feld des
// jeweiligen Firestore-Dokuments aktualisiert.
//
// Aufruf: node scripts/upload_regenerated_certs.js

const fs = require('fs');
const path = require('path');
const admin = require(path.join(
  __dirname, '..', 'firebase', 'functions', 'node_modules', 'firebase-admin'));

admin.initializeApp({
  projectId: 'codriver-eu',
  storageBucket: 'codriver-eu.firebasestorage.app',
});
const db = admin.firestore();
const bucket = admin.storage().bucket();

(async () => {
  const jobs = JSON.parse(fs.readFileSync('/tmp/regen/jobs.json'));
  let ok = 0;
  for (const j of jobs) {
    const local = `/tmp/regen/new/${j.idx}.pdf`;
    const size = fs.statSync(local).size;
    await bucket.upload(local, {
      destination: j.storagePath,
      metadata: {
        contentType: 'application/pdf',
        metadata: { firebaseStorageDownloadTokens: j.token },
      },
    });
    await db.doc(j.docPath).set({ size }, { merge: true });
    ok++;
    console.log('ok', j.idx, j.type, j.tid);
  }
  console.log('Hochgeladen:', ok, 'von', jobs.length);
  process.exit(0);
})().catch((e) => {
  console.error(e);
  process.exit(1);
});
