import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mytennat/screens/flatmate_profile_screen.dart'; // For FlatListingProfile
import 'package:mytennat/screens/flat_with_flatmate_profile_screen.dart'; // For SeekingFlatmateProfile
import 'package:mytennat/screens/chat_screen.dart'; // For ChatScreen
import 'package:mytennat/screens/view_profile_screen.dart'; // For ViewProfileScreen
import 'package:url_launcher/url_launcher.dart'; // Import for making phone calls
import 'package:mytennat/screens/home_page.dart' hide FlatListingProfile, SeekingFlatmateProfile;
import 'package:mytennat/screens/matching_screen.dart'; // Import MatchingScreen
import 'package:mytennat/screens/matches_list_screen.dart'; // Import MatchesListScreen
import 'package:mytennat/screens/more_profile_screen.dart'; // Import MoreProfileScreen
import 'package:mytennat/services/chat_unlock_service.dart';
import 'package:mytennat/screens/banner_popup_screen.dart'; // NEW: Import the banner popup screen
import 'package:mytennat/screens/PlansScreen.dart';

class UserActivityScreen extends StatefulWidget {
  const UserActivityScreen({super.key});

  @override
  State<UserActivityScreen> createState() => _UserActivityScreenState();
}

class _UserActivityScreenState extends State<UserActivityScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;
  bool _isLoading = true;

  List<dynamic> _userProfilesList = []; // List of all current user's profiles (FlatListing and SeekingFlatmate)

  // key: userProfileId, value: list of profiles that liked it
  final Map<String, List<dynamic>> _incomingLikes = {};
  // key: userProfileId, value: list of profiles it liked
  final Map<String, List<dynamic>> _outgoingLikes = {};
  // key: userProfileId, value: list of matched profiles with chatRoomId
  final Map<String, List<Map<String, dynamic>>> _matches = {};
  final Map<String, Map<String, dynamic>>
    _matchLookup = {};

  // Bottom Navigation Bar state
  int _selectedIndex = 3; // Set initial index to 3 for 'Activity'

bool _isBannerPopupShowing = false;

