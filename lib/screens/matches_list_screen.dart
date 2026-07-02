import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

// Assuming these models exist in your project. Adjust paths if necessary.
import 'package:mytennat/screens/chat_screen.dart';
import 'package:mytennat/screens/flatmate_profile_screen.dart'; // FlatListingProfile
import 'package:mytennat/screens/flat_with_flatmate_profile_screen.dart'; // SeekingFlatmateProfile
import 'package:mytennat/services/block_user_service.dart';
class MatchesListScreen extends StatefulWidget {
  const MatchesListScreen({
    super.key,
    required this.profileType, // Make it required
    required this.profileId,
  });

  final String profileType; // Add this line
  final String profileId; // Add this line

  @override
  State<MatchesListScreen> createState() => _MatchesListScreenState();
}

class _MatchesListScreenState extends State<MatchesListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    if (_currentUser != null) {
      print("Logged in user UID in MatchesListScreen: ${_currentUser!.uid}");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return Scaffold(
  backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text('Matches', style: TextStyle(color: Colors.white)),
          flexibleSpace: Container( // Removed const here
            decoration: const BoxDecoration( // BoxDecoration can be const
              gradient: LinearGradient(
                colors: [Color(0xFF6A1B9A), Color(0xFFAD1457)], // Deep Purple to Pink-Red
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
        ),
        body: const Center( // Added const here for the text widget
          child: Text(
            'Please log in to view matches.',
            style: TextStyle(color: Colors.black54), // Darker text on white background
          ),
        ),
      );
    }

    final currentUserId = _currentUser!.uid;

    return Scaffold(
  backgroundColor: const Color(0xFFF8FAFC),// Full page background is now white
      appBar: PreferredSize(
  preferredSize: const Size.fromHeight(90),
  child: Container(
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
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: () =>
                  Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
              ),
            ),

            const Expanded(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Text(
                    "Your Matches",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "People who matched with you",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.15),
                borderRadius:
                    BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.favorite_rounded,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    ),
  ),
),
      body: StreamBuilder<List<QuerySnapshot>>(
        // Combine streams for matches and chat rooms
        stream: Rx.combineLatest2(
          _firestore
              .collection('matches')
              .where('user1_uid', isEqualTo: currentUserId)
              .snapshots(),
          _firestore
              .collection('matches')
              .where('user2_uid', isEqualTo: currentUserId)
              .snapshots(),
              (QuerySnapshot snapshot1, QuerySnapshot snapshot2) {
            return [snapshot1, snapshot2];
          },
        ),
        builder: (context, AsyncSnapshot<List<QuerySnapshot>> snapshots) {
          if (snapshots.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF6A1B9A))); // Purple indicator on white bg
          }
          if (snapshots.hasError) {
            print('Matches Stream Error: ${snapshots.error}');
            return Center(child: Text('Error loading matches: ${snapshots.error}', style: const TextStyle(color: Colors.black54)));
          }

          final List<DocumentSnapshot> allMatchDocs = [];
          if (snapshots.hasData) {
            allMatchDocs.addAll(snapshots.data![0].docs);
            allMatchDocs.addAll(snapshots.data![1].docs);
          }

          // Use a map to store unique match IDs to avoid duplicates if a match appears in both user1_uid and user2_uid queries
          final Map<String, DocumentSnapshot> uniqueMatchesMap = {};
          for (var doc in allMatchDocs) {
            // A match is unique by its combination of user1_uid and user2_uid, regardless of query direction.
            // Create a consistent key for unique identification
            String key;
            String user1 = doc['user1_uid'];
            String user2 = doc['user2_uid'];
            if (user1.compareTo(user2) < 0) { // Ensures consistent ordering for key
              key = '${user1}_${user2}';
            } else {
              key = '${user2}_${user1}';
            }
            if (!uniqueMatchesMap.containsKey(key)) {
              uniqueMatchesMap[key] = doc;
            }
          }
          final List<DocumentSnapshot> uniqueMatches = uniqueMatchesMap.values.toList();


          print('Matches Stream: Snapshot hasData: ${snapshots.hasData}');
          print('Matches Stream: Raw documents received from combineLatest: ${allMatchDocs.length}');
          for (var doc in allMatchDocs) {
            print('  - Raw Doc ID: ${doc.id}, user1_uid: ${doc['user1_uid']}, user2_uid: ${doc['user2_uid']}');
          }
          print('Matches Stream: Total unique matches after processing: ${uniqueMatches.length}');


          if (uniqueMatches.isEmpty) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF7C3AED),
                  Color(0xFFEC4899),
                ],
              ),
              borderRadius:
                  BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.favorite_border_rounded,
              size: 70,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            "No Matches Yet",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Color(0xFF111827),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            "Keep exploring profiles and your perfect flatmate could be just one swipe away.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 28),

          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              gradient:
                  const LinearGradient(
                colors: [
                  Color(0xFF7C3AED),
                  Color(0xFFEC4899),
                ],
              ),
              borderRadius:
                  BorderRadius.circular(18),
            ),
            child: const Text(
              "Start Matching 🚀",
              style: TextStyle(
                color: Colors.white,
                fontWeight:
                    FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
return Column(
  children: [
    Container(
      margin: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Expanded(
            child: _statItem(
              "${uniqueMatches.length}",
              "Matches",
              Icons.favorite,
              const Color(0xFFEC4899),
            ),
          ),
          Expanded(
            child: _statItem(
              "${uniqueMatches.length}",
              "Chats",
              Icons.chat_bubble,
              const Color(0xFF7C3AED),
            ),
          ),
          Expanded(
            child: _statItem(
              "100%",
              "Active",
              Icons.local_fire_department,
              const Color(0xFFF97316),
            ),
          ),
        ],
      ),
    ),

    Expanded(
      child: ListView.builder(
          
            itemCount: uniqueMatches.length,
            itemBuilder: (context, index) {
              final matchDoc = uniqueMatches[index];
              final matchData = matchDoc.data() as Map<String, dynamic>;

              final partnerId = (matchData['user1_uid'] == currentUserId)
                  ? matchData['user2_uid']
                  : matchData['user1_uid'];

              // Extract partner's specific profile ID and type from the match document
              final partnerProfileId = (matchData['user1_uid'] == currentUserId)
                  ? matchData['user2_profile_id']
                  : matchData['user1_profile_id'];

              final partnerProfileType = (matchData['user1_uid'] == currentUserId)
                  ? matchData['user2_profile_type']
                  : matchData['user1_profile_type'];

              final chatRoomId = matchData['chatRoomId'] as String?;

              if (partnerProfileId == null || partnerProfileType == null) {
                print('Error: Partner profile ID or type is null for match ${matchDoc.id}');
                return const SizedBox.shrink(); // Hide problematic matches
              }

              // Use FutureBuilder to fetch the partner's specific profile data from the subcollection
              return FutureBuilder<bool>(
  future: BlockUserService.isUserBlocked(
    otherUserId: partnerId,
  ),
  builder: (context, blockedSnapshot) {
    if (blockedSnapshot.connectionState ==
        ConnectionState.waiting) {
      return const SizedBox.shrink();
    }

    if (blockedSnapshot.data == true) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<DocumentSnapshot>(
                future: _firestore
                    .collection('users')
                    .doc(partnerId)
                    .collection(partnerProfileType == 'flat_listing' ? 'flatListings' : 'seekingFlatmateProfiles')
                    .doc(partnerProfileId)
                    .get(),
                builder: (context, partnerProfileSnapshot) {
                  if (partnerProfileSnapshot.connectionState == ConnectionState.waiting) {
                    return Card( // Maintain card structure while loading
                      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF6A1B9A), Color(0xFFAD1457)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                        ),
                        child: const ListTile(
                          title: Text('Loading partner profile...', style: TextStyle(color: Colors.white)),
                          subtitle: LinearProgressIndicator(color: Colors.white70), // White progress bar
                        ),
                      ),
                    );
                  }
                  if (partnerProfileSnapshot.hasError) {
                    print('Partner Profile Error: ${partnerProfileSnapshot.error}');
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF6A1B9A), Color(0xFFAD1457)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                        ),
                        child: ListTile(
                          title: const Text('Error loading partner profile', style: TextStyle(color: Colors.white)),
                          subtitle: Text('Could not fetch details for this match: ${partnerProfileSnapshot.error}', style: const TextStyle(color: Colors.white70)),
                        ),
                      ),
                    );
                  }
                  if (!partnerProfileSnapshot.hasData || !partnerProfileSnapshot.data!.exists) {
                    print('Partner Profile not found for UID: $partnerId, ProfileID: $partnerProfileId, Type: $partnerProfileType');
                    return const SizedBox.shrink(); // Hide this match if profile is truly missing
                  }

                  String partnerName = 'Unknown';
                  String partnerProfileImageUrl = 'https://via.placeholder.com/150'; // Default placeholder image

                  final profileData = partnerProfileSnapshot.data!.data() as Map<String, dynamic>;

                  // Determine name and image based on profile type
                  if (partnerProfileType == 'flat_listing') {
                    final profile = FlatListingProfile.fromMap(profileData, partnerProfileId);
                    partnerName = profile.userProfile.name ?? 'Flat Owner';
                    if (profile.imageUrls != null && profile.imageUrls!.isNotEmpty) {
                      partnerProfileImageUrl = profile.imageUrls![0];
                    }
                  } else if (partnerProfileType == 'seeking_flatmate') {
                    final profile = SeekingFlatmateProfile.fromMap(profileData, partnerProfileId);
                    partnerName = profile.userProfile.name ?? 'Flatmate Seeker';
                    if (profile.imageUrls != null && profile.imageUrls!.isNotEmpty) {
                      partnerProfileImageUrl = profile.imageUrls![0];
                    }
                  }

                  // Conditionally show StreamBuilder only if chatRoomId is not null
                 return (chatRoomId == null)
    ? _buildPremiumMatchCard(
        name: partnerName,
        imageUrl: partnerProfileImageUrl,
        subtitle:
            "You matched with this profile. Tap to view details.",
        hasChat: false,
        onTap: () {
          ScaffoldMessenger.of(context)
              .showSnackBar(
            const SnackBar(
              content: Text(
                "Chat not available yet",
              ),
            ),
          );
        },
      )
                      : StreamBuilder<QuerySnapshot<Object?>>( // Specify the type for QuerySnapshot
                    stream: _firestore
                        .collection('chats')
                        .doc(chatRoomId)
                        .collection('messages')
                        .orderBy('timestamp', descending: true)
                        .limit(1)
                        .snapshots(),
                    builder: (context, chatSnapshot) {
                      String lastMessage = 'No messages yet';
                      if (chatSnapshot.hasData && chatSnapshot.data!.docs.isNotEmpty) {
                        lastMessage = chatSnapshot.data!.docs.first['content'] as String;
                      }

                      return _buildPremiumMatchCard(
  name: partnerName,
  imageUrl: partnerProfileImageUrl,
  subtitle: lastMessage,
  hasChat: true,
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          chatPartnerId: partnerId,
          chatPartnerName: partnerName,
          chatPartnerImageUrl:
              partnerProfileImageUrl,
          chatRoomId: chatRoomId,
        ),
      ),
    );
  },
);
                    },
                  );
                },
              );
  },
);
            },
                ),
    ),
  ],
);
        },
      ),
    );
  }
  Widget _statItem(
  String value,
  String label,
  IconData icon,
  Color color,
) {
  return Column(
    children: [
      Icon(
        icon,
        color: color,
      ),

      const SizedBox(height: 8),

      Text(
        value,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
      ),

      Text(
        label,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 13,
        ),
      ),
    ],
  );
}
Widget _buildPremiumMatchCard({
  required String name,
  required String imageUrl,
  required String subtitle,
  required bool hasChat,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
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
            color: const Color(
              0xFF7C3AED,
            ).withOpacity(.25),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Hero(
              tag: name,
              child: CircleAvatar(
                radius: 34,
                backgroundColor:
                    Colors.white.withOpacity(.15),
                backgroundImage:
                    imageUrl.startsWith('http')
                        ? NetworkImage(imageUrl)
                        : null,
                child: imageUrl.startsWith('http')
                    ? null
                    : Text(
                        name.isNotEmpty
                            ? name[0].toUpperCase()
                            : "U",
                        style:
                            const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style:
                              const TextStyle(
                            color:
                                Colors.white,
                            fontSize: 19,
                            fontWeight:
                                FontWeight
                                    .w800,
                          ),
                        ),
                      ),

                      Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration:
                            BoxDecoration(
                          color: Colors
                              .white12,
                          borderRadius:
                              BorderRadius
                                  .circular(
                                      20),
                        ),
                        child: Text(
                          hasChat
                              ? "Active"
                              : "New",
                          style:
                              const TextStyle(
                            color: Colors
                                .white,
                            fontSize: 11,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration:
                            BoxDecoration(
                          color: Colors
                              .white12,
                          borderRadius:
                              BorderRadius
                                  .circular(
                                      16),
                        ),
                        child: Row(
                          mainAxisSize:
                              MainAxisSize.min,
                          children: [
                            Icon(
                              hasChat
                                  ? Icons
                                      .chat_bubble_rounded
                                  : Icons
                                      .favorite_rounded,
                              size: 14,
                              color:
                                  Colors.white,
                            ),
                            const SizedBox(
                                width: 6),
                            Text(
                              hasChat
                                  ? "Chat"
                                  : "Match",
                              style:
                                  const TextStyle(
                                color: Colors
                                    .white,
                                fontSize: 12,
                                fontWeight:
                                    FontWeight
                                        .w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color:
                    Colors.white.withOpacity(.15),
                borderRadius:
                    BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}