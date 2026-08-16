/* eslint-disable require-jsdoc, valid-jsdoc, max-len */
// firebase/functions/src/fahrzeugschein/index.ts
//
// Trigger: a new doc lands in users/{dspUid}/vehicles/{plate}/documents/{docId}.
// If the documentType is fahrzeugschein_front or fahrzeugschein_back, we
// download the file from Storage, run Google Document AI OCR (EU region),
// regex-extract the standard German Fahrzeugschein fields, and merge them
// into users/{dspUid}/vehicles/{plate}.fahrzeugschein.*
//
// We NEVER overwrite manually-entered values — only empty fields get
// auto-filled. Every extracted value is also stored under
// `fahrzeugschein.autoExtracted.<field> = { value, confidence }` so the
// UI can show a "Auto-erkannt"-Badge that the admin then confirms.

import {onDocumentCreated} from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";
import {DocumentProcessorServiceClient} from "@google-cloud/documentai";

if (admin.apps.length === 0) {
  admin.initializeApp();
}

const REGION = "europe-west3";
const DOC_AI_PROCESSOR_NAME =
  "projects/641293967282/locations/eu/processors/ba79fa7cad33550a";
const STORAGE_BUCKET = "codriver-eu.firebasestorage.app";

let _client: DocumentProcessorServiceClient | null = null;
function client(): DocumentProcessorServiceClient {
  if (!_client) {
    _client = new DocumentProcessorServiceClient({
      apiEndpoint: "eu-documentai.googleapis.com",
    });
  }
  return _client;
}

// ── Field extractors ───────────────────────────────────────

const VIN_RE = /\b[A-HJ-NPR-Z0-9]{17}\b/;
const PLATE_RE = /\b[A-ZÄÖÜ]{1,3}[\s-]?[A-Z]{1,2}[\s-]?\d{1,4}\s?[A-Z]?\b/;
const DATE_RE = /\b\d{2}\.\d{2}\.\d{4}\b/;
// Tire: relaxed — accepts "225/65R16 91H" AND "225/75R 16C 121/120 R"
// AND "235/65 R 16 C 121 R" etc.
const TIRE_RE = /\b\d{3}\/\d{2}\s?[A-Z]?\s?\d{2}\s?[A-Z]?\s?\d{2,3}(?:\/\d{2,3})?\s?[A-Z]?\b/;

/**
 * Returns the text between `start` (after the matched label) and the
 * next label-like token. Useful when the label and value end up on
 * separate "lines" in the OCR output.
 */
function nextChunk(text: string, label: RegExp, maxChars = 60): string | null {
  const m = label.exec(text);
  if (!m) return null;
  const slice = text.slice(m.index + m[0].length, m.index + m[0].length + maxChars);
  // Up to the next label-like token (newline followed by single letter or
  // letter.number, or another known label key).
  const stopper = /\n[A-Z]\.?\d?(\.\d+)?(\s|$)|\n[A-Z]\d|\n\d{1,2}\.\d/;
  const stop = stopper.exec(slice);
  const out = stop ? slice.slice(0, stop.index) : slice;
  return out.trim().replace(/\s+/g, " ");
}

function firstMatch(text: string, re: RegExp): string | null {
  const m = re.exec(text);
  return m ? m[0] : null;
}

type Extracted = {
  value: string;
  confidence: number;
};

