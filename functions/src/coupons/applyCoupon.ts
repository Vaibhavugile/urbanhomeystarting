import * as admin from "firebase-admin";

import {
  onCall,
  HttpsError,
} from "firebase-functions/v2/https";

export const applyCoupon = onCall(

  async (request) => {
    /* ==========================================
        AUTH
    ========================================== */

    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "Please login first."
      );
    }

    const uid =
      request.auth.uid;

    /* ==========================================
        REQUEST
    ========================================== */

    const couponCode =
      String(
        request.data?.couponCode ?? ""
      )
        .trim()
        .toUpperCase();

    if (!couponCode) {
      throw new HttpsError(
        "invalid-argument",
        "Coupon code is required."
      );
    }

    const appVersion =
      request.data?.appVersion ?
        String(request.data.appVersion) :
        null;

    /* ==========================================
        FIRESTORE
    ========================================== */

    const db =
      admin.firestore();

    const userRef =
      db
        .collection("users")
        .doc(uid);

    const couponRef =
      db
        .collection("couponCodes")
        .doc(couponCode);

    /* ==========================================
        LOAD DOCUMENTS
    ========================================== */

    const [

      userSnap,

      couponSnap,

    ] = await Promise.all([

      userRef.get(),

      couponRef.get(),

    ]);

    if (!userSnap.exists) {
      throw new HttpsError(
        "not-found",
        "User not found."
      );
    }

    if (!couponSnap.exists) {
      throw new HttpsError(
        "not-found",
        "Coupon not found."
      );
    }

    const user =
  userSnap.data();

    if (!user) {
      throw new HttpsError(
        "not-found",
        "User not found."
      );
    }

    const coupon =
  couponSnap.data();

    if (!coupon) {
      throw new HttpsError(
        "not-found",
        "Coupon not found."
      );
    }

    /* ==========================================
        BASIC COUPON VALIDATION
    ========================================== */

    if (
      coupon.active !== true
    ) {
      throw new HttpsError(
        "failed-precondition",
        "This coupon is inactive."
      );
    }

    if (
      coupon.status !== "active"
    ) {
      throw new HttpsError(
        "failed-precondition",
        "This coupon is unavailable."
      );
    }

    const now =
      admin.firestore.Timestamp.now();

    if (

      coupon.startDate &&

      coupon.startDate.seconds >
      now.seconds

    ) {
      throw new HttpsError(

        "failed-precondition",

        "This coupon has not started yet."

      );
    }

    if (

      coupon.expiryDate &&

      coupon.expiryDate.seconds <
      now.seconds

    ) {
      throw new HttpsError(

        "failed-precondition",

        "This coupon has expired."

      );
    }

    if (

      Number(
        coupon.rewardValue ?? 0
      ) <= 0

    ) {
      throw new HttpsError(

        "failed-precondition",

        "Invalid coupon reward."

      );
    }

    if (

      Number(
        coupon.remainingUses ?? 0
      ) <= 0

    ) {
      throw new HttpsError(

        "failed-precondition",

        "Coupon has no remaining uses."

      );
    }

    if (

      Number(
        coupon.maxUses ?? 0
      ) <= 0

    ) {
      throw new HttpsError(

        "failed-precondition",

        "Invalid coupon configuration."

      );
    }

    /* ==========================================
        USER VALIDATION
    ========================================== */

    if (

      coupon.onlyNewUsers === true &&

      user.welcomeContactsGranted === true

    ) {
      throw new HttpsError(

        "failed-precondition",

        "This coupon is only for new users."

      );
    }

    if (

      coupon.allowExistingUsers === false &&

      user.welcomeContactsGranted === true

    ) {
      throw new HttpsError(

        "failed-precondition",

        "Existing users cannot use this coupon."

      );
    }

    if (

      coupon.allowReferralUsers === false &&

      user.referredBy

    ) {
      throw new HttpsError(

        "failed-precondition",

        "Referral users cannot use this coupon."

      );
    }

    if (

      coupon.minimumAppVersion &&

      appVersion &&

      appVersion !== coupon.minimumAppVersion

    ) {
      throw new HttpsError(

        "failed-precondition",

        `Please update the app to version ${coupon.minimumAppVersion}.`

      );
    }

    /* ==========================================
        PART 2 STARTS HERE
    ========================================== */
    /* ==========================================
    FIRESTORE TRANSACTION
========================================== */

    const result =
  await db.runTransaction(

    async (transaction) => {
      /* ---------------------------------------
          RELOAD DOCUMENTS
      --------------------------------------- */

      const [

        freshUser,

        freshCoupon,

      ] = await Promise.all([

        transaction.get(userRef),

        transaction.get(couponRef),

      ]);

      if (!freshUser.exists) {
        throw new HttpsError(
          "not-found",
          "User not found."
        );
      }

      if (!freshCoupon.exists) {
        throw new HttpsError(
          "not-found",
          "Coupon not found."
        );
      }

      const userData =
  freshUser.data();

      if (!userData) {
        throw new HttpsError(
          "not-found",
          "User not found."
        );
      }

      const couponData =
  freshCoupon.data();

      if (!couponData) {
        throw new HttpsError(
          "not-found",
          "Coupon not found."
        );
      }
      /* ---------------------------------------
          FINAL COUPON VALIDATION
      --------------------------------------- */

      if (
        couponData.active !== true
      ) {
        throw new HttpsError(
          "failed-precondition",
          "Coupon is inactive."
        );
      }

      if (
        couponData.status !== "active"
      ) {
        throw new HttpsError(
          "failed-precondition",
          "Coupon unavailable."
        );
      }

      const transactionNow =
        admin.firestore.Timestamp.now();

      if (

        couponData.startDate &&

        couponData.startDate.seconds >
        transactionNow.seconds

      ) {
        throw new HttpsError(
          "failed-precondition",
          "Coupon has not started."
        );
      }

      if (

        couponData.expiryDate &&

        couponData.expiryDate.seconds <
        transactionNow.seconds

      ) {
        throw new HttpsError(
          "failed-precondition",
          "Coupon expired."
        );
      }

      if (

        Number(
          couponData.remainingUses ?? 0
        ) <= 0

      ) {
        throw new HttpsError(
          "failed-precondition",
          "Coupon exhausted."
        );
      }

      /* ---------------------------------------
          RECHECK USER
      --------------------------------------- */

      if (

        couponData.onlyNewUsers === true &&

        userData.welcomeContactsGranted === true

      ) {
        throw new HttpsError(
          "failed-precondition",
          "Only new users can use this coupon."
        );
      }

      if (

        couponData.allowExistingUsers === false &&

        userData.welcomeContactsGranted === true

      ) {
        throw new HttpsError(
          "failed-precondition",
          "Existing users are not allowed."
        );
      }

      if (

        couponData.allowReferralUsers === false &&

        userData.referredBy

      ) {
        throw new HttpsError(
          "failed-precondition",
          "Referral users cannot redeem this coupon."
        );
      }

      /* ---------------------------------------
          REDEMPTION HISTORY
      --------------------------------------- */

      const redemptionSnapshot =
        await userRef
          .collection("redeemedCoupons")
          .where(
            "couponCode",
            "==",
            couponCode
          )
          .get();

      const previousUses =
        redemptionSnapshot.size;

      const userLimit =
        Number(
          couponData.userLimit ?? 1
        );

      if (
        previousUses >= userLimit
      ) {
        throw new HttpsError(

          "failed-precondition",

          `Coupon already redeemed ${userLimit} time(s).`

        );
      }

      const cooldownDays =
        Number(
          couponData.cooldownDays ?? 0
        );

      if (

        cooldownDays > 0 &&

        redemptionSnapshot.docs.length > 0

      ) {
        const latest =
          redemptionSnapshot.docs
            .sort((a, b) => {
              return (

                b.data()
                  .redeemedAt
                  .seconds -

                a.data()
                  .redeemedAt
                  .seconds

              );
            })[0];

        const redeemedAt =
          latest.data()
            .redeemedAt
            .toDate();

        const nextAllowed =
          new Date(redeemedAt);

        nextAllowed.setDate(
          nextAllowed.getDate() +
          cooldownDays
        );

        if (
          new Date() < nextAllowed
        ) {
          throw new HttpsError(

            "failed-precondition",

            `Try again after ${nextAllowed.toLocaleDateString()}.`

          );
        }
      }

      /* ==========================================
          PART 2B STARTS HERE
      ========================================== */
      /* ---------------------------------------
          REWARD
      --------------------------------------- */

      const reward =
        Number(
          couponData.rewardValue
        );

      const currentContacts =
        Number(
          userData.remainingContacts ?? 0
        );

      const newRemainingContacts =
        currentContacts + reward;

      /* ---------------------------------------
          UPDATE USER
      --------------------------------------- */

      transaction.update(

        userRef,

        {

          remainingContacts:
            newRemainingContacts,

          updatedAt:
            admin.firestore.FieldValue.serverTimestamp(),

        }

      );

      /* ---------------------------------------
          UPDATE COUPON
      --------------------------------------- */

      transaction.update(

        couponRef,

        {

          usedCount:
            admin.firestore.FieldValue.increment(
              1
            ),

          remainingUses:
            admin.firestore.FieldValue.increment(
              -1
            ),

          totalRewardGiven:
            admin.firestore.FieldValue.increment(
              reward
            ),

          updatedAt:
            admin.firestore.FieldValue.serverTimestamp(),

        }

      );

      /* ---------------------------------------
          SAVE HISTORY
      --------------------------------------- */

      const redemptionRef =
        userRef
          .collection(
            "redeemedCoupons"
          )
          .doc();

      const redeemedAt =
        admin.firestore.Timestamp.now();

      let cooldownUntil =
        null;

      if (

        cooldownDays > 0

      ) {
        cooldownUntil =
          admin.firestore.Timestamp.fromDate(

            new Date(

              Date.now() +

              cooldownDays *

              24 *

              60 *

              60 *

              1000

            )

          );
      }

      transaction.set(

        redemptionRef,

        {

          couponCode,

          couponTitle:
            couponData.title,

          rewardType:
            couponData.rewardType,

          rewardValue:
            reward,

          redeemedAt,

          cooldownUntil,

          redemptionNumber:
            previousUses + 1,

          userUid:
            uid,

          remainingContactsBefore:
            currentContacts,

          remainingContactsAfter:
            newRemainingContacts,

        }

      );

      return {

        reward,

        remainingContacts:
          newRemainingContacts,

      };
    }

  );

    /* ==========================================
      SUCCESS
  ========================================== */

    return {

      success: true,

      message:
      `Coupon applied successfully. You received ${result.reward} contacts.`,

      couponCode,

      rewardType:
      "contacts",

      rewardValue:
      result.reward,

      remainingContacts:
      result.remainingContacts,

    };
  }

);
