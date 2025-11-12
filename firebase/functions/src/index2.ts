// Firebase v2 Functions
import { onRequest } from "firebase-functions/v2/https";
import { onObjectFinalized } from "firebase-functions/v2/storage";
import * as logger from "firebase-functions/logger";

// Firebase Admin SDK (modular)
import { initializeApp } from "firebase-admin/app";
import { getFirestore, FieldValue, Timestamp } from "firebase-admin/firestore";
import { getStorage } from "firebase-admin/storage";

// Third-party
import axios from "axios";
import FormData from "form-data";
import path from "path";
import Papa from "papaparse";
import dayjs from "dayjs";
import isoWeek from "dayjs/plugin/isoWeek";
dayjs.extend(isoWeek);

/* ---------------------------------------------------------
   0) Global config
--------------------------------------------------------- */

const BUCKET = process.env.BUCKET || "gaurav-arion-001-e533e.appspot.com";

const IS_EMULATOR = process.env.FUNCTIONS_EMULATOR === "true";
const PARSER_URL =
  process.env.PARSER_URL || (IS_EMULATOR ? "http://127.0.0.1:8000/parse" : "");

if (!PARSER_URL) {
  logger.warn(
    "PARSER_URL is not set. Add it to functions/.env.local or .env.production."
  );
}

// Init admin
initializeApp({ storageBucket: BUCKET });
const db = getFirestore();

/* ---------------------------------------------------------
   1) Health check
--------------------------------------------------------- */
export const ping = onRequest((_req, res) => {
  res.status(200).send("Functions emulator is alive ✅");
});
logger.info(
  `Loaded functions (bucket=${BUCKET}): ping, onDriversCSVUpload, onReportPDFUpload`
);

/* ---------------------------------------------------------
   2) Types & helpers
--------------------------------------------------------- */
type ParserRow = {
  ["Transporter ID"]: string;
  Delivered?: number | null;
  POD?: any;
  CC?: any;
  DCR?: any;
  CE?: any;
  ["LoR DPMO"]?: any;
  ["DNR DPMO"]?: any;
  ["CDF DPMO"]?: any;

  POD_Score?: number | null;
  CC_Score?: number | null;
  DCR_Score?: number | null;
  CE_Score?: number | null;
  LoR_Score?: number | null;
  DNR_Score?: number | null;
  CDF_Score?: number | null;
  FinalScore?: number | null;

  rank?: number | null;
  statusBucket?: string | null;
};

type ParserSummary = {
  overallScore?: number | null;
  reliabilityScore?: number | null;
  reliabilityNextDay?: number | null;
  reliabilitySameDay?: number | null;
  rankAtStation?: number | null;
  stationCount?: number | null;
  rankDeltaWoW?: number | null;
  weekText?: string | null;
  weekNumber?: number | null;
  year?: number | null;
  stationCode?: string | null;
};

const bucketFor = (finalScore: number | null) => {
  if (finalScore == null) return "Unknown";
  if (finalScore >= 85) return "Fantastic";
  if (finalScore >= 70) return "Great";
  if (finalScore >= 55) return "Fair";
  return "Poor";
};

function normStation(code?: string | null): string {
  return (code || "UNK").toUpperCase().replace(/[^A-Z0-9]/g, "");
}

function makeReportId(summary: ParserSummary): string {
  const y = summary.year ?? dayjs().year();
  const w = summary.weekNumber ?? dayjs().isoWeek();
  const s = normStation(summary.stationCode);
  return `${s}_${y}-W${w}`;
}

