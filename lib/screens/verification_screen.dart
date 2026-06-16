// File: verification_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

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

const LinearGradient kPrimaryGradient =
    LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFF7C3AED),
    Color(0xFF9333EA),
    Color(0xFFEC4899),
  ],
);

const LinearGradient kMessageGradient =
    LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFF7C3AED),
    Color(0xFF8B5CF6),
  ],
);
class VerificationScreen extends StatefulWidget {
  const VerificationScreen({Key? key}) : super(key: key);

  @override
  State<VerificationScreen> createState() =>
      _VerificationScreenState();
}

class _VerificationScreenState
    extends State<VerificationScreen> {

  // ============================
  // Verification Status
  // ============================

  String verificationStatus =
      'Not Verified';

  bool isVerified = false;

  bool isSubmitting = false;

  // ============================
  // Images
  // ============================

  File? selfieImage;

  File? governmentIdImage;
final ImagePicker _picker = ImagePicker();
  // ============================
  // Document Information
  // ============================

  String? selectedDocumentType;

  final List<String> documentTypes = [
    'Aadhaar Card',
    'PAN Card',
    'Passport',
    'Driving License',
    'Voter ID',
  ];

  // ============================
  // UI State
  // ============================
Future<void> _pickSelfie() async {
  final XFile? image = await _picker.pickImage(
    source: ImageSource.camera,
    imageQuality: 80,
  );

  if (image == null) return;

  setState(() {
    selfieImage = File(image.path);
  });
}
Future<void> _pickGovernmentId() async {
  final XFile? image = await _picker.pickImage(
    source: ImageSource.gallery,
    imageQuality: 80,
  );

  if (image == null) return;

  setState(() {
    governmentIdImage = File(image.path);
  });
}
Future<void> _showDocumentTypePicker() async {
  final String? selected =
      await showModalBottomSheet<String>(
    context: context,
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: documentTypes.map((type) {
            return ListTile(
              leading: const Icon(Icons.badge),
              title: Text(type),
              onTap: () {
                Navigator.pop(context, type);
              },
            );
          }).toList(),
        ),
      );
    },
  );

  if (selected == null) return;

  setState(() {
    selectedDocumentType = selected;
  });

  await _pickGovernmentId();
}
Future<String> _uploadImage(
  File file,
  String fileName,
) async {
  final user =
      FirebaseAuth.instance.currentUser!;

  final ref = FirebaseStorage.instance
      .ref()
      .child(
        'verifications/${user.uid}/$fileName',
      );

  await ref.putFile(file);

  return await ref.getDownloadURL();
}
Future<void> _submitVerification() async {
  if (selfieImage == null ||
      governmentIdImage == null) {
    return;
  }

  final user =
      FirebaseAuth.instance.currentUser;

  if (user == null) return;

  try {
    setState(() {
      isSubmitting = true;
    });

    final selfieUrl =
        await _uploadImage(
      selfieImage!,
      'selfie.jpg',
    );

    final idUrl =
        await _uploadImage(
      governmentIdImage!,
      'government_id.jpg',
    );

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({
      'verificationStatus':
          'pending',

      'isVerified': false,

      'verification': {
        'selfieUrl': selfieUrl,

        'governmentIdUrl': idUrl,

        'documentType':
            selectedDocumentType,

        'submittedAt':
            FieldValue.serverTimestamp(),
      }
    });

    setState(() {
      verificationStatus =
          'Pending Review';
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'Verification submitted successfully',
        ),
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          'Verification failed: $e',
        ),
      ),
    );
  } finally {
    setState(() {
      isSubmitting = false;
    });
  }
}
  bool selfieUploaded = false;

  bool idUploaded = false;

  bool verificationSubmitted = false;

 @override
