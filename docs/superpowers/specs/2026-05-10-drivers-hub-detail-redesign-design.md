# Drivers Hub Detail — Redesign

## Goal
Convert the inline 1200-line driver-detail dialog (`_openDriverDetails` in `lib/Screens/drivers_hub_page.dart`) into a clean dashboard-grid layout that surfaces all key driver info "auf einen Blick", with input fields grouped into per-category cards (Kacheln).

## Layout

### Hero card (full width)
- Avatar 88×88 (existing `_profileImageFromOnboarding`)
- Name + tid + email + phone
- Score pill (existing `_buildOverallScoreCell`)
- Notification PIN (toggleable display + edit)
- Action buttons (export PDF, etc — existing)

### Kachel grid (responsive)
- ≥1100px: 2-column grid
- <1100px: 1-column stack
- 8 category cards (4 rows of 2):

| Left | Right |
|---|---|
| Personal & Origin | Address |
| Driving Licence | Documents & Permits |
| Payment / Tax | Emergency Contact |
| Uniform | Notes |

### Documents file list
Full-width below the grid (existing `_DriverDocumentsList`, just wrapped in the new card hull).

### Score charts
Stays below documents (existing `_buildWeeklyScoreSummaryCard` etc).

## Card anatomy
- White background, `BorderRadius.circular(16)`, level1 shadow, thin separator border
- Header: small icon + uppercase title (`AppTypography.caption2` w700 secondary color)
- Body: list of `_detailRowEditable` rows (existing helper, untouched)
- Expiry-date fields show a status chip (existing `_expiryStatus` helper)

## Field assignment per card

- **Personal & Origin**: `fullName`, `nameAtBirth`, `dateOfBirth`, `phone`, `birthCity`, `birthState`, `nationalityIdCard`
- **Address**: `address`, `city`, `postalCode`, `country`
- **Driving Licence**: `licenseNumber`, `licenseExpiry`
- **Documents & Permits**: `workPermitType`, `workStartDate`, `annualVacationDays`, remaining-vacation row, `probationEnd` (read-only), `contractExpiry`, `idDocExpiry`, `workVisaExpiry` + `zusatzblattExpiry` (only when `workPermitType == 'working_visa'`)
- **Payment / Tax**: `bankIban`, `insuranceCompany`, `taxId`
- **Emergency**: `emergencyContactName`, `emergencyContactPhone`
- **Uniform**: `tShirtSize`, `shoeSize`
- **Notes**: `notes`

## New widgets
- `_DetailKachel({required title, required icon, required children})` — reusable card hull (~60 LOC)
- `_DetailHeroCard(...)` — composed of existing pieces, just laid out cleanly

## Not in scope
- Edit dialogs themselves
- The score-summary card UI
- Documents file list internals
- Translation keys (existing `t.t('drivers_hub_section_*'/'drivers_hub_field_*')` already cover all labels)

## Implementation strategy
1. Add `_DetailKachel` widget class.
2. Replace the body inside `_openDriverDetails` (lines ~1923–2993) with: hero card + 2-col grid of kacheln + documents card.
3. Keep all field-row calls untouched (`_detailRowEditable`, `_detailRowReadOnly`, `_remainingVacationDaysRow`).
4. Verify via `flutter analyze`.
