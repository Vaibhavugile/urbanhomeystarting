import 'package:flutter/material.dart';

class PopularCitiesSection extends StatelessWidget {
  const PopularCitiesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cities = [
      {
        "name": "Mumbai",
        "subtitle": "Financial Capital",
        "homes": "2.4K",
        "flatmates": "850",
        "badge": "🔥 Trending",
        "image": "assets/cities/mumbai.jpg",
      },
      {
        "name": "Bangalore",
        "subtitle": "Tech Hub",
        "homes": "1.8K",
        "flatmates": "720",
        "badge": "⭐ Most Active",
        "image": "assets/cities/bangalore.jpg",
      },
      {
        "name": "Pune",
        "subtitle": "Student Favorite",
        "homes": "1.2K",
        "flatmates": "410",
        "badge": "🚀 Growing",
        "image": "assets/cities/pune.jpg",
      },
      {
        "name": "Hyderabad",
        "subtitle": "Fast Growing",
        "homes": "980",
        "flatmates": "360",
        "badge": "📈 Hot Market",
        "image": "assets/cities/hyderabad.jpg",
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              "Explore Cities",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Color(0xFF111827),
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {},
              child: const Text(
                "View All",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        Text(
          "Discover homes and flatmates near you",
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),

        const SizedBox(height: 20),

        SizedBox(
          height: 340,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: cities.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: 18),
            itemBuilder: (context, index) {
              final city = cities[index];

              return _CityCard(
                cityName: city["name"]!,
                subtitle: city["subtitle"]!,
                homes: city["homes"]!,
                flatmates: city["flatmates"]!,
                badge: city["badge"]!,
                image: city["image"]!,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CityCard extends StatelessWidget {
  final String cityName;
  final String subtitle;
  final String homes;
  final String flatmates;
  final String badge;
  final String image;

  const _CityCard({
    required this.cityName,
    required this.subtitle,
    required this.homes,
    required this.flatmates,
    required this.badge,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Future City Listings Screen
      },
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.08),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              flex: 6,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    child: Image.asset(
                      image,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF7C3AED),
                                Color(0xFFEC4899),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        badge,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    left: 18,
                    bottom: 18,
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          cityName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.home_rounded,
                          size: 18,
                          color: Color(0xFF7C3AED),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "$homes Homes",
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        const Icon(
                          Icons.groups_rounded,
                          size: 18,
                          color: Color(0xFFEC4899),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "$flatmates Flatmates",
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF7C3AED),
                            Color(0xFFEC4899),
                          ],
                        ),
                        borderRadius:
                            BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text(
                          "Explore City →",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}