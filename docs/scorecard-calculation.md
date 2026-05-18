# CoDriver Scorecard-Berechnung

Stand: 13. Mai 2026

Die Scorecard hat **zwei Ebenen** mit unterschiedlichen Quellen:

| Ebene | Wert | Quelle |
|---|---|---|
| Company / Wochen-Overall | `summary.overallScore`, `summary.overallStatus`, `rankAtStation`, `stationCount`, `reliabilityNextDay`, `reliabilitySameDay` | Direkt aus dem Amazon-PDF gelesen (per Regex aus dem Fließtext) |
| Per Driver | `comp.FinalScore`, `comp.POD_Score`, `comp.CC_Score`, `comp.DCR_Score`, `comp.CE_Score`, `comp.LoR_Score`, `comp.DNR_Score`, `comp.CDF_Score`, `statusBucket` | **Selbst berechnet** im Parser-Service in `compute_scores()` |

Beide Ebenen werden im selben `users/{adminUid}/reports/{reportId}` (`summary.*`) bzw. `users/{adminUid}/scores/{auto}` (`comp.*`, `kpis.*`) Dokument abgelegt.

---

## 1. Company-Score (Wochen-Overall)

Reine PDF-Extraktion, keine Eigenlogik. Aus dem Fließtext der Scorecard:

```
Overall Score: 87.45 | FANTASTIC
Rank at DBY5: 3 (+1 WoW)
Next Day Capacity Reliability 99.2 %
Same Day Capacity Reliability 98.8 %
```

werden via Regex extrahiert:
- `overallScore` → `87.45`
- `overallStatus` → `FANTASTIC`
- `stationCode` → `DBY5`
- `rankAtStation` → `3`
- `rankDeltaWoW` → `1`
- `reliabilityNextDay` → `99.2`
- `reliabilitySameDay` → `98.8`
- `reliabilityScore` → spiegelt `reliabilityNextDay`, falls vorhanden

→ **Diese Werte spiegelt CoDriver 1:1 wider — sie sind Amazons Wahrheit.**

---

## 2. Per-Driver-FinalScore

Hier kommt die CoDriver-eigene Bewertungslogik. Aus der Roh-Tabelle pro Fahrer (Spalten DCR, POD, CC, CE, LoR DPMO, DNR/DSC DPMO, CDF DPMO, Delivered) entsteht ein 0–100 Final-Score.

### 2.1 Per-Metric-Scores (Normierung auf 0–100)

| KPI | Formel | Notiz |
|---|---|---|
| **POD_Score** | `clamp(POD, 0, 100)` | Prozentwert direkt |
| **CC_Score** | `clamp(CC, 0, 100)` | Prozentwert direkt |
| **DCR_Score** | `clamp(DCR, 0, 100)` | Prozentwert direkt |
| **CE_Score** | `clamp(100 − 50·CE, 50, 100)` | Pro CE-Vorfall −50, Mindest-Floor 50 |
| **LoR_Score** | `clamp(100 − (LoR_DPMO / 1200)·30, 0, 100)` | DPMO → 30 Punkte Abzug pro 1200 |
| **DNR_Score** | `clamp(100 − (DNR_DPMO / 1200)·30, 0, 100)` | Gleiche Formel wie LoR |
| **CDF_Score** | siehe unten | Abhängig vom Spalten-Header |

**CDF_Score** ist zwei-modus:
- Header heißt **„CDF"** (Prozent) → `clamp(CDF, 0, 100)`
- Header heißt **„CDF DPMO"** → `clamp(100.33 − 0.01333 · CDF_DPMO, 0, 100)` (linear, bei 0 DPMO ≈ 100, bei ~7500 DPMO ≈ 0)
- Sonst → `None` (fließt nicht in den FinalScore ein)

### 2.2 FinalScore-Formel

```
avg_base   = MITTEL der vorhandenen { DCR_Score, POD_Score, CC_Score, CDF_Score }
ce_penalty  = 90 · CE
dsc_penalty = avg_base · dsc_penalty_rate(DNR_DPMO)
lor_penalty = avg_base · lor_penalty_rate(LoR_DPMO)

FinalScore  = avg_base − ce_penalty − dsc_penalty − lor_penalty
```

Klemmt am Ende nicht — der Wert kann negativ werden, wenn Penaltys zu hoch sind (z. B. >5 CE-Vorfälle ergeben einen 450-Punkt-Abzug). Anzeige `FinalScore` ist `round(..., 2)`.

**Wichtig**: `LoR_Score` und `DNR_Score` aus 2.1 werden zwar berechnet und gespeichert, fließen aber **nicht** direkt in den FinalScore-Durchschnitt ein — der Durchschnitt nimmt nur DCR/POD/CC/CDF. Die DPMO-Werte gehen stattdessen als Strafsatz-Multiplikator auf die ganze Basis.

### 2.3 Strafstaffeln (Penalty Rates)

**DSC/DNR DPMO → `dsc_penalty_rate`**

| DNR DPMO | Strafsatz |
|---|---|
| `0` | 0 % |
| `< 600` | 5 % |
| `≤ 1000` | 8 % |
| `≤ 2500` | 20 % |
| `≤ 5000` | 35 % |
| `≤ 10000` | 50 % |
| `> 10000` | 70 % |

**LoR DPMO → `lor_penalty_rate`**

| LoR DPMO | Strafsatz |
|---|---|
| `0` | 0 % |
| `≤ 500` | 10 % |
| `≤ 1500` | 25 % |
| `≤ 4000` | 40 % |
| `> 4000` | 80 % |

