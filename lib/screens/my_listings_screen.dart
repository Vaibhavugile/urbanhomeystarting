import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mytennat/screens/view_profile_screen.dart';
import 'package:mytennat/screens/flat_with_flatmate_profile_screen.dart';
import 'package:mytennat/screens/flatmate_profile_screen.dart';
class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() =>
      _MyListingsScreenState();
}

class _MyListingsScreenState
    extends State<MyListingsScreen> {
  List<DocumentSnapshot> _flatListings = [];
  List<DocumentSnapshot> _flatmateProfiles = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchListings();
  }

  Future<void> _fetchListings() async {
    try {
      final user =
          FirebaseAuth.instance.currentUser;

      if (user == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final flatListingsSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('flatListings')
              .get();

      final flatmateSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection(
                'seekingFlatmateProfiles',
              )
              .get();

      setState(() {
        _flatListings =
            flatListingsSnapshot.docs;

        _flatmateProfiles =
            flatmateSnapshot.docs;

        _isLoading = false;
      });
    } catch (e) {
      debugPrint(
        "Error loading listings: $e",
      );

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF8FAFC),

      appBar: AppBar(
  elevation: 0,
  centerTitle: true,
  backgroundColor: Colors.transparent,
  foregroundColor: Colors.white,
  surfaceTintColor: Colors.transparent,

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

  leading: Navigator.canPop(context)
      ? Padding(
          padding: const EdgeInsets.all(8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.15),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: Colors.white.withOpacity(.15),
              ),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 19,
              ),
            ),
          ),
        )
      : null,

  title: const Text(
    "My Listings",
    style: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.w800,
      letterSpacing: -.2,
    ),
  ),

  actions: [
    Padding(
      padding: const EdgeInsets.only(
        right: 10,
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.15),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: Colors.white.withOpacity(.15),
          ),
        ),
        child: IconButton(
          tooltip: 'Refresh',
          onPressed: _isLoading
              ? null
              : _fetchListings,
          icon: const Icon(
            Icons.refresh_rounded,
            color: Colors.white,
            size: 21,
          ),
        ),
      ),
    ),
  ],
),

      body: _isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh:
                  _fetchListings,
              child: ListView(
                physics:
                    const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.all(
                        20),
                children: [
                  const Text(
                    "🏠 Flat Listings",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight:
                          FontWeight.w800,
                      color: Color(
                          0xFF111827),
                    ),
                  ),

                  const SizedBox(
                      height: 6),

                  Text(
                    "${_flatListings.length} listings found",
                    style: const TextStyle(
                      color: Color(
                          0xFF6B7280),
                    ),
                  ),

                  const SizedBox(
                      height: 20),

                 if (_flatListings.isEmpty)
  _emptyCard(
    title: "No Flat Listings Yet",
    subtitle:
        "Create your first flat listing and start receiving interested flatmates.",
    icon: Icons.home_work_rounded,
    buttonText: "Add Flat Listing",
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const FlatmateProfileScreen(),
        ),
      ).then((_) => _fetchListings());
    },
  ),

                 ..._flatListings.map((doc) {
  final data =
      doc.data() as Map<String, dynamic>;

  final userProfile =
      data['userProfile'] ?? {};

  return Container(
    margin: const EdgeInsets.only(
      bottom: 18,
    ),
    decoration: BoxDecoration(
      borderRadius:
          BorderRadius.circular(30),
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
          ).withOpacity(.30),
          blurRadius: 30,
          spreadRadius: 2,
          offset: const Offset(0, 14),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          /// HEADER
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius:
                      BorderRadius.circular(
                          18),
                ),
                child: Center(
                  child: Text(
                    (userProfile['name']
                                ?.toString() ??
                            "U")
                        .substring(0, 1)
                        .toUpperCase(),
                    style:
                        const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      userProfile['name'] ??
                          'Owner',
                      style:
                          const TextStyle(
                        color:
                            Colors.white,
                        fontSize: 20,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),

                    const SizedBox(
                        height: 3),

                    Row(
                      children: [
                        const Icon(
                          Icons
                              .location_on_rounded,
                          size: 14,
                          color:
                              Colors.white70,
                        ),
                        const SizedBox(
                            width: 4),
                        Expanded(
  child: Text(
    data['locationName']?.toString().trim().isNotEmpty == true
        ? data['locationName'].toString()
        : 'Address not available',
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
    style: const TextStyle(
      color: Colors.white70,
    ),
  ),
),
                      ],
                    ),
                  ],
                ),
              ),

              Container(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration:
                    BoxDecoration(
                  color: Colors.white
                      .withOpacity(.15),
                  borderRadius:
                      BorderRadius
                          .circular(
                              20),
                ),
                child: Text(
                  "₹${data['rentPrice']}",
                  style:
                      const TextStyle(
                    color:
                        Colors.white,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          /// DESCRIPTION
          if ((data['flatDescription'] ??
                  '')
              .toString()
              .isNotEmpty)
            Text(
              data['flatDescription'],
              maxLines: 2,
              overflow:
                  TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                height: 1.4,
              ),
            ),

          const SizedBox(height: 18),

          /// PROPERTY CHIPS
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _listingChip(
                data['flatType'] ?? '',
              ),
              _listingChip(
                data[
                        'furnishedStatus'] ??
                    '',
              ),
              _listingChip(
                data['availableFor'] ??
                    '',
              ),
            ],
          ),

          const SizedBox(height: 18),

          /// PROPERTY INFO
          Container(
            padding:
                const EdgeInsets.all(
                    12),
            decoration: BoxDecoration(
              color: Colors.white
                  .withOpacity(.12),
              borderRadius:
                  BorderRadius.circular(
                      16),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.home_work_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "${data['flatType'] ?? ''} • ${data['roomType'] ?? ''}",
                    style:
                        const TextStyle(
                      color:
                          Colors.white,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          /// AMENITIES
          if (data['amenities'] != null)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  (data['amenities']
                          as List)
                      .take(3)
                      .map(
                        (e) =>
                            Container(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal:
                                10,
                            vertical:
                                6,
                          ),
                          decoration:
                              BoxDecoration(
                            color: Colors
                                .white10,
                            borderRadius:
                                BorderRadius.circular(
                                    20),
                          ),
                          child: Text(
                            e.toString(),
                            style:
                                const TextStyle(
                              color: Colors
                                  .white70,
                              fontSize:
                                  12,
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child:
                    ElevatedButton.icon(
                  onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ViewProfileScreen(
        userId: data['uid'],
        profileDocumentId: doc.id,
      ),
    ),
  );
},
                  icon: const Icon(
                    Icons
                        .visibility_rounded,
                    size: 18,
                  ),
                  label:
                      const Text("View"),
                  style:
                      ElevatedButton
                          .styleFrom(
                    backgroundColor:
                        Colors.white,
                    foregroundColor:
                        const Color(
                            0xFF7C3AED),
                    padding:
                        const EdgeInsets
                            .symmetric(
                      vertical: 14,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                                  14),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child:
                    ElevatedButton.icon(
                onPressed: () {
  debugPrint("");
  debugPrint("========================================");
  debugPrint("🟣 EDIT BUTTON CLICKED");
  debugPrint("Firestore Document ID : ${doc.id}");
  debugPrint("Firestore UID         : ${data['uid']}");
  debugPrint("========================================");

  final profile = FlatListingProfile.fromMap(
    data,
    doc.id,
  );

  debugPrint("🟢 FlatListingProfile Created");
  debugPrint("documentId : ${profile.documentId}");
  debugPrint("uid        : ${profile.uid}");
  debugPrint("rentPrice  : ${profile.rentPrice}");
  debugPrint("flatType   : ${profile.flatType}");
  debugPrint("roomType   : ${profile.roomType}");
  debugPrint("location   : ${profile.locationName}");
  debugPrint("========================================");

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => FlatmateProfileScreen(
        existingProfile: profile,
      ),
    ),
  ).then((_) {
    debugPrint("🔄 Returned from Edit Screen");
    _fetchListings();
  });
},
                  icon: const Icon(
                    Icons.edit_rounded,
                    size: 18,
                  ),
                  label:
                      const Text("Edit"),
                  style:
                      ElevatedButton
                          .styleFrom(
                    backgroundColor:
                        Colors.white24,
                    foregroundColor:
                        Colors.white,
                    padding:
                        const EdgeInsets
                            .symmetric(
                      vertical: 14,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                                  14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}),
                  const SizedBox(
                      height: 30),

                  const Divider(),

                  const SizedBox(
                      height: 20),

                  const Text(
                    "👥 Flatmate Profiles",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight:
                          FontWeight.w800,
                      color: Color(
                          0xFF111827),
                    ),
                  ),

                  const SizedBox(
                      height: 6),

                  Text(
                    "${_flatmateProfiles.length} profiles found",
                    style: const TextStyle(
                      color: Color(
                          0xFF6B7280),
                    ),
                  ),

                  const SizedBox(
                      height: 20),

                  if (_flatmateProfiles.isEmpty)
  _emptyCard(
    title: "No Flatmate Profile Yet",
    subtitle:
        "Create your profile so landlords and roommates can discover you.",
    icon: Icons.groups_rounded,
    buttonText: "Create Profile",
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const FlatWithFlatmateProfileScreen(),
        ),
      ).then((_) => _fetchListings());
    },
  ),

..._flatmateProfiles.map((doc) {
  final data =
      doc.data() as Map<String, dynamic>;

  final userProfile =
      data['userProfile'] ?? {};
  final flatRequirements =
    data['flatRequirements'] as Map<String, dynamic>? ?? {};

final flatmatePreferences =
    data['flatmatePreferences'] as Map<String, dynamic>? ?? {};

  return Container(
    margin: const EdgeInsets.only(
      bottom: 18,
    ),
    decoration: BoxDecoration(
      borderRadius:
          BorderRadius.circular(30),
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
          ).withOpacity(.30),
          blurRadius: 30,
          spreadRadius: 2,
          offset: const Offset(0, 14),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          /// HEADER
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius:
                      BorderRadius.circular(
                          18),
                ),
                child: Center(
                  child: Text(
                    (userProfile['name']
                                ?.toString() ??
                            "U")
                        .substring(0, 1)
                        .toUpperCase(),
                    style:
                        const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      userProfile['name'] ??
                          'Flatmate',
                      style:
                          const TextStyle(
                        color:
                            Colors.white,
                        fontSize: 20,
                        fontWeight:
                            FontWeight
                                .w800,
                      ),
                    ),

                    const SizedBox(
                        height: 3),

                    Row(
                      children: [
                        const Icon(
                          Icons
                              .location_on_rounded,
                          size: 14,
                          color:
                              Colors.white70,
                        ),
                        const SizedBox(
                            width: 4),
                       Expanded(
  child: Text(
    data['locationName']?.toString().trim().isNotEmpty == true
        ? data['locationName'].toString()
        : 'Address not available',
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
    style: const TextStyle(
      color: Colors.white70,
    ),
  ),
),
                      ],
                    ),
                  ],
                ),
              ),

              Container(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration:
                    BoxDecoration(
                  color: Colors.white
                      .withOpacity(.15),
                  borderRadius:
                      BorderRadius
                          .circular(
                              20),
                ),
                child: Text(
                  "₹${data['budgetMin']} - ₹${data['budgetMax']}",
                  style:
                      const TextStyle(
                    color:
                        Colors.white,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          /// BIO
          if ((userProfile['bio'] ?? '')
              .toString()
              .isNotEmpty)
            Text(
              userProfile['bio'],
              maxLines: 2,
              overflow:
                  TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                height: 1.4,
              ),
            ),

          const SizedBox(height: 18),

          /// BADGES
         Wrap(
  spacing: 8,
  runSpacing: 8,
  children: [

    if ((flatRequirements['preferredFlatType'] ?? '')
        .toString()
        .isNotEmpty)
      _listingChip(
        flatRequirements['preferredFlatType'],
      ),

    if ((flatRequirements['preferredRoomType'] ?? '')
        .toString()
        .isNotEmpty)
      _listingChip(
        flatRequirements['preferredRoomType'],
      ),

    if ((flatmatePreferences['preferredOccupation'] ?? '')
        .toString()
        .isNotEmpty)
      _listingChip(
        flatmatePreferences['preferredOccupation'],
      ),

    if ((flatmatePreferences['preferredFlatmateGender'] ?? '')
        .toString()
        .isNotEmpty)
      _listingChip(
        flatmatePreferences['preferredFlatmateGender'],
      ),
  ],
),

          const SizedBox(height: 18),

          Container(
            padding:
                const EdgeInsets.all(
                    12),
            decoration: BoxDecoration(
              color: Colors.white
                  .withOpacity(.12),
              borderRadius:
                  BorderRadius.circular(
                      16),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.home_work_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                          "${flatRequirements['preferredFlatType'] ?? ''} • ${flatRequirements['preferredRoomType'] ?? ''}" ,
                                             style:
                        const TextStyle(
                      color:
                          Colors.white,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ViewProfileScreen(
        userId: data['uid'],
        profileDocumentId: doc.id,
      ),
    ),
  );
},
                  icon: const Icon(
                    Icons
                        .visibility_rounded,
                    size: 18,
                  ),
                  label:
                      const Text("View"),
                  style:
                      ElevatedButton
                          .styleFrom(
                    backgroundColor:
                        Colors.white,
                    foregroundColor:
                        const Color(
                            0xFF7C3AED),
                    padding:
                        const EdgeInsets
                            .symmetric(
                      vertical: 14,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                                  14),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
  final profile = SeekingFlatmateProfile.fromMap(
    data,
    doc.id,
  );

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => FlatWithFlatmateProfileScreen(
        existingProfile: profile,
      ),
    ),
  ).then((_) {
    _fetchListings();
  });
},
                  icon: const Icon(
                    Icons.edit_rounded,
                    size: 18,
                  ),
                  label:
                      const Text("Edit"),
                  style:
                      ElevatedButton
                          .styleFrom(
                    backgroundColor:
                        Colors.white24,
                    foregroundColor:
                        Colors.white,
                    padding:
                        const EdgeInsets
                            .symmetric(
                      vertical: 14,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                                  14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}),

                  const SizedBox(
                      height: 30),
                ],
              ),
            ),
    );
  }

 Widget _emptyCard({
  required String title,
  required String subtitle,
  required IconData icon,
  required String buttonText,
  required VoidCallback onPressed,
}) {
  return Container(
    padding: const EdgeInsets.all(28),
    margin: const EdgeInsets.only(bottom: 20),
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
      children: [
        Icon(
          icon,
          size: 60,
          color: const Color(0xFF7C3AED),
        ),
        const SizedBox(height: 18),

        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.grey,
            height: 1.4,
          ),
        ),

        const SizedBox(height: 22),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onPressed,
            icon: const Icon(Icons.add_rounded),
            label: Text(buttonText),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C3AED),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
  Widget _listingChip(
  String text,
) {
  return Container(
    padding:
        const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 6,
    ),
    decoration: BoxDecoration(
      color: Colors.white12,
      borderRadius:
          BorderRadius.circular(20),
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
}