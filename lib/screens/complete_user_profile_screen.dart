// File: complete_user_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mytennat/data/user_profile.dart';
import 'package:mytennat/screens/home_page.dart';
import 'package:mytennat/screens/verification_screen.dart'; // Import the new verification screen

class CompleteUserProfileScreen extends StatefulWidget {
  const CompleteUserProfileScreen({Key? key}) : super(key: key);

  @override
  _CompleteUserProfileScreenState createState() => _CompleteUserProfileScreenState();
}

class _CompleteUserProfileScreenState extends State<CompleteUserProfileScreen> {
  final _formKey = GlobalKey<FormState>();

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

  final List<String> _occupationOptions = [
    'Student', 'Working Professional', 'Both', 'No preference'
  ];

  final List<String> _religionOptions = [
    'Hindu', 'Muslim', 'Christian','Sikh','Buddhism','Prefer not to say'
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
  'Very clean',
  'Moderately clean',
  'Not so clean',
];

final List<String> _socialPreferenceOptions = [
  'Value personal space highly',
  'Enjoy a balance',
  'Prefer more socialization',
  'Flexible',
];

final List<String> _petOwnershipOptions = [
  'Yes',
  'No',
  'Planning to get one',
];

final List<String> _petToleranceOptions = [
  'Comfortable with pets',
  'Tolerant of pets',
  'Prefer no pets',
  'Allergic to pets',
];

final List<String> _guestsFrequencyOptions = [
  'Never',
  'Rarely',
  'Sometimes',
  'Frequently',
];

