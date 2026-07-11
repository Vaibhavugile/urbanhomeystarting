import 'package:flutter/material.dart';

import '../dialogs/report_user_dialog.dart';
import '../dialogs/block_user_dialog.dart';

class ProfileActionMenu extends StatefulWidget {
  final String userId;
  final String profileId;
  final VoidCallback? onBlocked;

  const ProfileActionMenu({
    super.key,
    required this.userId,
    required this.profileId,
    this.onBlocked,
  });

  @override
  State<ProfileActionMenu> createState() =>
      _ProfileActionMenuState();
}

class _ProfileActionMenuState extends State<ProfileActionMenu> {
  bool _isProcessing = false;

  Future<void> _handleAction(String value) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      switch (value) {
        case 'report':
          await ReportUserDialog.show(
            context: context,
            reportedUserId: widget.userId,
            reportedProfileId: widget.profileId,
          );
          break;

        case 'block':
          final bool blocked = await BlockUserDialog.show(
            context: context,
            blockedUserId: widget.userId,
            blockedProfileId: widget.profileId,
          );

          if (!mounted) return;

          if (blocked) {
            widget.onBlocked?.call();
          }

          break;
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            'Unable to complete this action: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Profile Actions',

      enabled: !_isProcessing,

      color: Colors.white,

      elevation: 0,

      shadowColor: Colors.transparent,

      surfaceTintColor: Colors.transparent,

      offset: const Offset(0, 12),

      position: PopupMenuPosition.under,

      constraints: const BoxConstraints(
        minWidth: 245,
        maxWidth: 280,
      ),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(
          color: Color(0xFFE2E8F0),
        ),
      ),

      onSelected: _handleAction,

      itemBuilder: (menuContext) {
        return [
          PopupMenuItem<String>(
            value: 'report',
            padding: EdgeInsets.zero,
            child: _PremiumActionMenuItem(
              icon: Icons.flag_rounded,
              title: 'Report User',
              subtitle: 'Report inappropriate behavior',
              iconStartColor: const Color(0xFF7C3AED),
              iconEndColor: const Color(0xFFEC4899),
            ),
          ),

          const PopupMenuDivider(
            height: 1,
          ),

          PopupMenuItem<String>(
            value: 'block',
            padding: EdgeInsets.zero,
            child: _PremiumActionMenuItem(
              icon: Icons.block_rounded,
              title: 'Block User',
              subtitle: 'Hide and prevent interactions',
              iconStartColor: const Color(0xFF7C3AED),
              iconEndColor: const Color(0xFFEC4899),
            ),
          ),
        ];
      },

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(.20),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withOpacity(.22),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.08),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: _isProcessing
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white,
                  ),
                ),
              )
            : const Icon(
                Icons.more_vert_rounded,
                color: Colors.white,
                size: 24,
              ),
      ),
    );
  }
}

class _PremiumActionMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconStartColor;
  final Color iconEndColor;

  const _PremiumActionMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconStartColor,
    required this.iconEndColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 13,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  iconStartColor,
                  iconEndColor,
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: iconStartColor.withOpacity(.18),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 21,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    height: 1.3,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 13,
            color: Color(0xFF94A3B8),
          ),
        ],
      ),
    );
  }
}