Die Strafsätze werden auf `avg_base` angewendet, **nicht** auf 100. Heißt: ein Fahrer mit avg_base = 90 und DNR_DPMO = 1500 verliert `90 · 0.20 = 18` Punkte.

### 2.4 Rechenbeispiel

Fahrer mit folgenden Roh-KPIs:

```
DCR = 99.5 %     →  DCR_Score  = 99.5
POD = 98.0 %     →  POD_Score  = 98.0
CC  = 100  %     →  CC_Score   = 100.0
CDF DPMO = 200   →  CDF_Score  = clamp(100.33 − 2.666, 0, 100) = 97.66
CE  = 1          →  ce_penalty = 90
LoR DPMO = 400   →  lor_rate   = 10 %
DNR DPMO = 800   →  dnr_rate   = 8 %
```

```
avg_base    = (99.5 + 98.0 + 100.0 + 97.66) / 4  = 98.79
ce_penalty  = 90 · 1 = 90
dsc_penalty = 98.79 · 0.08 = 7.90
lor_penalty = 98.79 · 0.10 = 9.88

FinalScore  = 98.79 − 90 − 7.90 − 9.88 = −8.99
```

Trotz hervorragender Basis-KPIs zieht der eine CE-Vorfall den Score brutal runter (−90).

### 2.5 Status-Bucket (Tier)

`FinalScore` → `statusBucket`:

| FinalScore | Bucket |
|---|---|
| `≥ 93` | `FANTASTIC_PLUS` |
| `86 ≤ x < 93` | `FANTASTIC` |
| `70 ≤ x < 86` | `GREAT` |
| `50 ≤ x < 70` | `FAIR` |
| `< 50` | `POOR` |
| `None` | `Unknown` |

Die Tier-Buckets gelten **gleich** für Driver-FinalScore und für den Company `overallScore` (Amazon's eigene Wertung folgt denselben Grenzen).

---

## 3. Anzeige in der App

### Wochen-Detailseite (`scorecard_week.dart`)
- **Hero-Karte** zeigt `summary.overallScore` (Amazon) — nicht der Driver-Durchschnitt
- **Tier-Pille** zeigt `summary.overallStatus`
- **Reliability-Tile** zeigt `summary.reliabilityNextDay` (Fallback `reliabilityScore`)
- **Rank-Tile** zeigt `rankAtStation / stationCount` + `stationCode`
- **Driver-Karten** zeigen pro Fahrer:
  - `comp.FinalScore` als „SCORE"
  - `data.statusBucket` als Tier-Pille (in Tier-Farbe)
  - `data.rank` (falls vorhanden) als runde Tier-Badge
  - Die 8 Einzel-KPIs (Delivered, DCR, DSC DPMO, LoR DPMO, POD, CC, CE-Display, CDF DPMO)

### Drivers-Hub-Übersicht (`drivers_hub_page.dart`)
- Pro Fahrer wird `comp.FinalScore` über alle vorhandenen Wochen gemittelt → das ist `overallScore` in der Tabelle
- Tier-Farbe basiert auf diesem Durchschnitt (gleiche Grenzwerte wie oben)

### Best-Driver-Leaderboard (`scorecard_overview.dart` Tab 2)
- Für jeden Fahrer in der Periode (Monat oder Jahr): Mittelwert seiner `comp.FinalScore`-Werte
- Sortiert absteigend
- Top-3 bekommen Gold/Silber/Bronze-Verlauf-Badge, Rest Tier-Farbe

### CE-Anzeige (Sonderfall)
Im Driver-Detail wird CE nicht als Rohwert (Anzahl) angezeigt, sondern als
`100 − 50·CE` mit Floor 50 (= `CE_Score`). Das macht das CE-Feld visuell konsistent mit den anderen Prozent-KPIs.

---

## 4. Wo das alles passiert

| Datei | Verantwortung |
|---|---|
| `parser_service/app.py` | PDF-Extraktion + `compute_scores()` + `status_bucket()` |
| `lib/services/parser_api.dart` | Client-Aufruf an den FastAPI-Endpoint |
| `lib/services/report_writer.dart` | Schreibt das Result in Firestore: `users/{uid}/reports/{reportId}` (summary + meta) und `users/{uid}/scores/{auto}` (pro Fahrer mit `comp.*` + `kpis.*` + `statusBucket` + `rank`) |
| `lib/Screens/scorecard_week.dart` | Rendert eine einzelne Woche |
| `lib/Screens/scorecard_overview.dart` | Tab 1: Hero + Bars; Tab 2: Best-Driver-Leaderboard |
| `lib/Screens/drivers_hub_page.dart` | Driver-Liste mit aggregiertem Mittelwert |

---

## 5. Mögliche Stellschrauben

Falls du die Formel später tunen willst, ändere ausschließlich `compute_scores()` in `parser_service/app.py`:

- **CE-Strafe weniger brutal**: aktuell `90 · CE`. Realistisch eher `30 · CE` mit Floor (wie aktuell CE_Score schon macht).
- **LoR/DSC-Schwellen anpassen**: die beiden `*_penalty_rate`-Funktionen sind reine Lookup-Tabellen.
- **CDF nicht aus dem Average rauslassen**, falls Amazon CDF nicht mehr reportet — sonst sinkt die Aussagekraft.
- **LoR_Score und DNR_Score** könnten auch direkt in den Durchschnitt — momentan sind sie nur „kosmetisch" gespeichert.

Nach jeder Formel-Änderung müssen alte Reports neu durch den Parser laufen, damit sie konsistent sind. Roh-PDFs werden nicht persistiert — du brauchst sie also vorrätig oder eine Backfill-Funktion.
