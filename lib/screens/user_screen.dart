import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mytennat/data/user_profile.dart';
import 'package:mytennat/screens/complete_user_profile_screen.dart';
import 'package:mytennat/screens/my_listings_screen.dart';
import 'package:mytennat/screens/view_profile_screen.dart';
import 'package:mytennat/screens/verification_screen.dart';
import 'package:mytennat/screens/login_screen.dart'  hide kBackgroundColor,
         kPrimaryColor,
         kAccentColor,
         kPrimaryGradient,
         kErrorColor,
         kDarkText,
         kOnlineColor,
         kMediumText;
class UserScreen extends StatefulWidget {
  const UserScreen({Key? key}) : super(key: key);

  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  UserProfile? _userProfile;
  bool _isLoading = true;
  bool _showAdditionalData = false;
  double _completionPercentage = 0.0;
String _verificationStatus = 'Not Verified';
bool _isVerified = false;
  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final docSnapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (docSnapshot.exists) {
       setState(() {
  _userProfile = UserProfile.fromMap(
    docSnapshot.data() as Map<String, dynamic>,
    docSnapshot.id,
  );

  _isVerified =
      docSnapshot.data()?['isVerified'] ?? false;

  final status =
      docSnapshot.data()?['verificationStatus'];

  if (_isVerified) {
    _verificationStatus = 'Verified';
  } else if (status == 'pending') {
    _verificationStatus = 'Pending Review';
  } else if (status == 'rejected') {
    _verificationStatus = 'Rejected';
  } else {
    _verificationStatus = 'Not Verified';
  }

  _calculateCompletionPercentage();
  _isLoading = false;
});
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching user profile: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _calculateCompletionPercentage() {
    if (_userProfile == null) return;

    final List<dynamic?> allProfileFields = [
      _userProfile!.name,
      _userProfile!.age,
      _userProfile!.gender,
      _userProfile!.city,
      _userProfile!.profilePhotoUrl,
      _userProfile!.occupation,
      _userProfile!.religion,
      _userProfile!.bio,
      _userProfile!.smokingHabit,
      _userProfile!.drinkingHabit,
      _userProfile!.foodPreference,
      _userProfile!.cleanlinessLevel,
      _userProfile!.socialPreferences,
      _userProfile!.petOwnership,
      _userProfile!.petTolerance,
      _userProfile!.guestsFrequency,
    ];

    final double totalFields = allProfileFields.length.toDouble();
    int completedFields = 0;

    for (var field in allProfileFields) {
      if (field != null && field.toString().isNotEmpty) {
        completedFields++;
      }
    }

    setState(() {
      _completionPercentage = (completedFields / totalFields) * 100;
    });
  }

  void _navigateToUpdateProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CompleteUserProfileScreen(),
      ),
    );
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF8FAFC),
    body: _isLoading
        ? const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF7C3AED),
            ),
          )
        : _userProfile == null
            ? const Center(
                child: Text(
                  'Profile not found',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            : CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    expandedHeight: 320,
                    pinned: true,
                    backgroundColor: const Color(0xFF7C3AED),
                    elevation: 0,
                    centerTitle: true,
                    title: const Text(
                      "My Profile",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF7C3AED),
                              Color(0xFFEC4899),
                            ],
                          ),
                        ),
                        child: SafeArea(
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 30),

                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(100),
                                ),
                                child: _userProfile!
                                            .profilePhotoUrl !=
                                        null &&
                                    _userProfile!
                                        .profilePhotoUrl!
                                        .isNotEmpty
                                    ? CircleAvatar(
                                        radius: 50,
                                        backgroundImage:
                                            NetworkImage(
                                          _userProfile!
                                              .profilePhotoUrl!,
                                        ),
                                      )
                                    : const CircleAvatar(
                                        radius: 50,
                                        backgroundColor:
                                            Colors.white,
                                        child: Icon(
                                          Icons.person,
                                          size: 50,
                                          color: Color(
                                            0xFF7C3AED,
                                          ),
                                        ),
                                      ),
                              ),

                              const SizedBox(height: 14),

                              Text(
                                _userProfile!.name ??
                                    "User",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight:
                                      FontWeight.w800,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                "${_userProfile!.city ?? 'Unknown City'} • ${_userProfile!.occupation ?? 'Member'}",
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),

                              const SizedBox(height: 14),

                              Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white
                                      .withOpacity(.18),
                                  borderRadius:
                                      BorderRadius.circular(
                                          30),
                                ),
                                child: Row(
                                  mainAxisSize:
                                      MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.verified,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "${_completionPercentage.toStringAsFixed(0)}% Complete",
                                      style:
                                          const TextStyle(
                                        color: Colors.white,
                                        fontWeight:
                                            FontWeight.w600,
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
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding:
                          const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Container(
                            padding:
                                const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.circular(
                                      24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withOpacity(.05),
                                  blurRadius: 20,
                                  offset:
                                      const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                const Text(
                                  "Profile Completion",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight:
                                        FontWeight.w700,
                                  ),
                                ),

                                const SizedBox(
                                    height: 14),

                                ClipRRect(
                                  borderRadius:
                                      BorderRadius
                                          .circular(20),
                                  child:
                                      LinearProgressIndicator(
                                    value:
                                        _completionPercentage /
                                            100,
                                    minHeight: 10,
                                    backgroundColor:
                                        const Color(
                                            0xFFE5E7EB),
                                    color:
                                        const Color(
                                            0xFF7C3AED),
                                  ),
                                ),

                                const SizedBox(
                                    height: 10),

                                Text(
                                  "${_completionPercentage.toStringAsFixed(0)}% profile completed",
                                  style: const TextStyle(
                                    color: Color(
                                        0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),
                          _buildVerificationCard(),
                          const SizedBox(height: 20),
                          _buildActionButton(
  label: 'Update Profile',
  icon: Icons.edit_rounded,
  onPressed: _navigateToUpdateProfile,
),

const SizedBox(height: 12),

_buildActionButton(
  label: 'My Listings',
  icon: Icons.home_work_rounded,
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const MyListingsScreen(),
      ),
    );
  },
),
const SizedBox(height: 12),

_buildActionButton(
  label: 'Sign Out',
  icon: Icons.logout_rounded,
  onPressed: () async {

    final confirm =
        await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          'Sign Out',
        ),
        content: const Text(
          'Are you sure you want to sign out?',
        ),
        actions: [

          TextButton(
            onPressed: () {
              Navigator.pop(
                context,
                false,
              );
            },
            child: const Text(
              'Cancel',
            ),
          ),

          ElevatedButton(
            onPressed: () {
              Navigator.pop(
                context,
                true,
              );
            },
            child: const Text(
              'Sign Out',
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await FirebaseAuth.instance
        .signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const LoginScreen(),
      ),
      (route) => false,
    );
  },
),

const SizedBox(height: 12),

_buildActionButton(
  label: 'Request Account Deletion',
  icon: Icons.delete_forever_rounded,
  onPressed: () async {

    final user =
    FirebaseAuth.instance.currentUser;

await FirebaseFirestore.instance
    .collection(
        'accountDeletionRequests')
    .doc(user!.uid)
    .set({

  'userId': user.uid,

  'phoneNumber':
      user.phoneNumber,

  'status': 'pending',

  'createdAt':
      FieldValue.serverTimestamp(),
});

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(

      const SnackBar(
        content: Text(
          'Account deletion request submitted.',
        ),
      ),
    );
  },
),
const SizedBox(height: 12),

_buildActionButton(
  label: _showAdditionalData
      ? 'Hide Details'
      : 'View Details',
                            icon: _showAdditionalData
                                ? Icons.visibility_off
                                : Icons.visibility,
                            onPressed: () {
                              setState(() {
                                _showAdditionalData =
                                    !_showAdditionalData;
                              });
                            },
                          ),

                          if (_showAdditionalData)
                            ...[
                              const SizedBox(
                                  height: 20),
                              _buildProfileDetailCard(),
                            ],

                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
  );
}

