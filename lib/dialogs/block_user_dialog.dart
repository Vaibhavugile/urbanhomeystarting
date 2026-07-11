import 'package:flutter/material.dart';
import 'package:mytennat/services/block_user_service.dart';

class BlockUserDialog {
  static Future<bool> show({
    required BuildContext context,
    required String blockedUserId,
    required String blockedProfileId,
  }) async {
    final bool? result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        bool isBlocking = false;

        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> handleBlockUser() async {
              if (isBlocking) return;

              setModalState(() {
                isBlocking = true;
              });

              try {
                await BlockUserService.blockUser(
                  blockedUserId: blockedUserId,
                  blockedProfileId: blockedProfileId,
                );

                if (!sheetContext.mounted) return;

                Navigator.pop(sheetContext, true);
              } catch (e) {
                if (!sheetContext.mounted) return;

                setModalState(() {
                  isBlocking = false;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,
                    content: Text(
                      'Unable to block user: $e',
                    ),
                  ),
                );
              }
            }

            return PopScope(
              canPop: !isBlocking,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: SafeArea(
                  top: false,
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.fromLTRB(
                      22,
                      12,
                      22,
                      22,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.14),
                          blurRadius: 32,
                          offset: const Offset(0, 14),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Bottom sheet handle
                          Container(
                            width: 44,
                            height: 5,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),

                          const SizedBox(height: 22),

                          // Premium icon
                          Container(
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF7C3AED),
                                  Color(0xFFEC4899),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFEC4899)
                                      .withOpacity(.25),
                                  blurRadius: 24,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.block_rounded,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),

                          const SizedBox(height: 20),

                          const Text(
                            'Block This User?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF111827),
                            ),
                          ),

                          const SizedBox(height: 8),

                          const Text(
                            'Are you sure you want to block this user? You will no longer be able to interact with each other.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.5,
                              color: Color(0xFF64748B),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Information card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: const Column(
                              children: [
                                _BlockInfoRow(
                                  icon: Icons.chat_bubble_outline_rounded,
                                  label:
                                      'They won\'t be able to interact with you',
                                ),
                                SizedBox(height: 12),
                                _BlockInfoRow(
                                  icon: Icons.favorite_border_rounded,
                                  label:
                                      'They won\'t appear in your matches',
                                ),
                                SizedBox(height: 12),
                                _BlockInfoRow(
                                  icon: Icons.visibility_off_outlined,
                                  label:
                                      'You won\'t see each other\'s profiles',
                                ),
                                SizedBox(height: 12),
                                _BlockInfoRow(
                                  icon: Icons.settings_backup_restore_rounded,
                                  label:
                                      'You can unblock them later',
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Additional notice
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F3FF),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFDDD6FE),
                              ),
                            ),
                            child: const Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  color: Color(0xFF7C3AED),
                                  size: 22,
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'You can manage and unblock users later from your blocked users list.',
                                    style: TextStyle(
                                      fontSize: 14,
                                      height: 1.4,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF5B21B6),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 22),

                          // Block button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: isBlocking
                                    ? const LinearGradient(
                                        colors: [
                                          Color(0xFFCBD5E1),
                                          Color(0xFFCBD5E1),
                                        ],
                                      )
                                    : const LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: [
                                          Color(0xFF7C3AED),
                                          Color(0xFFEC4899),
                                        ],
                                      ),
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: isBlocking
                                    ? []
                                    : [
                                        BoxShadow(
                                          color: const Color(0xFFEC4899)
                                              .withOpacity(.20),
                                          blurRadius: 18,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                              ),
                              child: ElevatedButton(
                                onPressed:
                                    isBlocking ? null : handleBlockUser,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  disabledBackgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  disabledForegroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child: isBlocking
                                    ? const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 20,
                                            height: 20,
                                            child:
                                                CircularProgressIndicator(
                                              strokeWidth: 2.2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<
                                                      Color>(
                                                Colors.white,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          Text(
                                            'Blocking User...',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      )
                                    : const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.block_rounded,
                                            size: 21,
                                          ),
                                          SizedBox(width: 9),
                                          Text(
                                            'Block User',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Cancel button
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: TextButton(
                              onPressed: isBlocking
                                  ? null
                                  : () {
                                      Navigator.pop(sheetContext, false);
                                    },
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF475569),
                                backgroundColor: const Color(0xFFF8FAFC),
                                disabledForegroundColor:
                                    const Color(0xFF94A3B8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  side: const BorderSide(
                                    color: Color(0xFFE2E8F0),
                                  ),
                                ),
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    final bool blocked = result == true;

    if (blocked && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'User has been blocked.',
                ),
              ),
            ],
          ),
        ),
      );
    }

    return blocked;
  }
}

class _BlockInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _BlockInfoRow({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F3FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 18,
            color: const Color(0xFF7C3AED),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              height: 1.35,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
            ),
          ),
        ),
      ],
    );
  }
}