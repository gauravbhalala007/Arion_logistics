// firebase/functions/src/index.ts

/* eslint-disable object-curly-spacing, max-len */

// Minimal Firebase Functions file just for driver sub-accounts + notifications

import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import * as https from "node:https";

import {initializeApp} from "firebase-admin/app";
import {getFirestore, FieldValue} from "firebase-admin/firestore";
import { getAuth, UserRecord } from "firebase-admin/auth";
import {getStorage} from "firebase-admin/storage";

import {onSchedule} from "firebase-functions/v2/scheduler";

// Initialize Admin SDK once
initializeApp();

const db = getFirestore();
const auth = getAuth();

type CreateDriverLoginData = {
  dspUid?: string;
  transporterId?: string;
  password?: string;
};

type AuthLikeError = {
  code?: string;
  message?: string;
};

type PublishNotificationData = {
  dspUid?: string;
  type?: string; // rule|message|academy|rideAlong
  title?: string;
  body?: string;
  requiresConfirmation?: boolean;
  sourceLang?: string;
  translations?: unknown;
};

type DriverNotificationActionData = {
  dspUid?: string;
  transporterId?: string;
  notificationId?: string;
};

type DeleteNotificationData = {
  dspUid?: string;
  notificationId?: string;
};

type ReorderRulesData = {
  dspUid?: string;
  notificationIds?: unknown;
};

type DeleteDriverData = {
  dspUid?: string;
  transporterId?: string;
};

type CreateDispatcherAccountData = {
  email?: string;
  password?: string;
  displayName?: string;
};

type UpdateDispatcherAccountData = {
  dispatcherUid?: string;
  email?: string;
  password?: string;
  displayName?: string;
  active?: boolean;
  permissions?: Record<string, unknown>;
};

type DeleteDispatcherAccountData = {
  dispatcherUid?: string;
};

type DeleteFeedbackData = {
  feedbackId?: string;
};

type TranslateFaqTextData = {
  sourceLang?: string;
  targetLangs?: unknown;
  question?: string;
  answer?: string;
};

type NotificationTranslationRow = {
  title: string;
  body: string;
};

/**
 * Returns true if the caller is authenticated.
 * @param {unknown} authCtx onCall request.auth
 * @return {boolean} whether caller is signed in
 */
function hasAuth(authCtx: unknown): authCtx is {uid: string} {
  return !!authCtx && typeof (authCtx as {uid?: unknown}).uid === "string" &&
    !!(authCtx as {uid: string}).uid.trim();
}

/**
 * Ensures the caller is signed in and returns uid.
 * @param {unknown} authCtx onCall request.auth
 * @return {string} uid
 */
function requireAuthUid(authCtx: unknown): string {
  if (!hasAuth(authCtx)) {
    throw new HttpsError(
      "unauthenticated",
      "Only authenticated users can call this function.",
    );
  }
  return authCtx.uid;
}

/**
 * Normalizes translated notification payloads to a safe lang->title/body map.
 * @param {unknown} raw
 * @return {Record<string, NotificationTranslationRow>}
 */
function sanitizeNotificationTranslations(
  raw: unknown,
): Record<string, NotificationTranslationRow> {
  if (!raw || typeof raw !== "object") return {};

  const out: Record<string, NotificationTranslationRow> = {};
  for (const [langRaw, value] of Object.entries(
    raw as Record<string, unknown>,
  )) {
    const lang = langRaw.trim().toLowerCase();
    if (!/^[a-z]{2}$/.test(lang) || !value || typeof value !== "object") {
      continue;
    }

    const row = value as Record<string, unknown>;
    const title = (row.title || "").toString().trim();
    const body = (row.body || "").toString().trim();
    if (!title && !body) continue;

    out[lang] = {title, body};
  }

  return out;
}

/**
 * Driver "working" flag from users/{dspUid}/drivers/{driverId}.active
 * Missing values default to true for backward compatibility.
 * @param {Record<string, unknown>} driverData
 * @return {boolean}
 */
function isDriverWorking(driverData: Record<string, unknown>): boolean {
  const parseBoolish = (raw: unknown): boolean | null => {
    if (typeof raw === "boolean") return raw;
    if (typeof raw === "number") return raw !== 0;
    if (typeof raw === "string") {
      const v = raw.trim().toLowerCase();
      if (v === "false" || v === "0" || v === "off" || v === "inactive") {
        return false;
      }
      if (v === "true" || v === "1" || v === "on" || v === "active") {
        return true;
      }
    }
    return null;
  };

  const active = parseBoolish(driverData.active);
  const working = parseBoolish(driverData.working);
  const isWorking = parseBoolish(driverData.isWorking);

  if (active === false || working === false || isWorking === false) {
    return false;
  }

  const statusRaw = driverData.status;
  if (typeof statusRaw === "string") {
    const status = statusRaw.trim().toLowerCase();
    if (status === "off" || status === "inactive" || status === "suspended") {
      return false;
    }
  }

  if (active === true || working === true || isWorking === true) {
    return true;
  }

  return true;
}

/**
 * Very small helper for GET calls without adding dependencies.
 * @param {string} url
 * @return {Promise<string>}
 */
function getText(url: string): Promise<string> {
  return new Promise((resolve, reject) => {
    const req = https.get(url, (res) => {
      let body = "";
      res.setEncoding("utf8");
      res.on("data", (chunk) => {
        body += chunk;
      });
      res.on("end", () => {
        const code = res.statusCode ?? 500;
        if (code >= 400) {
          reject(new Error(`HTTP ${code}`));
          return;
        }
        resolve(body);
      });
    });

    req.on("error", reject);
    req.setTimeout(8000, () => {
      req.destroy(new Error("Request timeout"));
    });
  });
}

/**
 * Parses translate.googleapis.com response.
 * Expected shape starts with an array of translated text segments.
 * @param {unknown} raw
 * @return {string}
 */
function parseTranslatedSegments(raw: unknown): string {
  if (!Array.isArray(raw) || raw.length === 0) return "";
  const segmentsRoot = raw[0];
  if (!Array.isArray(segmentsRoot)) return "";

  const out: string[] = [];
  for (const seg of segmentsRoot) {
    if (!Array.isArray(seg) || seg.length === 0) continue;
    const translated = seg[0];
    if (typeof translated === "string" && translated.trim().length > 0) {
      out.push(translated);
    }
  }
  return out.join("");
}

