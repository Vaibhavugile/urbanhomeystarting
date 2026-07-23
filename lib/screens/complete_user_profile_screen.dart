import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:mytennat/data/user_profile.dart';
import 'package:mytennat/screens/home_page.dart';
import 'package:mytennat/screens/verification_screen.dart';

// ============================================================
// URBANHOMEY PREMIUM COLOR THEME
// ============================================================

const Color kPrimaryColor = Color(0xFF7C3AED);
const Color kSecondaryColor = Color(0xFF9333EA);
const Color kAccentColor = Color(0xFFEC4899);

const Color kBackgroundColor = Color(0xFFF8FAFC);
const Color kCardColor = Colors.white;

const Color kDarkText = Color(0xFF111827);
const Color kMediumText = Color(0xFF64748B);
const Color kLightText = Color(0xFF94A3B8);

const Color kBorderColor = Color(0xFFE2E8F0);
const Color kSuccessColor = Color(0xFF22C55E);
const Color kErrorColor = Color(0xFFEF4444);

const LinearGradient kPrimaryGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    kPrimaryColor,
    kSecondaryColor,
    kAccentColor,
  ],
);

// ============================================================
// COMPLETE USER PROFILE SCREEN
// ============================================================

class CompleteUserProfileScreen extends StatefulWidget {
  const CompleteUserProfileScreen({
    super.key,
  });

  @override
  State<CompleteUserProfileScreen> createState() =>
      _CompleteUserProfileScreenState();
}

