import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:flutter/scheduler.dart'; // For post-frame callbacks
import 'package:rxdart/rxdart.dart'; // Ensure rxdart is imported if not already
import 'dart:async';
import 'package:mytennat/screens/PlansScreen.dart';
import 'package:mytennat/widgets/profile_action_menu.dart';
import 'package:mytennat/screens/view_profile_screen.dart';
// Custom Colors for a modern look, aligned with your gradient theme
// ======================================================
// PREMIUM APP COLORS
// ======================================================

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

class ChatScreen extends StatefulWidget {
  final String chatPartnerId; // The UID of the chat partner
  final String chatPartnerName;
  final String? chatPartnerImageUrl;
  final String? chatRoomId; // This might be null if it's a new chat, we will create it

  const ChatScreen({
    Key? key,
    required this.chatPartnerId,
    required this.chatPartnerName,
    this.chatPartnerImageUrl,
    this.chatRoomId,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  User? _currentUser;
  String? _chatRoomId; // This will hold the actual chat room ID, confirmed after creation/finding
  bool _showScrollToBottomButton = false;
  bool _isLoadingChat = true; // New state to indicate chat room loading/creation
  bool _isMarkingRead = false;
static const int _pageSize = 20;
StreamSubscription? _messageSubscription;
DocumentSnapshot? _lastDocument;

bool _hasMoreMessages = true;
bool _isLoadingMoreMessages = false;
bool _conversationUnlocked = false;

bool _checkingUnlockStatus = true;

int _remainingContacts = 0;
List<QueryDocumentSnapshot<Map<String, dynamic>>> _messages = [];
  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    WidgetsBinding.instance.addObserver(this);
    _initializeChatRoom(); // Call the new initialization method
    _loadRemainingContacts();

    _scrollController.addListener(() {
  if (_scrollController.position.pixels >=
      _scrollController.position.maxScrollExtent - 200) {
    _loadMoreMessages();
  }
});
  }

 @override
void dispose() {
  _messageSubscription?.cancel();

  _messageController.dispose();
  _scrollController.dispose();

  WidgetsBinding.instance.removeObserver(this);

  super.dispose();
}

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _markVisibleMessagesAsRead();
    }
  }
