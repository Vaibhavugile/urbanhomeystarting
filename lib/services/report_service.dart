import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReportService {
  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static final FirebaseAuth _auth =
      FirebaseAuth.instance;

  /// ==========================================
  /// Report User
  /// ==========================================
  static Future<void> reportUser({
    required String reportedUserId,
    required String reportedProfileId,
    required String reason,
    String description = '',
  }) async {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      throw Exception("User not logged in.");
    }

    await _firestore.collection('reports').add({
      'reportedUserId': reportedUserId,
      'reportedProfileId': reportedProfileId,

      'reportedByUserId': currentUser.uid,

      'reason': reason,
      'description': description,

      'status': 'pending',

      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}