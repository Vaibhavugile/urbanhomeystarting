import 'package:flutter/material.dart';
import 'package:mytennat/services/block_user_service.dart';

class BlockUserDialog {
  static Future<bool> show({
    required BuildContext context,
    required String blockedUserId,
    required String blockedProfileId,
  }) async {
    bool blocked = false;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          title: const Row(
            children: [
              Icon(
                Icons.block,
                color: Colors.red,
              ),
              SizedBox(width: 10),
              Text("Block User"),
            ],
          ),

          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Are you sure you want to block this user?",
              ),

              SizedBox(height: 16),

              Text(
                "Once blocked:",
              ),

              SizedBox(height: 8),

              Text("• They won't be able to interact with you"),
              Text("• They won't appear in your matches"),
              Text("• You won't see each other's profiles"),
              Text("• You can unblock them later"),

              SizedBox(height: 16),

              Text(
                "This action can be managed later from your blocked users list.",
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                await BlockUserService.blockUser(
                  blockedUserId: blockedUserId,
                  blockedProfileId: blockedProfileId,
                );

                blocked = true;

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "User has been blocked.",
                    ),
                  ),
                );
              },
              child: const Text("Block User"),
            ),
          ],
        );
      },
    );

    return blocked;
  }
}