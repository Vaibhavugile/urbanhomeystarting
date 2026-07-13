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
  color: Colors.white,

  borderRadius: BorderRadius.circular(28),

  border: Border.all(
    color: const Color(0xFFEDE9FE),
    width: 1,
  ),

  boxShadow: [
    BoxShadow(
      color: const Color(0xFF7C3AED)
          .withOpacity(.10),
      blurRadius: 28,
      spreadRadius: 0,
      offset: const Offset(0, 12),
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
  color: const Color(0xFFDDD6FE),
  width: 3,
),
                        ),
                        child: ClipOval(
                          child: imageUrl != null
                              ? Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  color: const Color(0xFFF5F3FF),
                                  child: const Icon(
                                    Icons.person,
                                    color: const Color(0xFF7C3AED),
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
  color: Color(0xFF111827),
  fontSize: 20,
  fontWeight: FontWeight.w800,
  letterSpacing: -.2,
),
                            ),
                          ),

                       Container(
  padding: const EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 6,
  ),
  decoration: BoxDecoration(
    gradient: const LinearGradient(
      colors: [
        Color(0xFF7C3AED),
        Color(0xFFEC4899),
      ],
    ),
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFF7C3AED)
            .withOpacity(.18),
        blurRadius: 12,
        offset: const Offset(0, 5),
      ),
    ],
  ),
  child: Text(
    "$matchPercentage% Match",
    style: const TextStyle(
      color: Colors.white,
      fontSize: 11,
      fontWeight: FontWeight.w800,
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
                    /// LOCATION
Row(
  children: [
    const Icon(
      Icons.location_on_rounded,
      color: Color(0xFF7C3AED),
      size: 16,
    ),
    const SizedBox(width: 5),
    Expanded(
      child: Text(
        address.isNotEmpty ? address : city,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Color(0xFF64748B),
          fontSize: 13,
          fontWeight: FontWeight.w500,
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
        color: Color(0xFFEC4899),
        size: 15,
      ),

      const SizedBox(width: 5),

      Text(
        distanceText!,
        style: const TextStyle(
          color: Color(0xFFEC4899),
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  ),
],

                      const SizedBox(height: 6),

                      /// OCCUPATION
                      /// OCCUPATION
Row(
  children: [
    const Icon(
      Icons.work_outline_rounded,
      size: 15,
      color: Color(0xFF7C3AED),
    ),
    const SizedBox(width: 5),
    Expanded(
      child: Text(
        occupation,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Color(0xFF475569),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  ],
),

                      const SizedBox(height: 10),

                      /// PROPERTY
                      Container(
  padding: const EdgeInsets.symmetric(
    horizontal: 11,
    vertical: 7,
  ),
  decoration: BoxDecoration(
    color: const Color(0xFFF8F7FF),
    borderRadius: BorderRadius.circular(14),
    border: Border.all(
      color: const Color(0xFFEDE9FE),
    ),
  ),
  child: Text(
    propertyInfo,
    style: const TextStyle(
      color: Color(0xFF6D28D9),
      fontSize: 12,
      fontWeight: FontWeight.w700,
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
                           decoration: BoxDecoration(
  gradient: const LinearGradient(
    colors: [
      Color(0xFF7C3AED),
      Color(0xFF9333EA),
      Color(0xFFEC4899),
    ],
  ),
  borderRadius: BorderRadius.circular(30),
  boxShadow: [
    BoxShadow(
      color: const Color(0xFF7C3AED)
          .withOpacity(.14),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ],
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

                          if (lifestyle.isNotEmpty)
  Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 10,
      vertical: 6,
    ),
    decoration: BoxDecoration(
      color: const Color(0xFFFDF2F8),
      borderRadius: BorderRadius.circular(30),
      border: Border.all(
        color: const Color(0xFFFBCFE8),
      ),
    ),
    child: Text(
      lifestyle,
      style: const TextStyle(
        color: Color(0xFFBE185D),
        fontSize: 12,
        fontWeight: FontWeight.w600,
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
                                    decoration: BoxDecoration(
  color: const Color(0xFFF8FAFC),
  borderRadius: BorderRadius.circular(20),
  border: Border.all(
    color: const Color(0xFFE2E8F0),
  ),
),
                                    child: Text(
                                      e,
                                     style: const TextStyle(
  color: Color(0xFF64748B),
  fontSize: 11,
  fontWeight: FontWeight.w600,
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
    /// PASS BUTTON
    Expanded(
      child: SizedBox(
        height: 46,
        child: OutlinedButton.icon(
          onPressed: onPass,
          style: OutlinedButton.styleFrom(
            backgroundColor: const Color(0xFFFAF5FF),
            foregroundColor: const Color(0xFF7C3AED),
            side: const BorderSide(
              color: Color(0xFFDDD6FE),
              width: 1.2,
            ),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          icon: const Icon(
            Icons.close_rounded,
            size: 20,
          ),
          label: const Text(
            'Dislike',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    ),

    const SizedBox(width: 12),

    /// LIKE BUTTON
    Expanded(
      child: SizedBox(
        height: 46,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF7C3AED),
                Color(0xFF9333EA),
                Color(0xFFEC4899),
              ],
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7C3AED)
                    .withOpacity(.20),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: onLike,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            icon: const Icon(
              Icons.favorite_rounded,
              size: 19,
            ),
            label: const Text(
              'Like',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
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
      horizontal: 10,
      vertical: 6,
    ),
    decoration: BoxDecoration(
      color: color.withOpacity(.10),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: color.withOpacity(.22),
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: color,
          size: 14,
        ),
        const SizedBox(width: 5),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (text == "Verified") ...[
          const SizedBox(width: 4),
          const Icon(
            Icons.workspace_premium_rounded,
            color: Color(0xFFF59E0B),
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
      horizontal: 10,
      vertical: 6,
    ),
    decoration: BoxDecoration(
      color: const Color(0xFFF5F3FF),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: const Color(0xFFDDD6FE),
      ),
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: Color(0xFF7C3AED),
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}
}