/**
 * Best-effort translation using public Google Translate endpoint.
 * Returns empty string if input is empty or translation fails.
 * @param {string} text
 * @param {string} sourceLang
 * @param {string} targetLang
 * @return {Promise<string>}
 */
async function translateTextBestEffort(
  text: string,
  sourceLang: string,
  targetLang: string,
): Promise<string> {
  const clean = text.trim();
  if (!clean) return "";

  try {
    const query = encodeURIComponent(clean);
    const url =
      "https://translate.googleapis.com/translate_a/single" +
      `?client=gtx&sl=${encodeURIComponent(sourceLang)}` +
      `&tl=${encodeURIComponent(targetLang)}&dt=t&q=${query}`;
    const responseText = await getText(url);
    const parsed = JSON.parse(responseText) as unknown;
    const translated = parseTranslatedSegments(parsed).trim();
    return translated || clean;
  } catch (err) {
    logger.warn(
      `translateTextBestEffort failed ${sourceLang}->${targetLang}`,
      err,
    );
    return "";
  }
}

/**
 * Creates or updates a Firebase Auth login for a driver sub-account under a DSP.
 *
 * Security:
 * - Only allows authenticated callers.
 * - Caller UID must match dspUid.
 *
 * Side effects:
 * - Creates/updates Auth user (email+password).
 * - Sets custom claims { role: "driver", dspUid, transporterId }.
 * - Creates/updates top-level users/{driverUid}.
 * - Updates users/{dspUid}/drivers/{TRANSPORTER_ID} with login linkage.
 */
export const createDriverLogin = onCall(async (request) => {
  const ctx = request.auth;
  if (!ctx || !ctx.uid) {
    throw new HttpsError(
      "unauthenticated",
      "Only authenticated users can create driver logins.",
    );
  }

  const data = (request.data || {}) as CreateDriverLoginData;

  const dspUid = (data.dspUid || "").trim();
  const transporterIdRaw = (data.transporterId || "").trim();
  const password = (data.password || "").toString();

  if (!dspUid || !transporterIdRaw || !password) {
    throw new HttpsError(
      "invalid-argument",
      "dspUid, transporterId and password are required.",
    );
  }

  // Security: DSP can only create logins for their own account
  if (ctx.uid !== dspUid) {
    throw new HttpsError(
      "permission-denied",
      "You can only create driver logins for your own DSP.",
    );
  }

  const transporterId = transporterIdRaw.toUpperCase();

  // Find driver under this DSP
  const driverRef = db
    .collection("users")
    .doc(dspUid)
    .collection("drivers")
    .doc(transporterId);

  const driverSnap = await driverRef.get();
  if (!driverSnap.exists) {
    throw new HttpsError(
      "not-found",
      `Driver with transporterId=${transporterId} does not exist.`,
    );
  }

  const driverData = driverSnap.data() || {};
  const driverName = (driverData.driverName ?? "").toString();
  const existingEmail = (driverData.email ?? "").toString().trim();

  // If driver has a real email, use that. Otherwise create a synthetic one.
  const loginEmail =
    existingEmail || `${transporterId}_${dspUid}@drivers.dsp-copilot.local`;

  let userRecord: UserRecord;

  try {
    // If user already exists with this email → update password.
    const existingUser = await auth.getUserByEmail(loginEmail);
    userRecord = await auth.updateUser(existingUser.uid, {
      password,
      displayName: driverName || undefined,
    });
    logger.info(
      `Updated existing driver user for ${loginEmail} (uid=${userRecord.uid})`,
    );
  } catch (err: unknown) {
    const e = (typeof err === "object" && err !== null ? err : {}) as AuthLikeError;

    if (e.code === "auth/user-not-found") {
      // Create fresh driver auth user
      userRecord = await auth.createUser({
        email: loginEmail,
        password,
        displayName: driverName || undefined,
        emailVerified: !!existingEmail, // if you used real email
      });
      logger.info(
        `Created new driver user for ${loginEmail} (uid=${userRecord.uid})`,
      );
    } else {
      logger.error("Error in createDriverLogin:", err);

      const msg = typeof e.message === "string" && e.message.trim() ?
        e.message :
        String(err);

      throw new HttpsError(
        "internal",
        `Error while creating/updating driver auth user: ${msg}`,
      );
    }
  }

  // Custom claims → used on frontend (AuthGate) to route drivers
  await auth.setCustomUserClaims(userRecord.uid, {
    role: "driver",
    dspUid,
    transporterId,
  });

  const now = FieldValue.serverTimestamp();

  // Top-level user doc for driver (this is what AuthGate reads)
  const driverUserRef = db.collection("users").doc(userRecord.uid);
  await driverUserRef.set(
    {
      role: "driver",
      dspUid,
      transporterId,
      driverName: driverName || null,
      email: loginEmail,
      approved: true, // drivers created by DSP are auto-approved
      updatedAt: now,
      createdAt: now,
    },
    {merge: true},
  );

  // Link back from DSP's driver doc
  await driverRef.set(
    {
      hasLogin: true,
      authUid: userRecord.uid,
      loginEmail,
      updatedAt: now,
    },
    {merge: true},
  );

  // Backfill existing RULE notifications so new drivers can see old rules.
  const adminRulesSnap = await db
    .collection("users")
    .doc(dspUid)
    .collection("notifications")
    .where("type", "==", "rule")
    .get();

  if (!adminRulesSnap.empty) {
    const driverNotifsCol = driverRef.collection("notifications");

    const existenceChecks = adminRulesSnap.docs.map(async (doc) => {
      const driverNotifSnap = await driverNotifsCol.doc(doc.id).get();
      return {doc, exists: driverNotifSnap.exists};
    });

    const checks = await Promise.all(existenceChecks);
    const missing = checks.filter((c) => !c.exists).map((c) => c.doc);

    const chunkSize = 200;
    for (let i = 0; i < missing.length; i += chunkSize) {
      const chunk = missing.slice(i, i + chunkSize);
      const batch = db.batch();

      for (const adminDoc of chunk) {
        const adminData = adminDoc.data() || {};
        const driverNotifRef = driverNotifsCol.doc(adminDoc.id);

        batch.set(driverNotifRef, {
          notificationId: adminDoc.id,
          type: adminData.type || "rule",
          title: adminData.title || "",
          body: adminData.body || "",
          sourceLang: adminData.sourceLang || "en",
          translations: adminData.translations || {},
          status: "unread",
          createdAt: adminData.createdAt || FieldValue.serverTimestamp(),
          readAt: null,
          confirmedAt: null,
          requiresConfirmation: adminData.requiresConfirmation ?? true,
          sortOrder: typeof adminData.sortOrder === "number" ?
            adminData.sortOrder :
            null,
        });

        batch.set(
          adminDoc.ref,
          {targetCount: FieldValue.increment(1)},
          {merge: true},
        );
      }

      await batch.commit();
    }
  }

  return {
    uid: userRecord.uid,
    email: loginEmail,
  };
});

