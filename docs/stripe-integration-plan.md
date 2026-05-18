# Stripe-Integration — Trial + Abo

Stand: 13. Mai 2026
Status: **Planung** (noch nicht implementiert)

---

## 0. Entscheidungen (final)

| Punkt | Entscheidung |
|---|---|
| **Plan** | 1 Plan „CoDriver Pro", Preis **pro Station** |
| **Preis** | **€100 / Station / Monat** (netto) |
| **Trial** | 30 Tage, Karte wird hinterlegt, **kein** automatischer Übergang in Abo |
| **Stripe Tax** | Aktiviert (USt. wird automatisch berechnet) |
| **Dispatcher** | Inklusive, keine Zusatzkosten |
| **Station-Erfassung** | Automatisch aus hochgeladenen Scorecards — der Preis pro Station muss aber im UI klar kommuniziert werden |

---

## 1. Architektur

```
                                          ┌────────────────────────┐
                                          │  Stripe                │
                                          │  • Customer            │
                                          │  • Subscription        │
                                          │  • PaymentMethod       │
                                          │  • Stripe Tax          │
                                          └───┬───────────────┬────┘
                                              │ webhook        │ callable
                                              ▼                ▲
┌────────────┐  callable    ┌──────────────────────────────────────────┐
│ Flutter Web│ ───────────► │ Cloud Functions (TypeScript)             │
│ (Admin/    │              │ • createCheckoutSession                  │
│  Dispatch) │ ◄─────────── │ • createPortalSession                    │
└─────┬──────┘  Firestore   │ • stripeWebhook (HTTP)                   │
      │  stream             │ • onScorecardUpload (trigger)            │
      │                     │ • dailyTrialEnforcement (scheduled)      │
      ▼                     └────────────────┬─────────────────────────┘
┌────────────┐                               │
│ Firestore  │ ◄─────────────────────────────┘
│ users/{uid}│
│  .subscrip-│
│   tion     │
│  .stations │
└────────────┘
```

---

## 2. Datenmodell

### `users/{adminUid}` — Erweiterung
```jsonc
{
  // … bestehende Felder bleiben unverändert …

  "subscription": {
    "stripeCustomerId": "cus_xxx",
    "stripeSubscriptionId": "sub_xxx",
    "status": "trialing | active | past_due | canceled | unpaid",
    "trialStart": <Timestamp>,
    "trialEnd": <Timestamp>,
    "currentPeriodEnd": <Timestamp>,
    "plan": "monthly",
    "priceId": "price_xxx",
    "stationsQuantity": 2,
    "graceUntil": <Timestamp>,    // 14 Tage nach Trial- oder Sub-Ende
    "lastSyncedAt": <Timestamp>
  },

  "stations": {
    "DBY5": { "firstSeenAt": <Timestamp>, "label": "Berlin DBY5" },
    "DBV1": { "firstSeenAt": <Timestamp>, "label": "Düsseldorf DBV1" }
  },

  "billingEmail": "info@dsp-x.de",         // separat von Auth-Email
  "billingAddress": {                        // für Stripe Tax
    "line1": "Musterstr. 1",
    "city": "Berlin",
    "postal_code": "10115",
    "country": "DE"
  }
}
```

### `users/{adminUid}/invoices/{invoiceId}` — neu (Cache der Stripe-Rechnungen)
```jsonc
{
  "stripeInvoiceId": "in_xxx",
  "amountTotal": 11900,            // Cent inkl. USt.
  "amountSubtotal": 10000,
  "amountTax": 1900,
  "currency": "eur",
  "status": "paid | open | uncollectible | void",
  "hostedInvoiceUrl": "https://invoice.stripe.com/i/...",
  "invoicePdfUrl": "https://pay.stripe.com/...",
  "periodStart": <Timestamp>,
  "periodEnd": <Timestamp>,
  "createdAt": <Timestamp>
}
```

---

## 3. Stripe-Setup (Dashboard)

Einmalige Konfiguration, **bevor** Code deployt wird:

1. **Stripe-Account** (Test-Mode)
2. **Product anlegen**: „CoDriver Pro"
   - **Pricing model**: Recurring · Quantity-based
   - **Price**: €100,00 / Monat / Einheit, EUR
   - **Tax behavior**: Exclusive (Stripe Tax rechnet drauf)
