/* eslint-disable max-len, require-jsdoc, valid-jsdoc */
// firebase/functions/src/vehicleChecks/analyzeCheck.ts
//
// STUFE 2 — KI-Assistenz für die geführte Foto-Fahrzeuginspektion.
//
// Wird direkt aus `onVehicleCheckCreated` aufgerufen (eine Function-Kette,
// damit pro Check garantiert genau EIN Modell-Aufruf passiert).
//
// Ablauf:
//   1. Bis zu MAX_AI_PHOTOS Fotos aus Cloud Storage laden (Admin-SDK,
//      Rules greifen nicht).
//   2. Ein einziger multimodaler Request an Vertex AI Gemini in
//      europe-west3 — Authentifizierung über die Service-Identity der
//      Function (Application Default Credentials). KEIN API-Key.
//   3. Strukturiertes JSON zurück ins Check-Dokument:
//        aiStatus: "done" | "error"
//        aiFindings: { photoQuality[], odometerKm, plateText, plateMatch,
//                      damageCandidates[], summary }
//        aiOdometerKm / aiPlateMatch als Kurzfelder
//
// Die Admin-UI zeigt das Ergebnis ausschließlich als „KI-Vorschlag — bitte
// prüfen"; nichts landet automatisch in `damages`.
//
// KOSTEN-GUARD: max. 9 Bilder, genau ein Versuch, kein Retry-Loop. Bei
// jedem Fehler wird `aiStatus: "error"` samt Grund geschrieben und die
// Function endet normal (kein throw → keine automatische Wiederholung
// durch Eventarc).

import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";
import {GoogleAuth} from "google-auth-library";

import {
  DAMAGE_CATEGORIES,
  MAX_AI_PHOTOS,
  STEP_LABELS,
  VEHICLE_CHECK_REGION,
  VehicleCheckDoc,
} from "./types";

const STORAGE_BUCKET = "codriver-eu.firebasestorage.app";
const MODEL = "gemini-2.0-flash";

/** Vertex-Endpunkt in derselben Region wie die Function (DSGVO). */
function endpoint(projectId: string): string {
  return (
    `https://${VEHICLE_CHECK_REGION}-aiplatform.googleapis.com/v1/projects/` +
    `${projectId}/locations/${VEHICLE_CHECK_REGION}/publishers/google/models/` +
    `${MODEL}:generateContent`
  );
}

let _auth: GoogleAuth | null = null;
function auth(): GoogleAuth {
  if (!_auth) {
    _auth = new GoogleAuth({
      scopes: ["https://www.googleapis.com/auth/cloud-platform"],
    });
  }
  return _auth;
}

// ── Antwort-Schema ────────────────────────────────────────────────────────
// Gemini liefert damit garantiert parsebares JSON statt Fließtext.

const RESPONSE_SCHEMA = {
  type: "OBJECT",
  properties: {
    photoQuality: {
      type: "ARRAY",
      items: {
        type: "OBJECT",
        properties: {
          step: {type: "STRING"},
          usable: {type: "BOOLEAN"},
          matchesStep: {type: "BOOLEAN"},
          note: {type: "STRING"},
        },
        required: ["step", "usable", "matchesStep", "note"],
      },
    },
    odometerKm: {type: "INTEGER"},
    plateText: {type: "STRING"},
    plateMatch: {type: "BOOLEAN"},
    damageCandidates: {
      type: "ARRAY",
      items: {
        type: "OBJECT",
        properties: {
          step: {type: "STRING"},
          category: {type: "STRING", enum: [...DAMAGE_CATEGORIES]},
          description: {type: "STRING"},
          confidence: {type: "NUMBER"},
        },
        required: ["step", "category", "description", "confidence"],
      },
    },
    summary: {type: "STRING"},
  },
  required: ["photoQuality", "damageCandidates", "summary"],
};

