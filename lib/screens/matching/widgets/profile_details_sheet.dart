import 'package:flutter/material.dart';
import 'dart:ui';
class ProfileDetailsSheet extends StatelessWidget {
  final dynamic profile;

  final String bio;

  final String cleanliness;
  final String smoking;
  final String drinking;
  final String food;

  final String petTolerance;
  final String socialPreference;
final String name;
final String age;
final String city;
final String occupation;
final String? imageUrl;
  final List<String> desiredAmenities;

  const ProfileDetailsSheet({
  super.key,
  required this.profile,

  required this.name,
  required this.age,
  required this.city,
  required this.occupation,
  required this.imageUrl,

  required this.bio,
  required this.cleanliness,
  required this.smoking,
  required this.drinking,
  required this.food,
  required this.petTolerance,
  required this.socialPreference,
  required this.desiredAmenities,
});
@override
Widget build(BuildContext context) {
  return DraggableScrollableSheet(
    initialChildSize: 0.85,
    minChildSize: 0.60,
    maxChildSize: 0.95,
    builder: (context, scrollController) {
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(36),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 8,
            sigmaY: 8,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.35),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(36),
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.12),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 40,
                  offset: const Offset(0, -10),
                ),
              ],
            ),
            child: ListView(
              controller: scrollController,
              padding: EdgeInsets.zero,
              children: [

                const SizedBox(height: 12),

                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white38,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // HERO IMAGE
                Container(
                  height: 400,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    color: Colors.grey.shade300,
                    image: imageUrl != null
                        ? DecorationImage(
                            image: NetworkImage(imageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(.08),
                          Colors.black.withOpacity(.45),
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [

                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  age.isEmpty
                                      ? name
                                      : '$name, $age',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 34,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.8,
                                  ),
                                ),
                              ),

                              ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(20),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 5,
                                    sigmaY: 5,
                                  ),
                                  child: Container(
                                    padding:
                                        const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white
                                          .withOpacity(.08),
                                      borderRadius:
                                          BorderRadius.circular(
                                              20),
                                      border: Border.all(
                                        color: Colors.white
                                            .withOpacity(.18),
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisSize:
                                          MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.verified,
                                          color:
                                              Colors.lightBlueAccent,
                                          size: 14,
                                        ),
                                        SizedBox(width: 5),
                                        Text(
                                          'Verified',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight:
                                                FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_rounded,
                                color: Colors.white70,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '$city • $occupation',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 15,
                                    fontWeight:
                                        FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                  const SizedBox(height: 40),

                Transform.translate(
                  offset: const Offset(0, -35),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    child: Column(
                      children: [

                        _sectionCard(
                          title: 'About Me',
                          child: Text(
                            bio.isEmpty
                                ? 'No bio added yet.'
                                : bio,
                            style: const TextStyle(
                              color: Colors.white,
                              height: 1.7,
                              fontSize: 15,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        _sectionCard(
                          title: 'Lifestyle',
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              if (cleanliness.isNotEmpty)
                                _chip('✨ $cleanliness'),

                              if (smoking.isNotEmpty)
                                _chip('🚭 $smoking'),

                              if (drinking.isNotEmpty)
                                _chip('🍺 $drinking'),

                              if (food.isNotEmpty)
                                _chip('🥗 $food'),

                              if (petTolerance.isNotEmpty)
                                _chip('🐶 $petTolerance'),

                              if (socialPreference.isNotEmpty)
                                _chip('🎉 $socialPreference'),
                            ],
                          ),
                        ),

                        if (desiredAmenities.isNotEmpty) ...[
                          const SizedBox(height: 16),

                          _sectionCard(
                            title: 'Amenities',
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: desiredAmenities
                                  .map(
                                    (e) => _chip('🏠 $e'),
                                  )
                                  .toList(),
                            ),
                          ),
                        ],

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
Widget _chip(String text) {
  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 14,
      vertical: 10,
    ),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(22),
      color: Colors.white.withOpacity(0.04),
      border: Border.all(
        color: Colors.white.withOpacity(0.10),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.12),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Text(
      text,
      style: TextStyle(
        color: Colors.white.withOpacity(0.95),
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

Widget _sectionCard({
  required String title,
  required Widget child,
}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(30),

      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.08),
          Colors.white.withOpacity(0.03),
        ],
      ),

      border: Border.all(
        color: Colors.white.withOpacity(0.12),
        width: 1,
      ),

      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.18),
          blurRadius: 30,
          offset: const Offset(0, 12),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),

            const SizedBox(width: 12),

            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        child,
      ],
    ),
  );
}
}