class _CompleteUserProfileScreenState
    extends State<CompleteUserProfileScreen> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  // ============================================================
  // PROFILE VALUES
  // ============================================================

  String? _occupation;
  String? _religion;
  String? _smokingHabit;
  String? _drinkingHabit;
  String? _foodPreference;
  String? _cleanlinessLevel;
  String? _socialPreferences;
  String? _petOwnership;
  String? _petTolerance;
  String? _guestsFrequency;
  String? _bio;

  // ============================================================
  // OPTIONS
  // ============================================================

  final List<String> _occupationOptions = [
    'Student',
    'Working Professional',
    'Prefer not to say',
  ];

  final List<String> _religionOptions = [
    'Hindu',
    'Muslim',
    'Christian',
    'Sikh',
    'Buddhism',
    'Other',
    'Prefer not to say',
  ];

  final List<String> _smokingHabitOptions = [
    'Never',
    'Occasionally',
    'Socially',
    'Regularly',
  ];

  final List<String> _drinkingHabitOptions = [
    'Never',
    'Occasionally',
    'Socially',
    'Regularly',
  ];

  final List<String> _foodPreferenceOptions = [
    'Vegetarian',
    'Non-Vegetarian',
    'Vegan',
    'Eggetarian',
    'Jain',
    'Other',
  ];

  final List<String> _cleanlinessLevelOptions = [
    'Very neat',
    'Moderately neat',
    'Relaxed',
  ];

  final List<String> _socialPreferenceOptions = [
    'Private',
    'Balanced',
    'Social',
    'Flexible',
  ];

  final List<String> _petOwnershipOptions = [
    'Yes',
    'No',
    'Planning to get one',
  ];

  final List<String> _petToleranceOptions = [
    'Love Pets',
    'Okay With Pets',
    'No Pets',
    'Allergic',
  ];

  final List<String> _guestsFrequencyOptions = [
    'Never',
    'Rarely',
    'Sometimes',
    'Frequently',
  ];

  // ============================================================
  // STATE
  // ============================================================

  bool _isLoading = false;
  bool _isInitialLoading = true;

  UserProfile? _currentUserProfile;

  double _completionPercentage = 25.0;

  static const double _initialPercentage = 25.0;
  static const double _maxPercentage = 90.0;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _loadUserProfile();
  }

  // ============================================================
  // LOAD USER PROFILE
  // ============================================================

  Future<void> _loadUserProfile() async {
    final User? user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (mounted) {
        setState(() {
          _isInitialLoading = false;
        });
      }

      return;
    }

    try {
      final DocumentSnapshot<Map<String, dynamic>>
          document =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      if (!document.exists) {
        return;
      }

      final Map<String, dynamic>? data =
          document.data();

      if (data == null) {
        return;
      }

      _currentUserProfile =
          UserProfile.fromMap(
        data,
        user.uid,
      );

      _prefillData();
    } catch (e) {
      debugPrint(
        'Error loading user profile: $e',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            'Unable to load your profile: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isInitialLoading = false;
        });
      }
    }
  }

  // ============================================================
  // PREFILL PROFILE DATA
  // ============================================================

  void _prefillData() {
    final UserProfile? profile =
        _currentUserProfile;

    if (profile == null || !mounted) {
      return;
    }

    setState(() {
      _occupation = profile.occupation;
      _religion = profile.religion;
      _bio = profile.bio;

      _smokingHabit = profile.smokingHabit;
      _drinkingHabit = profile.drinkingHabit;
      _foodPreference = profile.foodPreference;
      _cleanlinessLevel = profile.cleanlinessLevel;
      _socialPreferences =
          profile.socialPreferences;
      _petOwnership = profile.petOwnership;
      _petTolerance = profile.petTolerance;
      _guestsFrequency =
          profile.guestsFrequency;
    });

    _calculateAndSetCompletionPercentage();
  }

  // ============================================================
  // COMPLETION PERCENTAGE
  // ============================================================

  void _calculateAndSetCompletionPercentage() {
    final List<dynamic> completeProfileFields = [
      _occupation,
      _religion,
      _smokingHabit,
      _drinkingHabit,
      _foodPreference,
      _cleanlinessLevel,
      _socialPreferences,
      _petOwnership,
      _petTolerance,
      _guestsFrequency,
      
    ];

    int completedFields = 0;

    for (final dynamic field
        in completeProfileFields) {
      if (field != null &&
          field.toString().trim().isNotEmpty) {
        completedFields++;
      }
    }

    final double totalFields =
        completeProfileFields.length.toDouble();

    final double percentageIncrease =
        _maxPercentage - _initialPercentage;

    final double percentagePerField =
        percentageIncrease / totalFields;

    final double newPercentage =
        _initialPercentage +
            (completedFields *
                percentagePerField);

    if (!mounted) return;

    setState(() {
      _completionPercentage =
          newPercentage.clamp(
        _initialPercentage,
        _maxPercentage,
      );
    });
  }

  // ============================================================
  // SAVE COMPLETE PROFILE
  // ============================================================

  Future<void> _saveCompleteProfile() async {
    if (_isLoading) return;

    final FormState? form =
        _formKey.currentState;

    if (form == null || !form.validate()) {
      return;
    }

    form.save();

    final User? user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            'You must be signed in to save your profile.',
          ),
        ),
      );

      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final Map<String, dynamic> data = {
        'occupation': _occupation,
        'religion': _religion,
        'bio': _bio,

        'habits': {
          'smoking': _smokingHabit,
          'drinking': _drinkingHabit,
          'food': _foodPreference,
          'cleanliness': _cleanlinessLevel,
          'socialPreferences':
              _socialPreferences,
          'petOwnership': _petOwnership,
          'petTolerance': _petTolerance,
          'guestsFrequency':
              _guestsFrequency,
        },
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(
        data,
        SetOptions(
          merge: true,
        ),
      );

      _calculateAndSetCompletionPercentage();

      if (!mounted) return;

      if (_completionPercentage >= 90.0) {
        await _showVerificationDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(
              'Profile saved successfully!',
            ),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const HomePage(),
          ),
        );
      }
    } catch (e) {
      debugPrint(
        'Error saving profile: $e',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            'Failed to save profile: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // VERIFICATION DIALOG
  // ============================================================

  Future<void> _showVerificationDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding:
              const EdgeInsets.symmetric(
            horizontal: 24,
          ),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: kCardColor,
              borderRadius:
                  BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color:
                      kPrimaryColor.withOpacity(.15),
                  blurRadius: 35,
                  offset:
                      const Offset(0, 15),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  Container(
                    height: 90,
                    width: 90,
                    decoration: BoxDecoration(
                      gradient:
                          kPrimaryGradient,
                      borderRadius:
                          BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: kAccentColor
                              .withOpacity(.25),
                          blurRadius: 20,
                          offset:
                              const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons
                          .verified_user_rounded,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    '🛡️ Verify Your Profile',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight:
                          FontWeight.w800,
                      color: kDarkText,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    'Your profile is '
                    '${_completionPercentage.toStringAsFixed(0)}% '
                    'complete. Verification helps build '
                    'trust and unlocks more opportunities.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: kMediumText,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 24),

                  Container(
                    padding:
                        const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: kPrimaryColor
                          .withOpacity(.06),
                      borderRadius:
                          BorderRadius.circular(18),
                      border: Border.all(
                        color: kPrimaryColor
                            .withOpacity(.10),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons
                                  .auto_graph_rounded,
                              color:
                                  kPrimaryColor,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Profile Completion',
                              style: TextStyle(
                                color: kDarkText,
                                fontWeight:
                                    FontWeight.w700,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(
                                  20),
                          child:
                              LinearProgressIndicator(
                            value:
                                _completionPercentage /
                                    100,
                            minHeight: 10,
                            backgroundColor:
                                kBorderColor,
                            valueColor:
                                const AlwaysStoppedAnimation<
                                    Color>(
                              kAccentColor,
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          '${_completionPercentage.toStringAsFixed(0)}% Complete',
                          style: const TextStyle(
                            fontWeight:
                                FontWeight.w600,
                            color: kMediumText,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  Container(
                    padding:
                        const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: kSuccessColor
                          .withOpacity(.08),
                      borderRadius:
                          BorderRadius.circular(16),
                      border: Border.all(
                        color: kSuccessColor
                            .withOpacity(.12),
                      ),
                    ),
                    child: const Column(
                      children: [
                        _VerificationBenefitRow(
                          text:
                              'Verified profiles receive more responses',
                        ),
                        SizedBox(height: 10),
                        _VerificationBenefitRow(
                          text:
                              'Increase trust and credibility',
                        ),
                        SizedBox(height: 10),
                        _VerificationBenefitRow(
                          text:
                              'Unlock premium verification badge',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient:
                          kPrimaryGradient,
                      borderRadius:
                          BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: kAccentColor
                              .withOpacity(.22),
                          blurRadius: 18,
                          offset:
                              const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(
                          dialogContext,
                        );

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const VerificationScreen(),
                          ),
                        );
                      },
                      style:
                          ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor:
                            Colors.transparent,
                        shadowColor:
                            Colors.transparent,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                                  18),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Text(
                            'Verify Now',
                            style: TextStyle(
                              color:
                                  Colors.white,
                              fontSize: 17,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons
                                .arrow_forward_rounded,
                            color:
                                Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextButton(
                    onPressed: () {
                      Navigator.pop(
                        dialogContext,
                      );

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const HomePage(),
                        ),
                      );
                    },
                    child: const Text(
                      'Skip For Now',
                      style: TextStyle(
                        color: kMediumText,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Stack(
        children: [
          // PREMIUM HEADER

          Container(
            height: 205,
            decoration: const BoxDecoration(
              gradient: kPrimaryGradient,
              borderRadius: BorderRadius.only(
                bottomLeft:
                    Radius.circular(36),
                bottomRight:
                    Radius.circular(36),
              ),
            ),
          ),

          // DECORATIVE CIRCLE

          Positioned(
            top: -65,
            right: -50,
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    Colors.white.withOpacity(.06),
              ),
            ),
          ),

          Positioned(
            top: 110,
            left: -75,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    Colors.white.withOpacity(.05),
              ),
            ),
          ),

          SafeArea(
            child: _isInitialLoading
                ? const Center(
                    child:
                        CircularProgressIndicator(
                      color: kPrimaryColor,
                    ),
                  )
                : SingleChildScrollView(
                    physics:
                        const BouncingScrollPhysics(),
                    padding:
                        const EdgeInsets.fromLTRB(
                      20,
                      8,
                      20,
                      30,
                    ),
                    child: Column(
                      children: [
                        // HEADER ROW

                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration:
                                  BoxDecoration(
                                color: Colors.white
                                    .withOpacity(.14),
                                borderRadius:
                                    BorderRadius.circular(
                                        14),
                                border: Border.all(
                                  color: Colors.white
                                      .withOpacity(.15),
                                ),
                              ),
                              child: IconButton(
                                onPressed: () {
                                  Navigator.pop(
                                    context,
                                  );
                                },
                                icon: const Icon(
                                  Icons
                                      .arrow_back_ios_new_rounded,
                                  color:
                                      Colors.white,
                                  size: 19,
                                ),
                              ),
                            ),

                            const Spacer(),

                            Container(
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration:
                                  BoxDecoration(
                                color: Colors.white
                                    .withOpacity(.15),
                                borderRadius:
                                    BorderRadius.circular(
                                        30),
                                border: Border.all(
                                  color: Colors.white
                                      .withOpacity(.15),
                                ),
                              ),
                              child: Row(
                                mainAxisSize:
                                    MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons
                                        .auto_graph_rounded,
                                    color:
                                        Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(
                                      width: 6),
                                  Text(
                                    '${_completionPercentage.toStringAsFixed(0)}%',
                                    style:
                                        const TextStyle(
                                      color:
                                          Colors.white,
                                      fontWeight:
                                          FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        const Align(
                          alignment:
                              Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              Text(
                                'Complete Profile',
                                style: TextStyle(
                                  color:
                                      Colors.white,
                                  fontSize: 30,
                                  fontWeight:
                                      FontWeight.w800,
                                  letterSpacing: -.5,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Help us find better flatmate matches for you',
                                style: TextStyle(
                                  color:
                                      Colors.white70,
                                  fontSize: 14,
                                  fontWeight:
                                      FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 25),

                        // MAIN FORM CARD

                        Container(
                          padding:
                              const EdgeInsets.fromLTRB(
                            22,
                            26,
                            22,
                            24,
                          ),
                          decoration: BoxDecoration(
                            color: kCardColor,
                            borderRadius:
                                BorderRadius.circular(
                                    28),
                            boxShadow: [
                              BoxShadow(
                                color: kPrimaryColor
                                    .withOpacity(.10),
                                blurRadius: 30,
                                offset:
                                    const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                _buildSectionHeader(
                                  'Basic Details',
                                  Icons
                                      .person_outline_rounded,
                                ),

                                const SizedBox(
                                    height: 22),

                                _buildDropdownField(
                                  labelText:
                                      'Occupation',
                                  value:
                                      _occupation,
                                  items:
                                      _occupationOptions,
                                  onChanged:
                                      (value) {
                                    setState(() {
                                      _occupation =
                                          value;
                                    });

                                    _calculateAndSetCompletionPercentage();
                                  },
                                  icon: Icons
                                      .work_outline_rounded,
                                ),

                                _buildDropdownField(
                                  labelText:
                                      'Religion',
                                  value: _religion,
                                  items:
                                      _religionOptions,
                                  onChanged:
                                      (value) {
                                    setState(() {
                                      _religion =
                                          value;
                                    });

                                    _calculateAndSetCompletionPercentage();
                                  },
                                  icon: Icons
                                      .favorite_border_rounded,
                                ),

                                const SizedBox(
                                    height: 8),

                                _buildSectionHeader(
                                  'Habits & Lifestyle',
                                  Icons
                                      .self_improvement_rounded,
                                ),

                                const SizedBox(
                                    height: 22),

                                _buildDropdownField(
                                  labelText:
                                      'Smoking Habit',
                                  value:
                                      _smokingHabit,
                                  items:
                                      _smokingHabitOptions,
                                  onChanged:
                                      (value) {
                                    setState(() {
                                      _smokingHabit =
                                          value;
                                    });

                                    _calculateAndSetCompletionPercentage();
                                  },
                                  icon: Icons
                                      .smoking_rooms_rounded,
                                ),

                                _buildDropdownField(
                                  labelText:
                                      'Drinking Habit',
                                  value:
                                      _drinkingHabit,
                                  items:
                                      _drinkingHabitOptions,
                                  onChanged:
                                      (value) {
                                    setState(() {
                                      _drinkingHabit =
                                          value;
                                    });

                                    _calculateAndSetCompletionPercentage();
                                  },
                                  icon: Icons
                                      .local_bar_rounded,
                                ),

                                _buildDropdownField(
                                  labelText:
                                      'Food Preference',
                                  value:
                                      _foodPreference,
                                  items:
                                      _foodPreferenceOptions,
                                  onChanged:
                                      (value) {
                                    setState(() {
                                      _foodPreference =
                                          value;
                                    });

                                    _calculateAndSetCompletionPercentage();
                                  },
                                  icon: Icons
                                      .restaurant_rounded,
                                ),

                                _buildDropdownField(
                                  labelText:
                                      'Cleanliness Level',
                                  value:
                                      _cleanlinessLevel,
                                  items:
                                      _cleanlinessLevelOptions,
                                  onChanged:
                                      (value) {
                                    setState(() {
                                      _cleanlinessLevel =
                                          value;
                                    });

                                    _calculateAndSetCompletionPercentage();
                                  },
                                  icon: Icons
                                      .cleaning_services_rounded,
                                ),

                                _buildDropdownField(
                                  labelText:
                                      'Social Style',
                                  value:
                                      _socialPreferences,
                                  items:
                                      _socialPreferenceOptions,
                                  onChanged:
                                      (value) {
                                    setState(() {
                                      _socialPreferences =
                                          value;
                                    });

                                    _calculateAndSetCompletionPercentage();
                                  },
                                  icon: Icons
                                      .groups_rounded,
                                ),

                                _buildDropdownField(
                                  labelText:
                                      'Pet Ownership',
                                  value:
                                      _petOwnership,
                                  items:
                                      _petOwnershipOptions,
                                  onChanged:
                                      (value) {
                                    setState(() {
                                      _petOwnership =
                                          value;
                                    });

                                    _calculateAndSetCompletionPercentage();
                                  },
                                  icon:
                                      Icons.pets_rounded,
                                ),

                                _buildDropdownField(
                                  labelText:
                                      'Pet Friendly?',
                                  value:
                                      _petTolerance,
                                  items:
                                      _petToleranceOptions,
                                  onChanged:
                                      (value) {
                                    setState(() {
                                      _petTolerance =
                                          value;
                                    });

                                    _calculateAndSetCompletionPercentage();
                                  },
                                  icon: Icons
                                      .favorite_outline_rounded,
                                ),

                                _buildDropdownField(
                                  labelText:
                                      'Guests Frequency',
                                  value:
                                      _guestsFrequency,
                                  items:
                                      _guestsFrequencyOptions,
                                  onChanged:
                                      (value) {
                                    setState(() {
                                      _guestsFrequency =
                                          value;
                                    });

                                    _calculateAndSetCompletionPercentage();
                                  },
                                  icon: Icons
                                      .people_alt_outlined,
                                ),

                                const SizedBox(
                                    height: 10),

                                _buildCompleteButton(),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
          ),

          if (_isLoading)
            Positioned.fill(
              child: Container(
                color:
                    Colors.black.withOpacity(.18),
                alignment: Alignment.center,
                child: Container(
                  padding:
                      const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withOpacity(.12),
                        blurRadius: 25,
                      ),
                    ],
                  ),
                  child:
                      const CircularProgressIndicator(
                    color: kPrimaryColor,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // DROPDOWN / OPTION FIELD
  // ============================================================

  Widget _buildDropdownField({
    required String labelText,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding:
                  const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: kPrimaryGradient,
                borderRadius:
                    BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: kPrimaryColor
                        .withOpacity(.14),
                    blurRadius: 8,
                    offset:
                        const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 18,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                labelText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.w700,
                  color: kDarkText,
                ),
              ),
            ),

            if (value != null &&
                value.trim().isNotEmpty)
              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: kSuccessColor
                      .withOpacity(.10),
                  borderRadius:
                      BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_rounded,
                      color: kSuccessColor,
                      size: 14,
                    ),
                    SizedBox(width: 3),
                    Text(
                      'Added',
                      style: TextStyle(
                        color: kSuccessColor,
                        fontSize: 11,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),

        const SizedBox(height: 14),

        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: items.map(
            (item) {
              final bool isSelected =
                  value == item;

              return GestureDetector(
                onTap: _isLoading
                    ? null
                    : () {
                        onChanged(item);
                      },
                child: AnimatedContainer(
                  duration:
                      const Duration(
                    milliseconds: 220,
                  ),
                  curve: Curves.easeOut,
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 13,
                  ),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? kPrimaryGradient
                        : null,
                    color: isSelected
                        ? null
                        : kBackgroundColor,
                    borderRadius:
                        BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : kBorderColor,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: kAccentColor
                                  .withOpacity(.20),
                              blurRadius: 12,
                              offset:
                                  const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: Row(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      Text(
                        item,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : kDarkText,
                        ),
                      ),

                      if (isSelected) ...[
                        const SizedBox(
                            width: 8),
                        const Icon(
                          Icons
                              .check_circle_rounded,
                          color:
                              Colors.white,
                          size: 18,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ).toList(),
        ),

        const SizedBox(height: 22),
      ],
    );
  }

  // ============================================================
  // SECTION HEADER
  // ============================================================

  Widget _buildSectionHeader(
    String title,
    IconData icon,
  ) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        gradient: kPrimaryGradient,
        borderRadius:
            BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color:
                kPrimaryColor.withOpacity(.18),
            blurRadius: 14,
            offset:
                const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color:
                  Colors.white.withOpacity(.16),
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 21,
            ),
          ),

          const SizedBox(width: 12),

          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // COMPLETE BUTTON
  // ============================================================

  Widget _buildCompleteButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: kPrimaryGradient,
        borderRadius:
            BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color:
                kPrimaryColor.withOpacity(.30),
            blurRadius: 20,
            offset:
                const Offset(0, 9),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading
            ? null
            : _saveCompleteProfile,
        style:
            ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor:
              Colors.transparent,
          disabledBackgroundColor:
              Colors.transparent,
          shadowColor:
              Colors.transparent,
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(18),
          ),
        ),
        child: const Row(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
            ),
            SizedBox(width: 10),
            Text(
              'Complete Profile',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// VERIFICATION BENEFIT ROW
// ============================================================

class _VerificationBenefitRow
    extends StatelessWidget {
  final String text;

  const _VerificationBenefitRow({
    required this.text,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Row(
      children: [
        const Icon(
          Icons.check_circle_rounded,
          color: kSuccessColor,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: kDarkText,
              fontWeight:
                  FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}