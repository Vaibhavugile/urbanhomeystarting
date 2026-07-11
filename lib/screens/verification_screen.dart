// File: verification_screen.dart

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

// ============================================================
// COLORS
// ============================================================

const Color kPrimaryColor = Color(0xFF7C3AED);
const Color kSecondaryColor = Color(0xFF9333EA);
const Color kAccentColor = Color(0xFFEC4899);

const Color kBackgroundColor = Color(0xFFF8FAFC);
const Color kCardColor = Colors.white;
const Color kLightGrey = Color(0xFFF1F5F9);
const Color kBorderColor = Color(0xFFE2E8F0);

const Color kDarkText = Color(0xFF111827);
const Color kMediumText = Color(0xFF64748B);
const Color kLightText = Color(0xFF94A3B8);

const Color kOnlineColor = Color(0xFF22C55E);
const Color kReadTickColor = Color(0xFF3B82F6);
const Color kErrorColor = Color(0xFFEF4444);

const LinearGradient kPrimaryGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFF7C3AED),
    Color(0xFF9333EA),
    Color(0xFFEC4899),
  ],
);

// ============================================================
// VERIFICATION SCREEN
// ============================================================

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({
    super.key,
  });

  @override
  State<VerificationScreen> createState() =>
      _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  // ============================================================
  // VERIFICATION STATUS
  // ============================================================

  String verificationStatus = 'Not Verified';

  bool isVerified = false;

  bool isSubmitting = false;

  bool isLoadingVerification = true;

  // ============================================================
  // LOCAL IMAGES
  // ============================================================

  File? selfieImage;

  File? governmentIdImage;

  // ============================================================
  // EXISTING FIREBASE STORAGE IMAGES
  // ============================================================

  String? existingSelfieUrl;

  String? existingGovernmentIdUrl;

  // ============================================================
  // IMAGE PICKER
  // ============================================================

  final ImagePicker _picker = ImagePicker();

  // ============================================================
  // DOCUMENT INFORMATION
  // ============================================================

  String? selectedDocumentType;

  final List<String> documentTypes = [
    'Aadhaar Card',
    'PAN Card',
    'Passport',
    'Driving License',
    'Voter ID',
  ];

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _loadVerificationStatus();
  }

  // ============================================================
  // LOAD EXISTING VERIFICATION DATA
  // ============================================================

  Future<void> _loadVerificationStatus() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!mounted) return;

      setState(() {
        isLoadingVerification = false;
      });

      return;
    }

    try {
      final document = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!mounted) return;

      if (!document.exists || document.data() == null) {
        setState(() {
          verificationStatus = 'Not Verified';

          isVerified = false;

          isLoadingVerification = false;
        });

        return;
      }

      final Map<String, dynamic> data = document.data()!;

      final bool verified = data['isVerified'] == true;

      final String firestoreStatus =
          data['verificationStatus']?.toString().toLowerCase() ?? '';

      final dynamic verificationData = data['verification'];

      String? selfieUrl;

      String? governmentIdUrl;

      String? documentType;

      if (verificationData is Map) {
        selfieUrl = verificationData['selfieUrl']?.toString();

        governmentIdUrl =
            verificationData['governmentIdUrl']?.toString();

        documentType =
            verificationData['documentType']?.toString();
      }

      String resolvedStatus;

      if (verified) {
        resolvedStatus = 'Verified';
      } else {
        switch (firestoreStatus) {
          case 'pending':
            resolvedStatus = 'Pending Review';
            break;

          case 'rejected':
            resolvedStatus = 'Rejected';
            break;

          default:
            resolvedStatus = 'Not Verified';
        }
      }

      setState(() {
        isVerified = verified;

        verificationStatus = resolvedStatus;

        existingSelfieUrl = selfieUrl;

        existingGovernmentIdUrl = governmentIdUrl;

        selectedDocumentType = documentType;

        isLoadingVerification = false;
      });
    } catch (e, stackTrace) {
      debugPrint(
        'Error loading verification data: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      if (!mounted) return;

      setState(() {
        isLoadingVerification = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            'Unable to load verification information.',
          ),
        ),
      );
    }
  }

  // ============================================================
  // COMPRESS IMAGE
  // ============================================================

  Future<File> _compressImage(
    File file,
  ) async {
    final directory = await getTemporaryDirectory();

    int quality = 80;

    while (true) {
      final String targetPath =
          '${directory.path}/${DateTime.now().microsecondsSinceEpoch}_$quality.jpg';

      final result =
          await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: quality,
        minWidth: 1280,
        minHeight: 1280,
        format: CompressFormat.jpeg,
        keepExif: false,
      );

      if (result == null) {
        return file;
      }

      final File compressed = File(result.path);

      final double sizeKB =
          await compressed.length() / 1024;

      debugPrint(
        'Verification Image: '
        '${sizeKB.toStringAsFixed(1)} KB',
      );

      if (sizeKB <= 300 || quality <= 40) {
        return compressed;
      }

      quality -= 5;
    }
  }

  // ============================================================
  // PICK SELFIE
  // ============================================================

  Future<void> _pickSelfie() async {
    if (_verificationLocked || isSubmitting) {
      return;
    }

    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 100,
    );

    if (image == null) return;

    if (!mounted) return;

    setState(() {
      isSubmitting = true;
    });

    try {
      final File compressed = await _compressImage(
        File(image.path),
      );

      if (!mounted) return;

      setState(() {
        selfieImage = compressed;
      });

      debugPrint(
        'Selfie Size: '
        '${(await compressed.length() / 1024).toStringAsFixed(1)} KB',
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            'Unable to process selfie: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  // ============================================================
  // PICK GOVERNMENT ID
  // ============================================================

  Future<void> _pickGovernmentId() async {
    if (_verificationLocked || isSubmitting) {
      return;
    }

    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
    );

    if (image == null) return;

    if (!mounted) return;

    setState(() {
      isSubmitting = true;
    });

    try {
      final File compressed = await _compressImage(
        File(image.path),
      );

      if (!mounted) return;

      setState(() {
        governmentIdImage = compressed;
      });

      debugPrint(
        'Document Size: '
        '${(await compressed.length() / 1024).toStringAsFixed(1)} KB',
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            'Unable to process document: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  // ============================================================
  // DOCUMENT TYPE PICKER
  // ============================================================

  Future<void> _showDocumentTypePicker() async {
    if (_verificationLocked || isSubmitting) {
      return;
    }

    final String? selected =
        await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.fromLTRB(
              18,
              12,
              18,
              18,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: kBorderColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Select Document Type',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: kDarkText,
                  ),
                ),

                const SizedBox(height: 16),

                ...documentTypes.map(
                  (type) {
                    final bool selected =
                        selectedDocumentType == type;

                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: 8,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius:
                              BorderRadius.circular(16),
                          onTap: () {
                            Navigator.pop(
                              sheetContext,
                              type,
                            );
                          },
                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 13,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? const Color(0xFFF5F3FF)
                                  : kBackgroundColor,
                              borderRadius:
                                  BorderRadius.circular(16),
                              border: Border.all(
                                color: selected
                                    ? kPrimaryColor
                                    : kBorderColor,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? const Color(0xFFEDE9FE)
                                        : Colors.white,
                                    borderRadius:
                                        BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.badge_outlined,
                                    color: selected
                                        ? kPrimaryColor
                                        : kMediumText,
                                  ),
                                ),

                                const SizedBox(width: 12),

                                Expanded(
                                  child: Text(
                                    type,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight:
                                          FontWeight.w700,
                                      color: selected
                                          ? kPrimaryColor
                                          : kDarkText,
                                    ),
                                  ),
                                ),

                                if (selected)
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    color: kPrimaryColor,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected == null || !mounted) {
      return;
    }

    setState(() {
      selectedDocumentType = selected;
    });

    await _pickGovernmentId();
  }

  // ============================================================
  // UPLOAD IMAGE
  // ============================================================

  Future<String> _uploadImage(
    File file,
    String fileName,
  ) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception(
        'You must be signed in to upload verification documents.',
      );
    }

    final double sizeKB =
        await file.length() / 1024;

    debugPrint(
      'Uploading $fileName '
      '(${sizeKB.toStringAsFixed(1)} KB)',
    );

    final Reference reference =
        FirebaseStorage.instance
            .ref()
            .child(
              'verifications/${user.uid}/$fileName',
            );

    await reference.putFile(
      file,
      SettableMetadata(
        contentType: 'image/jpeg',
      ),
    );

    return reference.getDownloadURL();
  }

  // ============================================================
  // SUBMIT VERIFICATION
  // ============================================================

  Future<void> _submitVerification() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null ||
        isSubmitting ||
        _verificationLocked) {
      return;
    }

    if (!_hasSelfie ||
        !_hasGovernmentId ||
        selectedDocumentType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            'Please upload your selfie, government ID, '
            'and select a document type.',
          ),
        ),
      );

      return;
    }

    try {
      setState(() {
        isSubmitting = true;
      });

      String? selfieUrl = existingSelfieUrl;

      String? governmentIdUrl =
          existingGovernmentIdUrl;

      // Upload only newly selected selfie.
      if (selfieImage != null) {
        selfieUrl = await _uploadImage(
          selfieImage!,
          'selfie.jpg',
        );
      }

      // Upload only newly selected government ID.
      if (governmentIdImage != null) {
        governmentIdUrl = await _uploadImage(
          governmentIdImage!,
          'government_id.jpg',
        );
      }

      if (selfieUrl == null ||
          selfieUrl.isEmpty ||
          governmentIdUrl == null ||
          governmentIdUrl.isEmpty) {
        throw Exception(
          'Verification images are missing.',
        );
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'verificationStatus': 'pending',
        'isVerified': false,
        'verification': {
          'selfieUrl': selfieUrl,
          'governmentIdUrl': governmentIdUrl,
          'documentType': selectedDocumentType,
          'submittedAt': FieldValue.serverTimestamp(),
        },
      });

      if (!mounted) return;

      setState(() {
        verificationStatus = 'Pending Review';

        isVerified = false;

        existingSelfieUrl = selfieUrl;

        existingGovernmentIdUrl = governmentIdUrl;

        selfieImage = null;

        governmentIdImage = null;
      });

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
                  'Verification submitted successfully.',
                ),
              ),
            ],
          ),
        ),
      );

      await Future<void>.delayed(
        const Duration(milliseconds: 700),
      );

      if (!mounted) return;

      // Return to UserScreen.
      // UserScreen refreshes Firestore status after Navigator.push returns.
      Navigator.pop(context, true);
    } catch (e, stackTrace) {
      debugPrint(
        'Verification submission failed: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            'Verification failed: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  // ============================================================
  // COMPUTED STATE
  // ============================================================

  bool get _hasSelfie {
    return selfieImage != null ||
        (existingSelfieUrl != null &&
            existingSelfieUrl!.isNotEmpty);
  }

  bool get _hasGovernmentId {
    return governmentIdImage != null ||
        (existingGovernmentIdUrl != null &&
            existingGovernmentIdUrl!.isNotEmpty);
  }

  bool get _verificationLocked {
    return verificationStatus == 'Pending Review' ||
        verificationStatus == 'Verified';
  }

  bool get _canSubmit {
    return _hasSelfie &&
        _hasGovernmentId &&
        selectedDocumentType != null &&
        !isSubmitting &&
        !_verificationLocked;
  }

  // ============================================================
  // STATUS HELPERS
  // ============================================================

  Color get _statusColor {
    switch (verificationStatus) {
      case 'Verified':
        return kOnlineColor;

      case 'Pending Review':
        return const Color(0xFFF59E0B);

      case 'Rejected':
        return kErrorColor;

      default:
        return Colors.white;
    }
  }

  IconData get _statusIcon {
    switch (verificationStatus) {
      case 'Verified':
        return Icons.verified_rounded;

      case 'Pending Review':
        return Icons.hourglass_top_rounded;

      case 'Rejected':
        return Icons.cancel_rounded;

      default:
        return Icons.verified_user_rounded;
    }
  }

  String get _statusDescription {
    switch (verificationStatus) {
      case 'Verified':
        return 'Your identity has been successfully verified.';

      case 'Pending Review':
        return 'Your verification request is currently under review.';

      case 'Rejected':
        return 'Verification was rejected. '
            'Please replace the required documents and submit again.';

      default:
        return 'Upload your selfie and government ID to get verified.';
    }
  }

  String get _headerTitle {
    switch (verificationStatus) {
      case 'Verified':
        return 'You\'re Verified';

      case 'Pending Review':
        return 'Verification Submitted';

      case 'Rejected':
        return 'Verification Needs Attention';

      default:
        return 'Get Verified';
    }
  }

  String get _headerDescription {
    switch (verificationStatus) {
      case 'Verified':
        return 'Your identity verification is complete. '
            'Your verified badge helps build trust with the '
            'UrbanHomey community.';

      case 'Pending Review':
        return 'Your selfie and government-issued ID were received. '
            'Your verification request is currently being reviewed.';

      case 'Rejected':
        return 'Your previous verification submission was not approved. '
            'Review your documents, replace them if needed, '
            'and submit again.';

      default:
        return 'Upload a selfie and government-issued ID to receive '
            'your verified badge and build trust with potential '
            'flatmates and landlords.';
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: kPrimaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: const Text(
          'Verification',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: kPrimaryGradient,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(
              right: 16,
            ),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.15),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withOpacity(.15),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      color: Colors.white,
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Secure',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: kPrimaryGradient,
        ),
        child: SafeArea(
          child: isLoadingVerification
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                )
              : RefreshIndicator(
                  color: kPrimaryColor,
                  onRefresh: _loadVerificationStatus,
                  child: SingleChildScrollView(
                    physics:
                        const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      10,
                      20,
                      30,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 10),

                        Text(
                          _headerTitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -.5,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Text(
                          _headerDescription,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.white70,
                            height: 1.6,
                          ),
                        ),

                        const SizedBox(height: 30),

                        _buildStatusCard(),

                        if (verificationStatus ==
                            'Pending Review') ...[
                          const SizedBox(height: 15),
                          _buildPendingNotice(),
                        ],

                        if (verificationStatus ==
                            'Verified') ...[
                          const SizedBox(height: 15),
                          _buildVerifiedNotice(),
                        ],

                        if (verificationStatus ==
                            'Rejected') ...[
                          const SizedBox(height: 15),
                          _buildRejectedNotice(),
                        ],

                        const SizedBox(height: 25),

                        _buildVerificationCard(
                          title: 'Selfie Verification',
                          description:
                              'Take a clear selfie showing your full face.',
                          icon: Icons.face_rounded,
                          isUploaded: _hasSelfie,
                          imageFile: selfieImage,
                          networkImageUrl: existingSelfieUrl,
                          onPressed: _pickSelfie,
                          uploadedLabel: selfieImage != null
                              ? 'New Selfie Selected'
                              : existingSelfieUrl != null
                                  ? 'Selfie Uploaded'
                                  : 'Awaiting Upload',
                          uploadButtonLabel: 'Take Selfie',
                          replaceButtonLabel: 'Replace Selfie',
                        ),

                        const SizedBox(height: 20),

                        _buildVerificationCard(
                          title: 'Government ID',
                          description:
                              'Upload Aadhaar Card, PAN Card, Passport, '
                              'Driving License or Voter ID.',
                          icon: Icons.badge_rounded,
                          isUploaded: _hasGovernmentId,
                          imageFile: governmentIdImage,
                          networkImageUrl:
                              existingGovernmentIdUrl,
                          documentType:
                              selectedDocumentType,
                          onPressed:
                              _showDocumentTypePicker,
                          uploadedLabel:
                              governmentIdImage != null
                                  ? 'New Document Selected'
                                  : existingGovernmentIdUrl !=
                                          null
                                      ? 'Document Uploaded'
                                      : 'Awaiting Upload',
                          uploadButtonLabel:
                              'Upload Government ID',
                          replaceButtonLabel:
                              'Replace Government ID',
                        ),

                        const SizedBox(height: 30),

                        _buildSubmitButton(),

                        const SizedBox(height: 28),

                        _buildBenefitsCard(),

                        const SizedBox(height: 28),

                        Center(
                          child: TextButton.icon(
                            onPressed: isSubmitting
                                ? null
                                : () {
                                    Navigator.pop(context);
                                  },
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.white70,
                              size: 18,
                            ),
                            label: Text(
                              _verificationLocked
                                  ? 'Back to Profile'
                                  : 'Maybe Later',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
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
  }

  // ============================================================
  // STATUS CARD
  // ============================================================

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.12),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(.15),
            ),
            child: Icon(
              _statusIcon,
              color: _statusColor,
              size: 30,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Verification Status',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  verificationStatus,
                  style: TextStyle(
                    color: _statusColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  _statusDescription,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NOTICES
  // ============================================================

  Widget _buildPendingNotice() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B).withOpacity(.15),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFF59E0B).withOpacity(.25),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.hourglass_top_rounded,
            color: Color(0xFFFBBF24),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Your verification request has been submitted and '
              'is awaiting approval. Documents cannot be changed '
              'while the review is in progress.',
              style: TextStyle(
                color: Colors.white,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifiedNotice() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kOnlineColor.withOpacity(.15),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: kOnlineColor.withOpacity(.25),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.verified_rounded,
            color: kOnlineColor,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Your identity has been verified successfully. '
              'Your verified badge is active.',
              style: TextStyle(
                color: Colors.white,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRejectedNotice() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kErrorColor.withOpacity(.15),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: kErrorColor.withOpacity(.25),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFFCA5A5),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Your previous verification request was not approved. '
              'Replace your selfie or government ID if needed, '
              'then submit the verification again.',
              style: TextStyle(
                color: Colors.white,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // VERIFICATION CARD
  // ============================================================

  Widget _buildVerificationCard({
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onPressed,
    required bool isUploaded,
    required File? imageFile,
    required String uploadedLabel,
    required String uploadButtonLabel,
    required String replaceButtonLabel,
    String? networkImageUrl,
    String? documentType,
  }) {
    final bool hasLocalImage = imageFile != null;

    final bool hasNetworkImage =
        networkImageUrl != null &&
        networkImageUrl.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: kPrimaryColor.withOpacity(.08),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: kPrimaryGradient,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 42,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: kDarkText,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: kMediumText,
                height: 1.6,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 20),

            if (hasLocalImage)
              _buildImagePreview(
                Image.file(
                  imageFile,
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                ),
              )
            else if (hasNetworkImage)
              _buildImagePreview(
                Image.network(
                  networkImageUrl,
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                  loadingBuilder: (
                    context,
                    child,
                    loadingProgress,
                  ) {
                    if (loadingProgress == null) {
                      return child;
                    }

                    return const SizedBox(
                      height: 220,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: kPrimaryColor,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (
                    context,
                    error,
                    stackTrace,
                  ) {
                    return const SizedBox(
                      height: 220,
                      child: Center(
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image_outlined,
                              color: kErrorColor,
                              size: 42,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Unable to load image',
                              style: TextStyle(
                                color: kMediumText,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

            if (hasLocalImage || hasNetworkImage)
              const SizedBox(height: 16),

            if (documentType != null &&
                documentType.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: kPrimaryColor.withOpacity(.08),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.badge_outlined,
                      size: 18,
                      color: kPrimaryColor,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        documentType,
                        style: const TextStyle(
                          color: kPrimaryColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
            ],

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: isUploaded
                    ? kOnlineColor.withOpacity(.12)
                    : const Color(0xFFF59E0B)
                        .withOpacity(.12),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: isUploaded
                      ? kOnlineColor.withOpacity(.25)
                      : const Color(0xFFF59E0B)
                          .withOpacity(.25),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isUploaded
                        ? Icons.check_circle_rounded
                        : Icons.pending_outlined,
                    size: 18,
                    color: isUploaded
                        ? kOnlineColor
                        : const Color(0xFFF59E0B),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      uploadedLabel,
                      style: TextStyle(
                        color: isUploaded
                            ? kOnlineColor
                            : const Color(0xFFF59E0B),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    _verificationLocked || isSubmitting
                        ? null
                        : onPressed,
                icon: Icon(
                  _verificationLocked
                      ? Icons.lock_outline_rounded
                      : isUploaded
                          ? Icons.edit_rounded
                          : Icons.upload_file_rounded,
                ),
                label: Text(
                  verificationStatus == 'Pending Review'
                      ? 'Under Review'
                      : verificationStatus == 'Verified'
                          ? 'Verified'
                          : isUploaded
                              ? replaceButtonLabel
                              : uploadButtonLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  disabledBackgroundColor:
                      const Color(0xFFCBD5E1),
                  foregroundColor: Colors.white,
                  disabledForegroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // IMAGE PREVIEW
  // ============================================================

  Widget _buildImagePreview(
    Widget image,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: kLightGrey,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: kBorderColor,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: image,
      ),
    );
  }

  // ============================================================
  // SUBMIT BUTTON
  // ============================================================

  Widget _buildSubmitButton() {
    String buttonText = 'Submit Verification';

    IconData buttonIcon =
        Icons.verified_user_rounded;

    if (verificationStatus == 'Pending Review') {
      buttonText = 'Verification Under Review';

      buttonIcon = Icons.hourglass_top_rounded;
    } else if (verificationStatus == 'Verified') {
      buttonText = 'Identity Verified';

      buttonIcon = Icons.verified_rounded;
    } else if (verificationStatus == 'Rejected') {
      buttonText = 'Resubmit Verification';

      buttonIcon = Icons.refresh_rounded;
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: _canSubmit
            ? kPrimaryGradient
            : const LinearGradient(
                colors: [
                  Color(0xFFCBD5E1),
                  Color(0xFF94A3B8),
                ],
              ),
        boxShadow: _canSubmit
            ? [
                BoxShadow(
                  color: kPrimaryColor.withOpacity(.35),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ]
            : [],
      ),
      child: ElevatedButton(
        onPressed: _canSubmit
            ? _submitVerification
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          disabledForegroundColor: Colors.white,
          minimumSize: const Size(
            double.infinity,
            62,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: isSubmitting
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.2,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Submitting...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    buttonIcon,
                    color: Colors.white,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      buttonText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ============================================================
  // BENEFITS CARD
  // ============================================================

  Widget _buildBenefitsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.12),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(.12),
        ),
      ),
      child: const Column(
        children: [
          _BenefitRow(
            icon: Icons.verified_rounded,
            iconColor: kOnlineColor,
            text:
                'Verified users receive a trusted badge that increases '
                'profile credibility and improves match confidence.',
          ),
          SizedBox(height: 16),
          _BenefitRow(
            icon: Icons.shield_outlined,
            iconColor: Colors.white,
            text:
                'Your documents are securely stored and reviewed only '
                'for identity verification purposes.',
          ),
          SizedBox(height: 16),
          _BenefitRow(
            icon: Icons.groups_rounded,
            iconColor: kReadTickColor,
            text:
                'Verified profiles are more likely to be trusted by '
                'flatmates and landlords.',
          ),
        ],
      ),
    );
  }
}

// ============================================================
// BENEFIT ROW
// ============================================================

class _BenefitRow extends StatelessWidget {
  final IconData icon;

  final Color iconColor;

  final String text;

  const _BenefitRow({
    required this.icon,
    required this.iconColor,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              height: 1.5,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}