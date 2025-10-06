import 'package:flutter_test/flutter_test.dart';
import 'package:yajid/models/chat_model.dart';

void main() {
  group('ChatModel', () {
    group('Model Creation', () {
      test('creates chat with all fields', () {
        final now = DateTime.now();
        final chat = ChatModel(
          id: 'chat123',
          participants: ['user1', 'user2'],
          participantNames: {'user1': 'Alice', 'user2': 'Bob'},
          lastMessage: 'Hello there!',
          lastSenderId: 'user1',
          lastSenderName: 'Alice',
          lastMessageTime: now,
          unreadCount: {'user1': 0, 'user2': 3},
          createdAt: now,
          updatedAt: now,
        );

        expect(chat.id, 'chat123');
        expect(chat.participants, ['user1', 'user2']);
        expect(chat.participantNames, {'user1': 'Alice', 'user2': 'Bob'});
        expect(chat.lastMessage, 'Hello there!');
        expect(chat.lastSenderId, 'user1');
        expect(chat.lastSenderName, 'Alice');
        expect(chat.lastMessageTime, now);
        expect(chat.unreadCount, {'user1': 0, 'user2': 3});
        expect(chat.createdAt, now);
        expect(chat.updatedAt, now);
      });

      test('creates chat with minimal fields', () {
        final now = DateTime.now();
        final chat = ChatModel(
          id: 'chat123',
          participants: ['user1', 'user2'],
          participantNames: {'user1': 'Alice', 'user2': 'Bob'},
          unreadCount: {},
          createdAt: now,
          updatedAt: now,
        );

        expect(chat.id, 'chat123');
        expect(chat.participants, ['user1', 'user2']);
        expect(chat.lastMessage, null);
        expect(chat.lastSenderId, null);
        expect(chat.lastSenderName, null);
        expect(chat.lastMessageTime, null);
        expect(chat.unreadCount, {});
      });

      test('handles multiple participants', () {
        final now = DateTime.now();
        final chat = ChatModel(
          id: 'group123',
          participants: ['user1', 'user2', 'user3', 'user4'],
          participantNames: {
            'user1': 'Alice',
            'user2': 'Bob',
            'user3': 'Charlie',
            'user4': 'Diana'
          },
          unreadCount: {},
          createdAt: now,
          updatedAt: now,
        );

        expect(chat.participants.length, 4);
        expect(chat.participantNames.length, 4);
        expect(chat.participantNames['user3'], 'Charlie');
      });

      test('handles empty unread count map', () {
        final now = DateTime.now();
        final chat = ChatModel(
          id: 'chat123',
          participants: ['user1', 'user2'],
          participantNames: {'user1': 'Alice', 'user2': 'Bob'},
          unreadCount: {},
          createdAt: now,
          updatedAt: now,
        );

        expect(chat.unreadCount, isEmpty);
      });

      test('handles non-zero unread counts', () {
        final now = DateTime.now();
        final chat = ChatModel(
          id: 'chat123',
          participants: ['user1', 'user2'],
          participantNames: {'user1': 'Alice', 'user2': 'Bob'},
          unreadCount: {'user1': 0, 'user2': 5},
          createdAt: now,
          updatedAt: now,
        );

        expect(chat.unreadCount['user1'], 0);
        expect(chat.unreadCount['user2'], 5);
      });
    });

    group('Serialization', () {
      test('converts to Map correctly', () {
        final now = DateTime(2025, 6, 15, 10, 30);
        final chat = ChatModel(
          id: 'chat123',
          participants: ['user1', 'user2'],
          participantNames: {'user1': 'Alice', 'user2': 'Bob'},
          lastMessage: 'Test message',
          lastSenderId: 'user1',
          lastSenderName: 'Alice',
          lastMessageTime: now,
          unreadCount: {'user1': 0, 'user2': 2},
          createdAt: now,
          updatedAt: now,
        );

        final map = chat.toMap();

        expect(map['id'], 'chat123');
        expect(map['participants'], ['user1', 'user2']);
        expect(map['participantNames'], {'user1': 'Alice', 'user2': 'Bob'});
        expect(map['lastMessage'], 'Test message');
        expect(map['lastSenderId'], 'user1');
        expect(map['lastSenderName'], 'Alice');
        expect(map['lastMessageTime'], now.millisecondsSinceEpoch);
        expect(map['unreadCount'], {'user1': 0, 'user2': 2});
        expect(map['createdAt'], now.millisecondsSinceEpoch);
        expect(map['updatedAt'], now.millisecondsSinceEpoch);
      });

      test('converts from Map correctly', () {
        final now = DateTime(2025, 6, 15, 10, 30);
        final map = {
          'id': 'chat123',
          'participants': ['user1', 'user2'],
          'participantNames': {'user1': 'Alice', 'user2': 'Bob'},
          'lastMessage': 'Test message',
          'lastSenderId': 'user1',
          'lastSenderName': 'Alice',
          'lastMessageTime': now.millisecondsSinceEpoch,
          'unreadCount': {'user1': 0, 'user2': 2},
          'createdAt': now.millisecondsSinceEpoch,
          'updatedAt': now.millisecondsSinceEpoch,
        };

        final chat = ChatModel.fromMap(map);

        expect(chat.id, 'chat123');
        expect(chat.participants, ['user1', 'user2']);
        expect(chat.participantNames, {'user1': 'Alice', 'user2': 'Bob'});
        expect(chat.lastMessage, 'Test message');
        expect(chat.lastSenderId, 'user1');
        expect(chat.lastSenderName, 'Alice');
        expect(chat.lastMessageTime, now);
        expect(chat.unreadCount, {'user1': 0, 'user2': 2});
        expect(chat.createdAt, now);
        expect(chat.updatedAt, now);
      });

      test('handles missing optional fields in fromMap', () {
        final now = DateTime(2025, 6, 15);
        final map = {
          'id': 'chat123',
          'participants': ['user1', 'user2'],
          'participantNames': {'user1': 'Alice', 'user2': 'Bob'},
          'createdAt': now.millisecondsSinceEpoch,
          'updatedAt': now.millisecondsSinceEpoch,
        };

        final chat = ChatModel.fromMap(map);

        expect(chat.lastMessage, null);
        expect(chat.lastSenderId, null);
        expect(chat.lastSenderName, null);
        expect(chat.lastMessageTime, null);
        expect(chat.unreadCount, {});
      });

      test('roundtrip serialization preserves data', () {
        final now = DateTime.now();
        final original = ChatModel(
          id: 'chat123',
          participants: ['user1', 'user2'],
          participantNames: {'user1': 'Alice', 'user2': 'Bob'},
          lastMessage: 'Hello',
          lastSenderId: 'user1',
          lastSenderName: 'Alice',
          lastMessageTime: now,
          unreadCount: {'user1': 0, 'user2': 1},
          createdAt: now,
          updatedAt: now,
        );

        final map = original.toMap();
        final restored = ChatModel.fromMap(map);

        expect(restored.id, original.id);
        expect(restored.participants, original.participants);
        expect(restored.participantNames, original.participantNames);
        expect(restored.lastMessage, original.lastMessage);
        expect(restored.lastSenderId, original.lastSenderId);
        expect(restored.unreadCount, original.unreadCount);
      });
    });

    group('copyWith', () {
      test('creates copy with modified fields', () {
        final now = DateTime.now();
        final later = now.add(const Duration(hours: 1));
        final original = ChatModel(
          id: 'chat123',
          participants: ['user1', 'user2'],
          participantNames: {'user1': 'Alice', 'user2': 'Bob'},
          lastMessage: 'Original message',
          unreadCount: {'user1': 0, 'user2': 1},
          createdAt: now,
          updatedAt: now,
        );

        final modified = original.copyWith(
          lastMessage: 'New message',
          updatedAt: later,
        );

        expect(modified.id, original.id);
        expect(modified.participants, original.participants);
        expect(modified.lastMessage, 'New message');
        expect(modified.updatedAt, later);
        expect(modified.createdAt, original.createdAt);
      });

      test('preserves original when no changes', () {
        final now = DateTime.now();
        final original = ChatModel(
          id: 'chat123',
          participants: ['user1', 'user2'],
          participantNames: {'user1': 'Alice', 'user2': 'Bob'},
          unreadCount: {},
          createdAt: now,
          updatedAt: now,
        );

        final copy = original.copyWith();

        expect(copy.id, original.id);
        expect(copy.participants, original.participants);
        expect(copy.participantNames, original.participantNames);
        expect(copy.createdAt, original.createdAt);
        expect(copy.updatedAt, original.updatedAt);
      });

      test('can update unread count', () {
        final now = DateTime.now();
        final original = ChatModel(
          id: 'chat123',
          participants: ['user1', 'user2'],
          participantNames: {'user1': 'Alice', 'user2': 'Bob'},
          unreadCount: {'user1': 0, 'user2': 3},
          createdAt: now,
          updatedAt: now,
        );

        final modified = original.copyWith(
          unreadCount: {'user1': 0, 'user2': 0},
        );

        expect(modified.unreadCount['user2'], 0);
        expect(original.unreadCount['user2'], 3);
      });
    });

    group('Helper Methods', () {
      test('getOtherParticipantName returns correct name', () {
        final now = DateTime.now();
        final chat = ChatModel(
          id: 'chat123',
          participants: ['user1', 'user2'],
          participantNames: {'user1': 'Alice', 'user2': 'Bob'},
          unreadCount: {},
          createdAt: now,
          updatedAt: now,
        );

        expect(chat.getOtherParticipantName('user1'), 'Bob');
        expect(chat.getOtherParticipantName('user2'), 'Alice');
      });

      test('getOtherParticipantName returns first participant for invalid user', () {
        final now = DateTime.now();
        final chat = ChatModel(
          id: 'chat123',
          participants: ['user1', 'user2'],
          participantNames: {'user1': 'Alice', 'user2': 'Bob'},
          unreadCount: {},
          createdAt: now,
          updatedAt: now,
        );

        // When user is not in participants, returns first participant's name
        expect(chat.getOtherParticipantName('user3'), 'Alice');
      });

      test('getOtherParticipantId returns correct id', () {
        final now = DateTime.now();
        final chat = ChatModel(
          id: 'chat123',
          participants: ['user1', 'user2'],
          participantNames: {'user1': 'Alice', 'user2': 'Bob'},
          unreadCount: {},
          createdAt: now,
          updatedAt: now,
        );

        expect(chat.getOtherParticipantId('user1'), 'user2');
        expect(chat.getOtherParticipantId('user2'), 'user1');
      });

      test('getOtherParticipantId returns first participant for invalid user', () {
        final now = DateTime.now();
        final chat = ChatModel(
          id: 'chat123',
          participants: ['user1', 'user2'],
          participantNames: {'user1': 'Alice', 'user2': 'Bob'},
          unreadCount: {},
          createdAt: now,
          updatedAt: now,
        );

        // When user is not in participants, returns first participant's id
        expect(chat.getOtherParticipantId('user3'), 'user1');
      });

      test('getUnreadCountForUser returns correct count', () {
        final now = DateTime.now();
        final chat = ChatModel(
          id: 'chat123',
          participants: ['user1', 'user2'],
          participantNames: {'user1': 'Alice', 'user2': 'Bob'},
          unreadCount: {'user1': 0, 'user2': 5},
          createdAt: now,
          updatedAt: now,
        );

        expect(chat.getUnreadCountForUser('user1'), 0);
        expect(chat.getUnreadCountForUser('user2'), 5);
      });

      test('getUnreadCountForUser returns 0 for missing user', () {
        final now = DateTime.now();
        final chat = ChatModel(
          id: 'chat123',
          participants: ['user1', 'user2'],
          participantNames: {'user1': 'Alice', 'user2': 'Bob'},
          unreadCount: {'user1': 0, 'user2': 5},
          createdAt: now,
          updatedAt: now,
        );

        expect(chat.getUnreadCountForUser('user3'), 0);
      });
    });

    group('Edge Cases', () {
      test('handles empty participant names map', () {
        final now = DateTime.now();
        final chat = ChatModel(
          id: 'chat123',
          participants: ['user1', 'user2'],
          participantNames: {},
          unreadCount: {},
          createdAt: now,
          updatedAt: now,
        );

        expect(chat.participantNames, isEmpty);
        expect(chat.getOtherParticipantName('user1'), 'Unknown User');
      });

      test('handles very long message', () {
        final now = DateTime.now();
        final longMessage = 'A' * 1000;
        final chat = ChatModel(
          id: 'chat123',
          participants: ['user1', 'user2'],
          participantNames: {'user1': 'Alice', 'user2': 'Bob'},
          lastMessage: longMessage,
          unreadCount: {},
          createdAt: now,
          updatedAt: now,
        );

        expect(chat.lastMessage?.length, 1000);
      });

      test('handles unicode characters in messages and names', () {
        final now = DateTime.now();
        final chat = ChatModel(
          id: 'chat123',
          participants: ['user1', 'user2'],
          participantNames: {'user1': '小明', 'user2': 'محمد'},
          lastMessage: 'Hello 👋 مرحبا 你好',
          unreadCount: {},
          createdAt: now,
          updatedAt: now,
        );

        expect(chat.participantNames['user1'], '小明');
        expect(chat.participantNames['user2'], 'محمد');
        expect(chat.lastMessage, contains('👋'));
      });

      test('handles large unread counts', () {
        final now = DateTime.now();
        final chat = ChatModel(
          id: 'chat123',
          participants: ['user1', 'user2'],
          participantNames: {'user1': 'Alice', 'user2': 'Bob'},
          unreadCount: {'user1': 0, 'user2': 999},
          createdAt: now,
          updatedAt: now,
        );

        expect(chat.unreadCount['user2'], 999);
      });

      test('timestamps are preserved correctly', () {
        final created = DateTime(2025, 1, 1, 10, 0);
        final updated = DateTime(2025, 1, 15, 14, 30);
        final lastMsg = DateTime(2025, 1, 15, 14, 29);

        final chat = ChatModel(
          id: 'chat123',
          participants: ['user1', 'user2'],
          participantNames: {'user1': 'Alice', 'user2': 'Bob'},
          lastMessageTime: lastMsg,
          unreadCount: {},
          createdAt: created,
          updatedAt: updated,
        );

        expect(chat.createdAt, created);
        expect(chat.updatedAt, updated);
        expect(chat.lastMessageTime, lastMsg);
        expect(chat.updatedAt.isAfter(chat.createdAt), true);
      });
    });
  });
}
