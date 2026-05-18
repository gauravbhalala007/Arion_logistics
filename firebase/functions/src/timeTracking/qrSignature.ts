/* eslint-disable max-len, require-jsdoc, valid-jsdoc, object-curly-spacing, operator-linebreak, indent, no-trailing-spaces, eol-last, quotes, comma-dangle */
// firebase/functions/src/timeTracking/qrSignature.ts
//
// HMAC-Signatur-Verifikation für QR-Codes am Hub-Eingang.
//
// Format des QR-Inhalts:
//   codriver://clock?h={hubId}&v={secretVersion}&sig={base64url(HMAC-SHA256)}
//
// Beispiel:
//   codriver://clock?h=DBY5_main&v=1&sig=aXFlbmRyaW5fX2hVRjJYWHE
//
// Der QR-Sticker wird einmal pro Hub gedruckt; der `sig` ist HMAC-SHA256
// über "<hubId>:<secretVersion>" mit dem Hub-spezifischen Secret. Wenn
// das Secret rotiert wird, erhöht sich `secretVersion`, alte Sticker
// werden ungültig.

import * as crypto from "node:crypto";

export interface ParsedQr {
  hubId: string;
  version: number;
  signature: string;
}

export function parseQrToken(token: string): ParsedQr | null {
  try {
    const url = new URL(token);
    if (url.protocol !== "codriver:") return null;
    if (url.host !== "clock") return null;
    const hubId = url.searchParams.get("h");
    const v = url.searchParams.get("v");
    const sig = url.searchParams.get("sig");
    if (!hubId || !v || !sig) return null;
    return {hubId, version: Number(v), signature: sig};
  } catch (_) {
    return null;
  }
}

export function verifyQrSignature(
  parsed: ParsedQr,
  secret: string,
): boolean {
  const expected = crypto
    .createHmac("sha256", secret)
    .update(`${parsed.hubId}:${parsed.version}`)
    .digest("base64url");
  // timingSafeEqual erwartet gleich lange Buffer
  const a = Buffer.from(parsed.signature);
  const b = Buffer.from(expected);
  if (a.length !== b.length) return false;
  return crypto.timingSafeEqual(a, b);
}

/**
 * Erzeugt einen neuen QR-Token. Wird genutzt vom Admin-UI, wenn ein
 * neuer Hub-Sticker gebraucht wird oder das Secret rotiert wird.
 */
export function makeQrToken(
  hubId: string,
  version: number,
  secret: string,
): string {
  const sig = crypto
    .createHmac("sha256", secret)
    .update(`${hubId}:${version}`)
    .digest("base64url");
  return `codriver://clock?h=${encodeURIComponent(hubId)}&v=${version}&sig=${sig}`;
}
