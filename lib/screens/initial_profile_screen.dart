import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mytennat/data/user_profile.dart';
import 'package:mytennat/screens/complete_user_profile_screen.dart';
import 'package:mytennat/screens/home_page.dart';
import 'package:lottie/lottie.dart';
class InitialProfileScreen extends StatefulWidget {
  const InitialProfileScreen({Key? key}) : super(key: key);

  @override
  _InitialProfileScreenState createState() => _InitialProfileScreenState();
}

class _InitialProfileScreenState extends State<InitialProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  String _selectedGender = 'Male';
  File? _profileImageFile;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _profileImageFile = File(pickedFile.path);
      }
    });
  }

  Future<String?> _uploadImage(File imageFile, String uid) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child('profile_images').child('$uid.jpg');
      await storageRef.putFile(imageFile);
      return await storageRef.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  Future<void> _saveInitialProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("User not logged in.");
        setState(() {
          _isLoading = false;
        });
        return;
      }

      String? profileImageUrl;
      if (_profileImageFile != null) {
        profileImageUrl = await _uploadImage(_profileImageFile!, user.uid);
      }

      final userProfile = UserProfile(
        uid: user.uid,
        name: _nameController.text.trim(),
        age: int.tryParse(_ageController.text.trim()),
        gender: _selectedGender,
        city: _cityController.text.trim(),
        profilePhotoUrl: profileImageUrl,
      );

      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
          userProfile.toMap(),
          SetOptions(merge: true),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile saved successfully!')),
        );

        _showProfileCompletionDialog();
      } catch (e) {
        print("Error saving initial profile: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save profile: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // New function to calculate profile completion percentage
  Future<double> _calculateProfileCompletionPercentage(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (!doc.exists) {
        return 0.0;
      }

      final data = doc.data() as Map<String, dynamic>;

      // A list of all fields that contribute to profile completion
      final fields = [
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
      for (var field in fields) {
        if (data.containsKey(field) && data[field] != null && data[field].toString().isNotEmpty) {
          completedFields++;
        }
      }

      return (completedFields / fields.length) * 100;
    } catch (e) {
      print("Error calculating profile completion: $e");
      return 0.0;
    }
  }

  void _showProfileCompletionDialog() {
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
                  Icons.celebration_rounded,
                  color: Colors.white,
                  size: 48,
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                "🎉 Profile Created",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),

              const SizedBox(height: 10),

              Text(
                "Your profile is now live and ready to start matching with potential flatmates.",
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
                          const LinearProgressIndicator(
                        value: 0.25,
                        minHeight: 10,
                        backgroundColor:
                            Color(0xFFE5E7EB),
                        valueColor:
                            AlwaysStoppedAnimation(
                          Color(0xFFAD1457),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      "25% Complete",
                      style: TextStyle(
                        fontWeight:
                            FontWeight.w600,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green
                      .withOpacity(.08),
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
                            "Get better flatmate recommendations",
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
                            "Increase your profile visibility",
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

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const CompleteUserProfileScreen(),
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
                        "Complete Profile",
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
                          const HomePage(),
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
          height: 320,
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
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
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
                    horizontal: 24,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
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
                        ],
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        "Welcome 👋",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 6),

                      const Text(
                        "Create Your Profile",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        "Let's get you set up so we can find your perfect flatmate match.",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 24),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.15),
                          borderRadius:
                              BorderRadius.circular(18),
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.auto_graph,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "Profile Completion",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight:
                                        FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(
                                      20),
                              child:
                                  LinearProgressIndicator(
                                value: 0.25,
                                minHeight: 8,
                                backgroundColor:
                                    Colors.white24,
                                valueColor:
                                    const AlwaysStoppedAnimation(
                                  Colors.white,
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),

                            const Text(
                              "25% Complete",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      Container(
                        padding:
                            const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(
                                  28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withOpacity(.08),
                              blurRadius: 30,
                              offset:
                                  const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              _buildProfileImagePicker(),

                              const SizedBox(height: 24),

                              _buildTextFormField(
                                controller:
                                    _nameController,
                                label: 'Full Name',
                                icon: Icons.person,
                                validator:
                                    (value) {
                                  if (value ==
                                          null ||
                                      value
                                          .isEmpty) {
                                    return 'Please enter your name';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(
                                  height: 18),

                              _buildTextFormField(
                                controller:
                                    _ageController,
                                label: 'Age',
                                icon: Icons.cake,
                                keyboardType:
                                    TextInputType
                                        .number,
                                validator:
                                    (value) {
                                  if (value ==
                                          null ||
                                      value
                                          .isEmpty) {
                                    return 'Please enter your age';
                                  }

                                  if (int.tryParse(
                                          value) ==
                                      null) {
                                    return 'Enter valid age';
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(
                                  height: 18),

                              _buildGenderDropdown(),

                              const SizedBox(
                                  height: 18),

                              _buildTextFormField(
                                controller:
                                    _cityController,
                                label: 'Location',
                                icon: Icons
                                    .location_on,
                                validator:
                                    (value) {
                                  if (value ==
                                          null ||
                                      value
                                          .isEmpty) {
                                    return 'Please enter your city';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(
                                  height: 28),

                              Container(
                                padding:
                                    const EdgeInsets
                                        .all(16),
                                decoration:
                                    BoxDecoration(
                                  color: const Color(
                                          0xFF6A1B9A)
                                      .withOpacity(
                                          .06),
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                              16),
                                ),
                                child: const Column(
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons
                                              .check_circle,
                                          color: Colors
                                              .green,
                                        ),
                                        SizedBox(
                                            width:
                                                10),
                                        Expanded(
                                          child:
                                              Text(
                                            "Get better flatmate matches",
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                        height:
                                            10),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons
                                              .check_circle,
                                          color: Colors
                                              .green,
                                        ),
                                        SizedBox(
                                            width:
                                                10),
                                        Expanded(
                                          child:
                                              Text(
                                            "Increase profile visibility",
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                        height:
                                            10),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons
                                              .check_circle,
                                          color: Colors
                                              .green,
                                        ),
                                        SizedBox(
                                            width:
                                                10),
                                        Expanded(
                                          child:
                                              Text(
                                            "Connect faster with compatible people",
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(
                                  height: 28),

                              SizedBox(
                                width:
                                    double.infinity,
                                height: 58,
                                child:
                                    ElevatedButton(
                                  onPressed:
                                      _saveInitialProfile,
                                  style:
                                      ElevatedButton
                                          .styleFrom(
                                    elevation: 0,
                                    backgroundColor:
                                        const Color(
                                      0xFFAD1457,
                                    ),
                                    shape:
                                        RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(
                                              18),
                                    ),
                                  ),
                                  child:
                                      const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .center,
                                    children: [
                                      Text(
                                        "Continue",
                                        style:
                                            TextStyle(
                                          color:
                                              Colors.white,
                                          fontSize:
                                              18,
                                          fontWeight:
                                              FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(
                                          width:
                                              8),
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

  Widget _buildProfileImagePicker() {
  return Column(
    children: [
      Stack(
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 130,
              width: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF6A1B9A),
                    Color(0xFFAD1457),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFAD1457)
                        .withOpacity(.25),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(4),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: ClipOval(
                  child: _profileImageFile != null
                      ? Image.file(
                          _profileImageFile!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        )
                      : Container(
                          color: const Color(0xFFF8F9FC),
                          child: const Icon(
                            Icons.person,
                            size: 70,
                            color: Color(0xFFBDBDBD),
                          ),
                        ),
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 4,
            right: -4,
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF6A1B9A),
                      Color(0xFFAD1457),
                    ],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.15),
                      blurRadius: 10,
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

      const SizedBox(height: 14),

      const Text(
        "Upload Profile Photo",
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
      ),

      const SizedBox(height: 4),

      Text(
        "Profiles with photos get more matches",
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey.shade600,
        ),
      ),
    ],
  );
}

 Widget _buildTextFormField({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  required String? Function(String?) validator,
  TextInputType keyboardType = TextInputType.text,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    validator: validator,
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

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
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

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: Color(0xFFAD1457),
          width: 2,
        ),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 2,
        ),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 2,
        ),
      ),
    ),
  );
}

  Widget _buildGenderDropdown() {
  final genders = ['Male', 'Female', 'Other'];

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Padding(
        padding: EdgeInsets.only(left: 4),
        child: Text(
          'Gender',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
      ),

      const SizedBox(height: 12),

      Wrap(
        spacing: 12,
        runSpacing: 12,
        children: genders.map((gender) {
          final isSelected =
              _selectedGender == gender;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedGender = gender;
              });
            },
            child: AnimatedContainer(
              duration:
                  const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
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
                borderRadius:
                    BorderRadius.circular(16),
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
                          ).withOpacity(.25),
                          blurRadius: 12,
                          offset:
                              const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    gender == 'Male'
                        ? Icons.male_rounded
                        : gender == 'Female'
                            ? Icons.female_rounded
                            : Icons.transgender_rounded,
                    size: 18,
                    color: isSelected
                        ? Colors.white
                        : Colors.grey.shade700,
                  ),

                  const SizedBox(width: 8),

                  Text(
                    gender,
                    style: TextStyle(
                      fontWeight:
                          FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),

                  if (isSelected) ...[
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.check_circle,
                      size: 18,
                      color: Colors.white,
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    ],
  );
}
}