// Firebase v2 Functions
import { onRequest } from "firebase-functions/v2/https";
import { onObjectFinalized } from "firebase-functions/v2/storage";
import * as logger from "firebase-functions/logger";

// Firebase Admin SDK (modular)
import { initializeApp } from "firebase-admin/app";
import {
  getFirestore,
  FieldValue,
  Timestamp,
} from "firebase-admin/firestore";
import { getStorage } from "firebase-admin/storage";

// Third-party
import axios from "axios";
import FormData from "form-data";
import path from "path";
import Papa from "papaparse";
import dayjs from "dayjs";
import isoWeek from "dayjs/plugin/isoWeek";
dayjs.extend(isoWeek);

// Initialize admin
initializeApp();
const db = getFirestore();

// Health check
export const ping = onRequest((_req, res) => {
  res.status(200).send("Functions emulator is alive ✅");
});

logger.info("Loaded functions: ping, onDriversCSVUpload, onReportPDFUpload");

// Parser URL (set via .env.local / .env.production)
const PARSER_URL = process.env.PARSER_URL ||
(process.env.FUNCTIONS_EMULATOR ? "http://127.0.0.1:8000/parse" : "");

if (!PARSER_URL) {
  logger.warn("PARSER_URL is not set. Add it to functions/.env.local or .env.production.");
}

// --- Types ---
type ParserRow = {
  ["Transporter ID"]: string;
  POD?: any; CC?: any; DCR?: any; CE?: any;
  ["LoR DPMO"]?: any; ["DNR DPMO"]?: any; ["CDF DPMO"]?: any;
  POD_Score?: number; CC_Score?: number; DCR_Score?: number;
  CE_Score?: number; LoR_Score?: number; DNR_Score?: number; CDF_Score?: number;
  FinalScore?: number;
};

const bucketFor = (finalScore: number | null) => {
  if (finalScore == null) return "Unknown";
  if (finalScore >= 85) return "Fantastic";
  if (finalScore >= 70) return "Great";
  if (finalScore >= 55) return "Fair";
  return "Poor";
};

// --- Helpers ---
async function upsertReportDoc(storagePath: string, reportDate: Date) {
  const q = await db.collection("reports").where("storagePath", "==", storagePath).limit(1).get();
  if (!q.empty) return q.docs[0].ref;
  return db.collection("reports").add({
    reportName: path.basename(storagePath),
    reportDate: Timestamp.fromDate(reportDate),
    storagePath,
    status: "uploaded",
    createdAt: FieldValue.serverTimestamp(),
    updatedAt: FieldValue.serverTimestamp(),
  });
}

// ===============================
// 1) CSV → upsert /drivers  (German headers)
// ===============================
export const onDriversCSVUpload = onObjectFinalized(async (event) => {
  const object = event.data;
  const filePath = object.name ?? "";
  const contentType = (object.contentType ?? "").toLowerCase();

  // Only react to CSVs under uploads/drivers/
  if (!filePath.startsWith("uploads/drivers/")) return;

  // Accept by MIME OR by extension (emulator sometimes sets octet-stream)
  const isCsvMime = /csv|text\/plain|application\/vnd\.ms-excel/.test(contentType);
  const isCsvExt  = filePath.toLowerCase().endsWith(".csv");
  if (!isCsvMime && !isCsvExt) return;

  const bucket = getStorage().bucket(object.bucket);
  const [buf] = await bucket.file(filePath).download();

  // Decode text, strip BOM
  const csvText = buf.toString("utf8").replace(/^\uFEFF/, "");

  // Your file is comma-separated with quoted fields
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

  // Exact columns from your sample (normalized by transformHeader)
  // "name des zustellenden"  → driver name
  // "zustellende-id"         → transporter id
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

  // Build latest mapping per transporterId
  const latestById = new Map<string, string | undefined>();
  for (const r of parsed.data as any[]) {
    const idRaw = getId(r);
    if (!idRaw) continue;
    const transporterId = String(idRaw).trim();
    if (!transporterId) continue;

    const name = getName(r) ? String(getName(r)).trim() : undefined;
    const prev = latestById.get(transporterId);
    latestById.set(transporterId, name && name.length ? name : prev);
  }

  const db = getFirestore();
  const batch = db.batch();

  for (const [transporterId, driverName] of latestById.entries()) {
    const dq = await db.collection("drivers")
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
  logger.info(`Drivers CSV processed: ${latestById.size} IDs (path=${filePath}, type=${contentType})`);
});

// ===============================
// 2) PDF → parse KPIs → /scores + update /drivers + /reports
// ===============================
export const onReportPDFUpload = onObjectFinalized(async (event) => {
  const object = event.data;
  const filePath = object.name ?? "";
  const contentType = object.contentType ?? "";

  // Only handle PDFs under uploads/reports/
  if (!filePath.startsWith("uploads/reports/") || !contentType.includes("pdf")) return;

  const bucket = getStorage().bucket(object.bucket);
  const [buf] = await bucket.file(filePath).download();

  const reportDate = dayjs().toDate();
  const reportRef = await upsertReportDoc(filePath, reportDate);
  await reportRef.update({ status: "processing", updatedAt: FieldValue.serverTimestamp() });

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
      timeout: 60000,
    });

    const data = resp.data as { drivers: ParserRow[]; count: number };

    const batch = db.batch();
    const year = dayjs(reportDate).year();
    const week = dayjs(reportDate).isoWeek();

    for (const row of data.drivers) {
      const transporterId = (row["Transporter ID"] || "").toString().trim();
      if (!transporterId) continue;

      // find or create driver by transporterId
      const dq = await db.collection("drivers").where("transporterId", "==", transporterId).limit(1).get();
      const driverRef = dq.empty ? db.collection("drivers").doc() : dq.docs[0].ref;

      if (dq.empty) {
        batch.set(driverRef, {
          transporterId,
          driverName: "",
          createdAt: FieldValue.serverTimestamp(),
          updatedAt: FieldValue.serverTimestamp(),
        }, { merge: true });
      }

      const scoreRef = db.collection("scores").doc();
      const kpis = {
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
      const statusBucket = bucketFor(comp.FinalScore as number | null);

      batch.set(scoreRef, {
        driverRef,
        reportRef,
        transporterId,
        year,
        weekNumber: week,
        reportDate: Timestamp.fromDate(reportDate),
        kpis,
        comp,
        statusBucket,
        computedAt: FieldValue.serverTimestamp(),
      });

      // update driver summary
      batch.set(driverRef, {
        currentScore: comp.FinalScore ?? null,
        currentStatus: statusBucket,
        lastKpiDate: Timestamp.fromDate(reportDate),
        updatedAt: FieldValue.serverTimestamp(),
      }, { merge: true });
    }

    batch.update(reportRef, {
      status: "done",
      notes: `Parsed: ${data.count} rows`,
      updatedAt: FieldValue.serverTimestamp(),
    });

    await batch.commit();
    logger.info(`Report parsed OK: ${data.count} rows`);
    return;
  } catch (err: any) {
    logger.error(err?.message || err);
    await reportRef.update({
      status: "failed",
      notes: err?.message || "Error",
      updatedAt: FieldValue.serverTimestamp(),
    });
    throw err;
  }
});