int _remainingContacts = 0;
  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    print('initState: _currentUser is ${_currentUser != null ? _currentUser!.uid : 'null'}');

    if (_currentUser == null) {
      setState(() {
        _isLoading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to view your activities.')),
        );
      });
    } else {
      _fetchUserActivities();
      _loadRemainingContacts();
    }
  }

  Future<void> _fetchUserActivities() async {
    setState(() {
      _isLoading = true;
      _userProfilesList.clear();
      _incomingLikes.clear();
      _outgoingLikes.clear();
      _matches.clear();
    });

    try {
      final String currentUserId = _currentUser!.uid;
      print('Fetching activities for current user ID: $currentUserId');

      // 1. Fetch all of the current user's profiles
      print('Fetching all user profiles...');
      await _fetchAllUserProfiles(currentUserId);
      print('Fetched user profiles: ${_userProfilesList.length} profiles found.');

      // 2. Fetch incoming likes for each of the user's profiles
      print('Fetching incoming likes...');
      await _fetchIncomingLikes(currentUserId);
      print('Incoming likes processed. Total entries: ${_incomingLikes.keys.length}');

      // 3. Fetch outgoing likes from each of the user's profiles
      print('Fetching outgoing likes...');
      await _fetchOutgoingLikes(currentUserId);
      print('Outgoing likes processed. Total entries: ${_outgoingLikes.keys.length}');

      // 4. Fetch matches involving any of the user's profiles
      print('Fetching matches...');
      await _fetchMatches(currentUserId);
      print('Matches processed. Total entries: ${_matches.keys.length}');

    } catch (e) {
      print('Error fetching user activities: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load activities: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
      print('Finished fetching user activities. Is loading: $_isLoading');
    }
  }
  Future<void> _loadRemainingContacts() async {

  if (_currentUser == null) {
    return;
  }

  try {

    final userDoc =
        await FirebaseFirestore
            .instance
            .collection('users')
            .doc(_currentUser!.uid)
            .get();

    if (!userDoc.exists) {
      return;
    }

    setState(() {

      _remainingContacts =
          userDoc.data()?[
                  'remainingContacts'] ??
              0;
    });

    debugPrint(
      'REMAINING CONTACTS = $_remainingContacts',
    );

  } catch (e) {

    debugPrint(
      'LOAD CONTACT ERROR: $e',
    );
  }
}

  Future<void> _fetchAllUserProfiles(String userId) async {
    _userProfilesList.clear();
    print('fetchAllUserProfiles: Clearing existing profiles.');

    // Fetch Flat Listings
    print('fetchAllUserProfiles: Fetching flatListings for $userId');
    QuerySnapshot flatListings = await _firestore
        .collection('users')
        .doc(userId)
        .collection('flatListings')
        .get();
    print('fetchAllUserProfiles: Found ${flatListings.docs.length} flatListings.');
    for (var doc in flatListings.docs) {
      _userProfilesList.add(FlatListingProfile.fromMap(doc.data() as Map<String, dynamic>, doc.id));
      print('fetchAllUserProfiles: Added FlatListing ${doc.id}');
    }

    // Fetch Seeking Flatmate Profiles
    print('fetchAllUserProfiles: Fetching seekingFlatmateProfiles for $userId');
    QuerySnapshot seekingFlatmateProfiles = await _firestore
        .collection('users')
        .doc(userId)
        .collection('seekingFlatmateProfiles')
        .get();
    print('fetchAllUserProfiles: Found ${seekingFlatmateProfiles.docs.length} seekingFlatmateProfiles.');
    for (var doc in seekingFlatmateProfiles.docs) {
      _userProfilesList.add(SeekingFlatmateProfile.fromMap(doc.data() as Map<String, dynamic>, doc.id));
      print('fetchAllUserProfiles: Added SeekingFlatmateProfile ${doc.id}');
    }
  }

  Future<void> _fetchIncomingLikes(String userId) async {
    _incomingLikes.clear();
    print('fetchIncomingLikes: Clearing existing incoming likes.');

    for (var userProfile in _userProfilesList) {
      final String userProfileId = userProfile.documentId!;
      print('fetchIncomingLikes: Querying collectionGroup "likes" for userProfileId: $userProfileId (likedUserId: $userId)');
      QuerySnapshot incomingLikesSnapshot = await _firestore.collectionGroup('likes')
          .where('likedUserId', isEqualTo: userId)
          .where('likedProfileDocumentId', isEqualTo: userProfileId)
          .get();
      print('fetchIncomingLikes: Found ${incomingLikesSnapshot.docs.length} incoming likes for profile $userProfileId.');

      List<dynamic> profilesThatLikedMe = [];
      for (var doc in incomingLikesSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final likingUserId = data['likingUserId'];
        final likingUserProfileId = data['likingUserProfileId'];
        final likingUserProfileType = data['likingUserProfileType'];

        dynamic likedByProfile;
        try {
          if (likingUserProfileType == 'flat_listing') {
            DocumentSnapshot otherDoc = await _firestore
                .collection('users')
                .doc(likingUserId)
                .collection('flatListings')
                .doc(likingUserProfileId)
                .get();
            if (otherDoc.exists) {
              likedByProfile = FlatListingProfile.fromMap(otherDoc.data() as Map<String, dynamic>, otherDoc.id);
            }
          } else if (likingUserProfileType == 'seeking_flatmate') {
            DocumentSnapshot otherDoc = await _firestore
                .collection('users')
                .doc(likingUserId)
                .collection('seekingFlatmateProfiles')
                .doc(likingUserProfileId)
                .get();
            if (otherDoc.exists) {
              likedByProfile = SeekingFlatmateProfile.fromMap(otherDoc.data() as Map<String, dynamic>, otherDoc.id);
            }
          }
        } catch (e) {
          print("Error fetching liking profile details for incoming like: $e");
        }

        if (likedByProfile != null) {
          profilesThatLikedMe.add(likedByProfile);
        }
      }
      if (profilesThatLikedMe.isNotEmpty) {
        _incomingLikes[userProfileId] = profilesThatLikedMe;
      }
    }
  }

  Future<void> _fetchOutgoingLikes(String userId) async {
    _outgoingLikes.clear();
    print('fetchOutgoingLikes: Clearing existing outgoing likes.');
    for (var userProfile in _userProfilesList) {
      final String userProfileId = userProfile.documentId!;
      print('fetchOutgoingLikes: Querying user_likes/${userId}/likes for likingUserProfileId: $userProfileId');
      QuerySnapshot outgoingLikesSnapshot = await _firestore.collection('user_likes')
          .doc(userId)
          .collection('likes')
          .where('likingUserProfileId', isEqualTo: userProfileId)
          .get();

      List<dynamic> profilesLikedByMe = [];
      for (var doc in outgoingLikesSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final likedUserId = data['likedUserId'];
        final likedProfileDocumentId = data['likedProfileDocumentId'];
        final likedUserProfileType = data['likedUserProfileType'];

        dynamic likedProfile;
        try {
          if (likedUserProfileType == 'flat_listing') {
            DocumentSnapshot otherDoc = await _firestore
                .collection('users')
                .doc(likedUserId)
                .collection('flatListings')
                .doc(likedProfileDocumentId)
                .get();
            if (otherDoc.exists) {
              likedProfile = FlatListingProfile.fromMap(otherDoc.data() as Map<String, dynamic>, otherDoc.id);
            }
          } else if (likedUserProfileType == 'seeking_flatmate') {
            DocumentSnapshot otherDoc = await _firestore
                .collection('users')
                .doc(likedUserId)
                .collection('seekingFlatmateProfiles')
                .doc(likedProfileDocumentId)
                .get();
            if (otherDoc.exists) {
              likedProfile = SeekingFlatmateProfile.fromMap(otherDoc.data() as Map<String, dynamic>, otherDoc.id);
            }
          }
        } catch (e) {
          print("Error fetching liked profile details for outgoing like: $e");
        }

        if (likedProfile != null) {
          profilesLikedByMe.add(likedProfile);
        }
      }
      if (profilesLikedByMe.isNotEmpty) {
        _outgoingLikes[userProfileId] = profilesLikedByMe;
      }
    }
  }

  Future<void> _fetchMatches(String userId) async {
    _matches.clear();
    print('fetchMatches: Clearing existing matches.');

    QuerySnapshot matchesSnapshot1 = await _firestore.collection('matches')
        .where('user1_uid', isEqualTo: userId)
        .get();

    QuerySnapshot matchesSnapshot2 = await _firestore.collection('matches')
        .where('user2_uid', isEqualTo: userId)
        .get();

    final allMatchDocs = {...matchesSnapshot1.docs, ...matchesSnapshot2.docs};

    for (var doc in allMatchDocs) {
      final data = doc.data() as Map<String, dynamic>;
      final String user1Uid = data['user1_uid'];
      final String user2Uid = data['user2_uid'];
      final String user1ProfileId = data['user1_profile_id'];
      final String user2ProfileId = data['user2_profile_id'];
      final String user1ProfileType = data['user1_profile_type'];
      final String user2ProfileType = data['user2_profile_type'];
      final String chatRoomId = data['chatRoomId'];
      final sortedIds = [
  user1ProfileId,
  user2ProfileId,
]..sort();

final matchId =
    '${sortedIds[0]}_${sortedIds[1]}';

_matchLookup[matchId] = {
  'conversationUnlocked':
      data['conversationUnlocked'] ??
          false,
  'chatRoomId':
      data['chatRoomId'],
};

      String currentUserProfileIdInMatch;
      String otherUserUid;
      String otherUserProfileId;
      String otherUserProfileType;

      if (user1Uid == userId) {
        currentUserProfileIdInMatch = user1ProfileId;
        otherUserUid = user2Uid;
        otherUserProfileId = user2ProfileId;
        otherUserProfileType = user2ProfileType;
      } else {
        currentUserProfileIdInMatch = user2ProfileId;
        otherUserUid = user1Uid;
        otherUserProfileId = user1ProfileId;
        otherUserProfileType = user1ProfileType;
      }

      // Fetch the details of the other user's profile involved in the match
      dynamic otherProfile;
      try {
        if (otherUserProfileType == 'flat_listing') {
          DocumentSnapshot otherDoc = await _firestore
              .collection('users')
              .doc(otherUserUid)
              .collection('flatListings')
              .doc(otherUserProfileId)
              .get();
          if (otherDoc.exists) {
            otherProfile = FlatListingProfile.fromMap(otherDoc.data() as Map<String, dynamic>, otherDoc.id);
          }
        } else if (otherUserProfileType == 'seeking_flatmate') {
          DocumentSnapshot otherDoc = await _firestore
              .collection('users')
              .doc(otherUserUid)
              .collection('seekingFlatmateProfiles')
              .doc(otherUserProfileId)
              .get();
          if (otherDoc.exists) {
            otherProfile = SeekingFlatmateProfile.fromMap(otherDoc.data() as Map<String, dynamic>, otherDoc.id);
          }
        }
      } catch (e) {
        print("Error fetching matched profile details: $e");
      }

      if (otherProfile != null) {
        if (!_matches.containsKey(currentUserProfileIdInMatch)) {
          _matches[currentUserProfileIdInMatch] = [];
        }
        _matches[currentUserProfileIdInMatch]!.add({
          'profile': otherProfile,
          'chatRoomId': chatRoomId,
        });
      }
    }
  }

  String? _findChatRoomId(String currentUserProfileId, String otherUserUid, String otherUserProfileId) {
    final List<Map<String, dynamic>>? matchesForCurrentUserProfile = _matches[currentUserProfileId];
    if (matchesForCurrentUserProfile == null) {
      return null;
    }

    for (var match in matchesForCurrentUserProfile) {
      final dynamic matchedProfile = match['profile'];
      // Assuming 'uid' is a property on both FlatListingProfile and SeekingFlatmateProfile
      if (matchedProfile != null && matchedProfile.uid == otherUserUid && matchedProfile.documentId == otherUserProfileId) {
        return match['chatRoomId'];
      }
    }
    return null;
  }
void _showOutOfContactsPopup() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => PlansScreen(),
    ),
  );
}
String _getProfileDisplayName(dynamic profile) {

  if (profile is FlatListingProfile) {

    return profile.userProfile.name != null &&
            profile.userProfile.name!.isNotEmpty
        ? profile.userProfile.name!
        : 'Room Listing';
  }

  if (profile is SeekingFlatmateProfile) {

    return profile.userProfile.name != null &&
            profile.userProfile.name!.isNotEmpty
        ? profile.userProfile.name!
        : 'Seeking Flatmate';
  }

  return 'Unknown Profile';
}

  String _getProfileTypeDisplay(dynamic profile) {
    if (profile is FlatListingProfile) {
      return 'flat_listing'; // Return raw type for filtering
    } else if (profile is SeekingFlatmateProfile) {
      return 'seeking_flatmate'; // Return raw type for filtering
    }
    return 'unknown';
  }

  // New function for making phone calls
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $phoneNumber')),
      );
    }
  }

  // --- New Aggregation Methods ---

  List<dynamic> _getAggregatedIncomingLikes(String profileType) {
    List<dynamic> aggregatedProfiles = [];
    for (var profile in _userProfilesList) {
      if (_getProfileTypeDisplay(profile) == profileType) {
        final profileId = profile.documentId!;
        if (_incomingLikes.containsKey(profileId)) {
          aggregatedProfiles.addAll(_incomingLikes[profileId]!);
        }
      }
    }
    // You might want to remove duplicates if the same 'liking' profile liked multiple of your profiles of the same type.
    return aggregatedProfiles.toSet().toList(); // Using toSet().toList() for basic deduplication
  }

