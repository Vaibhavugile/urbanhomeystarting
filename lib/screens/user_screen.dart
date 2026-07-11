import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mytennat/data/user_profile.dart';
import 'package:mytennat/screens/complete_user_profile_screen.dart' hide kBackgroundColor,
         kPrimaryColor,
         kAccentColor,
         kPrimaryGradient,
         kErrorColor,
         kDarkText,
         kOnlineColor,
         kMediumText;
import 'package:mytennat/screens/my_listings_screen.dart';
import 'package:mytennat/screens/view_profile_screen.dart';
import 'package:mytennat/screens/verification_screen.dart';
import 'package:mytennat/services/account_deletion_service.dart';
import 'package:mytennat/screens/login_screen.dart'  hide kBackgroundColor,
         kPrimaryColor,
         kAccentColor,
         kPrimaryGradient,
         kErrorColor,
         kDarkText,
         kOnlineColor,
         kMediumText;
import 'package:mytennat/screens/initial_profile_screen.dart'hide kBackgroundColor,
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
  bool _isGuest = false;
  bool _showAdditionalData = false;
  double _completionPercentage = 0.0;
String _verificationStatus = 'Not Verified';
final TextEditingController _deleteController =
    TextEditingController();
bool _isVerified = false;
bool _isDeletingAccount = false;
  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