void _openPartnerProfile() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ViewProfileScreen(
        userId: widget.chatPartnerId,
      ),
    ),
  );
}
  // NEW: Function to find or create the chat room document
  Future<void> _initializeChatRoom() async {
    if (_currentUser == null) {
      print('[_initializeChatRoom] Current user is null. Cannot initialize chat.');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in. Please log in again.')),
        );
        Navigator.of(context).pop();
      }
      return;
    }


    // Determine a consistent chat room ID based on both UIDs
    List<String> participants = [_currentUser!.uid, widget.chatPartnerId];
    participants.sort(); // Sort to ensure consistent ID regardless of who initiated
    String generatedChatRoomId = participants.join('_'); // e.g., 'uid1_uid2'

    setState(() {
      _chatRoomId = widget.chatRoomId ?? generatedChatRoomId; // Use provided ID if available, else generate
    });

    print('[_initializeChatRoom] Initializing chat room. Proposed ID: $_chatRoomId');

    try {
      // Check if the chat room document already exists
      DocumentSnapshot chatDoc = await _firestore.collection('chats').doc(_chatRoomId).get();
if (chatDoc.exists) {

  final data =
      chatDoc.data()
          as Map<String, dynamic>;

  _conversationUnlocked =
      data['conversationUnlocked'] ??
          false;

  debugPrint(
    'CONVERSATION UNLOCKED = $_conversationUnlocked',
  );
}

_checkingUnlockStatus = false;
      if (!chatDoc.exists) {
        // If it doesn't exist, create it with initial data
        print('[_initializeChatRoom] Chat room $_chatRoomId does not exist. Creating...');
        await _firestore.collection('chats').doc(_chatRoomId).set({
          'createdAt': FieldValue.serverTimestamp(),
          'participants': participants, // Initialize with both UIDs
          'lastMessage': '',
          'lastMessageTimestamp': null,
          'lastMessageSenderId': '',
        });
        print('[_initializeChatRoom] Chat room $_chatRoomId created successfully.');
      } else {
        print('[_initializeChatRoom] Chat room $_chatRoomId already exists. Merging participants if needed.');
        // If it exists, ensure the participants array is correct (merge in case it was old or missing participants)
        await _firestore.collection('chats').doc(_chatRoomId).set(
          {
            'participants': FieldValue.arrayUnion(participants), // Ensure both UIDs are in the array
          },
          SetOptions(merge: true),
        );
        print('[_initializeChatRoom] Chat room $_chatRoomId participants ensured.');
      }
      _markVisibleMessagesAsRead(); // Mark messages as read after chat room is confirmed
      await _loadMoreMessages();
      _listenForNewMessages();
    } catch (e) {
      print('[_initializeChatRoom] Error initializing chat room: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error setting up chat: $e')),
        );
        Navigator.of(context).pop();
      }
    } if (mounted) {
      setState(() {
        _isLoadingChat = false; // Chat room initialization complete
      });
    }
  }
  Future<void> _loadRemainingContacts() async {

  try {

    final userDoc =
        await _firestore
            .collection('users')
            .doc(_currentUser!.uid)
            .get();

    if (userDoc.exists) {

      final data =
          userDoc.data()!;

      setState(() {

        _remainingContacts =
            data['remainingContacts'] ?? 0;
      });

      debugPrint(
        'REMAINING CONTACTS = $_remainingContacts',
      );
    }

  } catch (e) {

    debugPrint(
      'CONTACT LOAD ERROR: $e',
    );
  }
}
Future<void> _loadMoreMessages() async {
  if (_isLoadingMoreMessages || !_hasMoreMessages || _chatRoomId == null) {
    return;
  }

  setState(() {
    _isLoadingMoreMessages = true;
  });

  Query<Map<String, dynamic>> query = _firestore
      .collection('chats')
      .doc(_chatRoomId)
      .collection('messages')
      .orderBy('timestamp', descending: true)
      .limit(_pageSize);

  if (_lastDocument != null) {
    query = query.startAfterDocument(_lastDocument!);
  }

  final snapshot = await query.get();

  if (snapshot.docs.isNotEmpty) {
    _lastDocument = snapshot.docs.last;

    for (final doc in snapshot.docs) {
  final exists = _messages.any((m) => m.id == doc.id);

  if (!exists) {
    _messages.add(doc);
  }
}

    if (snapshot.docs.length < _pageSize) {
      _hasMoreMessages = false;
    }
  } else {
    _hasMoreMessages = false;
  }

  setState(() {
    _isLoadingMoreMessages = false;
  });
}
void _listenForNewMessages() {
  if (_chatRoomId == null) return;

  _messageSubscription?.cancel();

  _messageSubscription = _firestore
      .collection('chats')
      .doc(_chatRoomId)
      .collection('messages')
      .orderBy('timestamp', descending: true)
      .limit(_pageSize)
      .snapshots()
      .listen((snapshot) {
    if (!mounted) return;

    setState(() {
      for (final doc in snapshot.docs) {
        final exists = _messages.any((m) => m.id == doc.id);

        if (!exists) {
          _messages.add(doc);
        }
      }
      _messages.sort((a, b) {
  final ta = a.data()['timestamp'] as Timestamp?;
  final tb = b.data()['timestamp'] as Timestamp?;

if (ta == null && tb == null) return 0;
if (ta == null) return 1;
if (tb == null) return -1;

return tb.compareTo(ta);
});
    });
  });
}

  void _sendMessage() async {
    // Add these print statements at the very beginning to capture current state
    print('[_sendMessage] Attempting to send message...');
    print('[_sendMessage] Current User UID: ${_currentUser?.uid}');
    print('[_sendMessage] Chat Room ID: $_chatRoomId');
    print('[_sendMessage] Message Text: ${_messageController.text.trim()}');
    print('[_sendMessage] Chat Partner ID (receiver): ${widget.chatPartnerId}');


    if (_messageController.text.trim().isEmpty || _currentUser == null || _chatRoomId == null) {
      print('[_sendMessage] Pre-check failed: Message empty, currentUser null, or chatRoomId null. Aborting send.');
      return;
    }

    String messageText = _messageController.text.trim();
    _messageController.clear();

    try {
      // Define the message data map here to print it before sending
    final now = Timestamp.now();

final Map<String, dynamic> messageData = {
  'senderId': _currentUser!.uid,
  'receiverId': widget.chatPartnerId,
  'content': messageText,

  // Instant timestamp
  'timestamp': now,

  // Optional server timestamp
  'serverTimestamp': FieldValue.serverTimestamp(),

  'type': 'text',
  'readBy': [_currentUser!.uid],
  'delivered': false,
};
      print('[_sendMessage] Message data being added: $messageData');

      await _firestore
          .collection('chats')
          .doc(_chatRoomId)
          .collection('messages')
          .add(messageData);

      print('[_sendMessage] Message added to subcollection successfully.');

      // Update the chat document with the last message and participants
      // This part is now redundant for 'participants' because it's handled in _initializeChatRoom,
      // but keeping it for 'lastMessage' and 'lastMessageTimestamp' for convenience.
    await _firestore.collection('chats').doc(_chatRoomId).set(
  {
    'lastMessage': messageText,
    'lastMessageTimestamp': now,
    'lastMessageServerTimestamp': FieldValue.serverTimestamp(),
    'lastMessageSenderId': _currentUser!.uid,
  },
  SetOptions(merge: true),
);
      print('[_sendMessage] Chat document updated successfully (last message).');

      // _scrollController.animateTo(
      //   0.0, // Scroll to the top of the reversed list (latest message)
      //   duration: const Duration(milliseconds: 300),
      //   curve: Curves.easeOut,
      // );
      print('[_sendMessage] Scroll animation initiated.');

    } catch (e) {
      print('[_sendMessage] *** ERROR SENDING MESSAGE: $e ***'); // More prominent error log
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $e')),
      );
    }
  }

  void _markMessageAsRead(String messageId) async {
    print('[_markMessageAsRead] Attempting to mark message $messageId as read.');
    print('[_markMessageAsRead] Current User UID: ${_currentUser?.uid}');
    print('[_markMessageAsRead] Chat Room ID: $_chatRoomId');

    if (_currentUser == null || _chatRoomId == null) {
      print('[_markMessageAsRead] Pre-check failed: currentUser null or chatRoomId null. Aborting.');
      return;
    }

    try {
      await _firestore
          .collection('chats')
          .doc(_chatRoomId)
          .collection('messages')
          .doc(messageId)
          .update({
        'readBy': FieldValue.arrayUnion([_currentUser!.uid]),
      });
      print('[_markMessageAsRead] Successfully marked message $messageId as read.');
    } catch (e) {
      print('[_markMessageAsRead] Error marking message $messageId as read: $e'); // Added messageId to log
    }
  }

