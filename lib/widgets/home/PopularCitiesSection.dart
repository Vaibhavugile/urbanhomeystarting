import 'package:flutter/material.dart';

class PopularCitiesSection extends StatelessWidget {
  const PopularCitiesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cities = [
      "assets/cities/mumbai.png",
      "assets/cities/banglore.png",
      "assets/cities/pune.png",
      "assets/cities/hyderabad.png",
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
                  color: Color(0xFF7C3AED),
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
          height: 560,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(
              left: 4,
              right: 20,
            ),
            itemCount: cities.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: 18),
            itemBuilder: (context, index) {
              return _CityCard(
                image: cities[index],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CityCard extends StatelessWidget {
  final String image;

  const _CityCard({
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    final cardWidth =
        MediaQuery.of(context).size.width * 0.82;

    return GestureDetector(
      onTap: () {
        // TODO: Open city listings
      },
      child: Container(
        width: cardWidth,
        margin: const EdgeInsets.only(
          bottom: 12,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.08),
              blurRadius: 24,
              spreadRadius: 2,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Image.asset(
            image,
            fit: BoxFit.fitHeight,
            alignment: Alignment.topCenter,
            errorBuilder: (_, __, ___) {
              return Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF7C3AED),
                      Color(0xFFEC4899),
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.location_city,
                    color: Colors.white,
                    size: 60,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}