function extractAll(text: string): Record<string, Extracted> {
  const out: Record<string, Extracted> = {};
  const put = (key: string, value: string | null | undefined, conf = 0.85) => {
    if (!value) return;
    const clean = value.trim().replace(/\s+/g, " ");
    if (clean.length === 0) return;
    out[key] = {value: clean, confidence: conf};
  };

  // FIN / VIN — 17 char alphanumeric (no I O Q)
  put("vinNumber", firstMatch(text, VIN_RE), 0.95);

  // Erstzulassung = "B\n<date>". Just find the first DD.MM.YYYY date.
  const firstDate = firstMatch(text, DATE_RE);
  if (firstDate) put("firstRegistration", firstDate, 0.8);

  // Marke (D.1) — next chunk after "D.1"
  const brand = nextChunk(text, /\bD\.1\b/, 40);
  put("brand", brand);

  // Typ (D.2)
  const typ = nextChunk(text, /\bD\.2\b/, 40);
  put("typeCode", typ);

  // Handelsbezeichnung (D.3)
  const model = nextChunk(text, /\bD\.3\b/, 40);
  put("model", model);

  // Kennzeichen (A)
  const plate = firstMatch(text, PLATE_RE);
  put("plateNumber", plate);

  // F.1 Zulässige Gesamtmasse — number after F.1, OR fallback to
  // largest 4-digit value below 8000 that appears with "kg" suffix.
  const fmax = /\bF\.?1\b[^\d]{0,8}(\d{3,5})\b/.exec(text);
  if (fmax) put("maxWeight", fmax[1]);
  if (!out["maxWeight"]) {
    const kg = /(\d{3,5})\s*kg\b/i.exec(text);
    if (kg) {
      const v = parseInt(kg[1], 10);
      if (v >= 1000 && v <= 7500) put("maxWeight", kg[1], 0.6);
    }
  }

  // G Leermasse — sometimes "G2270" or "G 2270"
  const fkerb = /\bG\s?(\d{3,5})\b/.exec(text);
  if (fkerb) put("kerbWeight", fkerb[1]);
  // Fallback: a 4-digit number near labels "Leermasse" / "Masse"
  if (!out["kerbWeight"]) {
    const m = /(?:Leermasse|Masse[^\n]{0,40})[^\d]{0,20}(\d{3,5})/i.exec(text);
    if (m) put("kerbWeight", m[1], 0.6);
  }

  // 23 Hubraum (cm³) — primary German Fahrzeugschein field number is 23.
  // We also try 21 (older variant). Require the value to look like an
  // engine displacement (1000-7000 cm³) so we don't match VIN bits.
  for (const code of ["23", "P\\.1", "21"]) {
    const re = new RegExp(`\\b${code}\\s+(\\d{3,4})\\b(?!\\w)`);
    const m = re.exec(text);
    if (m) {
      const v = parseInt(m[1], 10);
      if (v >= 900 && v <= 9000) {
        put("engineDisplacement", m[1]);
        break;
      }
    }
  }
  // Also if "cm³" appears near a number → use that.
  if (!out["engineDisplacement"]) {
    const ccm = /(\d{3,4})\s*(?:cm³|ccm)\b/i.exec(text);
    if (ccm) put("engineDisplacement", ccm[1]);
  }

  // P.2 / 22 Motorleistung (kW) — typically 50-300 kW for vans.
  // Skip pure electric vehicles where the kW value is embedded
  // differently.
  for (const code of ["P\\.2", "22"]) {
    const re = new RegExp(`\\b${code}\\s+(\\d{2,4})\\b(?!\\w)`);
    const m = re.exec(text);
    if (m) {
      const v = parseInt(m[1], 10);
      if (v >= 30 && v <= 500) {
        put("enginePower", m[1]);
        break;
      }
    }
  }
  // Also "kW" suffix detection.
  if (!out["enginePower"]) {
    const kw = /\b(\d{2,4})\s*kW\b/.exec(text);
    if (kw) put("enginePower", kw[1]);
  }

  // 15.1 / 15.2 — Bereifung
  const tireMatches = text.match(new RegExp(TIRE_RE, "g")) || [];
  if (tireMatches.length > 0) {
    put("tireSize", tireMatches[0]);
    if (tireMatches.length > 1 && tireMatches[1] !== tireMatches[0]) {
      put("tireSizeRear", tireMatches[1]);
    }
  }

  // P.3 Kraftstoffart
  const fuel = nextChunk(text, /\bP\.3\b/, 30);
  if (fuel) {
    const m = /\b(Diesel|Benzin|Petrol|Elektro|Hybrid|LPG|CNG|Gas)\b/i.exec(fuel);
    if (m) put("fuelType", m[1]);
  }
  // Also try a global match.
  if (!out["fuelType"]) {
    const g = /\b(Diesel|Benzin|Petrol|Elektro|Hybrid|LPG|CNG)\b/i.exec(text);
    if (g) put("fuelType", g[1]);
  }

  // V.9 Schadstoffklasse — typically "EURO6", "Euro 6d", etc.
  const emission = /\b(EURO\s?\d[a-z]?(?:-\w+)?)\b/i.exec(text);
  if (emission) put("emissionClass", emission[1].replace(/\s/g, ""));

  // S.1 Sitzplätze
  const seats = /\bS\.?1\b[^\d]{0,5}(\d{1,2})\b/.exec(text);
  if (seats) put("seats", seats[1]);

  // Halter (C.1.1) — Name oder Firmenname
  // The label line is "C.1.1 Name oder Firmenname" or just "C.1.1".
  // Best heuristic: find the line that ends with "GmbH" / "AG" / "KG" /
  // "e.K." OR matches a name pattern near "C.1.1".
  const ownerName = nextChunk(text, /\bC\.1\.1\b[^\n]*\n/, 100);
  if (ownerName) put("ownerName", ownerName);
  // Fallback: anything ending with GmbH / AG / KG
  if (!out["ownerName"]) {
    const co = /\b([A-ZÄÖÜ][A-Za-zÄÖÜäöüß .&-]{2,}\s+(?:GmbH|AG|KG|e\.K\.|UG))\b/.exec(text);
    if (co) put("ownerName", co[1]);
  }

  // C.1.3 Anschrift — try to capture street + ZIP/city. Two patterns:
  //   "Industriestr. 12 a\n91325 Adelsdorf"
  // We look for a street-like line followed by ZIP + city.
  const addr = /([A-ZÄÖÜ][A-Za-zÄÖÜäöüß .-]+(?:str\.?|straße|gasse|weg|platz|allee|ring)\s*\d+[a-z]?)\s*\n?\s*(\d{5}\s+[A-ZÄÖÜ][A-Za-zÄÖÜäöüß -]+)/i.exec(text);
  if (addr) put("ownerAddress", `${addr[1]}, ${addr[2]}`);

  // Typgenehmigung (K)
  const ktyp = nextChunk(text, /\bK\b\s*\n?\s*(?=[A-Z0-9])/, 80);
  if (ktyp && /\d/.test(ktyp)) put("typeApproval", ktyp);

  return out;
}

