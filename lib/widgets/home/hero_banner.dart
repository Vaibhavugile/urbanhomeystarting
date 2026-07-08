import 'dart:async';
import 'package:flutter/material.dart';

class HeroBanner extends StatefulWidget {
  final VoidCallback onFindRoom;
  final VoidCallback onFindFlatmate;

  const HeroBanner({
    super.key,
    required this.onFindRoom,
    required this.onFindFlatmate,
  });

  @override
  State<HeroBanner> createState() => _HeroBannerState();
}

class _HeroBannerState extends State<HeroBanner> {
  final PageController _controller = PageController();

  int _currentPage = 0;

  final List<String> images = [
    "assets/banners/banner6.png",
    "assets/banners/banner7.png",
    "assets/banners/banner8.png",
    "assets/banners/banner5.png",
  ];

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _startAutoSlide();
  }

  // ============================================================
  // AUTO SLIDE
  // ============================================================

  void _startAutoSlide() {
    _timer?.cancel();

    _timer = Timer.periodic(
      const Duration(seconds: 4),
      (_) {
        if (!mounted) return;

        if (!_controller.hasClients || images.isEmpty) {
          return;
        }

        final nextPage = (_currentPage + 1) % images.length;

        _controller.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      },
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();

    super.dispose();
  }

  // ============================================================
  // FALLBACK BACKGROUND
  // ============================================================

  Widget _fallbackBackground() {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF312E81),
            Color(0xFF7C3AED),
            Color(0xFFEC4899),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        /*
         * Use the width actually provided to HeroBanner.
         *
         * If HeroBanner is directly inside the screen Column,
         * this will be the complete screen width.
         */
        final bannerWidth = constraints.maxWidth;

        // Horizontal 16:9 ratio.
        final bannerHeight = bannerWidth * 9 / 16;

        return SizedBox(
          width: bannerWidth,
          height: bannerHeight,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ==================================================
              // BANNER CAROUSEL
              // ==================================================

              PageView.builder(
                controller: _controller,
                itemCount: images.length,
                padEnds: false,
                onPageChanged: (index) {
                  if (!mounted) return;

                  setState(() {
                    _currentPage = index;
                  });

                  // Restart auto-slide countdown after page change.
                  _startAutoSlide();
                },
                itemBuilder: (context, index) {
                  return SizedBox.expand(
                    child: Image.asset(
                      images[index],
                      width: bannerWidth,
                      height: bannerHeight,

                      // Completely fill the banner.
                      fit: BoxFit.cover,

                      alignment: Alignment.center,

                      errorBuilder: (
                        BuildContext context,
                        Object error,
                        StackTrace? stackTrace,
                      ) {
                        return _fallbackBackground();
                      },
                    ),
                  );
                },
              ),

              // ==================================================
              // BOTTOM GRADIENT
              // ==================================================

              IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      stops: const [
                        0.0,
                        0.50,
                        1.0,
                      ],
                      colors: [
                        Colors.black.withOpacity(0.38),
                        Colors.black.withOpacity(0.05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // ==================================================
              // VERIFIED MEMBERS BADGE
              // ==================================================

              Positioned(
                left: 16,
                bottom: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.60),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified_rounded,
                        color: Colors.white,
                        size: 17,
                      ),

                      SizedBox(width: 7),

                      Text(
                        "50K+ Verified Members",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ==================================================
              // PAGE INDICATORS
              // ==================================================

              Positioned(
                right: 16,
                bottom: 20,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    images.length,
                    (index) {
                      final bool isActive = _currentPage == index;

                      return AnimatedContainer(
                        duration: const Duration(
                          milliseconds: 300,
                        ),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.only(left: 5),
                        height: 7,
                        width: isActive ? 24 : 7,
                        decoration: BoxDecoration(
                          color: isActive
                              ? Colors.white
                              : Colors.white.withOpacity(0.55),
                          borderRadius: BorderRadius.circular(100),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}