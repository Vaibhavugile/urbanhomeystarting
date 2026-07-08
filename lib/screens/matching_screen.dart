import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mytennat/screens/flatmate_profile_screen.dart'; // For FlatListingProfile
import 'package:mytennat/screens/flat_with_flatmate_profile_screen.dart'; // For SeekingFlatmateProfile
import 'package:intl/intl.dart';
import 'package:mytennat/screens/filter_screen.dart'
hide kBackgroundColor,
         kPrimaryColor,
         kAccentColor,
         kPrimaryGradient,
         kErrorColor,
         kDarkText,
         kMediumText;
import 'package:mytennat/screens/filter_options.dart';
import 'dart:math' as math; // Import for math.min
import 'package:mytennat/screens/view_profile_screen.dart'; // Import ViewProfileScreen
import 'package:mytennat/screens/banner_popup_screen.dart'; // NEW: Import the banner popup screen
import 'package:mytennat/screens/PlansScreen.dart';
import 'package:mytennat/screens/ad_page.dart'; // NEW: Import the AdPage
import 'package:mytennat/screens/matching/widgets/profile_card.dart';
import 'package:mytennat/screens/matching/widgets/profile_list_item.dart';
import 'package:mytennat/screens/matching/services/matching_service.dart';
import 'package:mytennat/screens/matching/widgets/ad_panel.dart';
import 'dart:math' as math;
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:mytennat/screens/chat_screen.dart'
    hide kBackgroundColor,
         kPrimaryColor,
         kPrimaryGradient,
         kErrorColor,
         kDarkText,
         kMediumText;


import '../widgets/location_selector_widget.dart'
      hide kPrimaryGradient,
      kAccentColor;


// NEW: Enum to manage different view types
enum _ViewType {
  card,
  list,
}

class MatchingScreen extends StatefulWidget {
  final String profileType;
  final String profileId;
  final bool isExploreMode;
  final String? exploreCity;

final String? exploreLocationName;

final String? explorePlaceId;

final double? exploreLatitude;

final double? exploreLongitude;

const MatchingScreen({
  super.key,
  required this.profileType,
  required this.profileId,
  this.isExploreMode = false,

  this.exploreCity,
  this.exploreLocationName,
  this.explorePlaceId,
  this.exploreLatitude,
  this.exploreLongitude,
});
  @override
  State<MatchingScreen> createState() => _MatchingScreenState();
}

class _MatchingScreenState extends State<MatchingScreen> {
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final MatchingService _matchingService =
    MatchingService(FirebaseFirestore.instance);
  User? _currentUser;
  List<dynamic> _profiles = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  String? _userProfileType;
  dynamic _currentUserParsedProfile; // Store the current user's parsed profile
  FilterOptions _currentFilters = FilterOptions(); // Current active filters
  bool _isBannerPopupShowing = false; // NEW: Flag to prevent multiple popups
  // Data for banner and liked/liked by me logic
  // Key: current user's active profile ID, Value: List of profiles that liked it
  final Map<String, List<dynamic>> _incomingLikes = {};
  // Key: current user's active profile ID, Value: List of profiles liked by it
  final Map<String, List<dynamic>> _outgoingLikes = {};
// Pagination
DocumentSnapshot? _lastDocument;

bool _hasMoreProfiles = true;

bool _isLoadingMore = false;
final CardSwiperController _cardController =
    CardSwiperController();
static const int _pageSize = 50;

  String? _bannerMessage;
  String? _lastLikedProfileName; // Name of the person you just liked who didn't like back

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // Key for Scaffold

  int _interactionCount = 0; // NEW: Counter for likes/dislikes
  int _remainingContacts = 0; // State to hold remaining contacts
  String? _currentPlanName; // State to hold current plan name
dynamic _lastLikedProfile;
  // NEW: State variable to track the current view
  _ViewType _currentViewType = _ViewType.card;
dynamic _lastPassedProfile;
// ============================================================
// EXPLORE MODE STATE
// ============================================================

late String _exploreType;

String? _exploreCity;
String? _exploreLocationName;
String? _explorePlaceId;

double? _exploreLatitude;
double? _exploreLongitude;
double? get _activeLatitude {
  // FilterScreen selected location has highest priority
  if (_currentFilters.latitude != null) {
    return _currentFilters.latitude;
  }

  // Explore Mode location selected inside MatchingScreen
  if (widget.isExploreMode) {
    return _exploreLatitude;
  }

  // Normal Flat Listing Profile
  if (_currentUserParsedProfile is FlatListingProfile) {
    return (_currentUserParsedProfile as FlatListingProfile).latitude;
  }

  // Normal Seeking Flatmate Profile
  if (_currentUserParsedProfile is SeekingFlatmateProfile) {
    return (_currentUserParsedProfile as SeekingFlatmateProfile).latitude;
  }

  return null;
}

double? get _activeLongitude {
  // FilterScreen selected location has highest priority
  if (_currentFilters.longitude != null) {
    return _currentFilters.longitude;
  }

  // Explore Mode location selected inside MatchingScreen
  if (widget.isExploreMode) {
    return _exploreLongitude;
  }

  // Normal Flat Listing Profile
  if (_currentUserParsedProfile is FlatListingProfile) {
    return (_currentUserParsedProfile as FlatListingProfile).longitude;
  }

  // Normal Seeking Flatmate Profile
  if (_currentUserParsedProfile is SeekingFlatmateProfile) {
    return (_currentUserParsedProfile as SeekingFlatmateProfile).longitude;
  }

  return null;
}
bool _canUndoPass = false;
@override
void initState() {
  super.initState();

  _currentUser = _auth.currentUser;

  _userProfileType = widget.profileType;

  // ============================================================
  // INITIALIZE EXPLORE MODE STATE
  // ============================================================

  _exploreType = widget.profileType;

  _exploreCity = widget.exploreCity;

  _exploreLocationName =
      widget.exploreLocationName;

  _explorePlaceId =
      widget.explorePlaceId;

  _exploreLatitude =
      widget.exploreLatitude;

  _exploreLongitude =
      widget.exploreLongitude;

  // ============================================================
  // USER LOGIN CHECK
  // ============================================================

  if (_currentUser == null) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showAlertDialog(
        'Not Logged In',
        'Please log in to use the matching feature.',
        () {},
      );
    });

    return;
  }

  // ============================================================
  // LOAD MATCHING DATA
  // ============================================================

  if (widget.isExploreMode) {
  _loadExploreProfiles();
} else {
  _fetchUserProfile();
}
}

  @override
  void dispose() {
    super.dispose();
    _cardController.dispose();
  }

  // Helper to get display name for a profile
  String _getProfileDisplayName(dynamic profile) {
    if (profile is FlatListingProfile) {
      return profile.userProfile.name ?? 'Unnamed Flat Listing';
    } else if (profile is SeekingFlatmateProfile) {
      return profile.userProfile.name ?? 'Unnamed Flatmate Seeker';
    }
    return 'Unknown Profile';
  }

  // Helper to get display type for a profile
  String _getProfileTypeDisplay(dynamic profile) {
    if (profile is FlatListingProfile) {
      return 'Flat Listing';
    } else if (profile is SeekingFlatmateProfile) {
      return 'Seeking Flatmate';
    }
    return 'Unknown Type';
  }
  double _calculateDistanceKm(
  double lat1,
  double lon1,
  double lat2,
  double lon2,
) {
  const double earthRadius = 6371;

  final dLat =
      (lat2 - lat1) *
      (math.pi / 180);

  final dLon =
      (lon2 - lon1) *
      (math.pi / 180);

  final a =
      math.sin(dLat / 2) *
          math.sin(dLat / 2) +
      math.cos(
            lat1 *
                (math.pi / 180),
          ) *
          math.cos(
            lat2 *
                (math.pi / 180),
          ) *
          math.sin(dLon / 2) *
          math.sin(dLon / 2);

  final c = 2 *
      math.atan2(
        math.sqrt(a),
        math.sqrt(1 - a),
      );

  return earthRadius * c;
}
String? _getDistanceText(dynamic profile) {

  if (profile == null) {
    return null;
  }

  if (_activeLatitude == null ||
      _activeLongitude == null ||
      profile.latitude == null ||
      profile.longitude == null) {
    return null;
  }

  final distance = _calculateDistanceKm(
    _activeLatitude!,
    _activeLongitude!,
    profile.latitude!,
    profile.longitude!,
  );

  if (distance < 1) {
    return '${(distance * 1000).round()} m away';
  }

  return '${distance.toStringAsFixed(1)} km away';
}
String? get _defaultCity {
  // Location selected from FilterScreen has highest priority
  if (_currentFilters.desiredCity != null &&
      _currentFilters.desiredCity!.isNotEmpty) {
    return _currentFilters.desiredCity;
  }

  // Explore Mode city selected inside MatchingScreen
  if (widget.isExploreMode &&
      _exploreCity != null &&
      _exploreCity!.isNotEmpty) {
    return _exploreCity;
  }

  // Normal Flat Listing Profile
  if (_currentUserParsedProfile is FlatListingProfile) {
    return (_currentUserParsedProfile as FlatListingProfile).city;
  }

  // Normal Seeking Flatmate Profile
  if (_currentUserParsedProfile is SeekingFlatmateProfile) {
    return (_currentUserParsedProfile as SeekingFlatmateProfile).city;
  }

  return null;
}
Future<void> _loadExploreProfiles() async {
  if (!widget.isExploreMode) {
    return;
  }

  if (!mounted) {
    return;
  }

  setState(() {
    // Show loading UI
    _isLoading = true;

    // Remove old Room/Flatmate results
    _profiles.clear();

    // Reset card position
    _currentIndex = 0;

    // Reset pagination
    _lastDocument = null;
    _hasMoreProfiles = true;
    _isLoadingMore = false;

    // Reset undo state because old profile belongs
    // to the previous Explore result set.
    _lastPassedProfile = null;
    _canUndoPass = false;
  });

  if (_exploreType == "flat_listing") {
    await _fetchFlatListingProfiles(
      applyFilters: true,
    );
  } else {
    await _fetchSeekingFlatmateProfiles(
      applyFilters: true,
    );
  }
}
  Future<void> _fetchUserProfile({bool applyFilters = false}) async {
    if (_currentUser == null) return;

    setState(() {
      _isLoading = true;
      _interactionCount = 0; // NEW: Reset interaction count when fetching new profiles
    });

    try {
      // Add a print statement to verify the value of widget.profileType
      print('Widget profileType: ${widget.profileType}');

      final userDoc = await _firestore.collection('users').doc(_currentUser!.uid).get();
      if (userDoc.exists) {
        final userData = userDoc.data();
        if (userData != null) {
          setState(() {
            _remainingContacts = userData['remainingContacts'] as int? ?? 0;
            _currentPlanName = userData['currentPlan'] as String?;
          });
        }
      }

      // Use widget.profileType to determine the user's profile type
      if (widget.profileType == 'flat_listing') {
        DocumentSnapshot flatListingDoc = await _firestore
            .collection('users')
            .doc(_currentUser!.uid)
            .collection('flatListings')
            .doc(widget.profileId) // Use the passed profileId
            .get();

        if (flatListingDoc.exists) {
          _currentUserParsedProfile = FlatListingProfile.fromMap(
              flatListingDoc.data() as Map<String, dynamic>,
              flatListingDoc.id
          );
          // Fetch likes after the current user's profile is loaded
          await _fetchIncomingLikes(_currentUser!.uid, widget.profileId);
          await _fetchOutgoingLikes(_currentUser!.uid, widget.profileId);
          // If current user is 'flat_listing', they are looking for 'seeking_flatmate' profiles
          await _fetchSeekingFlatmateProfiles(applyFilters: true);
        } else {
          _showAlertDialog('Profile Not Found', 'The selected Flat Listing profile could not be found.', () {
            // Navigate back to profile selection or home
          });
        }
      } else if (widget.profileType == 'seeking_flatmate') {
        DocumentSnapshot seekingFlatmateDoc = await _firestore
            .collection('users')
            .doc(_currentUser!.uid)
            .collection('seekingFlatmateProfiles')
            .doc(widget.profileId) // Use the passed profileId
            .get();

        if (seekingFlatmateDoc.exists) {
          _currentUserParsedProfile = SeekingFlatmateProfile.fromMap(
              seekingFlatmateDoc.data() as Map<String, dynamic>,
              seekingFlatmateDoc.id
          );
          // Fetch likes after the current user's profile is loaded
          await _fetchIncomingLikes(_currentUser!.uid, widget.profileId);
          await _fetchOutgoingLikes(_currentUser!.uid, widget.profileId);
          // If current user is 'seeking_flatmate', they are looking for 'flat_listing' profiles
          await _fetchFlatListingProfiles(applyFilters: true);
        } else {
          _showAlertDialog('Profile Not Found', 'The selected Seeking Flatmate profile could not be found.', () {
            // Navigate back to profile selection or home
          });
        }
      } else {
        _showAlertDialog('Profile Type Not Found', 'Your active profile type could not be determined from the provided data.', () {});
      }
      _checkForBanner(); // Initial check for banner after all data is loaded
    } catch (e) {
      _showAlertDialog('Error', 'Failed to fetch user profile: $e', () {});
      print('Firebase Firestore Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
        _currentIndex = 0; // Reset index when new profiles are fetched
        // _bannerMessage is now set by _checkForBanner()
      });
    }
  }
  Future<void> _fetchIncomingLikes(String currentUserId, String currentProfileId) async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collectionGroup('likes') // Query across all 'likes' subcollections
          .where('likedUserId', isEqualTo: currentUserId)
          .where('likedProfileDocumentId', isEqualTo: currentProfileId)
          .get();

      List<dynamic> likedMeProfiles = [];
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final String likingUserId = data['likingUserId'];
        final String likingUserProfileId = data['likingUserProfileId'];
        final String likingUserProfileType = data['likingUserProfileType'];

        DocumentSnapshot? profileDoc;
        if (likingUserProfileType == 'flat_listing') {
          profileDoc = await _firestore.collection('users').doc(likingUserId).collection('flatListings').doc(likingUserProfileId).get();
        } else if (likingUserProfileType == 'seeking_flatmate') {
          profileDoc = await _firestore.collection('users').doc(likingUserId).collection('seekingFlatmateProfiles').doc(likingUserProfileId).get();
        }

        if (profileDoc != null && profileDoc.exists) {
          if (likingUserProfileType == 'flat_listing') {
            likedMeProfiles.add(FlatListingProfile.fromMap(profileDoc.data() as Map<String, dynamic>, profileDoc.id));
          } else if (likingUserProfileType == 'seeking_flatmate') {
            likedMeProfiles.add(SeekingFlatmateProfile.fromMap(profileDoc.data() as Map<String, dynamic>, profileDoc.id));
          }
        }
      }
      setState(() {
        _incomingLikes[currentProfileId] = likedMeProfiles;
      });
    } catch (e) {
      print('Error fetching incoming likes: $e');
    }
  }

  Future<void> _fetchOutgoingLikes(String currentUserId, String currentProfileId) async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('user_likes')
          .doc(currentUserId)
          .collection('likes')
          .where('likingUserProfileId', isEqualTo: currentProfileId)
          .get();

      List<dynamic> likedByMeProfiles = [];
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final String likedUserId = data['likedUserId'];
        final String likedProfileDocumentId = data['likedProfileDocumentId'];
        final String likedUserProfileType = data['likedUserProfileType'];

        DocumentSnapshot? profileDoc;
        if (likedUserProfileType == 'flat_listing') {
          profileDoc = await _firestore.collection('users').doc(likedUserId).collection('flatListings').doc(likedProfileDocumentId).get();
        } else if (likedUserProfileType == 'seeking_flatmate') {
          profileDoc = await _firestore.collection('users').doc(likedUserId).collection('seekingFlatmateProfiles').doc(likedProfileDocumentId).get();
        }

        if (profileDoc != null && profileDoc.exists) {
          if (likedUserProfileType == 'flat_listing') {
            likedByMeProfiles.add(FlatListingProfile.fromMap(profileDoc.data() as Map<String, dynamic>, profileDoc.id));
          } else if (likedUserProfileType == 'seeking_flatmate') {
            likedByMeProfiles.add(SeekingFlatmateProfile.fromMap(profileDoc.data() as Map<String, dynamic>, profileDoc.id));
          }
        }
      }
      setState(() {
        _outgoingLikes[currentProfileId] = likedByMeProfiles;
      });
    } catch (e) {
      print('Error fetching outgoing likes: $e');
    }
  }
