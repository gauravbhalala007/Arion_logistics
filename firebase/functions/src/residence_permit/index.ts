/* eslint-disable require-jsdoc, valid-jsdoc, max-len */
// firebase/functions/src/residence_permit/index.ts
//
// Callable Cloud Function: `generateResidencePermitPdf`
//
// Inputs:   { dspUid: string, driverDocId: string }
// Output:   { pdfUrl: string }     // signed Storage URL, 30 min lifetime
//
// Auth:
//   - Caller must be authenticated.
//   - Caller MUST be admin of `dspUid` OR a dispatcher belonging to that
//     DSP. Drivers themselves cannot trigger PDF generation (admin job).
//
// Workflow:
//   1. Load the bundled original PDF (assets/antrag_aufenthaltserlaubnis.pdf).
//   2. Read the saved form doc at
//        users/{dspUid}/drivers/{driverDocId}/forms/residencePermit
//   3. Stamp text + signature image on the unmodified original via pdf-lib.
//   4. Upload result to
//        gs://codriver-eu.firebasestorage.app/residence_permits/{dspUid}/{driverDocId}/antrag-<timestamp>.pdf
//   5. Return a 30-minute signed URL.

import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {PDFDocument, StandardFonts, rgb} from "pdf-lib";
import * as fs from "fs";
import * as path from "path";
import {FIELD_MAP, FieldKey} from "./fieldMap";

if (admin.apps.length === 0) {
  admin.initializeApp();
}

const REGION = "europe-west3";
const BUCKET = "codriver-eu.firebasestorage.app";

// Cache the template bytes per cold-start so we don't re-read on every call.
let cachedTemplate: Uint8Array | null = null;
function loadTemplate(): Uint8Array {
  if (cachedTemplate) return cachedTemplate;
  const assetPath = path.join(__dirname, "..", "..", "assets",
    "antrag_aufenthaltserlaubnis.pdf");
  cachedTemplate = new Uint8Array(fs.readFileSync(assetPath));
  return cachedTemplate;
}

// WinAnsi (used by Helvetica) covers Latin-1 + the Windows-1252 extras.
// Strip anything outside that range to a safe placeholder so the function
// never crashes on exotic glyphs (Cyrillic, Asian, …).
function sanitizeForHelvetica(input: string): string {
  if (!input) return "";
  // Allowed: ASCII printable (U+0020..U+007E) + Latin-1 supplement
  // (U+00A0..U+00FF) which covers German umlauts + Albanian (ç/ë) +
  // most European glyphs. Plus smart quotes / dashes / euro from the
  // Windows-1252 high range. Anything else becomes "?".
  return input.replace(
    /[^\u0020-\u007E\u00A0-\u00FF\u2013\u2014\u2018-\u201E\u20AC]/g,
    "?",
  );
}

type FormData = {
  personal?: Record<string, unknown>;
  address?: Record<string, unknown>;
  spouse?: Record<string, unknown>;
  children?: Array<Record<string, unknown>>;
  parents?: { father?: Record<string, unknown>; mother?: Record<string, unknown> };
  travel?: Record<string, unknown>;
  work?: Record<string, unknown>;
  legal?: Record<string, unknown>;
  signature?: { pngBase64?: string; place?: string; date?: string };
};

function s(v: unknown): string {
  if (v == null) return "";
  return String(v).trim();
}

function maritalLabel(code: string): string {
  switch (code) {
  case "single": return "ledig";
  case "married": return "verheiratet";
  case "separated": return "getrennt lebend";
  case "divorced": return "geschieden";
  case "widowed": return "verwitwet";
  default: return code;
  }
}

function buildEmployerLines(employer: string): [string, string, string] {
  const lines = employer.split(/\r?\n/).filter((l) => l.trim().length > 0);
  return [lines[0] || "", lines[1] || "", lines[2] || ""];
}

function buildAddressLines(addr: string): [string, string, string] {
  const lines = addr.split(/\r?\n/).filter((l) => l.trim().length > 0);
  return [lines[0] || "", lines[1] || "", lines[2] || ""];
}

/**
 * Render the form data onto a copy of the original template. The
 * template bytes themselves are NEVER mutated — pdf-lib parses them,
 * we draw additional content on top, and the resulting bytes are a
 * NEW document whose pages preserve the original visual layout.
 */
