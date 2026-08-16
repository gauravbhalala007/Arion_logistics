# CoDriver Landing Page

Statische Marketing-Page für `codriver-app.com` (Hauptdomain).
Apple-style HTML/CSS, kein Build-Step nötig.

## Lokal anschauen

```bash
cd landing
python3 -m http.server 8080
# → http://localhost:8080
```

## Deploy auf Firebase Hosting

### Einmaliger Setup — zweites Hosting-Target im Firebase-Projekt anlegen

Im Firebase-Konsolen-UI (Projekt **codriver-eu**):
1. **Hosting → Add another site** → Site-ID z. B. `codriver-landing`
2. Domain `codriver-app.com` und `www.codriver-app.com` der neuen Site zuweisen
3. Die bestehende Admin-App-Site (`codriver-eu`, ausgeliefert auf `dsp-codriver.de`) bleibt unverändert

Lokal die Site-IDs als Target-Alias hinterlegen:
```bash
cd landing
firebase use --add codriver-eu              # Projekt wählen
firebase target:apply hosting landing codriver-landing
```

### Deploy

```bash
cd landing
firebase deploy --only hosting:landing
```

## Struktur

```
landing/
├── index.html          ← Single-page Landing (Hero, Features, Pricing, FAQ, …)
├── styles.css          ← Vollständiges Stylesheet (Apple-System)
├── app.js              ← Mobile-Menü + Scroll-Shadow
├── assets/
│   ├── favicon.png
│   └── og.png          ← Open-Graph-Bild für Link-Previews (1200×630)
├── firebase.json       ← Hosting-Config (eigenes Target)
└── README.md
```

## Anpassen

- **Branding-Farben** in `styles.css` unter `:root` (Block ganz oben)
- **Inhalte** direkt in `index.html` — keine Templates
- **CTAs** zeigen aktuell auf `https://dsp-codriver.de#/signup`.
  Sobald die App auf `app.codriver-app.com` liegt, alle Links suchen
  und ersetzen.

## Rechtsseiten — noch TODO

`/impressum.html`, `/datenschutz.html`, `/agb.html` sind in der Nav
verlinkt aber noch nicht angelegt. Sobald Impressum + Datenschutz vom
Anwalt da sind, als statische HTML-Seiten ins Landing-Verzeichnis legen.