/**
 * Publishes a notification to ALL drivers of a DSP and writes a history record.
 *
 * Security:
 * - caller must be authenticated
 * - caller uid must equal dspUid
 *
 * Writes:
 * - users/{dspUid}/notifications/{notifId} (history)
 * - users/{dspUid}/drivers/{TID}/notifications/{notifId} (fan-out)
 */
export const publishNotificationToAllDrivers = onCall(async (request) => {
  const callerUid = requireAuthUid(request.auth);
  const data = (request.data || {}) as PublishNotificationData;

  const dspUid = (data.dspUid || "").trim();
  const type = (data.type || "").trim();
  const title = (data.title || "").trim();
  const body = (data.body || "").trim();
  const sourceLang = (data.sourceLang || "en").toString().trim().toLowerCase();
  const translations = sanitizeNotificationTranslations(data.translations);
  const requiresConfirmation = true;


  if (!dspUid || !type || (title.length === 0 && body.length === 0)) {
    throw new HttpsError(
      "invalid-argument",
      "dspUid, type and (title or body) are required.",
    );
  }

  if (callerUid !== dspUid) {
    throw new HttpsError(
      "permission-denied",
      "You can only publish notifications for your own DSP.",
    );
  }

  const allowed = new Set(["rule", "message", "academy", "rideAlong"]);
  if (!allowed.has(type)) {
    throw new HttpsError(
      "invalid-argument",
      "Invalid notification type.",
    );
  }

  if (!/^[a-z]{2}$/.test(sourceLang)) {
    throw new HttpsError(
      "invalid-argument",
      "sourceLang must be 2 letters.",
    );
  }

  // Load drivers under this DSP
  const driversSnap = await db
    .collection("users")
    .doc(dspUid)
    .collection("drivers")
    .get();

  const drivers = driversSnap.docs.filter((d) => {
    const data = d.data() as Record<string, unknown>;
    return isDriverWorking(data);
  });
  const targetCount = drivers.length;
  let sortOrder: number | null = null;

  if (type === "rule") {
    const adminRulesSnap = await db
      .collection("users")
      .doc(dspUid)
      .collection("notifications")
      .where("type", "==", "rule")
      .get();

    let maxSortOrder = -1;
    for (const doc of adminRulesSnap.docs) {
      const raw = doc.data().sortOrder;
      if (typeof raw === "number" && raw > maxSortOrder) {
        maxSortOrder = raw;
      }
    }
    sortOrder = maxSortOrder + 1;
  }

  // Create history record first (single doc)
  const adminNotifRef = db
    .collection("users")
    .doc(dspUid)
    .collection("notifications")
    .doc();

  const notifId = adminNotifRef.id;

  await adminNotifRef.set({
    type,
    title,
    body,
    sourceLang,
    translations,
    createdAt: FieldValue.serverTimestamp(),
    createdBy: callerUid,
    target: "all",
    targetCount,
    confirmedCount: 0,
    requiresConfirmation,
    ...(sortOrder != null ? {sortOrder} : {}),
  });

  // Fan-out: chunk commits (batch limit is 500 writes)
  const chunkSize = 450;
  for (let i = 0; i < drivers.length; i += chunkSize) {
    const chunk = drivers.slice(i, i + chunkSize);
    const batch = db.batch();

    for (const d of chunk) {
      const driverNotifRef = d.ref.collection("notifications").doc(notifId);
      batch.set(driverNotifRef, {
        notificationId: notifId,
        type,
        title,
        body,
        sourceLang,
        translations,
        status: "unread",
        createdAt: FieldValue.serverTimestamp(),
        readAt: null,
        confirmedAt: null,
        requiresConfirmation,
        ...(sortOrder != null ? {sortOrder} : {}),
      });
    }

    await batch.commit();
  }

  logger.info(`Published notification ${notifId} to ${targetCount} drivers for dspUid=${dspUid}`);

  return {
    notificationId: notifId,
    targetCount,
  };
});

/**
 * Marks a driver notification as read.
 *
 * Security:
 * - caller must be authenticated driver
 * - caller's user doc must have matching dspUid and transporterId
 *
 * Writes:
 * - updates users/{dspUid}/drivers/{TID}/notifications/{notifId}
 */
export const markDriverNotificationRead = onCall(async (request) => {
  const callerUid = requireAuthUid(request.auth);
  const data = (request.data || {}) as DriverNotificationActionData;

  const dspUid = (data.dspUid || "").trim();
  const transporterId = (data.transporterId || "").trim().toUpperCase();
  const notificationId = (data.notificationId || "").trim();

  if (!dspUid || !transporterId || !notificationId) {
    throw new HttpsError(
      "invalid-argument",
      "dspUid, transporterId and notificationId are required.",
    );
  }

  // Verify caller is that driver (by top-level users/{uid})
  const meSnap = await db.collection("users").doc(callerUid).get();
  const me = meSnap.data() || {};

  if (me.role !== "driver" || me.dspUid !== dspUid || (me.transporterId || "").toString().toUpperCase() !== transporterId) {
    throw new HttpsError("permission-denied", "Not allowed.");
  }

  const ref = db
    .collection("users")
    .doc(dspUid)
    .collection("drivers")
    .doc(transporterId)
    .collection("notifications")
    .doc(notificationId);

  const snap = await ref.get();
  if (!snap.exists) {
    throw new HttpsError("not-found", "Notification not found.");
  }

  const current = snap.data() || {};
  if (current.status === "confirmed" || current.status === "read") {
    return {ok: true};
  }

  await ref.set({
    status: "read",
    readAt: FieldValue.serverTimestamp(),
  }, {merge: true});

  return {ok: true};
});

