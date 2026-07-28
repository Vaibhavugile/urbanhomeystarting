import axios from "axios";
import * as admin from "firebase-admin";
import {onCall, HttpsError} from "firebase-functions/v2/https";
import {defineSecret} from "firebase-functions/params";
import {
  applyCoupon,
} from "./coupons/applyCoupon";

export {
  applyCoupon,
};
const MSG91_AUTH_KEY = defineSecret("MSG91_AUTH_KEY");

admin.initializeApp();

export const sendOtp = onCall(
  {
    secrets: [MSG91_AUTH_KEY],
  },
  async (request) => {
    try {
      console.log("========== SEND OTP ==========");

      const phoneNumber = request.data.phoneNumber;

      console.log("Phone:", phoneNumber);

      if (!phoneNumber) {
        throw new HttpsError(
          "invalid-argument",
          "Phone number required"
        );
      }

      // Generate OTP
      const otp = Math.floor(
        100000 + Math.random() * 900000
      ).toString();

      console.log("Generated OTP:", otp);

      // Save OTP
      await admin
        .firestore()
        .collection("otp_verifications")
        .doc(phoneNumber)
        .set({
          otp,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          expiresAt: Date.now() + 3 * 60 * 1000,
          verified: false,
        });

      console.log("OTP saved to Firestore");

      const payload = {
        integrated_number: "918793744117",
        content_type: "template",
        payload: {
          messaging_product: "whatsapp",
          type: "template",
          template: {
            name: "otppp_login",
            language: {
              code: "en",
              policy: "deterministic",
            },
            namespace: "966353f8_de57_41d3_b22b_286d3ad61238",
            to_and_components: [
              {
                to: [phoneNumber],
                components: {
                  body_1: {
                    type: "text",
                    value: otp,
                  },
                  button_1: {
                    type: "text",
                    subtype: "url",
                    value: otp,
                  },
                },
              },
            ],
          },
        },
      };

      console.log(
        "Sending Payload:",
        JSON.stringify(payload, null, 2)
      );

      const response = await axios.post(
        "https://api.msg91.com/api/v5/whatsapp/whatsapp-outbound-message/bulk/",
        payload,
        {
          headers: {
            "authkey": MSG91_AUTH_KEY.value(),
            "Content-Type": "application/json",
          },
        }
      );

      console.log(
        "MSG91 Response:",
        JSON.stringify(response.data, null, 2)
      );

      return {
        success: true,
        message: "OTP sent successfully",
      };
    } catch (error: unknown) {
      const err = error as {
        message?: string;
        response?: {
          data?: {
            message?: string;
            [key: string]: unknown;
          };
        };
      };

      console.error("========== SEND OTP ERROR ==========");
      console.error(
        JSON.stringify(err.response?.data ?? err, null, 2)
      );

      throw new HttpsError(
        "internal",
        err.response?.data?.message ??
          err.message ??
          "Failed to send OTP"
      );
    }
  }
);