Future<void> _fetchFlatListingProfiles({
  bool applyFilters = false,
  
}) async {
  try {
    if (applyFilters) {
  _lastDocument = null;
  _hasMoreProfiles = true;
}
    Query query = _firestore
        .collectionGroup('flatListings')
        .where(
          'uid',
          isNotEqualTo: _currentUser!.uid,
        );
        debugPrint(
  'CURRENT USER PROFILE TYPE = ${_currentUserParsedProfile.runtimeType}',
);

debugPrint(
  'CURRENT FILTER CITY = ${_currentFilters.desiredCity}',
);

debugPrint(
  'DEFAULT CITY = $_defaultCity',
);

    if (applyFilters &&
        _currentUserParsedProfile
            is SeekingFlatmateProfile) {

      if (_defaultCity != null &&
    _defaultCity!.isNotEmpty) {

  debugPrint(
    'APPLYING CITY FILTER => $_defaultCity',
  );

  query = query.where(
    'city',
    isEqualTo: _defaultCity,
  );
}

      if (_currentFilters.availabilityDate !=
          null) {
        query = query.where(
          'availabilityDate',
          isGreaterThanOrEqualTo:
              _currentFilters
                  .availabilityDate,
        );
      }

      if (_currentFilters.flatType != null &&
          _currentFilters.flatType!
              .isNotEmpty) {
        query = query.where(
          'flatType',
          isEqualTo:
              _currentFilters.flatType,
        );
      }

      if (_currentFilters.roomType != null &&
          _currentFilters.roomType!
              .isNotEmpty) {
        query = query.where(
          'roomType',
          isEqualTo:
              _currentFilters.roomType,
        );
      }

      if (_currentFilters.furnishedStatus !=
              null &&
          _currentFilters
              .furnishedStatus!
              .isNotEmpty) {
        query = query.where(
          'furnishedStatus',
          isEqualTo:
              _currentFilters
                  .furnishedStatus,
        );
      }

      if (_currentFilters.bathroomType !=
              null &&
          _currentFilters
              .bathroomType!
              .isNotEmpty) {
        query = query.where(
          'bathroomType',
          isEqualTo:
              _currentFilters
                  .bathroomType,
        );
      }

      if (_currentFilters.leaseDuration !=
              null &&
          _currentFilters
              .leaseDuration!
              .isNotEmpty) {
        query = query.where(
          'leaseDuration',
          isEqualTo:
              _currentFilters
                  .leaseDuration,
        );
      }

      if (_currentFilters.availableFor !=
              null &&
          _currentFilters
              .availableFor!
              .isNotEmpty) {
        query = query.where(
          'availableFor',
          isEqualTo:
              _currentFilters
                  .availableFor,
        );
      }
    }

    // LIMIT RESULTS
    final QuerySnapshot querySnapshot =
    await query
        .limit(_pageSize)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
  _lastDocument =
      querySnapshot.docs.last;
}

_hasMoreProfiles =
    querySnapshot.docs.length ==
    _pageSize;

    // FETCH LIKED PROFILES
    final likedSnapshot =
        await _firestore
            .collection('user_likes')
            .doc(_currentUser!.uid)
            .collection('likes')
            .get();

    final likedIds =
        likedSnapshot.docs
            .map(
              (e) => e[
                  'likedProfileDocumentId'],
            )
            .toSet();

    debugPrint(
      'LIKED IDS COUNT: ${likedIds.length}',
    );

    final List<FlatListingProfile>
        fetchedProfiles =
        querySnapshot.docs
            .where(
              (doc) => !likedIds.contains(
                doc.id,
              ),
            )
            .map(
              (doc) =>
                  FlatListingProfile
                      .fromMap(
                doc.data()
                    as Map<
                        String,
                        dynamic>,
                doc.id,
              ),
            )
            .toList();

    // RENT FILTER
    if (_currentFilters.rentPriceMin !=
        null) {
      fetchedProfiles.removeWhere(
        (profile) =>
            profile.rentPrice == null ||
profile.rentPrice! <
_currentFilters.rentPriceMin!
      );
    }

    if (_currentFilters.rentPriceMax !=
        null) {
      fetchedProfiles.removeWhere(
        (profile) =>
            profile.rentPrice == null ||
profile.rentPrice! >
_currentFilters.rentPriceMax!
      );
    }

    // AMENITIES FILTER
    if (_currentFilters
        .amenitiesDesired.isNotEmpty) {
      fetchedProfiles.removeWhere(
        (profile) =>
            !_currentFilters
                .amenitiesDesired
                .every(
                  (a) => profile
                      .amenities
                      .contains(a),
                ),
      );
    }
 // LOCATION RADIUS FILTER
if (_activeLatitude != null &&
    _activeLongitude != null) {

  fetchedProfiles.removeWhere(
    (profile) {

      if (profile.latitude == null ||
          profile.longitude == null) {
        return true;
      }

      final distance =
          _calculateDistanceKm(
        _activeLatitude!,
        _activeLongitude!,
        profile.latitude!,
        profile.longitude!,
      );

      return distance >
          _currentFilters.searchRadiusKm;
    },
  );
}
if (_currentFilters.sortByNearest &&
    _activeLatitude != null &&
    _activeLongitude != null) {

  fetchedProfiles.sort(
    (a, b) {

      final distanceA =
          _calculateDistanceKm(
        _activeLatitude!,
        _activeLongitude!,
        a.latitude ?? 0,
        a.longitude ?? 0,
      );

      final distanceB =
          _calculateDistanceKm(
        _activeLatitude!,
        _activeLongitude!,
        b.latitude ?? 0,
        b.longitude ?? 0,
      );

      return distanceA.compareTo(
        distanceB,
      );
    },
  );
}
    // PHOTOS ONLY
    if (_currentFilters
        .profilesWithPhotosOnly) {
      fetchedProfiles.removeWhere(
        (profile) =>
            profile.imageUrls == null ||
profile.imageUrls!.isEmpty,
      );
    }

    debugPrint(
      'AFTER FILTERING LIKED: ${fetchedProfiles.length}',
    );

    setState(() {
      _profiles = fetchedProfiles;
      _isLoading = false;
    });
  } catch (e) {
    debugPrint(
      'FETCH FLAT LISTING ERROR: $e',
    );

    _showAlertDialog(
      'Error',
      'Failed to load flat listing profiles: $e',
      () {},
    );
  }
}
Future<void> _loadMoreFlatListings() async {

  if (_isLoadingMore ||
      !_hasMoreProfiles ||
      _lastDocument == null) {
    return;
  }

  setState(() {
    _isLoadingMore = true;
  });

  try {

    Query query = _firestore
        .collectionGroup('flatListings')
        .where(
          'uid',
          isNotEqualTo:
              _currentUser!.uid,
        );

    // APPLY SAME FILTERS
    if (_currentUserParsedProfile
        is SeekingFlatmateProfile) {

      if (_defaultCity != null &&
    _defaultCity!.isNotEmpty) {

  query = query.where(
    'city',
    isEqualTo: _defaultCity,
  );
}

      if (_currentFilters.availabilityDate !=
          null) {
        query = query.where(
          'availabilityDate',
          isGreaterThanOrEqualTo:
              _currentFilters
                  .availabilityDate,
        );
      }

      if (_currentFilters.flatType != null &&
          _currentFilters.flatType!
              .isNotEmpty) {
        query = query.where(
          'flatType',
          isEqualTo:
              _currentFilters.flatType,
        );
      }

      if (_currentFilters.roomType != null &&
          _currentFilters.roomType!
              .isNotEmpty) {
        query = query.where(
          'roomType',
          isEqualTo:
              _currentFilters.roomType,
        );
      }

      if (_currentFilters.furnishedStatus !=
              null &&
          _currentFilters
              .furnishedStatus!
              .isNotEmpty) {
        query = query.where(
          'furnishedStatus',
          isEqualTo:
              _currentFilters
                  .furnishedStatus,
        );
      }

      if (_currentFilters.bathroomType !=
              null &&
          _currentFilters
              .bathroomType!
              .isNotEmpty) {
        query = query.where(
          'bathroomType',
          isEqualTo:
              _currentFilters
                  .bathroomType,
        );
      }

      if (_currentFilters.leaseDuration !=
              null &&
          _currentFilters
              .leaseDuration!
              .isNotEmpty) {
        query = query.where(
          'leaseDuration',
          isEqualTo:
              _currentFilters
                  .leaseDuration,
        );
      }

      if (_currentFilters.availableFor !=
              null &&
          _currentFilters
              .availableFor!
              .isNotEmpty) {
        query = query.where(
          'availableFor',
          isEqualTo:
              _currentFilters
                  .availableFor,
        );
      }
    }

    final QuerySnapshot snapshot =
        await query
            .startAfterDocument(
              _lastDocument!,
            )
            .limit(_pageSize)
            .get();
  debugPrint(
  'FIRESTORE RETURNED ${snapshot.docs.length} DOCS',
);

for (final doc in snapshot.docs) {
  debugPrint(
    'CITY FROM FIRESTORE => ${doc['city']}',
  );
}

    if (snapshot.docs.isNotEmpty) {
      _lastDocument =
          snapshot.docs.last;
    }

    _hasMoreProfiles =
        snapshot.docs.length ==
        _pageSize;

    final likedSnapshot =
        await _firestore
            .collection('user_likes')
            .doc(_currentUser!.uid)
            .collection('likes')
            .get();

    final likedIds =
        likedSnapshot.docs
            .map(
              (e) => e[
                  'likedProfileDocumentId'],
            )
            .toSet();

    List<FlatListingProfile>
        newProfiles =
        snapshot.docs
            .where(
              (doc) =>
                  !likedIds.contains(
                doc.id,
              ),
            )
            .map(
              (doc) =>
                  FlatListingProfile
                      .fromMap(
                doc.data()
                    as Map<
                        String,
                        dynamic>,
                doc.id,
              ),
            )
            .toList();

    // LOCAL FILTERS

    if (_currentFilters.rentPriceMin !=
        null) {
      newProfiles.removeWhere(
         (p) =>
         p.rentPrice == null ||
        p.rentPrice! <
            _currentFilters
                .rentPriceMin!,
      );
    }

    if (_currentFilters.rentPriceMax !=
    null) {
  newProfiles.removeWhere(
    (p) =>
        p.rentPrice == null ||
        p.rentPrice! >
            _currentFilters
                .rentPriceMax!,
  );
}
    if (_currentFilters
        .amenitiesDesired.isNotEmpty) {

      newProfiles.removeWhere(
        (p) =>
            !_currentFilters
                .amenitiesDesired
                .every(
                  (a) => p.amenities
                      .contains(a),
                ),
      );
    }

    if (_currentFilters
        .profilesWithPhotosOnly) {

      newProfiles.removeWhere(
        (p) => p.imageUrls == null ||
p.imageUrls!.isEmpty,
      );
    }

    if (_activeLatitude != null &&
        _activeLongitude != null) {

      newProfiles.removeWhere(
        (p) {

          if (p.latitude == null ||
              p.longitude == null) {
            return true;
          }

          final distance =
              _calculateDistanceKm(
            _activeLatitude!,
            _activeLongitude!,
            p.latitude!,
            p.longitude!,
          );

          return distance >
              _currentFilters
                  .searchRadiusKm;
        },
      );
    }

    setState(() {
      _profiles.addAll(
        newProfiles,
      );
    });

  } catch (e) {

    debugPrint(
      'LOAD MORE FLAT LISTINGS ERROR: $e',
    );

  } finally {

    setState(() {
      _isLoadingMore = false;
    });
  }
}

  Future<void> _fetchSeekingFlatmateProfiles({
  bool applyFilters = false,
}) async {
  try {

    if (applyFilters) {
      _lastDocument = null;
      _hasMoreProfiles = true;
    }

    Query query = _firestore
        .collectionGroup(
          'seekingFlatmateProfiles',
        )
        .where(
          'uid',
          isNotEqualTo: _currentUser!.uid,
        );
        debugPrint(
  'CURRENT USER PROFILE TYPE = ${_currentUserParsedProfile.runtimeType}',
);

debugPrint(
  'CURRENT FILTER CITY = ${_currentFilters.desiredCity}',
);

debugPrint(
  'DEFAULT CITY = $_defaultCity',
);

    if (applyFilters &&
        _currentUserParsedProfile
            is FlatListingProfile) {

     if (_defaultCity != null &&
    _defaultCity!.isNotEmpty) {
 debugPrint(
    'APPLYING CITY FILTER => $_defaultCity',
  );
  query = query.where(
    'city',
    isEqualTo: _defaultCity,
  );
}

      if (_currentFilters.moveInDate != null) {
        query = query.where(
          'moveInDate',
          isLessThanOrEqualTo:
              _currentFilters.moveInDate,
        );
      }

      if (_currentFilters.gender != null &&
          _currentFilters.gender!
              .isNotEmpty) {
        query = query.where(
          'gender',
          isEqualTo:
              _currentFilters.gender,
        );
      }

      if (_currentFilters.occupation != null &&
          _currentFilters.occupation!
              .isNotEmpty) {
        query = query.where(
          'occupation',
          isEqualTo:
              _currentFilters.occupation,
        );
      }
    }

    final QuerySnapshot querySnapshot =
        await query
            .limit(_pageSize)
            .get();
 debugPrint(
  'FIRESTORE RETURNED ${querySnapshot.docs.length} DOCS',
);

for (final doc in querySnapshot.docs) {
  debugPrint(
    'CITY FROM FIRESTORE => ${doc['city']}',
  );
}

    if (querySnapshot.docs.isNotEmpty) {

      _lastDocument =
          querySnapshot.docs.last;
    }

    _hasMoreProfiles =
        querySnapshot.docs.length ==
        _pageSize;

    final likedSnapshot =
        await _firestore
            .collection('user_likes')
            .doc(_currentUser!.uid)
            .collection('likes')
            .get();

    final likedIds =
        likedSnapshot.docs
            .map(
              (e) => e[
                  'likedProfileDocumentId'],
            )
            .toSet();

    debugPrint(
      'LIKED IDS COUNT: ${likedIds.length}',
    );

    final List<SeekingFlatmateProfile>
        fetchedProfiles =
        querySnapshot.docs
            .where(
              (doc) =>
                  !likedIds.contains(
                doc.id,
              ),
            )
            .map(
              (doc) =>
                  SeekingFlatmateProfile
                      .fromMap(
                doc.data()
                    as Map<
                        String,
                        dynamic>,
                doc.id,
              ),
            )
            .toList();

    // BUDGET FILTER
   // BUDGET FILTER

if (_currentFilters.budgetMin != null) {
  fetchedProfiles.removeWhere(
    (profile) =>
        profile.budgetMax == null ||
        profile.budgetMax! <
            _currentFilters.budgetMin!,
  );
}

if (_currentFilters.budgetMax != null) {
  fetchedProfiles.removeWhere(
    (profile) =>
        profile.budgetMin == null ||
        profile.budgetMin! >
            _currentFilters.budgetMax!,
  );
}

// AGE FILTER
// REMOVE COMPLETELY

    // LOCATION RADIUS FILTER
    if (_activeLatitude != null &&
        _activeLongitude != null) {

      fetchedProfiles.removeWhere(
        (profile) {

          if (profile.latitude == null ||
              profile.longitude == null) {
            return true;
          }

          final distance =
              _calculateDistanceKm(
            _activeLatitude!,
            _activeLongitude!,
            profile.latitude!,
            profile.longitude!,
          );

          return distance >
              _currentFilters
                  .searchRadiusKm;
        },
      );
    }

    // SORT NEAREST
    if (_currentFilters.sortByNearest &&
        _activeLatitude != null &&
        _activeLongitude != null) {

      fetchedProfiles.sort(
        (a, b) {

          final distanceA =
              _calculateDistanceKm(
            _activeLatitude!,
            _activeLongitude!,
            a.latitude ?? 0,
            a.longitude ?? 0,
          );

          final distanceB =
              _calculateDistanceKm(
            _activeLatitude!,
            _activeLongitude!,
            b.latitude ?? 0,
            b.longitude ?? 0,
          );

          return distanceA.compareTo(
            distanceB,
          );
        },
      );
    }

    // PHOTOS ONLY
    if (_currentFilters
        .profilesWithPhotosOnly) {

      fetchedProfiles.removeWhere(
        (profile) =>
            profile.imageUrls == null ||
profile.imageUrls!.isEmpty,
      );
    }

    debugPrint(
      'AFTER FILTERING LIKED SEEKING FLATMATES: ${fetchedProfiles.length}',
    );

    setState(() {
      _profiles = fetchedProfiles;
      _isLoading = false;
    });

  } catch (e) {

    debugPrint(
      'FETCH SEEKING FLATMATE ERROR: $e',
    );

    _showAlertDialog(
      'Error',
      'Failed to load seeking flatmate profiles: $e',
      () {},
    );
  }
}
Future<void> _loadMoreSeekingFlatmates() async {

  if (_isLoadingMore ||
      !_hasMoreProfiles ||
      _lastDocument == null) {
    return;
  }

  setState(() {
    _isLoadingMore = true;
  });

  try {

    Query query = _firestore
        .collectionGroup(
          'seekingFlatmateProfiles',
        )
        .where(
          'uid',
          isNotEqualTo:
              _currentUser!.uid,
        );

    // APPLY SAME FILTERS
    if (_currentUserParsedProfile
        is FlatListingProfile) {

      if (_defaultCity != null &&
    _defaultCity!.isNotEmpty) {

  query = query.where(
    'city',
    isEqualTo: _defaultCity,
  );
}

      if (_currentFilters.moveInDate !=
          null) {
        query = query.where(
          'moveInDate',
          isLessThanOrEqualTo:
              _currentFilters.moveInDate,
        );
      }

      if (_currentFilters.gender != null &&
          _currentFilters.gender!
              .isNotEmpty) {
        query = query.where(
          'gender',
          isEqualTo:
              _currentFilters.gender,
        );
      }

      if (_currentFilters.occupation != null &&
          _currentFilters.occupation!
              .isNotEmpty) {
        query = query.where(
          'occupation',
          isEqualTo:
              _currentFilters.occupation,
        );
      }
    }

    final QuerySnapshot snapshot =
        await query
            .startAfterDocument(
              _lastDocument!,
            )
            .limit(_pageSize)
            .get();

    if (snapshot.docs.isNotEmpty) {
      _lastDocument =
          snapshot.docs.last;
    }

    _hasMoreProfiles =
        snapshot.docs.length ==
        _pageSize;

    final likedSnapshot =
        await _firestore
            .collection('user_likes')
            .doc(_currentUser!.uid)
            .collection('likes')
            .get();

    final likedIds =
        likedSnapshot.docs
            .map(
              (e) => e[
                  'likedProfileDocumentId'],
            )
            .toSet();

    List<SeekingFlatmateProfile>
        newProfiles =
        snapshot.docs
            .where(
              (doc) =>
                  !likedIds.contains(
                doc.id,
              ),
            )
            .map(
              (doc) =>
                  SeekingFlatmateProfile
                      .fromMap(
                doc.data()
                    as Map<String, dynamic>,
                doc.id,
              ),
            )
            .toList();

    // BUDGET FILTER
    // BUDGET FILTER

if (_currentFilters.budgetMin != null) {
  newProfiles.removeWhere(
    (p) =>
        p.budgetMax == null ||
        p.budgetMax! <
            _currentFilters.budgetMin!,
  );
}

if (_currentFilters.budgetMax != null) {
  newProfiles.removeWhere(
    (p) =>
        p.budgetMin == null ||
        p.budgetMin! >
            _currentFilters.budgetMax!,
  );
}

// AGE FILTER
// REMOVE COMPLETELY
    

    // LOCATION FILTER
    if (_activeLatitude != null &&
        _activeLongitude != null) {

      newProfiles.removeWhere(
        (p) {

          if (p.latitude == null ||
              p.longitude == null) {
            return true;
          }

          final distance =
              _calculateDistanceKm(
            _activeLatitude!,
            _activeLongitude!,
            p.latitude!,
            p.longitude!,
          );

          return distance >
              _currentFilters
                  .searchRadiusKm;
        },
      );
    }

    // SORT NEAREST
    if (_currentFilters.sortByNearest &&
        _activeLatitude != null &&
        _activeLongitude != null) {

      newProfiles.sort(
        (a, b) {

          final distanceA =
              _calculateDistanceKm(
            _activeLatitude!,
            _activeLongitude!,
            a.latitude ?? 0,
            a.longitude ?? 0,
          );

          final distanceB =
              _calculateDistanceKm(
            _activeLatitude!,
            _activeLongitude!,
            b.latitude ?? 0,
            b.longitude ?? 0,
          );

          return distanceA.compareTo(
            distanceB,
          );
        },
      );
    }

    // PHOTOS ONLY
    if (_currentFilters
        .profilesWithPhotosOnly) {

      newProfiles.removeWhere(
        (p) => p.imageUrls == null ||
p.imageUrls!.isEmpty,
      );
    }

    setState(() {
      _profiles.addAll(
        newProfiles,
      );
    });

    debugPrint(
      'LOADED ${newProfiles.length} MORE SEEKING FLATMATES',
    );

  } catch (e) {

    debugPrint(
      'LOAD MORE SEEKING FLATMATES ERROR: $e',
    );

  } finally {

    setState(() {
      _isLoadingMore = false;
    });
  }
}
void _showCreateProfileRequiredDialog() {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Text(
        "Create Profile First",
      ),
      content: const Text(
        "You can explore profiles freely.\n\nCreate your profile to like, connect and chat with others.",
      ),
      actions: [

        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            "Later",
          ),
        ),

        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);

            if (widget.profileType ==
                "flat_listing") {

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      FlatWithFlatmateProfileScreen(
                    initialPhoneNumber:
                        null,
                  ),
                ),
              );

            } else {

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      FlatmateProfileScreen(
                    initialPhoneNumber:
                        null,
                  ),
                ),
              );

            }
          },
          child: const Text(
            "Create Profile",
          ),
        ),
      ],
    ),
  );
}
  void _showAlertDialog(String title, String message, VoidCallback onPressed) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onPressed();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }


  void _onFiltersChanged(FilterOptions newFilters) {
    setState(() {
      _currentFilters = newFilters;
      debugPrint(
    "FILTER ADDRESS = ${newFilters.locationName}");

debugPrint(
    "FILTER LAT = ${newFilters.latitude}");

debugPrint(
    "FILTER LNG = ${newFilters.longitude}");
    });
    if (widget.isExploreMode) {

  if (widget.profileType == "flat_listing") {
    _fetchFlatListingProfiles(
      applyFilters: true,
    );
  } else {
    _fetchSeekingFlatmateProfiles(
      applyFilters: true,
    );
  }

} else {

  _fetchUserProfile(
    applyFilters: true,
  );

}
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop(); // Close the drawer after applying filters
    }
  }

