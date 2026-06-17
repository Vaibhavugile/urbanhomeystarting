import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() =>
      _NotificationScreenState();
}

class _NotificationScreenState
    extends State<NotificationScreen> {

  bool _loading = true;

  List<QueryDocumentSnapshot> _notifications =
      [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final uid =
          FirebaseAuth.instance.currentUser!.uid;

      final snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('notifications')
              .orderBy(
                'createdAt',
                descending: true,
              )
              .limit(50)
              .get();

      if (!mounted) return;

      setState(() {
        _notifications = snapshot.docs;
        _loading = false;
      });
    } catch (e) {
      debugPrint(
        'Error loading notifications: $e',
      );

      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _markAsRead(
    String notificationId,
  ) async {
    final uid =
        FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .doc(notificationId)
        .update({
      'isRead': true,
    });
  }

  Future<void> _deleteNotification(
    String notificationId,
  ) async {
    final uid =
        FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .doc(notificationId)
        .delete();

    setState(() {
      _notifications.removeWhere(
        (doc) => doc.id == notificationId,
      );
    });
  }

  IconData _getIcon(String type) {
  switch (type) {
    case 'chat':
      return Icons.chat_bubble_rounded;

    case 'like':
      return Icons.favorite_rounded;

    case 'match':
      return Icons.favorite_border_rounded;

    case 'verification':
      return Icons.verified_rounded;

    case 'premium':
      return Icons.workspace_premium_rounded;

    case 'profile_view':
      return Icons.remove_red_eye_rounded;

    default:
      return Icons.notifications_active_rounded;
  }
}

Color _getIconColor(String type) {
  switch (type) {
    case 'chat':
      return kPrimaryColor;

    case 'like':
      return kAccentColor;

    case 'match':
      return kSecondaryColor;

    case 'verification':
      return kOnlineColor;

    case 'premium':
      return const Color(0xFFF59E0B);

    case 'profile_view':
      return const Color(0xFF06B6D4);

    default:
      return kPrimaryColor;
  }
}
LinearGradient _getNotificationGradient(
  String type,
) {
  switch (type) {
    case 'chat':
      return const LinearGradient(
        colors: [
          Color(0xFF7C3AED),
          Color(0xFF8B5CF6),
        ],
      );

    case 'like':
      return const LinearGradient(
        colors: [
          Color(0xFFEC4899),
          Color(0xFFF472B6),
        ],
      );

    case 'match':
      return const LinearGradient(
        colors: [
          Color(0xFF9333EA),
          Color(0xFFEC4899),
        ],
      );

    case 'verification':
      return const LinearGradient(
        colors: [
          Color(0xFF22C55E),
          Color(0xFF4ADE80),
        ],
      );

    default:
      return kPrimaryGradient;
  }
}

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: kBackgroundColor,

    appBar: AppBar(
      toolbarHeight: 85,
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: kPrimaryGradient,
        ),
      ),
      title: const Text(
        'Notifications',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w800,
          letterSpacing: .3,
        ),
      ),
    ),

    body: RefreshIndicator(
      color: kPrimaryColor,
      onRefresh: _loadNotifications,

      child: _loading

          ? const Center(
              child:
                  CircularProgressIndicator(
                color: kPrimaryColor,
              ),
            )

          : _notifications.isEmpty

              ? ListView(
                  children: [

                    const SizedBox(
                      height: 120,
                    ),

                    Center(
                      child: Container(
                        height: 120,
                        width: 120,
                        decoration:
                            const BoxDecoration(
                          gradient:
                              kPrimaryGradient,
                          shape:
                              BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons
                              .notifications_none_rounded,
                          color:
                              Colors.white,
                          size: 60,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 24,
                    ),

                    const Center(
                      child: Text(
                        "No Notifications Yet",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight:
                              FontWeight.w800,
                          color:
                              kDarkText,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    const Padding(
                      padding:
                          EdgeInsets.symmetric(
                        horizontal: 40,
                      ),
                      child: Text(
                        "Likes, matches, profile views and messages will appear here.",
                        textAlign:
                            TextAlign.center,
                        style: TextStyle(
                          color:
                              kMediumText,
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                )

              : ListView.builder(
                  padding:
                      const EdgeInsets.all(
                    16,
                  ),
                  itemCount:
                      _notifications.length,
                  itemBuilder:
                      (context, index) {

                    final doc =
                        _notifications[index];

                    final data =
                        doc.data()
                            as Map<String,
                                dynamic>;

                    final title =
                        data['title'] ?? '';

                    final body =
                        data['body'] ?? '';

                    final type =
                        data['type'] ?? '';

                    final isRead =
                        data['isRead'] ??
                            false;

                    return Dismissible(
                      key: Key(
                        doc.id,
                      ),

                      direction:
                          DismissDirection
                              .endToStart,

                      background:
                          Container(
                        margin:
                            const EdgeInsets.only(
                          bottom: 14,
                        ),
                        decoration:
                            BoxDecoration(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            24,
                          ),
                          gradient:
                              const LinearGradient(
                            colors: [
                              Color(
                                0xFFEF4444,
                              ),
                              Color(
                                0xFFF43F5E,
                              ),
                            ],
                          ),
                        ),
                        alignment:
                            Alignment
                                .centerRight,
                        padding:
                            const EdgeInsets.only(
                          right: 24,
                        ),
                        child:
                            const Icon(
                          Icons
                              .delete_outline_rounded,
                          color:
                              Colors.white,
                          size: 30,
                        ),
                      ),

                      onDismissed:
                          (_) {
                        _deleteNotification(
                          doc.id,
                        );
                      },

                      child: Container(
                        margin:
                            const EdgeInsets.only(
                          bottom: 14,
                        ),

                        decoration:
                            BoxDecoration(
                          color:
                              Colors.white,
                          borderRadius:
                              BorderRadius
                                  .circular(
                            24,
                          ),

                          border:
                              Border.all(
                            color: isRead
                                ? kBorderColor
                                : kPrimaryColor
                                    .withOpacity(
                              .15,
                            ),
                          ),

                          boxShadow: [
                            BoxShadow(
                              color: Colors
                                  .black
                                  .withOpacity(
                                .05,
                              ),
                              blurRadius:
                                  24,
                              offset:
                                  const Offset(
                                0,
                                10,
                              ),
                            ),
                          ],
                        ),

                        child: InkWell(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            24,
                          ),

                          onTap:
                              () async {

                            if (!isRead) {
                              await _markAsRead(
                                doc.id,
                              );
                            }

                            setState(
                              () {
                                data['isRead'] =
                                    true;
                              },
                            );
                          },

                          child:
                              Padding(
                            padding:
                                const EdgeInsets.all(
                              18,
                            ),

                            child: Row(
                              children: [

                                Container(
                                  height:
                                      58,
                                  width:
                                      58,
                                  decoration:
                                      BoxDecoration(
                                    gradient:
                                        _getNotificationGradient(
                                      type,
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(
                                      18,
                                    ),
                                  ),
                                  child:
                                      Icon(
                                    _getIcon(
                                      type,
                                    ),
                                    color:
                                        Colors.white,
                                    size:
                                        28,
                                  ),
                                ),

                                const SizedBox(
                                  width:
                                      16,
                                ),

                                Expanded(
                                  child:
                                      Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [

                                      Row(
                                        children: [

                                          Expanded(
                                            child:
                                                Text(
                                              title,
                                              style:
                                                  TextStyle(
                                                fontSize:
                                                    16,
                                                fontWeight:
                                                    isRead
                                                        ? FontWeight.w600
                                                        : FontWeight.w800,
                                                color:
                                                    kDarkText,
                                              ),
                                            ),
                                          ),

                                          if (!isRead)

                                            Container(
                                              width:
                                                  12,
                                              height:
                                                  12,
                                              decoration:
                                                  const BoxDecoration(
                                                gradient:
                                                    kPrimaryGradient,
                                                shape:
                                                    BoxShape.circle,
                                              ),
                                            ),
                                        ],
                                      ),

                                      const SizedBox(
                                        height:
                                            6,
                                      ),

                                      Text(
                                        body,
                                        maxLines:
                                            2,
                                        overflow:
                                            TextOverflow.ellipsis,
                                        style:
                                            const TextStyle(
                                          color:
                                              kMediumText,
                                          fontSize:
                                              14,
                                          height:
                                              1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    ),
  );
}
}