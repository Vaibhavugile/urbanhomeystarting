import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/redeemed_coupon_model.dart';
class CouponService {
  static final FirebaseFunctions _functions =
      FirebaseFunctions.instance;

  /* ==========================================
      APPLY COUPON
  ========================================== */

  static Future<Map<String, dynamic>> applyCoupon(
    String couponCode,
  ) async {
    try {
      final callable =
          _functions.httpsCallable(
        "applyCoupon",
      );

      final result =
          await callable.call({
        "couponCode": couponCode
            .trim()
            .toUpperCase(),
      });

      return Map<String, dynamic>.from(
        result.data,
      );
    } on FirebaseFunctionsException catch (e) {
      throw Exception(
        _friendlyMessage(e),
      );
    } catch (_) {
      throw Exception(
        "Unable to apply coupon. Please try again.",
      );
    }
  }

  /* ==========================================
      FRIENDLY ERROR
  ========================================== */
/* ==========================================
    GET REDEEMED COUPONS
========================================== */

static Stream<List<RedeemedCouponModel>>
    redeemedCoupons(
  String uid,
) {
  return FirebaseFirestore.instance
      .collection("users")
      .doc(uid)
      .collection("redeemedCoupons")
      .orderBy(
        "redeemedAt",
        descending: true,
      )
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map(
              RedeemedCouponModel
                  .fromFirestore,
            )
            .toList(),
      );
}
  static String _friendlyMessage(
    FirebaseFunctionsException e,
  ) {
    final message =
        e.message ?? "";

    switch (e.code) {
      case "not-found":
        return "Invalid coupon code.";

      case "unauthenticated":
        return "Please login first.";

      case "invalid-argument":
        return message;

      case "failed-precondition":
        return message;

      case "permission-denied":
        return "Permission denied.";

      case "internal":
        return "Something went wrong.";

      default:
        return message.isNotEmpty
            ? message
            : "Unable to apply coupon.";
    }
  }

}