// matching_screen.dart
// matching_screen.dart

  // matching_screen.dart

  Future<void> _processLike(String likedUserId, String likedProfileDocumentId) async {
    if (_currentUser == null) {
      print("_processLike: Current user is null. Aborting like process.");
      return;
    }

    final currentUserId = _currentUser!.uid;
    final String currentUserProfileType = widget.profileType;

    print("_processLike: User $currentUserId (active profile ${widget.profileId}) attempting to like user $likedUserId's profile $likedProfileDocumentId.");

    String likedUserProfileType;
    if (currentUserProfileType == 'seeking_flatmate') {
      likedUserProfileType = 'flat_listing';
    } else if (currentUserProfileType == 'flat_listing') {
      likedUserProfileType = 'seeking_flatmate';
    } else {
      print("Warning: Unknown current user profile type: ${currentUserProfileType}. Assigning 'unknown' to likedUserProfileType.");
      likedUserProfileType = 'unknown';
    }
    print('Determined likedUserProfileType: $likedUserProfileType');


    try {
      print("_processLike (Op1): Attempting to record like for $currentUserId on $likedProfileDocumentId.");
      try {
        await _firestore.collection('user_likes').doc(currentUserId).collection('likes').doc(likedProfileDocumentId).set({
          'timestamp': FieldValue.serverTimestamp(),
          'likedUserId': likedUserId,
          'likedProfileDocumentId': likedProfileDocumentId,
          'likingUserProfileId': widget.profileId,
          'likingUserId': currentUserId,
          'likingUserProfileType': currentUserProfileType,
          'likedUserProfileType': likedUserProfileType,
        });
        print("_processLike (Op1): Successfully recorded like for $currentUserId on profile $likedProfileDocumentId.");

        // Update local outgoing likes
        setState(() {
          // Replaced firstWhere with a manual loop for robustness (previous fix)
          dynamic likedProfile;
          for (var p in _profiles) {
            if (p.documentId == likedProfileDocumentId) {
              likedProfile = p;
              break;
            }
          }

          if (likedProfile != null) {
            if (!_outgoingLikes.containsKey(widget.profileId)) {
              _outgoingLikes[widget.profileId] = [];
            }
            if (!_outgoingLikes[widget.profileId]!.any((p) => p.documentId == likedProfile.documentId)) {
              _outgoingLikes[widget.profileId]!.add(likedProfile);
            }
          } else {
            print("Warning: Liked profile with ID $likedProfileDocumentId not found in _profiles list during outgoing likes update.");
          }
        });

        // --- NEW ADDITION: Contact Reveal Logic ---
        // MODIFICATION START: Replaced firstWhere with a manual loop for robustness here too
        dynamic likedProfileObject;
        for (var profile in _profiles) {
          if (profile.documentId == likedProfileDocumentId) {
            likedProfileObject = profile;
            break;
          }
        }
        // MODIFICATION END

        if (likedProfileObject != null) {
          if (_remainingContacts > 0) {
            // Show contact reveal popup if contacts are available
            _showContactRevealPopup(likedUserId, likedProfileObject); // MODIFIED LINE
          } else {
            // Show out of contacts message or direct to plans
            _showOutOfContactsPopup();
          }
        } else {
          print("Warning: Liked profile object not found in _profiles for contact reveal.");
        }
        // --- END NEW ADDITION ---

      } catch (e) {
        print("_processLike (Op1) ERROR: Failed to SET like document: $e");
        _showAlertDialog('Error', 'Failed to record your like: ${e.toString()}', () {});
        return; // Exit if recording the like failed
      }

      print("_processLike (Op2): Checking if user $likedUserId has liked our active profile ${widget.profileId}.");
      QuerySnapshot otherUserLikesOurProfile;
      try {
        otherUserLikesOurProfile = await _firestore.collection('user_likes').doc(likedUserId).collection('likes')
            .where('likedUserId', isEqualTo: currentUserId)
            .where('likedProfileDocumentId', isEqualTo: widget.profileId)
            .get();
        print("_processLike (Op2): Other user like check completed. Exists: ${otherUserLikesOurProfile.docs.isNotEmpty}");
      } catch (e) {
        print("_processLike (Op2) ERROR: Failed to GET other user's like: $e");
        _showAlertDialog('Error', 'Failed to check for mutual like: ${e.toString()}', () {});
        return; // Exit if checking for mutual like failed
      }

      if (otherUserLikesOurProfile.docs.isNotEmpty) {
        print("_processLike: Mutual like detected! IT'S A MATCH!");
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('It\'s a MATCH! 🎉'))
        );

        setState(() {
          _bannerMessage = null;
          _lastLikedProfileName = null;
        });

        try {
          await _createMatchAndChatRoom(
            currentUserId,
            widget.profileId,
            currentUserProfileType,
            likedUserId,
            likedProfileDocumentId,
            likedUserProfileType,
          );
          print("_processLike (Op3): _createMatchAndChatRoom call completed successfully.");
        } catch (e) {
          print("_processLike (Op3) ERROR: _createMatchAndChatRoom failed: $e");
          _showAlertDialog('Error', 'Failed to create match/chat: ${e.toString()}', () {});
          return; // Exit if match/chat creation failed
        }

        String chatPartnerNameForDialog = 'that user';
        try {
          // This firstWhere call should be safe as it's outside the problematic context
          final matchedProfile = _profiles.firstWhere((p) => p.documentId == likedProfileDocumentId);
          chatPartnerNameForDialog = _getProfileDisplayName(matchedProfile);
        } catch (e) {
          print("_processLike: Could not find matched profile in _profiles for dialog. Error: $e");
        }

        if (mounted) {
          _showMatchDialog(
            'It\'s a Match!',
            'You and ${chatPartnerNameForDialog} have liked each other! Start chatting now?',
                () {
              if (mounted) {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      chatPartnerId: likedUserId,
                      chatPartnerName: chatPartnerNameForDialog,
                    ),
                  ),
                );
              }
            },
          );
        }
      } else {
        print("_processLike: No mutual like yet. Liked profile, awaiting response.");
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile Liked! Awaiting their response.'))
        );
      }
    } catch (e) {
      print("_processLike: UNEXPECTED GLOBAL ERROR: $e");
      _showAlertDialog('Error', 'An unexpected error occurred: ${e.toString()}', () {});
    }
  }