Widget _buildLockedConversationScreen() {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [

          const Icon(
            Icons.lock_rounded,
            size: 90,
            color: kPrimaryColor,
          ),

          const SizedBox(height: 24),

          const Text(
            'Start chatting instantly',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

         const Text(
  'This conversation is locked.\n\nEither you or the other person can unlock it using 1 contact and start chatting instantly.',
  textAlign: TextAlign.center,
  style: TextStyle(
    color: Color(0xFF64748B),
    height: 1.6,
    fontSize: 15,
  ),
),
          const SizedBox(height: 20),

Container(
  padding: const EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 12,
  ),
  decoration: BoxDecoration(
    color: const Color(
      0xFF7C3AED,
    ).withOpacity(.08),
    borderRadius:
        BorderRadius.circular(16),
  ),
  child: Text(
    'Contacts Remaining: $_remainingContacts',
    style: const TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 16,
    ),
  ),
),

          const SizedBox(height: 32),

        ElevatedButton(
  onPressed: () async {

    // NO CONTACTS

    if (_remainingContacts <= 0) {

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const PlansScreen(),
        ),
      );

      return;
    }

    final bool? confirmed =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {

        return Dialog(
  backgroundColor: Colors.transparent,
  child: Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(.08),
          blurRadius: 30,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [

        Container(
          width: 90,
          height: 90,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Color(0xFF7C3AED),
                Color(0xFFEC4899),
              ],
            ),
          ),
          child: const Icon(
            Icons.chat_bubble_rounded,
            color: Colors.white,
            size: 42,
          ),
        ),

        const SizedBox(height: 20),

        const Text(
          'Unlock Conversation',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 12),

        Text(
          _remainingContacts > 0
              ? 'You have $_remainingContacts contacts remaining.\n\nUnlock this conversation and start chatting instantly.'
              : 'You have no contacts remaining.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF64748B),
            height: 1.5,
          ),
        ),

        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: const Color(
              0xFF7C3AED,
            ).withOpacity(.08),
            borderRadius:
                BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [

              const Icon(
                Icons.local_fire_department,
                color: Color(0xFF7C3AED),
              ),

              const SizedBox(width: 8),

              Text(
                'Remaining Contacts: $_remainingContacts',
                style: const TextStyle(
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        Row(
          children: [

            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(
                    dialogContext,
                    false,
                  );
                },
                child: const Text(
                  'Cancel',
                ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(
                    dialogContext,
                    true,
                  );
                },
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(
                    0xFF7C3AED,
                  ),
                  foregroundColor:
                      Colors.white,
                ),
                child: Text(
                  _remainingContacts > 0
                      ? 'Unlock'
                      : 'Get Contacts',
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  ),
);
      },
    );

    if (confirmed != true) {
      return;
    }

