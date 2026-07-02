import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountDeletionService {
  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static final FirebaseAuth _auth =
      FirebaseAuth.instance;

  /// ==========================================
  /// Delete a subcollection
  /// ==========================================
  static Future<void> _deleteSubCollection(
    DocumentReference<Map<String, dynamic>> userDoc,
    String collectionName,
  ) async {
    final snapshot = await userDoc.collection(collectionName).get();

    if (snapshot.docs.isEmpty) return;

    final batch = _firestore.batch();

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  /// ==========================================
  /// Delete User Firestore Data
  /// ==========================================
  static Future<void> deleteUserDocument() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception("User not logged in.");
    }

    final userDoc =
        _firestore.collection('users').doc(user.uid);

    // Delete subcollections
    await _deleteSubCollection(
      userDoc,
      'flatListings',
    );

    await _deleteSubCollection(
      userDoc,
      'seekingFlatmateProfiles',
    );

    // Finally delete the user document
    await userDoc.delete();
    await user.delete();
  }
}