function buildPrompt(check: VehicleCheckDoc, steps: string[]): string {
  const stepList = steps
    .map((s, i) => `  Bild ${i + 1}: ${s} (${STEP_LABELS[s] ?? s})`)
    .join("\n");
  const plate = (check.plate ?? "").trim() || "unbekannt";
  const typed = check.odometerKm ?? 0;

  return [
    "Du bist Prüfassistent für Fahrzeug-Zustandsberichte einer",
    "Lieferflotte (Sprinter/Transporter). Du bekommst die Fotos einer",
    "geführten Fahrzeuginspektion in genau dieser Reihenfolge:",
    "",
    stepList,
    "",
    `Erwartetes Kennzeichen: ${plate}`,
    `Vom Fahrer eingetragener Kilometerstand: ${typed}`,
    "",
    "Aufgaben:",
    "1. photoQuality: Beurteile JEDES Bild einzeln. `usable` = ist das Bild",
    "   scharf, ausreichend belichtet und zeigt es genug vom Fahrzeug?",
    "   `matchesStep` = zeigt es wirklich die angeforderte Perspektive?",
    "   `note` = ein knapper deutscher Satz, warum nicht (sonst leer).",
    "2. odometerKm: Lies den Kilometerstand vom Tacho-Foto (Schritt",
    "   'odometer') ab. Nur die Gesamt-Kilometer, NICHT den Tageszähler.",
    "   Wenn nicht lesbar: Feld weglassen.",
    "3. plateText / plateMatch: Lies das Kennzeichen von Front- oder",
    "   Heck-Foto. plateMatch = stimmt es (ohne Leerzeichen/Bindestriche,",
    "   Groß-/Kleinschreibung egal) mit dem erwarteten Kennzeichen",
    "   überein? Wenn kein Kennzeichen lesbar ist, beide Felder weglassen.",
    "4. damageCandidates: Sichtbare Schäden. Kategorie ausschließlich aus",
    `   [${DAMAGE_CATEGORIES.join(", ")}]. \`step\` = der Schritt-Schlüssel`,
    "   des Bildes, auf dem du den Schaden siehst. `description` = kurze",
    "   deutsche Beschreibung inkl. Position. `confidence` = 0.0–1.0.",
    "   Melde NUR echte Schäden — Schmutz, Regentropfen, Spiegelungen,",
    "   Schatten und normale Gebrauchsspuren sind KEIN Schaden. Im Zweifel",
    "   lieber weglassen als falsch melden.",
    "5. summary: Zwei bis drei Sätze auf Deutsch für das Fleet-Team.",
    "",
    "Antworte ausschließlich als JSON nach dem vorgegebenen Schema.",
  ].join("\n");
}

// ── Storage ───────────────────────────────────────────────────────────────

async function loadPhoto(path: string): Promise<string | null> {
  try {
    const [buffer] = await admin
      .storage()
      .bucket(STORAGE_BUCKET)
      .file(path)
      .download();
    return buffer.toString("base64");
  } catch (err) {
    logger.warn("vehicleCheck.ai: could not read photo", {
      path,
      error: `${err}`,
    });
    return null;
  }
}

// ── Normalisierung ────────────────────────────────────────────────────────

function plateKeyOf(raw: string): string {
  return raw
    .toUpperCase()
    .replace(/Ü/g, "UE")
    .replace(/Ö/g, "OE")
    .replace(/Ä/g, "AE")
    .replace(/[^A-Z0-9]/g, "");
}

interface RawFindings {
  photoQuality?: unknown;
  odometerKm?: unknown;
  plateText?: unknown;
  plateMatch?: unknown;
  damageCandidates?: unknown;
  summary?: unknown;
}

/**
 * Härtet die Modell-Antwort ab: unbekannte Schritte/Kategorien fliegen
 * raus, Zahlen werden geklemmt. Ohne das könnte ein Halluzinat die
 * Admin-UI mit sinnlosen Chips fluten.
 */