@override
void dispose() {
  _deleteController.dispose();
  super.dispose();
}
 Future<void> _fetchUserProfile() async {
  final user = FirebaseAuth.instance.currentUser;

  // No Firebase user
  if (user == null) {
    if (!mounted) return;

    setState(() {
      _isGuest = true;
      _userProfile = null;
      _isLoading = false;
    });

    return;
  }

  // Guest / Anonymous Firebase user
  if (user.isAnonymous) {
    if (!mounted) return;

    setState(() {
      _isGuest = true;
      _userProfile = null;
      _isLoading = false;
    });

    return;
  }

  try {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!mounted) return;

    // Logged-in user, but profile document does not exist
    if (!docSnapshot.exists || docSnapshot.data() == null) {
      setState(() {
        _isGuest = false;
        _userProfile = null;
        _isLoading = false;
      });

      return;
    }

    final data = docSnapshot.data()!;

    _userProfile = UserProfile.fromMap(
      data,
      docSnapshot.id,
    );

    _isVerified = data['isVerified'] == true;

    final status = data['verificationStatus'];

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

    if (!mounted) return;

    setState(() {
      _isGuest = false;
      _isLoading = false;
    });
  } catch (e, stackTrace) {
    debugPrint('Error fetching user profile: $e');
    debugPrintStack(stackTrace: stackTrace);

    if (!mounted) return;

    setState(() {
      _userProfile = null;
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
  Future<void> _navigateToInitialProfile() async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const InitialProfileScreen(
        isEditMode: true,
      ),
    ),
  );

  if (!mounted) return;

  setState(() {
    _isLoading = true;
  });

  await _fetchUserProfile();
}

  Future<void> _navigateToUpdateProfile() async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const CompleteUserProfileScreen(),
    ),
  );

  if (!mounted) return;

  setState(() {
    _isLoading = true;
  });

  await _fetchUserProfile();
}
Future<void> _showDeleteAccountDialog() async {
  _deleteController.clear();

  bool canDelete = false;
  bool isDeleting = false;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return PopScope(
            canPop: !isDeleting,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SafeArea(
                top: false,
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.fromLTRB(
                    22,
                    12,
                    22,
                    22,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.14),
                        blurRadius: 32,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Top handle
                        Container(
                          width: 44,
                          height: 5,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),

                        const SizedBox(height: 22),

                        // Premium delete icon
                        Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF7C3AED),
                                Color(0xFFEC4899),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFEC4899)
                                    .withOpacity(.25),
                                blurRadius: 24,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.delete_forever_rounded,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          'Delete Account?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
                          ),
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          'Deleting your UrbanHomey account will permanently remove your account and associated data.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.5,
                            color: Color(0xFF64748B),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Data removal information
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: const Column(
                            children: [
                              _DeleteDataRow(
                                icon: Icons.person_outline_rounded,
                                label: 'Your profile',
                              ),
                              SizedBox(height: 12),
                              _DeleteDataRow(
                                icon: Icons.home_work_outlined,
                                label: 'Flat listings',
                              ),
                              SizedBox(height: 12),
                              _DeleteDataRow(
                                icon: Icons.people_outline_rounded,
                                label: 'Flatmate profiles',
                              ),
                              SizedBox(height: 12),
                              _DeleteDataRow(
                                icon: Icons.image_outlined,
                                label: 'Photos',
                              ),
                              SizedBox(height: 12),
                              _DeleteDataRow(
                                icon: Icons.manage_accounts_outlined,
                                label: 'Account information',
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Warning
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF1F2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFFECACA),
                            ),
                          ),
                          child: const Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: Color(0xFFDC2626),
                                size: 22,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'This action is permanent and cannot be undone.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    height: 1.4,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFB91C1C),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Type DELETE to confirm',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF334155),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // DELETE confirmation field
                        TextField(
                          controller: _deleteController,
                          enabled: !isDeleting,
                          textCapitalization: TextCapitalization.characters,
                          onChanged: (value) {
                            setModalState(() {
                              canDelete = value.trim() == 'DELETE';
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'DELETE',
                            prefixIcon: const Icon(
                              Icons.lock_outline_rounded,
                              color: Color(0xFF7C3AED),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 17,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: canDelete
                                    ? const Color(0xFF7C3AED)
                                    : const Color(0xFFE2E8F0),
                                width: canDelete ? 1.5 : 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: Color(0xFF7C3AED),
                                width: 1.8,
                              ),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: Color(0xFFE2E8F0),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 22),

                        // Delete button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: canDelete && !isDeleting
                                  ? const LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        Color(0xFF7C3AED),
                                        Color(0xFFEC4899),
                                      ],
                                    )
                                  : const LinearGradient(
                                      colors: [
                                        Color(0xFFCBD5E1),
                                        Color(0xFFCBD5E1),
                                      ],
                                    ),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: canDelete && !isDeleting
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFFEC4899)
                                            .withOpacity(.20),
                                        blurRadius: 18,
                                        offset: const Offset(0, 8),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: ElevatedButton(
                              onPressed: canDelete && !isDeleting
                                  ? () async {
                                      setModalState(() {
                                        isDeleting = true;
                                      });

                                      // Keep your existing state synchronized
                                      if (mounted) {
                                        setState(() {
                                          _isDeletingAccount = true;
                                        });
                                      }

                                      try {
                                        await AccountDeletionService
                                            .deleteUserDocument();

                                        if (!mounted) return;

                                        if (sheetContext.mounted) {
                                          Navigator.pop(sheetContext);
                                        }

                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Your account has been deleted.',
                                            ),
                                          ),
                                        );

                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const LoginScreen(),
                                          ),
                                          (route) => false,
                                        );
                                      } catch (e) {
                                        if (!mounted) return;

                                        setModalState(() {
                                          isDeleting = false;
                                        });

                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(e.toString()),
                                          ),
                                        );
                                      } finally {
                                        if (mounted) {
                                          setState(() {
                                            _isDeletingAccount = false;
                                          });
                                        }
                                      }
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                disabledBackgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                disabledForegroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: isDeleting
                                  ? const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Text(
                                          'Deleting Account...',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    )
                                  : const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.delete_forever_rounded,
                                          size: 21,
                                        ),
                                        SizedBox(width: 9),
                                        Text(
                                          'Permanently Delete Account',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Cancel
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: TextButton(
                            onPressed: isDeleting
                                ? null
                                : () {
                                    Navigator.pop(sheetContext);
                                  },
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF475569),
                              backgroundColor: const Color(0xFFF8FAFC),
                              disabledForegroundColor:
                                  const Color(0xFF94A3B8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                                side: const BorderSide(
                                  color: Color(0xFFE2E8F0),
                                ),
                              ),
                            ),
                            child: const Text(
                              'Keep My Account',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
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
    : _isGuest
        ? _buildGuestProfilePage()
        : _userProfile == null
            ? _buildMissingProfilePage()
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
  child: Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: _navigateToInitialProfile,

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 30),

          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(100),
            ),
            child:
                _userProfile!.profilePhotoUrl != null &&
                        _userProfile!
                            .profilePhotoUrl!
                            .isNotEmpty
                    ? CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(
                          _userProfile!.profilePhotoUrl!,
                        ),
                      )
                    : const CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: Color(0xFF7C3AED),
                        ),
                      ),
          ),

          const SizedBox(height: 14),

          Text(
            _userProfile!.name ?? "User",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
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
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.18),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.verified,
                  color: Colors.white,
                  size: 16,
                ),

                const SizedBox(width: 6),

                Text(
                  "${_completionPercentage.toStringAsFixed(0)}% Complete",
                  style: const TextStyle(
                    color: Colors.white,
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
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding:
                          const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Material(
  color: Colors.transparent,
  child: InkWell(
    borderRadius: BorderRadius.circular(24),

    // OPEN UPDATE PROFILE SCREEN
    onTap: _navigateToUpdateProfile,

    child: Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // ====================================================
          // TITLE
          // ====================================================

          const Text(
            "Profile Completion",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 14),

          // ====================================================
          // PROGRESS BAR
          // ====================================================

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: _completionPercentage / 100,
              minHeight: 10,
              backgroundColor:
                  const Color(0xFFE5E7EB),
              color: const Color(0xFF7C3AED),
            ),
          ),

          const SizedBox(height: 10),

          // ====================================================
          // COMPLETION PERCENTAGE
          // ====================================================

          Text(
            "${_completionPercentage.toStringAsFixed(0)}% profile completed",
            style: const TextStyle(
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    ),
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
    final confirm = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.fromLTRB(
              22,
              12,
              22,
              22,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
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
                // Bottom sheet handle
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),

                const SizedBox(height: 24),

                // Premium icon
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF7C3AED),
                        Color(0xFFEC4899),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7C3AED)
                            .withOpacity(.25),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Sign Out?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Are you sure you want to sign out of your UrbanHomey account?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Color(0xFF64748B),
                  ),
                ),

                const SizedBox(height: 26),

                // Sign Out button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Color(0xFF7C3AED),
                          Color(0xFFEC4899),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7C3AED)
                              .withOpacity(.20),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(sheetContext, true);
                      },
                      icon: const Icon(
                        Icons.logout_rounded,
                        size: 20,
                      ),
                      label: const Text(
                        'Yes, Sign Out',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Cancel button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(sheetContext, false);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF475569),
                      backgroundColor: const Color(0xFFF8FAFC),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                        side: const BorderSide(
                          color: Color(0xFFE2E8F0),
                        ),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirm != true) return;

    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
  },
),

