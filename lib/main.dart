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

  try {
    await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') {
      rethrow;
    }
  }

  FirebaseMessaging.onBackgroundMessage(
    _firebaseMessagingBackgroundHandler,
  );

  await NotificationService.initialize();

  FirebaseMessaging.onMessage.listen(
    (RemoteMessage message) {

      final title =
          message.notification?.title ??
          'Notification';

      final body =
          message.notification?.body ?? '';

      debugPrint(
        'Foreground notification received',
      );

      debugPrint(
        'Title: $title',
      );

      debugPrint(
        'Body: $body',
      );

      messengerKey.currentState?.showSnackBar(
  SnackBar(
    elevation: 0,
    backgroundColor: Colors.transparent,
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.fromLTRB(
      16,
      10,
      16,
      0,
    ),
    duration: const Duration(
      seconds: 4,
    ),
    content: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF7C3AED),
            Color(0xFF9333EA),
            Color(0xFFEC4899),
          ],
        ),
        borderRadius:
            BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(
              0xFF7C3AED,
            ).withOpacity(.30),
            blurRadius: 25,
            offset: const Offset(
              0,
              10,
            ),
          ),
        ],
      ),
      child: Row(
        children: [

          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: Colors.white
                  .withOpacity(.15),
              borderRadius:
                  BorderRadius.circular(
                16,
              ),
            ),
            child: const Icon(
              Icons
                  .notifications_active_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),

          const SizedBox(
            width: 14,
          ),

          Expanded(
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                Text(
                  title,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      const TextStyle(
                    color: Colors.white,
                    fontWeight:
                        FontWeight.w800,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  body,
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white
                        .withOpacity(.95),
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            width: 8,
          ),

          const Icon(
            Icons.chevron_right_rounded,
            color: Colors.white,
          ),
        ],
      ),
    ),
  ),
);
    },
  );

  FirebaseMessaging.onMessageOpenedApp
      .listen(
    (RemoteMessage message) {
      debugPrint(
        'Notification clicked',
      );

      debugPrint(
        'Notification data: ${message.data}',
      );
    },
  );

  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey:
          messengerKey,
      title: 'MyTennat',
      debugShowCheckedModeBanner:
          false,
      theme: ThemeData(
        primarySwatch:
            Colors.blue,
      ),
      home:
          FirebaseAuth.instance.currentUser !=
                  null
              ? const HomePage()
              : const LoginScreen(),
    );
  }
}