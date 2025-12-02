/* eslint-disable object-curly-spacing, max-len */

// Minimal Firebase Functions file just for driver sub-accounts

import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";

import {initializeApp} from "firebase-admin/app";
import {getFirestore, FieldValue} from "firebase-admin/firestore";
import {getAuth} from "firebase-admin/auth";

// Initialize Admin SDK once
initializeApp();

const db = getFirestore();
const auth = getAuth();

/* ---------------------------------------------------------
   Callable: createDriverLogin

   Called from Flutter (DriversHubPage) when a DSP sets login
   credentials for a driver.

   Args (request.data):
     - dspUid: string
     - transporterId: string   // driver login ID (TID)
     - password: string

   Behaviour:
     - Only allows authenticated DSP owner (auth.uid == dspUid)
     - Looks up driver doc:
         users/{dspUid}/drivers/{TRANSPORTER_ID}
     - Creates or updates a Firebase Auth user for the driver
       (using driver's email if present, else synthetic email)
     - Sets custom claims { role: "driver", dspUid, transporterId }
     - Creates/updates top-level users/{driverUid} doc
     - Marks driver doc with hasLogin=true, authUid, loginEmail
--------------------------------------------------------- */
export const createDriverLogin = onCall(async (request) => {
  const ctx = request.auth;
  if (!ctx || !ctx.uid) {
    throw new HttpsError(
      "unauthenticated",
      "Only authenticated users can create driver logins.",
    );
  }

  const data = (request.data || {}) as {
    dspUid?: string;
    transporterId?: string;
    password?: string;
  };

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

  let userRecord;

  try {
    // If user already exists with this email → update password.
    userRecord = await auth.getUserByEmail(loginEmail);
    userRecord = await auth.updateUser(userRecord.uid, {
      password,
      displayName: driverName || undefined,
    });
    logger.info(
      `Updated existing driver user for ${loginEmail} (uid=${userRecord.uid})`,
    );
  } catch (err: any) {
    if (err && err.code === "auth/user-not-found") {
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
      throw new HttpsError(
        "internal",
        `Error while creating/updating driver auth user: ${
          err?.message || err
        }`,
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
