import * as admin from "firebase-admin";
import {onDocumentCreated} from "firebase-functions/v2/firestore";

export const notifyAdminsNewUser = onDocumentCreated(
  "users/{userId}",
  async (event) => {
    try {
      const snapshot = event.data;

      if (!snapshot) return;

      const user = snapshot.data();

      const admins = await admin
        .firestore()
        .collection("adminUsers")
        .get();

      const tokens: string[] = [];

      admins.forEach((doc) => {
        const token = doc.data().fcmToken;

        if (token) {
          tokens.push(token);
        }
      });

      if (tokens.length === 0) {
        console.log("No Admin Tokens");
        return;
      }

      await admin.messaging().sendEachForMulticast({
        tokens,

        notification: {
          title: "🎉 New User Registered",
          body:
            `${user.firstName ?? ""} ${user.lastName ?? ""}
             has joined UrbanHomey.`,
        },

        data: {
          type: "new_user",
          userId: event.params.userId,
        },

        android: {
          priority: "high",
        },
      });

      console.log("Notification Sent");
    } catch (e) {
      console.error(e);
    }
  }
);
