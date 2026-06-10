
import 'package:flutter/material.dart';
import 'package:mytennat/screens/flatmate_profile_screen.dart';
import 'package:mytennat/screens/flat_with_flatmate_profile_screen.dart';

class ProfileListItem extends StatelessWidget {
  final dynamic profile;
  final VoidCallback onTap;

  const ProfileListItem({
    super.key,
    required this.profile,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    String name = '';
    String city = '';
    String occupation = '';
    String age = '';
    String budgetText = '';
    String? imageUrl;

    List<String> tags = [];

    if (profile is FlatListingProfile) {
      name = profile.userProfile.name ?? 'Flat Owner';
      city = profile.userProfile.city ?? '';
      occupation = profile.userProfile.occupation ?? '';
      age = profile.userProfile.age?.toString() ?? '';

      budgetText = '₹${profile.rentPrice ?? 0}/month';

      if (profile.amenities != null) {
        tags = List<String>.from(profile.amenities);
      }

      if (profile.imageUrls != null &&
          profile.imageUrls!.isNotEmpty) {
        imageUrl = profile.imageUrls!.first;
      }
    }

    if (profile is SeekingFlatmateProfile) {
      name = profile.userProfile.name ?? 'Flatmate';
      city = profile.userProfile.city ?? '';
      occupation = profile.userProfile.occupation ?? '';
      age = profile.userProfile.age?.toString() ?? '';

      budgetText =
          '₹${profile.budgetMin ?? 0} - ₹${profile.budgetMax ?? 0}';

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

    
return Container(
  margin: const EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 6,
  ),
  child: Material(
    borderRadius: BorderRadius.circular(18),
    elevation: 4,
    child: InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF6A1B9A),
              Color(0xFFAD1457),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Hero(
              tag: 'profile_${name}_$city',
              child: CircleAvatar(
                radius: 35,
                backgroundColor: Colors.white,
                backgroundImage: imageUrl != null
                    ? NetworkImage(imageUrl)
                    : null,
                child: imageUrl == null
                    ? const Icon(
                        Icons.person,
                        size: 35,
                        color: Color(0xFFAD1457),
                      )
                    : null,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
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
                          overflow:
                              TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.white70,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          city,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  Text(
                    occupation,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius:
                              BorderRadius.circular(
                                  20),
                        ),
                        child: Text(
                          budgetText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(width: 6),

                      if (tags.isNotEmpty)
                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white12,
                            borderRadius:
                                BorderRadius.circular(
                                    20),
                          ),
                          child: Text(
                            tags.first,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Color(0xFFAD1457),
              ),
            ),
          ],
        ),
      ),
    ),
  ),
);


  }
}

