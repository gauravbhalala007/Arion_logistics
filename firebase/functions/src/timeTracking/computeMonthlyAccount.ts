/* eslint-disable max-len, require-jsdoc, valid-jsdoc, object-curly-spacing, operator-linebreak, indent, no-trailing-spaces, eol-last, quotes, comma-dangle */
// firebase/functions/src/timeTracking/computeMonthlyAccount.ts
//
// Täglicher Job um 03:00 UTC: aggregiert alle Schichten des aktuellen
// Monats pro Driver in `time_account/{YYYY-MM}`.
//
// Berechnet Soll-Stunden anhand:
//   • dailyContractHours × Anzahl Werktage des Monats
//   • abzüglich Feiertage des Driver-Bundeslandes
//   • abzüglich Urlaubs- und Krankheitstage
//
// Ist-Stunden = Summe `workDuration` aller geschlossenen Schichten

import {onSchedule} from "firebase-functions/v2/scheduler";
import {onCall, HttpsError} from "firebase-functions/v2/https";
import {getFirestore, Timestamp} from "firebase-admin/firestore";
import * as logger from "firebase-functions/logger";

const REGION = "europe-west3";

interface DriverEmployment {
  // Soll-Berechnungsmodus:
  //  'fixed_monthly'  → konstantes monatliches Soll (z.B. 173 h DE-Standard)
  //  'workday_based'  → Arbeitstage × dailyContractHours – Feiertage (variiert)
  sollMode?: "fixed_monthly" | "workday_based";
  // Nur für fixed_monthly genutzt:
  monthlyContractHours?: number;
  // Für workday_based + zur Info-Anzeige:
  weeklyContractHours?: number;
  dailyContractHours?: number;
  workingDays?: string[];
  bundesland?: string;
}

function ym(date: Date): string {
  const y = date.getUTCFullYear();
  const m = String(date.getUTCMonth() + 1).padStart(2, "0");
  return `${y}-${m}`;
}

function workingDaysInMonth(
  year: number,
  month: number,
  workingDays: string[],
): Date[] {
  const map: Record<string, number> = {
    SU: 0, MO: 1, TU: 2, WE: 3, TH: 4, FR: 5, SA: 6,
  };
  const allowed = new Set(workingDays.map((d) => map[d.toUpperCase()]));
  const out: Date[] = [];
  const last = new Date(Date.UTC(year, month, 0)).getUTCDate();
  for (let d = 1; d <= last; d++) {
    const date = new Date(Date.UTC(year, month - 1, d));
    if (allowed.has(date.getUTCDay())) out.push(date);
  }
  return out;
}