// New: Function to show contact reveal popup
  void _showContactRevealPopup(String likedUserId, dynamic matchedProfile) {
    String profileName = '';

    if (matchedProfile is FlatListingProfile) {
      profileName = matchedProfile.userProfile.name ?? 'Flat Owner';
    } else if (matchedProfile is SeekingFlatmateProfile) {
      profileName = matchedProfile.userProfile.name ?? 'Flatmate Seeker';
    }
    String? imageUrl; // Get the actual image URL here
    if ( matchedProfile  is FlatListingProfile && matchedProfile .imageUrls != null && matchedProfile .imageUrls!.isNotEmpty) {
      imageUrl = matchedProfile .imageUrls!.first;
    } else if (matchedProfile  is SeekingFlatmateProfile && matchedProfile .imageUrls != null && matchedProfile .imageUrls!.isNotEmpty) {
      imageUrl = matchedProfile .imageUrls!.first;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BannerPopupScreen(
          message: 'Get Contact Details?',
          subMessage: 'You have $_remainingContacts contacts remaining.\nDo you want to reveal $profileName\'s contact information for 1 contact?',
          profileImageUrl:imageUrl, // Assuming your profile models have this property
          buttonText: 'Get Contact',
          onButtonPressed: () async {
            Navigator.of(context).pop(); // Dismiss popup
            await _revealContactAndDecrement(likedUserId, matchedProfile);
          },
        );
      },
    );
  }
  // New: Function to show out of contacts popup
  void _showOutOfContactsPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BannerPopupScreen(
          message: 'Out of Contacts!',
          subMessage: 'You have no remaining contacts. Please purchase a plan to get more contacts.',
          buttonText: 'View Plans',
          onButtonPressed: () {
            Navigator.of(context).pop(); // Dismiss this popup
            Navigator.pushNamed(context, '/plans');
          },
        );
      },
    );
  }


  // New: Function to reveal contact and decrement remaining contacts
  Future<void> _revealContactAndDecrement(
      String targetUserId,
      dynamic matchedProfile,
      ) async {
    if (_currentUser == null) return;

    final String targetProfileId = matchedProfile.documentId;

    try {
      if (_remainingContacts > 0) {
        await _firestore.collection('users').doc(_currentUser!.uid).update({
          'remainingContacts': FieldValue.increment(-1),
        });
        setState(() {
          _remainingContacts--;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No remaining contacts to reveal.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final likeDocRef = _firestore
          .collection('user_likes')
          .doc(_currentUser!.uid)
          .collection('likes')
          .doc(targetProfileId);

      final docSnapshot = await likeDocRef.get();
      if (docSnapshot.exists) {
        await likeDocRef.update({
          'contactRevealed': true,
        });
      } else {
        print('Warning: Like document with ID $targetProfileId not found for marking contact revealed. This might be an issue.');
      }

      String contactNumber = '';
      String contactEmail = '';
      String profileName = '';

      if (matchedProfile is FlatListingProfile) {
        // contactNumber = matchedProfile.ownerPhoneNumber ?? 'N/A'; // Assuming this property exists
        // contactEmail = matchedProfile.ownerEmail ?? 'N/A';     // Assuming this property exists
        profileName = matchedProfile.userProfile.name ?? 'Flat Owner';
      } else if (matchedProfile is SeekingFlatmateProfile) {
        //contactNumber = matchedProfile.phoneNumber ?? 'N/A'; // Assuming this property exists
        //  contactEmail = matchedProfile.email ?? 'N/A';       // Assuming this property exists
        profileName = matchedProfile.userProfile.name ?? 'Flatmate Seeker';
      }
      String? imageUrl; // Get the actual image URL here
      if ( matchedProfile  is FlatListingProfile && matchedProfile .imageUrls != null && matchedProfile .imageUrls!.isNotEmpty) {
        imageUrl = matchedProfile .imageUrls!.first;
      } else if (matchedProfile  is SeekingFlatmateProfile && matchedProfile .imageUrls != null && matchedProfile .imageUrls!.isNotEmpty) {
        imageUrl = matchedProfile .imageUrls!.first;
      }


      // Display contact details using BannerPopupScreen
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return BannerPopupScreen(
            message: '$profileName\'s Contact Details',
            subMessage: 'Remaining contacts: $_remainingContacts',
            profileImageUrl: imageUrl, // Assuming profile models have this
            // contactPhoneNumber: contactNumber, // Pass the revealed phone number
            buttonText: 'Close',
            onButtonPressed: () {
              Navigator.of(context).pop();
            },
          );
        },
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contact revealed successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error revealing contact or decrementing: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to reveal contact: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  // This function checks if the banner should be displayed
  Future<void> _checkForBanner() async {

  debugPrint(
    'CHECK BANNER => $_interactionCount',
  );

  if (_interactionCount < 2 ||
      _interactionCount % 2 != 0) {
    return;
  }

  if (_lastLikedProfile == null) {
    debugPrint(
      'NO LAST LIKED PROFILE',
    );
    return;
  }

  debugPrint(
    'SHOWING BANNER FOR ${_lastLikedProfile.documentId}',
  );

  _showBannerPopup(
    _lastLikedProfile,
  );
}

  // NEW: Function to show the banner popup
 Future<void> _showBannerPopup(
  dynamic likedProfile,
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
  widget.profileId,
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
      await _createMatchAndChatRoom(
        _currentUser!.uid,
        widget.profileId,
        widget.profileType,
        likedProfile.uid,
        likedProfile.documentId!,
        widget.profileType ==
                'flat_listing'
            ? 'seeking_flatmate'
            : 'flat_listing',
      );
      final sortedProfileIds = [
  widget.profileId,
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
      widget.profileId,

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
      widget.profileId,

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

  // This function is for creating a match document and a chat room
 Future<void> _createMatchAndChatRoom(
  String user1Uid,
  String user1ProfileId,
  String user1ProfileType,
  String user2Uid,
  String user2ProfileId,
  String user2ProfileType,
) async {

  List<String> sortedProfileIds = [
    user1ProfileId,
    user2ProfileId,
  ]..sort();

  String matchDocId =
      '${sortedProfileIds[0]}_${sortedProfileIds[1]}';

  print(
    "createMatchAndChatRoom: Attempting to check existence of match for profiles: $matchDocId",
  );

  try {

    DocumentSnapshot matchDoc =
        await _firestore
            .collection('matches')
            .doc(matchDocId)
            .get();

    print(
      "createMatchAndChatRoom: Match document existence check result: ${matchDoc.exists}",
    );

    if (!matchDoc.exists) {

      print(
        "createMatchAndChatRoom: Match document for profiles does not exist. Proceeding to create chat and match.",
      );

      // CHAT ID = phone_uid_phone_uid

      List<String> participants = [
        user1Uid,
        user2Uid,
      ]..sort();

      String chatRoomId =
          participants.join('_');

      // CREATE CHAT ONLY IF NOT EXISTS

      DocumentSnapshot chatDoc =
          await _firestore
              .collection('chats')
              .doc(chatRoomId)
              .get();

      if (!chatDoc.exists) {

        await _firestore
            .collection('chats')
            .doc(chatRoomId)
            .set({

          'participants': [
            user1Uid,
            user2Uid,
          ],

          'participants_profile_ids':
              sortedProfileIds,

          'createdAt':
              FieldValue.serverTimestamp(),

          'lastMessage': '',

          'lastMessageSenderId': '',

          'lastMessageTimestamp':
              null,

          'conversationUnlocked':
              false,

          'unlockedByUid':
              null,

          'unlockedByProfileId':
              null,

          'unlockedAt':
              null,
        });

        print(
          "createMatchAndChatRoom: Chat created with ID: $chatRoomId",
        );

      } else {

        print(
          "createMatchAndChatRoom: Chat already exists: $chatRoomId",
        );
      }

      await _firestore
          .collection('matches')
          .doc(matchDocId)
          .set({

        'user1_uid':
            user1Uid,

        'user2_uid':
            user2Uid,

        'user1_profile_id':
            user1ProfileId,

        'user2_profile_id':
            user2ProfileId,

        'user1_profile_type':
            user1ProfileType,

        'user2_profile_type':
            user2ProfileType,

        'chatRoomId':
            chatRoomId,

        'createdAt':
            FieldValue.serverTimestamp(),
      });

      print(
        "createMatchAndChatRoom: Match document created successfully for profiles: $matchDocId",
      );

    } else {

      print(
        "createMatchAndChatRoom: Match document for profiles already exists.",
      );

      String chatRoomId =
          (matchDoc.data()
              as Map<String, dynamic>)['chatRoomId'];

      print(
        "createMatchAndChatRoom: Existing chatRoomId: $chatRoomId",
      );
    }

  } catch (e) {

    print(
      "createMatchAndChatRoom ERROR: $e",
    );

    rethrow;
  }
}
  void _showMatchDialog(String title, String message, VoidCallback onChatPressed) {
    showDialog(
      context: context,
      barrierDismissible: false, // User must tap a button to dismiss
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
              child: const Text('Later'),
            ),
            ElevatedButton(
              onPressed: onChatPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFAD1457), // Changed to consistent primary button color
                foregroundColor: Colors.white,
              ),
              child: const Text('Chat Now'),
            ),
          ],
        );
      },
    );
  }
  // MODIFIED: _handleProfileDismissed now only contains the logic for managing state
  void _handleProfileDismissed(DismissDirection direction) {
    if (_profiles.isEmpty) {
      print("_handleProfileDismissed: No profiles to dismiss.");
      return;
    }

    final dismissedProfile = _profiles[0]; // Always dismiss the top card
    String likedOrPassedUserId = '';
    String dismissedProfileDocId = '';
    if (dismissedProfile is FlatListingProfile) {
      likedOrPassedUserId = dismissedProfile.uid!;
      dismissedProfileDocId = dismissedProfile.documentId!;
    } else if (dismissedProfile is SeekingFlatmateProfile) {
      likedOrPassedUserId = dismissedProfile.uid!;
      dismissedProfileDocId = dismissedProfile.documentId!;
    } else {
      print("Error: Unknown profile type encountered in _handleProfileDismissed");
      return;
    }

    // NEW: Increment interaction count regardless of like or dislike
    _interactionCount++;

  if (direction ==
    DismissDirection.startToEnd) {

  _lastLikedProfile =
      dismissedProfile;

  debugPrint(
    'SAVING LAST LIKED PROFILE = ${dismissedProfile.documentId}',
  );

  if (widget.isExploreMode) {

    _showCreateProfileRequiredDialog();

  } else {

    _processLike(
      likedOrPassedUserId,
      dismissedProfileDocId,
    );

  }

}
else if (direction == DismissDirection.endToStart) {

  _lastPassedProfile = dismissedProfile;
  _canUndoPass = true;

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Profile Passed'),
    ),
  );
}

    // FIX: Remove the dismissed profile from the list to trigger a rebuild
    setState(() {
  _profiles.removeAt(0);
  _checkForBanner();
});

