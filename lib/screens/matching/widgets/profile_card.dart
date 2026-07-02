
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
  name = profile.userProfile.name ?? '';
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
  name = profile.userProfile.name ?? '';
  city = profile.userProfile.city ?? '';
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
    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      margin: const EdgeInsets.all(12),
      child: Card(
        elevation: 15,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
           
            // IMAGE
            Positioned.fill(
  child: Stack(
    children: [

      // IMAGE
      Positioned.fill(
        child: imageUrl != null
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
              )
            : Container(
                color: Colors.grey.shade300,
                child: const Center(
                  child: Icon(
                    Icons.person,
                    size: 140,
                    color: Colors.white,
                  ),
                ),
              ),
      ),

      // LEFT TAP ZONE
      Positioned(
        left: 0,
        top: 0,
        bottom: 0,
        width: 80,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {

              debugPrint(
                'LEFT IMAGE CLICK',
              );

              if (_currentImageIndex > 0) {

                setState(() {

                  _currentImageIndex--;
                });
              }
            },
          ),
        ),
      ),

      // RIGHT TAP ZONE
      Positioned(
        right: 0,
        top: 0,
        bottom: 0,
        width: 80,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {

              debugPrint(
                'RIGHT IMAGE CLICK',
              );

              if (_currentImageIndex <
                  imageUrls.length - 1) {

                setState(() {

                  _currentImageIndex++;
                });
              }
            },
          ),
        ),
      ),
    ],
  ),
),
Positioned(
  top: 16,
  left: 16,
  right: 16,
  child: SafeArea(
    child: Row(
      children: List.generate(
        imageUrls.isEmpty
            ? 1
            : imageUrls.length,
        (index) => Expanded(
          child: Container(
            margin:
                const EdgeInsets.symmetric(
              horizontal: 3,
            ),
            height: 5,
            decoration: BoxDecoration(
              gradient:
                  index ==
                          _currentImageIndex
                      ? kPrimaryGradient
                      : null,
              color:
                  index ==
                          _currentImageIndex
                      ? null
                      : Colors.white
                          .withOpacity(
                            0.45,
                          ),
              borderRadius:
                  BorderRadius.circular(
                999,
              ),
              border: Border.all(
                color: Colors.white
                    .withOpacity(0.25),
                width: 0.5,
              ),
            ),
          ),
        ),
      ),
    ),
  ),
),
            // DARK OVERLAY
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black26,
                      Colors.black54,
                      Colors.black87,
                    ],
                  ),
                ),
              ),
            ),
            