final chatDoc =
    await _firestore
        .collection('chats')
        .doc(_chatRoomId)
        .get();

if (chatDoc.exists) {

  final data =
      chatDoc.data()
          as Map<String, dynamic>;

  final bool alreadyUnlocked =
      data['conversationUnlocked'] ??
          false;

  if (alreadyUnlocked) {

    debugPrint(
      'CHAT ALREADY UNLOCKED',
    );

    setState(() {

      _conversationUnlocked =
          true;
    });

    return;
  }
}
    // DEDUCT CONTACT

    await _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .update({

      'remainingContacts':
          FieldValue.increment(-1),
    });

    setState(() {

      _remainingContacts--;
    });

    // UNLOCK CHAT

    await _firestore
        .collection('chats')
        .doc(_chatRoomId)
        .update({

      'conversationUnlocked': true,

      'unlockedByUid':
          _currentUser!.uid,

      'unlockedAt':
          FieldValue.serverTimestamp(),
    });

    setState(() {

      _conversationUnlocked =
          true;
    });
    final matchQuery =
    await _firestore
        .collection('matches')
        .where(
          'chatRoomId',
          isEqualTo: _chatRoomId,
        )
        .limit(1)
        .get();

if (matchQuery.docs.isNotEmpty) {

  await matchQuery.docs.first.reference
      .update({

    'conversationUnlocked':
        true,

    'unlockedByUid':
        _currentUser!.uid,

    'unlockedAt':
        FieldValue.serverTimestamp(),
  });

  debugPrint(
    'MATCH UPDATED',
  );
}

    debugPrint(
      'CHAT UNLOCKED SUCCESSFULLY',
    );
  },

  style: ElevatedButton.styleFrom(
    backgroundColor:
        const Color(0xFF7C3AED),
    foregroundColor:
        Colors.white,
    minimumSize:
        const Size.fromHeight(56),
    shape:
        RoundedRectangleBorder(
      borderRadius:
          BorderRadius.circular(16),
    ),
  ),

  child: const Text(
    'Start Conversation',
  ),
),
        ],
      ),
    ),
  );
}
  void _markVisibleMessagesAsRead() {
    print('[_markVisibleMessagesAsRead] Checking for visible messages to mark as read...');
    print('[_markVisibleMessagesAsRead] Current User UID: ${_currentUser?.uid}');
    print('[_markVisibleMessagesAsRead] Chat Room ID: $_chatRoomId');
if (_isMarkingRead) return;

  _isMarkingRead = true;

  Future.delayed(
    const Duration(seconds: 1),
    () {
      _isMarkingRead = false;
    },
  );

    if (_chatRoomId == null || _currentUser == null) {
      print('[_markVisibleMessagesAsRead] Pre-check failed: chatRoomId null or currentUser null. Aborting.');
      return;
    }

    SchedulerBinding.instance.addPostFrameCallback((_) {
      print('[_markVisibleMessagesAsRead] Post-frame callback triggered. Fetching messages.');
      _firestore
          .collection('chats')
          .doc(_chatRoomId)
          .collection('messages')
          .where('receiverId', isEqualTo: _currentUser!.uid)
          .limit(20) // Consider increasing limit if many messages might be unread
          .get()
          .then((snapshot) {
        if (snapshot.docs.isEmpty) {
          print('[_markVisibleMessagesAsRead] No messages found for current user to mark as read.');
          return;
        }
        print('[_markVisibleMessagesAsRead] Found ${snapshot.docs.length} messages to check.');
        for (var doc in snapshot.docs) {
          final messageData = doc.data();
          final List<dynamic> readByList = (messageData['readBy'] as List<dynamic>?) ?? [];
          if (!readByList.contains(_currentUser!.uid)) {
            print('[_markVisibleMessagesAsRead] Message ${doc.id} not yet read by current user. Marking...');
            _markMessageAsRead(doc.id);
          } else {
            print('[_markVisibleMessagesAsRead] Message ${doc.id} already read by current user.');
          }
        }
      }).catchError((e) {
        print("[_markVisibleMessagesAsRead] Error fetching messages to mark as read: $e");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor, // Full page background is now white
      appBar: PreferredSize(
  preferredSize: const Size.fromHeight(80),
  child: Container(
    decoration: const BoxDecoration(
      gradient: kPrimaryGradient,
    ),
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
              ),
            ),

            GestureDetector(
  behavior: HitTestBehavior.opaque,
  onTap: _openPartnerProfile,
  child: Stack(
    children: [
      CircleAvatar(
        radius: 22,
        backgroundColor: Colors.white24,
        backgroundImage:
            widget.chatPartnerImageUrl != null &&
                    widget.chatPartnerImageUrl!.isNotEmpty
                ? NetworkImage(
                    widget.chatPartnerImageUrl!,
                  )
                : null,
        child: widget.chatPartnerImageUrl == null ||
                widget.chatPartnerImageUrl!.isEmpty
            ? Text(
                widget.chatPartnerName.isNotEmpty
                    ? widget.chatPartnerName[0].toUpperCase()
                    : 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
      ),

      Positioned(
        right: 2,
        bottom: 2,
        child: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: kOnlineColor,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
          ),
        ),
      ),
    ],
  ),
),

            const SizedBox(width: 12),

            Expanded(
  child: GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: _openPartnerProfile,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.chatPartnerName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 2),

        const Text(
          "Active now",
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    ),
  ),
),

            Container(
              width: 42,
              height: 42,
              decoration:
                  BoxDecoration(
                color: Colors.white
                    .withOpacity(.15),
                borderRadius:
                    BorderRadius
                        .circular(
                            14),
              ),
              
            ),

            const SizedBox(width: 8),

           Container(
  width: 42,
  height: 42,
  decoration: BoxDecoration(
    color: Colors.white.withOpacity(.15),
    borderRadius: BorderRadius.circular(14),
  ),
  child: ProfileActionMenu(
    userId: widget.chatPartnerId,
    profileId: '',
    onBlocked: () {
      Navigator.pop(context);
    },
  ),
),
          ],
        ),
      ),
    ),
  ),
),
      body: _isLoadingChat ||
        _checkingUnlockStatus
    ? const Center(
        child: CircularProgressIndicator(
          valueColor:
              AlwaysStoppedAnimation<Color>(
            kAccentColor,
          ),
        ),
      )
    

    : !_conversationUnlocked

        ? _buildLockedConversationScreen()

        : Stack(
            children: [
              Column(
                children: [
             Expanded(
  child: Builder(
    builder: (context) {// Explicitly typing QuerySnapshot
            
                    if (_isLoadingChat && _messages.isEmpty) {
  return const Center(
    child: CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(
        kAccentColor,
      ),
    ),
  );
}
                    if (_messages.isEmpty) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 32,
      ),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Container(
            width: 130,
            height: 130,
            decoration:
                const BoxDecoration(
              gradient:
                  kPrimaryGradient,
              shape:
                  BoxShape.circle,
            ),
            child: const Icon(
              Icons.chat_bubble_rounded,
              size: 56,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 28),

          const Text(
            "Start the Conversation",
            textAlign:
                TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight:
                  FontWeight.w800,
              color: kDarkText,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            "Say hello, introduce yourself, and start connecting with your match.",
            textAlign:
                TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: kMediumText,
            ),
          ),

          const SizedBox(height: 28),

          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(
                      100),
              border: Border.all(
                color: kBorderColor,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withOpacity(.04),
                  blurRadius: 15,
                  offset:
                      const Offset(0, 6),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                Icon(
                  Icons.waving_hand_rounded,
                  color:
                      kPrimaryColor,
                  size: 18,
                ),
                SizedBox(width: 8),
                Text(
                  "Be the first to message",
                  style: TextStyle(
                    fontWeight:
                        FontWeight.w600,
                    color:
                        kDarkText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

                    final messages = _messages;

                     return ListView.builder(
  key: const PageStorageKey('chat_messages'),
  controller: _scrollController,
  reverse: true,
  addAutomaticKeepAlives: false,
  addRepaintBoundaries: true,
  cacheExtent: 1000,
                      padding: const EdgeInsets.all(12.0),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final messageData = message.data(); // No longer casting here directly
                        final bool isMe = messageData['senderId'] == _currentUser!.uid;
                        final Timestamp? timestamp = messageData['timestamp'] as Timestamp?;
                        final List<dynamic> readBy = (messageData['readBy'] as List<dynamic>?) ?? [];
                        final bool isRead = readBy.contains(widget.chatPartnerId) && isMe;

                        String timeFormatted = '';
                        DateTime? messageDateTime;
                        if (timestamp != null) {
                          messageDateTime = timestamp.toDate();
                          timeFormatted = DateFormat('hh:mm a').format(messageDateTime);
                        }

                        bool showDateSeparator = false;
                        // Logic for date separator
                        if (index == messages.length - 1) { // Always show date for the first (oldest) message displayed
                          showDateSeparator = true;
                        } else {
                          final nextMessage = messages[index + 1]; // Use index + 1 for comparison
                          final nextTimestamp = (nextMessage.data())['timestamp'] as Timestamp?;
                          if (messageDateTime != null && nextTimestamp != null) {
                            final nextDateTime = nextTimestamp.toDate();
                            if (messageDateTime.day != nextDateTime.day ||
                                messageDateTime.month != nextDateTime.month ||
                                messageDateTime.year != nextDateTime.year) {
                              showDateSeparator = true;
                            }
                          }
                        }


                        return Column(
                          children: [
                            if (showDateSeparator && messageDateTime != null)
                              _DateSeparator(date: messageDateTime),
                            Row(
                              mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (!isMe && widget.chatPartnerImageUrl != null && widget.chatPartnerImageUrl!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0, bottom: 4.0),
                                    child: CircleAvatar(
                                      backgroundImage: NetworkImage(widget.chatPartnerImageUrl!),
                                      radius: 14,
                                      backgroundColor: Colors.white, // White background for partner's avatar
                                    ),
                                  ),
                                _MessageBubble(
                                  message: messageData['content'],
                                  time: timeFormatted,
                                  isMe: isMe,
                                  isRead: isRead,
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    );
                  
    },
                ),
              ),
              _MessageInput(
                controller: _messageController,
                onSendMessage: _sendMessage,
              ),
            ],
          ),
          if (_showScrollToBottomButton)
            Positioned(
              bottom: 80.0,
              right: 20.0,
              child: FloatingActionButton(
                onPressed: () {
                  if (_scrollController.hasClients &&
    _scrollController.offset < 150) {
  _scrollController.animateTo(
    0.0,
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeOut,
  );
}
                  setState(() {
                    _showScrollToBottomButton = false;
                  });
                },
                backgroundColor: kAccentColor.withOpacity(0.9), // Uses new kAccentColor
                mini: true,
                child: const Icon(Icons.arrow_downward_rounded, color: Colors.white),
                shape: const CircleBorder(),
                elevation: 4,
              ),
            ),
        ],
      ),
    );
  }
}

// Extracted Message Bubble Widget
class _MessageBubble extends StatelessWidget {
  final String message;
  final String time;
  final bool isMe;
  final bool isRead;

  const _MessageBubble({
    super.key,
    required this.message,
    required this.time,
    required this.isMe,
    required this.isRead,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 6,
      ),
      constraints: BoxConstraints(
        maxWidth:
            MediaQuery.of(context).size.width *
                0.78,
      ),
      decoration: BoxDecoration(
        gradient: isMe
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF7C3AED),
                  Color(0xFF9333EA),
                ],
              )
            : null,
        color: isMe
            ? null
            : Colors.white,
        borderRadius:
            BorderRadius.circular(24),
        border: !isMe
            ? Border.all(
                color: kBorderColor,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(.05),
            blurRadius: 18,
            offset:
                const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.end,
          children: [
            Text(
              message,
              style: TextStyle(
                color: isMe
                    ? Colors.white
                    : kDarkText,
                fontSize: 15,
                height: 1.4,
                fontWeight:
                    FontWeight.w500,
              ),
            ),

            const SizedBox(height: 8),

            Row(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight:
                        FontWeight.w500,
                    color: isMe
                        ? Colors.white70
                        : kMediumText,
                  ),
                ),

                if (isMe) ...[
                  const SizedBox(
                    width: 4,
                  ),

                  Icon(
                    isRead
                        ? Icons.done_all_rounded
                        : Icons.done_rounded,
                    size: 16,
                    color: isRead
                        ? kReadTickColor
                        : Colors.white70,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// New Date Separator Widget
class _DateSeparator extends StatelessWidget {
  final DateTime date;

  const _DateSeparator({
    super.key,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 16,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              color: kBorderColor,
            ),
          ),

          Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 12,
            ),
            padding:
                const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(
                      100),
              border: Border.all(
                color: kBorderColor,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withOpacity(.03),
                  blurRadius: 10,
                  offset:
                      const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              DateFormat(
                'MMMM d, y',
              ).format(date),
              style: const TextStyle(
                color: kMediumText,
                fontSize: 12,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),

          Expanded(
            child: Container(
              height: 1,
              color: kBorderColor,
            ),
          ),
        ],
      ),
    );
  }
}


