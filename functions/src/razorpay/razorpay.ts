import Razorpay from "razorpay";
import {defineSecret} from "firebase-functions/params";

export const RAZORPAY_KEY_ID =
  defineSecret("RAZORPAY_KEY_ID");

export const RAZORPAY_KEY_SECRET =
  defineSecret("RAZORPAY_KEY_SECRET");

/**
 * Creates a Razorpay client using Firebase Secret Manager credentials.
 * @return {Razorpay} Configured Razorpay client.
 */
export function getRazorpay(): Razorpay {
  return new Razorpay({
    key_id: RAZORPAY_KEY_ID.value(),
    key_secret: RAZORPAY_KEY_SECRET.value(),
  });
}
