import {onDocumentWritten} from "firebase-functions/v2/firestore";

export const forceTestOtp = onDocumentWritten(
  "otp_verifications/{phoneNumber}",
  async (event) => {
    try {
      const phoneNumber =
        event.params.phoneNumber;

      console.log(
        "================================="
      );
      console.log(
        "OTP DOC WRITTEN"
      );
      console.log(
        "PHONE:",
        phoneNumber
      );

      // Only test numbers
      if (
        !phoneNumber.startsWith(
          "+9199999999"
        )
      ) {
        console.log(
          "NOT TEST USER"
        );
        return;
      }

      const afterSnapshot =
        event.data?.after;

      if (!afterSnapshot) {
        console.log(
          "NO SNAPSHOT FOUND"
        );
        return;
      }

      const afterData =
        afterSnapshot.data();

      if (!afterData) {
        console.log(
          "NO DATA FOUND"
        );
        return;
      }

      console.log(
        "CURRENT OTP:",
        afterData.otp
      );

      if (
        afterData.otp ===
        "123456"
      ) {
        console.log(
          "OTP ALREADY 123456"
        );
        return;
      }

      await afterSnapshot.ref.update({
        otp: "123456",
      });

      console.log(
        "OTP UPDATED TO 123456"
      );

      console.log(
        "================================="
      );
    } catch (error) {
      console.error(
        "FORCE OTP ERROR:",
        error
      );
    }
  }
);

