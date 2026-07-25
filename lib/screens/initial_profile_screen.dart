import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mytennat/data/user_profile.dart';
import 'package:mytennat/screens/complete_user_profile_screen.dart';
import 'package:mytennat/screens/home_page.dart';
import 'package:path_provider/path_provider.dart';

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
// INITIAL PROFILE SCREEN
// ============================================================
class InitialProfileScreen extends StatefulWidget {
  final bool isEditMode;

  const InitialProfileScreen({
    super.key,
    this.isEditMode = false,
  });

  @override
  State<InitialProfileScreen> createState() =>
      _InitialProfileScreenState();
}

class _InitialProfileScreenState
    extends State<InitialProfileScreen> {
  // ============================================================
  // FORM
  // ============================================================
String? _existingProfileImageUrl;

bool _isLoadingProfile = false;
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  final TextEditingController _firstNameController =
      TextEditingController();

  final TextEditingController _lastNameController =
      TextEditingController();

  final TextEditingController _ageController =
      TextEditingController();

  final TextEditingController _cityController =
      TextEditingController();

  // ============================================================
  // PROFILE STATE
  // ============================================================

  String _selectedGender = 'Male';

  File? _profileImageFile;

  bool _isLoading = false;

  // ============================================================
  // IMAGE PICKER
  // ============================================================

  final ImagePicker _imagePicker = ImagePicker();

  // ============================================================
  // DISPOSE
  // ============================================================
@override
void initState() {
  super.initState();

  if (widget.isEditMode) {
    _loadExistingProfile();
  }
}
  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    _cityController.dispose();

    super.dispose();
  }
  String _formatWords(String value) {
  return value
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .map((part) {
        final String lowerCasePart =
            part.toLowerCase();

        return '${lowerCasePart[0].toUpperCase()}'
            '${lowerCasePart.substring(1)}';
      })
      .join(' ');
}
  Future<void> _loadExistingProfile() async {
  final User? user =
      FirebaseAuth.instance.currentUser;

  if (user == null) {
    return;
  }

  setState(() {
    _isLoadingProfile = true;
  });

  try {
    final DocumentSnapshot<
            Map<String, dynamic>>
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

    // ==========================================================
    // SPLIT EXISTING FULL NAME
    // ==========================================================

   final String fullName =
    data['name']?.toString().trim() ?? '';

final List<String> nameParts =
    fullName
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

_firstNameController.text =
    nameParts.isNotEmpty
        ? nameParts.first
        : '';

_lastNameController.text =
    nameParts.length > 1
        ? nameParts.sublist(1).join(' ')
        : '';

    // ==========================================================
    // LOAD OTHER DATA
    // ==========================================================

    _ageController.text =
        data['age']?.toString() ?? '';

    _cityController.text =
        data['city']?.toString() ?? '';

    final String gender =
        data['gender']?.toString().trim() ?? '';

    if ([
      'Male',
      'Female',
      'Other',
    ].contains(gender)) {
      _selectedGender = gender;
    }

    _existingProfileImageUrl =
    (data['profilePhotoUrl']?.toString().trim().isNotEmpty ?? false)
        ? data['profilePhotoUrl'].toString().trim()
        : data['pendingProfilePhotoUrl']?.toString().trim();

    if (_existingProfileImageUrl?.isEmpty ??
        true) {
      _existingProfileImageUrl = null;
    }
  } catch (e) {
    debugPrint(
      'Error loading existing profile: $e',
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          'Unable to load profile: $e',
        ),
      ),
    );
  } finally {
    if (mounted) {
      setState(() {
        _isLoadingProfile = false;
      });
    }
  }
}

  // ============================================================
  // IMAGE COMPRESSION
  // ============================================================

  Future<File> _compressImage(
    File file,
  ) async {
    final directory =
        await getTemporaryDirectory();

    int quality = 75;

    while (true) {
      final String targetPath =
          '${directory.path}/'
          '${DateTime.now().microsecondsSinceEpoch}_'
          '$quality.jpg';

      final result =
          await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: quality,
        minWidth: 720,
        minHeight: 720,
        format: CompressFormat.jpeg,
        keepExif: false,
      );

      if (result == null) {
        return file;
      }

      final File compressed =
          File(result.path);

      final double sizeKB =
          await compressed.length() / 1024;

      debugPrint(
        'Quality: $quality | '
        'Size: ${sizeKB.toStringAsFixed(1)} KB',
      );

      if (sizeKB <= 80 || quality <= 20) {
        return compressed;
      }

      quality -= 5;
    }
  }

  // ============================================================
  // PICK PROFILE IMAGE
  // ============================================================

  Future<void> _pickImage() async {
    if (_isLoading) return;

    final XFile? pickedFile =
        await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
    );

    if (pickedFile == null) return;

    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final File compressed =
          await _compressImage(
        File(pickedFile.path),
      );

      if (!mounted) return;

      setState(() {
        _profileImageFile = compressed;
      });

      debugPrint(
        'Final Size: '
        '${(await compressed.length() / 1024).toStringAsFixed(1)} KB',
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            'Unable to process image: $e',
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
  // UPLOAD PROFILE IMAGE
  // ============================================================

  Future<String?> _uploadImage(
    File imageFile,
    String uid,
  ) async {
    try {
      final double sizeKB =
          await imageFile.length() / 1024;

      debugPrint(
        'Uploading compressed image: '
        '${sizeKB.toStringAsFixed(1)} KB',
      );

      final Reference storageReference =
          FirebaseStorage.instance
              .ref()
              .child('profile_images')
              .child('$uid.jpg');

      await storageReference.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
        ),
      );

      return await storageReference
          .getDownloadURL();
    } catch (e) {
      debugPrint(
        'Upload Error: $e',
      );

      return null;
    }
  }

  // ============================================================
  // SAVE INITIAL PROFILE
  // ============================================================

  Future<void> _saveInitialProfile() async {
    if (_isLoading) return;

   if (!widget.isEditMode &&
    _profileImageFile == null &&
    _existingProfileImageUrl == null) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text(
        'Please upload your profile photo.',
      ),
    ),
  );
  return;
}

    final User? user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            'You must be signed in to create a profile.',
          ),
        ),
      );

      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // ============================================================