const SizedBox(height: 12),

_buildActionButton(
  label: 'Request Account Deletion',
  icon: Icons.delete_forever_rounded,
  onPressed: () {
  _showDeleteAccountDialog();
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
Widget _buildGuestProfilePage() {
  return SafeArea(
    child: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(
            maxWidth: 500,
          ),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.06),
                blurRadius: 24,
                offset: const Offset(0, 10),
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
                  color: const Color(0xFFF5F3FF),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  size: 48,
                  color: Color(0xFF7C3AED),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Guest Profile',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Sign in or create an account to create your profile, manage listings, access matches, and use all UrbanHomey features.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Color(0xFF64748B),
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();

                    if (!mounted) return;

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(
                      double.infinity,
                      56,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'Sign In or Create Account',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Continue as Guest',
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
Widget _buildMissingProfilePage() {
  return SafeArea(
    child: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(
            maxWidth: 500,
          ),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.06),
                blurRadius: 24,
                offset: const Offset(0, 10),
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
                  color: const Color(0xFFF5F3FF),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Icon(
                  Icons.account_circle_outlined,
                  size: 50,
                  color: Color(0xFF7C3AED),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Complete Your Profile',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Your account is active, but your profile information has not been completed yet.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Color(0xFF64748B),
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _navigateToUpdateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(
                      double.infinity,
                      56,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'Complete Profile',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Back to Home'),
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
      statusIcon = Icons.verified_user_outlined;
  }

  return Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(24),

      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const VerificationScreen(),
          ),
        );

        // Refresh verification status after returning
        if (!mounted) return;

        setState(() {
          _isLoading = true;
        });

        await _fetchUserProfile();
      },

      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                statusIcon,
                color: statusColor,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Identity Verification',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    _verificationStatus,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _verificationStatus == 'Verified'
                    ? Icons.check_rounded
                    : Icons.arrow_forward_ios_rounded,
                size: 16,
                color: statusColor,
              ),
            ),
          ],
        ),
      ),
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
class _DeleteDataRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DeleteDataRow({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F3FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 18,
            color: const Color(0xFF7C3AED),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
            ),
          ),
        ),
      ],
    );
  }
}