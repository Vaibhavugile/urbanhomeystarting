import {onCall, HttpsError} from "firebase-functions/v2/https";
import {createHmac} from "crypto";
import {RAZORPAY_KEY_SECRET} from "./razorpay";

export const verifyRazorpayPayment = onCall(
  {
    secrets: [RAZORPAY_KEY_SECRET],
  },
  async (request) => {
    const data = request.data;

    const razorpayOrderId = data.razorpay_order_id;
    const razorpayPaymentId = data.razorpay_payment_id;
    const razorpaySignature = data.razorpay_signature;

    if (
      !razorpayOrderId ||
      !razorpayPaymentId ||
      !razorpaySignature
    ) {
      throw new HttpsError(
        "invalid-argument",
        "Missing payment information."
      );
    }

    const generatedSignature = createHmac(
      "sha256",
      RAZORPAY_KEY_SECRET.value()
    )
      .update(`${razorpayOrderId}|${razorpayPaymentId}`)
      .digest("hex");

    const isValid = generatedSignature === razorpaySignature;

    return {
      success: isValid,
    };
  }
);
