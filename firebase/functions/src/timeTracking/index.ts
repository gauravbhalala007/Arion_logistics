/* eslint-disable max-len, require-jsdoc, valid-jsdoc, object-curly-spacing, operator-linebreak, indent, no-trailing-spaces, eol-last, quotes, comma-dangle */
// firebase/functions/src/timeTracking/index.ts
//
// Re-Exports aller Time-Tracking Cloud Functions. Wird vom Top-Level
// index.ts (firebase/functions/src/index.ts) eingebunden.

export {clockIn} from "./clockIn";
export {clockOut} from "./clockOut";
export {pauseToggle} from "./pauseToggle";
export {
  computeMonthlyAccount,
  recomputeMonthlyAccount,
} from "./computeMonthlyAccount";
export {populateHolidays, seedHolidaysNow} from "./populateHolidays";
export {processCorrectionRequest} from "./processCorrection";
export {onAbsenceUpdated} from "./onAbsenceUpdated";