async function fillPdf(form: FormData): Promise<Uint8Array> {
  const pdfDoc = await PDFDocument.load(loadTemplate());
  const helv = await pdfDoc.embedFont(StandardFonts.Helvetica);
  const pages = pdfDoc.getPages();

  // Helper: draw a single value at the field's anchor.
  const draw = (key: FieldKey, value: string, opts?: { size?: number }) => {
    const f = FIELD_MAP[key];
    if (!f) return;
    const text = sanitizeForHelvetica(value);
    if (!text) return;
    const page = pages[f.page - 1];
    if (!page) return;
    page.drawText(text, {
      x: f.x,
      y: f.y,
      size: opts?.size ?? f.size ?? 10,
      font: helv,
      color: rgb(0.05, 0.05, 0.15),
      maxWidth: f.maxWidth,
    });
  };

  const p = form.personal || {};
  const a = form.address || {};
  const sp = form.spouse || {};
  const children = Array.isArray(form.children) ? form.children : [];
  const parents = form.parents || {};
  const father = parents.father || {};
  const mother = parents.mother || {};
  const tr = form.travel || {};
  const w = form.work || {};
  const lg = form.legal || {};
  const sig = form.signature || {};

  // ── PAGE 1 ──
  draw("familyName", s(p.familyName));
  draw("givenNames", s(p.givenNames));
  draw("maidenName", s(p.maidenName));
  draw("birthDate", s(p.birthDate));
  draw("birthPlace", s(p.birthPlace));
  draw("nationalityCurrent", s(p.nationalityCurrent));
  draw("nationalityFormer", s(p.nationalityFormer));
  draw("maritalStatus", maritalLabel(s(p.maritalStatus)));
  draw("maritalSince", s(p.maritalSince));

  const [addr1, addr2, addr3] = buildAddressLines(s(a.current));
  draw("currentAddressLine1", addr1);
  draw("currentAddressLine2", addr2);
  draw("currentAddressLine3", addr3);

  draw("spouseFamilyName", s(sp.familyName));
  draw("spouseGivenName", s(sp.givenName));
  draw("spouseBirth", s(sp.birthDateAndPlace));
  draw("spouseNationality", s(sp.nationality));
  draw("spouseAddress", s(sp.address));

  for (let i = 0; i < Math.min(4, children.length); i++) {
    const c = children[i] || {};
    const fullName = [s(c.givenName), s(c.familyName)]
      .filter(Boolean).join(" ");
    const prefix = `child${i + 1}` as const;
    draw(`${prefix}Name` as FieldKey, fullName);
    draw(`${prefix}Birth` as FieldKey, s(c.birthDate));
    draw(`${prefix}Nationality` as FieldKey, s(c.nationality));
    draw(`${prefix}Address` as FieldKey, s(c.address));
  }

  // ── PAGE 2 ──
  draw("fatherFamilyName", s(father.familyName));
  draw("fatherGivenName", s(father.givenName));
  draw("fatherBirth", s(father.birthDate));
  draw("motherFamilyName", s(mother.familyName));
  draw("motherGivenName", s(mother.givenName));
  draw("motherBirth", s(mother.birthDate));

  draw("passportTypeText",
    s(tr.passportType) === "other" ? "Sonstiges Dokument" : "Reisepass");
  draw("passportNumber", s(tr.passportNumber));
  draw("passportIssuedBy", s(tr.issuedBy));
  draw("passportIssuedOn", s(tr.issuedOn));
  draw("passportValidUntil", s(tr.validUntil));
  draw("rightOfReturn", s(tr.rightOfReturn));

  draw("enteredOn", s(tr.enteredOn));
  const visaText = tr.hasVisa ?
    `Ja — ${s(tr.visaPurpose) || "Arbeit"}` :
    "Nein";
  draw("visaText", visaText);
  draw("stayedBeforeText",
    tr.stayedBefore ?
      `Ja — ${s(tr.stayedBeforeDetails)}` :
      "Nein");
  draw("arrivedOn", s(tr.arrivedOn));
  draw("arrivedFrom", s(tr.arrivedFrom));
  draw("maintainsAbroad",
    tr.maintainsResidenceAbroad ?
      `Ja — ${s(tr.residenceAbroadPlace)}` :
      "Nein");
  draw("purposeOfStay", s(tr.purposeOfStay));
  draw("intendedDuration", s(tr.intendedDuration));

  // ── PAGE 3 ──
  draw("profession", s(w.profession));
  const [emp1, emp2, emp3] = buildEmployerLines(s(w.employer));
  draw("employerLine1", emp1);
  draw("employerLine2", emp2);
  draw("employerLine3", emp3);
  draw("healthInsurance",
    w.hasHealthInsurance === true ? "Ja" :
      w.hasHealthInsurance === false ? "Nein" : "");
  draw("socialBenefits",
    w.receivesSocialBenefits === true ?
      `Ja — ${s(w.socialBenefitsDetails)}` :
      "Nein");

  const convictedAny = lg.convictedInGermany === true ||
                       lg.convictedAbroad === true;
  draw("convictionsText",
    convictedAny ? s(lg.convictionsDetails) || "Ja" : "Nein");
  draw("expulsionText",
    lg.expelled === true ? s(lg.expelledDetails) || "Ja" : "Nein");

  draw("height", s(p.heightCm) ? `${s(p.heightCm)} cm` : "");
  draw("eyeColor", s(p.eyeColor));

  // ── PAGE 4 — place + date + signature image ──
  draw("signaturePlace", s(sig.place));
  draw("signatureDate", s(sig.date));

  // Signature image
  const png = typeof sig.pngBase64 === "string" ? sig.pngBase64 : "";
  if (png) {
    try {
      const buf = Buffer.from(png, "base64");
      const img = await pdfDoc.embedPng(buf);
      const f = FIELD_MAP.signatureImage;
      const targetWidth = f.maxWidth || 180;
      const ratio = img.height / img.width;
      const targetHeight = Math.min(50, targetWidth * ratio);
      pages[f.page - 1].drawImage(img, {
        x: f.x,
        y: f.y - 5,
        width: targetWidth,
        height: targetHeight,
      });
    } catch (err) {
      console.warn("Signature embed failed:", err);
    }
  }

  return await pdfDoc.save();
}

