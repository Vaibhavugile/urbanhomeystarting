import 'package:flutter/material.dart';

class QuickActionsSection extends StatelessWidget {
final VoidCallback onNeedRoom;
final VoidCallback onNeedFlatmate;
final VoidCallback onListProperty;
final VoidCallback onExplore;

const QuickActionsSection({
super.key,
required this.onNeedRoom,
required this.onNeedFlatmate,
required this.onListProperty,
required this.onExplore,
});

@override
Widget build(BuildContext context) {
return Column(
children: [
Row(
children: [
Expanded(
child: _actionCard(
title: "Need Room",
subtitle: "Find your next stay",
icon: Icons.bed_rounded,
gradient: const [
Color(0xFF6366F1),
Color(0xFF8B5CF6),
],
badge: "POPULAR",
onTap: onNeedRoom,
),
),
const SizedBox(width: 14),
Expanded(
child: _actionCard(
title: "Need Flatmate",
subtitle: "Find roommates",
icon: Icons.groups_rounded,
gradient: const [
Color(0xFFEC4899),
Color(0xFF8B5CF6),
],
badge: "TRENDING",
onTap: onNeedFlatmate,
),
),
],
),


    const SizedBox(height: 14),

    Row(
      children: [
        Expanded(
          child: _actionCard(
            title: "List Property",
            subtitle: "Post your flat",
            icon: Icons.home_work_rounded,
            gradient: const [
              Color(0xFFF59E0B),
              Color(0xFFFB7185),
            ],
            badge: "FREE",
            onTap: onListProperty,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _actionCard(
            title: "Explore",
            subtitle: "Browse homes",
            icon: Icons.explore_rounded,
            gradient: const [
              Color(0xFF06B6D4),
              Color(0xFF14B8A6),
            ],
            badge: "NEW",
            onTap: onExplore,
          ),
        ),
      ],
    ),
  ],
);


}

Widget _actionCard({
required String title,
required String subtitle,
required IconData icon,
required List<Color> gradient,
required String badge,
required VoidCallback onTap,
}) {
return GestureDetector(
onTap: onTap,
child: AspectRatio(
aspectRatio: 0.95,
child: Container(
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(
borderRadius: BorderRadius.circular(28),
gradient: LinearGradient(
begin: Alignment.topLeft,
end: Alignment.bottomRight,
colors: gradient,
),
boxShadow: [
BoxShadow(
color: gradient.first.withOpacity(.30),
blurRadius: 20,
offset: const Offset(0, 10),
),
],
),
child: Stack(
children: [
Positioned(
right: -10,
bottom: -10,
child: Icon(
icon,
size: 90,
color: Colors.white.withOpacity(.12),
),
),


          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.18),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),

              const Spacer(),

              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),

              const SizedBox(height: 10),

              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              const SizedBox(height: 4),

              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withOpacity(.85),
                  fontSize: 12,
                  height: 1.3,
                ),
              ),

              const SizedBox(height: 8),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    "Open",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ),
  ),
);


}
}