/* ---------------------------------------------------------
   3) CSV → upsert driver names

   Two supported paths:
   - NEW per-report: uploads/drivers/byReport/{reportId}/file.csv
     -> writes to reports/{reportId}/driverNames/{transporterId}
     -> (optional) denormalizes driverName into that report's /scores docs
   - Legacy global:  uploads/drivers/yyyy-mm-dd/file.csv
     -> upserts into /drivers (kept for backward compatibility)
--------------------------------------------------------- */
export const onDriversCSVUpload = onObjectFinalized(
  { bucket: BUCKET },
  async (event) => {
    const object = event.data;
    const filePath = object.name ?? "";
    const contentType = (object.contentType ?? "").toLowerCase();

    if (!filePath.startsWith("uploads/drivers/")) return;

    const isCsvMime = /csv|text\/plain|application\/vnd\.ms-excel/.test(
      contentType
    );
    const isCsvExt = filePath.toLowerCase().endsWith(".csv");
    if (!isCsvMime && !isCsvExt) return;

    const [buf] = await getStorage().bucket(BUCKET).file(filePath).download();

    const csvText = buf.toString("utf8").replace(/^\uFEFF/, "");

    const parsed = Papa.parse(csvText, {
      header: true,
      skipEmptyLines: true,
      delimiter: ",",
      quoteChar: '"',
      transformHeader: (h: string) =>
        h.replace(/\uFEFF/g, "").trim().replace(/\s+/g, " ").toLowerCase(),
      transform: (v: any) => (typeof v === "string" ? v.trim() : v),
    });

    if (parsed.errors?.length) {
      logger.warn("CSV parse errors (first 3):", parsed.errors.slice(0, 3));
    }

    // Column pickers
    const getId = (row: any) =>
      row["zustellende-id"] ??
      row["transporter id"] ??
      row["transporterid"] ??
      row["associate id"];

    const getName = (row: any) =>
      row["name des zustellenden"] ??
      row["driver name"] ??
      row["name"] ??
      row["employee name"];

    // Build latest name per transporterId
    const latestById = new Map<string, string | undefined>();
    for (const r of parsed.data as any[]) {
      const idRaw = getId(r);
      if (!idRaw) continue;
      const transporterId = String(idRaw).trim();
      if (!transporterId) continue;

      const nm = getName(r);
      const name = nm ? String(nm).trim() : undefined;
      const prev = latestById.get(transporterId);
      latestById.set(transporterId, name && name.length ? name : prev);
    }

    const batch = db.batch();

    // NEW: detect per-report path
    let reportIdFromPath: string | null = null;
    const m = filePath.match(/^uploads\/drivers\/byReport\/([^/]+)\//i);
    if (m) reportIdFromPath = m[1];

    if (reportIdFromPath) {
      // Save per-report driver names under subcollection
      const reportRef = db.collection("reports").doc(reportIdFromPath);
      for (const [transporterId, driverName] of latestById.entries()) {
        const ref = reportRef.collection("driverNames").doc(transporterId);
        batch.set(
          ref,
          {
            transporterId,
            driverName: driverName ?? "",
            updatedAt: FieldValue.serverTimestamp(),
          },
          { merge: true }
        );
      }
      await batch.commit();
      logger.info(
        `Driver names stored under reports/${reportIdFromPath}/driverNames (count=${latestById.size})`
      );

      // ✅ Optional denormalization into that week's /scores docs
      try {
        for (const [transporterId, driverName] of latestById.entries()) {
          if (!driverName) continue;
          const q = await db
            .collection("scores")
            .where("reportRef", "==", reportRef)
            .where("transporterId", "==", transporterId)
            .get();
          const denormBatch = db.batch();
          for (const doc of q.docs) {
            denormBatch.update(doc.ref, {
              driverName,
              updatedAt: FieldValue.serverTimestamp(),
            });
          }
          if (!q.empty) {
            await denormBatch.commit();
            logger.info(
              `Denormalized driverName to ${q.size} score docs for transporterId=${transporterId} in report=${reportIdFromPath}`
            );
          }
        }
      } catch (e) {
        logger.warn(
          `Denormalization skipped or needs index (reportId=${reportIdFromPath}): ${String(
            (e as any)?.message || e
          )}`
        );
      }

      return;
    }

    // Legacy global /drivers upsert
    for (const [transporterId, driverName] of latestById.entries()) {
      const dq = await db
        .collection("drivers")
        .where("transporterId", "==", transporterId)
        .limit(1)
        .get();

      const driverRef = dq.empty ? db.collection("drivers").doc() : dq.docs[0].ref;

      batch.set(
        driverRef,
        {
          transporterId,
          ...(driverName ? { driverName } : {}),
          updatedAt: FieldValue.serverTimestamp(),
          ...(dq.empty ? { createdAt: FieldValue.serverTimestamp() } : {}),
        },
        { merge: true }
      );
    }

    await batch.commit();
    logger.info(
      `Drivers CSV processed (legacy): ${latestById.size} IDs (path=${filePath})`
    );
  }
);

/* ---------------------------------------------------------
   4) PDF → parse KPIs → /scores + /reports
--------------------------------------------------------- */
export const onReportPDFUpload = onObjectFinalized(
  { bucket: BUCKET },
  async (event) => {
    const object = event.data;
    const filePath = object.name ?? "";
    const contentType = (object.contentType ?? "").toLowerCase();

    if (!filePath.startsWith("uploads/reports/")) return;

    const isPdfMime = contentType.includes("pdf");
    const isPdfExt = filePath.toLowerCase().endsWith(".pdf");
    if (!isPdfMime && !isPdfExt) return;

    const [buf] = await getStorage().bucket(BUCKET).file(filePath).download();

    try {
      if (!PARSER_URL) throw new Error("Missing PARSER_URL env");

      // Send to FastAPI parser as multipart/form-data
      const form = new FormData();
      form.append("file", buf, {
        filename: path.basename(filePath),
        contentType: "application/pdf",
      });

      const resp = await axios.post(PARSER_URL, form as any, {
        headers: (form as any).getHeaders?.() || {},
        maxBodyLength: Infinity,
        timeout: 60_000,
      });

      const data = resp.data as {
        drivers: ParserRow[];
        count: number;
        summary?: ParserSummary | null;
      };

      const now = dayjs();
      const summary = data.summary || {};
      const year = summary.year ?? now.year();
      const week = summary.weekNumber ?? now.isoWeek();
      const station = normStation(summary.stationCode);
      const reportId = makeReportId({ ...summary, year, weekNumber: week, stationCode: station });

      // Deterministic weekly report doc
      const reportRef = db.collection("reports").doc(reportId);

      // Create/merge report summary
      await reportRef.set(
        {
          reportName: path.basename(filePath),
          storagePath: filePath,
          status: "computing",
          reportDate: Timestamp.fromDate(now.toDate()),
          year,
          weekNumber: week,
          stationCode: station,
          summary: {
            overallScore: summary.overallScore ?? null,
            reliabilityScore: summary.reliabilityScore ?? null,
            reliabilityNextDay: summary.reliabilityNextDay ?? null,
            reliabilitySameDay: summary.reliabilitySameDay ?? null,
            rankAtStation: summary.rankAtStation ?? null,
            stationCount: summary.stationCount ?? null,
            rankDeltaWoW: summary.rankDeltaWoW ?? null,
            weekText: summary.weekText ?? null,
            weekNumber: week ?? null,
            year: year ?? null,
            stationCode: station ?? null,
          },
          createdAt: FieldValue.serverTimestamp(),
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true }
      );

      // Batch insert scores
      const batch = db.batch();

      for (const row of data.drivers) {
        const transporterId = (row["Transporter ID"] || "").toString().trim();
        if (!transporterId) continue;

        // CHANGED: deterministic per-week+driver key (idempotent writes)
        const scoreDocId = `${reportId}_${transporterId}`;                  // CHANGED
        const scoreRef = db.collection("scores").doc(scoreDocId);           // CHANGED

        const kpis = {
          Delivered: row.Delivered ?? null,
          POD: row.POD ?? null,
          CC: row.CC ?? null,
          DCR: row.DCR ?? null,
          CE: row.CE ?? null,
          LoR: row["LoR DPMO"] ?? null,
          DNR: row["DNR DPMO"] ?? null,
          CDF: row["CDF DPMO"] ?? null,
        };

        const comp = {
          POD_Score: row.POD_Score ?? null,
          CC_Score: row.CC_Score ?? null,
          DCR_Score: row.DCR_Score ?? null,
          CE_Score: row.CE_Score ?? null,
          LoR_Score: row.LoR_Score ?? null,
          DNR_Score: row.DNR_Score ?? null,
          CDF_Score: row.CDF_Score ?? null,
          FinalScore: row.FinalScore ?? null,
        };

        const statusBucket = row.statusBucket ?? bucketFor(comp.FinalScore ?? null);
        const rank = row.rank ?? null;

        // CHANGED: use merge so re-parses update instead of duplicating
        batch.set(                                                           // CHANGED
          scoreRef,
          {
            reportRef,
            transporterId,
            year,
            weekNumber: week,
            reportDate: Timestamp.fromDate(now.toDate()),
            kpis,
            comp,
            rank,
            statusBucket,
            computedAt: FieldValue.serverTimestamp(),
          },
          { merge: true }                                                   // CHANGED
        );
      }

      batch.update(reportRef, {
        status: "done",
        notes: `Parsed: ${data.count} rows`,
        updatedAt: FieldValue.serverTimestamp(),
      });

      await batch.commit();
      logger.info(
        `Report parsed OK: ${data.count} rows (reportId=${reportId}, station=${station}, year=${year}, week=${week})`
      );
      return;
    } catch (err: any) {
      logger.error(err?.message || err);
      // best effort: try to mark report failed if we have enough info
      try {
        const now = dayjs();
        const fallbackRef = db
          .collection("reports")
          .doc(`UNK_${now.year()}-W${now.isoWeek()}`);
        await fallbackRef.set(
          {
            status: "failed",
            notes: err?.message || "Error",
            updatedAt: FieldValue.serverTimestamp(),
          },
          { merge: true }
        );
      } catch (_) {}
      throw err;
    }
  }
);
