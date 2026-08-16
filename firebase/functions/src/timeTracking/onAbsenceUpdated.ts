/* eslint-disable max-len, require-jsdoc, valid-jsdoc, object-curly-spacing, operator-linebreak, indent, no-trailing-spaces, eol-last, quotes, comma-dangle */
// firebase/functions/src/timeTracking/onAbsenceUpdated.ts
//
// Firestore-Trigger: wenn ein absence_request approved/rejected wird,
// rechnen wir das time_account des betroffenen Monats neu durch — so
// sieht der Driver sofort die Anrechnung in seiner co:timer Übersicht.
//
// Pfad: users/{adminUid}/drivers/{driverId}/absence_requests/{requestId}

import {onDocumentWritten} from "firebase-functions/v2/firestore";
import * as logger from "firebase-functions/logger";

import {runMonthlyCompute} from "./computeMonthlyAccount";

const REGION = "europe-west3";

export const onAbsenceUpdated = onDocumentWritten(
  {
    document: "users/{adminUid}/drivers/{driverId}/absence_requests/{requestId}",
    region: REGION,
  },
  async (event) => {
    const after = event.data?.after?.data();
    const before = event.data?.before?.data();
    if (!after) return; // gelöscht — nichts zu tun

    const newStatus = (after.status ?? "").toString();
    const oldStatus = (before?.status ?? "").toString();

    // Nur wenn sich der Status ändert ODER ein approved Antrag editiert
    // wird, lohnt die Recompute.
    const statusChanged = newStatus !== oldStatus;
    const stillRelevant =
      newStatus === "approved" || oldStatus === "approved";
    if (!statusChanged && !stillRelevant) return;

    const adminUid = event.params.adminUid as string;
    const fromDate = after.fromDate?.toDate?.() as Date | undefined;
    const toDate = after.toDate?.toDate?.() as Date | undefined;
    if (!adminUid || !fromDate || !toDate) return;

    // Alle Monate die der Antrag berührt neu berechnen (Anträge können
    // monatsübergreifend sein, z.B. 28.Mai–3.Juni). WICHTIG: auch die
    // ALTEN Monate (before) einbeziehen — wird ein genehmigter Urlaub
    // per Edit in einen anderen Monat verschoben, muss der bisherige
    // Monat ebenfalls zurückgerechnet werden, sonst bleibt sein
    // time_account veraltet.
    const months = new Set<string>();
    const addRange = (from?: Date, to?: Date) => {
      if (!from || !to) return;
      const cursor = new Date(Date.UTC(
        from.getUTCFullYear(),
        from.getUTCMonth(),
        1,
      ));
      const stop = new Date(Date.UTC(
        to.getUTCFullYear(),
        to.getUTCMonth(),
        1,
      ));
      while (cursor.getTime() <= stop.getTime()) {
        const y = cursor.getUTCFullYear();
        const m = String(cursor.getUTCMonth() + 1).padStart(2, "0");
        months.add(`${y}-${m}`);
        cursor.setUTCMonth(cursor.getUTCMonth() + 1);
      }
    };
    addRange(fromDate, toDate);
    addRange(
      before?.fromDate?.toDate?.() as Date | undefined,
      before?.toDate?.toDate?.() as Date | undefined,
    );

    for (const month of months) {
      try {
        await runMonthlyCompute({forAdminUid: adminUid, forMonth: month});
      } catch (e) {
        logger.warn(`Recompute after absence update failed for ${month}`, e);
      }
    }
  },
);
