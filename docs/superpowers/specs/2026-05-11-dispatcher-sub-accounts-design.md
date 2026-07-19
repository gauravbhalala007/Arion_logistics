# Dispatcher Sub-Accounts

## Goal
Introduce a **dispatcher** role that lives below the main DSP-admin account. The main admin can create dispatcher accounts (email + initial password), and the dispatcher logs into a stripped-down shell of the admin app that only shows the modules the admin has granted in a per-dispatcher permission grid.

## Data model

```
users/{dispatcherUid}                  ← Firebase Auth user, role='dispatcher'
  role: 'dispatcher'
  parentAdminUid: '{adminUid}'         ← link to the main account
  email, displayName
  active: true
  createdAt, updatedAt

users/{adminUid}/sub_accounts/{dispatcherUid}
  email, displayName
  active: bool
  createdAt
  permissions: {
    'waveplan': true,
    'drivers_hub': false,
    'calendar': true,
    'fleet_status': false,
    'tasks': true,
    'shift_absence': false,
    'incident_reports': false,
    'academy': false,
    'dispatcher_pill': false,
    'feedback': false,
    'faqs': true,
    'approvals': false,
  }
```

Permissions are boolean (visible / hidden). Read/write differentiation is out of scope for Phase 1–2.

## Phase 1 — Account provisioning

### Cloud Function `createDispatcherAccount`
Mirror of `createDriverLogin`:
- Caller must be authenticated and `role === 'admin'` (validate via Firestore look-up).
- Inputs: `{email, password, displayName}`.
- Steps:
  1. `auth.createUser({email, password, displayName, emailVerified: true})`
  2. `setCustomUserClaims(newUid, { role: 'dispatcher', parentAdminUid: callerUid })`
  3. Write `users/{newUid}` doc with the fields above
  4. Write `users/{callerUid}/sub_accounts/{newUid}` with default permissions: **`waveplan`, `calendar`, `tasks` = true**, rest false
  5. Return `{uid}`

### Cloud Function `deleteDispatcherAccount`
Mirror of `deleteDriverAccount`:
- Caller must be the parent admin (or developer override).
- Delete Auth user, `users/{uid}` doc, `users/{adminUid}/sub_accounts/{uid}` doc.

### AuthGate routing
Add a `dispatcher` branch:
- `role === 'dispatcher'` → load `parentAdminUid` from `users/{uid}` → push `DispatcherShellPage(parentAdminUid: …)`.

### DispatcherShellPage
- Visually mirrors `AdminShellPage`: side menu on wide, drawer on narrow, `IndexedStack` body.
- Reads `users/{parentAdminUid}/sub_accounts/{currentUid}` once on init for the permission map.
- Renders only the nav items whose permission key is `true`. Permission keys ↔ `AppNav` map below.
- All module bodies are reused 1:1 from `AdminShellPage`, but with `effectiveAdminUid` = `parentAdminUid` instead of `currentUser.uid` so all Firestore reads/writes target the admin's data namespace.
- Profile section shows: "Dispatcher für: {Admin-Name}" + change-password.

### Permission key ↔ AppNav map
| Permission key | `AppNav` enum |
|---|---|
| `waveplan` | `AppNav.waveplan` |
| `drivers_hub` | `AppNav.drivers` |
| `calendar` | `AppNav.calendar` |
| `fleet_status` | `AppNav.fleetStatus` |
| `tasks` | `AppNav.tasks` |
| `shift_absence` | `AppNav.shiftAbsence` |
| `incident_reports` | `AppNav.incidentReports` |
| `academy` | `AppNav.academy` |
| `dispatcher_pill` | `AppNav.dispatcherPill` |
| `feedback` | `AppNav.feedback` |
| `faqs` | `AppNav.faqs` |
| `approvals` | `AppNav.approvals` |

(Home and Profile are always visible.)

## Phase 2 — Permission management UI

New admin nav item **"Dispatcher-Accounts"** (`AppNav.dispatchers`), inserted between Profile and Notifications.