if (_profiles.length <= 10 &&
    !_isLoadingMore &&
    _hasMoreProfiles) {

  if (widget.isExploreMode) {
  // ============================================================
  // EXPLORE MODE PAGINATION
  // ============================================================

  if (_exploreType == "flat_listing") {
    // Currently exploring Rooms
    _loadMoreFlatListings();
  } else {
    // Currently exploring Flatmates
    _loadMoreSeekingFlatmates();
  }
} else {
  // ============================================================
  // NORMAL MATCHING MODE PAGINATION
  // ============================================================

  if (_currentUserParsedProfile is SeekingFlatmateProfile) {
    // Seeking Flatmate profile searches for Rooms
    _loadMoreFlatListings();
  } else {
    // Flat Listing profile searches for Flatmates
    _loadMoreSeekingFlatmates();
  }
}
}
    if (_profiles.isEmpty) {
      // Show a message or fetch more profiles when the list is empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No more profiles to show. Check back later!')),
      );
    }
  }
  void _undoLastPass() {
  if (_lastPassedProfile == null) return;

  setState(() {
    _profiles.insert(
      0,
      _lastPassedProfile,
    );

    _lastPassedProfile = null;
    _canUndoPass = false;
  });

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Profile Restored'),
    ),
  );
}

int _calculateMatchPercentage(
  dynamic userProfile,
  dynamic otherProfile,
) {
 int score = 0;

// Prevent NoSuchMethodError when either profile is null
if (userProfile == null || otherProfile == null) {
  return 0;
}

final double? myLat = userProfile.latitude;
final double? myLng = userProfile.longitude;

final double? otherLat = otherProfile.latitude;
final double? otherLng = otherProfile.longitude;

// -------------------------
// LOCATION SCORE (25)
// -------------------------
if (myLat != null &&
    myLng != null &&
    otherLat != null &&
    otherLng != null) {

  final distance = _calculateDistanceKm(
    myLat,
    myLng,
    otherLat,
    otherLng,
  );

  if (distance <= 2) {
    score += 25;
  } else if (distance <= 5) {
    score += 22;
  } else if (distance <= 10) {
    score += 18;
  } else if (distance <= 20) {
    score += 14;
  } else if (distance <= 40) {
    score += 8;
  } else {
    score += 2;
  }
}
  // -------------------------
// BUDGET SCORE (20)
// -------------------------

if (userProfile is SeekingFlatmateProfile &&
    otherProfile is FlatListingProfile) {

  final budgetMin = userProfile.budgetMin ?? 0;
  final budgetMax = userProfile.budgetMax ?? 0;
  final rent = otherProfile.rentPrice ?? 0;

  if (rent >= budgetMin && rent <= budgetMax) {

    score += 20;

  } else if (rent <= budgetMax * 1.10) {

    score += 12;

  } else if (rent <= budgetMax * 1.20) {

    score += 6;
  }
}

else if (userProfile is FlatListingProfile &&
         otherProfile is SeekingFlatmateProfile) {

  final rent = userProfile.rentPrice ?? 0;
  final budgetMin = otherProfile.budgetMin ?? 0;
  final budgetMax = otherProfile.budgetMax ?? 0;

  if (rent >= budgetMin && rent <= budgetMax) {

    score += 20;

  } else if (rent <= budgetMax * 1.10) {

    score += 12;

  } else if (rent <= budgetMax * 1.20) {

    score += 6;
  }
}
// -------------------------
// MOVE-IN / AVAILABILITY (10)
// -------------------------

if (userProfile is SeekingFlatmateProfile &&
    otherProfile is FlatListingProfile) {

  final moveIn = userProfile.moveInDate;
  final available = otherProfile.availabilityDate;

  if (moveIn != null && available != null) {

    final difference =
        (moveIn.difference(available).inDays).abs();

    if (difference <= 7) {

      score += 10;

    } else if (difference <= 15) {

      score += 7;

    } else if (difference <= 30) {

      score += 4;
    }
  }
}

else if (userProfile is FlatListingProfile &&
         otherProfile is SeekingFlatmateProfile) {

  final available = userProfile.availabilityDate;
  final moveIn = otherProfile.moveInDate;

  if (moveIn != null && available != null) {

    final difference =
        (moveIn.difference(available).inDays).abs();

    if (difference <= 7) {

      score += 10;

    } else if (difference <= 15) {

      score += 7;

    } else if (difference <= 30) {

      score += 4;
    }
  }
}
// -------------------------
// GENDER PREFERENCE (10)
// -------------------------

String? myGender;
String? otherGender;

if (userProfile is FlatListingProfile) {
  myGender = userProfile.userProfile.gender;
} else if (userProfile is SeekingFlatmateProfile) {
  myGender = userProfile.userProfile.gender;
}

if (otherProfile is FlatListingProfile) {
  otherGender = otherProfile.userProfile.gender;
} else if (otherProfile is SeekingFlatmateProfile) {
  otherGender = otherProfile.userProfile.gender;
}

// Flat Owner's preference
if (userProfile is FlatListingProfile &&
    otherProfile is SeekingFlatmateProfile) {

  final preferredGender =
      userProfile.preferredGender?.trim().toLowerCase();

  if (preferredGender == null ||
      preferredGender.isEmpty ||
      preferredGender == "any" ||
      preferredGender == "no preference") {

    score += 10;

  } else if (otherGender != null &&
      preferredGender == otherGender.toLowerCase()) {

    score += 10;
  }
}

// Flatmate's preference
else if (userProfile is SeekingFlatmateProfile &&
         otherProfile is FlatListingProfile) {

  final preferredGender =
      userProfile.preferredFlatmateGender
          ?.trim()
          .toLowerCase();

  if (preferredGender == null ||
      preferredGender.isEmpty ||
      preferredGender == "any" ||
      preferredGender == "no preference") {

    score += 10;

  } else if (otherGender != null &&
      preferredGender == otherGender.toLowerCase()) {

    score += 10;
  }
}
// -------------------------
// OCCUPATION (8)
// -------------------------

String? myOccupation;
String? otherOccupation;

if (userProfile is FlatListingProfile) {
  myOccupation = userProfile.userProfile.occupation;
} else if (userProfile is SeekingFlatmateProfile) {
  myOccupation = userProfile.userProfile.occupation;
}

if (otherProfile is FlatListingProfile) {
  otherOccupation = otherProfile.userProfile.occupation;
} else if (otherProfile is SeekingFlatmateProfile) {
  otherOccupation = otherProfile.userProfile.occupation;
}

// Flat Owner preference
if (userProfile is FlatListingProfile &&
    otherProfile is SeekingFlatmateProfile) {

  final preferredOccupation =
      userProfile.preferredOccupation
          ?.trim()
          .toLowerCase();

  if (preferredOccupation == null ||
      preferredOccupation.isEmpty ||
      preferredOccupation == "any" ||
      preferredOccupation == "no preference") {

    score += 8;

  } else if (otherOccupation != null &&
      preferredOccupation ==
          otherOccupation.toLowerCase()) {

    score += 8;

  } else {

    score += 2;
  }
}

// Flatmate preference
else if (userProfile is SeekingFlatmateProfile &&
         otherProfile is FlatListingProfile) {

  final preferredOccupation =
      userProfile.preferredOccupation
          ?.trim()
          .toLowerCase();

  if (preferredOccupation == null ||
      preferredOccupation.isEmpty ||
      preferredOccupation == "any" ||
      preferredOccupation == "no preference") {

    score += 8;

  } else if (otherOccupation != null &&
      preferredOccupation ==
          otherOccupation.toLowerCase()) {

    score += 8;

  } else {

    score += 2;
  }
}
// -------------------------
// PROPERTY COMPATIBILITY (8)
// -------------------------

if (userProfile is SeekingFlatmateProfile &&
    otherProfile is FlatListingProfile) {

  // Flat Type
  if (userProfile.preferredFlatType != null &&
      userProfile.preferredFlatType!.isNotEmpty &&
      otherProfile.flatType != null &&
      userProfile.preferredFlatType!
              .toLowerCase() ==
          otherProfile.flatType!
              .toLowerCase()) {
    score += 3;
  }

  // Room Type
  if (userProfile.preferredRoomType != null &&
      userProfile.preferredRoomType!.isNotEmpty &&
      otherProfile.roomType != null &&
      userProfile.preferredRoomType!
              .toLowerCase() ==
          otherProfile.roomType!
              .toLowerCase()) {
    score += 3;
  }

  // Furnished
  if (userProfile.preferredFurnishedStatus != null &&
      userProfile.preferredFurnishedStatus!.isNotEmpty &&
      otherProfile.furnishedStatus != null &&
      userProfile.preferredFurnishedStatus!
              .toLowerCase() ==
          otherProfile.furnishedStatus!
              .toLowerCase()) {
    score += 2;
  }

  // Bathroom
 
}

else if (userProfile is FlatListingProfile &&
         otherProfile is SeekingFlatmateProfile) {

  // Flat Type
  if (otherProfile.preferredFlatType != null &&
      otherProfile.preferredFlatType!.isNotEmpty &&
      userProfile.flatType != null &&
      otherProfile.preferredFlatType!
              .toLowerCase() ==
          userProfile.flatType!
              .toLowerCase()) {
    score += 3;
  }

  // Room Type
  if (otherProfile.preferredRoomType != null &&
      otherProfile.preferredRoomType!.isNotEmpty &&
      userProfile.roomType != null &&
      otherProfile.preferredRoomType!
              .toLowerCase() ==
          userProfile.roomType!
              .toLowerCase()) {
    score += 3;
  }

  // Furnished
  if (otherProfile.preferredFurnishedStatus != null &&
      otherProfile.preferredFurnishedStatus!.isNotEmpty &&
      userProfile.furnishedStatus != null &&
      otherProfile.preferredFurnishedStatus!
              .toLowerCase() ==
          userProfile.furnishedStatus!
              .toLowerCase()) {
    score += 2;
  }

  // Bathroom
 
}
// -------------------------
// LIFESTYLE (10)
// -------------------------

String? myCleanliness;
String? otherCleanliness;

String? mySmoking;
String? otherSmoking;

String? myDrinking;
String? otherDrinking;

String? myFood;
String? otherFood;

String? myPets;
String? otherPets;

if (userProfile is FlatListingProfile) {
  myCleanliness = userProfile.userProfile.cleanlinessLevel;
  mySmoking = userProfile.userProfile.smokingHabit;
  myDrinking = userProfile.userProfile.drinkingHabit;
  myFood = userProfile.userProfile.foodPreference;
  myPets = userProfile.userProfile.petTolerance;
} else if (userProfile is SeekingFlatmateProfile) {
  myCleanliness = userProfile.userProfile.cleanlinessLevel;
  mySmoking = userProfile.userProfile.smokingHabit;
  myDrinking = userProfile.userProfile.drinkingHabit;
  myFood = userProfile.userProfile.foodPreference;
  myPets = userProfile.userProfile.petTolerance;
}

if (otherProfile is FlatListingProfile) {
  otherCleanliness = otherProfile.userProfile.cleanlinessLevel;
  otherSmoking = otherProfile.userProfile.smokingHabit;
  otherDrinking = otherProfile.userProfile.drinkingHabit;
  otherFood = otherProfile.userProfile.foodPreference;
  otherPets = otherProfile.userProfile.petTolerance;
} else if (otherProfile is SeekingFlatmateProfile) {
  otherCleanliness = otherProfile.userProfile.cleanlinessLevel;
  otherSmoking = otherProfile.userProfile.smokingHabit;
  otherDrinking = otherProfile.userProfile.drinkingHabit;
  otherFood = otherProfile.userProfile.foodPreference;
  otherPets = otherProfile.userProfile.petTolerance;
}

if (_equals(myCleanliness, otherCleanliness)) score += 2;

if (_equals(mySmoking, otherSmoking)) score += 2;

if (_equals(myDrinking, otherDrinking)) score += 2;

if (_equals(myFood, otherFood)) score += 2;

if (_equals(myPets, otherPets)) score += 2;
// -------------------------
// AMENITIES (5)
// -------------------------

if (userProfile is SeekingFlatmateProfile &&
    otherProfile is FlatListingProfile) {

  final wanted =
      userProfile.amenitiesDesired ?? [];

  final available =
      otherProfile.amenities ?? [];

  if (wanted.isNotEmpty) {

    int matched = 0;

    for (final amenity in wanted) {

      if (available.any(
        (a) =>
            a.toLowerCase() ==
            amenity.toLowerCase(),
      )) {
        matched++;
      }
    }

    final ratio = matched / wanted.length;

    if (ratio >= 1) {
      score += 5;
    } else if (ratio >= .75) {
      score += 4;
    } else if (ratio >= .50) {
      score += 3;
    } else if (ratio >= .25) {
      score += 2;
    } else if (ratio > 0) {
      score += 1;
    }
  }
}

else if (userProfile is FlatListingProfile &&
         otherProfile is SeekingFlatmateProfile) {

  final wanted =
      otherProfile.amenitiesDesired ?? [];

  final available =
      userProfile.amenities ?? [];

  if (wanted.isNotEmpty) {

    int matched = 0;

    for (final amenity in wanted) {

      if (available.any(
        (a) =>
            a.toLowerCase() ==
            amenity.toLowerCase(),
      )) {
        matched++;
      }
    }

    final ratio = matched / wanted.length;

    if (ratio >= 1) {
      score += 5;
    } else if (ratio >= .75) {
      score += 4;
    } else if (ratio >= .50) {
      score += 3;
    } else if (ratio >= .25) {
      score += 2;
    } else if (ratio > 0) {
      score += 1;
    }
  }
}
// -------------------------
// AGE PREFERENCE (4)
// -------------------------

if (userProfile is FlatListingProfile &&
    otherProfile is SeekingFlatmateProfile) {

  final otherAge =
      otherProfile.userProfile.age;

  if (_ageMatches(
    otherAge,
    userProfile.preferredAgeGroup,
  )) {
    score += 4;
  }
}

else if (userProfile is SeekingFlatmateProfile &&
         otherProfile is FlatListingProfile) {

  final otherAge =
      otherProfile.userProfile.age;

  if (_ageMatches(
    otherAge,
    userProfile.preferredFlatmateAge,
  )) {
    score += 4;
  }
}

return score.clamp(0, 100);
}
bool _equals(String? a, String? b) {
  if (a == null || b == null) return false;

  return a.trim().toLowerCase() ==
      b.trim().toLowerCase();
}
bool _ageMatches(
  int? age,
  String? preferredRange,
) {
  if (age == null ||
      preferredRange == null ||
      preferredRange.isEmpty) {
    return false;
  }

  final match = RegExp(r'(\d+)\D+(\d+)')
      .firstMatch(preferredRange);

  if (match == null) return false;

  final minAge =
      int.tryParse(match.group(1)!);

  final maxAge =
      int.tryParse(match.group(2)!);

  if (minAge == null || maxAge == null) {
    return false;
  }

  return age >= minAge &&
      age <= maxAge;
}
// NEW: Method to build the list view of profiles
  Widget _buildListView() {
    if (_profiles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'No profiles found matching your criteria.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _currentFilters.clear(); // Clear filters
                });
                _fetchUserProfile(applyFilters: true);
                if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
                  Navigator.of(context).pop(); // Close drawer if it was somehow closed
                } else {
                  _scaffoldKey.currentState?.openDrawer(); // Open drawer for small screens
                }
              },
              icon: const Icon(Icons.filter_list),
              label: const Text('Adjust Filters'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFAD1457),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _profiles.length,
      itemBuilder: (context, index) {
        final profile = _profiles[index];
        final String profileName = _getProfileDisplayName(profile);
        String? profileImageUrl;

        if (profile is FlatListingProfile && profile.imageUrls != null && profile.imageUrls!.isNotEmpty) {
          profileImageUrl = profile.imageUrls!.first;
        } else if (profile is SeekingFlatmateProfile && profile.imageUrls != null && profile.imageUrls!.isNotEmpty) {
          profileImageUrl = profile.imageUrls!.first;
        }

       return ProfileListItem(
  profile: profile,

  distanceText:
      _getDistanceText(profile),
matchPercentage: _calculateMatchPercentage(
  _currentUserParsedProfile,
  profile,
),
  onLike: () {

    if (widget.isExploreMode) {

      _showCreateProfileRequiredDialog();
      return;
    }

    final profileIndex =
        _profiles.indexOf(profile);

    if (profileIndex != -1) {

      final selectedProfile =
          _profiles[profileIndex];

      _profiles.removeAt(
        profileIndex,
      );

      _processLike(
        selectedProfile.uid,
        selectedProfile.documentId!,
      );

      setState(() {});
    }
  },

  onPass: () {

    final profileIndex =
        _profiles.indexOf(profile);

    if (profileIndex != -1) {

      _lastPassedProfile =
          _profiles[profileIndex];

      _canUndoPass = true;

      _profiles.removeAt(
        profileIndex,
      );

      setState(() {});
    }
  },

  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ViewProfileScreen(
          userId: profile.uid,
          profileDocumentId:
              profile.documentId!,
        ),
      ),
    );
  },
);
      },
    );
  }

