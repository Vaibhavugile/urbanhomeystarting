class AppNotification {
  final String id;
  final String title;
  final String body;
  final String type;
  final bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
  });

  factory AppNotification.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    return AppNotification(
      id: id,
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      type: data['type'] ?? '',
      isRead: data['isRead'] ?? false,
    );
  }
}