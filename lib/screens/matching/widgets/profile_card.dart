
import 'package:flutter/material.dart';
import 'package:mytennat/screens/flatmate_profile_screen.dart';
import 'package:mytennat/screens/flat_with_flatmate_profile_screen.dart';
import 'profile_details_sheet.dart';
class ProfileCard extends StatelessWidget {
  final dynamic profile;
  final VoidCallback onLike;
  final VoidCallback onPass;

  const ProfileCard({
    super.key,
    required this.profile,
    required this.onLike,
    required this.onPass,
  });

  @override
  Widget build(BuildContext context) {
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
    imageUrl = profile.imageUrls!.first;
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
        profile.flatmatePreferences
                .preferredFlatmateGender ??
            '';

    preferredAge =
        profile.flatmatePreferences
                .preferredFlatmateAge ??
            '';

    tags = List<String>.from(
      profile.flatmatePreferences
              .preferredHabits ??
          [],
    );

    if (profile.moveInDate != null) {
      moveInDateText =
          '${profile.moveInDate.day}/${profile.moveInDate.month}/${profile.moveInDate.year}';
    }
  } catch (_) {}

  if (profile.imageUrls != null &&
      profile.imageUrls!.isNotEmpty) {
    imageUrl = profile.imageUrls!.first;
  }
  print("===== SEEKING PROFILE =====");
print(profile.preferredFlatType);
print(profile.preferredRoomType);
print(profile.preferredFurnishedStatus);
print(profile.preferredFlatmateGender);
print(profile.preferredFlatmateAge);
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
  top: 20,
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
    child: const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '🔥',
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(width: 6),
        Text(
          '92% Match',
          style: TextStyle(
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
  top: 20,
  right: 20,
  child: Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 14,
      vertical: 8,
    ),
    decoration: BoxDecoration(
      color: Colors.black87,
      borderRadius: BorderRadius.circular(30),
    ),
    child: Text(
      budgetText,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
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
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.blue.withOpacity(.4),
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified,
            color: Colors.blue,
            size: 14,
          ),
          SizedBox(width: 4),
          Text(
            'Verified',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  ],
),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.white70,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        city,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
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






                  const SizedBox(height: 20),
                  const SizedBox(height: 16),

GestureDetector(
  onTap: () {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProfileDetailsSheet(
  profile: profile,

  name: name,
  age: age,
  city: city,
  occupation: occupation,
  imageUrl: imageUrl,

  bio: bio,
  cleanliness: cleanliness,
  smoking: smoking,
  drinking: drinking,
  food: food,
  petTolerance: petTolerance,
  socialPreference: socialPreference,
  desiredAmenities: desiredAmenities,
),
    );
  },
  child: Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(
      vertical: 12,
    ),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(.08),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: Colors.white.withOpacity(.12),
      ),
    ),
    child: const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'View More',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(width: 6),
        Icon(
          Icons.keyboard_arrow_up_rounded,
          color: Colors.white,
          size: 18,
        ),
      ],
    ),
  ),
),

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


