// home_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mytennat/screens/edit_profile_screen.dart';
import 'package:mytennat/screens/matching_screen.dart';
import 'package:mytennat/screens/matches_list_screen.dart';
import 'package:mytennat/widgets/profile_display_widgets.dart';
import 'package:mytennat/screens/view_profile_screen.dart';
import 'package:mytennat/screens/more_profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mytennat/screens/user_activity_screen.dart';
import 'package:mytennat/screens/flatmate_profile_screen.dart';
import 'package:mytennat/screens/flat_with_flatmate_profile_screen.dart';
import 'package:mytennat/screens/PlansScreen.dart';
import 'package:mytennat/screens/user_screen.dart';
import 'package:mytennat/screens/profile_switch_animation.dart';
import '../widgets/home/hero_banner.dart';
import '../widgets/home/quick_actions_section.dart';
import '../widgets/home/Community_Stats_Section.dart';
// import '../widgets/home/PopularCitiesSection.dart';
// import '../widgets/home/Success_Stories_Section.dart';
import '../widgets/home/subscription_section.dart';
import 'package:mytennat/screens/notification_screen.dart';
import '../widgets/location_selector_widget.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _userProfileType;
  String? _currentActiveProfileId;
  dynamic _activeProfileObject;
  bool _isLoadingProfileType = true;
String get currentUserId =>
    FirebaseAuth.instance.currentUser!.uid;
  String? _currentPlanName;
  int? _currentPlanContacts;
  int? _remainingContacts;

  String _userName = 'User'; // Default user name

  static const String _lastSelectedProfileKey = 'lastSelectedProfileId_';

  int _selectedIndex = 0; // For Bottom Navigation Bar
String _exploreType = "flat_listing";
String? _exploreCity;

String? _exploreLocationName;

String? _explorePlaceId;

double? _exploreLatitude;

double? _exploreLongitude;
  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() {
      _isLoadingProfileType = true;
      _userProfileType = null;
      _currentActiveProfileId = null;
      _activeProfileObject = null;
      _currentPlanName = null;
      _currentPlanContacts = null;
      _remainingContacts = null;
      _userName = 'User'; // Reset to a default before fetching
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

        final userDocSnapshot = await userDocRef.get();
        if (userDocSnapshot.exists) {
          final userData = userDocSnapshot.data();
          if (userData != null) {
            setState(() {
              _userName = userData['name'] as String? ?? 'User'; // Fetch user's name
              _currentPlanName = userData['currentPlan'] as String?;
              _currentPlanContacts = userData['currentPlanContacts'] as int?;
              _remainingContacts = userData['remainingContacts'] as int?;
            });
            print('[HomePage][_fetchUserData] Fetched Plan: $_currentPlanName, Remaining Contacts: $_remainingContacts');
          }
        }

        final flatListingsSnapshot = await userDocRef.collection('flatListings').get();
        final List<FlatListingProfile> flatListings = flatListingsSnapshot.docs
            .map((doc) => FlatListingProfile.fromMap(doc.data(), doc.id))
            .toList();

        final seekingFlatmateProfilesSnapshot = await userDocRef.collection('seekingFlatmateProfiles').get();
        final List<SeekingFlatmateProfile> seekingFlatmateProfiles = seekingFlatmateProfilesSnapshot.docs
            .map((doc) => SeekingFlatmateProfile.fromMap(doc.data(), doc.id))
            .toList();

        if (flatListings.isEmpty && seekingFlatmateProfiles.isEmpty) {
          setState(() {
            _userProfileType = null;
          });
        }

        final prefs = await SharedPreferences.getInstance();
        final lastSelectedId = prefs.getString(_lastSelectedProfileKey + user.uid);

        bool profileSet = false;

        if (lastSelectedId != null) {
          try {
            final activeFlatListing = flatListings.firstWhere((p) => p.documentId == lastSelectedId);
            setState(() {
              _userProfileType = 'flat_listing';
              _currentActiveProfileId = activeFlatListing.documentId;
              _activeProfileObject = activeFlatListing;
            });
            profileSet = true;
          } catch (_) {
            try {
              final activeSeekingFlatmate = seekingFlatmateProfiles.firstWhere((p) => p.documentId == lastSelectedId);
              setState(() {
                _userProfileType = 'seeking_flatmate';
                _currentActiveProfileId = activeSeekingFlatmate.documentId;
                _activeProfileObject = activeSeekingFlatmate;
              });
              profileSet = true;
            } catch (__) {
              // Last selected profile ID not found in current profiles.
            }
          }
        }

        if (!profileSet) {
          if (flatListings.isNotEmpty) {
            setState(() {
              _userProfileType = 'flat_listing';
              _currentActiveProfileId = flatListings.first.documentId;
              _activeProfileObject = flatListings.first;
            });
          } else if (seekingFlatmateProfiles.isNotEmpty) {
            setState(() {
              _userProfileType = 'seeking_flatmate';
              _currentActiveProfileId = seekingFlatmateProfiles.first.documentId;
              _activeProfileObject = seekingFlatmateProfiles.first;
            });
          } else {
            setState(() {
              _userProfileType = null;
              _activeProfileObject = null;
            });
          }
        }
      } catch (e) {
        print('[HomePage][_fetchUserData] Error fetching user data: $e');
        setState(() {
          _userProfileType = null;
          _activeProfileObject = null;
          _currentPlanName = null;
          _currentPlanContacts = null;
          _remainingContacts = null;
          _userName = 'User';
        });
      }
    } else {
      print('[HomePage][_fetchUserData] No user logged in.');
      setState(() {
        _userProfileType = null;
        _activeProfileObject = null;
        _currentPlanName = null;
        _currentPlanContacts = null;
        _remainingContacts = null;
        _userName = 'User';
      });
    }

    setState(() {
      _isLoadingProfileType = false;
    });
  }

  // New method to perform the profile switch and refresh
  Future<void> _performSwitchAndRefresh() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final flatListingsSnapshot = await userDocRef.collection('flatListings').get();
    final seekingFlatmateProfilesSnapshot = await userDocRef.collection('seekingFlatmateProfiles').get();

    final flatListings = flatListingsSnapshot.docs;
    final seekingFlatmateProfiles = seekingFlatmateProfilesSnapshot.docs;

    String? newProfileType;
    String? newActiveProfileId;

    if (_userProfileType == 'flat_listing' && seekingFlatmateProfiles.isNotEmpty) {
      newProfileType = 'seeking_flatmate';
      newActiveProfileId = seekingFlatmateProfiles.first.id;
    } else if (_userProfileType == 'seeking_flatmate' && flatListings.isNotEmpty) {
      newProfileType = 'flat_listing';
      newActiveProfileId = flatListings.first.id;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot switch profile. Only one profile type exists.')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSelectedProfileKey + user.uid, newActiveProfileId!);

    // Re-fetch data to update the UI
    _fetchUserData();
  }