### Page layout
- Header: title + "+ Anlegen" button.
- List: streams `users/{adminUid}/sub_accounts/*` — each row shows email, displayName, active flag, and an "Edit" / "Delete" trailing action.
- Tap on row → detail page with:
  - Inactive toggle (deactivate without deleting).
  - **Permission grid** — one toggle per permission key from the map above, with the human-readable module name in the active locale.
  - Save writes the permissions map back atomically.
- "+ Anlegen" dialog → calls `createDispatcherAccount` Cloud Function.
- Edit dialog → updates email/displayName (Auth + doc) via `updateDispatcherAccount` function or direct admin-SDK call.

### Live application of permission changes
When the admin flips a toggle, the dispatcher's shell rebuilds the next time they navigate (we read the doc on shell init). Optional: stream the sub-account doc so changes are instant. Phase-2 ships with init-only read; instant updates can come later.

## Phase 3 — out of scope here

- Read/write split per module (currently a toggle only hides the module — once visible, dispatcher has the same write access as the admin).
- Audit log of dispatcher actions.
- Mass-invite / bulk import.

## Firestore Security Rules

Add helpers:
```
function isDispatcher() {
  return request.auth != null && getRole() == 'dispatcher';
}

function dispatcherParentUid() {
  return get(/databases/$(database)/documents/users/$(request.auth.uid))
    .data.parentAdminUid;
}

function isDispatcherOf(adminUid) {
  return isDispatcher() && dispatcherParentUid() == adminUid;
}
```

Every rule that currently grants admin read/write to `users/{adminUid}/...` is extended with `|| isDispatcherOf(adminUid)`. Phase 1 does NOT gate Rules by individual permissions — UI gating handles that, Rules only enforce cross-admin isolation. Phase 3 would tighten this.

The `sub_accounts/*` subcollection is admin-only:
```
match /users/{adminUid}/sub_accounts/{subUid} {
  allow read, write: if isAdmin() && request.auth.uid == adminUid;
}
```

## Module-level handling
All admin modules currently use `FirebaseAuth.instance.currentUser!.uid` to scope queries. For DispatcherShell to reuse them, we pass `effectiveAdminUid` down. Two options:

1. **Wrapper widgets** that override the `currentUid` getter — invasive, every screen needs touching.
2. **InheritedWidget `AdminScope.of(context).adminUid`** — modules call `AdminScope.of(context)?.adminUid ?? auth.currentUser.uid`. Default fallback keeps admin shell unchanged; dispatcher shell wraps body in `AdminScope(parentAdminUid)`.

Use option 2 — minimal touch points (one new file `lib/widgets/admin_scope.dart`, plus each module changes `currentUser.uid` to `AdminScope.adminUidOf(context)`).

## Not in scope
- Driver app changes (drivers don't see dispatchers; dispatchers don't see drivers' own dashboard).
- Email verification for dispatcher accounts (admin-provisioned → `emailVerified: true`).
- Multi-admin parent (one dispatcher belongs to exactly one admin).
- Translation of permission labels (Phase 2 adds the keys; can localize later).

## Implementation order (single delivery batch)
1. Cloud Functions `createDispatcherAccount`, `deleteDispatcherAccount`, `updateDispatcherAccount`.
2. Firestore rules: add helpers + sub_accounts rule + extend admin rules with `|| isDispatcherOf(…)` where needed.
3. `AdminScope` InheritedWidget + retrofit one module to confirm the wiring (start with Waveplan since it's the smallest scope).
4. `DispatcherShellPage` + nav rendering by permission map.
5. Update `AuthGate` to route dispatcher → DispatcherShellPage.
6. Admin "Dispatcher-Accounts" page (list + create dialog + permission grid + delete).
7. Retrofit remaining admin modules to use `AdminScope.adminUidOf(context)`.
8. Translations for the new strings.
9. Deploy: Functions → Hosting → done.
