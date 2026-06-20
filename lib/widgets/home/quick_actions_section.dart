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
title: "Looking for a Flat",
subtitle: "Find a flat & flatmates",
icon: Icons.apartment_rounded,
gradient: const [
Color(0xFFEDE9FE),
Color(0xFFF5F3FF),
],
badge: "POPULAR",
onTap: onNeedRoom,
),
),
const SizedBox(width: 14),
Expanded(
child: _actionCard(
title: "Looking for a Flatmate",
subtitle: "Already have a flat",
icon: Icons.groups_rounded,
gradient: const [
Color(0xFFFCE7F3),
Color(0xFFFDF2F8),
],
badge: "TRENDING",
onTap: onNeedFlatmate,
),
),
],
),


  // const SizedBox(height: 14),

  // Row(
  //   children: [
  //     Expanded(
  //       child: _actionCard(
  //         title: "List Property",
  //         subtitle: "Post your flat",
  //         icon: Icons.home_work_rounded,
  //         gradient: const [
  //           Color(0xFFFEF3C7),
  //           Color(0xFFFFFBEB),
  //         ],
  //         badge: "FREE",
  //         onTap: onListProperty,
  //       ),
  //     ),
  //     const SizedBox(width: 14),
  //     Expanded(
  //       child: _actionCard(
  //         title: "Explore",
  //         subtitle: "Browse homes",
  //         icon: Icons.explore_rounded,
  //         gradient: const [
  //           Color(0xFFCFFAFE),
  //           Color(0xFFF0FDFA),
  //         ],
  //         badge: "NEW",
  //         onTap: onExplore,
  //       ),
  //     ),
  //   ],
  // ),
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
border: Border.all(
color: Colors.white,
width: 1.5,
),
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(.05),
blurRadius: 15,
offset: const Offset(0, 8),
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
color: Colors.black.withOpacity(.04),
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
                color: Colors.white.withOpacity(.75),
                borderRadius:
                    BorderRadius.circular(50),
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  color: Color(0xFF374151),
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ),

            const Spacer(),

            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color:
                        Colors.black.withOpacity(.04),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: const Color(0xFF7C3AED),
                size: 24,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF111827),
                fontSize: 17,
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 12,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 10),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  "Open",
                  style: TextStyle(
                    color: Color(0xFF7C3AED),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: Color(0xFF7C3AED),
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