void _openExploreMode() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => MatchingScreen(
        profileType: _exploreType,
        profileId: "",
        isExploreMode: true,

        exploreCity:
            _exploreCity,

        exploreLocationName:
            _exploreLocationName,

        explorePlaceId:
            _explorePlaceId,

        exploreLatitude:
            _exploreLatitude,

        exploreLongitude:
            _exploreLongitude,
      ),
    ),
  );
}
  // Modified method to initiate the animation and then the switch
  void _switchProfileTypeWithAnimation() {
    if (_userProfileType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No active profile to switch from.')),
      );
      return;
    }

    String newType = _userProfileType == 'flat_listing' ? 'seeking_flatmate' : 'flat_listing';

    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) => ProfileSwitchAnimationScreen(
          newProfileType: newType,
          onAnimationComplete: () {
            Navigator.of(context).pop(); // Pop the animation screen
            _performSwitchAndRefresh(); // Perform the actual switch
          },
        ),
      ),
    );
  }

 void _onItemTapped(int index) {
  setState(() {
    _selectedIndex = index;
  });

  switch (index) {

    case 0:
      break;

    case 1:

      if (_userProfileType != null &&
          _currentActiveProfileId != null) {

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MatchingScreen(
              profileType: _userProfileType!,
              profileId: _currentActiveProfileId!,
              isExploreMode: false,
            ),
          ),
        );

      } else {

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MatchingScreen(
              profileType: _exploreType,
              profileId: "",
              isExploreMode: true,
            ),
          ),
        );

      }

      break;

    case 2:

      if (_userProfileType != null &&
          _currentActiveProfileId != null) {

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MatchesListScreen(
              profileType: _userProfileType!,
              profileId: _currentActiveProfileId!,
            ),
          ),
        );

      } else {

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Create a profile to access chats and matches.',
            ),
          ),
        );

      }

      break;

    case 3:
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const UserActivityScreen(),
        ),
      );
      break;

    case 4:
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const MoreProfileScreen(),
        ),
      );
      break;
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
     appBar: AppBar(
  elevation: 0,
  toolbarHeight: 95,
  automaticallyImplyLeading: false,
  flexibleSpace: Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF7C3AED),
          Color(0xFF9333EA),
          Color(0xFFEC4899),
        ],
      ),
    ),
  ),
  title: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        'Welcome Back 👋',
        style: TextStyle(
          color: Colors.white.withOpacity(.85),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),

      const SizedBox(height: 2),

      Text(
        _userName,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w800,
          letterSpacing: -.5,
        ),
      ),

      if (_remainingContacts != null)
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            "${_remainingContacts!} contacts remaining",
            style: TextStyle(
              color: Colors.white.withOpacity(.80),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
    ],
  ),
 actions: [

  if (_currentPlanName != null)
    Container(
      margin: const EdgeInsets.only(
        top: 20,
        bottom: 20,
        right: 10,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.15),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white24,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.workspace_premium_rounded,
            color: Colors.amber,
            size: 16,
          ),

          const SizedBox(width: 6),

          Text(
            _currentPlanName!,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    ),

  StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('notifications')
        .where(
          'isRead',
          isEqualTo: false,
        )
        .snapshots(),
    builder: (context, snapshot) {

      final unreadCount =
          snapshot.data?.docs.length ?? 0;

      return Padding(
        padding: const EdgeInsets.only(
          right: 8,
        ),
        child: Stack(
          children: [

            IconButton(
              icon: const Icon(
                Icons.notifications_outlined,
                color: Colors.white,
                size: 28,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const NotificationScreen(),
                  ),
                );
              },
            ),

            if (unreadCount > 0)
              Positioned(
                right: 4,
                top: 4,
                child: Container(
                  padding:
                      const EdgeInsets.all(5),
                  decoration:
                      const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    unreadCount > 99
                        ? '99+'
                        : unreadCount.toString(),
                    style:
                        const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    },
  ),

  Padding(
    padding: const EdgeInsets.only(
      right: 16,
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const UserScreen(),
          ),
        );
      },
      child: Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.15),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white24,
          ),
        ),
        child: const Icon(
          Icons.person_outline_rounded,
          color: Colors.white,
        ),
      ),
    ),
  ),
],
),
      
      body: Container(
        width: double.infinity,
        height: double.infinity,
       color: const Color(0xFFF8FAFC),
        child: _isLoadingProfileType
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

const SizedBox(height: 20),
Container(
  padding: const EdgeInsets.all(20),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(24),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(.05),
        blurRadius: 15,
        offset: const Offset(0, 8),
      ),
    ],
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      const Text(
        "Explore",
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: Color(0xFF111827),
        ),
      ),

      const SizedBox(height: 6),

      const Text(
        "Browse rooms and flatmates before creating your profile",
        style: TextStyle(
          color: Color(0xFF64748B),
        ),
      ),

      const SizedBox(height: 20),

      Row(
        children: [

          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _exploreType = "flat_listing";
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: _exploreType == "flat_listing"
                      ? const Color(0xFF7C3AED)
                      : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    "🏠 Rooms",
                    style: TextStyle(
                      color: _exploreType == "flat_listing"
                          ? Colors.white
                          : Colors.black87,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _exploreType = "seeking_flatmate";
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: _exploreType == "seeking_flatmate"
                      ? const Color(0xFF7C3AED)
                      : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    "👤 Flatmates",
                    style: TextStyle(
                      color: _exploreType == "seeking_flatmate"
                          ? Colors.white
                          : Colors.black87,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
const SizedBox(height: 16),

LocationSelectorWidget(
  googleApiKey:
      'AIzaSyBK82kg-QdV1TdTrOoC3-jvbSstRhz1wZ0',

  initialCity:
      _exploreCity,

  initialAddress:
      _exploreLocationName,

  onLocationSelected:
      (LocationResult result) {

    setState(() {

      _exploreCity =
          result.city;

      _exploreLocationName =
          result.address;

      _explorePlaceId =
          result.placeId;

      _exploreLatitude =
          result.latitude;

      _exploreLongitude =
          result.longitude;
    });
  },
),
      const SizedBox(height: 16),

      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _openExploreMode,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7C3AED),
            foregroundColor: Colors.white,
            minimumSize: const Size(
              double.infinity,
              54,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: const Text(
            "Explore Matches",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ],
  ),
),
const SizedBox(height: 24),
HeroBanner(
  onFindRoom: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FlatWithFlatmateProfileScreen(
          initialPhoneNumber: null,
        ),
      ),
    );
  },
  onFindFlatmate: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FlatmateProfileScreen(
          initialPhoneNumber: null,
        ),
      ),
    );
  },
),

