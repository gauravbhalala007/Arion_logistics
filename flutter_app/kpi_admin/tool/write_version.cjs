// Schreibt build/web/build_version.json mit einer eindeutigen Build-ID.
// Läuft automatisch als firebase-hosting-predeploy (siehe firebase.json) —
// jede Veröffentlichung bekommt dadurch zwingend eine neue ID, die die App
// zur Laufzeit gegen ihren Startwert vergleicht (NewVersionGate).
const fs = require('fs');
const path = require('path');

// Bewusst NICHT version.json: die erzeugt Flutter selbst (package_info)
// und darf nicht überschrieben werden.
const out = path.join(__dirname, '..', 'build', 'web', 'build_version.json');
const payload = JSON.stringify({
  buildId: Date.now().toString(),
  deployedAt: new Date().toISOString(),
});
fs.writeFileSync(out, payload);
console.log('build_version.json geschrieben: ' + payload);
