import 'package:flutter_test/flutter_test.dart';
import 'package:yajid/models/message_model.dart';

void main() {
  group('MessageModel', () {
    group('Model Creation', () {
      test('creates text message with all fields', () {
        final now = DateTime.now();
        final message = MessageModel(
          id: 'msg123',
          chatId: 'chat123',
          senderId: 'user1',
          senderName: 'Alice',
          content: 'Hello there!',
          type: MessageType.text,
          timestamp: now,
          isRead: false,
        );

        expect(message.id, 'msg123');
        expect(message.chatId, 'chat123');
        expect(message.senderId, 'user1');
        expect(message.senderName, 'Alice');
        expect(message.content, 'Hello there!');
        expect(message.type, MessageType.text);
        expect(message.timestamp, now);
        expect(message.isRead, false);
        expect(message.imageUrl, null);
        expect(message.audioUrl, null);
        expect(message.fileName, null);
      });

      test('creates image message with imageUrl', () {
        final now = DateTime.now();
        final message = MessageModel(
          id: 'msg123',
          chatId: 'chat123',
          senderId: 'user1',
          senderName: 'Alice',
          content: 'Check out this image',
          type: MessageType.image,
          timestamp: now,
          imageUrl: 'https://example.com/image.jpg',
        );

        expect(message.type, MessageType.image);
        expect(message.imageUrl, 'https://example.com/image.jpg');
      });

      test('creates audio message with audioUrl', () {
        final now = DateTime.now();
        final message = MessageModel(
          id: 'msg123',
          chatId: 'chat123',
          senderId: 'user1',
          senderName: 'Alice',
          content: 'Voice message',
          type: MessageType.audio,
          timestamp: now,
          audioUrl: 'https://example.com/audio.mp3',
        );

        expect(message.type, MessageType.audio);
        expect(message.audioUrl, 'https://example.com/audio.mp3');
      });

      test('creates file message with fileName', () {
        final now = DateTime.now();
        final message = MessageModel(
          id: 'msg123',
          chatId: 'chat123',
          senderId: 'user1',
          senderName: 'Alice',
          content: 'Document attached',
          type: MessageType.file,
          timestamp: now,
          fileName: 'document.pdf',
        );

        expect(message.type, MessageType.file);
        expect(message.fileName, 'document.pdf');
      });

      test('defaults to text type when not specified', () {
        final now = DateTime.now();
        final message = MessageModel(
          id: 'msg123',
          chatId: 'chat123',
          senderId: 'user1',
          senderName: 'Alice',
          content: 'Hello',
          timestamp: now,
        );

        expect(message.type, MessageType.text);
      });

      test('defaults isRead to false when not specified', () {
        final now = DateTime.now();
        final message = MessageModel(
          id: 'msg123',
          chatId: 'chat123',
          senderId: 'user1',
          senderName: 'Alice',
          content: 'Hello',
          timestamp: now,
        );

        expect(message.isRead, false);
      });

      test('creates read message', () {
        final now = DateTime.now();
        final message = MessageModel(
          id: 'msg123',
          chatId: 'chat123',
          senderId: 'user1',
          senderName: 'Alice',
          content: 'Hello',
          timestamp: now,
          isRead: true,
        );

        expect(message.isRead, true);
      });
    });

    group('MessageType Enum', () {
      test('all message types are supported', () {
        final types = [
          MessageType.text,
          MessageType.image,
          MessageType.file,
          MessageType.audio,
        ];

        expect(types.length, 4);
        expect(types.contains(MessageType.text), true);
        expect(types.contains(MessageType.image), true);
        expect(types.contains(MessageType.file), true);
        expect(types.contains(MessageType.audio), true);
      });

      test('message type enum values are correct', () {
        expect(MessageType.text.toString(), 'MessageType.text');
        expect(MessageType.image.toString(), 'MessageType.image');
        expect(MessageType.file.toString(), 'MessageType.file');
        expect(MessageType.audio.toString(), 'MessageType.audio');
      });
    });

    group('Serialization', () {
      test('converts text message to Map correctly', () {
        final now = DateTime(2025, 6, 15, 10, 30);
        final message = MessageModel(
          id: 'msg123',
          chatId: 'chat123',
          senderId: 'user1',
          senderName: 'Alice',
          content: 'Test message',
          type: MessageType.text,
          timestamp: now,
          isRead: false,
        );

        final map = message.toMap();

        expect(map['id'], 'msg123');
        expect(map['chatId'], 'chat123');
        expect(map['senderId'], 'user1');
        expect(map['senderName'], 'Alice');
        expect(map['content'], 'Test message');
        expect(map['type'], 'text');
        expect(map['timestamp'], now.millisecondsSinceEpoch);
        expect(map['isRead'], false);
        expect(map['imageUrl'], null);
        expect(map['audioUrl'], null);
        expect(map['fileName'], null);
      });

      test('converts image message to Map correctly', () {
        final now = DateTime(2025, 6, 15, 10, 30);
        final message = MessageModel(
          id: 'msg123',
          chatId: 'chat123',
          senderId: 'user1',
          senderName: 'Alice',
          content: 'Image',
          type: MessageType.image,
          timestamp: now,
          imageUrl: 'https://example.com/image.jpg',
        );

        final map = message.toMap();

        expect(map['type'], 'image');
        expect(map['imageUrl'], 'https://example.com/image.jpg');
      });

      test('converts from Map correctly', () {
        final now = DateTime(2025, 6, 15, 10, 30);
        final map = {
          'id': 'msg123',
          'chatId': 'chat123',
          'senderId': 'user1',
          'senderName': 'Alice',
          'content': 'Test message',
          'type': 'text',
          'timestamp': now.millisecondsSinceEpoch,
          'isRead': true,
        };

        final message = MessageModel.fromMap(map);

        expect(message.id, 'msg123');
        expect(message.chatId, 'chat123');
        expect(message.senderId, 'user1');
        expect(message.senderName, 'Alice');
        expect(message.content, 'Test message');
        expect(message.type, MessageType.text);
        expect(message.timestamp, now);
        expect(message.isRead, true);
      });

      test('fromMap handles missing optional fields', () {
        final now = DateTime(2025, 6, 15);
        final map = {
          'id': 'msg123',
          'chatId': 'chat123',
          'senderId': 'user1',
          'senderName': 'Alice',
          'content': 'Test',
          'type': 'text',
          'timestamp': now.millisecondsSinceEpoch,
        };

        final message = MessageModel.fromMap(map);

        expect(message.isRead, false);
        expect(message.imageUrl, null);
        expect(message.audioUrl, null);
        expect(message.fileName, null);
      });

      test('fromMap defaults to text type for unknown type', () {
        final now = DateTime(2025, 6, 15);
        final map = {
          'id': 'msg123',
          'chatId': 'chat123',
          'senderId': 'user1',
          'senderName': 'Alice',
          'content': 'Test',
          'type': 'unknown_type',
          'timestamp': now.millisecondsSinceEpoch,
        };

        final message = MessageModel.fromMap(map);

        expect(message.type, MessageType.text);
      });

      test('roundtrip serialization preserves data', () {
        final now = DateTime.now();
        final original = MessageModel(
          id: 'msg123',
          chatId: 'chat123',
          senderId: 'user1',
          senderName: 'Alice',
          content: 'Hello world',
          type: MessageType.image,
          timestamp: now,
          isRead: true,
          imageUrl: 'https://example.com/image.jpg',
        );

        final map = original.toMap();
        final restored = MessageModel.fromMap(map);

        expect(restored.id, original.id);
        expect(restored.chatId, original.chatId);
        expect(restored.senderId, original.senderId);
        expect(restored.content, original.content);
        expect(restored.type, original.type);
        expect(restored.isRead, original.isRead);
        expect(restored.imageUrl, original.imageUrl);
      });

      test('handles all message types in serialization', () {
        final now = DateTime.now();
        final types = [
          MessageType.text,
          MessageType.image,
          MessageType.file,
          MessageType.audio,
        ];

        for (final type in types) {
          final message = MessageModel(
            id: 'msg123',
            chatId: 'chat123',
            senderId: 'user1',
            senderName: 'Alice',
            content: 'Test',
            type: type,
            timestamp: now,
          );

          final map = message.toMap();
          final restored = MessageModel.fromMap(map);

          expect(restored.type, type);
        }
      });
    });

    group('copyWith', () {
      test('creates copy with modified content', () {
        final now = DateTime.now();
        final original = MessageModel(
          id: 'msg123',
          chatId: 'chat123',
          senderId: 'user1',
          senderName: 'Alice',
          content: 'Original message',
          timestamp: now,
        );

        final modified = original.copyWith(
          content: 'Modified message',
        );

        expect(modified.id, original.id);
        expect(modified.chatId, original.chatId);
        expect(modified.senderId, original.senderId);
        expect(modified.content, 'Modified message');
        expect(modified.timestamp, original.timestamp);
      });

      test('can mark message as read', () {
        final now = DateTime.now();
        final original = MessageModel(
          id: 'msg123',
          chatId: 'chat123',
          senderId: 'user1',
          senderName: 'Alice',
          content: 'Hello',
          timestamp: now,
          isRead: false,
        );

        final modified = original.copyWith(isRead: true);

        expect(modified.isRead, true);
        expect(original.isRead, false);
      });

      test('can change message type', () {
        final now = DateTime.now();
        final original = MessageModel(
          id: 'msg123',
          chatId: 'chat123',
          senderId: 'user1',
          senderName: 'Alice',
          content: 'Message',
          type: MessageType.text,
          timestamp: now,
        );

        final modified = original.copyWith(
          type: MessageType.image,
          imageUrl: 'https://example.com/image.jpg',
        );

        expect(modified.type, MessageType.image);
        expect(modified.imageUrl, 'https://example.com/image.jpg');
      });

      test('preserves original when no changes', () {
        final now = DateTime.now();
        final original = MessageModel(
          id: 'msg123',
          chatId: 'chat123',
          senderId: 'user1',
          senderName: 'Alice',
          content: 'Hello',
          timestamp: now,
        );

        final copy = original.copyWith();

        expect(copy.id, original.id);
        expect(copy.chatId, original.chatId);
        expect(copy.senderId, original.senderId);
        expect(copy.content, original.content);
        expect(copy.timestamp, original.timestamp);
      });
    });

    group('Edge Cases', () {
      test('handles empty content', () {
        final now = DateTime.now();
        final message = MessageModel(
          id: 'msg123',
          chatId: 'chat123',
          senderId: 'user1',
          senderName: 'Alice',
          content: '',
          timestamp: now,
        );

        expect(message.content, isEmpty);
      });

      test('handles very long content', () {
        final now = DateTime.now();
        final longContent = 'A' * 5000;
        final message = MessageModel(
          id: 'msg123',
          chatId: 'chat123',
          senderId: 'user1',
          senderName: 'Alice',
          content: longContent,
          timestamp: now,
        );

        expect(message.content.length, 5000);
      });

      test('handles unicode characters in content', () {
        final now = DateTime.now();
        final message = MessageModel(
          id: 'msg123',
          chatId: 'chat123',
          senderId: 'user1',
          senderName: 'Alice',
          content: 'Hello 👋 مرحبا 你好 🎉',
          timestamp: now,
        );

        expect(message.content, contains('👋'));
        expect(message.content, contains('مرحبا'));
        expect(message.content, contains('你好'));
      });

      test('handles unicode in sender name', () {
        final now = DateTime.now();
        final message = MessageModel(
          id: 'msg123',
          chatId: 'chat123',
          senderId: 'user1',
          senderName: '小明 محمد',
          content: 'Hello',
          timestamp: now,
        );

        expect(message.senderName, '小明 محمد');
      });

      test('handles special characters in content', () {
        final now = DateTime.now();
        final message = MessageModel(
          id: 'msg123',
          chatId: 'chat123',
          senderId: 'user1',
          senderName: 'Alice',
          content: 'Test: "quoted", \'apostrophe\', <brackets>, &ampersand',
          timestamp: now,
        );

        expect(message.content, contains('"'));
        expect(message.content, contains('\''));
        expect(message.content, contains('<'));
        expect(message.content, contains('&'));
      });

      test('handles newlines in content', () {
        final now = DateTime.now();
        final message = MessageModel(
          id: 'msg123',
          chatId: 'chat123',
          senderId: 'user1',
          senderName: 'Alice',
          content: 'Line 1\nLine 2\nLine 3',
          timestamp: now,
        );

        expect(message.content, contains('\n'));
        expect(message.content.split('\n').length, 3);
      });

      test('handles URLs in imageUrl', () {
        final now = DateTime.now();
        final message = MessageModel(
          id: 'msg123',
          chatId: 'chat123',
          senderId: 'user1',
          senderName: 'Alice',
          content: 'Image',
          type: MessageType.image,
          timestamp: now,
          imageUrl: 'https://example.com/path/to/image.jpg?param=value',
        );

        expect(message.imageUrl, contains('?'));
        expect(message.imageUrl, contains('='));
      });

      test('timestamps are preserved correctly', () {
        final timestamp = DateTime(2025, 6, 15, 14, 30, 45);
        final message = MessageModel(
          id: 'msg123',
          chatId: 'chat123',
          senderId: 'user1',
          senderName: 'Alice',
          content: 'Hello',
          timestamp: timestamp,
        );

        expect(message.timestamp, timestamp);
        expect(message.timestamp.year, 2025);
        expect(message.timestamp.month, 6);
        expect(message.timestamp.day, 15);
        expect(message.timestamp.hour, 14);
        expect(message.timestamp.minute, 30);
      });

      test('handles empty sender name', () {
        final now = DateTime.now();
        final message = MessageModel(
          id: 'msg123',
          chatId: 'chat123',
          senderId: 'user1',
          senderName: '',
          content: 'Hello',
          timestamp: now,
        );

        expect(message.senderName, isEmpty);
      });
    });
  });
}