Widget _buildCardView() {
  if (_profiles.isEmpty) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 24,
        ),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                .06,
              ),
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
                shape: BoxShape.circle,
                gradient:
                    const LinearGradient(
                  colors: [
                    Color(0xFF7C3AED),
                    Color(0xFFEC4899),
                  ],
                ),
              ),
              child: const Icon(
                Icons.favorite_border,
                color: Colors.white,
                size: 42,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'No More Profiles',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'We could not find any more matching profiles right now.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF64748B),
                height: 1.5,
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _fetchUserProfile(
                    applyFilters: true,
                  );
                },
                icon: const Icon(
                  Icons.refresh_rounded,
                ),
                label: const Text(
                  'Refresh Profiles',
                ),
                style:
                    ElevatedButton.styleFrom(
                  elevation: 0,
                  minimumSize:
                      const Size.fromHeight(
                    56,
                  ),
                  backgroundColor:
                      const Color(
                    0xFF7C3AED,
                  ),
                  foregroundColor:
                      Colors.white,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      18,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  final profile = _profiles.first;

  return AnimatedSwitcher(
    duration:
        const Duration(milliseconds: 300),
    child: Container(
      key: ValueKey(
        profile.documentId,
      ),
      margin: const EdgeInsets.fromLTRB(
        16,
        8,
        16,
        16,
      ),
      child: CardSwiper(
  controller: _cardController,

  cardsCount: 1,

  numberOfCardsDisplayed: 1,

  isLoop: false,

  backCardOffset: const Offset(0, 0),

  padding: EdgeInsets.zero,

  allowedSwipeDirection:
      const AllowedSwipeDirection.only(
    left: true,
    right: true,
  ),

  cardBuilder: (
    context,
    index,
    horizontalOffsetPercentage,
    verticalOffsetPercentage,
  ) {
final double offset =
    horizontalOffsetPercentage.toDouble();

final double likeOpacity =
    offset.clamp(0.0, 1.0).toDouble();

final double nopeOpacity =
    (-offset).clamp(0.0, 1.0).toDouble();
    return Stack(
  fit: StackFit.expand,
  children: [

    InkWell(
      borderRadius: BorderRadius.circular(32),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ViewProfileScreen(
              userId: profile.uid,
              profileDocumentId: profile.documentId!,
            ),
          ),
        );
      },
      child: ProfileCard(
        profile: profile,
        distanceText: _getDistanceText(profile),
          matchPercentage: _calculateMatchPercentage(
    _currentUserParsedProfile,
    profile,
  ),

        onLike: () {

          if (widget.isExploreMode) {
            _showCreateProfileRequiredDialog();
            return;
          }

          _cardController.swipe(
            CardSwiperDirection.right,
          );
        },

        onPass: () {

          _cardController.swipe(
            CardSwiperDirection.left,
          );
        },
      ),
    ),
   

    /// LIKE
    if (horizontalOffsetPercentage > 0)
      if (likeOpacity > 0)
  Positioned(
    top: 70,
    left: 28,
    child: _buildSwipeBadge(
      text: "LIKE",
      color: const Color(0xFF22C55E),
      opacity: likeOpacity,
      angle: -.25,
    ),
  ),

    /// NOPE
    if (horizontalOffsetPercentage < 0)
      if (nopeOpacity > 0)
  Positioned(
    top: 70,
    right: 28,
    child: _buildSwipeBadge(
      text: "NOPE",
      color: const Color(0xFFEF4444),
      opacity: nopeOpacity,
      angle: .25,
    ),
  ),
  ],
);

  },

  onSwipe: (
    previousIndex,
    currentIndex,
    direction,
  ) {

    if (direction ==
        CardSwiperDirection.right) {

      if (widget.isExploreMode) {
        return false;
      }

      _lastLikedProfile = profile;

      debugPrint(
        'LAST LIKED PROFILE = ${profile.documentId}',
      );

      _handleProfileDismissed(
        DismissDirection.startToEnd,
      );

    } else {

      _handleProfileDismissed(
        DismissDirection.endToStart,
      );

    }

    return true;

  },
),
    ),
  );
}