3. **Stripe Tax aktivieren** → Settings → Tax → Enable
   - Origin Address: deine DSP-Geschäftsadresse
   - Registrierungen: DE, EU-OSS optional
4. **Customer Portal** aktivieren → Settings → Billing → Customer Portal
   - Erlauben: Karte updaten, Rechnungen sehen, Plan kündigen
   - **Nicht** erlauben: Quantity ändern (das macht CoDriver selbst über Scorecard-Upload)
5. **Webhook** anlegen → Developers → Webhooks
   - Endpoint URL: `https://europe-west3-gaurav-arion-001-3d94a.cloudfunctions.net/stripeWebhook`
   - Events:
     - `customer.subscription.created`
     - `customer.subscription.updated`
     - `customer.subscription.deleted`
     - `customer.subscription.trial_will_end`
     - `invoice.paid`
     - `invoice.payment_failed`
     - `invoice.finalized`
6. **Keys notieren**:
   - `STRIPE_SECRET_KEY` (sk_test_…)
   - `STRIPE_PUBLISHABLE_KEY` (pk_test_…)
   - `STRIPE_WEBHOOK_SECRET` (whsec_…)
   - `STRIPE_PRICE_ID` (price_…)

   → in Firebase Functions als Secrets ablegen:
   ```
   firebase functions:secrets:set STRIPE_SECRET_KEY
   firebase functions:secrets:set STRIPE_WEBHOOK_SECRET
   ```

---

## 4. Phase 1 — Trial-Init + Customer-Creation

**Ziel**: Neue Signups bekommen direkt einen Stripe-Customer + Trial. Kartenhinterlegung passiert per Stripe Checkout.

### Cloud Function: `onAdminApproved`
**Trigger**: Firestore `users/{adminUid}` `onWrite`, wenn `approved` von `false → true`.

```ts
// firebase/functions/src/billing/onAdminApproved.ts
import { onDocumentWritten } from 'firebase-functions/v2/firestore';
import { defineSecret } from 'firebase-functions/params';
import Stripe from 'stripe';

const stripeSecret = defineSecret('STRIPE_SECRET_KEY');

export const onAdminApproved = onDocumentWritten(
  { document: 'users/{adminUid}', secrets: [stripeSecret] },
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (!after) return;

    // Nur beim Approved-Übergang reagieren
    if (before?.approved === true || after.approved !== true) return;
    if (after.role !== 'admin') return;
    if (after.subscription?.stripeCustomerId) return; // schon initialisiert

    const stripe = new Stripe(stripeSecret.value(), { apiVersion: '2024-06-20' });

    // 1) Customer anlegen
    const customer = await stripe.customers.create({
      email: after.billingEmail ?? after.email,
      name: after.companyName ?? after.driverName,
      metadata: { firebaseUid: event.params.adminUid },
      // Stripe Tax: Adresse so früh wie möglich setzen,
      // damit USt. korrekt berechnet wird
      address: after.billingAddress
        ? {
            line1: after.billingAddress.line1,
            city: after.billingAddress.city,
            postal_code: after.billingAddress.postal_code,
            country: after.billingAddress.country,
          }
        : undefined,
    });

    const now = admin.firestore.Timestamp.now();
    const trialEnd = admin.firestore.Timestamp.fromMillis(
      now.toMillis() + 30 * 24 * 60 * 60 * 1000,
    );

    await event.data!.after.ref.update({
      'subscription.stripeCustomerId': customer.id,
      'subscription.status': 'trialing',
      'subscription.trialStart': now,
      'subscription.trialEnd': trialEnd,
      'subscription.stationsQuantity': 0,
      'subscription.lastSyncedAt': now,
    });
  },
);
```

### Cloud Function: `createCheckoutSession` (callable)
Wird von Flutter beim Klick auf „Karte hinterlegen" / „Reaktivieren" aufgerufen.

