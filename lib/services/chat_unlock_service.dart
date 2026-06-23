import 'package:cloud_firestore/cloud_firestore.dart';

class ChatUnlockService {

  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;
static Future<void> createMatchAndChatRoom(
      String user1Uid,
  String user1ProfileId,
  String user1ProfileType,
  String user2Uid,
  String user2ProfileId,
  String user2ProfileType,
) async {

  List<String> sortedProfileIds = [
    user1ProfileId,
    user2ProfileId,
  ]..sort();

  String matchDocId =
      '${sortedProfileIds[0]}_${sortedProfileIds[1]}';

  print(
    "createMatchAndChatRoom: Attempting to check existence of match for profiles: $matchDocId",
  );

  try {

    DocumentSnapshot matchDoc =
        await _firestore
            .collection('matches')
            .doc(matchDocId)
            .get();

    print(
      "createMatchAndChatRoom: Match document existence check result: ${matchDoc.exists}",
    );

    if (!matchDoc.exists) {

      print(
        "createMatchAndChatRoom: Match document for profiles does not exist. Proceeding to create chat and match.",
      );

      // CHAT ID = phone_uid_phone_uid

      List<String> participants = [
        user1Uid,
        user2Uid,
      ]..sort();

      String chatRoomId =
          participants.join('_');

      // CREATE CHAT ONLY IF NOT EXISTS

      DocumentSnapshot chatDoc =
          await _firestore
              .collection('chats')
              .doc(chatRoomId)
              .get();

      if (!chatDoc.exists) {

        await _firestore
            .collection('chats')
            .doc(chatRoomId)
            .set({

          'participants': [
            user1Uid,
            user2Uid,
          ],

          'participants_profile_ids':
              sortedProfileIds,

          'createdAt':
              FieldValue.serverTimestamp(),

          'lastMessage': '',

          'lastMessageSenderId': '',

          'lastMessageTimestamp':
              null,

          'conversationUnlocked':
              false,

          'unlockedByUid':
              null,

          'unlockedByProfileId':
              null,

          'unlockedAt':
              null,
        });

        print(
          "createMatchAndChatRoom: Chat created with ID: $chatRoomId",
        );

      } else {

        print(
          "createMatchAndChatRoom: Chat already exists: $chatRoomId",
        );
      }

      await _firestore
          .collection('matches')
          .doc(matchDocId)
          .set({

        'user1_uid':
            user1Uid,

        'user2_uid':
            user2Uid,

        'user1_profile_id':
            user1ProfileId,

        'user2_profile_id':
            user2ProfileId,

        'user1_profile_type':
            user1ProfileType,

        'user2_profile_type':
            user2ProfileType,

        'chatRoomId':
            chatRoomId,

        'createdAt':
            FieldValue.serverTimestamp(),
      });

      print(
        "createMatchAndChatRoom: Match document created successfully for profiles: $matchDocId",
      );

    } else {

      print(
        "createMatchAndChatRoom: Match document for profiles already exists.",
      );

      String chatRoomId =
          (matchDoc.data()
              as Map<String, dynamic>)['chatRoomId'];

      print(
        "createMatchAndChatRoom: Existing chatRoomId: $chatRoomId",
      );
    }

  } catch (e) {

    print(
      "createMatchAndChatRoom ERROR: $e",
    );

    rethrow;
  }
}

}