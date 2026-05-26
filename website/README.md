# Business Website Template

Zweisprachige (DE/EN) Business-Website — reines HTML/CSS/JS, keine Build-Tools nötig.

## Dateien

| Datei | Inhalt |
|---|---|
| `index.html` | Seitenstruktur & Inhalte |
| `style.css` | Styles (Variablen, Layout, Responsive) |
| `script.js` | Sprach-Toggle, Animationen, Kontaktformular |

## IONOS Deployment

1. Alle drei Dateien (+ Bilder/Assets) per **FTP oder IONOS Datei-Manager** in das Root-Verzeichnis deines Hosting-Pakets laden
2. Fertig — die Seite ist live ✅

## Anpassen

### Inhalte
Alle Texte in `index.html` haben zwei Attribute:
```html
data-de="Deutscher Text"
data-en="English text"
```
Einfach beide Werte anpassen.

### Farben
In `style.css` ganz oben unter `:root { }` alle CSS-Variablen ändern:
```css
--color-cta: #0f0f0f;   /* Hauptfarbe (Buttons, Akzente) */
--color-text: #1a1a1a;  /* Textfarbe */
```

### Kontaktformular
Das Formular zeigt aktuell eine Demo-Erfolgsmeldung.
Für echten E-Mail-Versand → in `script.js` den Kommentarbereich ersetzen, z. B. mit [Formspree](https://formspree.io):
```js
await fetch('https://formspree.io/f/DEINE_ID', {
  method: 'POST',
  body: new FormData(contactForm),
  headers: { 'Accept': 'application/json' }
});
```

### Bilder
Die Platzhalter-Boxen (`about-image-placeholder`, `team-avatar`) mit echten `<img>`-Tags ersetzen.