// KEEP EXISTING IMAGE BY DEFAULT
// ============================================================

String? profileImageUrl =
    _existingProfileImageUrl;

// ============================================================
// UPLOAD ONLY IF USER SELECTED A NEW IMAGE
// ============================================================

if (_profileImageFile != null) {
  profileImageUrl = await _uploadImage(
    _profileImageFile!,
    user.uid,
  );

  if (profileImageUrl == null) {
    throw Exception(
      'Profile photo upload failed.',
    );
  }

  // Keep local state synchronized with new uploaded image.
  _existingProfileImageUrl =
      profileImageUrl;
}

     final String firstName =
    _formatWords(_firstNameController.text);

final String lastName =
    _formatWords(_lastNameController.text);

final String fullName =
    '$firstName $lastName'.trim();

final DocumentReference<Map<String, dynamic>>
    userReference = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid);

if (widget.isEditMode) {
  final Map<String, dynamic> updates = {
    'name': fullName,
    'age': int.tryParse(
      _ageController.text.trim(),
    ),
    'gender': _selectedGender,
    'city': _formatWords(
      _cityController.text,
    ),
  };

  if (_profileImageFile != null &&
      profileImageUrl != null) {
    updates['profilePhotoUrl'] =
        profileImageUrl;
  }

  await userReference.update(updates);
} else {
  final UserProfile userProfile =
      UserProfile(
    uid: user.uid,
    name: fullName,
    age: int.tryParse(
      _ageController.text.trim(),
    ),
    gender: _selectedGender,
    city: _formatWords(
      _cityController.text,
    ),
   profilePhotoUrl: "",

pendingProfilePhotoUrl: profileImageUrl,

profileImageVerification: false,
  );

  await userReference.set(
    userProfile.toMap(),
    SetOptions(
      merge: true,
    ),
  );
}
     if (!mounted) return;

// ============================================================
// EDIT MODE
// ============================================================

if (widget.isEditMode) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Row(
        children: [
          Icon(
            Icons.check_circle_rounded,
            color: Colors.white,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Profile updated successfully!',
            ),
          ),
        ],
      ),
    ),
  );

  // Return to UserScreen.
  // UserScreen will refresh because its navigation method
  // awaits Navigator.push().
  Navigator.pop(context);

  return;
}

// ============================================================
// CREATE MODE
// ============================================================

ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(
    behavior: SnackBarBehavior.floating,
    content: Row(
      children: [
        Icon(
          Icons.check_circle_rounded,
          color: Colors.white,
        ),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            'Profile saved successfully!',
          ),
        ),
      ],
    ),
  ),
);

