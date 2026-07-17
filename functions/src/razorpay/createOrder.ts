import {onCall, HttpsError} from "firebase-functions/v2/https";
import {
  getRazorpay,
  RAZORPAY_KEY_ID,
  RAZORPAY_KEY_SECRET,
} from "./razorpay";

export const createRazorpayOrder = onCall(
  {
    secrets: [RAZORPAY_KEY_ID, RAZORPAY_KEY_SECRET],
  },
  async (request) => {
    const {amount, planId, userId} = request.data;

    if (!amount || !planId || !userId) {
      throw new HttpsError(
        "invalid-argument",
        "Missing required parameters."
      );
    }

    const razorpay = getRazorpay();

    const order = await razorpay.orders.create({
      amount: Number(amount) * 100,
      currency: "INR",
      receipt: `${userId}_${Date.now()}`,
      notes: {
        userId,
        planId,
      },
    });

    return {
      success: true,
      key: RAZORPAY_KEY_ID.value(),
      orderId: order.id,
      amount: order.amount,
      currency: order.currency,
    };
  }
);
