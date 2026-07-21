import 'package:flutter/material.dart';

enum PremiumSnackbarType {
  success,
  error,
  warning,
  info,
}

class PremiumSnackbar {
  static void show(
    BuildContext context, {
    required String title,
    required String message,
    PremiumSnackbarType type = PremiumSnackbarType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.of(context);

    late Color startColor;
    late Color endColor;
    late IconData icon;

    switch (type) {
      case PremiumSnackbarType.success:
        startColor = const Color(0xFF16A34A);
        endColor = const Color(0xFF22C55E);
        icon = Icons.check_circle_rounded;
        break;

      case PremiumSnackbarType.error:
        startColor = const Color(0xFFDC2626);
        endColor = const Color(0xFFEF4444);
        icon = Icons.error_rounded;
        break;

      case PremiumSnackbarType.warning:
        startColor = const Color(0xFFF59E0B);
        endColor = const Color(0xFFFBBF24);
        icon = Icons.warning_amber_rounded;
        break;

      case PremiumSnackbarType.info:
        startColor = const Color(0xFF7C3AED);
        endColor = const Color(0xFFEC4899);
        icon = Icons.info_rounded;
        break;
    }

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Align(
            alignment: Alignment.topCenter,
            child: Material(
              color: Colors.transparent,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: -100, end: 0),
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutBack,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, value),
                    child: child,
                  );
                },
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 500),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: LinearGradient(
                      colors: [
                        startColor,
                        endColor,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: startColor.withOpacity(.35),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.18),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          icon,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),

                      const SizedBox(width: 16),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              message,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),

                      InkWell(
                        onTap: () => entry.remove(),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);

    Future.delayed(duration, () {
      if (entry.mounted) {
        entry.remove();
      }
    });
  }

  static void success(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    show(
      context,
      title: title,
      message: message,
      type: PremiumSnackbarType.success,
    );
  }

  static void error(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    show(
      context,
      title: title,
      message: message,
      type: PremiumSnackbarType.error,
    );
  }

  static void warning(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    show(
      context,
      title: title,
      message: message,
      type: PremiumSnackbarType.warning,
    );
  }

  static void info(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    show(
      context,
      title: title,
      message: message,
      type: PremiumSnackbarType.info,
    );
  }
}