List<dynamic> _getAggregatedOutgoingLikes(
  String profileType,
) {

  List<dynamic> aggregatedProfiles = [];

  for (var profile
      in _userProfilesList) {

    if (_getProfileTypeDisplay(
            profile) ==
        profileType) {

      final profileId =
          profile.documentId!;

      if (_outgoingLikes
          .containsKey(
              profileId)) {

        for (var likedProfile
            in _outgoingLikes[
                profileId]!) {

          final sortedIds = [
            profileId,
            likedProfile.documentId!,
          ]..sort();

          final matchId =
              '${sortedIds[0]}_${sortedIds[1]}';

          

          aggregatedProfiles.add({

  'profile':
      likedProfile,

  'myProfileId':
      profileId,

  'conversationUnlocked':
    _matchLookup[matchId]
            ?['conversationUnlocked'] ??
        false,

'chatRoomId':
    _matchLookup[matchId]
        ?['chatRoomId'],
});
        }
      }
    }
  }

  return aggregatedProfiles;
}

  List<Map<String, dynamic>> _getAggregatedMatches(String profileType) {
    List<Map<String, dynamic>> aggregatedMatches = [];
    for (var profile in _userProfilesList) {
      if (_getProfileTypeDisplay(profile) == profileType) {
        final profileId = profile.documentId!;
        if (_matches.containsKey(profileId)) {
          // Add the matched profiles along with their chatRoomId
          for (var matchEntry in _matches[profileId]!) {
            // Check if this specific match (profile + chatRoomId) is already added
            bool isDuplicate = aggregatedMatches.any((existingMatch) =>
            existingMatch['profile'].documentId == matchEntry['profile'].documentId &&
                existingMatch['profile'].uid == matchEntry['profile'].uid && // Also check UID for uniqueness
                existingMatch['chatRoomId'] == matchEntry['chatRoomId']
            );
            if (!isDuplicate) {
              // Add a reference to the current user's profile ID that generated this match
              aggregatedMatches.add({
                ...matchEntry,
                'currentOwnerProfileId': profileId, // Add this crucial piece of information
              });
            }
          }
        }
      }
    }
    return aggregatedMatches;
  }


  // Method to handle bottom navigation bar taps
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0: // Home
        Navigator.popUntil(context, (route) => route.isFirst);
        break;
      case 1: // Matches (Now refers to MatchingScreen)
        if (_userProfilesList.isNotEmpty) {
          String? defaultProfileType = _getProfileTypeDisplay(_userProfilesList[0]);
          String? defaultProfileId = _userProfilesList[0].documentId;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MatchingScreen(
                profileType: defaultProfileType!,
                profileId: defaultProfileId!,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please create a profile to view matches.')),
          );
        }
        break;
      case 2: // Chat (MatchesListScreen)
        if (_userProfilesList.isNotEmpty) {
          String? defaultProfileType = _getProfileTypeDisplay(_userProfilesList[0]);
          String? defaultProfileId = _userProfilesList[0].documentId;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MatchesListScreen(
                profileType: defaultProfileType!,
                profileId: defaultProfileId!,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please create a profile to view chat/matches.')),
          );
        }
        break;
      case 3: // Activity
      // Stay on UserActivityScreen, or pop if it's not the root
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        break;
      case 4: // More
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MoreProfileScreen()),
        );
        break;
    }
  }


 @override
