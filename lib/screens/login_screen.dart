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
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
const Color kPrimaryColor = Color(0xFF7C3AED);
const Color kSecondaryColor = Color(0xFF9333EA);
const Color kAccentColor = Color(0xFFEC4899);

const Color kBackgroundColor = Color(0xFFF8FAFC);

const Color kCardColor = Colors.white;

const Color kLightGrey = Color(0xFFF1F5F9);

const Color kBorderColor = Color(0xFFE2E8F0);

const Color kDarkText = Color(0xFF111827);

const Color kMediumText = Color(0xFF64748B);

const Color kLightText = Color(0xFF94A3B8);

const Color kOnlineColor = Color(0xFF22C55E);

const Color kReadTickColor = Color(0xFF3B82F6);

const Color kErrorColor = Color(0xFFEF4444);

const LinearGradient kPrimaryGradient =
    LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFF7C3AED),
    Color(0xFF9333EA),
    Color(0xFFEC4899),
  ],
);

const LinearGradient kMessageGradient =
    LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFF7C3AED),
    Color(0xFF8B5CF6),
  ],
);
enum SnackBarType {
  success,
  error,
  warning,
  info,
}
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
  bool _acceptedTerms = false;

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
void _showPremiumSnackBar({
  required String message,
  required SnackBarType type,
}) {
  if (!mounted) return;

  ScaffoldMessenger.of(context).hideCurrentSnackBar();

  late final IconData icon;
  late final String title;
  late final List<Color> gradientColors;

  switch (type) {
    case SnackBarType.success:
      icon = Icons.check_circle_rounded;
      title = 'Success';
      gradientColors = const [
        Color(0xFF059669),
        Color(0xFF10B981),
      ];
      break;

    case SnackBarType.error:
      icon = Icons.error_rounded;
      title = 'Something went wrong';
      gradientColors = const [
        Color(0xFFDC2626),
        Color(0xFFEF4444),
      ];
      break;

    case SnackBarType.warning:
      icon = Icons.warning_amber_rounded;
      title = 'Attention';
      gradientColors = const [
        Color(0xFFD97706),
        Color(0xFFF59E0B),
      ];
      break;

    case SnackBarType.info:
      icon = Icons.info_rounded;
      title = 'UrbanHomey';
      gradientColors = const [
        kPrimaryColor,
        kSecondaryColor,
        kAccentColor,
      ];
      break;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,

      backgroundColor: Colors.transparent,
      elevation: 0,

      margin: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 16,
      ),

      padding: EdgeInsets.zero,

      duration: const Duration(seconds: 3),

      content: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withOpacity(.30),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),

        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.18),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.white.withOpacity(.20),
                ),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 25,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    message,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(.90),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context)
                    .hideCurrentSnackBar();
              },
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 17,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
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

    _showPremiumSnackBar(
  message: 'OTP sent successfully on WhatsApp.',
  type: SnackBarType.success,
);
  } catch (e) {
    setState(() {
      _loading = false;
    });

    _showPremiumSnackBar(
  message: 'Unable to send OTP. Please try again.',
  type: SnackBarType.error,
);
  }
}
Future<void> _openUrl(String url) async {
  final uri = Uri.parse(url);

  if (await canLaunchUrl(uri)) {
    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }
}

