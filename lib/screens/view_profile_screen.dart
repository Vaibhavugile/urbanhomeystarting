// lib/screens/view_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mytennat/widgets/profile_display_widgets.dart';
import 'package:mytennat/screens/flatmate_profile_screen.dart';
import 'package:mytennat/screens/flat_with_flatmate_profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewProfileScreen extends StatefulWidget {
  final String? userId;
  // Add an optional profileDocumentId to allow direct linking to a specific sub-profile
  final String? profileDocumentId; // NEW

  const ViewProfileScreen({super.key, this.userId, this.profileDocumentId}); // MODIFIED

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  dynamic _userProfile;
  String? _userType;
  bool _isLoading = true;
  String? _errorMessage;

  List<FlatListingProfile> _flatListingProfiles = [];
  List<SeekingFlatmateProfile> _seekingFlatmateProfiles = [];
  String? _currentDisplayProfileId;

  static const String _lastSelectedProfileKey = 'lastSelectedProfileId_';

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _userProfile = null;
      _userType = null;
      _flatListingProfiles = [];
      _seekingFlatmateProfiles = [];
      _currentDisplayProfileId = null;
    });

    final User? currentUser = FirebaseAuth.instance.currentUser;
    final String? targetUserId = widget.userId ?? currentUser?.uid;

    print('[_fetchUserProfile] Target User ID: $targetUserId');

    if (targetUserId == null) {
      setState(() {
        _errorMessage = 'User ID not available. Please log in or provide a user ID.';
        _isLoading = false;
      });
      return;
    }

    try {
      final userDocRef = FirebaseFirestore.instance.collection('users').doc(targetUserId);

      final flatListingsSnapshot = await userDocRef.collection('flatListings').get();
      _flatListingProfiles = flatListingsSnapshot.docs
          .map((doc) => FlatListingProfile.fromMap(doc.data(), doc.id))
          .toList();
      print('[_fetchUserProfile] Fetched Flat Listing Profiles: ${_flatListingProfiles.length}');
      for (var p in _flatListingProfiles) {
        print('  - Flat Listing ID: ${p.documentId}, Owner Name: ${p.userProfile.name}');
      }

      final seekingFlatmateProfilesSnapshot = await userDocRef.collection('seekingFlatmateProfiles').get();
      _seekingFlatmateProfiles = seekingFlatmateProfilesSnapshot.docs
          .map((doc) => SeekingFlatmateProfile.fromMap(doc.data(), doc.id))
          .toList();
      print('[_fetchUserProfile] Fetched Seeking Flatmate Profiles: ${_seekingFlatmateProfiles.length}');
      for (var p in _seekingFlatmateProfiles) {
        print('  - Seeking Flatmate ID: ${p.documentId}, Name: ${p.userProfile.name}');
      }

      // --- Logic to prioritize displaying the specific profileDocumentId if provided ---
      bool profileFoundAndSet = false;
      if (widget.profileDocumentId != null) { // NEW: Check if profileDocumentId is provided
        print('[_fetchUserProfile] Specific profileDocumentId provided: ${widget.profileDocumentId}');
        try {
          final foundFlatListing = _flatListingProfiles.firstWhere(
                  (p) => p.documentId == widget.profileDocumentId,
              orElse: () => throw Exception('Not found'));
          _userProfile = foundFlatListing;
          _userType = 'flat_listing';
          _currentDisplayProfileId = widget.profileDocumentId;
          profileFoundAndSet = true;
          print('[_fetchUserProfile] Set initial display to provided Flat Listing ID: $_currentDisplayProfileId');
        } catch (_) {
          try {
            final foundSeekingFlatmate = _seekingFlatmateProfiles.firstWhere(
                    (p) => p.documentId == widget.profileDocumentId,
                orElse: () => throw Exception('Not found'));
            _userProfile = foundSeekingFlatmate;
            _userType = 'seeking_flatmate';
            _currentDisplayProfileId = widget.profileDocumentId;
            profileFoundAndSet = true;
            print('[_fetchUserProfile] Set initial display to provided Seeking Flatmate ID: $_currentDisplayProfileId');
          } catch (__) {
            print('[_fetchUserProfile] Provided profileDocumentId not found in fetched profiles.');
          }
        }
      }

      // --- Original logic to load last selected profile from SharedPreferences (if no specific ID provided) ---
      if (!profileFoundAndSet && currentUser != null) {
        final prefs = await SharedPreferences.getInstance();
        final lastSelectedId = prefs.getString(_lastSelectedProfileKey + currentUser.uid);
        print('[_fetchUserProfile] Last selected profile ID from preferences: $lastSelectedId');

        if (lastSelectedId != null) {
          try {
            final foundFlatListing = _flatListingProfiles.firstWhere(
                    (p) => p.documentId == lastSelectedId,
                orElse: () => throw Exception('Not found'));
            _userProfile = foundFlatListing;
            _userType = 'flat_listing';
            _currentDisplayProfileId = lastSelectedId;
            profileFoundAndSet = true;
            print('[_fetchUserProfile] Set initial display to last selected Flat Listing: $_currentDisplayProfileId');
          } catch (_) {
            try {
              final foundSeekingFlatmate = _seekingFlatmateProfiles.firstWhere(
                      (p) => p.documentId == lastSelectedId,
                  orElse: () => throw Exception('Not found'));
              _userProfile = foundSeekingFlatmate;
              _userType = 'seeking_flatmate';
              _currentDisplayProfileId = lastSelectedId;
              profileFoundAndSet = true;
              print('[_fetchUserProfile] Set initial display to last selected Seeking Flatmate: $_currentDisplayProfileId');
            } catch (__) {
              print('[_fetchUserProfile] Last selected profile ID not found in fetched profiles (or was invalid).');
            }
          }
        }
      }

      // If no specific profile or last selected profile was found, default to first available
      if (!profileFoundAndSet) {
        if (_flatListingProfiles.isNotEmpty) {
          _userProfile = _flatListingProfiles.first;
          _userType = 'flat_listing';
          _currentDisplayProfileId = _flatListingProfiles.first.documentId;
          print('[_fetchUserProfile] Default initial display: First Flat Listing - ID: $_currentDisplayProfileId');
        } else if (_seekingFlatmateProfiles.isNotEmpty) {
          _userProfile = _seekingFlatmateProfiles.first;
          _userType = 'seeking_flatmate';
          _currentDisplayProfileId = _seekingFlatmateProfiles.first.documentId;
          print('[_fetchUserProfile] Default initial display: First Seeking Flatmate - ID: $_currentDisplayProfileId');
        } else {
          _errorMessage = 'No profile found for user ID: $targetUserId. Profile might be incomplete or not created.';
          print('[_fetchUserProfile] Error: $_errorMessage');
        }
      }
    } catch (e) {
      _errorMessage = 'Error fetching profile for $targetUserId: ${e.toString()}';
      print('[_fetchUserProfile] Error fetching profile for $targetUserId: $e');
    } finally {
      setState(() {
        _isLoading = false;
        print('[_fetchUserProfile] Loading complete. _userType: $_userType, _currentDisplayProfileId: $_currentDisplayProfileId');
      });
    }
  }

  void _switchProfile(String profileIdentifier) async {
    print('[_switchProfile] Attempting to switch to: $profileIdentifier');
    setState(() {
      _isLoading = true;
    });

    String profileType;
    String profileId;

    if (profileIdentifier.startsWith('flat_listing_')) {
      profileType = 'flat_listing';
      profileId = profileIdentifier.substring('flat_listing_'.length);
    } else if (profileIdentifier.startsWith('seeking_flatmate_')) {
      profileType = 'seeking_flatmate';
      profileId = profileIdentifier.substring('seeking_flatmate_'.length);
    } else {
      print('[_switchProfile] Invalid profile identifier format: $profileIdentifier');
      setState(() {
        _errorMessage = 'Invalid profile selection.';
        _isLoading = false;
      });
      return;
    }

    print('[_switchProfile] Parsed - Type: $profileType, ID: $profileId');

    try {
      dynamic selectedProfile;
      if (profileType == 'flat_listing') {
        selectedProfile = _flatListingProfiles.firstWhere((p) => p.documentId == profileId);
        _userType = 'flat_listing';
      } else if (profileType == 'seeking_flatmate') {
        selectedProfile = _seekingFlatmateProfiles.firstWhere((p) => p.documentId == profileId);
        _userType = 'seeking_flatmate';
      }

      if (selectedProfile != null) {
        _userProfile = selectedProfile;
        _currentDisplayProfileId = profileId;

        final prefs = await SharedPreferences.getInstance();
        final User? currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          await prefs.setString(_lastSelectedProfileKey + currentUser.uid, profileId);
          print('[_switchProfile] Saved last selected profile ID: $profileId for user ${currentUser.uid}');
        }
        print('[_switchProfile] Switched to $profileType - ID: $_currentDisplayProfileId');
      } else {
        throw Exception('Profile not found after parsing.');
      }

      _errorMessage = null;
    } catch (e) {
      print('[_switchProfile] Error finding or setting profile with ID $profileId and type $profileType: $e');
      _errorMessage = 'Could not find the selected profile. It might have been deleted.';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('[build] Rebuilding ViewProfileScreen. IsLoading: $_isLoading, Error: $_errorMessage, UserType: $_userType');
   
return Scaffold(
  backgroundColor: kBackgroundColor,

  appBar: AppBar(
    automaticallyImplyLeading: true,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: true,
    backgroundColor: Colors.transparent,

    flexibleSpace: Container(
      decoration: const BoxDecoration(
        gradient: kPrimaryGradient,
      ),
    ),

    iconTheme: const IconThemeData(
      color: Colors.white,
      size: 24,
    ),

    title: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.userId == null
              ? 'My Profile'
              : 'User Profile',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -.5,
          ),
        ),

        Text(
          widget.userId == null
              ? 'Manage your profiles'
              : 'Explore profile',
          style: TextStyle(
            color: Colors.white.withOpacity(.85),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),

    actions: [
      if (widget.userId == null &&
          (_flatListingProfiles.isNotEmpty ||
              _seekingFlatmateProfiles.isNotEmpty))
        Container(
          margin: const EdgeInsets.only(
            right: 12,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.15),
            borderRadius: BorderRadius.circular(14),
          ),
          child: PopupMenuButton<String>(
            tooltip: "Switch Profile",
            offset: const Offset(0, 50),
            color: Colors.white,

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),

            icon: const Icon(
              Icons.swap_horiz_rounded,
              color: Colors.white,
            ),

            onSelected: _switchProfile,

            itemBuilder: (BuildContext context) {
              List<PopupMenuEntry<String>> items = [];

              if (_flatListingProfiles.isNotEmpty) {
                items.add(
                  const PopupMenuItem<String>(
                    enabled: false,
                    child: Text(
                      'Flat Listings',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );

                for (var profile
                    in _flatListingProfiles) {
                  final displayName =
                      (profile.userProfile.name != null &&
                              profile.userProfile.name
                                  .isNotEmpty)
                          ? profile.userProfile.name
                          : 'Flat Listing';

                  items.add(
                    PopupMenuItem<String>(
                      value:
                          'flat_listing_${profile.documentId}',
                      child: Row(
                        children: [
                          const Icon(
                            Icons.home_rounded,
                            color: kPrimaryColor,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(displayName),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              }

              if (_seekingFlatmateProfiles
                  .isNotEmpty) {
                items.add(
                  const PopupMenuDivider(),
                );

                items.add(
                  const PopupMenuItem<String>(
                    enabled: false,
                    child: Text(
                      'Seeking Flatmates',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );

                for (var profile
                    in _seekingFlatmateProfiles) {
                  final displayName =
                      (profile.userProfile.name != null &&
                              profile.userProfile.name
                                  .isNotEmpty)
                          ? profile.userProfile.name
                          : 'Seeking Flatmate';

                  items.add(
                    PopupMenuItem<String>(
                      value:
                          'seeking_flatmate_${profile.documentId}',
                      child: Row(
                        children: [
                          const Icon(
                            Icons.people_alt_rounded,
                            color: kAccentColor,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(displayName),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              }

              return items;
            },
          ),
        ),
    ],
  ),

  body: _isLoading
      ? const Center(
          child: CircularProgressIndicator(
            color: kPrimaryColor,
          ),
        )
      : _errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: kErrorColor
                            .withOpacity(.1),
                      ),
                      child: const Icon(
                        Icons.error_outline_rounded,
                        size: 45,
                        color: kErrorColor,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.w600,
                        color: kDarkText,
                      ),
                    ),

                    const SizedBox(height: 24),

                    ElevatedButton.icon(
                      onPressed:
                          _fetchUserProfile,
                      icon: const Icon(
                        Icons.refresh_rounded,
                      ),
                      label:
                          const Text('Retry'),
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            kPrimaryColor,
                        foregroundColor:
                            Colors.white,
                        elevation: 0,
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 28,
                          vertical: 14,
                        ),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : _userProfile == null
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'No profile data available.\nThis user may not have completed their profile yet.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: kMediumText,
                        fontWeight:
                            FontWeight.w500,
                      ),
                    ),
                  ),
                )
              : _userType == 'seeking_flatmate'
                  ? SeekingFlatmateProfileDisplay(
                      profile: _userProfile
                          as SeekingFlatmateProfile,
                    )
                  : FlatListingProfileDisplay(
                      profile: _userProfile
                          as FlatListingProfile,
                    ),
);


  }
}