import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mytennat/screens/home_page.dart'; // For FlatListingProfile

import 'package:mytennat/screens/initial_profile_screen.dart';
import 'package:mytennat/screens/login_screen.dart';

class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key});

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  @override
  void initState() {
    super.initState();
    _checkStartup();
  }

  Future<void> _checkStartup() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;

      debugPrint("========== STARTUP SCREEN ==========");
      debugPrint("Current User: ${user?.uid}");

      // User not logged in
      if (user == null) {
        _navigate(const LoginScreen());
        return;
      }

      // Get user document
      final DocumentSnapshot<Map<String, dynamic>> userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      final data = userDoc.data();

      // Check if initial profile exists
      final bool hasInitialProfile =
          userDoc.exists &&
          data != null &&
          (data['name']?.toString().trim().isNotEmpty ?? false) &&
          data['age'] != null &&
          (data['gender']?.toString().trim().isNotEmpty ?? false) &&
          (data['city']?.toString().trim().isNotEmpty ?? false);

      if (hasInitialProfile) {
        debugPrint("Initial profile found → HomePage");
        _navigate(const HomePage());
      } else {
        debugPrint("No initial profile → InitialProfileScreen");
        _navigate(const InitialProfileScreen());
      }
    } catch (e) {
      debugPrint("STARTUP ERROR: $e");

      _navigate(const LoginScreen());
    }
  }

  void _navigate(Widget page) {
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => page,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}