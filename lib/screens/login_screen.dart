// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'selection_screen.dart';
import 'home_page.dart';
import 'package:flutter/foundation.dart';
import 'package:mytennat/screens/initial_profile_screen.dart'; // Import InitialProfileScreen
import 'package:mytennat/screens/complete_user_profile_screen.dart'; // Import CompleteUserProfileScreen
import 'package:cloud_functions/cloud_functions.dart';
import 'package:mytennat/services/notification_service.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isOtpSent = false;
  bool _loading = false;
  int _resendOtpTimer = 60;
  bool _canResendOtp = false;
  Timer? _timer;

  late AnimationController _animationController;
  late Animation<Offset> _slideUpAnimation;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _slideUpAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _fadeInAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    _canResendOtp = false;
    _resendOtpTimer = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendOtpTimer < 1) {
          timer.cancel();
          _canResendOtp = true;
        } else {
          _resendOtpTimer--;
        }
      });
    });
  }

Future<void> _verifyPhoneNumber() async {
  setState(() {
    _loading = true;
  });

  try {
    final callable = FirebaseFunctions.instance
        .httpsCallable('sendOtp');

    await callable.call({
      'phoneNumber':
          '+91${_phoneController.text.trim()}',
    });

    setState(() {
      _isOtpSent = true;
      _loading = false;
    });

    _startResendTimer();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'OTP sent on WhatsApp',
        ),
      ),
    );
  } catch (e) {
    setState(() {
      _loading = false;
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          'Failed to send OTP: $e',
        ),
      ),
    );
  }
}

Future<void> _verifyOtpAndSignIn() async {
  setState(() {
    _loading = true;
  });

  try {
    final callable =
        FirebaseFunctions.instance
            .httpsCallable(
      'verifyOtp',
    );

    final result =
        await callable.call({
      'phoneNumber':
          '+91${_phoneController.text.trim()}',
      'otp':
          _otpController.text.trim(),
    });

    final token =
        result.data['token'];

    await FirebaseAuth.instance
        .signInWithCustomToken(
      token,
    );

    debugPrint(
      'Custom token login successful',
    );
    await NotificationService.initialize();

    await _createOrUpdateUser();

    _navigateToNextScreen();
  } catch (e) {
    setState(() {
      _loading = false;
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          'Invalid OTP: $e',
        ),
      ),
    );
  }
}
Future<void> _createOrUpdateUser() async {
  final user =
      FirebaseAuth.instance.currentUser;

  if (user == null) return;

  await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .set({
    'uid': user.uid,
    'phoneNumber':
        '+91${_phoneController.text.trim()}',
    'lastLogin':
        FieldValue.serverTimestamp(),
    'createdAt':
        FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));
}
 Future<void> _navigateToNextScreen() async {
  setState(() {
    _loading = false;
  });

  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    debugPrint(
      'Authentication failed: No current user after sign-in attempt.',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Authentication failed. Please try again.',
        ),
      ),
    );

    return;
  }

  final userDocRef = FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid);

  final userProfileSnapshot =
      await userDocRef.get();

  final userData =
      userProfileSnapshot.data();

  // Phone number now comes from Firestore
  final String? userPhoneNumber =
      userData?['phoneNumber'];

  debugPrint(
    'Authenticated user phone number: $userPhoneNumber',
  );

  final flatListingsSnapshot =
      await userDocRef
          .collection('flatListings')
          .limit(1)
          .get();

  final bool hasFlatListingProfile =
      flatListingsSnapshot.docs.isNotEmpty;

  final seekingFlatmateProfilesSnapshot =
      await userDocRef
          .collection('seekingFlatmateProfiles')
          .limit(1)
          .get();

  final bool hasSeekingFlatmateProfile =
      seekingFlatmateProfilesSnapshot
          .docs
          .isNotEmpty;

  if (userProfileSnapshot.exists &&
      userData != null &&
      userData.containsKey('name') &&
      userData.containsKey('age') &&
      userData.containsKey('gender') &&
      userData.containsKey('city')) {

    if (userData.containsKey('occupation') &&
        userData.containsKey('religion') &&
        userData.containsKey('bio')) {

      debugPrint(
        'User has a complete profile. Navigating to HomePage.',
      );

      Navigator.of(context)
          .pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) =>
              const HomePage(),
        ),
        (Route<dynamic> route) =>
            false,
      );

      return;
    }

    debugPrint(
      'User has initial profile but not complete. Navigating to CompleteUserProfileScreen.',
    );

    Navigator.of(context)
        .pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) =>
            const CompleteUserProfileScreen(),
      ),
      (Route<dynamic> route) =>
          false,
    );

    return;
  }

  if (hasFlatListingProfile ||
      hasSeekingFlatmateProfile) {

    debugPrint(
      'User has existing flat listing or seeking flatmate profile. Navigating to HomePage.',
    );

    Navigator.of(context)
        .pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) =>
            const HomePage(),
      ),
      (Route<dynamic> route) =>
          false,
    );

    return;
  }

  debugPrint(
    'New user. No existing profiles found. Navigating to InitialProfileScreen.',
  );

  Navigator.of(context)
      .pushAndRemoveUntil(
    MaterialPageRoute(
      builder: (context) =>
          const InitialProfileScreen(),
    ),
    (Route<dynamic> route) =>
        false,
  );
}

