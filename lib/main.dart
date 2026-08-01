import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/home_page.dart';
import 'services/notification_service.dart';
import 'screens/startup_screen.dart';
final GlobalKey<ScaffoldMessengerState>
    messengerKey =
        GlobalKey<ScaffoldMessengerState>();

Future<void> _firebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);

  debugPrint(
    'Background Message: ${message.messageId}',
  );

  debugPrint(
    'Title: ${message.notification?.title}',
  );

  debugPrint(
    'Body: ${message.notification?.body}',
  );
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    debugPrint("========== APP START ==========");

    debugPrint("STEP 1 - Initializing Firebase");

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    debugPrint("STEP 2 - Firebase Initialized");

    FirebaseMessaging.onBackgroundMessage(
      _firebaseMessagingBackgroundHandler,
    );

    debugPrint("STEP 3 - Background Handler Registered");

    // ❌ DO NOT initialize notifications here
    // await NotificationService.initialize();

    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) {
        final title =
            message.notification?.title ??
                "Notification";

        final body =
            message.notification?.body ?? "";

        debugPrint(
          "Foreground notification received",
        );

        debugPrint(
          "Title: $title",
        );

        debugPrint(
          "Body: $body",
        );

        messengerKey.currentState?.showSnackBar(
          SnackBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            behavior:
                SnackBarBehavior.floating,
            margin: const EdgeInsets.fromLTRB(
              16,
              10,
              16,
              0,
            ),
            duration:
                const Duration(seconds: 4),
            content: Text(
              "$title\n$body",
            ),
          ),
        );
      },
    );

    FirebaseMessaging.onMessageOpenedApp
        .listen(
      (RemoteMessage message) {
        debugPrint(
          "Notification clicked",
        );

        debugPrint(
          message.data.toString(),
        );
      },
    );

    debugPrint("STEP 4 - runApp");

    runApp(
      const MyApp(),
    );

    debugPrint("STEP 5 - App Running");
  } catch (e, stackTrace) {
    debugPrint(
      "========== MAIN ERROR ==========",
    );

    debugPrint(
      e.toString(),
    );

    debugPrintStack(
      stackTrace: stackTrace,
    );

    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
            title: const Text(
              "Startup Error",
            ),
          ),
          body: Padding(
            padding:
                const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: SelectableText(
                "$e\n\n$stackTrace",
                style: const TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser =
        FirebaseAuth.instance.currentUser;

    debugPrint(
      "========== BUILDING MYAPP ==========",
    );

    debugPrint(
      "Current User UID: ${currentUser?.uid}",
    );

    debugPrint(
      "Current User Phone: ${currentUser?.phoneNumber}",
    );

    debugPrint(
      "Is Logged In: ${currentUser != null}",
    );

    ErrorWidget.builder =
        (FlutterErrorDetails details) {
      return Material(
        color: Colors.white,
        child: SafeArea(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.all(20),
            child: SelectableText(
              details.exceptionAsString(),
              style: const TextStyle(
                color: Colors.red,
                fontSize: 14,
              ),
            ),
          ),
        ),
      );
    };

    return MaterialApp(
      scaffoldMessengerKey: messengerKey,
      title: "MyTennat",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),

      home: currentUser != null
    ? const StartupScreen()
    : const LoginScreen(),
    );
  }
}