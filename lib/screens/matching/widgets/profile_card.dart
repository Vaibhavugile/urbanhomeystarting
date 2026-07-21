
import 'package:flutter/material.dart';
import 'package:mytennat/screens/flatmate_profile_screen.dart';
import 'package:mytennat/screens/flat_with_flatmate_profile_screen.dart';
import 'profile_details_sheet.dart';
const LinearGradient kPrimaryGradient =
    LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFF7C3AED),
    Color(0xFF9333EA),
    Color(0xFFEC4899),
  ],
);
class ProfileCard extends StatefulWidget {
  final dynamic profile;
  final VoidCallback onLike;
  final VoidCallback onPass;
final String? distanceText;
 final int matchPercentage; // NEW
 const ProfileCard({
  super.key,
  required this.profile,
  required this.onLike,
  required this.onPass,
  this.distanceText,
  required this.matchPercentage, // NEW
});

@override
State<ProfileCard> createState() =>
    _ProfileCardState();
}
class _ProfileCardState
    extends State<ProfileCard> {

  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
   final profile = widget.profile;

    final onLike = widget.onLike;

    final onPass = widget.onPass;

    final distanceText =
        widget.distanceText;
      debugPrint('========================');
  debugPrint('PROFILE CARD BUILDING');
  debugPrint('Profile Type: ${profile.runtimeType}');
  debugPrint('Profile ID: ${profile.documentId}');
  debugPrint('========================');

  try {
   String name = '';
String city = '';
String address = '';
String age = '';
String occupation = '';
String? imageUrl;

List<String> imageUrls = [];

String budgetText = '';
String propertyText = '';

String gender = '';
String religion = '';

String cleanliness = '';
String smoking = '';
String drinking = '';
String food = '';

String petTolerance = '';
String socialPreference = '';

String bathroomType = '';
String availableFor = '';
String preferredOccupation = '';
String moveInDateText = '';
String preferredGender = '';
String preferredAge = '';
String preferredFlatType = '';
String preferredRoomType = '';
String preferredFurnishedStatus = '';

List<String> desiredAmenities = [];
String bio = '';

List<String> tags = [];

if (profile is FlatListingProfile) {
  final String fullName =
    profile.userProfile.name?.trim() ?? '';

name = fullName.isNotEmpty
    ? fullName.split(RegExp(r'\s+')).first
    : 'Flat Owner';
  city = profile.userProfile.city ?? '';
  age = profile.userProfile.age?.toString() ?? '';
  occupation = profile.userProfile.occupation ?? '';
  bio = profile.userProfile.bio ?? '';
  preferredOccupation =
    profile.preferredOccupation ?? '';
preferredGender =
    profile.preferredGender ?? '';
    preferredAge =
    profile.preferredAgeGroup ?? '';
  budgetText = '₹${profile.rentPrice ?? 0}/month';

  propertyText =
      '${profile.flatType ?? ''} • ${profile.furnishedStatus ?? ''}';
      print("Flat Type: ${profile.flatType}");
print("Furnished: ${profile.furnishedStatus}");
print("PropertyText: $propertyText");
print("rentPrice: ${profile.rentPrice}");


  address = profile.locationName ?? '';

  availableFor =
      profile.availableFor ?? '';

  bathroomType =
      profile.roomType ?? '';

  gender =
      profile.userProfile.gender ?? '';

  religion =
      profile.userProfile.religion ?? '';

  cleanliness =
      profile.userProfile.cleanlinessLevel ?? '';

  smoking =
      profile.userProfile.smokingHabit ?? '';

  drinking =
      profile.userProfile.drinkingHabit ?? '';

  food =
      profile.userProfile.foodPreference ?? '';

  petTolerance =
      profile.userProfile.petTolerance ?? '';

  socialPreference =
      profile.userProfile.socialPreferences ?? '';

  if (profile.amenities != null) {
    tags = List<String>.from(
      profile.amenities,
    );
  }

  if (profile.imageUrls != null &&
    profile.imageUrls!.isNotEmpty) {

  imageUrls =
      List<String>.from(
        profile.imageUrls!,
      );

  if (_currentImageIndex >=
      imageUrls.length) {
    _currentImageIndex = 0;
  }

  imageUrl =
      imageUrls[
          _currentImageIndex];
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
  age = profile.userProfile.age?.toString() ?? '';
  occupation =
      profile.userProfile.occupation ?? '';

  bio = profile.userProfile.bio ?? '';

  budgetText =
      '₹${profile.budgetMin ?? 0} - ₹${profile.budgetMax ?? 0}';

  gender =
      profile.userProfile.gender ?? '';

  religion =
      profile.userProfile.religion ?? '';

  cleanliness =
      profile.userProfile.cleanlinessLevel ?? '';

  smoking =
      profile.userProfile.smokingHabit ?? '';

  drinking =
      profile.userProfile.drinkingHabit ?? '';

  food =
      profile.userProfile.foodPreference ?? '';

  petTolerance =
      profile.userProfile.petTolerance ?? '';

  socialPreference =
      profile.userProfile.socialPreferences ?? '';
      preferredFlatType =
    profile.preferredFlatType ?? '';

preferredRoomType =
    profile.preferredRoomType ?? '';

preferredFurnishedStatus =
    profile.preferredFurnishedStatus ?? '';
preferredOccupation =
    profile.preferredOccupation ?? '';

desiredAmenities = List<String>.from(
  profile.amenitiesDesired ?? [],
);

  try {
   propertyText = preferredFlatType;

    preferredGender =
    profile.preferredFlatmateGender ?? '';

preferredAge =
    profile.preferredFlatmateAge ?? '';


    tags = List<String>.from(
      profile.preferredHabits ??
          [],
    );

  final moveInDate =
    profile.moveInDate;

if (moveInDate != null) {
  moveInDateText =
      '${moveInDate.day}/${moveInDate.month}/${moveInDate.year}';
}
  } catch (_) {}

  if (profile.imageUrls != null &&
    profile.imageUrls!.isNotEmpty) {

  imageUrls =
      List<String>.from(
        profile.imageUrls!,
      );

  if (_currentImageIndex >=
      imageUrls.length) {
    _currentImageIndex = 0;
  }

  imageUrl =
      imageUrls[
          _currentImageIndex];
}
  print("===== SEEKING PROFILE =====");
print(profile.preferredFlatType);
print(profile.preferredRoomType);
print(profile.preferredFurnishedStatus);
print(profile.preferredFlatmateGender);
print(profile.preferredFlatmateAge);
}
final isVerified = profile.userProfile.isVerified;

final verificationStatus =
    profile.userProfile.verificationStatus;
Color badgeColor;
List<Color> badgeGradient;
IconData badgeIcon;
String badgeText;

if (isVerified) {
  badgeColor = const Color(0xFF00C853);

  badgeGradient = const [
    Color(0xFF00C853),
    Color(0xFF64DD17),
  ];

  badgeIcon = Icons.verified_rounded;

  badgeText = "Verified";

} else if (verificationStatus == "pending") {

  badgeColor = const Color(0xFFFF9800);

  badgeGradient = const [
    Color(0xFFFF9800),
    Color(0xFFFFC107),
  ];

  badgeIcon = Icons.hourglass_top_rounded;

  badgeText = "Verification Pending";

} else if (verificationStatus == "rejected") {

  badgeColor = const Color(0xFFFF5252);

  badgeGradient = const [
    Color(0xFFFF5252),
    Color(0xFFFF1744),
  ];

  badgeIcon = Icons.gpp_bad_rounded;

  badgeText = "Verification Failed";

} else {

  badgeColor = const Color(0xFF607D8B);

  badgeGradient = const [
    Color(0xFF607D8B),
    Color(0xFF90A4AE),
  ];

  badgeIcon = Icons.shield_outlined;

  badgeText = "Not Verified";
}


final media = MediaQuery.of(context);

final double screenHeight = media.size.height;
final double screenWidth = media.size.width;

final bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;

final bool compactScreen =
    screenHeight < 760 ||
    screenWidth < 390 ||
    isIOS;

final int imageFlex = compactScreen ? 34 : 46;

final int contentFlex = compactScreen ? 66 : 54;
    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      margin: const EdgeInsets.all(12),
      child: Card(
        elevation: 15,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        clipBehavior: Clip.antiAlias,
child: Column(
  children: [

    Expanded(
      flex:imageFlex,
      child: Stack(
        fit: StackFit.expand,
        children: [

         /// IMAGE
imageUrl != null
    ? Image.network(
        imageUrl,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        filterQuality: FilterQuality.high,

        loadingBuilder: (
          context,
          child,
          loadingProgress,
        ) {
          if (loadingProgress == null) {
            return child;
          }

          return Container(
            color: const Color(0xFFF5F3FF),
            child: const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF7C3AED),
                strokeWidth: 2,
              ),
            ),
          );
        },

        errorBuilder: (
          context,
          error,
          stackTrace,
        ) {
          return Container(
            color: const Color(0xFFF5F3FF),
            child: const Center(
              child: Icon(
                Icons.broken_image_outlined,
                size: 70,
                color: Color(0xFF7C3AED),
              ),
            ),
          );
        },
      )
    : Container(
        color: const Color(0xFFF5F3FF),
        child: const Center(
          child: Icon(
            Icons.person_rounded,
            size: 100,
            color: Color(0xFF7C3AED),
          ),
        ),
      ),

/// LEFT IMAGE TAP AREA
Positioned(
  left: 0,
  top: 0,
  bottom: 0,
  width: 80,
  child: GestureDetector(
    behavior: HitTestBehavior.translucent,
    onTap: () {
      if (_currentImageIndex > 0) {
        setState(() {
          _currentImageIndex--;
        });
      }
    },
  ),
),

/// RIGHT IMAGE TAP AREA
Positioned(
  right: 0,
  top: 0,
  bottom: 0,
  width: 80,
  child: GestureDetector(
    behavior: HitTestBehavior.translucent,
    onTap: () {
      if (_currentImageIndex <
          imageUrls.length - 1) {
        setState(() {
          _currentImageIndex++;
        });
      }
    },
  ),
),
/// IMAGE INDICATORS
Positioned(
  top: 14,
  left: 14,
  right: 14,
  child: Row(
    children: List.generate(
      imageUrls.isEmpty ? 1 : imageUrls.length,
      (index) {
        final bool isActive =
            index == _currentImageIndex;

        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(
              milliseconds: 220,
            ),
            height: 4,
            margin: const EdgeInsets.symmetric(
              horizontal: 2,
            ),
            decoration: BoxDecoration(
              gradient:
                  isActive ? kPrimaryGradient : null,

              color: isActive
                  ? null
                  : Colors.white.withOpacity(.55),

              borderRadius:
                  BorderRadius.circular(999),

              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: const Color(0xFF7C3AED)
                            .withOpacity(.25),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            ),
          ),
        );
      },
    ),
  ),
),
/// MATCH BADGE
Positioned(
  left: 14,
  bottom: 14,
  child: Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 7,
    ),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(.94),
      borderRadius: BorderRadius.circular(999),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(.10),
          blurRadius: 14,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.auto_awesome_rounded,
          size: 15,
          color: Color(0xFFEC4899),
        ),
        const SizedBox(width: 5),
        Text(
          '${widget.matchPercentage}% Match',
          style: const TextStyle(
            color: Color(0xFF7C3AED),
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  ),
),

/// RENT / BUDGET BADGE
Positioned(
  right: 14,
  bottom: 14,
  child: Container(
    constraints: const BoxConstraints(
      maxWidth: 160,
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: 13,
      vertical: 7,
    ),
    decoration: BoxDecoration(
      gradient: kPrimaryGradient,
      borderRadius: BorderRadius.circular(999),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF7C3AED)
              .withOpacity(.22),
          blurRadius: 14,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Text(
      budgetText,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w800,
      ),
    ),
  ),
),
        ],
      ),
    ),

    Expanded(
  flex: contentFlex,
  child: Container(
    width: double.infinity,
    color: Colors.white,
    padding: const EdgeInsets.fromLTRB(
      18,
      16,
      18,
      16,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// NAME + AGE + VERIFICATION
        Row(
          children: [

            Expanded(
              child: Text(
                age.isNotEmpty
                    ? '$name, $age'
                    : name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -.4,
                ),
              ),
            ),

            const SizedBox(width: 10),

            /// VERIFICATION STATUS
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 9,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: badgeColor.withOpacity(.10),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: badgeColor.withOpacity(.22),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    badgeIcon,
                    color: badgeColor,
                    size: 14,
                  ),

                  const SizedBox(width: 4),

                  Text(
                    badgeText,
                    style: TextStyle(
                      color: badgeColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        /// WE WILL ADD LOCATION NEXT
        const SizedBox(height: 10),

/// LOCATION
Row(
  children: [
    const Icon(
      Icons.location_on_rounded,
      color: Color(0xFF7C3AED),
      size: 17,
    ),

    const SizedBox(width: 5),

    Expanded(
      child: Text(
        address.isNotEmpty
            ? address
            : city,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Color(0xFF475569),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  ],
),

const SizedBox(height: 7),

/// DISTANCE + OCCUPATION
Row(
  children: [

    if (distanceText != null) ...[
      const Icon(
        Icons.near_me_rounded,
        color: Color(0xFFEC4899),
        size: 15,
      ),

      const SizedBox(width: 4),

      Text(
        distanceText!,
        style: const TextStyle(
          color: Color(0xFFEC4899),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),

      const SizedBox(width: 10),

      Container(
        width: 4,
        height: 4,
        decoration: const BoxDecoration(
          color: Color(0xFFCBD5E1),
          shape: BoxShape.circle,
        ),
      ),

      const SizedBox(width: 10),
    ],

    const Icon(
      Icons.work_outline_rounded,
      color: Color(0xFF7C3AED),
      size: 15,
    ),

    const SizedBox(width: 4),

    Expanded(
      child: Text(
        occupation,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Color(0xFF64748B),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  ],
),
const SizedBox(height: 14),

/// PROFILE-SPECIFIC SECTION TITLE
Text(
  profile is FlatListingProfile
      ? 'Property'
      : 'Looking for a Home',
  style: const TextStyle(
    color: Color(0xFF111827),
    fontSize: 13,
    fontWeight: FontWeight.w800,
  ),
),

const SizedBox(height: 8),

/// PROFILE-SPECIFIC CHIPS
Wrap(
  spacing: 7,
  runSpacing: 7,
  children: [

    /// FLAT LISTING PROFILE
    if (profile is FlatListingProfile) ...[
      if (profile.flatType.isNotEmpty)
        _buildPremiumInfoChip(
          Icons.home_work_outlined,
          profile.flatType,
        ),

      if (profile.furnishedStatus.isNotEmpty)
        _buildPremiumInfoChip(
          Icons.chair_outlined,
          profile.furnishedStatus,
        ),

      if (profile.roomType.isNotEmpty)
        _buildPremiumInfoChip(
          Icons.bed_outlined,
          profile.roomType,
        ),
    ],

    /// SEEKING FLATMATE PROFILE
    if (profile is SeekingFlatmateProfile) ...[
      if (preferredFlatType.isNotEmpty)
        _buildPremiumInfoChip(
          Icons.home_work_outlined,
          preferredFlatType,
        ),

      if (preferredRoomType.isNotEmpty)
        _buildPremiumInfoChip(
          Icons.bed_outlined,
          preferredRoomType,
        ),

      if (preferredFurnishedStatus.isNotEmpty)
        _buildPremiumInfoChip(
          Icons.chair_outlined,
          preferredFurnishedStatus,
        ),
    ],
  ],
),
const SizedBox(height: 12),

/// =====================================================
/// PREFERENCES
/// =====================================================
const Text(
  'Preferences',
  style: TextStyle(
    color: Color(0xFF111827),
    fontSize: 13,
    fontWeight: FontWeight.w800,
  ),
),

const SizedBox(height: 8),

Wrap(
  spacing: 7,
  runSpacing: 7,
  children: [

    if (preferredGender.isNotEmpty)
      _buildPremiumPreferenceChip(
        Icons.person_outline_rounded,
        preferredGender,
      ),

    if (preferredAge.isNotEmpty)
      _buildPremiumPreferenceChip(
        Icons.cake_outlined,
        preferredAge,
      ),

    if (preferredOccupation.isNotEmpty)
      _buildPremiumPreferenceChip(
        Icons.work_outline_rounded,
        preferredOccupation,
      ),
  ],
),
const Spacer(),

/// PASS + LIKE BUTTONS
Row(
  children: [

    /// PASS
    Expanded(
      child: SizedBox(
        height: 44,
        child: OutlinedButton.icon(
          onPressed: onPass,

          style: OutlinedButton.styleFrom(
            backgroundColor:
                const Color(0xFFFAF5FF),

            foregroundColor:
                const Color(0xFF7C3AED),

            side: const BorderSide(
              color: Color(0xFFDDD6FE),
            ),

            elevation: 0,

            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(14),
            ),
          ),

          icon: const Icon(
            Icons.close_rounded,
            size: 19,
          ),

          label: const Text(
            'Pass',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    ),

    const SizedBox(width: 10),

    /// LIKE
    Expanded(
      child: SizedBox(
        height: 44,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: kPrimaryGradient,

            borderRadius:
                BorderRadius.circular(14),

            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7C3AED)
                    .withOpacity(.18),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),

          child: ElevatedButton.icon(
            onPressed: onLike,

            style: ElevatedButton.styleFrom(
              backgroundColor:
                  Colors.transparent,

              shadowColor:
                  Colors.transparent,

              foregroundColor:
                  Colors.white,

              elevation: 0,

              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(14),
              ),
            ),

            icon: const Icon(
              Icons.favorite_rounded,
              size: 18,
            ),

            label: const Text(
              'Like',
              style: TextStyle(
                fontSize: 13,
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
),
  ],
),
      ),
    );
      } catch (e, stack) {

    debugPrint('========================');
    debugPrint('PROFILE CARD ERROR');
    debugPrint(e.toString());
    debugPrint(stack.toString());
    debugPrint('========================');

    return Scaffold(
      body: Center(
        child: Text(
          'Profile Card Error\n$e',
        ),
      ),
    );
  }
}
  }
Widget _buildChip(
  IconData icon,
  String text,
) {
  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 10,
      vertical: 6,
    ),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.08),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: Colors.white.withOpacity(0.12),
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: Colors.white.withOpacity(0.9),
        ),
        const SizedBox(width: 5),
        Text(
          text,
          style: TextStyle(
            color: Colors.white.withOpacity(0.95),
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),
      ],
    ),
  );
}
Widget _buildPremiumInfoChip(
  IconData icon,
  String text,
) {
  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 10,
      vertical: 7,
    ),
    decoration: BoxDecoration(
      color: const Color(0xFFF8F7FF),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: const Color(0xFFEDE9FE),
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: const Color(0xFF7C3AED),
        ),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(
            color: Color(0xFF5B21B6),
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}
Widget _buildPremiumPreferenceChip(
  IconData icon,
  String text,
) {
  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 10,
      vertical: 7,
    ),
    decoration: BoxDecoration(
      color: const Color(0xFFFDF2F8),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: const Color(0xFFFBCFE8),
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: const Color(0xFFEC4899),
        ),

        const SizedBox(width: 5),

        Text(
          text,
          style: const TextStyle(
            color: Color(0xFFBE185D),
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}
Widget _tagChip(String text) {
  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 10,
      vertical: 6,
    ),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.08),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: Colors.white.withOpacity(0.12),
      ),
    ),
    child: Text(
      text,
      style: TextStyle(
        color: Colors.white.withOpacity(0.95),
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}