const SizedBox(height: 24),
const Text(
  "List Your Requirement",
  style: TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: Color(0xFF111827),
  ),
),

SizedBox(height: 16),
QuickActionsSection(
  onNeedRoom: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FlatWithFlatmateProfileScreen(
          initialPhoneNumber: null,
        ),
      ),
    );
  },

  onNeedFlatmate: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FlatmateProfileScreen(
          initialPhoneNumber: null,
        ),
      ),
    );
  },

  onListProperty: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FlatmateProfileScreen(
          initialPhoneNumber: null,
        ),
      ),
    );
  },

  onExplore: () {
      // Future Explore Screen
  },
),
// const SizedBox(height: 28),


// const PopularCitiesSection(),


// const SizedBox(height: 32),

// const SuccessStoriesSection(),

const SizedBox(height: 32),

if (_currentPlanName != null)
  Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(.05),
          blurRadius: 15,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF7C3AED),
                Color(0xFF9333EA),
                Color(0xFFEC4899),
              ],
            ),
          ),
          child: const Icon(
            Icons.workspace_premium_rounded,
            color: Colors.white,
            size: 30,
          ),
        ),

        const SizedBox(width: 16),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                _currentPlanName!,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),

              const SizedBox(height: 4),

              Text(
                "${_remainingContacts ?? 0} Contacts Remaining",
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius:
                BorderRadius.circular(20),
          ),
          child: const Text(
            "ACTIVE",
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  ),

