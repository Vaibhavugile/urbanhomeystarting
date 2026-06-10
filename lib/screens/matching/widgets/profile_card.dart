
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
    String age = '';
    String occupation = '';
    String? imageUrl;

    String budgetText = '';
    String propertyText = '';

    List<String> tags = [];

    if (profile is FlatListingProfile) {
      name = profile.userProfile.name ?? '';
      city = profile.userProfile.city ?? '';
      age = profile.userProfile.age?.toString() ?? '';
      occupation = profile.userProfile.occupation ?? '';

      budgetText = '₹${profile.rentPrice ?? 0}/month';

      propertyText =
          '${profile.flatType ?? ''} • ${profile.furnishedStatus ?? ''}';

      if (profile.amenities != null) {
        tags = List<String>.from(profile.amenities);
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
      occupation = profile.userProfile.occupation ?? '';

      budgetText =
          '₹${profile.budgetMin ?? 0} - ₹${profile.budgetMax ?? 0}';

      try {
        propertyText =
            '${profile.flatRequirements.preferredFlatType ?? ''} • '
            '${profile.flatRequirements.preferredFurnishedStatus ?? ''}';

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
      height: MediaQuery.of(context).size.height * 0.75,
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

                  const SizedBox(height: 15),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.15),
                      borderRadius:
                          BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.currency_rupee,
                          color: Colors.white,
                        ),
                        Text(
                          budgetText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight:
                                FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    propertyText,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: tags.take(5).map((tag) {
                      return Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white24,
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
                    mainAxisAlignment:
                        MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: onPass,
                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.red,
                          shape:
                              const CircleBorder(),
                          padding:
                              const EdgeInsets.all(
                                  20),
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: onLike,
                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.green,
                          shape:
                              const CircleBorder(),
                          padding:
                              const EdgeInsets.all(
                                  20),
                        ),
                        child: const Icon(
                          Icons.favorite,
                          color: Colors.white,
                          size: 30,
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
}

