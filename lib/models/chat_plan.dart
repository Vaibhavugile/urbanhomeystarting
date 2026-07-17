class ChatPlan {
  final String id;

  final String title;

  final String productId;

  final int contacts;

  /// Amount in INR (e.g. 99, 199, 499)
  final int amount;

  final int sortOrder;

  final String badge;

  final bool isHighlighted;

  final bool isActive;

  final List<String> features;

  const ChatPlan({
    required this.id,
    required this.title,
    required this.productId,
    required this.contacts,
    required this.amount,
    required this.sortOrder,
    required this.badge,
    required this.isHighlighted,
    required this.isActive,
    required this.features,
  });

  // ============================================================
  // CREATE CHAT PLAN FROM FIRESTORE
  // ============================================================

  factory ChatPlan.fromMap(
    Map<String, dynamic> data,
    String documentId,
  ) {
    return ChatPlan(
      id: documentId,

      title:
          data['title']?.toString() ?? '',

      productId:
          data['productId']?.toString() ??
              documentId,

      contacts:
          (data['contacts'] as num?)
                  ?.toInt() ??
              0,

      amount:
          (data['amount'] as num?)
                  ?.toInt() ??
              0,

      sortOrder:
          (data['sortOrder'] as num?)
                  ?.toInt() ??
              0,

      badge:
          data['badge']?.toString() ?? '',

      isHighlighted:
          data['isHighlighted'] == true,

      isActive:
          data['isActive'] == true,

      features:
          (data['features'] as List<dynamic>?)
                  ?.map(
                    (item) => item.toString(),
                  )
                  .toList() ??
              [],
    );
  }

  // ============================================================
  // CONVERT CHAT PLAN TO MAP
  // ============================================================

  Map<String, dynamic> toMap() {
    return {
      'title': title,

      'productId': productId,

      'contacts': contacts,

      'amount': amount,

      'sortOrder': sortOrder,

      'badge': badge,

      'isHighlighted': isHighlighted,

      'isActive': isActive,

      'features': features,
    };
  }

  @override
  String toString() {
    return 'ChatPlan('
        'id: $id, '
        'title: $title, '
        'productId: $productId, '
        'contacts: $contacts, '
        'amount: $amount, '
        'sortOrder: $sortOrder, '
        'badge: $badge, '
        'isHighlighted: $isHighlighted, '
        'isActive: $isActive, '
        'features: $features'
        ')';
  }
}