Positioned(
  top: 30,
  left: 20,
  child: Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 10,
    ),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.35),
      borderRadius: BorderRadius.circular(30),
      border: Border.all(
        color: Colors.white.withOpacity(0.25),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.25),
          blurRadius: 15,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    const Text(
      '🔥',
      style: TextStyle(fontSize: 16),
    ),
    const SizedBox(width: 6),
    Text(
      '${widget.matchPercentage}% Match',
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w700,
        fontSize: 14,
      ),
    ),
  ],
),
  ),
),

           Positioned(
  top: 30,
  right: 20,
  child: Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 10,
    ),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.35),
      borderRadius: BorderRadius.circular(30),
      border: Border.all(
        color: Colors.white.withOpacity(0.25),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.25),
          blurRadius: 15,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          '💰',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(width: 6),
        Text(
          budgetText,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ],
    ),
  ),
),
            // CONTENT
            Positioned(
  left: 0,
  right: 0,
  bottom: 0,
  child: Container(
    padding: const EdgeInsets.fromLTRB(
      24,
      24,
      24,
      24,
    ),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          Colors.black.withOpacity(.15),
          Colors.black.withOpacity(.55),
          Colors.black.withOpacity(.92),
        ],
      ),
    ),
    child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
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
          color: Colors.white,
          fontSize: 26,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),

    Container(
  padding: const EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 8,
  ),
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: badgeGradient,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(999),
    border: Border.all(
      color: Colors.white.withOpacity(.28),
      width: 1.2,
    ),
    boxShadow: [
      BoxShadow(
        color: badgeColor.withOpacity(.45),
        blurRadius: 18,
        spreadRadius: 1,
        offset: const Offset(0, 8),
      ),
      BoxShadow(
        color: Colors.white.withOpacity(.08),
        blurRadius: 2,
        offset: const Offset(0, -1),
      ),
    ],
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [

      Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.18),
          shape: BoxShape.circle,
        ),
        child: Icon(
          badgeIcon,
          color: Colors.white,
          size: 14,
        ),
      ),

      const SizedBox(width: 8),

      Text(
        badgeText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
          letterSpacing: .35,
          height: 1,
        ),
      ),

      if (isVerified) ...[
        const SizedBox(width: 6),

        Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Color(0xFFFFF176),
                Color(0xFFFFC107),
              ],
            ),
          ),
          child: const Icon(
            Icons.workspace_premium_rounded,
            color: Colors.white,
            size: 12,
          ),
        ),
      ],

      if (verificationStatus == "pending") ...[
        const SizedBox(width: 6),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.18),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            "LIVE",
            style: TextStyle(
              color: Colors.white,
              fontSize: 8,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    ],
  ),
),
  ],
),
                  const SizedBox(height: 8),

                Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [

    // CITY
    Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withOpacity(.18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [

          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6)
                  .withOpacity(.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: Color(0xFF60A5FA),
              size: 14,
            ),
          ),

          const SizedBox(width: 8),

          Flexible(
            child: Text(
              city,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    ),

    if (distanceText != null) ...[

      const SizedBox(height: 10),

      Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF10B981),
              Color(0xFF34D399),
            ],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10B981)
                  .withOpacity(.35),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [

            const Icon(
              Icons.near_me_rounded,
              color: Colors.white,
              size: 15,
            ),

            const SizedBox(width: 6),

            Text(
              distanceText!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: .2,
              ),
            ),
          ],
        ),
      ),
    ],
  ],
),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(
                        Icons.work,
                        color: Colors.white70,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          occupation,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
    
                    ],
                  ),

          

                  
   
