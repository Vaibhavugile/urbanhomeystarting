import 'package:cloud_firestore/cloud_firestore.dart';

class RedeemedCouponModel {
  final String id;

  final String couponCode;

  final String couponTitle;

  final String rewardType;

  final int rewardValue;

  final DateTime redeemedAt;

  final int remainingContactsAfter;

  RedeemedCouponModel({
    required this.id,
    required this.couponCode,
    required this.couponTitle,
    required this.rewardType,
    required this.rewardValue,
    required this.redeemedAt,
    required this.remainingContactsAfter,
  });

  factory RedeemedCouponModel.fromFirestore(
    DocumentSnapshot doc,
  ) {
    final data =
        doc.data() as Map<String, dynamic>;

    return RedeemedCouponModel(
      id: doc.id,
      couponCode: data["couponCode"] ?? "",
      couponTitle: data["couponTitle"] ?? "",
      rewardType: data["rewardType"] ?? "",
      rewardValue:
          (data["rewardValue"] ?? 0) as int,
      redeemedAt:
          (data["redeemedAt"] as Timestamp)
              .toDate(),
      remainingContactsAfter:
          (data["remainingContactsAfter"] ??
              0) as int,
    );
  }
}