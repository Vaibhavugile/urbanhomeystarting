
import 'package:flutter/material.dart';
import 'package:mytennat/screens/flatmate_profile_screen.dart';
import 'package:mytennat/screens/flat_with_flatmate_profile_screen.dart';

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

String moveInDateText = '';
String preferredGender = '';
String preferredAge = '';

String bio = '';

List<String> tags = [];

if (profile is FlatListingProfile) {
  name = profile.userProfile.name ?? '';
  city = profile.userProfile.city ?? '';
  age = profile.userProfile.age?.toString() ?? '';
  occupation = profile.userProfile.occupation ?? '';
  bio = profile.userProfile.bio ?? '';

  budgetText = '₹${profile.rentPrice ?? 0}/month';

  propertyText =
      '${profile.flatType ?? ''} • ${profile.furnishedStatus ?? ''}';
      print("Flat Type: ${profile.flatType}");
print("Furnished: ${profile.furnishedStatus}");
print("PropertyText: $propertyText");
print("rentPrice: ${profile.rentPrice}");


  address = profile.address ?? '';

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

  try {
    propertyText =
        '${profile.flatRequirements.preferredFlatType ?? ''} • '
        '${profile.flatRequirements.preferredFurnishedStatus ?? ''}';

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
              left: 20,
              right: 20,
              bottom: 20,
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    age.isNotEmpty
                        ? '$name, $age'
                        : name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),

Container(
  padding: const EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 4,
  ),
  decoration: BoxDecoration(
    color: Colors.blue.withOpacity(.2),
    borderRadius: BorderRadius.circular(20),
  ),
  child: const Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(
        Icons.verified,
        color: Colors.blue,
        size: 16,
      ),
      SizedBox(width: 4),
      Text(
        'Verified Profile',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    ],
  ),
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

          

                  
                  if (bio.isNotEmpty) ...[
  const SizedBox(height: 10),
  Text(
    bio,
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
    style: const TextStyle(
      color: Colors.white70,
      fontSize: 14,
      height: 1.4,
    ),
  ),
],
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
),
const SizedBox(height: 12),

const Text(
  'Lifestyle',
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

    if (cleanliness.isNotEmpty)
      _tagChip('✨ $cleanliness'),

    if (smoking.isNotEmpty)
      _tagChip('🚭 $smoking'),

    if (drinking.isNotEmpty)
      _tagChip('🍺 $drinking'),

    if (food.isNotEmpty)
      _tagChip('🥗 $food'),

    if (petTolerance.isNotEmpty)
      _tagChip('🐶 $petTolerance'),

    if (socialPreference.isNotEmpty)
      _tagChip('🎉 $socialPreference'),
  ],
),

                  const SizedBox(height: 12),

Text(
  profile is SeekingFlatmateProfile
      ? 'Preferred Habits'
      : 'Amenities',
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
                    children: tags.take(4).map((tag) {
                      return Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                         color: Colors.black38,
border: Border.all(
  color: Colors.white24,
),
                          borderRadius:
                              BorderRadius.circular(
                                  30),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

               Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
    Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.35),
            blurRadius: 25,
            spreadRadius: 2,
          ),
        ],
      ),
      child: GestureDetector(
        onTap: onPass,
        child: Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.close_rounded,
            color: Colors.red,
            size: 34,
          ),
        ),
      ),
    ),

    Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.35),
            blurRadius: 25,
            spreadRadius: 2,
          ),
        ],
      ),
      child: GestureDetector(
        onTap: onLike,
        child: Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.favorite_rounded,
            color: Colors.pink,
            size: 34,
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
    );
  }
  Widget _buildChip(
  IconData icon,
  String text,
) {
  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 8,
    ),
    decoration: BoxDecoration(
      color: Colors.black38,
border: Border.all(
  color: Colors.white24,
),
      borderRadius: BorderRadius.circular(25),
      
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.white,
        ),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}
Widget _tagChip(String text) {
  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 8,
    ),
    decoration: BoxDecoration(
      color: Colors.black38,
      borderRadius: BorderRadius.circular(25),
      border: Border.all(
        color: Colors.white24,
      ),
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 13,
      ),
    ),
  );
}
}

