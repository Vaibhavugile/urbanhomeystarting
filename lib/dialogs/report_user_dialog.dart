import 'package:flutter/material.dart';
import 'package:mytennat/services/report_service.dart';

class ReportUserDialog {
  static Future<void> show({
    required BuildContext context,
    required String reportedUserId,
    required String reportedProfileId,
  }) async {
    String? selectedReason;
    final TextEditingController descriptionController =
        TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text("Report User"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Help us keep UrbanHomey safe. Select a reason for reporting this user.",
                    ),

                    const SizedBox(height: 20),

                    ...[
                      "Fake Profile",
                      "Spam",
                      "Harassment",
                      "Inappropriate Content",
                      "Scam / Fraud",
                      "Other",
                    ].map(
                      (reason) => RadioListTile<String>(
                        value: reason,
                        groupValue: selectedReason,
                        title: Text(reason),
                        onChanged: (value) {
                          setState(() {
                            selectedReason = value;
                          });
                        },
                      ),
                    ),

                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: "Additional Details (Optional)",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                ),
                ElevatedButton(
                  onPressed: selectedReason == null
                      ? null
                      : () async {
                          await ReportService.reportUser(
                            reportedUserId: reportedUserId,
                            reportedProfileId: reportedProfileId,
                            reason: selectedReason!,
                            description:
                                descriptionController.text.trim(),
                          );

                          Navigator.pop(dialogContext);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Thank you. Your report has been submitted.",
                              ),
                            ),
                          );
                        },
                  child: const Text("Submit"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}