import 'package:flutter/material.dart';

class BannerPopupScreen extends StatelessWidget {
final String message;
final String? subMessage;

final String? profileName;
final String? profileImageUrl;

final String? buttonText;
final VoidCallback? onButtonPressed;

const BannerPopupScreen({
  super.key,

  required this.message,

  this.subMessage,

  this.profileName,
  this.profileImageUrl,

  this.buttonText,

  this.onButtonPressed,
});

 @override
Widget build(BuildContext context) {

  final screenHeight =
      MediaQuery.of(context).size.height;

  final double headerHeight =
      screenHeight * 0.55;

  return Scaffold(
    backgroundColor: Colors.white,

    body: Stack(
      children: [

        // PURPLE HEADER
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: headerHeight,
          child: ClipPath(
            clipper:
                BottomConcaveCurveClipper(
              curveHeight: 90,
            ),
            child: Container(
              decoration:
                  const BoxDecoration(
                gradient:
                    LinearGradient(
                  begin:
                      Alignment.topLeft,
                  end: Alignment
                      .bottomRight,
                  colors: [
                    Color(0xFF7C3AED),
                    Color(0xFF9333EA),
                    Color(0xFFEC4899),
                  ],
                ),
              ),
            ),
          ),
        ),

        SafeArea(
          child: Column(
            children: [

              // CLOSE
              Align(
                alignment:
                    Alignment.topRight,
                child: IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: () {
                    Navigator.pop(
                      context,
                    );
                  },
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              // PROFILE IMAGE
              Container(
                width: 130,
                height: 130,
                decoration:
                    BoxDecoration(
                  shape:
                      BoxShape.circle,
                  border: Border.all(
                    color:
                        Colors.white,
                    width: 4,
                  ),
                  image:
                      profileImageUrl !=
                                  null &&
                              profileImageUrl!
                                  .isNotEmpty
                          ? DecorationImage(
                              image:
                                  NetworkImage(
                                profileImageUrl!,
                              ),
                              fit: BoxFit
                                  .cover,
                            )
                          : null,
                ),
                child:
                    profileImageUrl ==
                                null ||
                            profileImageUrl!
                                .isEmpty
                        ? const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 60,
                          )
                        : null,
              ),

              const SizedBox(
                height: 12,
              ),

              if (profileName != null)
                Text(
                  profileName!,
                  style:
                      const TextStyle(
                    color:
                        Colors.white,
                    fontSize: 24,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

              const SizedBox(
                height: 24,
              ),

              Padding(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 24,
                ),
                child: Text(
                  message,
                  textAlign:
                      TextAlign.center,
                  style:
                      const TextStyle(
                    color:
                        Colors.white,
                    fontSize: 24,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),

              if (subMessage != null)
                Padding(
                  padding:
                      const EdgeInsets
                          .all(20),
                  child: Text(
                    subMessage!,
                    textAlign:
                        TextAlign.center,
                    style:
                        const TextStyle(
                      color:
                          Colors.white,
                    ),
                  ),
                ),

              const Spacer(),

              Padding(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 24,
                ),
                child: Text(
                  profileName != null
                      ? 'You liked $profileName'
                      : 'You liked this profile',
                  textAlign:
                      TextAlign.center,
                  style:
                      const TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              const Text(
                'Unlock contact & start chatting',
                style: TextStyle(
                  color:
                      Color(0xFF7C3AED),
                  fontSize: 20,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 24,
              ),

              if (buttonText != null)
                Padding(
                  padding:
                      const EdgeInsets
                          .all(24),
                  child:
                      ElevatedButton(
                    onPressed:
                        onButtonPressed,
                    style:
                        ElevatedButton
                            .styleFrom(
                      backgroundColor:
                          const Color(
                        0xFF7C3AED,
                      ),
                      minimumSize:
                          const Size
                              .fromHeight(
                        58,
                      ),
                    ),
                    child: Text(
                      buttonText!,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}
}

// Custom Clipper for creating the smooth, concave (U-shaped) bottom curve of the red background
class BottomConcaveCurveClipper
    extends CustomClipper<Path> {

  final double curveHeight;

  BottomConcaveCurveClipper({
    required this.curveHeight,
  });

  @override
  Path getClip(Size size) {

    final path = Path();

    path.lineTo(
      0,
      size.height - curveHeight,
    );

    path.cubicTo(
      size.width * 0.20,
      size.height + 10,

      size.width * 0.80,
      size.height + 10,

      size.width,
      size.height - curveHeight,
    );

    path.lineTo(
      size.width,
      0,
    );

    path.close();

    return path;
  }

  @override
  bool shouldReclip(
    covariant BottomConcaveCurveClipper
        oldClipper,
  ) {
    return oldClipper.curveHeight !=
        curveHeight;
  }
}