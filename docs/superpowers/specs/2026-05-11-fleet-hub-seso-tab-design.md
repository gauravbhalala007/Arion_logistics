# Fleet-Hub — SESO Vehicles Tab

## Goal
Add a second top-level tab "SESO" inside the Fleet-Hub admin page. The admin records *confirmations* for self-sourced vehicles: one confirmation = a vehicle type (SWB / LWB) + daily rate + a set of calendar weeks (KWs). The system computes the weekly cost (= daily rate × 7) and the total. Each week tracks paid/unpaid independently. Screenshots of the original confirmation and of payment receipts can be uploaded.

## Why
Today the DSP admin manually tracks SESO weekly rentals in spreadsheets to make sure Amazon's confirmed weeks actually got paid. Moving it into the app means: one source of truth, payment status visible at a glance, and screenshots stay attached to the record.

## Tab integration
`FleetStatusPage` becomes a `DefaultTabController` with two tabs:
1. "Fahrzeuge" — the existing vehicle list (no changes).
2. "SESO" — new content from this spec.

Toolbar stays above the TabBar so existing filters/exports keep working.

## Data model

```
users/{adminUid}/seso_confirmations/{confId}
  vehicleType: 'swb' | 'lwb'
  dailyRate: number              // EUR per day, two decimals
  weeks: [                       // ordered, one item per KW
    {
      year: number,              // ISO year of the KW
      weekNumber: number,        // 1–53
      paid: bool,
      paidAt: Timestamp?,        // when admin marked it paid
      paymentScreenshotPath: string?
    },
    …
  ]
  confirmationScreenshotPath: string?
  note: string?
  createdAt: Timestamp
  updatedAt: Timestamp
  createdByUid: string
```

Derived (computed in UI, never written):
- `weeklyCost  = dailyRate × 7`
- `totalCost   = weeklyCost × weeks.length`
- `paidCost    = weeklyCost × weeks.where(paid).length`
- `openCost    = totalCost − paidCost`

## Storage paths
```
users/{adminUid}/seso/{confId}/confirmation.{jpg|png|pdf}
users/{adminUid}/seso/{confId}/payment_{YEAR}_W{WEEK}.{jpg|png|pdf}
```

## UI

### SESO tab overview
- Three stat cards: "Offen", "Bezahlt", "# unbezahlte Wochen".
- "+ Confirmation anlegen" button (top right).
- List of confirmation cards. Each card:
  - SWB/LWB badge · daily rate · weekly cost
  - KW chips with paid/unpaid color (green ✓ paid, amber ○ open)
  - Total / Open
  - Confirmation screenshot thumbnail (or placeholder)
  - Tap → detail page

### Create / edit dialog
- Type switch: SWB / LWB.
- Daily rate field (TextFormField, € prefix). Quick-fill chips: SWB peak 53.23, LWB peak 57.26, SWB off-peak 41.63, LWB off-peak 48.63.
- Year stepper + KW chip grid (1–53). Multi-select.
- Live preview: "N Wochen × X € × 7 Tage = Y €".
- Optional note field.
- Confirmation-screenshot picker (single file). Web: file_picker; Mobile: image_picker (image or PDF).
- "Speichern" → writes Firestore + uploads file to Storage (if picked).

### Detail page
- Header: type + daily rate + summary stats.
- Weeks table: KW · weekly cost · paid toggle · payment screenshot (thumbnail + upload/replace button).
- Confirmation screenshot full-size preview.
- "Bearbeiten" (opens dialog with pre-fill) · "Löschen" (red).

## Berechnung implementation
Single pure helper in `lib/services/seso_pricing.dart`:
```dart
double weeklyCost(double dailyRate) => dailyRate * 7;
double totalCost(double dailyRate, int weeks) => weeklyCost(dailyRate) * weeks;
double paidCost(double dailyRate, int paidWeeks) => weeklyCost(dailyRate) * paidWeeks;
```
No off-peak detection — admin sets the daily rate per confirmation.

## Permission & access control
- New permission key `seso` (default OFF for new dispatchers).
- Admin's dispatcher-permissions page lists it as "SESO" — labelled "SESO Fahrzeuge".
- Dispatcher shell module list includes a SESO entry (uses the Fleet-Hub SESO tab? — no, dispatcher shell renders the full FleetStatusPage if `fleet_status` is on, **and** a separate `seso`-permission gates only the SESO tab visibility). For Phase 1 here: simpler to gate the whole FleetStatusPage via `fleet_status`; the SESO tab will be hidden inside FleetStatusPage when the new `seso` permission is off but `fleet_status` is on.

Implementation: FleetStatusPage reads the current dispatcher's sub-account permissions; if `seso == false` the SESO tab is omitted from the TabBar.

## Firestore Rules
The new collection `users/{adminUid}/seso_confirmations/{confId}` is covered by the existing recursive rule that grants admin + their dispatchers full read/write under `users/{adminUid}/`. No additional rules needed.

## Storage Rules
Storage rules currently scope by `users/{uid}/...`. The new path `users/{adminUid}/seso/...` falls under any catch-all admin block already present. If not present (TBD on inspection), add:
```
match /users/{adminUid}/seso/{allPaths=**} {
  allow read, write: if request.auth != null
    && (request.auth.uid == adminUid
        || (firestore.get(/databases/(default)/documents/users/$(request.auth.uid))
              .data.parentAdminUid == adminUid));
}
```

## Out of scope
- Automatic peak/off-peak rate detection.
- Multi-currency.
- CSV/PDF export.
- Email reminders for unpaid weeks.
- Bulk delete / archive.

## Implementation order
1. Model class `SesoConfirmation` + repository (`seso_confirmation_repository.dart`).
2. Pricing helpers.
3. Storage upload helper for screenshots.
4. New permission key `seso` added to dispatcher permissions list + default false.
5. FleetStatusPage gets TabBar (tab 1 = current body, tab 2 = SESO overview).
6. SESO overview page widget.
7. Create/edit dialog widget.
8. Detail page widget.
9. Storage rule update if catch-all isn't enough.
10. German strings — translations: add later if other languages need them.
11. Deploy: rules + hosting.