Future<void> _verifyOtpAndSignIn() async {
  setState(() {
    _loading = true;
  });

  try {
    debugPrint(
      "========== VERIFY OTP START ==========",
    );

    final callable =
        FirebaseFunctions.instance
            .httpsCallable(
      'verifyOtp',
    );

    debugPrint(
      "Calling verifyOtp cloud function...",
    );

    final result =
        await callable.call({
      'phoneNumber':
          '+91${_phoneController.text.trim()}',
      'otp':
          _otpController.text.trim(),
    });

    debugPrint(
      "Cloud function success",
    );

    final token =
        result.data['token'];

    debugPrint(
      "Custom token received",
    );

    await FirebaseAuth.instance
        .signInWithCustomToken(
      token,
    );

    debugPrint(
      "Firebase custom token login successful",
    );

    // -------------------------------
    // Notification initialization
    // Should NEVER block login
    // -------------------------------
    try {
      debugPrint(
        "Initializing notifications...",
      );

      await NotificationService.initialize();

      debugPrint(
        "Notification initialization completed",
      );
    } catch (e, stackTrace) {
      debugPrint(
        "Notification initialization failed",
      );

      debugPrint(
        e.toString(),
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );
    }

    debugPrint(
      "Creating/updating user...",
    );

    await _createOrUpdateUser();

    debugPrint(
      "User document created",
    );

    debugPrint(
      "Navigating to HomePage...",
    );

    _navigateToNextScreen();

    debugPrint(
      "========== LOGIN COMPLETE ==========",
    );
  } catch (e, stackTrace) {
    debugPrint(
      "========== LOGIN FAILED ==========",
    );

    debugPrint(
      e.toString(),
    );

    debugPrintStack(
      stackTrace: stackTrace,
    );

    setState(() {
      _loading = false;
    });

   _showPremiumSnackBar(
  message: 'Invalid or expired OTP. Please check and try again.',
  type: SnackBarType.error,
);
  }
}
Future<void> _openWhatsAppSupport() async {
  const String phoneNumber = '918793744117'; // Replace with your WhatsApp number

  const String message =
      'Hi UrbanHomey Support, I am having trouble logging into the app. Please help me.';

  final Uri whatsappUri = Uri.parse(
    'https://wa.me/$phoneNumber'
    '?text=${Uri.encodeComponent(message)}',
  );

  try {
    final bool opened = await launchUrl(
      whatsappUri,
      mode: LaunchMode.externalApplication,
    );

    if (!opened && mounted) {
      _showPremiumSnackBar(
        message: 'Unable to open WhatsApp. Please try again.',
        type: SnackBarType.error,
      );
    }
  } catch (e) {
    debugPrint('WHATSAPP OPEN ERROR: $e');

    if (mounted) {
      _showPremiumSnackBar(
        message: 'Unable to open WhatsApp. Please try again.',
        type: SnackBarType.error,
      );
    }
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

   _showPremiumSnackBar(
  message: 'Authentication failed. Please try again.',
  type: SnackBarType.error,
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
    backgroundColor: kBackgroundColor,
    body: SafeArea(
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
  width: 140,
  height: 140,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    color: Colors.white,
    border: Border.all(
      color: kPrimaryColor.withOpacity(.15),
    ),
    boxShadow: [
      BoxShadow(
        color: kPrimaryColor.withOpacity(.10),
        blurRadius: 30,
        spreadRadius: 2,
      ),
    ],
  ),
  child: Padding(
    padding: const EdgeInsets.all(20),
    child: Image.asset(
      'assets/images/app_icon.png',
      fit: BoxFit.contain,
    ),
  ),
),

                      const SizedBox(height: 30),

                      const Text(
                        'Find Your Perfect\nFlatmate & Home',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color: kDarkText,
                          height: 1.2,
                          letterSpacing: -0.5,
                        ),
                      ),

                      const SizedBox(height: 18),

                      const Text(
                        'Connect with compatible flatmates and discover your ideal living space effortlessly.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: kMediumText,
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
                      color: kCardColor,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: kBorderColor,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: kPrimaryColor.withOpacity(.06),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: kLightGrey,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: kBorderColor,
                            ),
                          ),
                          child: TextField(
  controller: _phoneController,
  keyboardType: TextInputType.number,
  maxLength: 10,

  inputFormatters: [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(10),
  ],

  onChanged: (value) {
    if (value.length == 10) {
      FocusScope.of(context).unfocus();
    }
  },

  style: const TextStyle(
    color: kDarkText,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  ),

  decoration: InputDecoration(
    hintText: 'Enter 10 Digit Whatsapp Number',
    counterText: '',

    hintStyle: const TextStyle(
      color: kLightText,
    ),

    prefixIcon: Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: kPrimaryColor.withOpacity(.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.phone,
        color: kPrimaryColor,
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
                              color: kLightGrey,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: kBorderColor,
                              ),
                            ),
                            child: TextField(
  controller: _otpController,
  keyboardType: TextInputType.number,
  maxLength: 6,

  inputFormatters: [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(6),
  ],

  onChanged: (value) {
    if (value.length == 6) {
      FocusScope.of(context).unfocus();
    }
  },

  style: const TextStyle(
    color: kDarkText,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 3,
  ),

  decoration: InputDecoration(
    hintText: 'Enter 6 Digit OTP',
    counterText: '',

    hintStyle: const TextStyle(
      color: kLightText,
    ),

    prefixIcon: Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: kPrimaryColor.withOpacity(.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.lock_outline,
        color: kPrimaryColor,
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
                        CheckboxListTile(
  value: _acceptedTerms,
  onChanged: (value) {
    setState(() {
      _acceptedTerms = value ?? false;
    });
  },
  controlAffinity: ListTileControlAffinity.leading,
  contentPadding: EdgeInsets.zero,
  title: RichText(
  text: TextSpan(
    style: const TextStyle(
      color: Colors.black87,
      fontSize: 13,
    ),
    children: [
      const TextSpan(
        text: "I agree to the ",
      ),

      WidgetSpan(
        child: GestureDetector(
          onTap: () {
            _openUrl(
              'https://urbanhomey-363dc.web.app/terms',
            );
          },
          child: const Text(
            "Terms of Use",
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ),

      const TextSpan(
        text: " and ",
      ),

      WidgetSpan(
        child: GestureDetector(
          onTap: () {
            _openUrl(
              'https://urbanhomey-363dc.web.app/privacy',
            );
          },
          child: const Text(
            "Privacy Policy",
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ),
    ],
  ),
),
),
const SizedBox(height: 10),

                        SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: DecoratedBox(
                           decoration: BoxDecoration(
  gradient: _acceptedTerms
      ? kPrimaryGradient
      : LinearGradient(
          colors: [
            Colors.grey.shade400,
            Colors.grey.shade500,
          ],
        ),
  borderRadius: BorderRadius.circular(18),
  boxShadow: _acceptedTerms
      ? [
          BoxShadow(
            color: kPrimaryColor.withOpacity(.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ]
      : [],
),
                            child: ElevatedButton(
                             onPressed: _loading
    ? null
    : !_acceptedTerms
        ? null
        : (_isOtpSent
            ? _verifyOtpAndSignIn
            : _verifyPhoneNumber),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
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
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(
                                          Icons.arrow_forward_rounded,
                                          size: 20,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
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
                                color: kPrimaryColor.withOpacity(.08),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: kPrimaryColor.withOpacity(.15),
                                ),
                              ),
                              child: Text(
                                _canResendOtp
                                    ? 'Resend OTP'
                                    : 'Resend in $_resendOtpTimer seconds',
                                style: TextStyle(
                                  color: _canResendOtp
                                      ? kPrimaryColor
                                      : kMediumText,
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

              const SizedBox(height: 20),

SizedBox(
  width: double.infinity,
  height: 56,
  child: OutlinedButton.icon(

   onPressed: () async {

  try {

    await FirebaseAuth.instance
        .signInAnonymously();

    Navigator.of(context)
        .pushReplacement(
      MaterialPageRoute(
        builder: (_) =>
            const HomePage(),
      ),
    );

  } catch (e) {

    print(
      'GUEST LOGIN ERROR: $e',
    );
  }
},
    icon: const Icon(
      Icons.person_outline_rounded,
    ),

    label: const Text(
      'Continue as Guest',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    ),

    style: OutlinedButton.styleFrom(
      foregroundColor: kPrimaryColor,

      side: BorderSide(
        color: kPrimaryColor.withOpacity(.25),
      ),

      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(18),
      ),
    ),
  ),
),

const SizedBox(height: 24),

TextButton(
onPressed: _openWhatsAppSupport,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: kPrimaryColor.withOpacity(.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.support_agent_rounded,
                        color: kPrimaryColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Having trouble? Give Feedback',
                      style: TextStyle(
                        color: kDarkText,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),


              
            ],
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
    : !_acceptedTerms
        ? null
        : (_isOtpSent
            ? _verifyOtpAndSignIn
            : _verifyPhoneNumber),
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