/**
 * Confirms a driver notification (manual confirmation).
 *
 * Security:
 * - caller must be authenticated driver
 * - caller's user doc must have matching dspUid and transporterId
 *
 * Writes:
 * - updates users/{dspUid}/drivers/{TID}/notifications/{notifId}
 * - increments users/{dspUid}/notifications/{notifId}.confirmedCount
 */
export const confirmDriverNotification = onCall(async (request) => {
  const callerUid = requireAuthUid(request.auth);
  const data = (request.data || {}) as DriverNotificationActionData;

  const dspUid = (data.dspUid || "").trim();
  const transporterId = (data.transporterId || "").trim().toUpperCase();
  const notificationId = (data.notificationId || "").trim();

  if (!dspUid || !transporterId || !notificationId) {
    throw new HttpsError(
      "invalid-argument",
      "dspUid, transporterId and notificationId are required.",
    );
  }

  // Verify caller identity
  const meSnap = await db.collection("users").doc(callerUid).get();
  const me = meSnap.data() || {};

  if (
    me.role !== "driver" ||
    me.dspUid !== dspUid ||
    (me.transporterId || "").toString().toUpperCase() !== transporterId
  ) {
    throw new HttpsError("permission-denied", "Not allowed.");
  }

  const driverNotifRef = db
    .collection("users")
    .doc(dspUid)
    .collection("drivers")
    .doc(transporterId)
    .collection("notifications")
    .doc(notificationId);

  const adminNotifRef = db
    .collection("users")
    .doc(dspUid)
    .collection("notifications")
    .doc(notificationId);

  await db.runTransaction(async (tx) => {
    // ✅ ALL READS FIRST
    const driverSnap = await tx.get(driverNotifRef);
    const adminSnap = await tx.get(adminNotifRef);

    if (!driverSnap.exists) {
      throw new HttpsError("not-found", "Notification not found.");
    }

    const driverData = driverSnap.data() || {};
    if (driverData.status === "confirmed") {
      return;
    }

    // ✅ THEN WRITES
    tx.set(
      driverNotifRef,
      {
        status: "confirmed",
        confirmedAt: FieldValue.serverTimestamp(),
        readAt: driverData.readAt ?? FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );

    if (adminSnap.exists) {
      tx.set(
        adminNotifRef,
        {
          confirmedCount: FieldValue.increment(1),
        },
        { merge: true },
      );
    }
  });

  return { ok: true };
});

/**
 * Scheduled job: create/update/delete document-expiry notifications for drivers.
 *
 * Writes ONLY to:
 * users/{dspUid}/drivers/{transporterId}/notifications/{notificationId}
 *
 * No admin history.
 *
 * Deduping:
 * - Uses deterministic doc IDs per document field.
 *
 * Behavior:
 * - daysLeft <= 0  => "expired"
 * - 0 < daysLeft <= 30 => "expiring soon"
 * - daysLeft > 30 => delete existing expiry notification (if any)
 *
 * Re-notify rule:
 * - If expiry date string changed, reset status to "unread" (even if still expiring soon)
 * - Otherwise do not spam: keep current status/readAt as-is
 */
export const syncDriverDocExpiryNotifications = onSchedule(
  {
    schedule: "every 12 hours", // UTC time by default; adjust if you want
    region: "us-central1",
    timeZone: "Europe/Berlin",
    memory: "256MiB",
  },
  async () => {
    const MS_PER_DAY = 24 * 60 * 60 * 1000;

    /**
     * Parses a YYYY-MM-DD string into a UTC Date at 00:00.
     * @param {string} ymd date string in YYYY-MM-DD format
     * @return {Date|null} parsed UTC date or null if invalid
     */
    function parseYmdToUtcDate(ymd: string): Date | null {
      const s = (ymd || "").trim();
      // expected YYYY-MM-DD
      const m = /^(\d{4})-(\d{2})-(\d{2})$/.exec(s);
      if (!m) return null;
      const y = Number(m[1]);
      const mo = Number(m[2]);
      const d = Number(m[3]);
      if (!y || mo < 1 || mo > 12 || d < 1 || d > 31) return null;
      return new Date(Date.UTC(y, mo - 1, d, 0, 0, 0));
    }

    /**
     * Returns today's date at UTC midnight.
     * @return {Date} UTC start-of-day
     */
    function utcStartOfToday(): Date {
      const now = new Date();
      return new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate(), 0, 0, 0));
    }

    /**
     * Calculates full-day difference between today and expiry.
     * @param {Date} todayUtc UTC start-of-today
     * @param {Date} expiryUtc UTC expiry date
     * @return {number} number of days until expiry
     */
    function daysBetweenUtc(todayUtc: Date, expiryUtc: Date): number {
      const diff = expiryUtc.getTime() - todayUtc.getTime();
      return Math.floor(diff / MS_PER_DAY);
    }

    const todayUtc = utcStartOfToday();

    // Get DSPs (admins). Adjust this if your DSP docs are identified differently.
    const dspSnap = await db
      .collection("users")
      .where("role", "==", "admin")
      .where("approved", "==", true)
      .get();

    for (const dspDoc of dspSnap.docs) {
      const dspUid = dspDoc.id;

      const driversSnap = await db
        .collection("users")
        .doc(dspUid)
        .collection("drivers")
        .get();

      // Batch per DSP (avoid 500 limit by chunking)
      const writes: Array<Promise<unknown>> = [];

      for (const driverDoc of driversSnap.docs) {
        const transporterId = driverDoc.id; // already uppercase in your structure
        const driverData = driverDoc.data() || {};
        const onboarding = (driverData.onboarding || {}) as Record<string, unknown>;

        // Exact keys you provided
        const fields: Array<{key: "licenseExpiry" | "idDocExpiry" | "residencePermitExpiry"; label: string}> = [
          {key: "licenseExpiry", label: "Driving License"},
          {key: "idDocExpiry", label: "ID/Passport"},
          {key: "residencePermitExpiry", label: "Work/Residence Permit"},
        ];

        for (const f of fields) {
          const raw = (onboarding[f.key] ?? "").toString().trim();
          const notifId = `docExpiry_${f.key}`;

          const notifRef = db
            .collection("users")
            .doc(dspUid)
            .collection("drivers")
            .doc(transporterId)
            .collection("notifications")
            .doc(notifId);

          // If missing/unparseable date -> remove existing notification (clean)
          const expiryUtc = parseYmdToUtcDate(raw);
          if (!expiryUtc) {
            writes.push(
              notifRef.get().then((s) => (s.exists ? notifRef.delete() : null)),
            );
            continue;
          }

          const daysLeft = daysBetweenUtc(todayUtc, expiryUtc);

          // If not within 30 days -> delete existing expiry notification
          if (daysLeft > 30) {
            writes.push(
              notifRef.get().then((s) => (s.exists ? notifRef.delete() : null)),
            );
            continue;
          }

          const severity = daysLeft <= 0 ? "expired" : "expiringSoon";

          const title =
            severity === "expired" ?
              `${f.label} expired on ${raw}` :
              `${f.label} expires on ${raw}`;

          const body =
            severity === "expired" ?
              `${f.label} expired on ${raw}. Please update your document.` :
              `${f.label} will expire on ${raw} (in ${daysLeft} day${daysLeft === 1 ? "" : "s"}). Please renew soon.`;

          // Dedup + re-notify only if expiry date changed:
          writes.push(
            (async () => {
              const existing = await notifRef.get();
              const existingData = existing.data() || {};
              const existingExpiry = (existingData["expiryDate"] ?? "").toString().trim();

              const expiryChanged = existingExpiry && existingExpiry !== raw;

              // If expiry changed and still within range -> reset to unread
              const shouldResetUnread = expiryChanged;

              const patch: Record<string, unknown> = {
                type: "docExpiry",
                docKey: f.key,
                docLabel: f.label,
                severity,
                title,
                body,
                expiryDate: raw,
                // keep requiresConfirmation false for these
                requiresConfirmation: true,
                updatedAt: FieldValue.serverTimestamp(),
              };

              // First time create
              if (!existing.exists) {
                patch["status"] = "unread";
                patch["createdAt"] = FieldValue.serverTimestamp();
                patch["readAt"] = null;
                patch["confirmedAt"] = null;
                await notifRef.set(patch, {merge: true});
                return;
              }

              // Update existing
              if (shouldResetUnread) {
                patch["status"] = "unread";
                patch["readAt"] = null;
                patch["confirmedAt"] = null;
              }

              await notifRef.set(patch, {merge: true});
            })(),
          );
        }
      }

      // Avoid unbounded parallelism: flush in chunks
      const CHUNK = 250;
      for (let i = 0; i < writes.length; i += CHUNK) {
        await Promise.allSettled(writes.slice(i, i + CHUNK));
      }
    }

    logger.info("syncDriverDocExpiryNotifications: completed");
  },
);