Widget build(BuildContext context) {
  return Scaffold(
    extendBodyBehindAppBar: true,

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
            color: Colors.white.withOpacity(0.15),
            borderRadius:
                BorderRadius.circular(30),
            border: Border.all(
              color:
                  Colors.white.withOpacity(
                0.15,
              ),
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
  decoration: const BoxDecoration(
    gradient: kPrimaryGradient,
  ),
  child: SafeArea(
    child: SingleChildScrollView(
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

          // HEADER

          const Text(
            'Get Verified',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            'Upload a selfie and government-issued ID to receive your verified badge and build trust with potential flatmates and landlords.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.white70,
              height: 1.6,
            ),
          ),

          const SizedBox(height: 30),

          // STATUS CARD

          Container(
            padding:
                const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white
                  .withOpacity(0.12),
              borderRadius:
                  BorderRadius.circular(
                24,
              ),
              border: Border.all(
                color: Colors.white
                    .withOpacity(0.15),
              ),
            ),
            child: Row(
              children: [

                Container(
                  width: 60,
                  height: 60,
                  decoration:
                      BoxDecoration(
                    shape:
                        BoxShape.circle,
                    color: Colors.white
                        .withOpacity(
                            0.15),
                  ),
                  child: Icon(
                    _statusIcon,
                    color:
                        _statusColor,
                    size: 30,
                  ),
                ),

                const SizedBox(
                    width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [

                      const Text(
                        'Verification Status',
                        style:
                            TextStyle(
                          color: Colors
                              .white70,
                          fontSize:
                              13,
                        ),
                      ),

                      const SizedBox(
                          height: 4),

                      Text(
                        verificationStatus,
                        style:
                            TextStyle(
                          color:
                              _statusColor,
                          fontSize:
                              20,
                          fontWeight:
                              FontWeight
                                  .w800,
                        ),
                      ),

                      const SizedBox(
                          height: 4),

                      Text(
                        _statusDescription,
                        style:
                            const TextStyle(
                          color: Colors
                              .white70,
                          fontSize:
                              13,
                          height:
                              1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (verificationStatus ==
              'Pending Review')
            Container(
              margin:
                  const EdgeInsets.only(
                top: 15,
              ),
              padding:
                  const EdgeInsets.all(
                      16),
              decoration:
                  BoxDecoration(
                color: Colors.orange
                    .withOpacity(
                        0.15),
                borderRadius:
                    BorderRadius
                        .circular(18),
              ),
              child: const Row(
                children: [

                  Icon(
                    Icons
                        .hourglass_top,
                    color:
                        Colors.orange,
                  ),

                  SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      'Your verification request has been submitted and is awaiting approval.',
                      style:
                          TextStyle(
                        color: Colors
                            .white,
                      ),
                    ),
                  ),
                ],
              ),
            ),


            const SizedBox(height: 25),

            // SELFIE CARD

            _buildVerificationCard(
  title: 'Selfie Verification',
  description:
      'Take a clear selfie showing your full face.',
  icon: Icons.face,
  isUploaded: selfieImage != null,
  imageFile: selfieImage,
  onPressed: _pickSelfie,
),

            const SizedBox(height: 20),

            // GOVERNMENT ID CARD

            _buildVerificationCard(
  title: 'Government ID',
  description:
      'Upload Aadhaar Card, PAN Card, Passport, Driving License or Voter ID.',
  icon: Icons.badge,
  isUploaded: governmentIdImage != null,
  imageFile: governmentIdImage,
  documentType: selectedDocumentType,
  onPressed: _showDocumentTypePicker,
),

            const SizedBox(height: 30),

            // SUBMIT BUTTON

            // SUBMIT BUTTON

Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(20),
    gradient: kPrimaryGradient,
    boxShadow: [
      BoxShadow(
        color: kPrimaryColor.withOpacity(0.35),
        blurRadius: 20,
        offset: const Offset(0, 10),
      ),
    ],
  ),
  child: ElevatedButton(
    onPressed: selfieImage != null &&
            governmentIdImage != null
        ? _submitVerification
        : null,
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      disabledBackgroundColor:
          Colors.transparent,
      minimumSize:
          const Size(double.infinity, 62),
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(20),
      ),
    ),
    child: isSubmitting
        ? const SizedBox(
            height: 24,
            width: 24,
            child:
                CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          )
        : const Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [

              Icon(
                Icons.verified_user_rounded,
                color: Colors.white,
                size: 22,
              ),

              SizedBox(width: 10),

              Text(
                'Submit Verification',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight:
                      FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
  ),
),

const SizedBox(height: 28),

// BENEFITS CARD

Container(
  padding: const EdgeInsets.all(20),
  decoration: BoxDecoration(
    color: Colors.white.withOpacity(0.12),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(
      color:
          Colors.white.withOpacity(0.12),
    ),
  ),
  child: Column(
    children: [

      Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          Container(
            padding:
                const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: kOnlineColor
                  .withOpacity(0.15),
              borderRadius:
                  BorderRadius.circular(
                      10),
            ),
            child: const Icon(
              Icons.verified,
              color: kOnlineColor,
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Text(
              'Verified users receive a trusted badge that increases profile credibility and improves match confidence.',
              style: TextStyle(
                color: Colors.white,
                height: 1.5,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),

      const SizedBox(height: 16),

      Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          Container(
            padding:
                const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white
                  .withOpacity(0.12),
              borderRadius:
                  BorderRadius.circular(
                      10),
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: Colors.white,
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Text(
              'Your documents are securely stored and reviewed only for identity verification purposes.',
              style: TextStyle(
                color: Colors.white,
                height: 1.5,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),

      const SizedBox(height: 16),

      Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          Container(
            padding:
                const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: kReadTickColor
                  .withOpacity(0.15),
              borderRadius:
                  BorderRadius.circular(
                      10),
            ),
            child: const Icon(
              Icons.groups_rounded,
              color: kReadTickColor,
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Text(
              'Verified profiles are more likely to be trusted by flatmates and landlords.',
              style: TextStyle(
                color: Colors.white,
                height: 1.5,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    ],
  ),
),

const SizedBox(height: 28),

Center(
  child: TextButton.icon(
    onPressed: () {
      Navigator.pop(context);
    },
    icon: const Icon(
      Icons.arrow_back_rounded,
      color: Colors.white70,
      size: 18,
    ),
    label: const Text(
      'Maybe Later',
      style: TextStyle(
        color: Colors.white70,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
),
        ], // Column children
      ),
    ), // SingleChildScrollView
  ),
     ), // SafeArea
); // Container
}
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
      return 'Verification was rejected. Please upload clearer documents.';

    default:
      return 'Upload your selfie and ID to get verified.';
  }
}
Widget _buildVerificationCard({
  required String title,
  required String description,
  required IconData icon,
  required VoidCallback onPressed,
  required bool isUploaded,
  required File? imageFile,
  String? documentType,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      boxShadow: [
        BoxShadow(
          color: kPrimaryColor.withOpacity(0.08),
          blurRadius: 25,
          offset: const Offset(0, 12),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [

          // ICON

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

          // TITLE

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

          // IMAGE PREVIEW

          if (imageFile != null)
            Container(
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(20),
                border: Border.all(
                  color: kBorderColor,
                ),
              ),
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(20),
                child: Image.file(
                  imageFile,
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),
            ),

          if (imageFile != null)
            const SizedBox(height: 16),

          // DOCUMENT TYPE

          if (documentType != null)
            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color:
                    kPrimaryColor.withOpacity(
                  0.08,
                ),
                borderRadius:
                    BorderRadius.circular(50),
              ),
              child: Row(
                mainAxisSize:
                    MainAxisSize.min,
                children: [

                  const Icon(
                    Icons.badge_outlined,
                    size: 18,
                    color: kPrimaryColor,
                  ),

                  const SizedBox(width: 6),

                  Text(
                    documentType,
                    style:
                        const TextStyle(
                      color:
                          kPrimaryColor,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

          if (documentType != null)
            const SizedBox(height: 15),

          // STATUS CHIP

          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: isUploaded
                  ? kOnlineColor
                      .withOpacity(0.12)
                  : const Color(
                          0xFFF59E0B)
                      .withOpacity(0.12),
              borderRadius:
                  BorderRadius.circular(
                      50),
              border: Border.all(
                color: isUploaded
                    ? kOnlineColor
                        .withOpacity(0.25)
                    : const Color(
                            0xFFF59E0B)
                        .withOpacity(
                            0.25),
              ),
            ),
            child: Row(
              mainAxisSize:
                  MainAxisSize.min,
              children: [

                Icon(
                  isUploaded
                      ? Icons
                          .check_circle_rounded
                      : Icons
                          .pending_outlined,
                  size: 18,
                  color: isUploaded
                      ? kOnlineColor
                      : const Color(
                          0xFFF59E0B),
                ),

                const SizedBox(width: 8),

                Text(
                  isUploaded
                      ? 'Uploaded Successfully'
                      : 'Awaiting Upload',
                  style: TextStyle(
                    color: isUploaded
                        ? kOnlineColor
                        : const Color(
                            0xFFF59E0B),
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ACTION BUTTON

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onPressed,
              icon: Icon(
                isUploaded
                    ? Icons.edit_rounded
                    : Icons
                        .upload_file_rounded,
                color: Colors.white,
              ),
              label: Text(
                isUploaded
                    ? 'Replace Document'
                    : 'Upload Document',
                style: const TextStyle(
                  fontWeight:
                      FontWeight.w700,
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    kPrimaryColor,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(
                  vertical: 16,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                          18),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}