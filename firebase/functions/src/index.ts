// firebase/functions/src/index.ts

/* eslint-disable object-curly-spacing, max-len */

// Minimal Firebase Functions file just for driver sub-accounts + notifications

import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";

import {initializeApp} from "firebase-admin/app";
import {getFirestore, FieldValue} from "firebase-admin/firestore";
import {getAuth, UserRecord} from "firebase-admin/auth";

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
};

type DriverNotificationActionData = {
  dspUid?: string;
  transporterId?: string;
  notificationId?: string;
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
  const requiresConfirmation = !!data.requiresConfirmation;

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

  // Load drivers under this DSP
  const driversSnap = await db
    .collection("users")
    .doc(dspUid)
    .collection("drivers")
    .get();

  const drivers = driversSnap.docs;
  const targetCount = drivers.length;

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
    createdAt: FieldValue.serverTimestamp(),
    createdBy: callerUid,
    target: "all",
    targetCount,
    confirmedCount: 0,
    requiresConfirmation,
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
        status: "unread",
        createdAt: FieldValue.serverTimestamp(),
        readAt: null,
        confirmedAt: null,
        requiresConfirmation,
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
