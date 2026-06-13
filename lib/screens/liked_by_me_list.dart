import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mytennat/screens/flatmate_profile_screen.dart'; // Ensure these are imported from your project
import 'package:mytennat/screens/flat_with_flatmate_profile_screen.dart'; // Ensure these are imported from your project
import 'package:mytennat/screens/chat_screen.dart'; // For chat navigation
import 'package:mytennat/screens/view_profile_screen.dart'; // Add this import

class LikedByMeList extends StatefulWidget {
  final String currentUserId;

  const LikedByMeList({super.key, required this.currentUserId});

  @override
  State<LikedByMeList> createState() => _LikedByMeListState();
}

class _LikedByMeListState extends State<LikedByMeList> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<dynamic> _likedProfiles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLikedByMeProfiles();
  }

  Future<void> _fetchLikedByMeProfiles() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get all users that the current user has liked
      QuerySnapshot likedSnapshot = await _firestore
          .collection('user_likes')
          .doc(widget.currentUserId)
          .collection('likes')
          .get();

      List<dynamic> profiles = [];
      for (var doc in likedSnapshot.docs) {
        String likedUserId = doc.id; // The document ID here is the ID of the liked user

        // NEW: Fetch the liked user's actual profile from their subcollections
        DocumentSnapshot? userProfileDoc;
        Map<String, dynamic>? userData;
        String? userProfileId; // This will hold the actual profile document ID

        // Try to fetch from seekingFlatmateProfiles subcollection
        DocumentSnapshot seekingFlatmateProfileDoc = await _firestore
            .collection('users')
            .doc(likedUserId)
            .collection('seekingFlatmateProfiles')
            .doc(likedUserId) // Assuming profileId is the same as userId
            .get();

        if (seekingFlatmateProfileDoc.exists && seekingFlatmateProfileDoc.data() != null) {
          userProfileDoc = seekingFlatmateProfileDoc;
          userData = userProfileDoc.data() as Map<String, dynamic>;
          userProfileId = userProfileDoc.id; // Get the actual profile document ID
          profiles.add(SeekingFlatmateProfile.fromMap(userData, userProfileId));
        } else {
          // If not found, try to fetch from flatListings subcollection
          DocumentSnapshot flatListingProfileDoc = await _firestore
              .collection('users')
              .doc(likedUserId)
              .collection('flatListings')
              .doc(likedUserId) // Assuming profileId is the same as userId
              .get();

          if (flatListingProfileDoc.exists && flatListingProfileDoc.data() != null) {
            userProfileDoc = flatListingProfileDoc;
            userData = userProfileDoc.data() as Map<String, dynamic>;
            userProfileId = userProfileDoc.id; // Get the actual profile document ID
            profiles.add(FlatListingProfile.fromMap(userData, userProfileId));
          }
        }
      }

      setState(() {
        _likedProfiles = profiles;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching liked by me profiles: $e');
      setState(() {
        _isLoading = false;
      });
      _showAlertDialog('Error', 'Failed to load profiles you liked: $e');
    }
  }

  void _showAlertDialog(String title, String message) {
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
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

 @override
Widget build(BuildContext context) {
  if (_isLoading) {
    return const Center(
      child: CircularProgressIndicator(
        color: Color(0xFF7C3AED),
      ),
    );
  }

  if (_likedProfiles.isEmpty) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF7C3AED),
                    Color(0xFF9333EA),
                    Color(0xFFEC4899),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_border_rounded,
                color: Colors.white,
                size: 55,
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "No Likes Yet",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Profiles you like will appear here.\nStart exploring and finding your perfect match.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  return ListView.builder(
    padding: const EdgeInsets.only(
      top: 16,
      bottom: 30,
    ),
    itemCount: _likedProfiles.length,
    itemBuilder: (context, index) {
      final profile = _likedProfiles[index];

      String name = '';
      String imageUrl = '';
      String subtitle = '';
      String profileId = profile.documentId;

      if (profile is FlatListingProfile) {
        name = profile.userProfile.name ?? '';
        imageUrl = profile.imageUrls != null &&
                profile.imageUrls!.isNotEmpty
            ? profile.imageUrls!.first
            : '';
        subtitle =
            "Flat Listing • ${profile.userProfile.gender ?? ''}";
      } else if (profile is SeekingFlatmateProfile) {
        name = profile.userProfile.name ?? '';
        imageUrl = profile.imageUrls != null &&
                profile.imageUrls!.isNotEmpty
            ? profile.imageUrls!.first
            : '';
        subtitle =
            "Seeking Flatmate • ${profile.userProfile.gender ?? ''}";
      }

      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ViewProfileScreen(
                userId: profileId,
              ),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(28),
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
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor:
                          Colors.white24,
                      backgroundImage:
                          imageUrl.isNotEmpty
                              ? NetworkImage(
                                  imageUrl,
                                )
                              : null,
                      child: imageUrl.isEmpty
                          ? Text(
                              name.isNotEmpty
                                  ? name[0]
                                      .toUpperCase()
                                  : "U",
                              style:
                                  const TextStyle(
                                color:
                                    Colors.white,
                                fontSize:
                                    22,
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
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
                            style:
                                const TextStyle(
                              color:
                                  Colors.white,
                              fontSize:
                                  20,
                              fontWeight:
                                  FontWeight
                                      .w700,
                            ),
                          ),

                          const SizedBox(
                              height: 4),

                          Text(
                            subtitle,
                            style:
                                const TextStyle(
                              color:
                                  Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration:
                          BoxDecoration(
                        color: Colors.white
                            .withOpacity(
                                .15),
                        borderRadius:
                            BorderRadius
                                .circular(
                                    30),
                      ),
                      child: const Row(
                        mainAxisSize:
                            MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.favorite,
                            size: 14,
                            color:
                                Colors.white,
                          ),
                          SizedBox(width: 4),
                          Text(
                            "Liked",
                            style:
                                TextStyle(
                              color: Colors
                                  .white,
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

                const SizedBox(height: 20),

                FutureBuilder<
                    DocumentSnapshot>(
                  future: _firestore
                      .collection(
                          'matches')
                      .doc(
                        _getMatchDocId(
                          widget
                              .currentUserId,
                          profileId,
                        ),
                      )
                      .get(),
                  builder: (
                    context,
                    snapshot,
                  ) {
                    bool matched =
                        snapshot.hasData &&
                            snapshot
                                .data!
                                .exists;

                    return Row(
                      children: [
                        Expanded(
                          child:
                              ElevatedButton
                                  .icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) =>
                                          ViewProfileScreen(
                                    userId:
                                        profileId,
                                  ),
                                ),
                              );
                            },
                            icon:
                                const Icon(
                              Icons
                                  .visibility_rounded,
                            ),
                            label:
                                const Text(
                              "View Profile",
                            ),
                            style:
                                ElevatedButton
                                    .styleFrom(
                              backgroundColor:
                                  Colors.white,
                              foregroundColor:
                                  const Color(
                                0xFF7C3AED,
                              ),
                              minimumSize:
                                  const Size(
                                0,
                                52,
                              ),
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                  16,
                                ),
                              ),
                            ),
                          ),
                        ),

                        if (matched) ...[
                          const SizedBox(
                              width: 10),

                          Expanded(
                            child:
                                ElevatedButton
                                    .icon(
                              onPressed:
                                  () {
                                final matchData =
                                    snapshot.data!.data()
                                        as Map<String, dynamic>;

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) =>
                                            ChatScreen(
                                      chatPartnerId:
                                          profileId,
                                      chatPartnerName:
                                          name,
                                      chatRoomId:
                                          matchData['chatRoomId'],
                                    ),
                                  ),
                                );
                              },
                              icon:
                                  const Icon(
                                Icons
                                    .chat_bubble_rounded,
                              ),
                              label:
                                  const Text(
                                "Chat",
                              ),
                              style:
                                  ElevatedButton
                                      .styleFrom(
                                backgroundColor:
                                    Colors.white24,
                                foregroundColor:
                                    Colors.white,
                                minimumSize:
                                    const Size(
                                  0,
                                  52,
                                ),
                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                    16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

  String _getMatchDocId(String user1Id, String user2Id) {
    List<String> sortedUids = [user1Id, user2Id]..sort();
    return '${sortedUids[0]}_${sortedUids[1]}';
  }
}