```ts
// firebase/functions/src/billing/createCheckoutSession.ts
import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { defineSecret } from 'firebase-functions/params';
import Stripe from 'stripe';

const stripeSecret = defineSecret('STRIPE_SECRET_KEY');
const PRICE_ID = defineSecret('STRIPE_PRICE_ID');

export const createCheckoutSession = onCall(
  { secrets: [stripeSecret, PRICE_ID] },
  async (req) => {
    const uid = req.auth?.uid;
    if (!uid) throw new HttpsError('unauthenticated', 'Login required');

    const stripe = new Stripe(stripeSecret.value(), { apiVersion: '2024-06-20' });
    const userSnap = await db.collection('users').doc(uid).get();
    const userData = userSnap.data() ?? {};
    const customerId = userData.subscription?.stripeCustomerId;
    if (!customerId) {
      throw new HttpsError('failed-precondition', 'No Stripe customer');
    }

    const quantity = userData.subscription?.stationsQuantity ?? 1;
    const isTrial = !userData.subscription?.stripeSubscriptionId
                    && userData.subscription?.status === 'trialing';

    const session = await stripe.checkout.sessions.create({
      mode: 'subscription',
      customer: customerId,
      line_items: [{ price: PRICE_ID.value(), quantity }],
      subscription_data: {
        // Beim ersten Mal Trial direkt drauf — beim "Reaktivieren" nicht
        trial_period_days: isTrial ? 30 : undefined,
        // Wichtig: Sub endet automatisch nach Trial,
        // kein Auto-Charge ohne explizite Reaktivierung
        trial_settings: isTrial
          ? { end_behavior: { missing_payment_method: 'cancel' } }
          : undefined,
        cancel_at_period_end: isTrial,
      },
      automatic_tax: { enabled: true },
      tax_id_collection: { enabled: true },
      billing_address_collection: 'required',
      customer_update: { address: 'auto', name: 'auto' },
      success_url: `${req.data.appUrl}/#/billing?success=true`,
      cancel_url: `${req.data.appUrl}/#/billing?canceled=true`,
    });

    return { url: session.url };
  },
);
```

### Cloud Function: `createPortalSession` (callable)
Öffnet Stripe-Customer-Portal für Karten-Update / Rechnungseinsicht.

```ts
export const createPortalSession = onCall(
  { secrets: [stripeSecret] },
  async (req) => {
    const uid = req.auth?.uid;
    if (!uid) throw new HttpsError('unauthenticated', 'Login required');
    // … wie oben, dann:
    const session = await stripe.billingPortal.sessions.create({
      customer: customerId,
      return_url: `${req.data.appUrl}/#/billing`,
    });
    return { url: session.url };
  },
);
```

---

## 5. Phase 2 — Webhook + Subscription-Sync

**Ziel**: Stripe ist Source-of-Truth für den Subscription-Status. Firestore wird via Webhook aktuell gehalten.

### Cloud Function: `stripeWebhook` (HTTP)
```ts
// firebase/functions/src/billing/stripeWebhook.ts
import { onRequest } from 'firebase-functions/v2/https';
import Stripe from 'stripe';

export const stripeWebhook = onRequest(
  { secrets: [stripeSecret, webhookSecret], cors: false },
  async (req, res) => {
    const stripe = new Stripe(stripeSecret.value(), { apiVersion: '2024-06-20' });
    let event: Stripe.Event;
    try {
      event = stripe.webhooks.constructEvent(
        req.rawBody,
        req.headers['stripe-signature']!,
        webhookSecret.value(),
      );
    } catch (err) {
      res.status(400).send(`Webhook signature error: ${err}`);
      return;
    }

    switch (event.type) {
      case 'customer.subscription.created':
      case 'customer.subscription.updated':
      case 'customer.subscription.deleted':
        await syncSubscription(event.data.object as Stripe.Subscription);
        break;
      case 'invoice.paid':
      case 'invoice.payment_failed':
      case 'invoice.finalized':
        await cacheInvoice(event.data.object as Stripe.Invoice);
        break;
      case 'customer.subscription.trial_will_end':
        await sendTrialEndingEmail(event.data.object as Stripe.Subscription);
        break;
    }
    res.json({ received: true });
  },
);

async function syncSubscription(sub: Stripe.Subscription) {
  const uid = await uidForCustomer(sub.customer as string);
  if (!uid) return;

  await db.collection('users').doc(uid).update({
    'subscription.stripeSubscriptionId': sub.id,
    'subscription.status': sub.status,
    'subscription.trialEnd': sub.trial_end
      ? admin.firestore.Timestamp.fromMillis(sub.trial_end * 1000)
      : null,
    'subscription.currentPeriodEnd': admin.firestore.Timestamp.fromMillis(
      sub.current_period_end * 1000,
    ),
    'subscription.cancelAtPeriodEnd': sub.cancel_at_period_end,
    'subscription.priceId': sub.items.data[0]?.price.id,
    'subscription.stationsQuantity': sub.items.data[0]?.quantity ?? 1,
    'subscription.lastSyncedAt': admin.firestore.Timestamp.now(),
  });
}

