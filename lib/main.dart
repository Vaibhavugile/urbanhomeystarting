import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/home_page.dart';
import 'services/notification_service.dart';

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

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);

    debugPrint(
      "========== FLUTTER ERROR ==========",
    );

    debugPrint(
      details.exceptionAsString(),
    );

    if (details.stack != null) {
      debugPrint(
        details.stack.toString(),
      );
    }
  };

  try {
    debugPrint(
      "========== MAIN START ==========",
    );

    debugPrint(
      "STEP 1 - Initializing Firebase",
    );

    await Firebase.initializeApp(
      options:
          DefaultFirebaseOptions.currentPlatform,
    );

    debugPrint(
      "STEP 2 - Firebase initialized",
    );

    FirebaseMessaging.onBackgroundMessage(
      _firebaseMessagingBackgroundHandler,
    );

    debugPrint(
      "STEP 3 - Background handler registered",
    );

    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) {
        debugPrint(
          "Foreground notification received",
        );

        final title =
            message.notification?.title ??
                "Notification";

        final body =
            message.notification?.body ??
                "";

        messengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text(
              "$title\n$body",
            ),
          ),
        );
      },
    );

    FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage message) {
        debugPrint(
          "Notification clicked",
        );

        debugPrint(
          message.data.toString(),
        );
      },
    );

    debugPrint(
      "STEP 4 - Running App",
    );

    runApp(
      const MyApp(),
    );

    debugPrint(
      "STEP 5 - App Started",
    );
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
                const EdgeInsets.all(16),
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
    debugPrint(
      "========== BUILDING MYAPP ==========",
    );

    debugPrint(
      "Current User: ${FirebaseAuth.instance.currentUser?.uid}",
    );

    return MaterialApp(
      scaffoldMessengerKey:
          messengerKey,
      title: "MyTennat",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:
          FirebaseAuth.instance.currentUser !=
                  null
              ? const HomePage()
              : const LoginScreen(),
    );
  }
}