Widget _buildMobileLoginUi(BuildContext context) {
  return Scaffold(
   backgroundColor: Colors.white,
    body: Container(
      decoration: const BoxDecoration(
  color: Colors.white,
),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FadeTransition(
                  opacity: _fadeInAnimation,
                  child: SlideTransition(
                    position: _slideUpAnimation,
                    child: Column(
                      children: [
                        Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFAD1457).withOpacity(.08),
                            border: Border.all(
                              color: const Color(0xFFAD1457).withOpacity(.15),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(.06),
                                blurRadius: 30,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
  Icons.home_work_rounded,
  color: Color(0xFFAD1457),
  size: 65,
),
                        ),

                        const SizedBox(height: 30),

                        const Text(
                          'Find Your Perfect\nFlatmate & Home',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                            height: 1.2,
                            letterSpacing: -0.5,
                          ),
                        ),

                        const SizedBox(height: 18),

                        Text(
                          'Connect with compatible flatmates and discover your ideal living space effortlessly.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(.85),
                            height: 1.6,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 50),

                FadeTransition(
                  opacity: _fadeInAnimation,
                  child: SlideTransition(
                    position: _slideUpAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                       border: Border.all(
  color: Colors.grey.shade200,
),
                        boxShadow: [
                          BoxShadow(
                           color: Colors.grey.shade50,
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(.10),
                              borderRadius: BorderRadius.circular(18),
                             border: Border.all(
  color: Colors.grey.shade300,
),
                            ),
                            child: TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Enter Phone Number',
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                ),
                                prefixIcon: Container(
                                  margin: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                  color: const Color(0xFFAD1457).withOpacity(.08),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.phone,
                                   color: Color(0xFFAD1457),
                                  ),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                  horizontal: 20,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          if (_isOtpSent)
                            Container(
                              decoration: BoxDecoration(
                               color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(18),
                               border: Border.all(
  color: Colors.grey.shade300,
),
                              ),
                              child: TextField(
                                controller: _otpController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 3,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Enter OTP',
                                  hintStyle: TextStyle(
  color: Colors.grey,
),
                                  prefixIcon: Container(
                                    margin: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFAD1457).withOpacity(.08),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.lock_outline,
                                      color: Color(0xFFAD1457),
                                    ),
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 20,
                                    horizontal: 20,
                                  ),
                                ),
                              ),
                            ),

                          const SizedBox(height: 28),

                          SizedBox(
                            width: double.infinity,
                            height: 58,
                            child: ElevatedButton(
                              onPressed: _loading
                                  ? null
                                  : (_isOtpSent
                                      ? _verifyOtpAndSignIn
                                      : _verifyPhoneNumber),
                              style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFAD1457),
foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: _loading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          _isOtpSent
                                              ? 'Verify OTP'
                                              : 'Get OTP',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(
                                          Icons.arrow_forward_rounded,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          if (_isOtpSent)
                            TextButton(
                              onPressed:
                                  _canResendOtp ? _verifyPhoneNumber : null,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                 color: const Color(0xFFAD1457).withOpacity(.08),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: Colors.white24,
                                  ),
                                ),
                                child: Text(
                                  _canResendOtp
                                      ? 'Resend OTP'
                                      : 'Resend in $_resendOtpTimer seconds',
                                style: TextStyle(
  color: _canResendOtp
      ? const Color(0xFFAD1457)
      : Colors.grey,
  fontWeight: FontWeight.w700,
  fontSize: 14,
),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Opening feedback form...'),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      const Icon(
                        Icons.support_agent_rounded,
                        color: Color(0xFFAD1457),
                        size: 22,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Having trouble? Give Feedback',
                        style: TextStyle(
                        color: Colors.black87,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'By continuing, you agree to our Terms & Privacy Policy',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

  Widget _buildWebLoginUi(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.all(40.0),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.home_work_rounded, color: Colors.redAccent, size: 120),
                    const SizedBox(height: 30),
                    Text(
                      'Welcome to Flatmate Finder',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Your ultimate solution to finding the perfect flatmate and ideal living space. Experience seamless connections and a harmonious home environment.',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 60),
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 5,
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Log In',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent[700],
                        ),
                      ),
                      const SizedBox(height: 30),
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Phone Number (e.g., +919876543210)',
                          prefixIcon: const Icon(Icons.phone, color: Colors.redAccent),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (_isOtpSent)
                        TextField(
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'OTP',
                            prefixIcon: const Icon(Icons.lock, color: Colors.redAccent),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                        ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loading
                              ? null
                              : (_isOtpSent ? _verifyOtpAndSignIn : _verifyPhoneNumber),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 5,
                          ),
                          child: _loading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                            _isOtpSent ? 'Verify OTP' : 'Get OTP',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_isOtpSent)
                        TextButton(
                          onPressed: _canResendOtp ? _verifyPhoneNumber : null,
                          child: Text(
                            _canResendOtp
                                ? 'Resend OTP'
                                : 'Resend in $_resendOtpTimer seconds',
                            style: TextStyle(
                              color: _canResendOtp ? Colors.redAccent : Colors.grey,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      const SizedBox(height: 32),
                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Opening feedback form...')),
                          );
                        },
                        child: Text(
                          'Having trouble? Give Feedback',
                          style: TextStyle(color: Colors.grey[600], fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return _buildWebLoginUi(context);
    } else {
      return _buildMobileLoginUi(context);
    }
  }
}