// ── Auth + Firestore + Storage glue ─────────────────────────

export const generateResidencePermitPdf = onCall(
  {region: REGION, memory: "512MiB", timeoutSeconds: 60},
  async (request) => {
    const auth = request.auth;
    if (!auth) {
      throw new HttpsError("unauthenticated", "Login required.");
    }
    const dspUid = String(request.data?.dspUid || "").trim();
    const driverDocId = String(request.data?.driverDocId || "").trim();
    if (!dspUid || !driverDocId) {
      throw new HttpsError("invalid-argument",
        "dspUid and driverDocId are required.");
    }

    // Permission check — admin of this DSP (admin user IS the dsp root
    // OR a sub-admin whose token.dspUid points at this DSP) or a
    // dispatcher of this DSP.
    const tok = auth.token as Record<string, unknown>;
    const role = String(tok.role || "");
    const tokDsp = String(tok.dspUid || "");
    const isAdminOfDsp = (role === "admin" || role === "developer") &&
      (auth.uid === dspUid || tokDsp === dspUid);
    const isDispatcherOfDsp = role === "dispatcher" && tokDsp === dspUid;
    if (!isAdminOfDsp && !isDispatcherOfDsp) {
      throw new HttpsError("permission-denied",
        "Only admins or dispatchers of this DSP can generate the PDF.");
    }

    // Fetch saved form data.
    const db = admin.firestore();
    const formRef = db
      .collection("users").doc(dspUid)
      .collection("drivers").doc(driverDocId)
      .collection("forms").doc("residencePermit");
    const snap = await formRef.get();
    if (!snap.exists) {
      throw new HttpsError("not-found",
        "No residence permit form has been filled out for this driver yet.");
    }
    const form = snap.data() as FormData;

    // Render PDF.
    const filledBytes = await fillPdf(form);

    // Upload.
    const bucket = admin.storage().bucket(BUCKET);
    const ts = new Date().toISOString()
      .replace(/[:.]/g, "-")
      .replace("T", "_")
      .slice(0, 19);
    const objectPath =
      `residence_permits/${dspUid}/${driverDocId}/antrag-${ts}.pdf`;
    const file = bucket.file(objectPath);
    await file.save(Buffer.from(filledBytes), {
      contentType: "application/pdf",
      metadata: {
        cacheControl: "private, max-age=0",
        contentDisposition:
          `attachment; filename="aufenthaltserlaubnis-${driverDocId}.pdf"`,
      },
      resumable: false,
    });

    const [pdfUrl] = await file.getSignedUrl({
      action: "read",
      expires: Date.now() + 30 * 60 * 1000, // 30 minutes
    });

    // Audit trail on the form doc.
    await formRef.set({
      lastPdfGeneratedAt: admin.firestore.FieldValue.serverTimestamp(),
      lastPdfStoragePath: objectPath,
    }, {merge: true});

    return {pdfUrl, storagePath: objectPath};
  }
);
