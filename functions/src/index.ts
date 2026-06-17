import axios from "axios";
import * as admin from "firebase-admin";

import {
  onCall,
  HttpsError,
} from "firebase-functions/v2/https";

import {
  onDocumentCreated,
} from "firebase-functions/v2/firestore";

import {defineSecret}
  from "firebase-functions/params";

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
export const onNewMessage =
onDocumentCreated(
  "chats/{chatId}/messages/{messageId}",
  async (event) => {
    const message =
      event.data?.data();

    if (!message) {
      return;
    }

    const receiverId =
      message.receiverId;

    const senderId =
      message.senderId;

    const content =
      message.content ||
      "New Message";

    console.log(
      "New message:",
      content
    );

    const receiverDoc =
      await admin
        .firestore()
        .collection("users")
        .doc(receiverId)
        .get();

    if (!receiverDoc.exists) {
      console.log(
        "Receiver not found"
      );
      return;
    }

    const receiverData =
      receiverDoc.data();

    const fcmToken =
      receiverData?.fcmToken;

    if (!fcmToken) {
      console.log(
        "No FCM token"
      );
      return;
    }

    await admin
      .messaging()
      .send({
        token: fcmToken,

        notification: {
          title:
            "New Message",
          body: content,
        },

        data: {
          type: "chat",
          senderId:
            senderId,
        },

        android: {
          priority:
            "high",
        },
      });
    await admin
      .firestore()
      .collection("users")
      .doc(receiverId)
      .collection("notifications")
      .add({
        title: "New Message",
        body: content,
        type: "chat",
        senderId: senderId,
        chatId: event.params.chatId,
        isRead: false,
        createdAt:
        admin.firestore.FieldValue.serverTimestamp(),
      });
    console.log(
      "Push sent"
    );
  }
);

