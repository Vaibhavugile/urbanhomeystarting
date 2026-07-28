import 'package:cloud_firestore/cloud_firestore.dart';

class CouponModel {
  final String code;

  final String title;

  final String description;

  final String rewardType;

  final int rewardValue;

  final bool active;

  final DateTime? startDate;

  final DateTime? expiryDate;

  CouponModel({
    required this.code,
    required this.title,
    required this.description,
    required this.rewardType,
    required this.rewardValue,
    required this.active,
    required this.startDate,
    required this.expiryDate,
  });

  factory CouponModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return CouponModel(
      code: map["code"] ?? "",

      title: map["title"] ?? "",

      description:
          map["description"] ?? "",

      rewardType:
          map["rewardType"] ?? "contacts",

      rewardValue:
          (map["rewardValue"] ?? 0) as int,

      active:
          map["active"] ?? false,

      startDate:
          (map["startDate"]
                  as Timestamp?)
              ?.toDate(),

      expiryDate:
          (map["expiryDate"]
                  as Timestamp?)
              ?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "code": code,
      "title": title,
      "description": description,
      "rewardType": rewardType,
      "rewardValue": rewardValue,
      "active": active,
    };
  }
}