// Gemeinsame Compute-Logik — wird vom Cron UND vom manuellen onCall
// genutzt. Optional `forAdminUid` (nur dieser Admin) + `forMonth`
// (YYYY-MM, default = aktueller Monat).
export async function runMonthlyCompute(opts: {
  forAdminUid?: string;
  forMonth?: string;
}): Promise<{adminsProcessed: number; driversProcessed: number}> {
  const db = getFirestore();

  const month = opts.forMonth ?? ym(new Date());
  const [year, monthNum] = month.split("-").map(Number);

  // Hole alle Admin-Konten die das Zeit-Modul aktiviert haben.
  // (Owner-Email-Whitelist als Phase-1-Fallback.)
  let owners;
  if (opts.forAdminUid) {
    const oneDoc = await db.collection("users").doc(opts.forAdminUid).get();
    owners = {docs: oneDoc.exists ? [oneDoc] : []};
  } else {
    owners = await db
      .collection("users")
      .where("role", "==", "admin")
      .get();
  }

  let adminsProcessed = 0;
  let driversProcessed = 0;
  for (const adminDoc of owners.docs) {
    const adminUid = adminDoc.id;
    const addons = (adminDoc.data() ?? {}).addons ?? {};
    const email = ((adminDoc.data() ?? {}).email ?? "").toLowerCase();
    const allowedEmails = [
      "admin@arion-logistics.de",
      "test@arion-logistics.de",
    ];
    if (!addons.timeTracking && !allowedEmails.includes(email)) continue;
    adminsProcessed++;

    // Company-wide employment settings (gilt für alle Fahrer dieses Admins).
    // Stored at users/{adminUid}.cotimerEmployment. Per-Fahrer-Overrides
    // sind aktuell nicht vorgesehen — alle Fahrer eines DSP teilen sich
    // Soll-Modus / Vertragsstunden / Bundesland.
    const companyEmployment =
      ((adminDoc.data() ?? {}).cotimerEmployment ?? {}) as DriverEmployment;

    const drivers = await db
      .collection("users")
      .doc(adminUid)
      .collection("drivers")
      .get();

    for (const driverDoc of drivers.docs) {
      const driverId = driverDoc.id;
      const employment = companyEmployment;
      const sollMode = employment.sollMode ?? "workday_based";
      const dailyHours = employment.dailyContractHours ?? 8;
      const workingDays =
        employment.workingDays ?? ["MO", "TU", "WE", "TH", "FR"];
      const bundesland = employment.bundesland ?? "DE_ALL";

      // Arbeitstage + Feiertage berechnen (auch im fixed-Mode nützlich
      // für die UI-Anzeige).
      const days = workingDaysInMonth(year, monthNum, workingDays);
      const holidaysSnap = await db
        .collection("global_holidays")
        .where("year", "==", year)
        .where("state", "in", [bundesland, "DE_ALL"])
        .get();
      const holidayDates = new Set(
        holidaysSnap.docs
          .map((d) => d.data().date as string)
          .filter((d) => d?.startsWith(month)),
      );
      const effectiveDays = days.filter(
        (d) => !holidayDates.has(d.toISOString().slice(0, 10)),
      );

      // Soll-Sekunden je nach Modus
      let sollSeconds: number;
      if (sollMode === "fixed_monthly") {
        const monthly = employment.monthlyContractHours ?? 173;
        sollSeconds = monthly * 3600;
      } else {
        sollSeconds = effectiveDays.length * dailyHours * 3600;
      }

      // Ist-Stunden aus geschlossenen Schichten des Monats
      const monthStart = new Date(Date.UTC(year, monthNum - 1, 1));
      const monthEnd = new Date(Date.UTC(year, monthNum, 1));
      const shiftsSnap = await db
        .collection(`users/${adminUid}/drivers/${driverId}/shifts`)
        .where("startTs", ">=", Timestamp.fromDate(monthStart))
        .where("startTs", "<", Timestamp.fromDate(monthEnd))
        .where("isOpen", "==", false)
        .get();

      const stampedSeconds = shiftsSnap.docs.reduce(
        (sum, s) => sum + ((s.data().workDuration as number) ?? 0),
        0,
      );

      // Spesen-Tracking (DE Verpflegungspauschale, steuerfrei).
      // Bedingung: Abwesenheit/Arbeit > 8 h an einem Tag → 1 Spesen-
      // Tag à 14 €. Bei > 24 h gilt der volle Tagessatz von 28 €
      // (Fahrer-Use-Case selten — wir bewerten konservativ pro
      // Schicht: > 8 h = 14 €).
      const SPESEN_THRESHOLD_SEC = 8 * 3600;
      const SPESEN_PER_DAY_EUR = 14.0;
      const spesenShifts = shiftsSnap.docs.filter((s) => {
        const total = (s.data().totalDuration as number) ?? 0;
        const work = (s.data().workDuration as number) ?? 0;
        // Auf Total (inkl. Pausen) abstellen, weil die Pauschale die
        // Abwesenheits-Dauer voraussetzt, nicht die reine Arbeitszeit.
        const dur = Math.max(total, work);
        return dur >= SPESEN_THRESHOLD_SEC;
      });
      const spesenDays = spesenShifts.length;
      const spesenAmount = +(spesenDays * SPESEN_PER_DAY_EUR).toFixed(2);

      // ── Urlaubs- und Krankentage anrechnen ──────────────────────
      // Lade approved Absences, die sich mit dem Monat überschneiden,
      // und zähle die abgedeckten Werktage (nach workingDays, ohne
      // Feiertage). Pro Tag werden dailyContractHours dem Ist gutge-
      // schrieben — bezahlte Freistellung in DE-Standard.
      const absSnap = await db
        .collection(
          `users/${adminUid}/drivers/${driverId}/absence_requests`,
        )
        .where("status", "==", "approved")
        .get();
      const workingWeekdaySet = new Set(
        workingDays.map((d) => {
          const map: Record<string, number> = {
            SU: 0, MO: 1, TU: 2, WE: 3, TH: 4, FR: 5, SA: 6,
          };
          return map[d.toUpperCase()];
        }),
      );
      let vacationDays = 0;
      let sickDays = 0;
      for (const aDoc of absSnap.docs) {
        const ad = aDoc.data();
        const type = (ad.type ?? "").toString();
        const fromTs = ad.fromDate as FirebaseFirestore.Timestamp | null;
        const toTs = ad.toDate as FirebaseFirestore.Timestamp | null;
        if (!fromTs || !toTs) continue;
        const from = fromTs.toDate();
        const to = toTs.toDate();
        // Iteriere Tag-für-Tag über die Schnittmenge mit [monthStart,
        // monthEnd) und zähle nur Werktage (= im workingDays-Set) die
        // nicht auch Feiertag sind.
        const startIter = from < monthStart ? monthStart : from;
        const endIter = to >= monthEnd
          ? new Date(monthEnd.getTime() - 24 * 3600 * 1000)
          : to;
        const cursor = new Date(Date.UTC(
          startIter.getUTCFullYear(),
          startIter.getUTCMonth(),
          startIter.getUTCDate(),
        ));
        const stop = new Date(Date.UTC(
          endIter.getUTCFullYear(),
          endIter.getUTCMonth(),
          endIter.getUTCDate(),
        ));
        while (cursor.getTime() <= stop.getTime()) {
          const iso = cursor.toISOString().slice(0, 10);
          const isHoliday = holidayDates.has(iso);
          const isWorkday =
            workingWeekdaySet.has(cursor.getUTCDay());
          if (isWorkday && !isHoliday) {
            if (type === "vacation") vacationDays++;
            else if (type === "sick") sickDays++;
          }
          cursor.setUTCDate(cursor.getUTCDate() + 1);
        }
      }
      const creditedSeconds =
        (vacationDays + sickDays) * dailyHours * 3600;
      const istSeconds = stampedSeconds + creditedSeconds;
      const saldoSeconds = istSeconds - sollSeconds;

      await db
        .collection(`users/${adminUid}/drivers/${driverId}/time_account`)
        .doc(month)
        .set(
          {
            // Indizier-Felder für CollectionGroup-Queries.
            adminUid,
            driverId,
            month,
            sollMode,
            soll: +(sollSeconds / 3600).toFixed(2),
            ist: +(istSeconds / 3600).toFixed(2),
            istStamped: +(stampedSeconds / 3600).toFixed(2),
            istCredited: +(creditedSeconds / 3600).toFixed(2),
            saldo: +(saldoSeconds / 3600).toFixed(2),
            workingDays: effectiveDays.length,
            holidayDays: days.length - effectiveDays.length,
            vacationDays,
            sickDays,
            spesenDays,
            spesenAmount,
            spesenRatePerDay: SPESEN_PER_DAY_EUR,
            spesenThresholdHours: SPESEN_THRESHOLD_SEC / 3600,
            lastRecomputedAt: Timestamp.now(),
          },
          {merge: true},
        );
      driversProcessed++;
    }
  }

  logger.info(
    `Monthly account computed for ${month} — ` +
    `${adminsProcessed} admins, ${driversProcessed} drivers`,
  );
  return {adminsProcessed, driversProcessed};
}

export const computeMonthlyAccount = onSchedule(
  {
    schedule: "0 3 * * *",
    timeZone: "Europe/Berlin",
    region: REGION,
  },
  async () => {
    await runMonthlyCompute({});
  },
);

// Manueller Trigger — admin kann das Zeitkonto seiner Driver für einen
// beliebigen Monat neu berechnen (z.B. nach Schicht-Korrekturen oder
// während des Tests bevor der Cron um 03:00 läuft).
export const recomputeMonthlyAccount = onCall(
  {region: REGION, cors: true},
  async (req) => {
    if (!req.auth) {
      throw new HttpsError("unauthenticated", "Login required");
    }
    const adminUid = req.auth.uid;
    const month = ((req.data ?? {}) as {month?: string}).month;
    const result = await runMonthlyCompute({
      forAdminUid: adminUid,
      forMonth: month,
    });
    return {month: month ?? ym(new Date()), ...result};
  },
);
