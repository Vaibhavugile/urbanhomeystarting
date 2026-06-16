import axios from "axios";
import * as admin from "firebase-admin";
import {onCall, HttpsError} from "firebase-functions/v2/https";
import {defineSecret} from "firebase-functions/params";

const MSG91_AUTH_KEY =
  defineSecret("MSG91_AUTH_KEY");

admin.initializeApp();

export const sendOtp = onCall(
  {
    secrets: [MSG91_AUTH_KEY],
  },
  async (request) => {
    const phoneNumber =
      request.data.phoneNumber;

    if (!phoneNumber) {
      throw new HttpsError(
        "invalid-argument",
        "Phone number required"
      );
    }

    const otp =
      Math.floor(
        100000 + Math.random() * 900000
      ).toString();

    await admin
      .firestore()
      .collection("otp_verifications")
      .doc(phoneNumber)
      .set({
        otp,
        createdAt:
          admin.firestore.FieldValue.serverTimestamp(),
        expiresAt:
          Date.now() + 180000,
        verified: false,
      });

    await axios.post(
      "https://api.msg91.com/api/v5/whatsapp/whatsapp-outbound-message/bulk/",
      {
        integrated_number:
          "919096457700",
        content_type: "template",
        payload: {
          messaging_product:
            "whatsapp",
          type: "template",
          template: {
            name: "otp_login",
            language: {
              code: "en",
              policy:
                "deterministic",
            },
            namespace:
              "4ffa31a1_ffeb_487b_9817_7ab865d7addf",
            to_and_components: [
              {
                to: [phoneNumber],
                components: {
                  body_1: {
                    type: "text",
                    value: otp,
                  },
                  button_1: {
                    subtype: "url",
                    type: "text",
                    value: otp,
                  },
                },
              },
            ],
          },
        },
      },
      {
        headers: {
          "authkey":
            MSG91_AUTH_KEY.value(),
          "Content-Type":
            "application/json",
        },
      }
    );

    return {
      success: true,
    };
  }
);
export const verifyOtp = onCall(
  async (request) => {
    const phoneNumber =
      request.data.phoneNumber;

    const otp =
      request.data.otp;

    if (!phoneNumber || !otp) {
      throw new HttpsError(
        "invalid-argument",
        "Phone number and OTP required"
      );
    }

    const doc = await admin
      .firestore()
      .collection("otp_verifications")
      .doc(phoneNumber)
      .get();

    if (!doc.exists) {
      throw new HttpsError(
        "not-found",
        "OTP not found"
      );
    }

    const data = doc.data();

    if (!data) {
      throw new HttpsError(
        "not-found",
        "OTP data missing"
      );
    }

    if (Date.now() > data.expiresAt) {
      throw new HttpsError(
        "deadline-exceeded",
        "OTP expired"
      );
    }

    if (data.otp !== otp) {
      throw new HttpsError(
        "permission-denied",
        "Invalid OTP"
      );
    }

    await doc.ref.update({
      verified: true,
      verifiedAt:
        admin.firestore.FieldValue.serverTimestamp(),
    });

    const uid =
      "phone_" +
      phoneNumber.replace(
        /[^0-9]/g,
        ""
      );

    const token =
      await admin
        .auth()
        .createCustomToken(uid);

    return {
      success: true,
      uid,
      token,
    };
  }
);

