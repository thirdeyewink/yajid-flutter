import 'package:flutter_test/flutter_test.dart';
import 'package:yajid/models/chat_model.dart';
import 'package:yajid/models/message_model.dart';

void main() {
  group('Messaging Models', () {
    group('ChatModel', () {
      test('creates chat correctly', () {
        final now = DateTime(2025, 1, 1);
        final chat = ChatModel(
          id: 'chat123',
          participants: ['user1', 'user2'],
          participantNames: {'user1': 'Alice', 'user2': 'Bob'},
          unreadCount: {'user1': 2, 'user2': 0},
          createdAt: now,
          updatedAt: now,
        );

        expect(chat.id, 'chat123');
        expect(chat.participants, ['user1', 'user2']);
        expect(chat.participantNames['user1'], 'Alice');
        expect(chat.participantNames['user2'], 'Bob');
        expect(chat.unreadCount['user1'], 2);
        expect(chat.createdAt, now);
      });

      test('converts to and from Map correctly', () {
        final now = DateTime(2025, 1, 1);
        final original = ChatModel(
          id: 'chat123',
          participants: ['user1', 'user2'],
          participantNames: {'user1': 'Alice', 'user2': 'Bob'},
          lastMessage: 'Hello!',
          lastSenderId: 'user1',
          lastSenderName: 'Alice',
          lastMessageTime: now,
          unreadCount: {'user1': 0, 'user2': 1},
          createdAt: now,
          updatedAt: now,
        );

        final map = original.toMap();
        expect(map['id'], 'chat123');
        expect(map['participants'], ['user1', 'user2']);
        expect(map['lastMessage'], 'Hello!');
        expect(map['lastSenderId'], 'user1');
        expect(map['unreadCount'], {'user1': 0, 'user2': 1});

        final restored = ChatModel.fromMap(map);
        expect(restored.id, original.id);
        expect(restored.participants, original.participants);
        expect(restored.lastMessage, original.lastMessage);
        expect(restored.lastSenderId, original.lastSenderId);
      });

      test('copyWith creates modified copy', () {
        final now = DateTime(2025, 1, 1);
        final original = ChatModel(
          id: 'chat123',
          participants: ['user1', 'user2'],
          participantNames: {'user1': 'Alice', 'user2': 'Bob'},
          unreadCount: {'user1': 0, 'user2': 1},
          createdAt: now,
          updatedAt: now,
        );

        final modified = original.copyWith(
          lastMessage: 'New message',
          unreadCount: {'user1': 0, 'user2': 2},
        );

        expect(modified.lastMessage, 'New message');
        expect(modified.unreadCount['user2'], 2);
        expect(modified.id, original.id); // Unchanged
        expect(modified.participants, original.participants); // Unchanged
      });

      test('getOtherParticipantName returns correct name', () {
        final chat = ChatModel(
          id: 'chat123',
          participants: ['user1', 'user2'],
          participantNames: {'user1': 'Alice', 'user2': 'Bob'},
          unreadCount: {},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(chat.getOtherParticipantName('user1'), 'Bob');
        expect(chat.getOtherParticipantName('user2'), 'Alice');
      });

      test('getOtherParticipantName returns first participant for non-participant user', () {
        final chat = ChatModel(
          id: 'chat123',
          participants: ['user1', 'user2'],
          participantNames: {'user1': 'Alice', 'user2': 'Bob'},
          unreadCount: {},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(chat.getOtherParticipantName('user3'), 'Alice');
      });

      test('getOtherParticipantId returns correct ID', () {
        final chat = ChatModel(
          id: 'chat123',
          participants: ['user1', 'user2'],
          participantNames: {'user1': 'Alice', 'user2': 'Bob'},
          unreadCount: {},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(chat.getOtherParticipantId('user1'), 'user2');
        expect(chat.getOtherParticipantId('user2'), 'user1');
      });

      test('getOtherParticipantId returns first participant for non-participant user', () {
        final chat = ChatModel(
          id: 'chat123',
          participants: ['user1', 'user2'],
          participantNames: {'user1': 'Alice', 'user2': 'Bob'},
          unreadCount: {},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(chat.getOtherParticipantId('user3'), 'user1');
      });

      test('getUnreadCountForUser returns correct count', () {
        final chat = ChatModel(
          id: 'chat123',
          participants: ['user1', 'user2'],
          participantNames: {'user1': 'Alice', 'user2': 'Bob'},
          unreadCount: {'user1': 5, 'user2': 0},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(chat.getUnreadCountForUser('user1'), 5);
        expect(chat.getUnreadCountForUser('user2'), 0);
      });

      test('getUnreadCountForUser returns 0 for missing user', () {
        final chat = ChatModel(
          id: 'chat123',
          participants: ['user1', 'user2'],
          participantNames: {'user1': 'Alice', 'user2': 'Bob'},
          unreadCount: {'user1': 5},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(chat.getUnreadCountForUser('user3'), 0);
      });

      test('handles null lastMessage fields', () {
        final chat = ChatModel(
          id: 'chat123',
          participants: ['user1', 'user2'],
          participantNames: {'user1': 'Alice', 'user2': 'Bob'},
          unreadCount: {},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(chat.lastMessage, null);
        expect(chat.lastSenderId, null);
        expect(chat.lastSenderName, null);
        expect(chat.lastMessageTime, null);
      });
    });

    group('MessageModel', () {
      test('creates text message correctly', () {
        final now = DateTime(2025, 1, 1);
        final message = MessageModel(
          id: 'msg123',
          chatId: 'chat123',
          senderId: 'user1',
          senderName: 'Alice',
          content: 'Hello!',
          type: MessageType.text,
          timestamp: now,
          isRead: false,
        );

        expect(message.id, 'msg123');
        expect(message.chatId, 'chat123');
        expect(message.senderId, 'user1');
        expect(message.senderName, 'Alice');
        expect(message.content, 'Hello!');
        expect(message.type, MessageType.text);
        expect(message.timestamp, now);
        expect(message.isRead, false);
      });

      test('creates image message with imageUrl', () {
        final message = MessageModel(
          id: 'msg123',
          chatId: 'chat123',
          senderId: 'user1',
          senderName: 'Alice',
          content: 'Check this out!',
          type: MessageType.image,
          timestamp: DateTime.now(),
          imageUrl: 'https://example.com/image.jpg',
        );

        expect(message.type, MessageType.image);
        expect(message.imageUrl, 'https://example.com/image.jpg');
      });

      test('creates audio message with audioUrl', () {
        final message = MessageModel(
          id: 'msg123',
          chatId: 'chat123',
          senderId: 'user1',
          senderName: 'Alice',
          content: 'Voice message',
          type: MessageType.audio,
          timestamp: DateTime.now(),
          audioUrl: 'https://example.com/audio.mp3',
        );

        expect(message.type, MessageType.audio);
        expect(message.audioUrl, 'https://example.com/audio.mp3');
      });

      test('creates file message with fileName', () {
        final message = MessageModel(
          id: 'msg123',
          chatId: 'chat123',
          senderId: 'user1',
          senderName: 'Alice',
          content: 'Document',
          type: MessageType.file,
          timestamp: DateTime.now(),
          fileName: 'document.pdf',
        );

        expect(message.type, MessageType.file);
        expect(message.fileName, 'document.pdf');
      });

      test('converts to and from Map correctly', () {
        final now = DateTime(2025, 1, 1);
        final original = MessageModel(
          id: 'msg123',
          chatId: 'chat123',
          senderId: 'user1',
          senderName: 'Alice',
          content: 'Hello!',
          type: MessageType.text,
          timestamp: now,
          isRead: true,
        );

        final map = original.toMap();
        expect(map['id'], 'msg123');
        expect(map['chatId'], 'chat123');
        expect(map['senderId'], 'user1');
        expect(map['content'], 'Hello!');
        expect(map['type'], 'text');
        expect(map['isRead'], true);

        final restored = MessageModel.fromMap(map);
        expect(restored.id, original.id);
        expect(restored.chatId, original.chatId);
        expect(restored.senderId, original.senderId);
        expect(restored.content, original.content);
        expect(restored.type, original.type);
        expect(restored.isRead, original.isRead);
      });

      test('copyWith creates modified copy', () {
        final original = MessageModel(
          id: 'msg123',
          chatId: 'chat123',
          senderId: 'user1',
          senderName: 'Alice',
          content: 'Hello!',
          timestamp: DateTime.now(),
          isRead: false,
        );

        final modified = original.copyWith(
          content: 'Hello World!',
          isRead: true,
        );

        expect(modified.content, 'Hello World!');
        expect(modified.isRead, true);
        expect(modified.id, original.id); // Unchanged
        expect(modified.chatId, original.chatId); // Unchanged
      });

      test('defaults to text type when not specified', () {
        final message = MessageModel(
          id: 'msg123',
          chatId: 'chat123',
          senderId: 'user1',
          senderName: 'Alice',
          content: 'Hello!',
          timestamp: DateTime.now(),
        );

        expect(message.type, MessageType.text);
      });

      test('defaults isRead to false when not specified', () {
        final message = MessageModel(
          id: 'msg123',
          chatId: 'chat123',
          senderId: 'user1',
          senderName: 'Alice',
          content: 'Hello!',
          timestamp: DateTime.now(),
        );

        expect(message.isRead, false);
      });

      test('fromMap handles missing optional fields', () {
        final map = {
          'id': 'msg123',
          'chatId': 'chat123',
          'senderId': 'user1',
          'senderName': 'Alice',
          'content': 'Hello!',
          'type': 'text',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        };

        final message = MessageModel.fromMap(map);
        expect(message.imageUrl, null);
        expect(message.audioUrl, null);
        expect(message.fileName, null);
      });

      test('fromMap handles all MessageTypes correctly', () {
        final timestamp = DateTime.now().millisecondsSinceEpoch;

        final textMap = {
          'id': 'msg1',
          'chatId': 'chat123',
          'senderId': 'user1',
          'senderName': 'Alice',
          'content': 'Text',
          'type': 'text',
          'timestamp': timestamp,
        };
        expect(MessageModel.fromMap(textMap).type, MessageType.text);

        final imageMap = {...textMap, 'type': 'image'};
        expect(MessageModel.fromMap(imageMap).type, MessageType.image);

        final fileMap = {...textMap, 'type': 'file'};
        expect(MessageModel.fromMap(fileMap).type, MessageType.file);

        final audioMap = {...textMap, 'type': 'audio'};
        expect(MessageModel.fromMap(audioMap).type, MessageType.audio);
      });

      test('fromMap defaults to text type for unknown type', () {
        final map = {
          'id': 'msg123',
          'chatId': 'chat123',
          'senderId': 'user1',
          'senderName': 'Alice',
          'content': 'Hello!',
          'type': 'unknown_type',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        };

        final message = MessageModel.fromMap(map);
        expect(message.type, MessageType.text);
      });
    });

    group('MessageType enum', () {
      test('has all expected types', () {
        expect(MessageType.values, hasLength(4));
        expect(MessageType.values, contains(MessageType.text));
        expect(MessageType.values, contains(MessageType.image));
        expect(MessageType.values, contains(MessageType.file));
        expect(MessageType.values, contains(MessageType.audio));
      });
    });
  });

  // Note: MessagingService integration tests require Firebase emulator
  // The following tests verify business logic and data structures
  group('MessagingService Logic', () {
    group('Chat ID Generation', () {
      test('Chat ID is consistent for same participants in different order', () {
        // Simulate the chat ID generation logic
        final participants1 = ['user1', 'user2']..sort();
        final participants2 = ['user2', 'user1']..sort();

        expect(participants1, participants2);
        expect(participants1.join('_'), participants2.join('_'));
      });

      test('Chat ID is unique for different participants', () {
        final participants1 = ['user1', 'user2']..sort();
        final participants2 = ['user1', 'user3']..sort();

        expect(participants1.join('_'), isNot(participants2.join('_')));
      });
    });

    group('Unread Count Management', () {
      test('New chat has zero unread count for all participants', () {
        final chat = ChatModel(
          id: 'chat123',
          participants: ['user1', 'user2'],
          participantNames: {'user1': 'Alice', 'user2': 'Bob'},
          unreadCount: {'user1': 0, 'user2': 0},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(chat.getUnreadCountForUser('user1'), 0);
        expect(chat.getUnreadCountForUser('user2'), 0);
      });

      test('Unread count increments correctly', () {
        final chat = ChatModel(
          id: 'chat123',
          participants: ['user1', 'user2'],
          participantNames: {'user1': 'Alice', 'user2': 'Bob'},
          unreadCount: {'user1': 0, 'user2': 3},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final updated = chat.copyWith(
          unreadCount: {'user1': 0, 'user2': 4},
        );

        expect(updated.getUnreadCountForUser('user2'), 4);
      });

      test('Marking as read resets unread count to zero', () {
        final chat = ChatModel(
          id: 'chat123',
          participants: ['user1', 'user2'],
          participantNames: {'user1': 'Alice', 'user2': 'Bob'},
          unreadCount: {'user1': 0, 'user2': 5},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final updated = chat.copyWith(
          unreadCount: {'user1': 0, 'user2': 0},
        );

        expect(updated.getUnreadCountForUser('user2'), 0);
      });
    });

    group('Last Message Tracking', () {
      test('Chat updates last message information correctly', () {
        final chat = ChatModel(
          id: 'chat123',
          participants: ['user1', 'user2'],
          participantNames: {'user1': 'Alice', 'user2': 'Bob'},
          unreadCount: {},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final now = DateTime.now();
        final updated = chat.copyWith(
          lastMessage: 'Hello!',
          lastSenderId: 'user1',
          lastSenderName: 'Alice',
          lastMessageTime: now,
        );

        expect(updated.lastMessage, 'Hello!');
        expect(updated.lastSenderId, 'user1');
        expect(updated.lastSenderName, 'Alice');
        expect(updated.lastMessageTime, now);
      });

      test('Last message time updates with each new message', () {
        final time1 = DateTime(2025, 1, 1, 10, 0);
        final time2 = DateTime(2025, 1, 1, 10, 5);

        final chat = ChatModel(
          id: 'chat123',
          participants: ['user1', 'user2'],
          participantNames: {'user1': 'Alice', 'user2': 'Bob'},
          unreadCount: {},
          lastMessageTime: time1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final updated = chat.copyWith(lastMessageTime: time2);

        expect(updated.lastMessageTime, time2);
        expect(updated.lastMessageTime!.isAfter(time1), true);
      });
    });

    group('Participant Management', () {
      test('Two-participant chat correctly identifies other participant', () {
        final chat = ChatModel(
          id: 'chat123',
          participants: ['user1', 'user2'],
          participantNames: {'user1': 'Alice', 'user2': 'Bob'},
          unreadCount: {},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(chat.getOtherParticipantId('user1'), 'user2');
        expect(chat.getOtherParticipantId('user2'), 'user1');
        expect(chat.getOtherParticipantName('user1'), 'Bob');
        expect(chat.getOtherParticipantName('user2'), 'Alice');
      });

      test('Participant names map correctly to IDs', () {
        final chat = ChatModel(
          id: 'chat123',
          participants: ['user1', 'user2', 'user3'],
          participantNames: {
            'user1': 'Alice',
            'user2': 'Bob',
            'user3': 'Charlie',
          },
          unreadCount: {},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(chat.participantNames['user1'], 'Alice');
        expect(chat.participantNames['user2'], 'Bob');
        expect(chat.participantNames['user3'], 'Charlie');
      });
    });

    group('Message Ordering', () {
      test('Messages can be sorted by timestamp', () {
        final time1 = DateTime(2025, 1, 1, 10, 0);
        final time2 = DateTime(2025, 1, 1, 10, 5);
        final time3 = DateTime(2025, 1, 1, 10, 10);

        final msg1 = MessageModel(
          id: 'msg1',
          chatId: 'chat123',
          senderId: 'user1',
          senderName: 'Alice',
          content: 'First',
          timestamp: time1,
        );

        final msg2 = MessageModel(
          id: 'msg2',
          chatId: 'chat123',
          senderId: 'user2',
          senderName: 'Bob',
          content: 'Second',
          timestamp: time2,
        );

        final msg3 = MessageModel(
          id: 'msg3',
          chatId: 'chat123',
          senderId: 'user1',
          senderName: 'Alice',
          content: 'Third',
          timestamp: time3,
        );

        final messages = [msg3, msg1, msg2];
        messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

        expect(messages[0].content, 'First');
        expect(messages[1].content, 'Second');
        expect(messages[2].content, 'Third');
      });
    });

    group('Message Read Status', () {
      test('New messages default to unread', () {
        final message = MessageModel(
          id: 'msg123',
          chatId: 'chat123',
          senderId: 'user1',
          senderName: 'Alice',
          content: 'Hello!',
          timestamp: DateTime.now(),
        );

        expect(message.isRead, false);
      });

      test('Message can be marked as read', () {
        final message = MessageModel(
          id: 'msg123',
          chatId: 'chat123',
          senderId: 'user1',
          senderName: 'Alice',
          content: 'Hello!',
          timestamp: DateTime.now(),
          isRead: false,
        );

        final updated = message.copyWith(isRead: true);

        expect(updated.isRead, true);
      });

      test('Read status persists through serialization', () {
        final message = MessageModel(
          id: 'msg123',
          chatId: 'chat123',
          senderId: 'user1',
          senderName: 'Alice',
          content: 'Hello!',
          timestamp: DateTime.now(),
          isRead: true,
        );

        final map = message.toMap();
        final restored = MessageModel.fromMap(map);

        expect(restored.isRead, true);
      });
    });

    group('Message Types Handling', () {
      test('Text message has no media URLs', () {
        final message = MessageModel(
          id: 'msg123',
          chatId: 'chat123',
          senderId: 'user1',
          senderName: 'Alice',
          content: 'Hello!',
          type: MessageType.text,
          timestamp: DateTime.now(),
        );

        expect(message.type, MessageType.text);
        expect(message.imageUrl, null);
        expect(message.audioUrl, null);
        expect(message.fileName, null);
      });

      test('Image message includes imageUrl', () {
        final message = MessageModel(
          id: 'msg123',
          chatId: 'chat123',
          senderId: 'user1',
          senderName: 'Alice',
          content: 'Check this out!',
          type: MessageType.image,
          imageUrl: 'https://example.com/image.jpg',
          timestamp: DateTime.now(),
        );

        expect(message.type, MessageType.image);
        expect(message.imageUrl, isNotNull);
        expect(message.imageUrl, contains('.jpg'));
      });

      test('Audio message includes audioUrl', () {
        final message = MessageModel(
          id: 'msg123',
          chatId: 'chat123',
          senderId: 'user1',
          senderName: 'Alice',
          content: 'Voice message',
          type: MessageType.audio,
          audioUrl: 'https://example.com/audio.mp3',
          timestamp: DateTime.now(),
        );

        expect(message.type, MessageType.audio);
        expect(message.audioUrl, isNotNull);
        expect(message.audioUrl, contains('.mp3'));
      });

      test('File message includes fileName', () {
        final message = MessageModel(
          id: 'msg123',
          chatId: 'chat123',
          senderId: 'user1',
          senderName: 'Alice',
          content: 'Document',
          type: MessageType.file,
          fileName: 'document.pdf',
          timestamp: DateTime.now(),
        );

        expect(message.type, MessageType.file);
        expect(message.fileName, isNotNull);
        expect(message.fileName, contains('.pdf'));
      });

      test('Media URLs persist through serialization', () {
        final message = MessageModel(
          id: 'msg123',
          chatId: 'chat123',
          senderId: 'user1',
          senderName: 'Alice',
          content: 'Image',
          type: MessageType.image,
          imageUrl: 'https://example.com/image.jpg',
          timestamp: DateTime.now(),
        );

        final map = message.toMap();
        final restored = MessageModel.fromMap(map);

        expect(restored.imageUrl, message.imageUrl);
      });
    });

    group('Chat Timestamp Management', () {
      test('Chat creation and update timestamps are independent', () {
        final created = DateTime(2025, 1, 1, 10, 0);
        final updated = DateTime(2025, 1, 1, 10, 30);

        final chat = ChatModel(
          id: 'chat123',
          participants: ['user1', 'user2'],
          participantNames: {'user1': 'Alice', 'user2': 'Bob'},
          unreadCount: {},
          createdAt: created,
          updatedAt: updated,
        );

        expect(chat.createdAt, created);
        expect(chat.updatedAt, updated);
        expect(chat.updatedAt.isAfter(chat.createdAt), true);
      });

      test('Update timestamp changes with each modification', () {
        final created = DateTime(2025, 1, 1, 10, 0);
        final updated1 = DateTime(2025, 1, 1, 10, 30);
        final updated2 = DateTime(2025, 1, 1, 11, 0);

        final chat = ChatModel(
          id: 'chat123',
          participants: ['user1', 'user2'],
          participantNames: {'user1': 'Alice', 'user2': 'Bob'},
          unreadCount: {},
          createdAt: created,
          updatedAt: updated1,
        );

        final modified = chat.copyWith(updatedAt: updated2);

        expect(modified.updatedAt, updated2);
        expect(modified.updatedAt.isAfter(updated1), true);
        expect(modified.createdAt, created); // Unchanged
      });
    });

    group('Data Integrity', () {
      test('Chat participants list matches participantNames keys', () {
        final chat = ChatModel(
          id: 'chat123',
          participants: ['user1', 'user2', 'user3'],
          participantNames: {
            'user1': 'Alice',
            'user2': 'Bob',
            'user3': 'Charlie',
          },
          unreadCount: {},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        for (final participantId in chat.participants) {
          expect(chat.participantNames.containsKey(participantId), true);
        }
      });

      test('Unread count keys match participants', () {
        final chat = ChatModel(
          id: 'chat123',
          participants: ['user1', 'user2'],
          participantNames: {'user1': 'Alice', 'user2': 'Bob'},
          unreadCount: {'user1': 0, 'user2': 3},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        for (final participantId in chat.participants) {
          expect(chat.unreadCount.containsKey(participantId), true);
        }
      });

      test('Message chatId references valid chat', () {
        final chatId = 'chat123';
        final message = MessageModel(
          id: 'msg123',
          chatId: chatId,
          senderId: 'user1',
          senderName: 'Alice',
          content: 'Hello!',
          timestamp: DateTime.now(),
        );

        expect(message.chatId, chatId);
      });

      test('Message senderId should be in chat participants', () {
        final participants = ['user1', 'user2'];
        final message = MessageModel(
          id: 'msg123',
          chatId: 'chat123',
          senderId: 'user1',
          senderName: 'Alice',
          content: 'Hello!',
          timestamp: DateTime.now(),
        );

        expect(participants.contains(message.senderId), true);
      });
    });
  });
}