Widget build(BuildContext context) {
  return DefaultTabController(
    length: 2,
    child: Scaffold(
      backgroundColor: kBackgroundColor,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,

        iconTheme: const IconThemeData(
          color: Colors.white,
        ),

        title: const Text(
          'My Connections',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),

        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: kPrimaryGradient,
          ),
        ),

        bottom: TabBar(
          indicatorColor: Colors.white,
          indicatorWeight: 3,

          labelColor: Colors.white,

          unselectedLabelColor:
              Colors.white.withOpacity(.75),

          labelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),

          unselectedLabelStyle:
              const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),

          tabs: const [

            Tab(
              icon: Icon(
                Icons.home_rounded,
              ),
              text: 'Room Listings',
            ),

            Tab(
              icon: Icon(
                Icons.people_alt_rounded,
              ),
              text: 'Flatmates',
            ),
          ],
        ),
      ),

      body: _isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(
                color: kPrimaryColor,
              ),
            )
          : TabBarView(
              children: [

                _buildProfileActivityView(
                  profileType:
                      'flat_listing',
                  emptyMessage:
                      'No Room Listings found.',
                ),

                _buildProfileActivityView(
                  profileType:
                      'seeking_flatmate',
                  emptyMessage:
                      'No Flatmate Profiles found.',
                ),
              ],
            ),

      bottomNavigationBar:
          Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [

            BoxShadow(
              color:
                  Colors.black.withOpacity(
                .06,
              ),
              blurRadius: 20,
              offset:
                  const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor:
              Colors.white,

          elevation: 0,

          type:
              BottomNavigationBarType
                  .fixed,

          selectedItemColor:
              kPrimaryColor,

          unselectedItemColor:
              kLightText,

          selectedLabelStyle:
              const TextStyle(
            fontWeight:
                FontWeight.w700,
          ),

          currentIndex:
              _selectedIndex,

          onTap:
              _onItemTapped,

          items: const [

            BottomNavigationBarItem(
              icon: Icon(
                Icons.home_rounded,
              ),
              label: 'Home',
            ),

            BottomNavigationBarItem(
              icon: Icon(
                Icons.favorite_rounded,
              ),
              label: 'Matches',
            ),

            BottomNavigationBarItem(
              icon: Icon(
                Icons.chat_bubble_rounded,
              ),
              label: 'Chat',
            ),

            BottomNavigationBarItem(
              icon: Icon(
                Icons.local_activity_rounded,
              ),
              label: 'Activity',
            ),

            BottomNavigationBarItem(
              icon: Icon(
                Icons.more_horiz_rounded,
              ),
              label: 'More',
            ),
          ],
        ),
      ),
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
    true,
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


  // Renamed from _buildMainProfileSection to represent the content of each main tab
