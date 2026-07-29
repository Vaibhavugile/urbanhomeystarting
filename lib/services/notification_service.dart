import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  static Future<void> initialize() async {
    FirebaseMessaging messaging =
        FirebaseMessaging.instance;

    NotificationSettings settings =
        await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    print(
      'Notification permission: ${settings.authorizationStatus}',
    );

    await saveFcmToken();

    FirebaseMessaging.instance.onTokenRefresh
        .listen((newToken) async {

      final user =
          FirebaseAuth.instance.currentUser;

      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'fcmToken': newToken,
        'tokenUpdatedAt':
            FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print(
        'FCM token refreshed',
      );
    });
  }

  static Future<void> saveFcmToken() async {
  if (!Platform.isIOS) return;

  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final messaging = FirebaseMessaging.instance;

  Future<void> log(String title, dynamic value) async {
    await FirebaseFirestore.instance
        .collection("ios_debug")
        .add({
      "uid": user.uid,
      "title": title,
      "value": value?.toString(),
      "time": FieldValue.serverTimestamp(),
    });
  }

  try {
    await log("STEP_1", "saveFcmToken Started");

    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    await log(
      "STEP_2_PERMISSION",
      settings.authorizationStatus.name,
    );

    await log(
      "ALERT",
      settings.alert.name,
    );

    await log(
      "BADGE",
      settings.badge.name,
    );

    await log(
      "SOUND",
      settings.sound.name,
    );

    await messaging.setAutoInitEnabled(true);

    await log(
      "STEP_3",
      "Auto Init Enabled",
    );

    for (int i = 1; i <= 20; i++) {
      final apns = await messaging.getAPNSToken();

      await log(
        "APNS_ATTEMPT_$i",
        apns,
      );

      if (apns != null) {
        break;
      }

      await Future.delayed(
        const Duration(seconds: 1),
      );
    }

    final apnsToken =
        await messaging.getAPNSToken();

    await log(
      "FINAL_APNS",
      apnsToken,
    );

    String? fcmToken;

    try {
      fcmToken =
          await messaging.getToken();

      await log(
        "FCM_TOKEN",
        fcmToken,
      );
    } catch (e) {
      await log(
        "FCM_EXCEPTION",
        e.toString(),
      );
    }

    await log(
      "IOS_VERSION",
      Platform.operatingSystemVersion,
    );

    await log(
      "PLATFORM",
      Platform.operatingSystem,
    );

    if (fcmToken != null &&
        fcmToken.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .set({
        "fcmToken": fcmToken,
        "tokenUpdatedAt":
            FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await log(
        "USER_DOC",
        "FCM Saved",
      );
    } else {
      await log(
        "USER_DOC",
        "FCM NULL",
      );
    }

    await log(
      "FINISHED",
      "Completed",
    );
  } catch (e, stack) {
    await log(
      "CRASH",
      e.toString(),
    );

    await log(
      "STACKTRACE",
      stack.toString(),
    );
  }
}
}