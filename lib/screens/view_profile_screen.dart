// lib/screens/view_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mytennat/widgets/profile_display_widgets.dart';
import 'package:mytennat/screens/flatmate_profile_screen.dart';
import 'package:mytennat/screens/flat_with_flatmate_profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/chat_unlock_service.dart';
import 'package:mytennat/screens/banner_popup_screen.dart'; // NEW: Import the banner popup screen
import 'package:mytennat/screens/PlansScreen.dart';
import 'package:mytennat/widgets/profile_action_menu.dart';
import 'package:mytennat/screens/chat_screen.dart'
    hide kBackgroundColor,
         kPrimaryColor,
         kAccentColor,
         kPrimaryGradient,
         kErrorColor,
         kDarkText,
         kMediumText;


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
String? _myProfileType;
String? _myProfileId;
bool _alreadyLiked = false;
bool _alreadyMatched = false;
bool _isBannerPopupShowing = false;

int _remainingContacts = 0;
bool _conversationUnlocked = false;
User? get _currentUser =>
    FirebaseAuth.instance.currentUser;
String? _existingChatRoomId;
final FirebaseFirestore _firestore =
    FirebaseFirestore.instance;
  static const String _lastSelectedProfileKey = 'lastSelectedProfileId_';

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }
String _getProfileDisplayName(
  dynamic profile,
) {

  if (profile is FlatListingProfile) {
    return profile.userProfile.name;
  }

  if (profile is SeekingFlatmateProfile) {
    return profile.userProfile.name;
  }

  return 'User';
}
String _getProfileTypeDisplay(
  dynamic profile,
) {

  if (profile is FlatListingProfile) {
    return 'flat_listing';
  }

  if (profile is SeekingFlatmateProfile) {
    return 'seeking_flatmate';
  }

  return '';
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

  _errorMessage =
      'Error fetching profile for $targetUserId: ${e.toString()}';

  print(
    '[_fetchUserProfile] Error fetching profile for $targetUserId: $e',
  );

}

await _determineMyProfileType();
await _checkLikeStatus();
await _determineMyProfileType();

await _loadRemainingContacts();

await _checkLikeStatus();