await _showProfileCompletionDialog();
    } catch (e) {
      debugPrint(
        'Error saving initial profile: $e',
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
  // PROFILE COMPLETION PERCENTAGE
  // ============================================================

  Future<double>
      _calculateProfileCompletionPercentage(
    String uid,
  ) async {
    try {
      final DocumentSnapshot<
              Map<String, dynamic>>
          document =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .get();

      if (!document.exists) {
        return 0.0;
      }

      final Map<String, dynamic>? data =
          document.data();

      if (data == null) {
        return 0.0;
      }

      final List<String> fields = [
        'name',
        'age',
        'gender',
        'city',
        'profilePhotoUrl',
        'occupation',
        'religion',
        'bio',
        'smokingHabit',
        'drinkingHabit',
        'foodPreference',
        'cleanlinessLevel',
        'socialPreferences',
        'petOwnership',
        'petTolerance',
        'guestsFrequency',
      ];

      int completedFields = 0;

      for (final String field in fields) {
        final dynamic value = data[field];

        if (value != null &&
            value.toString().trim().isNotEmpty) {
          completedFields++;
        }
      }

      return (completedFields / fields.length) *
          100;
    } catch (e) {
      debugPrint(
        'Error calculating profile completion: $e',
      );

      return 0.0;
    }
  }

  // ============================================================
  // PROFILE COMPLETION DIALOG
  // ============================================================

  Future<void> _showProfileCompletionDialog() async {
    final User? user =
        FirebaseAuth.instance.currentUser;

    double completionPercentage = 25;

    if (user != null) {
      completionPercentage =
          await _calculateProfileCompletionPercentage(
        user.uid,
      );
    }

    if (!mounted) return;

    final double progress =
        (completionPercentage / 100)
            .clamp(0.0, 1.0);

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
          ),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color:
                      kPrimaryColor.withOpacity(.15),
                  blurRadius: 35,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 90,
                    width: 90,
                    decoration: BoxDecoration(
                      gradient: kPrimaryGradient,
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
                      Icons.celebration_rounded,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    '🎉 Profile Created',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: kDarkText,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Your profile is now live and ready to '
                    'start matching with potential flatmates.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: kMediumText,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 24),

                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color:
                          kPrimaryColor.withOpacity(.06),
                      borderRadius:
                          BorderRadius.circular(18),
                      border: Border.all(
                        color:
                            kPrimaryColor.withOpacity(.10),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.auto_graph_rounded,
                              color: kPrimaryColor,
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
                              BorderRadius.circular(20),
                          child:
                              LinearProgressIndicator(
                            value: progress,
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
                          '${completionPercentage.toStringAsFixed(0)}% Complete',
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
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color:
                          kSuccessColor.withOpacity(.08),
                      borderRadius:
                          BorderRadius.circular(16),
                      border: Border.all(
                        color: kSuccessColor
                            .withOpacity(.12),
                      ),
                    ),
                    child: const Column(
                      children: [
                        _DialogBenefitRow(
                          text:
                              'Get better flatmate recommendations',
                        ),
                        SizedBox(height: 10),
                        _DialogBenefitRow(
                          text:
                              'Increase your profile visibility',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: kPrimaryGradient,
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

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const CompleteUserProfileScreen(),
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
                              BorderRadius.circular(18),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Text(
                            'Complete Profile',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons
                                .arrow_forward_rounded,
                            color: Colors.white,
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
          // PREMIUM HEADER BACKGROUND

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

          // DECORATIVE HEADER CIRCLES

          Positioned(
            top: -60,
            right: -50,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    Colors.white.withOpacity(.06),
              ),
            ),
          ),

          Positioned(
            top: 105,
            left: -70,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    Colors.white.withOpacity(.05),
              ),
            ),
          ),

          SafeArea(
            child: (_isLoading || _isLoadingProfile)
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
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        // BACK BUTTON

                       


                        // HEADER

                        Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.center,
                          children: [
                            Expanded(
  child: Column(
    crossAxisAlignment:
        CrossAxisAlignment.start,
    children: [
      Text(
        widget.isEditMode
            ? 'Update Profile'
            : 'Create Profile',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 30,
          fontWeight: FontWeight.w800,
          letterSpacing: -.5,
        ),
      ),

      const SizedBox(height: 5),

      Text(
        widget.isEditMode
            ? 'Update your basic profile information'
            : 'Tell us a little about yourself',
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
  ),
),
                            Container(
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 13,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
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
  mainAxisSize: MainAxisSize.min,
  children: [
    Icon(
      widget.isEditMode
          ? Icons.edit_rounded
          : Icons.looks_one_rounded,
      color: Colors.white,
      size: 16,
    ),

    const SizedBox(width: 5),

    Text(
      widget.isEditMode
          ? 'Basic Profile'
          : 'Step 1 of 3',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    ),
  ],
),
                            ),
                          ],
                        ),

                        const SizedBox(height: 25),

                        // FORM CARD

                        Container(
                          padding:
                              const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: kCardColor,
                            borderRadius:
                                BorderRadius.circular(28),
                            border: Border.all(
                              color: Colors.white,
                            ),
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
                              children: [
                                _buildProfileImagePicker(),

                                const SizedBox(
                                  height: 28,
                                ),

                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  children: [
                                    Expanded(
                                      child:
                                          _buildTextFormField(
                                        controller:
                                            _firstNameController,
                                        label:
                                            'First Name',
                                        icon: Icons
                                            .person_outline_rounded,
                                        textCapitalization: TextCapitalization.words,
                                        validator:
                                            (value) {
                                          if (value ==
                                                  null ||
                                              value
                                                  .trim()
                                                  .isEmpty) {
                                            return 'Required';
                                          }

                                          return null;
                                        },
                                      ),
                                    ),

                                    const SizedBox(
                                      width: 12,
                                    ),

                                    Expanded(
                                      child:
                                          _buildTextFormField(
                                        controller:
                                            _lastNameController,
                                        label:
                                            'Last Name',
                                        icon: Icons
                                            .person_outline_rounded,
                                        textCapitalization: TextCapitalization.words,
                                        validator:
                                            (value) {
                                          if (value ==
                                                  null ||
                                              value
                                                  .trim()
                                                  .isEmpty) {
                                            return 'Required';
                                          }

                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(
                                  height: 18,
                                ),

                                _buildTextFormField(
                                  controller:
                                      _ageController,
                                  label: 'Age',
                                  icon:
                                      Icons.cake_rounded,
                                  keyboardType:
                                      TextInputType
                                          .number,
                                  validator:
                                      (value) {
                                    if (value ==
                                            null ||
                                        value
                                            .trim()
                                            .isEmpty) {
                                      return 'Please enter your age';
                                    }

                                    final int? age =
                                        int.tryParse(
                                      value.trim(),
                                    );

                                    if (age == null) {
                                      return 'Enter valid age';
                                    }

                                    if (age < 18) {
                                      return 'You must be at least 18';
                                    }

                                    if (age > 100) {
                                      return 'Enter valid age';
                                    }

                                    return null;
                                  },
                                ),

                                const SizedBox(
                                  height: 18,
                                ),

                                _buildGenderDropdown(),

                                const SizedBox(
                                  height: 18,
                                ),

                                _buildTextFormField(
                                  controller:
                                      _cityController,
                                  label: 'HomeTown',
                                  icon: Icons
                                      .location_on_rounded,
                                  textCapitalization: TextCapitalization.words,
                                  validator:
                                      (value) {
                                    if (value ==
                                            null ||
                                        value
                                            .trim()
                                            .isEmpty) {
                                      return 'Please enter your city';
                                    }

                                    return null;
                                  },
                                ),

                                const SizedBox(
                                  height: 30,
                                ),

                                _buildContinueButton(),
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

  // ============================================================
  // PROFILE IMAGE PICKER
  // ============================================================

  Widget _buildProfileImagePicker() {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 132,
                width: 132,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: kPrimaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color:
                          kAccentColor.withOpacity(.25),
                      blurRadius: 22,
                      offset:
                          const Offset(0, 10),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(4),
                child: Container(
                  decoration:
                      const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  padding:
                      const EdgeInsets.all(3),
                  child: ClipOval(
                    child: _profileImageFile != null

    // NEW IMAGE SELECTED FROM GALLERY
    ? Image.file(
        _profileImageFile!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      )

    // EXISTING FIREBASE PROFILE IMAGE
    : _existingProfileImageUrl != null
        ? Image.network(
            _existingProfileImageUrl!,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,

            loadingBuilder: (
              context,
              child,
              loadingProgress,
            ) {
              if (loadingProgress == null) {
                return child;
              }

              return const Center(
                child: CircularProgressIndicator(
                  color: kPrimaryColor,
                  strokeWidth: 2.5,
                ),
              );
            },

            errorBuilder: (
              context,
              error,
              stackTrace,
            ) {
              return Container(
                color: kBackgroundColor,
                child: const Icon(
                  Icons.person_rounded,
                  size: 70,
                  color: kLightText,
                ),
              );
            },
          )

        // NO PROFILE IMAGE
        : Container(
            color: kBackgroundColor,
            child: const Icon(
              Icons.person_rounded,
              size: 70,
              color: kLightText,
            ),
          ),
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: 3,
              right: -3,
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    gradient:
                        kPrimaryGradient,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: kAccentColor
                            .withOpacity(.25),
                        blurRadius: 12,
                        offset:
                            const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        Text(
  widget.isEditMode
      ? 'Update Profile Photo'
      : 'Upload Profile Photo',
  style: const TextStyle(
    color: kDarkText,
    fontSize: 18,
    fontWeight: FontWeight.w800,
  ),
),

        const SizedBox(height: 5),

        const Text(
          'Profiles with photos get more matches',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: kMediumText,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TEXT FORM FIELD
  // ============================================================

Widget _buildTextFormField({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  required String? Function(String?) validator,
  TextInputType keyboardType = TextInputType.text,
  TextCapitalization textCapitalization =
      TextCapitalization.none,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    textCapitalization: textCapitalization,
    validator: validator,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: kDarkText,
      ),
      decoration: InputDecoration(
        hintText: label,
        hintStyle: const TextStyle(
          color: kLightText,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Container(
          margin: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            gradient: kPrimaryGradient,
            borderRadius:
                BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color:
                    kPrimaryColor.withOpacity(.12),
                blurRadius: 8,
                offset:
                    const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 19,
          ),
        ),
        filled: true,
        fillColor: kBackgroundColor,
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 19,
        ),
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: kBorderColor,
            width: 1.2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: kPrimaryColor,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: kErrorColor,
            width: 1.5,
          ),
        ),
        focusedErrorBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: kErrorColor,
            width: 2,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // GENDER SELECTOR
  // ============================================================

  Widget _buildGenderDropdown() {
    const List<String> genders = [
      'Male',
      'Female',
      'Other',
    ];

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4),
          child: Text(
            'Gender',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: kDarkText,
            ),
          ),
        ),

        const SizedBox(height: 12),

        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: genders.map(
            (gender) {
              final bool isSelected =
                  _selectedGender == gender;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedGender = gender;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(
                    milliseconds: 220,
                  ),
                  curve: Curves.easeOut,
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 18,
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
                                  .withOpacity(.22),
                              blurRadius: 12,
                              offset:
                                  const Offset(0, 5),
                            ),
                          ]
                        : [],
                  ),
                  child: Row(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      Icon(
                        gender == 'Male'
                            ? Icons.male_rounded
                            : gender == 'Female'
                                ? Icons
                                    .female_rounded
                                : Icons
                                    .transgender_rounded,
                        size: 18,
                        color: isSelected
                            ? Colors.white
                            : kMediumText,
                      ),

                      const SizedBox(width: 7),

                      Text(
                        gender,
                        style: TextStyle(
                          fontWeight:
                              FontWeight.w700,
                          color: isSelected
                              ? Colors.white
                              : kDarkText,
                        ),
                      ),

                      if (isSelected) ...[
                        const SizedBox(width: 7),
                        const Icon(
                          Icons
                              .check_circle_rounded,
                          size: 17,
                          color: Colors.white,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ).toList(),
        ),
      ],
    );
  }

  // ============================================================
  // CONTINUE BUTTON
  // ============================================================

  Widget _buildContinueButton() {
    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        gradient: kPrimaryGradient,
        borderRadius:
            BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color:
                kPrimaryColor.withOpacity(.30),
            blurRadius: 20,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading
            ? null
            : _saveInitialProfile,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.transparent,
          disabledBackgroundColor:
              Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(18),
          ),
        ),
        child: Row(
  mainAxisAlignment:
      MainAxisAlignment.center,
  children: [
    Text(
      widget.isEditMode
          ? 'Save Changes'
          : 'Continue',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w800,
      ),
    ),

    const SizedBox(width: 8),

    Icon(
      widget.isEditMode
          ? Icons.check_rounded
          : Icons.arrow_forward_rounded,
      color: Colors.white,
    ),
  ],
),
      ),
    );
  }
}

// ============================================================
// DIALOG BENEFIT ROW
// ============================================================

class _DialogBenefitRow extends StatelessWidget {
  final String text;

  const _DialogBenefitRow({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
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
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}