/**
 * Reorders rule notifications for admin history and all driver copies.
 *
 * Security:
 * - caller must be authenticated
 * - caller uid must equal dspUid
 */
export const reorderRulesEverywhere = onCall(async (request) => {
  const callerUid = requireAuthUid(request.auth);
  const data = (request.data || {}) as ReorderRulesData;

  const dspUid = (data.dspUid || "").trim();
  const rawIds = Array.isArray(data.notificationIds) ? data.notificationIds : [];
  const notificationIds = Array.from(
    new Set(
      rawIds
        .map((value) => (value || "").toString().trim())
        .filter((value) => value.length > 0),
    ),
  );

  if (!dspUid || notificationIds.length === 0) {
    throw new HttpsError(
      "invalid-argument",
      "dspUid and notificationIds are required.",
    );
  }

  if (callerUid !== dspUid) {
    throw new HttpsError(
      "permission-denied",
      "You can only reorder rules for your own DSP.",
    );
  }

  const adminRulesCol = db
    .collection("users")
    .doc(dspUid)
    .collection("notifications");

  const adminRuleSnaps = await Promise.all(
    notificationIds.map((id) => adminRulesCol.doc(id).get()),
  );

  for (const snap of adminRuleSnaps) {
    if (!snap.exists) {
      throw new HttpsError("not-found", `Rule ${snap.id} was not found.`);
    }
    const type = (snap.data()?.type || "").toString().trim();
    if (type !== "rule") {
      throw new HttpsError(
        "failed-precondition",
        `Notification ${snap.id} is not a rule.`,
      );
    }
  }

  const now = FieldValue.serverTimestamp();
  let batch = db.batch();
  let opCount = 0;

  const flush = async () => {
    if (opCount === 0) return;
    await batch.commit();
    batch = db.batch();
    opCount = 0;
  };

  for (let i = 0; i < notificationIds.length; i += 1) {
    batch.set(
      adminRulesCol.doc(notificationIds[i]),
      {sortOrder: i, updatedAt: now},
      {merge: true},
    );
    opCount += 1;
    if (opCount >= 450) {
      await flush();
    }
  }
  await flush();

  const idToSortOrder = new Map<string, number>();
  for (let i = 0; i < notificationIds.length; i += 1) {
    idToSortOrder.set(notificationIds[i], i);
  }

  const driversSnap = await db
    .collection("users")
    .doc(dspUid)
    .collection("drivers")
    .get();

  for (const driverDoc of driversSnap.docs) {
    const driverRulesSnap = await driverDoc.ref
      .collection("notifications")
      .where("type", "==", "rule")
      .get();

    batch = db.batch();
    opCount = 0;
    for (const ruleDoc of driverRulesSnap.docs) {
      const nextSortOrder = idToSortOrder.get(ruleDoc.id);
      if (nextSortOrder == null) continue;

      batch.set(
        ruleDoc.ref,
        {sortOrder: nextSortOrder, updatedAt: now},
        {merge: true},
      );
      opCount += 1;
      if (opCount >= 450) {
        await batch.commit();
        batch = db.batch();
        opCount = 0;
      }
    }

    if (opCount > 0) {
      await batch.commit();
    }
  }

  logger.info(
    `reorderRulesEverywhere: reordered ${notificationIds.length} rules for dspUid=${dspUid}`,
  );
  return {ok: true, count: notificationIds.length};
});

