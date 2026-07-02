import 'package:flutter/material.dart';

import '../dialogs/report_user_dialog.dart';
import '../dialogs/block_user_dialog.dart';

class ProfileActionMenu extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'More',
      icon: const Icon(
        Icons.more_vert_rounded,
        color: Colors.white,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      onSelected: (value) async {
        switch (value) {
          case 'report':
            await ReportUserDialog.show(
              context: context,
              reportedUserId: userId,
              reportedProfileId: profileId,
            );
            break;

          case 'block':
            final blocked =
                await BlockUserDialog.show(
              context: context,
              blockedUserId: userId,
              blockedProfileId: profileId,
            );

            if (blocked && context.mounted) {
  if (onBlocked != null) {
    onBlocked!();
  }
}

            break;
        }
      },
      itemBuilder: (_) => const [
        PopupMenuItem(
          value: 'report',
          child: Row(
            children: [
              Icon(
                Icons.flag_outlined,
                color: Colors.orange,
              ),
              SizedBox(width: 12),
              Text("Report User"),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'block',
          child: Row(
            children: [
              Icon(
                Icons.block,
                color: Colors.red,
              ),
              SizedBox(width: 12),
              Text("Block User"),
            ],
          ),
        ),
      ],
    );
  }
}