// ── Cloud Function ─────────────────────────────────────────

export const extractFahrzeugscheinOnUpload = onDocumentCreated(
  {
    document: "users/{dspUid}/vehicles/{plate}/documents/{docId}",
    region: REGION,
    memory: "1GiB",
    timeoutSeconds: 120,
  },
  async (event) => {
    const data = event.data?.data();
    if (!data) return;

    const docType = (data.documentType ?? "").toString();
    if (docType !== "fahrzeugschein_front" && docType !== "fahrzeugschein_back") {
      return; // not a Fahrzeugschein upload — skip.
    }

    let storagePath = (data.storagePath ?? "").toString();
    // Fallback: parse from fileUrl for legacy docs (uploaded before we
    // started writing storagePath into the Firestore doc).
    if (!storagePath) {
      const fileUrl = (data.fileUrl ?? "").toString();
      const match = /\/o\/([^?]+)/.exec(fileUrl);
      if (match) {
        storagePath = decodeURIComponent(match[1]);
        console.log("Recovered storagePath from fileUrl:", storagePath);
      }
    }
    if (!storagePath) {
      console.warn("Fahrzeugschein doc has no storagePath or fileUrl, skipping");
      return;
    }

    const {dspUid, plate} = event.params;
    console.log(`Extracting Fahrzeugschein from ${storagePath} for ${dspUid}/${plate}`);

    // 1) Download file from Storage.
    const bucket = admin.storage().bucket(STORAGE_BUCKET);
    const [fileBytes] = await bucket.file(storagePath).download();

    const mimeType =
      storagePath.toLowerCase().endsWith(".pdf") ? "application/pdf" :
        storagePath.toLowerCase().endsWith(".png") ? "image/png" :
          "image/jpeg";

    // 2) Send to Document AI OCR.
    let ocrText = "";
    try {
      const [resp] = await client().processDocument({
        name: DOC_AI_PROCESSOR_NAME,
        rawDocument: {
          content: fileBytes,
          mimeType,
        },
      });
      ocrText = resp.document?.text ?? "";
    } catch (e) {
      console.error("Document AI failed:", e);
      throw e;
    }

    if (!ocrText) {
      console.warn("Empty OCR result, nothing to extract");
      return;
    }

    // 3) Extract fields.
    const extracted = extractAll(ocrText);
    const keys = Object.keys(extracted);
    console.log(`Extracted ${keys.length} fields: ${keys.join(", ")}`);
    if (keys.length === 0) return;

    // 4) Merge into vehicle doc — only fill empty fields, but always
    // record the autoExtracted snapshot for the UI badge.
    const vehicleRef = admin.firestore()
      .collection("users").doc(dspUid)
      .collection("vehicles").doc(plate);

    await admin.firestore().runTransaction(async (tx) => {
      const snap = await tx.get(vehicleRef);
      const existing = (snap.data()?.fahrzeugschein as Record<string, unknown> | undefined) ?? {};
      const autoMap: Record<string, Extracted> = {
        ...(existing.autoExtracted as Record<string, Extracted> | undefined ?? {}),
        ...extracted,
      };

      const updates: Record<string, unknown> = {
        "fahrzeugschein.autoExtracted": autoMap,
        "fahrzeugschein.lastAutoExtractedAt": admin.firestore.FieldValue.serverTimestamp(),
        "fahrzeugschein.lastAutoExtractedSource": docType,
        // Keep last ~6 KB of raw OCR for debug/audit; rewritten each upload.
        "fahrzeugschein.lastOcrText": ocrText.slice(0, 6000),
        "updatedAt": admin.firestore.FieldValue.serverTimestamp(),
      };

      // Only fill an empty manual field.
      for (const [k, e] of Object.entries(extracted)) {
        const current = (existing[k] as string | undefined) ?? "";
        if (!current.toString().trim()) {
          updates[`fahrzeugschein.${k}`] = e.value;
        }
      }

      tx.set(vehicleRef, decompose(updates), {merge: true});
    });

    console.log(`Vehicle ${dspUid}/${plate} updated with ${keys.length} auto-extracted fields`);
  }
);

/**
 * Firestore set({merge:true}) doesn't accept dot-notation in keys —
 * we have to convert "fahrzeugschein.foo" → nested object.
 */
function decompose(flat: Record<string, unknown>): Record<string, unknown> {
  const out: Record<string, unknown> = {};
  for (const [k, v] of Object.entries(flat)) {
    if (!k.includes(".")) {
      out[k] = v;
      continue;
    }
    const parts = k.split(".");
    let cur = out;
    for (let i = 0; i < parts.length - 1; i++) {
      const p = parts[i];
      if (typeof cur[p] !== "object" || cur[p] === null) cur[p] = {};
      cur = cur[p] as Record<string, unknown>;
    }
    cur[parts[parts.length - 1]] = v;
  }
  return out;
}