const SizedBox(height: 24),
Container(
  padding: const EdgeInsets.all(24),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(30),
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF7C3AED),
        Color(0xFF9333EA),
        Color(0xFFEC4899),
      ],
    ),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFF7C3AED).withOpacity(.25),
        blurRadius: 25,
        offset: const Offset(0, 12),
      ),
    ],
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.workspace_premium_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),

          const Spacer(),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.15),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Text(
              "PREMIUM",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),

      const SizedBox(height: 20),

      const Text(
        "Unlock Unlimited Matches",
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w800,
        ),
      ),

      const SizedBox(height: 8),

      const Text(
        "Get more profile views, unlock contact details, priority matching and premium support.",
        style: TextStyle(
          color: Colors.white70,
          fontSize: 15,
          height: 1.5,
        ),
      ),

      const SizedBox(height: 20),

      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _premiumChip("Unlimited Likes"),
          _premiumChip("Priority Matching"),
          _premiumChip("Contact Access"),
          _premiumChip("Premium Badge"),
        ],
      ),

      const SizedBox(height: 24),

      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const PlansScreen(),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF7C3AED),
            minimumSize: const Size(
              double.infinity,
              56,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: const Text(
            "View Premium Plans",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    ],
  ),
),

const SizedBox(height: 32),

            
              // New ElevatedButton for the profile switch button
              if (_userProfileType != null)
                Center(
                  child: Container(
  padding: const EdgeInsets.symmetric(
    horizontal: 18,
    vertical: 12,
  ),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(18),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(.06),
        blurRadius: 15,
      ),
    ],
  ),
  child: InkWell(
    onTap: _switchProfileTypeWithAnimation,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.swap_horiz,
          color: Color(0xFF7C3AED),
        ),
        const SizedBox(width: 8),
        Text(
          _userProfileType == 'flat_listing'
              ? 'Switch to Flatmate'
              : 'Switch to Flat',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
      ],
    ),
  ),
),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFAD1457),
        unselectedItemColor: Colors.grey[600],
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Matches',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_activity),
            label: 'Activity',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.more_horiz),
          //   label: 'More',
          // ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildRequirementCard(
      BuildContext context, {
        required String title,
        required String subtitle,
        required String imagePath,
        required Color color,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Align(
              alignment: Alignment.topRight,
              child: Icon(Icons.arrow_forward_ios, size: 18, color: Colors.black54),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Image.asset(
                imagePath,
                height: 80,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _premiumChip(String text) {
  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 8,
    ),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(.15),
      borderRadius: BorderRadius.circular(30),
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
    ),
  );
}
}

class FlatListingProfile {
  final String documentId;
  final String? ownerName;
  FlatListingProfile({required this.documentId, this.ownerName});
  factory FlatListingProfile.fromMap(Map<String, dynamic> data, String id) {
    return FlatListingProfile(documentId: id, ownerName: data['ownerName']);
  }
}

class SeekingFlatmateProfile {
  final String documentId;
  final String? name;
  SeekingFlatmateProfile({required this.documentId, this.name});
  factory SeekingFlatmateProfile.fromMap(Map<String, dynamic> data, String id) {
    return SeekingFlatmateProfile(documentId: id, name: data['name']);
  }
}