const SizedBox(height: 10),
Text(
  profile is SeekingFlatmateProfile
      ? 'Looking For'
      : 'Property',
  style: const TextStyle(
    color: Colors.white,
    fontSize: 15,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 8),
Wrap(
  spacing: 8,
  runSpacing: 8,
  children: [

    if (profile is FlatListingProfile) ...[

      if (propertyText.isNotEmpty)
        _buildChip(
          Icons.home,
          propertyText,
        ),

      if (bathroomType.isNotEmpty)
        _buildChip(
          Icons.bathtub,
          bathroomType,
        ),

      if (religion.isNotEmpty)
        _buildChip(
          Icons.temple_hindu,
          religion,
        ),
    ],

    if (profile is SeekingFlatmateProfile) ...[

      if (preferredFlatType.isNotEmpty)
        _buildChip(
          Icons.home_work,
          preferredFlatType,
        ),

      if (preferredRoomType.isNotEmpty)
        _buildChip(
          Icons.bed,
          preferredRoomType,
        ),

      if (preferredFurnishedStatus.isNotEmpty)
        _buildChip(
          Icons.chair,
          preferredFurnishedStatus,
        ),

      if (moveInDateText.isNotEmpty)
        _buildChip(
          Icons.calendar_month,
          moveInDateText,
        ),

      if (religion.isNotEmpty)
        _buildChip(
          Icons.temple_hindu,
          religion,
        ),
    ],
  ],
),
const SizedBox(height: 12),

// const Text(
//   'Lifestyle',
//   style: TextStyle(
//     color: Colors.white,
//     fontSize: 15,
//     fontWeight: FontWeight.bold,
//   ),
// ),

// const SizedBox(height: 8),

// Wrap(
//   spacing: 8,
//   runSpacing: 8,
//   children: [

//     if (cleanliness.isNotEmpty)
//       _tagChip('✨ $cleanliness'),

//     if (smoking.isNotEmpty)
//       _tagChip('🚭 $smoking'),

//     if (drinking.isNotEmpty)
//       _tagChip('🍺 $drinking'),

//     if (food.isNotEmpty)
//       _tagChip('🥗 $food'),

//     if (petTolerance.isNotEmpty)
//       _tagChip('🐶 $petTolerance'),

//     if (socialPreference.isNotEmpty)
//       _tagChip('🎉 $socialPreference'),
//   ],
// ),

// if (profile is SeekingFlatmateProfile) ...[

// const SizedBox(height: 12),

// const Text(
//   'Preferred Amenities',
//   style: TextStyle(
//     color: Colors.white,
//     fontSize: 15,
//     fontWeight: FontWeight.bold,
//   ),
// ),

// const SizedBox(height: 8),

// Wrap(
//   spacing: 8,
//   runSpacing: 8,
//   children: desiredAmenities.map((e) {
//     return _tagChip('🏠 $e');
//   }).toList(),
// ),
// ],
const SizedBox(height: 12),
const Text(
  'Looking For',
  style: TextStyle(
    color: Colors.white,
    fontSize: 15,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 8),
Wrap(
  spacing: 8,
  runSpacing: 8,
  children: [

    if (availableFor.isNotEmpty)
      _buildChip(
        Icons.group,
        availableFor,
      ),

    if (preferredGender.isNotEmpty)
      _buildChip(
        Icons.person_outline,
        preferredGender,
      ),

    if (preferredAge.isNotEmpty)
      _buildChip(
        Icons.cake,
        preferredAge,
      ),

    if (preferredOccupation.isNotEmpty)
      _buildChip(
        Icons.work,
        preferredOccupation,
      ),
  ],
),






//                   const SizedBox(height: 20),
//                   const SizedBox(height: 16),

// GestureDetector(
//   onTap: () {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (_) => ProfileDetailsSheet(
//   profile: profile,

//   name: name,
//   age: age,
//   city: city,
//   occupation: occupation,
//   imageUrl: imageUrl,

//   bio: bio,
//   cleanliness: cleanliness,
//   smoking: smoking,
//   drinking: drinking,
//   food: food,
//   petTolerance: petTolerance,
//   socialPreference: socialPreference,
//   desiredAmenities: desiredAmenities,
// ),
//     );
//   },
//   child: Container(
//     width: double.infinity,
//     padding: const EdgeInsets.symmetric(
//       vertical: 12,
//     ),
//     decoration: BoxDecoration(
//       color: Colors.white.withOpacity(.08),
//       borderRadius: BorderRadius.circular(18),
//       border: Border.all(
//         color: Colors.white.withOpacity(.12),
//       ),
//     ),
//     child: const Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Text(
//           'View More',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 14,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         SizedBox(width: 6),
//         Icon(
//           Icons.keyboard_arrow_up_rounded,
//           color: Colors.white,
//           size: 18,
//         ),
//       ],
//     ),
//   ),
// ),

const SizedBox(height: 16),

   Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [

    // PASS
    GestureDetector(
  onTap: onPass,
  child: Container(
    width: 72,
    height: 72,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: const LinearGradient(
  colors: [
    Color(0xFFFFB6C1),
    Color(0xFFFF7AA2),
  ],
),
      boxShadow: [
        BoxShadow(
          color: Color(0xFFFF6B81).withOpacity(.35),
          blurRadius: 24,
          spreadRadius: 1,
        ),
      ],
    ),
    child: const Icon(
      Icons.close_rounded,
      color: Colors.white,
      size: 32,
    ),
  ),
),

    const SizedBox(width: 28),

    // LIKE
    GestureDetector(
      onTap: onLike,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [
              Color(0xFFEC4899),
              Color(0xFF7C3AED),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(
                0xFFEC4899,
              ).withOpacity(.45),
              blurRadius: 30,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(
          Icons.favorite_rounded,
          color: Colors.white,
          size: 32,
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


