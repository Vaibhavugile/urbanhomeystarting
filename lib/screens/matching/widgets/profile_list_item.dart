import 'package:flutter/material.dart';
import 'package:mytennat/screens/flatmate_profile_screen.dart';
import 'package:mytennat/screens/flat_with_flatmate_profile_screen.dart';

class ProfileListItem extends StatelessWidget {
  final dynamic profile;
  final VoidCallback onTap;
  final String? distanceText;
final int matchPercentage;
final VoidCallback? onLike;

final VoidCallback? onPass;

 const ProfileListItem({
  super.key,
  required this.profile,
  required this.onTap,
required this.matchPercentage,
  this.distanceText,
  this.onLike,
  this.onPass,
});

  @override
  Widget build(BuildContext context) {
    String name = '';
    String city = '';
    String address = '';
    String occupation = '';
    String age = '';
    String budgetText = '';
    String propertyInfo = '';
    String lifestyle = '';
    String badgeText = '';
    String? imageUrl;

    List<String> tags = [];

    if (profile is FlatListingProfile) {
     final String fullName =
    profile.userProfile.name?.trim() ?? '';

name = fullName.isNotEmpty
    ? fullName.split(RegExp(r'\s+')).first
    : 'Flat Owner';
      city = profile.userProfile.city ?? '';
      address = profile.locationName ?? '';
      occupation = profile.userProfile.occupation ?? '';
      age = profile.userProfile.age?.toString() ?? '';

      budgetText = '₹${profile.rentPrice ?? 0}/month';

      propertyInfo =
          '${profile.flatType ?? ''} • ${profile.furnishedStatus ?? ''}';

      lifestyle =
          profile.userProfile.cleanlinessLevel ?? '';

      badgeText = '🏠 Flat Available';

      if (profile.amenities != null) {
        tags = List<String>.from(profile.amenities);
      }

      if (profile.imageUrls != null &&
          profile.imageUrls!.isNotEmpty) {
        imageUrl = profile.imageUrls!.first;
      }
    }

    if (profile is SeekingFlatmateProfile) {
      final String fullName =
    profile.userProfile.name?.trim() ?? '';

name = fullName.isNotEmpty
    ? fullName.split(RegExp(r'\s+')).first
    : 'Flatmate';
      city = profile.userProfile.city ?? '';
      address = profile.locationName ?? '';
      occupation = profile.userProfile.occupation ?? '';
      age = profile.userProfile.age?.toString() ?? '';

      budgetText =
          '₹${profile.budgetMin ?? 0} - ₹${profile.budgetMax ?? 0}';

      propertyInfo =
          '${profile.preferredFlatType ?? ''} • ${profile.preferredRoomType ?? ''}';

      lifestyle =
          profile.userProfile.drinkingHabit ?? '';

      badgeText = '🔍 Looking For Flat';

      try {
        tags = List<String>.from(
          profile.flatmatePreferences.preferredHabits ?? [],
        );
      } catch (_) {}

      if (profile.imageUrls != null &&
          profile.imageUrls!.isNotEmpty) {
        imageUrl = profile.imageUrls!.first;
      }
    }
    final isVerified =
    profile.userProfile.isVerified;

final verificationStatus =
    profile.userProfile.verificationStatus;

IconData verificationIcon;
Color verificationColor;
String verificationText;

if (isVerified) {
  verificationIcon = Icons.verified_rounded;
  verificationColor = const Color(0xFF00C853);
  verificationText = "Verified";
} else if (verificationStatus == "pending") {
  verificationIcon = Icons.hourglass_top_rounded;
  verificationColor = const Color(0xFFFF9800);
  verificationText = "Pending Review";
} else if (verificationStatus == "rejected") {
  verificationIcon = Icons.gpp_bad_rounded;
  verificationColor = const Color(0xFFFF5252);
  verificationText = "Verification Failed";
} else {
  verificationIcon = Icons.shield_outlined;
  verificationColor = const Color(0xFF78909C);
  verificationText = "Not Verified";
}

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFF6A1B9A),
    Color(0xFF8E24AA),
    Color(0xFFAD1457),
  ],
),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.25),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                /// PROFILE IMAGE
                Stack(
                  children: [
                    Hero(
                      tag: 'profile_$name$city',
                      child: Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white24,
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: imageUrl != null
                              ? Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  color: Colors.white10,
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 42,
                                  ),
                                ),
                        ),
                      ),
                    ),

                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [

                      /// NAME
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              age.isNotEmpty
                                  ? '$name, $age'
                                  : name,
                              maxLines: 1,
                              overflow:
                                  TextOverflow.ellipsis,
                              style:
                                  const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight:
                                    FontWeight.w700,
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
                              color:
                                  Colors.greenAccent
                                      .withOpacity(
                                          .15),
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                          20),
                            ),
                            child:  Text(
  "$matchPercentage% Match",
  style: const TextStyle(
    color: Colors.greenAccent,
    fontSize: 11,
    fontWeight: FontWeight.bold,
  ),
),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      /// VERIFIED + BADGE
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _chip(
  verificationIcon,
  verificationText,
  verificationColor,
),
                          _textChip(
                            badgeText,
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      /// LOCATION
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.white70,
                            size: 15,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
  child: Text(
    address.isNotEmpty
        ? address
        : city,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: const TextStyle(
      color: Colors.white70,
      fontSize: 13,
    ),
  ),
),
                        ],
                      ),
                      if (distanceText != null) ...[

  const SizedBox(height: 6),

  Row(
    children: [

      const Icon(
        Icons.near_me_rounded,
        color: Colors.greenAccent,
        size: 15,
      ),

      const SizedBox(width: 4),

      Text(
        distanceText!,
        style: const TextStyle(
          color: Colors.greenAccent,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  ),
],

                      const SizedBox(height: 6),

                      /// OCCUPATION
                      Row(
                        children: [
                          const Icon(
                            Icons.work_outline,
                            size: 15,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              occupation,
                              maxLines: 1,
                              overflow:
                                  TextOverflow
                                      .ellipsis,
                              style:
                                  const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      /// PROPERTY
                      Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration:
                            BoxDecoration(
                          color:
                              Colors.white10,
                          borderRadius:
                              BorderRadius
                                  .circular(
                                      14),
                        ),
                        child: Text(
                          propertyInfo,
                          style:
                              const TextStyle(
                            color:
                                Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: [

                          /// BUDGET
                          Container(
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration:
                                BoxDecoration(
                              color:
                                  Colors.deepPurple,
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                          30),
                            ),
                            child: Text(
                              budgetText,
                              style:
                                  const TextStyle(
                                color:
                                    Colors.white,
                                fontSize: 12,
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),
                          ),

                          const SizedBox(width: 8),

                          if (lifestyle
                              .isNotEmpty)
                            Container(
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration:
                                  BoxDecoration(
                                color:
                                    Colors.white12,
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                            30),
                              ),
                              child: Text(
                                lifestyle,
                                style:
                                    const TextStyle(
                                  color:
                                      Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),

                      if (tags.isNotEmpty)
                        Padding(
                          padding:
                              const EdgeInsets
                                  .only(
                                      top: 12),
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: tags
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
                                          5,
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
                                      e,
                                      style:
                                          const TextStyle(
                                        color: Colors
                                            .white70,
                                        fontSize:
                                            11,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        const SizedBox(height: 14),

Row(
  children: [

    Expanded(
      child: OutlinedButton.icon(
        onPressed: onPass,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(
            color: Colors.white24,
          ),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(16),
          ),
        ),
        icon: const Icon(
          Icons.close_rounded,
        ),
        label: const Text(
          'Pass',
        ),
      ),
    ),

    const SizedBox(width: 12),

    Expanded(
      child: ElevatedButton.icon(
        onPressed: onLike,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              const Color(0xFF22C55E),
          foregroundColor:
              Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(16),
          ),
        ),
        icon: const Icon(
          Icons.favorite_rounded,
        ),
        label: const Text(
          'Like',
        ),
      ),
    ),
  ],
),
                    ],
                  ),
                ),

                
              ],
            ),
          ),
        ),
      ),
    );
  }

 static Widget _chip(
  IconData icon,
  String text,
  Color color,
) {
  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 7,
    ),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          color,
          color.withOpacity(.75),
        ],
      ),
      borderRadius: BorderRadius.circular(30),
      border: Border.all(
        color: Colors.white.withOpacity(.25),
      ),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(.35),
          blurRadius: 14,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [

        Icon(
          icon,
          color: Colors.white,
          size: 14,
        ),

        const SizedBox(width: 5),

        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: .3,
          ),
        ),

        if (text == "Verified") ...[
          const SizedBox(width: 5),
          const Icon(
            Icons.workspace_premium_rounded,
            color: Color(0xFFFFD54F),
            size: 13,
          ),
        ],
      ],
    ),
  );
}

  static Widget _textChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(.2),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}