/**
 * Deletes a broadcast notification from:
 * - users/{dspUid}/notifications/{notificationId}           (admin history)
 * - users/{dspUid}/drivers/{transporterId}/notifications/{notificationId} (all drivers)
 *
 * Security:
 * - caller must be authenticated
 * - caller uid must equal dspUid
 */
export const deleteNotificationEverywhere = onCall(async (request) => {
  const callerUid = requireAuthUid(request.auth);
  const data = (request.data || {}) as DeleteNotificationData;

  const dspUid = (data.dspUid || "").trim();
  const notificationId = (data.notificationId || "").trim();

  if (!dspUid || !notificationId) {
    throw new HttpsError("invalid-argument", "dspUid and notificationId are required.");
  }

  if (callerUid !== dspUid) {
    throw new HttpsError("permission-denied", "You can only delete notifications for your own DSP.");
  }

  const adminNotifRef = db
    .collection("users")
    .doc(dspUid)
    .collection("notifications")
    .doc(notificationId);

  const driversSnap = await db
    .collection("users")
    .doc(dspUid)
    .collection("drivers")
    .get();

  const drivers = driversSnap.docs;

  // If no drivers, still delete admin doc.
  if (drivers.length === 0) {
    await adminNotifRef.delete().catch(() => null);
    return { ok: true, deletedFromDrivers: 0 };
  }

  // Batch delete from driver subcollections + admin doc
  const chunkSize = 450;
  for (let i = 0; i < drivers.length; i += chunkSize) {
    const chunk = drivers.slice(i, i + chunkSize);
    const batch = db.batch();

    for (const d of chunk) {
      const driverNotifRef = d.ref.collection("notifications").doc(notificationId);
      batch.delete(driverNotifRef);
    }

    // delete admin doc once
    if (i === 0) {
      batch.delete(adminNotifRef);
    }

    await batch.commit();
  }

  logger.info(`deleteNotificationEverywhere: deleted ${notificationId} for dspUid=${dspUid} (drivers=${drivers.length})`);
  return { ok: true, deletedFromDrivers: drivers.length };
});

/**
 * Deletes a driver account end-to-end:
 * - Firebase Auth user (if linked)
 * - users/{driverUid} doc (if linked)
 * - users/{dspUid}/drivers/{transporterId} doc
 *
 * Security:
 * - caller must be authenticated
 * - caller uid must equal dspUid
 */
export const deleteDriverAccount = onCall(async (request) => {
  const callerUid = requireAuthUid(request.auth);
  const data = (request.data || {}) as DeleteDriverData;

  const dspUid = (data.dspUid || "").trim();
  const transporterId = (data.transporterId || "").trim().toUpperCase();

  if (!dspUid || !transporterId) {
    throw new HttpsError(
      "invalid-argument",
      "dspUid and transporterId are required.",
    );
  }

  if (callerUid !== dspUid) {
    throw new HttpsError(
      "permission-denied",
      "You can only delete drivers for your own DSP.",
    );
  }

  const driverRef = db
    .collection("users")
    .doc(dspUid)
    .collection("drivers")
    .doc(transporterId);

  const driverSnap = await driverRef.get();
  if (!driverSnap.exists) {
    throw new HttpsError("not-found", "Driver not found.");
  }

  const driverData = driverSnap.data() || {};
  let authUid = (driverData.authUid ?? "").toString().trim();
  const loginEmail = (driverData.loginEmail ?? "").toString().trim();

  if (!authUid && loginEmail) {
    try {
      const u = await auth.getUserByEmail(loginEmail);
      authUid = u.uid;
    } catch (err) {
      logger.warn(`deleteDriverAccount: auth lookup failed email=${loginEmail}`, err);
    }
  }

  let authDeleted = false;
  let userDocDeleted = false;

  if (authUid) {
    try {
      await auth.deleteUser(authUid);
      authDeleted = true;
    } catch (err) {
      logger.warn(`deleteDriverAccount: auth delete failed uid=${authUid}`, err);
    }

    try {
      await db.collection("users").doc(authUid).delete();
      userDocDeleted = true;
    } catch (err) {
      logger.warn(`deleteDriverAccount: user doc delete failed uid=${authUid}`, err);
    }
  }

  await driverRef.delete();

  logger.info(
    `deleteDriverAccount: deleted driver ${transporterId} for dspUid=${dspUid} (authDeleted=${authDeleted}, userDocDeleted=${userDocDeleted})`,
  );

  return { ok: true, authDeleted, userDocDeleted };
});

/**
 * Auto-translates FAQ question/answer from one source language to targets.
 * Caller must be authenticated.
 */
export const translateFaqText = onCall(async (request) => {
  requireAuthUid(request.auth);

  const data = (request.data || {}) as TranslateFaqTextData;

  const sourceLang = (data.sourceLang || "en").toString().trim().toLowerCase();
  const question = (data.question || "").toString().trim();
  const answer = (data.answer || "").toString().trim();

  if (!/^[a-z]{2}$/.test(sourceLang)) {
    throw new HttpsError("invalid-argument", "sourceLang must be 2 letters.");
  }

  if (!question && !answer) {
    throw new HttpsError(
      "invalid-argument",
      "question or answer is required.",
    );
  }

  const rawTargets = Array.isArray(data.targetLangs) ? data.targetLangs : [];
  const targets = Array.from(
    new Set(
      rawTargets
        .map((v) => (v ?? "").toString().trim().toLowerCase())
        .filter((v) => /^[a-z]{2}$/.test(v) && v !== sourceLang),
    ),
  ).slice(0, 12);

  if (targets.length === 0) {
    throw new HttpsError(
      "invalid-argument",
      "At least one valid target language is required.",
    );
  }

  const translations: Record<string, {question: string; answer: string}> = {};

  await Promise.all(
    targets.map(async (targetLang) => {
      const qText = question ?
        await translateTextBestEffort(question, sourceLang, targetLang) :
        "";
      const aText = answer ?
        await translateTextBestEffort(answer, sourceLang, targetLang) :
        "";

      translations[targetLang] = {
        question: qText,
        answer: aText,
      };
    }),
  );

  return {
    sourceLang,
    translations,
  };
});

/**
 * Deletes a feedback document (and its attachment if present).
 * Allowed for:
 * - the submitter (createdByUid)
 * - developer role
 */
