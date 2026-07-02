import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BlockUserService {
  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static final FirebaseAuth _auth =
      FirebaseAuth.instance;

  /// ==========================================
  /// Block User
  /// ==========================================
  static Future<void> blockUser({
    required String blockedUserId,
    required String blockedProfileId,
  }) async {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      throw Exception("User not logged in.");
    }

    await _firestore
        .collection('blockedUsers')
        .add({
      'blockedByUserId': currentUser.uid,

      'blockedUserId': blockedUserId,
      'blockedProfileId': blockedProfileId,

      'createdAt': FieldValue.serverTimestamp(),
    });
  }
  /// ==========================================
/// Check if User is Blocked
/// ==========================================
static Future<bool> isUserBlocked({
  required String otherUserId,
}) async {
  final currentUser = _auth.currentUser;

  if (currentUser == null) return false;

  // Did I block them?
  final blockedByMe = await _firestore
      .collection('blockedUsers')
      .where(
        'blockedByUserId',
        isEqualTo: currentUser.uid,
      )
      .where(
        'blockedUserId',
        isEqualTo: otherUserId,
      )
      .limit(1)
      .get();

  if (blockedByMe.docs.isNotEmpty) {
    return true;
  }

  // Did they block me?
  final blockedMe = await _firestore
      .collection('blockedUsers')
      .where(
        'blockedByUserId',
        isEqualTo: otherUserId,
      )
      .where(
        'blockedUserId',
        isEqualTo: currentUser.uid,
      )
      .limit(1)
      .get();

  return blockedMe.docs.isNotEmpty;
}
}