async function cacheInvoice(inv: Stripe.Invoice) {
  const uid = await uidForCustomer(inv.customer as string);
  if (!uid) return;
  await db
    .collection('users').doc(uid)
    .collection('invoices').doc(inv.id)
    .set({
      stripeInvoiceId: inv.id,
      amountTotal: inv.total,
      amountSubtotal: inv.subtotal,
      amountTax: inv.tax ?? 0,
      currency: inv.currency,
      status: inv.status,
      hostedInvoiceUrl: inv.hosted_invoice_url,
      invoicePdfUrl: inv.invoice_pdf,
      periodStart: admin.firestore.Timestamp.fromMillis(inv.period_start * 1000),
      periodEnd: admin.firestore.Timestamp.fromMillis(inv.period_end * 1000),
      createdAt: admin.firestore.Timestamp.fromMillis(inv.created * 1000),
    }, { merge: true });
}
```

### Cloud Function: `onScorecardUploaded` (Trigger)
Aktualisiert die Anzahl Stationen → Stripe-Subscription-Quantity.

```ts
export const onScorecardUploaded = onDocumentCreated(
  'users/{adminUid}/reports/{reportId}',
  async (event) => {
    const adminUid = event.params.adminUid;
    const data = event.data?.data();
    const stationCode = data?.summary?.stationCode;
    if (!stationCode) return;

    const userRef = db.collection('users').doc(adminUid);
    const userSnap = await userRef.get();
    const stations = userSnap.data()?.stations ?? {};

    if (stations[stationCode]) return; // schon erfasst

    // Neue Station → Firestore + Stripe-Quantity hochzählen
    const newCount = Object.keys(stations).length + 1;
    await userRef.update({
      [`stations.${stationCode}`]: {
        firstSeenAt: admin.firestore.Timestamp.now(),
        label: stationCode,
      },
      'subscription.stationsQuantity': newCount,
    });

    const subId = userSnap.data()?.subscription?.stripeSubscriptionId;
    if (subId) {
      const stripe = new Stripe(stripeSecret.value(), { apiVersion: '2024-06-20' });
      const sub = await stripe.subscriptions.retrieve(subId);
      await stripe.subscriptions.update(subId, {
        items: [{ id: sub.items.data[0].id, quantity: newCount }],
        proration_behavior: 'create_prorations',
      });
    }
  },
);
```

### Cloud Function: `dailyTrialEnforcement` (Scheduled)
Läuft täglich um 03:00 UTC und setzt abgelaufene Trials in Read-only-Grace.

```ts
export const dailyTrialEnforcement = onSchedule('0 3 * * *', async () => {
  const now = admin.firestore.Timestamp.now();
  const q = await db.collection('users')
    .where('subscription.status', '==', 'trialing')
    .where('subscription.trialEnd', '<', now)
    .get();

  for (const doc of q.docs) {
    const graceUntil = admin.firestore.Timestamp.fromMillis(
      now.toMillis() + 14 * 24 * 60 * 60 * 1000,
    );
    await doc.ref.update({
      'subscription.status': 'canceled',
      'subscription.graceUntil': graceUntil,
    });
  }
});
```

---

## 6. Phase 3 — Flutter UI

### Neue Files
- `lib/services/billing_service.dart` — Wrapper für Cloud Functions
- `lib/widgets/subscription_guard.dart` — Banner / Read-only-Overlay
- `lib/Screens/admin_billing_page.dart` — Settings-Page mit Plan, Karte, Rechnungen
- `lib/widgets/station_pricing_card.dart` — wiederverwendbar: zeigt „2 Stationen × €100 = €200/Monat"

### `BillingService` (Wrapper)
```dart
class BillingService {
  static final _functions = FirebaseFunctions.instanceFor(region: 'europe-west3');