  bool _isLoading = false;
  UserProfile? _currentUserProfile;
  double _completionPercentage = 0.0;
  final double _initialPercentage = 25.0;
  final double _maxPercentage = 90.0;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          _currentUserProfile = UserProfile.fromMap(doc.data() as Map<String, dynamic>, user.uid);
          _prefillData();
        }
      } catch (e) {
        print("Error loading user profile: $e");
      }
    }
  }

  void _prefillData() {
    if (_currentUserProfile != null) {
      setState(() {
        _occupation = _currentUserProfile!.occupation;
        _religion = _currentUserProfile!.religion;
        _bio = _currentUserProfile!.bio;
        _smokingHabit = _currentUserProfile!.smokingHabit;
        _drinkingHabit = _currentUserProfile!.drinkingHabit;
        _foodPreference = _currentUserProfile!.foodPreference;
        _cleanlinessLevel = _currentUserProfile!.cleanlinessLevel;
        _socialPreferences = _currentUserProfile!.socialPreferences;
        _petOwnership = _currentUserProfile!.petOwnership;
        _petTolerance = _currentUserProfile!.petTolerance;
        _guestsFrequency = _currentUserProfile!.guestsFrequency;
      });
      _calculateAndSetCompletionPercentage();
    }
  }

  void _calculateAndSetCompletionPercentage() {
    final List<dynamic?> completeProfileFields = [
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
      _bio,
    ];

    final double totalFieldsOnThisPage = completeProfileFields.length.toDouble();
    int completedFieldsOnThisPage = 0;

    for (var field in completeProfileFields) {
      if (field != null && field.toString().isNotEmpty) {
        completedFieldsOnThisPage++;
      }
    }

    final double percentageIncrease = _maxPercentage - _initialPercentage;
    final double percentagePerField = percentageIncrease / totalFieldsOnThisPage;

    setState(() {
      _completionPercentage = _initialPercentage + (completedFieldsOnThisPage * percentagePerField);
    });
  }

  Future<void> _saveCompleteProfile() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    form.save();

    setState(() {
      _isLoading = true;
    });

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

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
    'socialPreferences': _socialPreferences,
    'petOwnership': _petOwnership,
    'petTolerance': _petTolerance,
    'guestsFrequency': _guestsFrequency,
  },
};

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(data, SetOptions(merge: true));

      _calculateAndSetCompletionPercentage();

      if (_completionPercentage >= 90.0) {
        _showVerificationDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile saved successfully!')));
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
      }
    } catch (e) {
      print("Error saving profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save profile: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Part of the _CompleteUserProfileScreenState class

  // Part of the _CompleteUserProfileScreenState class

  void _showVerificationDialog() {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(
          horizontal: 24,
        ),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.12),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 90,
                width: 90,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF6A1B9A),
                      Color(0xFFAD1457),
                    ],
                  ),
                  borderRadius:
                      BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.verified_user_rounded,
                  color: Colors.white,
                  size: 48,
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                "🛡️ Verify Your Profile",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),

              const SizedBox(height: 10),

              Text(
                "Your profile is ${_completionPercentage.toStringAsFixed(0)}% complete. Verification helps build trust and unlocks more opportunities.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(
                    0xFF6A1B9A,
                  ).withOpacity(.06),
                  borderRadius:
                      BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.auto_graph,
                          color: Color(0xFF6A1B9A),
                        ),
                        SizedBox(width: 10),
                        Text(
                          "Profile Completion",
                          style: TextStyle(
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
                            const Color(
                          0xFFE5E7EB,
                        ),
                        valueColor:
                            const AlwaysStoppedAnimation(
                          Color(0xFFAD1457),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "${_completionPercentage.toStringAsFixed(0)}% Complete",
                      style: const TextStyle(
                        fontWeight:
                            FontWeight.w600,
                        color:
                            Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      Colors.green.withOpacity(.08),
                  borderRadius:
                      BorderRadius.circular(16),
                ),
                child: const Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Verified profiles receive more responses",
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Increase trust and credibility",
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Unlock premium verification badge",
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            VerificationScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor:
                        const Color(0xFFAD1457),
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
                        "Verify Now",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: () {
                  Navigator.pop(context);

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          HomePage(),
                    ),
                  );
                },
                child: const Text(
                  "Skip For Now",
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF8F9FC),
    body: Stack(
      children: [
        Container(
          height: 180,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF6A1B9A),
                Color(0xFFAD1457),
              ],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
        ),

        SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFAD1457),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Column(
                    children: [

                      /// HEADER
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                            ),
                          ),

                          const Spacer(),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(.15),
                              borderRadius:
                                  BorderRadius.circular(30),
                            ),
                            child: Text(
                              "${_completionPercentage.toStringAsFixed(0)}%",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Complete Profile",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      /// MAIN FORM CARD
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withOpacity(.08),
                              blurRadius: 25,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),

                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [

                              _buildSectionHeader(
                                "Lifestyle Preferences",
                                Icons.favorite_rounded,
                              ),

                              const SizedBox(height: 20),

                              _buildDropdownField(
                                labelText: 'Occupation',
                                value: _occupation,
                                items: _occupationOptions,
                                onChanged: (val) {
                                  setState(() {
                                    _occupation = val;
                                  });
                                  _calculateAndSetCompletionPercentage();
                                },
                                icon: Icons.work,
                              ),

                              const SizedBox(height: 18),

                              _buildDropdownField(
                                labelText: 'Religion',
                                value: _religion,
                                items: _religionOptions,
                                onChanged: (val) {
                                  setState(() {
                                    _religion = val;
                                  });
                                  _calculateAndSetCompletionPercentage();
                                },
                                icon: Icons.favorite,
                              ),

                              const SizedBox(height: 30),

                              _buildSectionHeader(
                                "Habits & Lifestyle",
                                Icons.self_improvement_rounded,
                              ),

                              const SizedBox(height: 20),

                              _buildDropdownField(
                                labelText: 'Smoking Habit',
                                value: _smokingHabit,
                                items: _smokingHabitOptions,
                                onChanged: (val) {
                                  setState(() {
                                    _smokingHabit = val;
                                  });
                                  _calculateAndSetCompletionPercentage();
                                },
                                icon: Icons.smoking_rooms,
                              ),

                              const SizedBox(height: 18),

                              _buildDropdownField(
                                labelText: 'Drinking Habit',
                                value: _drinkingHabit,
                                items: _drinkingHabitOptions,
                                onChanged: (val) {
                                  setState(() {
                                    _drinkingHabit = val;
                                  });
                                  _calculateAndSetCompletionPercentage();
                                },
                                icon: Icons.local_bar,
                              ),

                              const SizedBox(height: 18),

                              _buildDropdownField(
                                labelText: 'Food Preference',
                                value: _foodPreference,
                                items: _foodPreferenceOptions,
                                onChanged: (val) {
                                  setState(() {
                                    _foodPreference = val;
                                  });
                                  _calculateAndSetCompletionPercentage();
                                },
                                icon: Icons.restaurant,
                              ),

                              const SizedBox(height: 18),

                              _buildDropdownField(
                                labelText: 'Cleanliness Level',
                                value: _cleanlinessLevel,
                                items: _cleanlinessLevelOptions,
                                onChanged: (val) {
                                  setState(() {
                                    _cleanlinessLevel = val;
                                  });
                                  _calculateAndSetCompletionPercentage();
                                },
                                icon: Icons.cleaning_services,
                              ),

                              const SizedBox(height: 18),

                              _buildDropdownField(
                                labelText: 'Social Preferences',
                                value: _socialPreferences,
                                items: _socialPreferenceOptions,
                                onChanged: (val) {
                                  setState(() {
                                    _socialPreferences = val;
                                  });
                                  _calculateAndSetCompletionPercentage();
                                },
                                icon: Icons.groups,
                              ),

                              const SizedBox(height: 18),

                              _buildDropdownField(
                                labelText: 'Pet Ownership',
                                value: _petOwnership,
                                items: _petOwnershipOptions,
                                onChanged: (val) {
                                  setState(() {
                                    _petOwnership = val;
                                  });
                                  _calculateAndSetCompletionPercentage();
                                },
                                icon: Icons.pets,
                              ),

                              const SizedBox(height: 18),

                              _buildDropdownField(
                                labelText: 'Pet Tolerance',
                                value: _petTolerance,
                                items: _petToleranceOptions,
                                onChanged: (val) {
                                  setState(() {
                                    _petTolerance = val;
                                  });
                                  _calculateAndSetCompletionPercentage();
                                },
                                icon: Icons.favorite_border,
                              ),

                              const SizedBox(height: 18),

                              _buildDropdownField(
                                labelText: 'Guests Frequency',
                                value: _guestsFrequency,
                                items: _guestsFrequencyOptions,
                                onChanged: (val) {
                                  setState(() {
                                    _guestsFrequency = val;
                                  });
                                  _calculateAndSetCompletionPercentage();
                                },
                                icon: Icons.people_alt,
                              ),

                              const SizedBox(height: 30),

                              _buildSectionHeader(
                                "About You",
                                Icons.person_rounded,
                              ),

                              const SizedBox(height: 20),

                              _buildTextFormField(
                                label: 'Short Bio',
                                icon: Icons.description,
                                initialValue: _bio,
                                maxLines: 5,
                                onSaved: (value) {
                                  _bio = value;
                                },
                              ),

                              const SizedBox(height: 35),

                              SizedBox(
                                width: double.infinity,
                                height: 60,
                                child: ElevatedButton(
                                  onPressed:
                                      _saveCompleteProfile,
                                  style:
                                      ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color(
                                      0xFFAD1457,
                                    ),
                                    elevation: 0,
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
                                      Icon(
                                        Icons.check_circle_rounded,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        "Complete Profile",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight:
                                              FontWeight.bold,
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

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
        ),
      ],
    ),
  );
}

 Widget _buildTextFormField({
  required String label,
  required IconData icon,
  String? initialValue,
  int maxLines = 1,
  required FormFieldSetter<String> onSaved,
}) {
  return TextFormField(
    initialValue: initialValue,
    maxLines: maxLines,
    onSaved: onSaved,
    style: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Color(0xFF1F2937),
    ),
    decoration: InputDecoration(
      hintText: label,
      hintStyle: TextStyle(
        color: Colors.grey.shade500,
        fontSize: 15,
      ),

      alignLabelWithHint: true,

      prefixIcon: Container(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF6A1B9A),
              Color(0xFFAD1457),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ),

      filled: true,
      fillColor: const Color(0xFFF8F9FC),

      contentPadding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: maxLines > 1 ? 20 : 18,
      ),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: Colors.grey.shade200,
          width: 1.5,
        ),
      ),

      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(18),
        ),
        borderSide: BorderSide(
          color: Color(0xFFAD1457),
          width: 2,
        ),
      ),

      errorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(18),
        ),
        borderSide: BorderSide(
          color: Colors.red,
          width: 2,
        ),
      ),

      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(18),
        ),
        borderSide: BorderSide(
          color: Colors.red,
          width: 2,
        ),
      ),
    ),
  );
}

  Widget _buildDropdownField({
  required String labelText,
  required String? value,
  required List<String> items,
  required ValueChanged<String?> onChanged,
  required IconData icon,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF6A1B9A),
                  Color(0xFFAD1457),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
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
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
        ],
      ),

      const SizedBox(height: 14),

      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: items.map((item) {
          final bool isSelected = value == item;

          return GestureDetector(
            onTap: () {
              onChanged(item);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [
                          Color(0xFF6A1B9A),
                          Color(0xFFAD1457),
                        ],
                      )
                    : null,
                color: isSelected
                    ? null
                    : const Color(0xFFF8F9FC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : Colors.grey.shade300,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(
                            0xFFAD1457,
                          ).withOpacity(.20),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF374151),
                    ),
                  ),

                  if (isSelected) ...[
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 18,
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),

      const SizedBox(height: 20),
    ],
  );
}
Widget _buildSectionHeader(
  String title,
  IconData icon,
) {
  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 14,
    ),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [
          Color(0xFF6A1B9A),
          Color(0xFFAD1457),
        ],
      ),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Row(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 22,
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}
}