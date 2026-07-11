import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/chat_plan.dart';


class ChatPlanService {
  ChatPlanService._();

  static final ChatPlanService instance =
      ChatPlanService._();


  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;


  // ============================================================
  // GET ACTIVE CHAT PLANS
  // ============================================================

  Future<List<ChatPlan>> getActivePlans() async {
    final QuerySnapshot<Map<String, dynamic>>
        snapshot = await _firestore
            .collection('chatPlans')
            .where(
              'isActive',
              isEqualTo: true,
            )
            .get();


    final List<ChatPlan> plans =
        snapshot.docs
            .map(
              (doc) => ChatPlan.fromMap(
                doc.data(),
                doc.id,
              ),
            )
            .where(
              (plan) =>
                  plan.productId.isNotEmpty &&
                  plan.contacts > 0,
            )
            .toList();


    // Sort locally for now.
    //
    // This avoids requiring a Firestore composite index for:
    //
    // isActive == true
    // sortOrder ascending

    plans.sort(
      (first, second) =>
          first.sortOrder.compareTo(
        second.sortOrder,
      ),
    );


    return plans;
  }
}