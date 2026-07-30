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
  title: "List Your Flat",
  subtitle: "Find verified flatmates",
  icon: Icons.groups_rounded,
  gradient: const [
    Color(0xFFFFEEF6),
    Color(0xFFFFFAFD),
  ],
  badge: "POPULAR",
  onTap: onNeedFlatmate,
),
),
        const SizedBox(height: 14),

Expanded(
child: _actionCard(
  title: "Find a Flat",
  subtitle: "Find verified flats",
  icon: Icons.apartment_rounded,
  gradient: const [
    Color(0xFFF3EEFF),
    Color(0xFFFAF8FF),
  ],
  badge: "NEW",
  onTap: onNeedRoom,
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
  return TweenAnimationBuilder<double>(
    duration: const Duration(milliseconds: 250),
    tween: Tween(begin: 1, end: 1),
    builder: (context, scale, child) {
      return Transform.scale(
        scale: scale,
        child: GestureDetector(
          onTap: onTap,
          child: SizedBox(
  height: 310,
  child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(34),
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
                    color: gradient.first.withOpacity(.22),
                    blurRadius: 35,
                    offset: const Offset(0, 18),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(.03),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Stack(
                children: [

                  //----------------------------------
                  // Decorative Background
                  //----------------------------------

                  Positioned(
                    top: -70,
                    left: -60,
                    child: Container(
                      width: 170,
                      height: 170,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(.18),
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: -80,
                    right: -50,
                    child: Container(
                      width: 190,
                      height: 190,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(.12),
                      ),
                    ),
                  ),

                  Positioned(
                    top: 125,
                    left: -40,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(.10),
                      ),
                    ),
                  ),

                  //----------------------------------
                  // Tiny Sparkles
                  //----------------------------------

                  const Positioned(
                    top: 105,
                    right: 90,
                    child: Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),

                  Positioned(
                    top: 145,
                    right: 55,
                    child: Icon(
                      Icons.circle,
                      size: 5,
                      color: Colors.white.withOpacity(.8),
                    ),
                  ),

                  //----------------------------------
                  // Main Content
                  //----------------------------------

                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        //----------------------------------
                        // Badge
                        //----------------------------------

                        Row(
                          children: [

                           


                            //----------------------------------
                            // Floating Icon
                            //----------------------------------

//                             Hero(
//   tag: "${title}_icon",
//   child: Container(
//     width: 56,
//     height: 56,
//     decoration: BoxDecoration(
//       shape: BoxShape.circle,
//       color: Colors.white,
//       boxShadow: [
//         BoxShadow(
//           color: Colors.black.withOpacity(.08),
//           blurRadius: 20,
//           offset: const Offset(0, 8),
//         ),
//       ],
//     ),
//     padding: const EdgeInsets.all(10),
//     child: Image.asset(
//       title == "List Your Flat"
//           ? "assets/images/cards/list_icon.png"
//           : "assets/images/cards/search_icon.png",
//       fit: BoxFit.contain,
//     ),
//   ),
// ),
                          ],
                        ),

                        const SizedBox(height: 1),

                        //----------------------------------
                        // PART 1B
                        //----------------------------------

                        

                        // We'll add the illustration here in Part 1B
                        //----------------------------------------------------
// Illustration
//----------------------------------------------------

SizedBox(
  height: 130,
  child: Stack(
    alignment: Alignment.center,
    children: [

      // Soft Glow
      Container(
        width: 190,
        height: 190,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(.25),
        ),
      ),

      // Floating Illustration
      TweenAnimationBuilder<double>(
        duration: const Duration(seconds: 3),
        tween: Tween(begin: -6.0, end: 6.0),
        curve: Curves.easeInOut,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, value),
            child: child,
          );
        },
        child: Image.asset(
          title == "List Your Flat"
              ? "assets/images/cards/list_your_flat.png"
              : "assets/images/cards/looking_flat.png",
          width: 135,
height: 135,
fit: BoxFit.contain,
        ),
      ),

      const Positioned(
        top: 10,
        left: 25,
        child: Icon(
          Icons.auto_awesome,
          color: Colors.white,
          size: 18,
        ),
      ),

      Positioned(
        bottom: 22,
        right: 30,
        child: Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.85),
            shape: BoxShape.circle,
          ),
        ),
      ),
    ],
  ),
),

const SizedBox(height: 18),

//----------------------------------------------------
// Title
//----------------------------------------------------

Text(
  title,
  style: const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w900,
    color: Color(0xFF111827),
    letterSpacing: -.6,
    height: 1.1,
  ),
),

const SizedBox(height: 10),

//----------------------------------------------------
// Subtitle
//----------------------------------------------------

Text(
  subtitle,
  style: const TextStyle(
   fontSize: 12,
height: 1.3,
    color: Color(0xFF6B7280),
    fontWeight: FontWeight.w500,
  ),
),

const SizedBox(height: 16),

//----------------------------------------------------
// CTA Button
//----------------------------------------------------

Container(
  height: 34,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(18),
    gradient: LinearGradient(
      colors: badge == "NEW"
          ? const [
              Color(0xFF7C3AED),
              Color(0xFF8B5CF6),
            ]
          : const [
              Color(0xFFFF2E88),
              Color(0xFFFF5BA5),
            ],
    ),
    boxShadow: [
      BoxShadow(
        color: (badge == "NEW"
                ? const Color(0xFF7C3AED)
                : const Color(0xFFFF2E88))
            .withOpacity(.28),
        blurRadius: 18,
        offset: const Offset(0, 8),
      ),
    ],
  ),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children:  [
      Text(
  badge == "POPULAR"
      ? "List Now"
      : "Find Flat",
        style: TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
      SizedBox(width: 8),
      Icon(
        Icons.arrow_forward_rounded,
        color: Colors.white,
      ),
    ],
  ),
),

                      ],
                    ),
                  ),
                  //============================================
// Bottom White Wave
//============================================



//============================================
// Glass Overlay
//============================================

Positioned.fill(
  child: IgnorePointer(
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withOpacity(.18),
            Colors.transparent,
            Colors.transparent,
            Colors.white.withOpacity(.06),
          ],
        ),
      ),
    ),
  ),
),

//============================================
// Decorative Blob
//============================================

Positioned(
  top: 70,
  right: -35,
  child: Container(
    width: 85,
    height: 85,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white.withOpacity(.18),
    ),
  ),
),

Positioned(
  bottom: 80,
  left: -25,
  child: Container(
    width: 65,
    height: 65,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white.withOpacity(.15),
    ),
  ),
),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

}
