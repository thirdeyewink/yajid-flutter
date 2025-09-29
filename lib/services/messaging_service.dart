import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yajid/models/chat_model.dart';
import 'package:yajid/models/message_model.dart';
import 'package:yajid/models/user_model.dart';
import 'package:yajid/services/logging_service.dart';

class MessagingService {
  static final MessagingService _instance = MessagingService._internal();
  factory MessagingService() => _instance;
  MessagingService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collections
  String get _usersCollection => 'users';
  String get _chatsCollection => 'chats';
  String get _messagesCollection => 'messages';

  // Current user
  User? get currentUser => _auth.currentUser;
  String? get currentUserId => currentUser?.uid;

  // Initialize user in Firestore
  Future<void> initializeUser() async {
    if (currentUser == null) return;

    final userDoc = _firestore.collection(_usersCollection).doc(currentUser!.uid);
    final userSnapshot = await userDoc.get();

    if (!userSnapshot.exists) {
      final userModel = UserModel(
        uid: currentUser!.uid,
        displayName: currentUser!.displayName ?? 'User',
        email: currentUser!.email ?? '',
        photoURL: currentUser!.photoURL,
        isOnline: true,
        lastSeen: DateTime.now(),
      );

      await userDoc.set(userModel.toMap());
    } else {
      // Update online status
      await userDoc.update({
        'isOnline': true,
        'lastSeen': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }

  // Update user presence
  Future<void> updateUserPresence(bool isOnline) async {
    if (currentUserId == null) return;

    await _firestore.collection(_usersCollection).doc(currentUserId).update({
      'isOnline': isOnline,
      'lastSeen': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection(_usersCollection).doc(userId).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
    } catch (e) {
      logger.error('Error getting user', e);
    }
    return null;
  }

  // Search users by name or email
  Stream<List<UserModel>> searchUsers(String query) {
    if (query.isEmpty) {
      return Stream.value([]);
    }

    return _firestore
        .collection(_usersCollection)
        .where('displayName', isGreaterThanOrEqualTo: query)
        .where('displayName', isLessThanOrEqualTo: '$query\uf8ff')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromMap(doc.data()))
            .where((user) => user.uid != currentUserId)
            .toList());
  }

  // Create or get existing chat
  Future<String?> createOrGetChat(String otherUserId) async {
    if (currentUserId == null) return null;

    try {
      // Check if chat already exists
      final existingChat = await _firestore
          .collection(_chatsCollection)
          .where('participants', arrayContains: currentUserId)
          .get();

      for (var doc in existingChat.docs) {
        final chat = ChatModel.fromMap(doc.data());
        if (chat.participants.contains(otherUserId)) {
          return chat.id;
        }
      }

      // Create new chat
      final otherUser = await getUserById(otherUserId);
      if (otherUser == null) return null;

      final chatId = _firestore.collection(_chatsCollection).doc().id;
      final now = DateTime.now();

      final chat = ChatModel(
        id: chatId,
        participants: [currentUserId!, otherUserId],
        participantNames: {
          currentUserId!: currentUser!.displayName ?? 'User',
          otherUserId: otherUser.displayName,
        },
        unreadCount: {
          currentUserId!: 0,
          otherUserId: 0,
        },
        createdAt: now,
        updatedAt: now,
      );

      await _firestore.collection(_chatsCollection).doc(chatId).set(chat.toMap());
      return chatId;
    } catch (e) {
      logger.error('Error creating chat', e);
      return null;
    }
  }

  // Get user's chats
  Stream<List<ChatModel>> getUserChats() {
    if (currentUserId == null) return Stream.value([]);

    return _firestore
        .collection(_chatsCollection)
        .where('participants', arrayContains: currentUserId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatModel.fromMap(doc.data()))
            .toList());
  }

  // Send message
  Future<bool> sendMessage({
    required String chatId,
    required String content,
    MessageType type = MessageType.text,
    String? imageUrl,
    String? audioUrl,
    String? fileName,
  }) async {
    if (currentUserId == null) return false;

    try {
      final messageId = _firestore.collection(_messagesCollection).doc().id;
      final now = DateTime.now();

      final message = MessageModel(
        id: messageId,
        chatId: chatId,
        senderId: currentUserId!,
        senderName: currentUser!.displayName ?? 'User',
        content: content,
        type: type,
        timestamp: now,
        isRead: false,
        imageUrl: imageUrl,
        audioUrl: audioUrl,
        fileName: fileName,
      );

      // Add message to collection
      await _firestore.collection(_messagesCollection).doc(messageId).set(message.toMap());

      // Update chat with last message info
      final chatDoc = await _firestore.collection(_chatsCollection).doc(chatId).get();
      if (chatDoc.exists) {
        final chat = ChatModel.fromMap(chatDoc.data()!);
        final updatedUnreadCount = Map<String, int>.from(chat.unreadCount);

        // Increment unread count for other participants
        for (String participantId in chat.participants) {
          if (participantId != currentUserId) {
            updatedUnreadCount[participantId] = (updatedUnreadCount[participantId] ?? 0) + 1;
          }
        }

        await _firestore.collection(_chatsCollection).doc(chatId).update({
          'lastMessage': content,
          'lastSenderId': currentUserId,
          'lastSenderName': currentUser!.displayName ?? 'User',
          'lastMessageTime': now.millisecondsSinceEpoch,
          'unreadCount': updatedUnreadCount,
          'updatedAt': now.millisecondsSinceEpoch,
        });
      }

      return true;
    } catch (e) {
      logger.error('Error sending message', e);
      return false;
    }
  }

  // Get messages for a chat
  Stream<List<MessageModel>> getChatMessages(String chatId) {
    return _firestore
        .collection(_messagesCollection)
        .where('chatId', isEqualTo: chatId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromMap(doc.data()))
            .toList());
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String chatId) async {
    if (currentUserId == null) return;

    try {
      // Get unread messages from other users in this chat
      final unreadMessages = await _firestore
          .collection(_messagesCollection)
          .where('chatId', isEqualTo: chatId)
          .where('senderId', isNotEqualTo: currentUserId)
          .where('isRead', isEqualTo: false)
          .get();

      // Update messages as read
      final batch = _firestore.batch();
      for (var doc in unreadMessages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();

      // Reset unread count for current user in chat
      await _firestore.collection(_chatsCollection).doc(chatId).update({
        'unreadCount.$currentUserId': 0,
      });
    } catch (e) {
      logger.error('Error marking messages as read', e);
    }
  }

  // Delete message
  Future<bool> deleteMessage(String messageId) async {
    try {
      await _firestore.collection(_messagesCollection).doc(messageId).delete();
      return true;
    } catch (e) {
      logger.error('Error deleting message', e);
      return false;
    }
  }

  // Delete chat
  Future<bool> deleteChat(String chatId) async {
    try {
      // Delete all messages in the chat
      final messages = await _firestore
          .collection(_messagesCollection)
          .where('chatId', isEqualTo: chatId)
          .get();

      final batch = _firestore.batch();
      for (var doc in messages.docs) {
        batch.delete(doc.reference);
      }

      // Delete the chat
      batch.delete(_firestore.collection(_chatsCollection).doc(chatId));
      await batch.commit();

      return true;
    } catch (e) {
      logger.error('Error deleting chat', e);
      return false;
    }
  }

  // Cleanup on logout
  Future<void> cleanup() async {
    await updateUserPresence(false);
  }
}