Widget _buildProfileActivityView({
  required String profileType,
  required String emptyMessage,
}) {

  final List<dynamic> profilesOfType =
      _userProfilesList
          .where(
            (p) =>
                _getProfileTypeDisplay(
                  p,
                ) ==
                profileType,
          )
          .toList();

  final incomingLikes =
      _getAggregatedIncomingLikes(
    profileType,
  );

  final outgoingLikes =
      _getAggregatedOutgoingLikes(
    profileType,
  );

  final matches =
      _getAggregatedMatches(
    profileType,
  );

  return DefaultTabController(
    length: 3,
    child: Column(
      children: [

        if (profilesOfType.isEmpty)

          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [

                  Container(
                    width: 90,
                    height: 90,
                    decoration:
                        BoxDecoration(
                      color:
                          kPrimaryColor
                              .withOpacity(
                        .08,
                      ),
                      shape:
                          BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.people_alt_rounded,
                      size: 42,
                      color:
                          kPrimaryColor,
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  Text(
                    emptyMessage,
                    textAlign:
                        TextAlign.center,
                    style:
                        const TextStyle(
                      color:
                          kMediumText,
                      fontSize: 16,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          )

        else ...[

          Container(
            margin:
                const EdgeInsets.only(
              top: 8,
              left: 12,
              right: 12,
            ),

            decoration:
                BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(
                18,
              ),
              border: Border.all(
                color:
                    kBorderColor,
              ),
            ),

            child: TabBar(
              dividerColor:
                  Colors.transparent,

              indicator: BoxDecoration(
  gradient: kPrimaryGradient,
  borderRadius: BorderRadius.circular(18),
),
indicatorSize: TabBarIndicatorSize.tab,

              labelColor:
                  Colors.white,

              unselectedLabelColor:
                  kMediumText,

              labelStyle:
                  const TextStyle(
                fontWeight:
                    FontWeight.w700,
                fontSize: 13,
              ),

              tabs: [

                Tab(
                  icon: const Icon(
                    Icons.favorite,
                    size: 18,
                  ),
                  text:
                      'Liked Me (${incomingLikes.length})',
                ),

                Tab(
                  icon: const Icon(
                    Icons.thumb_up,
                    size: 18,
                  ),
                  text:
                      'Liked (${outgoingLikes.length})',
                ),

                Tab(
                  icon: const Icon(
                    Icons.chat_bubble_rounded,
                    size: 18,
                  ),
                  text:
                      'Matches (${matches.length})',
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          Expanded(
            child: TabBarView(
              children: [

                _buildSectionContent(
                  profiles:
                      incomingLikes,

                  emptyMessage:
                      'Nobody has liked your profiles yet.',

                  isMatchSection:
                      false,

                  isLikedByMeSection:
                      false,

                  profileTypeFilter:
                      profileType,
                ),

                _buildSectionContent(
                  profiles:
                      outgoingLikes,

                  emptyMessage:
                      'You have not liked anyone yet.',

                  isMatchSection:
                      false,

                  isLikedByMeSection:
                      true,

                  profileTypeFilter:
                      profileType,
                ),

                _buildSectionContent(
                  profiles:
                      matches,

                  emptyMessage:
                      'No matches yet.',

                  isMatchSection:
                      true,

                  isLikedByMeSection:
                      false,

                  profileTypeFilter:
                      profileType,
                ),
              ],
            ),
          ),
        ],
      ],
    ),
  );
}
  // Re-designed _buildSectionContent to be more generic and use aggregated data
 Widget _buildSectionContent({
  List<dynamic>? profiles,
  required String emptyMessage,
  required bool isMatchSection,
  required bool isLikedByMeSection,
  required String profileTypeFilter,
}) {

  if (profiles == null ||
      profiles.isEmpty) {

    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [

            Icon(
              isMatchSection
                  ? Icons.chat_bubble_outline_rounded
                  : Icons.favorite_border_rounded,
              size: 60,
              color: kLightText,
            ),

            const SizedBox(
              height: 16,
            ),

            Text(
              emptyMessage,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color:
                    kMediumText,
                fontSize: 16,
                fontWeight:
                    FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  return ListView.separated(
    physics:
        const BouncingScrollPhysics(),

    padding:
        const EdgeInsets.only(
      top: 4,
      bottom: 20,
    ),

    itemCount:
        profiles.length,

    separatorBuilder:
        (_, __) =>
            const SizedBox(
      height: 2,
    ),

    itemBuilder: (context, index) {

  dynamic profile;

  String? chatRoomId;

  String? currentOwnerProfileId;

  String? myProfileId;

  bool conversationUnlocked = false;

  String? unlockedChatRoomId;

  if (isMatchSection) {

    final Map<String, dynamic>
        matchEntry =
        profiles[index];

    profile =
        matchEntry['profile'];

    chatRoomId =
        matchEntry['chatRoomId'];

    currentOwnerProfileId =
        matchEntry[
            'currentOwnerProfileId'];

  } else if (isLikedByMeSection) {

    final Map<String, dynamic>
        entry =
        profiles[index];

    profile =
        entry['profile'];

    myProfileId =
        entry['myProfileId'];

    conversationUnlocked =
        entry[
            'conversationUnlocked'] ??
        false;

    unlockedChatRoomId =
        entry['chatRoomId'];

  } else {

    profile = profiles[index];
  }

  return _buildProfileCard(
    profile: profile,

    isMatchSection:
        isMatchSection,

    isLikedMeSection:
        !isMatchSection &&
            !isLikedByMeSection,

    isLikedByMeSection:
        isLikedByMeSection,

    onTap: () {

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ViewProfileScreen(
            userId:
                profile.uid!,
            profileDocumentId:
                profile.documentId!,
          ),
        ),
      );
    },

    showChatButton:
        isMatchSection &&
            chatRoomId != null,

    showCallButton: false,

    chatRoomId:
        chatRoomId,

    currentOwnerProfileId:
        currentOwnerProfileId,

    myProfileId:
        myProfileId,

    conversationUnlocked:
        conversationUnlocked,

    unlockedChatRoomId:
        unlockedChatRoomId,
  );
},
  );
}

  // Reusable card widget for displaying profiles in lists
Widget _buildProfileCard({
  required dynamic profile,

  required bool isMatchSection,

  required bool isLikedMeSection,

  required bool isLikedByMeSection,

  required VoidCallback onTap,

  required bool showChatButton,

  required bool showCallButton,

  required bool conversationUnlocked,

  String? unlockedChatRoomId,

  String? chatRoomId,

  String? currentOwnerProfileId,

  String? myProfileId,
}) {
    String name = _getProfileDisplayName(profile);
    String typeDisplay = _getProfileTypeDisplay(profile); // Still used for icon/label
  String? profileImageUrl;

if (profile is FlatListingProfile) {

  if (profile.imageUrls != null &&
      profile.imageUrls!.isNotEmpty) {
    profileImageUrl =
        profile.imageUrls!.first;
  }

} else if (profile is SeekingFlatmateProfile) {

  if (profile.imageUrls != null &&
      profile.imageUrls!.isNotEmpty) {
    profileImageUrl =
        profile.imageUrls!.first;
  }
}
   return Card(
  margin: const EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 6,
  ),

  elevation: 0,

  color: kCardColor,

  shadowColor: Colors.transparent,

  shape: RoundedRectangleBorder(
    borderRadius:
        BorderRadius.circular(20),
    side: const BorderSide(
      color: kBorderColor,
    ),
  ),

  child: InkWell(
    borderRadius:
        BorderRadius.circular(20),

    onTap: onTap,

    child: Padding(
      padding:
          const EdgeInsets.all(14),

      child: Row(
        children: [

          CircleAvatar(
            radius: 30,

            backgroundColor:
                kPrimaryColor
                    .withOpacity(.08),

            backgroundImage:
                profileImageUrl != null
                    ? NetworkImage(
                        profileImageUrl,
                      )
                    : null,

            child:
                profileImageUrl == null
                    ? Icon(
                        profile is FlatListingProfile
                            ? Icons.home_rounded
                            : Icons.person_rounded,
                        color:
                            kPrimaryColor,
                        size: 28,
                      )
                    : null,
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

              children: [

                Text(
                  name,
                  maxLines: 1,
                  overflow:
                      TextOverflow
                          .ellipsis,

                  style:
                      const TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight
                            .w700,
                    color:
                        kDarkText,
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                Row(
                  children: [

                    const Icon(
                      Icons
                          .location_on_rounded,
                      size: 14,
                      color:
                          kMediumText,
                    ),

                    const SizedBox(
                      width: 4,
                    ),

                    Expanded(
                      child: Text(
                        profile.city ??
                            '',
                        maxLines: 1,
                        overflow:
                            TextOverflow
                                .ellipsis,

                        style:
                            const TextStyle(
                          color:
                              kMediumText,
                          fontSize:
                              13,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 8,
                ),

                Container(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),

                  decoration:
                      BoxDecoration(
                    color:
                        kPrimaryColor
                            .withOpacity(
                      .08,
                    ),

                    borderRadius:
                        BorderRadius
                            .circular(
                      30,
                    ),
                  ),

                  child: Text(
                    profile
                            is FlatListingProfile
                        ? 'Room Listing'
                        : 'Seeking Flatmate',

                    style:
                        const TextStyle(
                      color:
                          kPrimaryColor,
                      fontSize: 12,
                      fontWeight:
                          FontWeight
                              .w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          if (isMatchSection &&
              chatRoomId != null)

            ElevatedButton.icon(
              onPressed: () {

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            ChatScreen(
                      chatPartnerId:
                          profile.uid!,
                      chatPartnerName:
                          name,
                      chatRoomId:
                          chatRoomId,
                    ),
                  ),
                );
              },

              icon: const Icon(
                Icons
                    .chat_bubble_rounded,
                size: 16,
              ),

              label: const Text(
                'Chat',
              ),

              style:
                  ElevatedButton
                      .styleFrom(
                backgroundColor:
                    kOnlineColor,

                foregroundColor:
                    Colors.white,

                elevation: 0,

                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius
                          .circular(
                    14,
                  ),
                ),
              ),
            ),

          if (isLikedMeSection)

            ElevatedButton.icon(
              onPressed: () async {

                // Like Back

              },

              icon: const Icon(
                Icons.favorite,
                size: 16,
              ),

              label: const Text(
                'Like',
              ),

              style:
                  ElevatedButton
                      .styleFrom(
                backgroundColor:
                    kAccentColor,

                foregroundColor:
                    Colors.white,

                elevation: 0,

                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius
                          .circular(
                    14,
                  ),
                ),
              ),
            ),

     // LOCKED PROFILE

if (isLikedByMeSection &&
    !conversationUnlocked)

  ElevatedButton.icon(
    onPressed: () async {

      await _showBannerPopup(
        profile,
        myProfileId!,
      );

    },

    icon: const Icon(
      Icons.lock_open_rounded,
      size: 16,
    ),

    label: const Text(
      'Start',
    ),

    style:
        ElevatedButton.styleFrom(
      backgroundColor:
          kPrimaryColor,

      foregroundColor:
          Colors.white,

      elevation: 0,

      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          14,
        ),
      ),
    ),
  ),

// UNLOCKED PROFILE

if (isLikedByMeSection &&
    conversationUnlocked)

  ElevatedButton.icon(
    onPressed: () {

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            chatRoomId:
                unlockedChatRoomId!,
            chatPartnerId:
                profile.uid!,
            chatPartnerName:
                _getProfileDisplayName(
              profile,
            ),
          ),
        ),
      );
    },

    icon: const Icon(
      Icons.chat_bubble_rounded,
      size: 16,
    ),

    label: const Text(
      'Chat',
    ),

    style:
        ElevatedButton.styleFrom(
      backgroundColor:
          kOnlineColor,

      foregroundColor:
          Colors.white,

      elevation: 0,

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
  ),
);
  }
}

// Dummy classes for FlatListingProfile and SeekingFlatmateProfile
// (Ensure these match your actual implementations, potentially in a shared models file)
// Make sure these classes have a 'uid' field if you are using it for navigation.
