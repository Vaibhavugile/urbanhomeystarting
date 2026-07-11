import 'package:flutter/material.dart';
import 'package:mytennat/services/report_service.dart';

class ReportUserDialog {
  static Future<bool> show({
    required BuildContext context,
    required String reportedUserId,
    required String reportedProfileId,
  }) async {
    final TextEditingController descriptionController =
        TextEditingController();

    String? selectedReason;
    bool isSubmitting = false;

    final bool? result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> submitReport() async {
              if (selectedReason == null || isSubmitting) {
                return;
              }

              setModalState(() {
                isSubmitting = true;
              });

              try {
                await ReportService.reportUser(
                  reportedUserId: reportedUserId,
                  reportedProfileId: reportedProfileId,
                  reason: selectedReason!,
                  description: descriptionController.text.trim(),
                );

                if (!sheetContext.mounted) return;

                Navigator.pop(sheetContext, true);
              } catch (e) {
                if (!sheetContext.mounted) return;

                setModalState(() {
                  isSubmitting = false;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,
                    content: Text(
                      'Unable to submit report: $e',
                    ),
                  ),
                );
              }
            }

            return PopScope(
              canPop: !isSubmitting,
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
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Handle
                          Container(
                            width: 44,
                            height: 5,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),

                          const SizedBox(height: 22),

                          // Premium report icon
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
                              Icons.flag_rounded,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),

                          const SizedBox(height: 20),

                          const Text(
                            'Report This User',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF111827),
                            ),
                          ),

                          const SizedBox(height: 8),

                          const Text(
                            'Help us keep UrbanHomey safe. Select the reason that best describes the issue.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.5,
                              color: Color(0xFF64748B),
                            ),
                          ),

                          const SizedBox(height: 22),

                          // Reasons
                          _ReportReasonTile(
                            title: 'Fake Profile',
                            icon: Icons.person_off_outlined,
                            selected:
                                selectedReason == 'Fake Profile',
                            enabled: !isSubmitting,
                            onTap: () {
                              setModalState(() {
                                selectedReason = 'Fake Profile';
                              });
                            },
                          ),

                          _ReportReasonTile(
                            title: 'Spam',
                            icon: Icons.mark_email_unread_outlined,
                            selected: selectedReason == 'Spam',
                            enabled: !isSubmitting,
                            onTap: () {
                              setModalState(() {
                                selectedReason = 'Spam';
                              });
                            },
                          ),

                          _ReportReasonTile(
                            title: 'Harassment',
                            icon: Icons.record_voice_over_outlined,
                            selected:
                                selectedReason == 'Harassment',
                            enabled: !isSubmitting,
                            onTap: () {
                              setModalState(() {
                                selectedReason = 'Harassment';
                              });
                            },
                          ),

                          _ReportReasonTile(
                            title: 'Inappropriate Content',
                            icon: Icons.visibility_off_outlined,
                            selected: selectedReason ==
                                'Inappropriate Content',
                            enabled: !isSubmitting,
                            onTap: () {
                              setModalState(() {
                                selectedReason =
                                    'Inappropriate Content';
                              });
                            },
                          ),

                          _ReportReasonTile(
                            title: 'Scam / Fraud',
                            icon: Icons.gpp_bad_outlined,
                            selected:
                                selectedReason == 'Scam / Fraud',
                            enabled: !isSubmitting,
                            onTap: () {
                              setModalState(() {
                                selectedReason = 'Scam / Fraud';
                              });
                            },
                          ),

                          _ReportReasonTile(
                            title: 'Other',
                            icon: Icons.more_horiz_rounded,
                            selected: selectedReason == 'Other',
                            enabled: !isSubmitting,
                            onTap: () {
                              setModalState(() {
                                selectedReason = 'Other';
                              });
                            },
                          ),

                          const SizedBox(height: 18),

                          // Additional details label
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Additional Details',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF334155),
                              ),
                            ),
                          ),

                          const SizedBox(height: 5),

                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Optional • Maximum 500 characters',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          TextField(
                            controller: descriptionController,
                            enabled: !isSubmitting,
                            maxLines: 4,
                            minLines: 3,
                            maxLength: 500,
                            textCapitalization:
                                TextCapitalization.sentences,
                            decoration: InputDecoration(
                              hintText:
                                  'Provide any additional information that may help us review this report...',
                              hintStyle: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 14,
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              contentPadding: const EdgeInsets.all(16),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE2E8F0),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Color(0xFF7C3AED),
                                  width: 1.8,
                                ),
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE2E8F0),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Safety notice
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
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.shield_outlined,
                                  color: Color(0xFF7C3AED),
                                  size: 22,
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Reports are reviewed to help keep the UrbanHomey community safe.',
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

                          // Submit button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient:
                                    selectedReason != null &&
                                            !isSubmitting
                                        ? const LinearGradient(
                                            begin:
                                                Alignment.centerLeft,
                                            end:
                                                Alignment.centerRight,
                                            colors: [
                                              Color(0xFF7C3AED),
                                              Color(0xFFEC4899),
                                            ],
                                          )
                                        : const LinearGradient(
                                            colors: [
                                              Color(0xFFCBD5E1),
                                              Color(0xFFCBD5E1),
                                            ],
                                          ),
                                borderRadius:
                                    BorderRadius.circular(18),
                                boxShadow:
                                    selectedReason != null &&
                                            !isSubmitting
                                        ? [
                                            BoxShadow(
                                              color: const Color(
                                                0xFFEC4899,
                                              ).withOpacity(.20),
                                              blurRadius: 18,
                                              offset:
                                                  const Offset(0, 8),
                                            ),
                                          ]
                                        : [],
                              ),
                              child: ElevatedButton(
                                onPressed:
                                    selectedReason == null ||
                                            isSubmitting
                                        ? null
                                        : submitReport,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Colors.transparent,
                                  disabledBackgroundColor:
                                      Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  disabledForegroundColor:
                                      Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(18),
                                  ),
                                ),
                                child: isSubmitting
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
                                            'Submitting Report...',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight:
                                                  FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      )
                                    : const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.flag_rounded,
                                            size: 21,
                                          ),
                                          SizedBox(width: 9),
                                          Text(
                                            'Submit Report',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight:
                                                  FontWeight.w700,
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
                              onPressed: isSubmitting
                                  ? null
                                  : () {
                                      Navigator.pop(
                                        sheetContext,
                                        false,
                                      );
                                    },
                              style: TextButton.styleFrom(
                                foregroundColor:
                                    const Color(0xFF475569),
                                backgroundColor:
                                    const Color(0xFFF8FAFC),
                                disabledForegroundColor:
                                    const Color(0xFF94A3B8),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(18),
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

    descriptionController.dispose();

    final bool reported = result == true;

    if (reported && context.mounted) {
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
                  'Thank you. Your report has been submitted.',
                ),
              ),
            ],
          ),
        ),
      );
    }

    return reported;
  }
}

class _ReportReasonTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  const _ReportReasonTile({
    required this.title,
    required this.icon,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
            decoration: BoxDecoration(
              color: selected
                  ? const Color(0xFFF5F3FF)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected
                    ? const Color(0xFF7C3AED)
                    : const Color(0xFFE2E8F0),
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFFEDE9FE)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: selected
                        ? const Color(0xFF7C3AED)
                        : const Color(0xFF64748B),
                  ),
                ),

                const SizedBox(width: 13),

                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: selected
                          ? const Color(0xFF5B21B6)
                          : const Color(0xFF334155),
                    ),
                  ),
                ),

                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: selected
                        ? const LinearGradient(
                            colors: [
                              Color(0xFF7C3AED),
                              Color(0xFFEC4899),
                            ],
                          )
                        : null,
                    color: selected ? null : Colors.white,
                    border: Border.all(
                      color: selected
                          ? Colors.transparent
                          : const Color(0xFFCBD5E1),
                      width: 1.5,
                    ),
                  ),
                  child: selected
                      ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 16,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}