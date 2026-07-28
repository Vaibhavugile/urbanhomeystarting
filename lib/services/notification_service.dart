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

  final settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    provisional: false,
  );

  // Wait for APNs registration
  await Future.delayed(const Duration(seconds: 5));

  String? apnsToken;
  String? fcmToken;

  try {
    apnsToken = await messaging.getAPNSToken();
  } catch (e) {
    print("APNS ERROR: $e");
  }

  try {
    fcmToken = await messaging.getToken();
  } catch (e) {
    print("FCM ERROR: $e");
  }

  print("================================");
  print("Permission : ${settings.authorizationStatus}");
  print("Alert      : ${settings.alert}");
  print("Badge      : ${settings.badge}");
  print("Sound      : ${settings.sound}");
  print("APNS Token : $apnsToken");
  print("FCM Token  : $fcmToken");
  print("================================");

  await FirebaseFirestore.instance
      .collection("debug")
      .doc("ios")
      .set({
    "uid": user.uid,
    "permission": settings.authorizationStatus.name,
    "alert": settings.alert.name,
    "badge": settings.badge.name,
    "sound": settings.sound.name,
    "apnsToken": apnsToken,
    "fcmToken": fcmToken,
    "platform": Platform.operatingSystem,
    "time": FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));

  if (fcmToken != null && fcmToken.isNotEmpty) {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .set({
      "fcmToken": fcmToken,
      "tokenUpdatedAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
}