// Extracted Message Input Widget
class _MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSendMessage;

  const _MessageInput({
    super.key,
    required this.controller,
    required this.onSendMessage,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          16,
          12,
          16,
          16,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 20,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.end,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: kLightGrey,
                borderRadius:
                    BorderRadius.circular(
                        16),
              ),
              child: IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Attachments coming soon",
                      ),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.add_rounded,
                  color: kPrimaryColor,
                ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Container(
                decoration:
                    BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius
                          .circular(
                              28),
                  border: Border.all(
                    color:
                        kBorderColor,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors
                          .black
                          .withOpacity(
                              .03),
                      blurRadius: 10,
                      offset:
                          const Offset(
                              0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller:
                      controller,
                  minLines: 1,
                  maxLines: 5,
                  textCapitalization:
                      TextCapitalization
                          .sentences,
                  decoration:
                      InputDecoration(
                    hintText:
                        "Type a message...",
                    hintStyle:
                        const TextStyle(
                      color:
                          kMediumText,
                    ),
                    border:
                        InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    suffixIcon:
                        IconButton(
                      onPressed: () {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Emoji picker coming soon",
                            ),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons
                            .emoji_emotions_outlined,
                        color:
                            kPrimaryColor,
                      ),
                    ),
                  ),
                  onSubmitted:
                      (_) =>
                          onSendMessage(),
                ),
              ),
            ),

            const SizedBox(width: 12),

            GestureDetector(
              onTap: onSendMessage,
              child: Container(
                width: 56,
                height: 56,
                decoration:
                    const BoxDecoration(
                  gradient:
                      kPrimaryGradient,
                  shape:
                      BoxShape.circle,
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}