Widget _buildActionButton({
  required String label,
  required IconData icon,
  required VoidCallback onPressed,
}) {
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 4),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFF1F5F9),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.04),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F3FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF7C3AED),
                  size: 22,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
              ),

              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
Widget _buildVerificationCard() {
  Color statusColor;
  IconData statusIcon;

  switch (_verificationStatus) {
    case 'Verified':
      statusColor = kOnlineColor;
      statusIcon = Icons.verified_rounded;
      break;

    case 'Pending Review':
      statusColor = Colors.orange;
      statusIcon = Icons.hourglass_top_rounded;
      break;

    case 'Rejected':
      statusColor = kErrorColor;
      statusIcon = Icons.cancel_rounded;
      break;

    default:
      statusColor = kPrimaryColor;
      statusIcon =
          Icons.verified_user_outlined;
  }

  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius:
          BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(.05),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Column(
      children: [

        Row(
          children: [

            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color:
                    statusColor.withOpacity(.1),
                borderRadius:
                    BorderRadius.circular(
                        16),
              ),
              child: Icon(
                statusIcon,
                color: statusColor,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [

                  const Text(
                    'Identity Verification',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    _verificationStatus,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const VerificationScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
  backgroundColor: kPrimaryColor,
  foregroundColor: Colors.white,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  ),
),

child: Text(
  _verificationStatus == 'Pending Review'
      ? 'View Submission'
      : _verificationStatus == 'Verified'
          ? 'Verified'
          : 'Start Verification',
  style: const TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 15,
  ),
),
          ),
        ),
      ],
    ),
  );
}

 Widget _buildProfileDetailCard() {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(.04),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.person_outline_rounded,
              color: Color(0xFF7C3AED),
            ),
            SizedBox(width: 10),
            Text(
              "Profile Details",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        _buildDetailTile(
          Icons.badge_outlined,
          "Occupation",
          _userProfile!.occupation,
        ),

        _buildDetailTile(
          Icons.menu_book_outlined,
          "Religion",
          _userProfile!.religion,
        ),

        _buildDetailTile(
          Icons.smoke_free_outlined,
          "Smoking Habit",
          _userProfile!.smokingHabit,
        ),

        _buildDetailTile(
          Icons.local_bar_outlined,
          "Drinking Habit",
          _userProfile!.drinkingHabit,
        ),

        _buildDetailTile(
          Icons.restaurant_outlined,
          "Food Preference",
          _userProfile!.foodPreference,
        ),

        _buildDetailTile(
          Icons.cleaning_services_outlined,
          "Cleanliness",
          _userProfile!.cleanlinessLevel,
        ),

        _buildDetailTile(
          Icons.people_outline_rounded,
          "Social Preferences",
          _userProfile!.socialPreferences,
        ),

        _buildDetailTile(
          Icons.pets_outlined,
          "Pet Ownership",
          _userProfile!.petOwnership,
        ),

        _buildDetailTile(
          Icons.favorite_border_rounded,
          "Pet Tolerance",
          _userProfile!.petTolerance,
        ),

        _buildDetailTile(
          Icons.groups_rounded,
          "Guests Frequency",
          _userProfile!.guestsFrequency,
        ),

        if (_userProfile!.bio != null &&
            _userProfile!.bio!.isNotEmpty) ...[
          const SizedBox(height: 20),

          const Text(
            "About Me",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),

          const SizedBox(height: 10),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _userProfile!.bio!,
              style: const TextStyle(
                color: Color(0xFF4B5563),
                height: 1.5,
              ),
            ),
          ),
        ],
      ],
    ),
  );
}
Widget _buildDetailTile(
  IconData icon,
  String title,
  String? value,
) {
  if (value == null || value.isEmpty) {
    return const SizedBox.shrink();
  }

  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F3FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF7C3AED),
            size: 20,
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

  
}