function sanitize(
  raw: RawFindings,
  check: VehicleCheckDoc,
  knownSteps: Set<string>,
): Record<string, unknown> {
  const quality: Array<Record<string, unknown>> = [];
  if (Array.isArray(raw.photoQuality)) {
    for (const entry of raw.photoQuality) {
      if (!entry || typeof entry !== "object") continue;
      const e = entry as Record<string, unknown>;
      const step = `${e.step ?? ""}`;
      if (!knownSteps.has(step)) continue;
      quality.push({
        step,
        usable: e.usable !== false,
        matchesStep: e.matchesStep !== false,
        note: `${e.note ?? ""}`.slice(0, 300),
      });
    }
  }

  const candidates: Array<Record<string, unknown>> = [];
  if (Array.isArray(raw.damageCandidates)) {
    for (const entry of raw.damageCandidates) {
      if (!entry || typeof entry !== "object") continue;
      const e = entry as Record<string, unknown>;
      const category = `${e.category ?? "other"}`;
      const step = `${e.step ?? ""}`;
      const confidence = Number(e.confidence);
      candidates.push({
        step: knownSteps.has(step) ? step : "",
        category: (DAMAGE_CATEGORIES as readonly string[]).includes(category) ?
          category :
          "other",
        description: `${e.description ?? ""}`.slice(0, 400),
        confidence: Number.isFinite(confidence) ?
          Math.min(1, Math.max(0, confidence)) :
          0,
      });
    }
  }

  const out: Record<string, unknown> = {
    photoQuality: quality,
    damageCandidates: candidates,
    summary: `${raw.summary ?? ""}`.slice(0, 1200),
  };

  const odo = Number(raw.odometerKm);
  if (Number.isFinite(odo) && odo > 0 && odo < 2_000_000) {
    out.odometerKm = Math.round(odo);
  }

  const plateText = `${raw.plateText ?? ""}`.trim().slice(0, 24);
  if (plateText) {
    out.plateText = plateText;
    // Dem Modell wird das Urteil nicht geglaubt — wir vergleichen selbst
    // über dieselbe Normalisierung wie die App (plateKeyOf).
    const expected = plateKeyOf(`${check.plate ?? ""}`);
    out.plateMatch = expected.length > 0 && plateKeyOf(plateText) === expected;
  }

  return out;
}

// ── Einstieg ──────────────────────────────────────────────────────────────

/**
 * Analysiert einen Check und schreibt das Ergebnis zurück ins Dokument.
 * Wirft NIE — Fehler landen als `aiStatus: "error"` im Dokument.
 */
export async function analyzeVehicleCheck(
  ref: FirebaseFirestore.DocumentReference,
  check: VehicleCheckDoc,
): Promise<void> {
  const photos = (check.photos ?? []).filter((p) => p && p.path);
  if (photos.length === 0) {
    await ref
      .update({aiStatus: "skipped", aiError: "no photos"})
      .catch(() => undefined);
    return;
  }

  // Kosten-Guard.
  const selected = photos.slice(0, MAX_AI_PHOTOS);

  try {
    await ref.update({aiStatus: "running"});

    const parts: Array<Record<string, unknown>> = [];
    const steps: string[] = [];
    for (const photo of selected) {
      const data = await loadPhoto(photo.path);
      if (!data) continue;
      steps.push(photo.step);
      parts.push({inlineData: {mimeType: "image/jpeg", data}});
    }

    if (parts.length === 0) {
      await ref.update({
        aiStatus: "error",
        aiError: "Keine Fotos lesbar (Storage).",
      });
      return;
    }

    parts.unshift({text: buildPrompt(check, steps)});

    const projectId =
      process.env.GCLOUD_PROJECT ??
      process.env.GOOGLE_CLOUD_PROJECT ??
      "codriver-eu";

    const client = await auth().getClient();
    const response = await client.request<{
      candidates?: Array<{content?: {parts?: Array<{text?: string}>}}>;
    }>({
      url: endpoint(projectId),
      method: "POST",
      data: {
        contents: [{role: "user", parts}],
        generationConfig: {
          temperature: 0.1,
          maxOutputTokens: 2048,
          responseMimeType: "application/json",
          responseSchema: RESPONSE_SCHEMA,
        },
      },
    });

    const text =
      response.data?.candidates?.[0]?.content?.parts?.[0]?.text ?? "";
    if (!text.trim()) {
      await ref.update({
        aiStatus: "error",
        aiError: "Leere Antwort vom Modell.",
      });
      return;
    }

    let parsed: RawFindings;
    try {
      parsed = JSON.parse(text) as RawFindings;
    } catch {
      await ref.update({
        aiStatus: "error",
        aiError: "Antwort war kein gültiges JSON.",
      });
      return;
    }

    const findings = sanitize(parsed, check, new Set(steps));
    await ref.update({
      aiStatus: "done",
      aiError: "",
      aiFindings: findings,
      aiOdometerKm: findings.odometerKm ?? null,
      aiPlateMatch: findings.plateMatch ?? null,
      aiModel: MODEL,
      aiAnalyzedAt: admin.firestore.FieldValue.serverTimestamp(),
      aiPhotoCount: parts.length - 1,
    });
    logger.info("vehicleCheck.ai: analysis stored", {
      path: ref.path,
      photos: parts.length - 1,
    });
  } catch (err) {
    logger.error("vehicleCheck.ai: failed", {path: ref.path, error: `${err}`});
    await ref
      .update({
        aiStatus: "error",
        aiError: `${err}`.slice(0, 500),
      })
      .catch(() => undefined);
  }
}