  static Future<String> openCheckout() async {
    final result = await _functions
        .httpsCallable('createCheckoutSession')
        .call({'appUrl': Uri.base.origin});
    return result.data['url'] as String;
  }

  static Future<String> openPortal() async {
    final result = await _functions
        .httpsCallable('createPortalSession')
        .call({'appUrl': Uri.base.origin});
    return result.data['url'] as String;
  }
}
```

### `SubscriptionGuard` (umhüllt AdminShellPage)
```dart
class SubscriptionGuard extends StatelessWidget {
  final Widget child;
  const SubscriptionGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final uid = AdminScope.adminUidOf(context);
    if (uid == null) return child;
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, snap) {
        final sub = snap.data?.data()?['subscription'] as Map<String, dynamic>?;
        final status = sub?['status'] as String? ?? 'trialing';
        final trialEnd = (sub?['trialEnd'] as Timestamp?)?.toDate();
        final graceUntil = (sub?['graceUntil'] as Timestamp?)?.toDate();
        final now = DateTime.now();

        // 1. Trialing → Banner mit X Tagen verbleibend
        if (status == 'trialing' && trialEnd != null) {
          final daysLeft = trialEnd.difference(now).inDays;
          return _withBanner(child, _TrialBanner(daysLeft: daysLeft));
        }

        // 2. Canceled + Grace → Read-only Banner
        if (status == 'canceled' && graceUntil != null && graceUntil.isAfter(now)) {
          return _withBanner(child, _GraceBanner(graceUntil: graceUntil));
        }

        // 3. Grace abgelaufen → Vollscreen-Block
        if (status == 'canceled' && graceUntil != null && graceUntil.isBefore(now)) {
          return const _ReactivateScreen();
        }

        // 4. Active → keine UI-Änderung
        return child;
      },
    );
  }
}
```

Eingehängt in `auth_gate.dart`:
```dart
return AdminScope(
  adminUid: parentAdminUid,
  child: const SubscriptionGuard(
    child: AdminShellPage(initialNav: AppNav.home),
  ),
);
```

### Billing-Page Layout (`admin_billing_page.dart`)
```
┌─ Header ────────────────────────────────────────┐
│ ABO & RECHNUNGEN                                 │
└──────────────────────────────────────────────────┘

┌─ Plan-Karte (grün, Apple-Hero) ──────────────────┐
│ CoDriver Pro                  STATUS · TRIAL     │
│ €100 × 2 Stationen = €200 / Monat                │
│ Trial läuft 18 Tage                              │
│                                                  │
│ [Karte hinterlegen & aktivieren]                 │
└──────────────────────────────────────────────────┘

┌─ Stationen ──────────────────────────────────────┐
│ • DBY5  Berlin             seit 12.05.2026       │
│ • DBV1  Düsseldorf         seit 03.05.2026       │
│ Jede zusätzliche Station kostet €100 / Monat.    │
└──────────────────────────────────────────────────┘

┌─ Zahlungsmethode ────────────────────────────────┐
│ [Karte verwalten]   öffnet Stripe Portal         │
└──────────────────────────────────────────────────┘