if (mounted) {

  setState(() {

    _isLoading = false;

    print(
      '[_fetchUserProfile] Loading complete. _userType: $_userType, _currentDisplayProfileId: $_currentDisplayProfileId',
    );
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
  Future<void> _checkLikeStatus() async {

  final currentUser =
      FirebaseAuth.instance.currentUser;

  if (currentUser == null ||
      widget.profileDocumentId == null) {
    return;
  }

  final likeDoc =
      await FirebaseFirestore.instance
          .collection('user_likes')
          .doc(currentUser.uid)
          .collection('likes')
          .doc(widget.profileDocumentId!)
          .get();

  if (likeDoc.exists) {

    _alreadyLiked = true;
  }

  if (_myProfileId != null) {

    List<String> ids = [
      _myProfileId!,
      widget.profileDocumentId!,
    ]..sort();

    final matchDocId =
        '${ids[0]}_${ids[1]}';

    final matchDoc =
        await FirebaseFirestore.instance
            .collection('matches')
            .doc(matchDocId)
            .get();

   if (matchDoc.exists) {

  _alreadyMatched = true;

  final data =
      matchDoc.data()
          as Map<String, dynamic>;

  _conversationUnlocked =
      data['conversationUnlocked'] ??
          false;

  _existingChatRoomId =
      data['chatRoomId'];

  print(
    'MATCH FOUND',
  );

  print(
    'CONVERSATION UNLOCKED = $_conversationUnlocked',
  );

  print(
    'CHAT ROOM ID = $_existingChatRoomId',
  );
}
  }

  if (mounted) {
    setState(() {});
  }
}

Future<void> _determineMyProfileType() async {

  final currentUser =
      FirebaseAuth.instance.currentUser;

  if (currentUser == null) return;

  if (_userType == 'flat_listing') {

    _myProfileType =
        'seeking_flatmate';

    final profiles =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .collection(
              'seekingFlatmateProfiles',
            )
            .limit(1)
            .get();

    if (profiles.docs.isNotEmpty) {

      _myProfileId =
          profiles.docs.first.id;
    }

  } else {

    _myProfileType =
        'flat_listing';

    final profiles =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .collection(
              'flatListings',
            )
            .limit(1)
            .get();

    if (profiles.docs.isNotEmpty) {

      _myProfileId =
          profiles.docs.first.id;
    }
  }

  print(
    'VIEWED PROFILE TYPE = $_userType',
  );

  print(
    'MY PROFILE TYPE = $_myProfileType',
  );

  print(
    'MY PROFILE ID = $_myProfileId',
  );
}

Future<void> _loadRemainingContacts() async {

  final currentUser =
      FirebaseAuth.instance.currentUser;

  if (currentUser == null) return;

  final userDoc =
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

  if (!userDoc.exists) return;

  _remainingContacts =
      userDoc.data()?[
          'remainingContacts'] ??
      0;

  print(
    'REMAINING CONTACTS = $_remainingContacts',
  );
}
Future<void> _processLike() async {

  final currentUser =
      FirebaseAuth.instance.currentUser;

  if (currentUser == null) {
    print(
      "_processLike: Current user is null.",
    );
    return;
  }

  final String currentUserId =
      currentUser.uid;

  final String currentUserProfileId =
      _myProfileId!;

  final String currentUserProfileType =
      _myProfileType!;

  final String likedUserId =
      widget.userId!;

  final String likedProfileDocumentId =
      widget.profileDocumentId!;

  final String likedUserProfileType =
      _userType!;

  try {

    print(
      "_processLike: Saving like...",
    );

    await _firestore
        .collection('user_likes')
        .doc(currentUserId)
        .collection('likes')
        .doc(likedProfileDocumentId)
        .set({

      'timestamp':
          FieldValue.serverTimestamp(),

      'likedUserId':
          likedUserId,

      'likedProfileDocumentId':
          likedProfileDocumentId,

      'likingUserProfileId':
          currentUserProfileId,

      'likingUserId':
          currentUserId,

      'likingUserProfileType':
          currentUserProfileType,

      'likedUserProfileType':
          likedUserProfileType,
    });

    print(
      "_processLike: Like saved.",
    );

    print(
      "_processLike: Checking mutual like...",
    );

    final otherUserLikesOurProfile =
        await _firestore
            .collection('user_likes')
            .doc(likedUserId)
            .collection('likes')
            .where(
              'likedUserId',
              isEqualTo:
                  currentUserId,
            )
            .where(
              'likedProfileDocumentId',
              isEqualTo:
                  currentUserProfileId,
            )
            .get();

    if (otherUserLikesOurProfile
        .docs
        .isNotEmpty) {

      print(
        "_processLike: MATCH FOUND",
      );

      await ChatUnlockService
          .createMatchAndChatRoom(

        currentUserId,

        currentUserProfileId,

        currentUserProfileType,

        likedUserId,

        likedProfileDocumentId,

        likedUserProfileType,
      );

      print(
        "_processLike: Match + Chat created",
      );

      final participants = [
        currentUserId,
        likedUserId,
      ]..sort();

      final chatRoomId =
          participants.join('_');

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(

        const SnackBar(
          content: Text(
            "It's a Match! 🎉",
          ),
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            chatRoomId:
                chatRoomId,
            chatPartnerId:
                likedUserId,
            chatPartnerName:
                _userProfile
                        ?.userProfile
                        .name ??
                    'User',
          ),
        ),
      );

    } else {

      print(
        "_processLike: No match yet",
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(

        const SnackBar(
          content: Text(
            "Profile Liked!",
          ),
        ),
      );
    }

  } catch (e) {

    print(
      "_processLike ERROR: $e",
    );

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(

      SnackBar(
        content: Text(
          e.toString(),
        ),
      ),
    );
  }
}
void _showOutOfContactsPopup() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => PlansScreen(),
    ),
  );
}
Future<void> _showBannerPopup(
  dynamic likedProfile,
  String myProfileId,
) {

  if (_isBannerPopupShowing) {
    return Future.value();
  }

  _isBannerPopupShowing = true;

  final String profileName =
      _getProfileDisplayName(
    likedProfile,
  );

  String? imageUrl;

  if (likedProfile
          is FlatListingProfile &&
      likedProfile.imageUrls != null &&
      likedProfile.imageUrls!
          .isNotEmpty) {

    imageUrl =
        likedProfile.imageUrls!.first;

  } else if (likedProfile
          is SeekingFlatmateProfile &&
      likedProfile.imageUrls != null &&
      likedProfile.imageUrls!
          .isNotEmpty) {

    imageUrl =
        likedProfile.imageUrls!.first;
  }

  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (
      BuildContext context,
    ) {

      return BannerPopupScreen(

  profileName: profileName,

  profileImageUrl: imageUrl,

  message:
      'You liked $profileName',

  subMessage:
      'Start a conversation instantly and unlock contact details.',

  buttonText:
      'Start Conversation',

  onButtonPressed: () async {
 final parentContext = this.context;
    Navigator.of(
      context,
    ).pop();

    setState(() {

      _isBannerPopupShowing =
          false;
    });
final bool? proceed =
    await showDialog<bool>(
  context: parentContext,
  builder: (context) {
    return Dialog(
  backgroundColor: Colors.transparent,
  insetPadding:
      const EdgeInsets.symmetric(
    horizontal: 24,
  ),

  child: Container(
    padding: const EdgeInsets.all(24),

    decoration: BoxDecoration(
      color: Colors.white,

      borderRadius:
          BorderRadius.circular(
        28,
      ),

      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(
            .12,
          ),
          blurRadius: 30,
          offset: const Offset(
            0,
            12,
          ),
        ),
      ],
    ),

    child: Column(
      mainAxisSize: MainAxisSize.min,

      children: [

        Container(
          width: 72,
          height: 72,

          decoration:
              const BoxDecoration(
            shape: BoxShape.circle,

            gradient:
                LinearGradient(
              colors: [
                Color(0xFF7C3AED),
                Color(0xFF9333EA),
                Color(0xFFEC4899),
              ],
            ),
          ),

          child: const Icon(
            Icons.chat_bubble_rounded,
            color: Colors.white,
            size: 34,
          ),
        ),

        const SizedBox(height: 20),

        const Text(
          'Start Conversation',
          style: TextStyle(
            fontSize: 24,
            fontWeight:
                FontWeight.w800,
            color: Color(
              0xFF111827,
            ),
          ),
        ),

        const SizedBox(height: 16),

        Container(
          width: double.infinity,

          padding:
              const EdgeInsets.all(
            16,
          ),

          decoration: BoxDecoration(
            color:
                const Color(
              0xFFF8FAFC,
            ),

            borderRadius:
                BorderRadius.circular(
              18,
            ),
          ),

          child: Column(
            children: [

              Text(
                _remainingContacts
                    .toString(),
                style:
                    const TextStyle(
                  fontSize: 34,
                  fontWeight:
                      FontWeight
                          .w900,
                  color: Color(
                    0xFF7C3AED,
                  ),
                ),
              ),

              const SizedBox(
                height: 4,
              ),

              const Text(
                'Contacts Remaining',
                style: TextStyle(
                  color: Color(
                    0xFF64748B,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        Text(
          _remainingContacts > 0
              ? 'Starting this conversation will use 1 contact.'
              : 'You have no contacts remaining.',
          textAlign:
              TextAlign.center,
          style: const TextStyle(
            fontSize: 15,
            height: 1.5,
            color: Color(
              0xFF64748B,
            ),
          ),
        ),

        const SizedBox(height: 24),

        Row(
          children: [

            Expanded(
              child: OutlinedButton(
               onPressed: () {

  if (_remainingContacts <= 0) {

    Navigator.pop(
      context,
      false,
    );

    Navigator.push(
      parentContext,
      MaterialPageRoute(
        builder: (_) =>
            const PlansScreen(),
      ),
    );

    return;
  }

  Navigator.pop(
    context,
    false,
  );
},

                style:
                    OutlinedButton.styleFrom(
                  minimumSize:
                      const Size(
                    0,
                    54,
                  ),

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
                  ),
                ),

                child: const Text(
                  'Cancel',
                ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                    true,
                  );
                },

                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(
                    0xFF7C3AED,
                  ),

                  foregroundColor:
                      Colors.white,

                  elevation: 0,

                  minimumSize:
                      const Size(
                    0,
                    54,
                  ),

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
                  ),
                ),

                child: Text(
                  _remainingContacts >
                          0
                      ? 'Continue'
                      : 'Get Contacts',
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  ),
);
  },
);

if (proceed != true) {
  return;
}
final sortedProfileIds = [
  myProfileId,
  likedProfile.documentId!,
]..sort();

final matchDocId =
    '${sortedProfileIds[0]}_${sortedProfileIds[1]}';

final matchDoc =
    await _firestore
        .collection('matches')
        .doc(matchDocId)
        .get();

if (matchDoc.exists) {

  final data =
      matchDoc.data()
          as Map<String, dynamic>;

  final bool alreadyUnlocked =
      data['conversationUnlocked'] ??
          false;

  if (alreadyUnlocked) {

    debugPrint(
      'CONVERSATION ALREADY UNLOCKED',
    );

    final String chatRoomId =
        data['chatRoomId'];

    final String partnerName =
        _getProfileDisplayName(
      likedProfile,
    );

    if (!mounted) return;

    Navigator.push(
      parentContext,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          chatRoomId:
              chatRoomId,
          chatPartnerId:
              likedProfile.uid,
          chatPartnerName:
              partnerName,
        ),
      ),
    );

    return;
  }
}
    // CHECK CONTACTS
    if (_remainingContacts <= 0) {

      _showOutOfContactsPopup();
      return;
    }

    try {

      // DEDUCT CONTACT
      await _firestore
          .collection('users')
          .doc(_currentUser!.uid)
          .update({
        'remainingContacts':
            FieldValue.increment(-1),
      });

      setState(() {

        _remainingContacts--;
      });

      debugPrint(
        'CONTACT DEDUCTED. REMAINING = $_remainingContacts',
      );

      // CREATE CHAT ROOM / MATCH
      await ChatUnlockService
    .createMatchAndChatRoom(

  _currentUser!.uid,

  myProfileId,

  _getProfileTypeDisplay(
              likedProfile) ==
          'flat_listing'
      ? 'seeking_flatmate'
      : 'flat_listing',

  likedProfile.uid,

  likedProfile.documentId!,

  _getProfileTypeDisplay(
      likedProfile),
);
      final sortedProfileIds = [
  myProfileId,
  likedProfile.documentId!,
]..sort();

final matchDocId =
    '${sortedProfileIds[0]}_${sortedProfileIds[1]}';

await _firestore
    .collection('matches')
    .doc(matchDocId)
    .update({

  'conversationUnlocked': true,

  'unlockedByUid':
      _currentUser!.uid,

  'unlockedByProfileId':
      myProfileId,

  'unlockedAt':
      FieldValue.serverTimestamp(),
});

debugPrint(
  'MATCH UNLOCK STATUS SAVED',
);
final matchDoc =
    await _firestore
        .collection('matches')
        .doc(matchDocId)
        .get();

final String chatRoomId =
    matchDoc['chatRoomId'];

await _firestore
    .collection('chats')
    .doc(chatRoomId)
    .update({

  'conversationUnlocked': true,

  'unlockedByUid':
      _currentUser!.uid,

  'unlockedByProfileId':
      myProfileId,

  'unlockedAt':
      FieldValue.serverTimestamp(),
});

debugPrint(
  'CHAT UNLOCK STATUS SAVED',
);

      debugPrint(
        'CHAT ROOM CREATED SUCCESSFULLY',
      );

   final String partnerName =
    _getProfileDisplayName(
  likedProfile,
);

debugPrint(
  'OPENING CHAT SCREEN...',
);

if (!mounted) {
  debugPrint(
    'WIDGET NOT MOUNTED',
  );
  return;
}

if (!mounted) return;

Navigator.push(
  parentContext,
  MaterialPageRoute(
    builder: (_) => ChatScreen(
      chatPartnerId: likedProfile.uid,
      chatPartnerName: partnerName,
    ),
  ),
);

     debugPrint(
  'CONVERSATION STARTED SUCCESSFULLY',
);

    } catch (e) {

      debugPrint(
        'START CONVERSATION ERROR: $e',
      );

      debugPrint(
  'FAILED: $e',
);
    }
  },
);
    },
  );
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
          : 'Profile Details',
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
          : 'View profile details',
      style: TextStyle(
        color: Colors.white.withOpacity(.85),
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),
    ),
  ],
),

    actions: [
        if (widget.userId != null)
    ProfileActionMenu(
      userId: widget.userId!,
      profileId: widget.profileDocumentId!,
    ),
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
  bottomNavigationBar:
    widget.userId != null
        ? SafeArea(
            child: Container(
              padding: const EdgeInsets.all(16),
             child: Row(
  children: [

    Expanded(
      child: SizedBox(
        height: 56,
        child: ElevatedButton.icon(

          onPressed: () async {

            if (_alreadyLiked) return;

            await _processLike();

            setState(() {
              _alreadyLiked = true;
            });
          },

          icon: Icon(
            _alreadyMatched
                ? Icons.favorite
                : Icons.favorite_border,
          ),

          label: Text(

            _alreadyMatched
                ? "Match"

                : _alreadyLiked
                    ? "Liked"

                    : "Like",

          ),

          style: ElevatedButton.styleFrom(
            backgroundColor: kAccentColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    ),

    const SizedBox(width: 12),

    Expanded(
      child: SizedBox(
        height: 56,
        child: ElevatedButton.icon(

          onPressed: () async {

            if (_conversationUnlocked &&
                _existingChatRoomId != null) {

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    chatRoomId:
                        _existingChatRoomId!,
                    chatPartnerId:
                        widget.userId!,
                    chatPartnerName:
                        _userProfile
                                ?.userProfile
                                .name ??
                            'User',
                  ),
                ),
              );

              return;
            }

            await _showBannerPopup(
              _userProfile,
              _myProfileId!,
            );
          },

          icon: const Icon(
            Icons.chat_bubble_rounded,
          ),

          label: Text(
            _conversationUnlocked
                ? "Open Chat"
                : "Chat",
          ),

          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    ),
  ],
),
            ),
          )
        : null,

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