export const deleteFeedback = onCall(async (request) => {
  const uid = requireAuthUid(request.auth);
  const data = (request.data || {}) as DeleteFeedbackData;

  const feedbackId = (data.feedbackId || "").toString().trim();
  if (!feedbackId) {
    throw new HttpsError("invalid-argument", "feedbackId is required.");
  }

  const userSnap = await db.collection("users").doc(uid).get();
  const user = userSnap.data() || {};
  if (user.approved !== true) {
    throw new HttpsError("permission-denied", "User is not approved.");
  }
  const role = (user.role || "").toString().trim().toLowerCase();
  if (role === "driver") {
    throw new HttpsError("permission-denied", "Drivers cannot delete feedback.");
  }

  const ref = db.collection("feedback").doc(feedbackId);
  const snap = await ref.get();
  if (!snap.exists) {
    throw new HttpsError("not-found", "Feedback not found.");
  }

  const fbData = snap.data() || {};
  const createdByUid = (fbData.createdByUid || "").toString().trim();
  const isDeveloper = role === "developer";

  if (!isDeveloper && createdByUid !== uid) {
    throw new HttpsError("permission-denied", "Not allowed to delete this feedback.");
  }

  const attachmentPath = (fbData.attachmentPath || "").toString().trim();
  if (attachmentPath) {
    await getStorage().bucket().file(attachmentPath).delete({ignoreNotFound: true});
  }

  await ref.delete();
  return {ok: true};
});

/**
 * Scheduled job: delete resolved feedback older than 7 days.
 * Also attempts to delete the stored attachment file (if any).
 */
export const cleanupResolvedFeedback = onSchedule(
  {
    schedule: "every day 03:10",
    region: "us-central1",
    timeZone: "Europe/Berlin",
    memory: "256MiB",
  },
  async () => {
    const MS_PER_DAY = 24 * 60 * 60 * 1000;
    const cutoff = new Date(Date.now() - 7 * MS_PER_DAY);
    const bucket = getStorage().bucket();

    let totalDeleted = 0;
    // Avoid long running schedules; process in a few chunks.
    for (let round = 0; round < 8; round += 1) {
      const snap = await db
        .collection("feedback")
        .where("status", "==", "resolved")
        .where("resolvedAt", "<=", cutoff)
        .orderBy("resolvedAt", "asc")
        .limit(200)
        .get();

      if (snap.empty) break;

      const deletes: Promise<unknown>[] = [];
      const batch = db.batch();

      for (const doc of snap.docs) {
        const data = doc.data() as Record<string, unknown>;
        const attachmentPath = (data.attachmentPath || "").toString().trim();
        if (attachmentPath) {
          deletes.push(
            bucket.file(attachmentPath).delete({ignoreNotFound: true}).catch((err) => {
              logger.warn(
                `cleanupResolvedFeedback: failed to delete attachment ${attachmentPath}`,
                err,
              );
            }),
          );
        }
        batch.delete(doc.ref);
      }

      await batch.commit();
      await Promise.all(deletes);

      totalDeleted += snap.size;
    }

    if (totalDeleted > 0) {
      logger.info(
        `cleanupResolvedFeedback: deleted ${totalDeleted} resolved feedback docs older than ${cutoff.toISOString()}`,
      );
    }
  },
);

// ════════════════════════════════════════════════════════════════════════════
//  Dispatcher sub-accounts (Phase 1)
// ════════════════════════════════════════════════════════════════════════════
//
// A DSP admin can create dispatcher sub-accounts. Each dispatcher has its
// own Firebase Auth identity but reads/writes data scoped to the parent
// admin (via parentAdminUid). The admin grants per-module permissions in
// users/{adminUid}/sub_accounts/{dispatcherUid}.permissions.

const DISPATCHER_PERMISSION_KEYS = [
  "waveplan",
  "drivers_hub",
  "calendar",
  "fleet_status",
  "tasks",
  "shift_absence",
  "incident_reports",
  "academy",
  "dispatcher_pill",
  "feedback",
  "faqs",
  "approvals",
] as const;

const DISPATCHER_DEFAULT_PERMISSIONS: Record<string, boolean> = {
  waveplan: true,
  drivers_hub: false,
  calendar: true,
  fleet_status: false,
  tasks: true,
  shift_absence: false,
  incident_reports: false,
  academy: false,
  dispatcher_pill: false,
  feedback: false,
  faqs: true,
  approvals: false,
};

/**
 * Verify caller is an admin by reading their users/{uid} doc.
 * @param {string} uid caller uid
 * @return {Promise<void>} resolves if admin, throws otherwise
 */
async function requireAdminRole(uid: string): Promise<void> {
  const snap = await db.collection("users").doc(uid).get();
  const role = (snap.data()?.role ?? "").toString();
  if (role !== "admin") {
    throw new HttpsError(
      "permission-denied",
      "Only DSP admins can manage dispatcher sub-accounts.",
    );
  }
}

/**
 * Sanitize a permissions map: only keep boolean values for known keys,
 * coerce undefined/non-bool to false, fill missing keys with defaults.
 * @param {unknown} raw incoming map from the client
 * @return {Record<string, boolean>} sanitized
 */
function sanitizePermissions(raw: unknown): Record<string, boolean> {
  const out: Record<string, boolean> = {...DISPATCHER_DEFAULT_PERMISSIONS};
  if (raw && typeof raw === "object") {
    const incoming = raw as Record<string, unknown>;
    for (const key of DISPATCHER_PERMISSION_KEYS) {
      if (key in incoming) {
        out[key] = incoming[key] === true;
      }
    }
  }
  return out;
}