┌─ Rechnungen ─────────────────────────────────────┐
│ Mai 2026   €238,00   PAID    [PDF]               │
│ April 2026 €238,00   PAID    [PDF]               │
└──────────────────────────────────────────────────┘
```

### Side-Menu-Eintrag
Neuer `AppNav.billing` in `app_side_menu.dart`, nur für Admin-Rolle (nicht Dispatcher), zwischen „Profil" und „Logout":
```dart
_MenuItem(
  icon: Icons.credit_card_rounded,
  label: 'Abo & Rechnungen',
  active: active == AppNav.billing,
  onTap: () => _handleNav(context, AppNav.billing, '/billing'),
),
```

---

## 7. Sicherheits-Layer (Firestore Rules)

In `firebase/firestore.rules`:
```
function subscriptionAllowsWrites(userId) {
  let sub = get(/databases/$(database)/documents/users/$(userId)).data.subscription;
  return sub == null  // Migration: bestehende Nutzer ohne Sub-Feld
    || sub.status in ['trialing', 'active']
    || (sub.status == 'canceled' && request.time < sub.graceUntil);
}
```

Auf jeder schreibenden Regel anwenden:
```
match /users/{userId}/{document=**} {
  allow read: if isSelf(userId) || isDispatcherOf(userId);
  allow write: if (isSelf(userId) || isDispatcherOf(userId))
                && subscriptionAllowsWrites(userId);
}
```

→ Read ist immer erlaubt (auch nach Grace-Ende → Daten bleiben einsehbar), aber Writes sind während Grace + nach Grace gesperrt.

---

## 8. UX-Texte (Trial-Banner)

| Zustand | Banner-Text |
|---|---|
| Trial Tag 1–14 | „**X Tage Trial verbleibend.** Stationen werden automatisch erkannt — €100 / Station / Monat. [Jetzt aktivieren]" |
| Trial Tag 15–28 | „**Trial endet in X Tagen.** Karte hinterlegen, um nach dem Trial weiter arbeiten zu können. [Jetzt aktivieren]" |
| Trial Tag 29-30 | „**Trial endet morgen.** Heute aktivieren für nahtlosen Übergang. [Jetzt aktivieren]" |
| Read-only Grace | „**Trial abgelaufen.** Du kannst noch X Tage Daten einsehen, aber keine Änderungen vornehmen. [Plan aktivieren]" |
| Grace abgelaufen | Vollscreen-Block: „Dein Account ist pausiert. Aktiviere CoDriver Pro für €100 / Station / Monat. [Reaktivieren]" |

---

## 9. Roll-out-Sequenz

| Phase | Was | Geschätzt |
|---|---|---|
| **0** | Stripe-Dashboard-Setup (Product, Price, Tax, Webhook, Portal) | 1 h |
| **1** | Cloud Functions: `onAdminApproved`, `createCheckoutSession`, `createPortalSession` | 1–2 Tage |
| **2** | Cloud Functions: `stripeWebhook`, `onScorecardUploaded`, `dailyTrialEnforcement` | 2 Tage |
| **3** | Flutter: `BillingService`, `SubscriptionGuard`, `AdminBillingPage`, Side-Menu-Eintrag | 2 Tage |
| **4** | Firestore Rules + Migrations-Script für bestehende Nutzer | 0.5 Tag |
| **5** | Live-Mode-Switch, Real-Card-Test, Monitoring | 0.5 Tag |

**Test-Mode-Phase**: alle Phasen werden zuerst in Stripe-Test-Mode entwickelt und getestet (Test-Karten `4242 4242 4242 4242` etc.). Erst nach erfolgreichem End-to-End-Test wird in Live-Mode geschaltet.

---

## 10. Migrations-Strategie für Bestandskunden

Vorhandene `users/{uid}`-Docs ohne `subscription`-Feld werden bei Deployment so behandelt:

**Option A (empfohlen)**: One-off Cloud Function `seedExistingAccounts` läuft einmalig und legt für jeden bestehenden Admin:
- Stripe-Customer an
- Setzt `subscription.status = 'trialing'`
- `trialEnd = now + 30 Tage`

So bekommen alle Bestandskunden noch einmal 30 Tage Karenz, in denen sie ihren Plan auswählen können.

**Option B**: Sofort `status = 'active'` setzen mit `trialEnd = null` und `currentPeriodEnd = +1 Monat`, dann müssen sie **vor** Ende des ersten Monats die Karte hinterlegen. Härter aber klarer.

---

## 11. Was nicht im MVP ist (für später)

- **Jahresabo / Discount** — Phase 2.0
- **Promo-Codes** (z. B. Pilotkunden 50 % Rabatt) — kann via Stripe Dashboard händisch
- **Team-Management** über Stripe (mehrere Admins pro Subscription) — wir haben Dispatcher inkludiert, weitere Admin-Slots ggf. später
- **Lifetime / One-time Pricing** — nicht geplant
- **Multi-Currency** — nur EUR im MVP

---

## 12. Was du jetzt machen musst

Bevor wir Phase 1 starten:

1. **Stripe-Account erstellen** (Test-Mode reicht für Start), Business-Details ausfüllen
2. **Product + Price** anlegen wie in Abschnitt 3
3. **Stripe Tax aktivieren** und Registrierungen pflegen
4. **Webhook-Endpoint** mit der Cloud-Function-URL anlegen (URL liefert Phase 1 Deployment)
5. **Keys** in Firebase-Secrets ablegen

Sobald das steht, sag Bescheid und ich fang mit Phase 1 an.
