// Schreibt build/web/version.json mit einer eindeutigen Build-ID.
// Läuft automatisch als firebase-hosting-predeploy (siehe firebase.json) —
// jede Veröffentlichung bekommt dadurch zwingend eine neue ID, die die App
// zur Laufzeit gegen ihren Startwert vergleicht (NewVersionGate).
const fs = require('fs');
const path = require('path');

const out = path.join(__dirname, '..', 'build', 'web', 'version.json');
const payload = JSON.stringify({
  buildId: Date.now().toString(),
  deployedAt: new Date().toISOString(),
});
fs.writeFileSync(out, payload);
console.log('version.json geschrieben: ' + payload);
