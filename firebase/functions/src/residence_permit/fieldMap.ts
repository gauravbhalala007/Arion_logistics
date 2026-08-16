/* eslint-disable require-jsdoc, max-len */
// firebase/functions/src/residence_permit/fieldMap.ts
//
// Coordinate map (PDF user-space units, A4 = 595 × 842 pt) that
// describes WHERE each Form field's value gets stamped onto the
// original Aufenthaltserlaubnis template.
//
// Anchors were extracted via pdfplumber on the actual template — see
// the conversation in the project history for the raw label positions.
// Y in this file uses the pdf-lib convention (origin at bottom-left).
// To convert from pdfplumber `top` (origin top-left) we used:
//
//   y_pdflib = 842 - top - LINE_OFFSET
//
// where LINE_OFFSET ≈ 22 (about one line-height below the label so
// values sit cleanly under the German caption row).

export type FieldDraw = {
  page: number; // 1-based page number
  x: number; // left x in pt
  y: number; // baseline y in pt (pdf-lib origin = bottom-left)
  size?: number;
  maxWidth?: number; // optional wrap width (single-line truncate)
};

// Convenience helper: same math, used at compile-time.
function fromTop(top: number, offset = 22): number {
  return 842 - top - offset;
}

const _FIELD_MAP_RAW = {
  // ── Page 1 — personal data ──────────────────────────────
  familyName: {page: 1, x: 40, y: fromTop(83.9), maxWidth: 260},
  givenNames: {page: 1, x: 40, y: fromTop(115.7), maxWidth: 260},
  maidenName: {page: 1, x: 40, y: fromTop(146.8), maxWidth: 260},
  birthDate: {page: 1, x: 40, y: fromTop(177.9), maxWidth: 130},
  birthPlace: {page: 1, x: 200, y: fromTop(177.9), maxWidth: 260},
  nationalityCurrent: {page: 1, x: 40, y: fromTop(240.1), maxWidth: 260},
  nationalityFormer: {page: 1, x: 320, y: fromTop(240.1), maxWidth: 230},
  maritalStatus: {page: 1, x: 40, y: fromTop(289.9), maxWidth: 180},
  maritalSince: {page: 1, x: 230, y: fromTop(289.9), maxWidth: 130},

  // Address block
  currentAddressLine1: {page: 1, x: 40, y: fromTop(369.3), maxWidth: 510},
  currentAddressLine2: {page: 1, x: 40, y: fromTop(369.3) - 14, maxWidth: 510},
  currentAddressLine3: {page: 1, x: 40, y: fromTop(369.3) - 28, maxWidth: 510},

  // Spouse — block around y=441-547
  spouseFamilyName: {page: 1, x: 40, y: fromTop(454.5), maxWidth: 510},
  spouseGivenName: {page: 1, x: 40, y: fromTop(484.5), maxWidth: 510},
  spouseBirth: {page: 1, x: 40, y: fromTop(508.8), maxWidth: 260},
  spouseNationality: {page: 1, x: 40, y: fromTop(547.0), maxWidth: 260},
  spouseAddress: {page: 1, x: 300, y: fromTop(547.0), maxWidth: 250},

  // Children rows — 5 fields each, 4 rows. Approximate row pitch ≈ 35pt.
  child1Name: {page: 1, x: 40, y: fromTop(660.0), maxWidth: 200},
  child1Birth: {page: 1, x: 240, y: fromTop(660.0), maxWidth: 90},
  child1Nationality: {page: 1, x: 340, y: fromTop(660.0), maxWidth: 120},
  child1Address: {page: 1, x: 470, y: fromTop(660.0), maxWidth: 100},
  child2Name: {page: 1, x: 40, y: fromTop(695.0), maxWidth: 200},
  child2Birth: {page: 1, x: 240, y: fromTop(695.0), maxWidth: 90},
  child2Nationality: {page: 1, x: 340, y: fromTop(695.0), maxWidth: 120},
  child2Address: {page: 1, x: 470, y: fromTop(695.0), maxWidth: 100},
  child3Name: {page: 1, x: 40, y: fromTop(730.0), maxWidth: 200},
  child3Birth: {page: 1, x: 240, y: fromTop(730.0), maxWidth: 90},
  child3Nationality: {page: 1, x: 340, y: fromTop(730.0), maxWidth: 120},
  child3Address: {page: 1, x: 470, y: fromTop(730.0), maxWidth: 100},
  child4Name: {page: 1, x: 40, y: fromTop(765.0), maxWidth: 200},
  child4Birth: {page: 1, x: 240, y: fromTop(765.0), maxWidth: 90},
  child4Nationality: {page: 1, x: 340, y: fromTop(765.0), maxWidth: 120},
  child4Address: {page: 1, x: 470, y: fromTop(765.0), maxWidth: 100},

  // ── Page 2 — parents + passport + travel ───────────────
  fatherFamilyName: {page: 2, x: 30, y: fromTop(75.6), maxWidth: 155},
  fatherGivenName: {page: 2, x: 30, y: fromTop(106.7), maxWidth: 155},
  fatherBirth: {page: 2, x: 30, y: fromTop(137.8), maxWidth: 155},
  motherFamilyName: {page: 2, x: 215, y: fromTop(75.6), maxWidth: 155},
  motherGivenName: {page: 2, x: 215, y: fromTop(106.7), maxWidth: 155},
  motherBirth: {page: 2, x: 215, y: fromTop(137.8), maxWidth: 155},

  passportTypeText: {page: 2, x: 30, y: fromTop(169.9), maxWidth: 230},
  passportNumber: {page: 2, x: 270, y: fromTop(169.9), maxWidth: 280},
  passportIssuedBy: {page: 2, x: 30, y: fromTop(245.0), maxWidth: 260},
  passportIssuedOn: {page: 2, x: 300, y: fromTop(245.0), maxWidth: 120},
  passportValidUntil: {page: 2, x: 430, y: fromTop(245.0), maxWidth: 120},
  rightOfReturn: {page: 2, x: 30, y: fromTop(322.5), maxWidth: 530},

  enteredOn: {page: 2, x: 30, y: fromTop(380.0), maxWidth: 160},
  visaText: {page: 2, x: 200, y: fromTop(418.3), maxWidth: 350},
  stayedBeforeText: {page: 2, x: 30, y: fromTop(495.0), maxWidth: 530},

  arrivedOn: {page: 2, x: 30, y: fromTop(599.4), maxWidth: 160},
  arrivedFrom: {page: 2, x: 200, y: fromTop(599.4), maxWidth: 360},
  maintainsAbroad: {page: 2, x: 30, y: fromTop(670.0), maxWidth: 530},

  purposeOfStay: {page: 2, x: 30, y: fromTop(730.0), maxWidth: 530},
  intendedDuration: {page: 2, x: 130, y: fromTop(760.1), maxWidth: 430},

  // ── Page 3 — work + insurance + identifying features ───
  profession: {page: 3, x: 40, y: fromTop(47.1), maxWidth: 530},
  employerLine1: {page: 3, x: 270, y: fromTop(76.1), maxWidth: 295},
  employerLine2: {page: 3, x: 270, y: fromTop(76.1) - 14, maxWidth: 295},
  employerLine3: {page: 3, x: 270, y: fromTop(76.1) - 28, maxWidth: 295},

  healthInsurance: {page: 3, x: 280, y: fromTop(170.8), maxWidth: 280},
  socialBenefits: {page: 3, x: 280, y: fromTop(220.5), maxWidth: 280},

  convictionsText: {page: 3, x: 40, y: fromTop(390.0), maxWidth: 530},
  expulsionText: {page: 3, x: 40, y: fromTop(540.0), maxWidth: 530},

  height: {page: 3, x: 130, y: fromTop(644.0), maxWidth: 100},
  eyeColor: {page: 3, x: 130, y: fromTop(679.1), maxWidth: 200},

  // ── Page 4 — signature ────────────────────────────────
  signaturePlace: {page: 4, x: 40, y: fromTop(430.0), maxWidth: 200},
  signatureDate: {page: 4, x: 250, y: fromTop(430.0), maxWidth: 100},
  signatureImage: {page: 4, x: 360, y: fromTop(460.0), maxWidth: 180},
} satisfies Record<string, FieldDraw>;

export type FieldKey = keyof typeof _FIELD_MAP_RAW;

// Widen each entry to the full FieldDraw shape so consumers can read
// optional `.size` / `.maxWidth` without TS narrowing complaints.
export const FIELD_MAP: Record<FieldKey, FieldDraw> = _FIELD_MAP_RAW;
