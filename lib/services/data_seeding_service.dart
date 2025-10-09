import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:faker/faker.dart';
import 'package:yajid/config/env_config.dart';

/// Data seeding service for populating dev/staging environments with fake data
/// This service should ONLY be used in development and staging environments
class DataSeedingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Faker _faker = Faker();

  // Recommendation categories
  final List<String> _categories = [
    'movies',
    'music',
    'books',
    'tv_shows',
    'podcasts',
    'sports',
    'videogames',
    'brands',
    'recipes',
    'events',
    'activities',
    'businesses',
  ];

  /// Seed all data (users, events, recommendations, messages, notifications)
  Future<void> seedAllData({
    int userCount = 20,
    int eventsPerUser = 3,
    int recommendationsPerCategory = 10,
    int messagesPerConversation = 15,
    int notificationsPerUser = 8,
  }) async {
    // Safety check: Only allow seeding in dev/staging
    if (currentConfig.isProduction) {
      throw Exception('Data seeding is not allowed in production environment');
    }

    print('[DataSeeding] Starting data seeding for ${currentConfig.environmentName} environment');

    try {
      // Step 1: Create fake users
      print('[DataSeeding] Creating $userCount fake users...');
      final userIds = await _seedUsers(userCount);
      print('[DataSeeding] Created ${userIds.length} users');

      // Step 2: Create fake events
      print('[DataSeeding] Creating events...');
      await _seedEvents(userIds, eventsPerUser);
      print('[DataSeeding] Created events');

      // Step 3: Create fake recommendations
      print('[DataSeeding] Creating recommendations...');
      await _seedRecommendations(recommendationsPerCategory);
      print('[DataSeeding] Created recommendations');

      // Step 4: Create fake messages between users
      print('[DataSeeding] Creating messages...');
      await _seedMessages(userIds, messagesPerConversation);
      print('[DataSeeding] Created messages');

      // Step 5: Create fake notifications
      print('[DataSeeding] Creating notifications...');
      await _seedNotifications(userIds, notificationsPerUser);
      print('[DataSeeding] Created notifications');

      print('[DataSeeding] ✓ Data seeding completed successfully');
    } catch (e) {
      print('[DataSeeding] ✗ Error during data seeding: $e');
      rethrow;
    }
  }

  /// Create fake users with realistic data
  Future<List<String>> _seedUsers(int count) async {
    final List<String> userIds = [];

    for (int i = 0; i < count; i++) {
      try {
        final userId = _firestore.collection('users').doc().id;
        final firstName = _faker.person.firstName();
        final lastName = _faker.person.lastName();

        await _firestore.collection('users').doc(userId).set({
          'uid': userId,
          'email': _faker.internet.email(),
          'displayName': '$firstName $lastName',
          'firstName': firstName,
          'lastName': lastName,
          'phoneNumber': _faker.phoneNumber.us(),
          'photoURL': 'https://i.pravatar.cc/150?img=${i + 1}',
          'bio': _faker.lorem.sentence(),
          'createdAt': FieldValue.serverTimestamp(),
          'lastActive': FieldValue.serverTimestamp(),
          'preferences': {
            'categories': (_categories..shuffle()).take(5).toList(),
            'language': 'en',
            'notifications': true,
          },
          'stats': {
            'followers': _faker.randomGenerator.integer(1000),
            'following': _faker.randomGenerator.integer(500),
            'posts': _faker.randomGenerator.integer(50),
          },
        });

        userIds.add(userId);
      } catch (e) {
        print('[DataSeeding] Error creating user $i: $e');
      }
    }

    return userIds;
  }

  /// Create fake events
  Future<void> _seedEvents(List<String> userIds, int eventsPerUser) async {
    for (final userId in userIds) {
      for (int i = 0; i < eventsPerUser; i++) {
        try {
          final startDate = DateTime.now().add(Duration(days: _faker.randomGenerator.integer(60, min: 1)));
          final endDate = startDate.add(Duration(hours: _faker.randomGenerator.integer(6, min: 1)));

          await _firestore.collection('events').add({
            'title': _faker.conference.name(),
            'description': _faker.lorem.sentences(3).join(' '),
            'location': '${_faker.address.city()}, ${_faker.address.stateAbbreviation()}',
            'startTime': Timestamp.fromDate(startDate),
            'endTime': Timestamp.fromDate(endDate),
            'createdBy': userId,
            'createdAt': FieldValue.serverTimestamp(),
            'category': _categories[_faker.randomGenerator.integer(_categories.length)],
            'isPublic': _faker.randomGenerator.boolean(),
            'attendees': [userId],
            'maxAttendees': _faker.randomGenerator.integer(100, min: 10),
            'tags': List.generate(3, (_) => _faker.sport.name()),
          });
        } catch (e) {
          print('[DataSeeding] Error creating event for user $userId: $e');
        }
      }
    }
  }

  /// Create fake recommendations across all categories
  Future<void> _seedRecommendations(int perCategory) async {
    for (final category in _categories) {
      for (int i = 0; i < perCategory; i++) {
        try {
          await _firestore.collection('recommendations').add({
            'title': _getTitleForCategory(category),
            'description': _faker.lorem.sentences(2).join(' '),
            'category': category,
            'imageUrl': 'https://picsum.photos/seed/${category}_$i/400/600',
            'rating': _faker.randomGenerator.decimal(scale: 5.0, min: 3.0),
            'totalRatings': _faker.randomGenerator.integer(1000, min: 10),
            'createdAt': FieldValue.serverTimestamp(),
            'tags': List.generate(3, (_) => _faker.lorem.word()),
            'metadata': _getMetadataForCategory(category),
          });
        } catch (e) {
          print('[DataSeeding] Error creating recommendation for $category: $e');
        }
      }
    }
  }

  /// Create fake messages between users
  Future<void> _seedMessages(List<String> userIds, int messagesPerConversation) async {
    // Create conversations between random pairs of users
    for (int i = 0; i < userIds.length - 1; i += 2) {
      if (i + 1 >= userIds.length) break;

      final user1 = userIds[i];
      final user2 = userIds[i + 1];
      final participants = [user1, user2]..sort();
      final chatId = participants.join('_');

      try {
        // Create chat document
        await _firestore.collection('chats').doc(chatId).set({
          'participants': participants,
          'participantDetails': {
            user1: {
              'displayName': _faker.person.name(),
              'photoURL': 'https://i.pravatar.cc/150?img=${i + 1}',
            },
            user2: {
              'displayName': _faker.person.name(),
              'photoURL': 'https://i.pravatar.cc/150?img=${i + 2}',
            },
          },
          'lastMessage': _faker.lorem.sentence(),
          'lastMessageTime': FieldValue.serverTimestamp(),
          'unreadCount': {user1: 0, user2: 0},
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Create messages
        for (int j = 0; j < messagesPerConversation; j++) {
          final sender = j % 2 == 0 ? user1 : user2;
          final timestamp = DateTime.now().subtract(Duration(hours: messagesPerConversation - j));

          await _firestore
              .collection('chats')
              .doc(chatId)
              .collection('messages')
              .add({
            'senderId': sender,
            'text': _faker.lorem.sentence(),
            'timestamp': Timestamp.fromDate(timestamp),
            'read': j < messagesPerConversation - 3, // Last 3 messages unread
          });
        }
      } catch (e) {
        print('[DataSeeding] Error creating messages for chat $chatId: $e');
      }
    }
  }

  /// Create fake notifications for users
  Future<void> _seedNotifications(List<String> userIds, int notificationsPerUser) async {
    final notificationTypes = [
      'friend_request',
      'message',
      'event_invite',
      'recommendation',
      'achievement',
    ];

    for (final userId in userIds) {
      for (int i = 0; i < notificationsPerUser; i++) {
        try {
          final type = notificationTypes[_faker.randomGenerator.integer(notificationTypes.length)];

          await _firestore.collection('notifications').add({
            'userId': userId,
            'type': type,
            'title': _getNotificationTitle(type),
            'message': _faker.lorem.sentence(),
            'read': i < notificationsPerUser - 2, // Last 2 unread
            'createdAt': FieldValue.serverTimestamp(),
            'data': {
              'sourceId': _firestore.collection('users').doc().id,
              'actionUrl': '/profile/fake-user-id',
            },
          });
        } catch (e) {
          print('[DataSeeding] Error creating notification for user $userId: $e');
        }
      }
    }
  }

  /// Generate realistic titles based on category
  String _getTitleForCategory(String category) {
    switch (category) {
      case 'movies':
        return _faker.lorem.words(3).join(' ');
      case 'music':
        return '${_faker.person.firstName()} - ${_faker.lorem.words(2).join(' ')}';
      case 'books':
        return _faker.lorem.words(4).join(' ');
      case 'tv_shows':
        return _faker.lorem.words(3).join(' ');
      case 'podcasts':
        return 'The ${_faker.lorem.words(2).join(' ')} Podcast';
      case 'sports':
        return _faker.sport.name();
      case 'videogames':
        return _faker.lorem.words(3).join(' ');
      case 'brands':
        return _faker.company.name();
      case 'recipes':
        return '${_faker.food.dish()} Recipe';
      case 'events':
        return _faker.conference.name();
      case 'activities':
        return _faker.sport.name();
      case 'businesses':
        return _faker.company.name();
      default:
        return _faker.lorem.words(3).join(' ');
    }
  }

  /// Generate category-specific metadata
  Map<String, dynamic> _getMetadataForCategory(String category) {
    switch (category) {
      case 'movies':
      case 'tv_shows':
        return {
          'director': _faker.person.name(),
          'year': _faker.randomGenerator.integer(2024, min: 1980),
          'duration': '${_faker.randomGenerator.integer(180, min: 60)} min',
        };
      case 'music':
        return {
          'artist': _faker.person.name(),
          'album': _faker.lorem.words(2).join(' '),
          'year': _faker.randomGenerator.integer(2024, min: 1960),
        };
      case 'books':
        return {
          'author': _faker.person.name(),
          'pages': _faker.randomGenerator.integer(500, min: 100),
          'year': _faker.randomGenerator.integer(2024, min: 1950),
        };
      case 'recipes':
        return {
          'prepTime': '${_faker.randomGenerator.integer(60, min: 10)} min',
          'servings': _faker.randomGenerator.integer(8, min: 1),
          'difficulty': ['Easy', 'Medium', 'Hard'][_faker.randomGenerator.integer(3)],
        };
      case 'businesses':
        return {
          'address': _faker.address.streetAddress(),
          'phone': _faker.phoneNumber.us(),
          'hours': '9 AM - 5 PM',
        };
      default:
        return {};
    }
  }

  /// Generate notification titles based on type
  String _getNotificationTitle(String type) {
    switch (type) {
      case 'friend_request':
        return 'New Friend Request';
      case 'message':
        return 'New Message';
      case 'event_invite':
        return 'Event Invitation';
      case 'recommendation':
        return 'New Recommendation';
      case 'achievement':
        return 'Achievement Unlocked';
      default:
        return 'Notification';
    }
  }

  /// Clear all seeded data (useful for testing)
  Future<void> clearAllSeededData() async {
    // Safety check: Only allow in dev/staging
    if (currentConfig.isProduction) {
      throw Exception('Clearing data is not allowed in production environment');
    }

    print('[DataSeeding] Clearing all seeded data...');

    try {
      // Note: This is a simplified version. In production, you'd want batch deletes
      final collections = ['users', 'events', 'recommendations', 'chats', 'notifications'];

      for (final collection in collections) {
        final snapshot = await _firestore.collection(collection).limit(500).get();
        for (final doc in snapshot.docs) {
          await doc.reference.delete();
        }
      }

      print('[DataSeeding] ✓ All seeded data cleared');
    } catch (e) {
      print('[DataSeeding] ✗ Error clearing data: $e');
      rethrow;
    }
  }
}