export const createDispatcherAccount = onCall(async (request) => {
  const callerUid = requireAuthUid(request.auth);
  await requireAdminRole(callerUid);

  const data = (request.data || {}) as CreateDispatcherAccountData;
  const email = (data.email || "").trim().toLowerCase();
  const password = (data.password || "").toString();
  const displayName = (data.displayName || "").toString().trim();

  if (!email || !password || password.length < 6) {
    throw new HttpsError(
      "invalid-argument",
      "email and password (min 6 chars) are required.",
    );
  }

  let userRecord: UserRecord;
  try {
    userRecord = await auth.createUser({
      email,
      password,
      displayName: displayName || undefined,
      emailVerified: true,
    });
  } catch (err) {
    const e = (typeof err === "object" && err !== null ? err : {}) as AuthLikeError;
    if (e.code === "auth/email-already-exists") {
      throw new HttpsError(
        "already-exists",
        "Eine Person mit dieser E-Mail existiert bereits.",
      );
    }
    logger.error("createDispatcherAccount: auth.createUser failed", err);
    throw new HttpsError(
      "internal",
      `Konnte Dispatcher-Account nicht anlegen: ${e.message || String(err)}`,
    );
  }

  await auth.setCustomUserClaims(userRecord.uid, {
    role: "dispatcher",
    parentAdminUid: callerUid,
  });

  const now = FieldValue.serverTimestamp();

  await db.collection("users").doc(userRecord.uid).set(
    {
      role: "dispatcher",
      parentAdminUid: callerUid,
      email,
      displayName: displayName || null,
      active: true,
      createdAt: now,
      updatedAt: now,
    },
    {merge: true},
  );

  await db
    .collection("users")
    .doc(callerUid)
    .collection("sub_accounts")
    .doc(userRecord.uid)
    .set({
      email,
      displayName: displayName || null,
      active: true,
      permissions: DISPATCHER_DEFAULT_PERMISSIONS,
      createdAt: now,
      updatedAt: now,
    });

  logger.info(
    `createDispatcherAccount: ${userRecord.uid} for admin ${callerUid}`,
  );
  return {uid: userRecord.uid};
});

export const updateDispatcherAccount = onCall(async (request) => {
  const callerUid = requireAuthUid(request.auth);
  await requireAdminRole(callerUid);

  const data = (request.data || {}) as UpdateDispatcherAccountData;
  const dispatcherUid = (data.dispatcherUid || "").trim();
  if (!dispatcherUid) {
    throw new HttpsError("invalid-argument", "dispatcherUid is required.");
  }

  // Confirm this dispatcher actually belongs to the calling admin.
  const subRef = db
    .collection("users")
    .doc(callerUid)
    .collection("sub_accounts")
    .doc(dispatcherUid);
  const subSnap = await subRef.get();
  if (!subSnap.exists) {
    throw new HttpsError(
      "not-found",
      "Dispatcher gehört nicht zu diesem Admin-Account.",
    );
  }

  const newEmailRaw = (data.email || "").toString().trim().toLowerCase();
  const newPassword = (data.password || "").toString();
  const newDisplayName = (data.displayName || "").toString().trim();
  const newActive = data.active;
  const newPermissionsRaw = data.permissions;

  // Update Firebase Auth user (if email/password/displayName supplied).
  const authPatch: Record<string, unknown> = {};
  if (newEmailRaw) authPatch.email = newEmailRaw;
  if (newPassword) {
    if (newPassword.length < 6) {
      throw new HttpsError(
        "invalid-argument",
        "Passwort muss mindestens 6 Zeichen haben.",
      );
    }
    authPatch.password = newPassword;
  }
  if (newDisplayName) authPatch.displayName = newDisplayName;
  if (Object.keys(authPatch).length > 0) {
    try {
      await auth.updateUser(dispatcherUid, authPatch);
    } catch (err) {
      const e = (typeof err === "object" && err !== null ? err : {}) as AuthLikeError;
      throw new HttpsError(
        "internal",
        `Update fehlgeschlagen: ${e.message || String(err)}`,
      );
    }
  }

  // Update top-level user doc.
  const userPatch: Record<string, unknown> = {
    updatedAt: FieldValue.serverTimestamp(),
  };
  if (newEmailRaw) userPatch.email = newEmailRaw;
  if (newDisplayName) userPatch.displayName = newDisplayName;
  if (typeof newActive === "boolean") userPatch.active = newActive;
  await db.collection("users").doc(dispatcherUid).set(userPatch, {merge: true});

  // Update sub-account doc.
  const subPatch: Record<string, unknown> = {
    updatedAt: FieldValue.serverTimestamp(),
  };
  if (newEmailRaw) subPatch.email = newEmailRaw;
  if (newDisplayName) subPatch.displayName = newDisplayName;
  if (typeof newActive === "boolean") subPatch.active = newActive;
  if (newPermissionsRaw !== undefined) {
    subPatch.permissions = sanitizePermissions(newPermissionsRaw);
  }
  await subRef.set(subPatch, {merge: true});

  if (typeof newActive === "boolean") {
    // Disabling the auth user also locks them out immediately.
    try {
      await auth.updateUser(dispatcherUid, {disabled: !newActive});
    } catch (err) {
      logger.warn(
        `updateDispatcherAccount: failed to set disabled flag uid=${dispatcherUid}`,
        err,
      );
    }
  }

  logger.info(
    `updateDispatcherAccount: ${dispatcherUid} by admin ${callerUid}`,
  );
  return {ok: true};
});

export const deleteDispatcherAccount = onCall(async (request) => {
  const callerUid = requireAuthUid(request.auth);
  await requireAdminRole(callerUid);

  const data = (request.data || {}) as DeleteDispatcherAccountData;
  const dispatcherUid = (data.dispatcherUid || "").trim();
  if (!dispatcherUid) {
    throw new HttpsError("invalid-argument", "dispatcherUid is required.");
  }

  const subRef = db
    .collection("users")
    .doc(callerUid)
    .collection("sub_accounts")
    .doc(dispatcherUid);
  const subSnap = await subRef.get();
  if (!subSnap.exists) {
    throw new HttpsError(
      "not-found",
      "Dispatcher gehört nicht zu diesem Admin-Account.",
    );
  }

  let authDeleted = false;
  try {
    await auth.deleteUser(dispatcherUid);
    authDeleted = true;
  } catch (err) {
    logger.warn(
      `deleteDispatcherAccount: auth delete failed uid=${dispatcherUid}`,
      err,
    );
  }

  try {
    await db.collection("users").doc(dispatcherUid).delete();
  } catch (err) {
    logger.warn(
      `deleteDispatcherAccount: user doc delete failed uid=${dispatcherUid}`,
      err,
    );
  }

  await subRef.delete();

  logger.info(
    `deleteDispatcherAccount: ${dispatcherUid} by admin ${callerUid} (authDeleted=${authDeleted})`,
  );
  return {ok: true, authDeleted};
});