Widget _buildSwipeBadge({
  required String text,
  required Color color,
  required double opacity,
  required double angle,
}) {
  return Transform.rotate(
    angle: angle,
    child: AnimatedScale(
      duration: const Duration(milliseconds: 120),
      scale: .85 + (.15 * opacity),
      child: Opacity(
        opacity: opacity,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 22,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: color,
              width: 4,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(.35),
                blurRadius: 20,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 34,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
            ),
          ),
        ),
      ),
    ),
  );
}
Widget _buildActionButton({
  required IconData icon,
  required Color color,
  required VoidCallback onTap,
  required String tooltip,
}) {
  return Tooltip(
    message: tooltip,
    child: InkWell(
      borderRadius:
          BorderRadius.circular(16),
      onTap: onTap,
      child: Ink(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.12),
          borderRadius:
              BorderRadius.circular(16),
          border: Border.all(
            color:
                Colors.white.withOpacity(.15),
          ),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 22,
        ),
      ),
    ),
  );
}

Widget _buildExploreTypeSelector() {
  if (!widget.isExploreMode) {
    return const SizedBox.shrink();
  }

  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
    child: Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          // ============================================================
          // ROOMS
          // ============================================================

          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (_exploreType == "flat_listing") {
                  return;
                }

                setState(() {
                  _exploreType = "flat_listing";
                });

                _loadExploreProfiles();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: 48,
                decoration: BoxDecoration(
                  color: _exploreType == "flat_listing"
                      ? Colors.white
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: _exploreType == "flat_listing"
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.home_rounded,
                      size: 20,
                      color: _exploreType == "flat_listing"
                          ? const Color(0xFF7C3AED)
                          : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      "Rooms",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _exploreType == "flat_listing"
                            ? const Color(0xFF111827)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 5),

          // ============================================================
          // FLATMATES
          // ============================================================

          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (_exploreType == "seeking_flatmate") {
                  return;
                }

                setState(() {
                  _exploreType = "seeking_flatmate";
                });

                _loadExploreProfiles();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: 48,
                decoration: BoxDecoration(
                  color: _exploreType == "seeking_flatmate"
                      ? Colors.white
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: _exploreType == "seeking_flatmate"
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_alt_rounded,
                      size: 20,
                      color: _exploreType == "seeking_flatmate"
                          ? const Color(0xFF7C3AED)
                          : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      "Flatmates",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _exploreType == "seeking_flatmate"
                            ? const Color(0xFF111827)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
Future<void> _openExploreLocationPicker() async {
  if (!widget.isExploreMode) {
    return;
  }

  FocusManager.instance.primaryFocus?.unfocus();

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
        ),
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxHeight:
                MediaQuery.sizeOf(sheetContext).height * 0.82,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),

              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),

              const SizedBox(height: 18),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      color: Color(0xFF7C3AED),
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Choose explore location",
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    0,
                    16,
                    24,
                  ),
                  child: LocationSelectorWidget(
                    googleApiKey: 'YOUR_EXISTING_GOOGLE_API_KEY',
                    initialCity: _exploreCity,
                    initialAddress: _exploreLocationName,
                    onLocationSelected: (LocationResult result) {
                      setState(() {
                        _exploreCity = result.city;
                        _exploreLocationName = result.address;
                        _explorePlaceId = result.placeId;
                        _exploreLatitude = result.latitude;
                        _exploreLongitude = result.longitude;
                      });

                      Navigator.of(sheetContext).pop();

                      _loadExploreProfiles();
                    },
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
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth > 900; // Define your breakpoint for web layout
    return Scaffold(
      key: _scaffoldKey, // Assign the key to Scaffold
      
      appBar: AppBar(
  automaticallyImplyLeading: false,
  toolbarHeight: 72,
  centerTitle: false,
  elevation: 0,
  scrolledUnderElevation: 0,
  backgroundColor: Colors.transparent,

  flexibleSpace: Container(
    decoration: const BoxDecoration(
      gradient: kPrimaryGradient,
    ),
  ),

  titleSpacing: 8,

  title: widget.isExploreMode

    // ============================================================
    // EXPLORE MODE APPBAR TITLE
    // ============================================================

    ? InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: _openExploreLocationPicker,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 4,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ==================================================
              // LOCATION ICON
              // ==================================================

              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withOpacity(.15),
                  ),
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),

              const SizedBox(width: 12),

              // ==================================================
              // CITY + SUBTITLE
              // ==================================================

              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _exploreCity != null &&
                              _exploreCity!.trim().isNotEmpty
                          ? _exploreCity!
                          : "Select a city",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        letterSpacing: .2,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      _exploreCity != null &&
                              _exploreCity!.trim().isNotEmpty
                          ? "Tap to change location"
                          : "Choose your explore location",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 4),

              // ==================================================
              // DROPDOWN ICON
              // ==================================================

              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.white70,
                size: 21,
              ),
            ],
          ),
        ),
      )

    // ============================================================
    // NORMAL MATCHING MODE APPBAR TITLE
    // ============================================================

    : Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withOpacity(.15),
              ),
            ),
            child: const Icon(
              Icons.favorite_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),

          const SizedBox(width: 12),

          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Discover",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .2,
                ),
              ),

              SizedBox(height: 2),

              Text(
                "Find your perfect flatmate",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),

  iconTheme: const IconThemeData(
    color: Colors.white,
    size: 24,
  ),

  actions: [

    if (_canUndoPass)
      Padding(
        padding: const EdgeInsets.only(
          right: 6,
        ),
        child: _buildActionButton(
          icon: Icons.undo_rounded,
          tooltip: "Undo Pass",
          color: const Color(0xFFFFB020),
          onTap: _undoLastPass,
        ),
      ),

    Padding(
      padding: const EdgeInsets.only(
        right: 6,
      ),
      child: _buildActionButton(
        icon: _currentViewType ==
                _ViewType.card
            ? Icons.view_list_rounded
            : Icons.swipe_rounded,
        tooltip: "Change View",
        color: const Color(0xFF22C55E),
        onTap: () {
          setState(() {
            _currentViewType =
                _currentViewType ==
                        _ViewType.card
                    ? _ViewType.list
                    : _ViewType.card;
          });
        },
      ),
    ),

    if (!isLargeScreen)
      Padding(
        padding:
            const EdgeInsets.only(
          right: 14,
        ),
        child: _buildActionButton(
          icon: Icons.tune_rounded,
          tooltip: "Filters",
          color: kAccentColor,
          onTap: () {
            _scaffoldKey.currentState
                ?.openDrawer();
          },
        ),
      ),
  ],
),
      drawer: isLargeScreen ? null // No drawer on large screens, as filter is inline
          : Drawer(
        child: FilterScreen(
          initialFilters: _currentFilters.copyWith(),
          isSeekingFlatmate: _userProfileType == 'seeking_flatmate',
          onFiltersChanged: _onFiltersChanged,
        ),
      ),
     body: _isLoading
    ? const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF6A1B9A),
        ),
      )
    : Column(
        children: [
          // ============================================================
          // EXPLORE MODE TYPE SELECTOR
          // Shows only when MatchingScreen is opened in Explore Mode
          // ============================================================

          if (widget.isExploreMode)
            _buildExploreTypeSelector(),

          // ============================================================
          // EXISTING MATCHING CONTENT
          // ============================================================

          Expanded(
            child: isLargeScreen

                // ======================================================
                // LARGE SCREEN / WEB
                // ======================================================

                ? Row(
                    children: [
                      // FILTER PANEL

                      SizedBox(
                        width: math.min(
                          350.0,
                          screenWidth * 0.3,
                        ),
                        child: FilterScreen(
                          initialFilters:
                              _currentFilters.copyWith(),

                          // In Explore Mode use currently selected type.
                          isSeekingFlatmate:
                              widget.isExploreMode
                                  ? _exploreType ==
                                      'seeking_flatmate'
                                  : _userProfileType ==
                                      'seeking_flatmate',

                          onFiltersChanged:
                              _onFiltersChanged,
                        ),
                      ),

                      // MAIN MATCHING CONTENT

                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              // ========================================
                              // PLAN / CONTACT INFORMATION
                              // ========================================

                              Padding(
                                padding:
                                    const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .spaceBetween,
                                  children: [
                                    Text(
                                      'Plan: ${_currentPlanName ?? 'N/A'}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      'Contacts Left: $_remainingContacts',
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // ========================================
                              // CARD / LIST VIEW
                              // ========================================

                              Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.all(16.0),
                                  child: _currentViewType ==
                                          _ViewType.card
                                      ? _buildCardView()
                                      : _buildListView(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )

                // ======================================================
                // SMALL SCREEN / MOBILE
                // ======================================================

                : _currentViewType == _ViewType.card
                    ? _buildCardView()
                    : _buildListView(),
          ),
        ],
      ),
    );
  }
}