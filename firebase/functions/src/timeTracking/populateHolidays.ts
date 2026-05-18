/* eslint-disable max-len, require-jsdoc, valid-jsdoc, object-curly-spacing, operator-linebreak, indent, no-trailing-spaces, eol-last, quotes, comma-dangle */
// firebase/functions/src/timeTracking/populateHolidays.ts
//
// Scheduled Function: jeden 1. Januar 04:00 Berlin-Zeit holt alle
// gesetzlichen Feiertage Deutschlands für das laufende Jahr von
// feiertage-api.de und cached sie in `global_holidays/{auto}`.
//
// Datenmodell pro Doc:
//   { date, name, state, type, year }

import {onSchedule} from "firebase-functions/v2/scheduler";
import {getFirestore} from "firebase-admin/firestore";
import * as logger from "firebase-functions/logger";
import * as https from "node:https";
import {onCall, HttpsError} from "firebase-functions/v2/https";

const REGION = "europe-west3";

// Die ISO-Codes wie in der feiertage-api.de Dokumentation
const GERMAN_STATES = [
  "BW", "BY", "BE", "BB", "HB", "HH", "HE", "MV",
  "NI", "NW", "RP", "SL", "SN", "ST", "SH", "TH",
] as const;

interface FeiertagApiResponse {
  [name: string]: {
    datum: string; // YYYY-MM-DD
    hinweis?: string;
  };
}

function fetchJson(url: string): Promise<FeiertagApiResponse> {
  return new Promise((resolve, reject) => {
    https
      .get(url, (res) => {
        let body = "";
        res.on("data", (chunk) => (body += chunk));
        res.on("end", () => {
          try {
            resolve(JSON.parse(body));
          } catch (e) {
            reject(e);
          }
        });
      })
      .on("error", reject);
  });
}

export const populateHolidays = onSchedule(
  {
    schedule: "0 4 1 1 *", // 04:00 am 1. Januar
    timeZone: "Europe/Berlin",
    region: REGION,
  },
  async () => {
    const year = new Date().getFullYear();
    const db = getFirestore();
    let total = 0;

    for (const state of GERMAN_STATES) {
      const url = `https://feiertage-api.de/api/?jahr=${year}&nur_land=${state}`;
      try {
        const data = await fetchJson(url);
        for (const [name, info] of Object.entries(data)) {
          if (!info.datum) continue;
          const docId = `${year}_${state}_${info.datum}`;
          await db.collection("global_holidays").doc(docId).set({
            year,
            state,
            date: info.datum,
            name,
            type: "state",
            sourceHint: info.hinweis ?? "",
          });
          total++;
        }
        logger.info(`Holidays ${state} ${year} loaded`);
      } catch (e) {
        logger.error(`Failed to load ${state}`, e);
      }
    }

    logger.info(`Total holidays cached: ${total}`);
  },
);

// Manueller Trigger zum Initial-Befüllen über die Admin-UI.
// Schreibt die Feiertage des aktuellen und nächsten Jahres in
// global_holidays/{YYYY_STATE_DATE}.
export const seedHolidaysNow = onCall(
  {region: REGION, cors: true},
  async (req) => {
    if (!req.auth) {
      throw new HttpsError("unauthenticated", "Login required");
    }
    const db = getFirestore();
    const years = [
      new Date().getFullYear(),
      new Date().getFullYear() + 1,
    ];
    let total = 0;
    for (const year of years) {
      for (const state of GERMAN_STATES) {
        const url =
          `https://feiertage-api.de/api/?jahr=${year}&nur_land=${state}`;
        try {
          const data = await fetchJson(url);
          for (const [name, info] of Object.entries(data)) {
            if (!info.datum) continue;
            const docId = `${year}_${state}_${info.datum}`;
            await db.collection("global_holidays").doc(docId).set({
              year,
              state,
              date: info.datum,
              name,
              type: "state",
              sourceHint: info.hinweis ?? "",
            });
            total++;
          }
        } catch (e) {
          logger.warn(`seedHolidaysNow ${state} ${year} failed`, e);
        }
      }
    }
    logger.info(`seedHolidaysNow done — wrote ${total} entries`);
    return {count: total, years};
  },
);
