import 'package:flutter/material.dart';

class SuccessStoriesSection extends StatelessWidget {
  const SuccessStoriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final stories = [
      {
        "name": "Priya & Aisha",
        "city": "Mumbai",
        "story":
            "Found their perfect flatmate in just 3 days through UrbanHomey.",
        "emoji": "👩‍💼👩",
      },
      {
        "name": "Rahul",
        "city": "Bangalore",
        "story":
            "Moved into a fully furnished apartment without broker fees.",
        "emoji": "👨‍💻",
      },
      {
        "name": "Sneha",
        "city": "Pune",
        "story":
            "Matched with compatible roommates and saved time & money.",
        "emoji": "👩",
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Success Stories",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Color(0xFF111827),
          ),
        ),

        const SizedBox(height: 6),

        Text(
          "Real people finding homes and flatmates",
          style: TextStyle(
            color: Colors.grey.shade600,
          ),
        ),

        const SizedBox(height: 20),

        SizedBox(
          height: 240,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: stories.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final story = stories[index];

              return _StoryCard(
                name: story["name"]!,
                city: story["city"]!,
                story: story["story"]!,
                emoji: story["emoji"]!,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _StoryCard extends StatelessWidget {
  final String name;
  final String city;
  final String story;
  final String emoji;

  const _StoryCard({
    required this.name,
    required this.city,
    required this.story,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF7C3AED),
            Color(0xFFEC4899),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withOpacity(.25),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 40),
          ),

          const SizedBox(height: 16),

          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            city,
            style: TextStyle(
              color: Colors.white.withOpacity(.8),
            ),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: Text(
              "\"$story\"",
              style: TextStyle(
                color: Colors.white.withOpacity(.95),
                height: 1.5,
                fontSize: 15,
              ),
            ),
          ),

          const SizedBox(height: 12),

          const Row(
            children: [
              Icon(Icons.star,
                  color: Colors.amber, size: 18),
              Icon(Icons.star,
                  color: Colors.amber, size: 18),
              Icon(Icons.star,
                  color: Colors.amber, size: 18),
              Icon(Icons.star,
                  color: Colors.amber, size: 18),
              Icon(Icons.star,
                  color: Colors.amber, size: 18),
            ],
          ),
        ],
      ),
    );
  }
}