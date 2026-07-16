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
    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final apnsToken =
    await FirebaseMessaging.instance
        .getAPNSToken();

final token =
    await FirebaseMessaging.instance
        .getToken();

await FirebaseFirestore.instance
    .collection("debug")
    .doc("ios")
    .set({

  "apnsToken": apnsToken,

  "fcmToken": token,

  "time": FieldValue.serverTimestamp(),

});

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set({
      'fcmToken': token,
      'tokenUpdatedAt':
          FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}