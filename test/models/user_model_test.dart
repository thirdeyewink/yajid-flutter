import 'package:flutter_test/flutter_test.dart';
import 'package:yajid/models/user_model.dart';

void main() {
  group('UserModel', () {
    group('Model Creation', () {
      test('creates user model with all required fields', () {
        final now = DateTime.now();
        final user = UserModel(
          uid: 'user123',
          displayName: 'John Doe',
          email: 'john@example.com',
          photoURL: 'https://example.com/photo.jpg',
          isOnline: true,
          lastSeen: now,
          role: 'user',
        );

        expect(user.uid, 'user123');
        expect(user.displayName, 'John Doe');
        expect(user.email, 'john@example.com');
        expect(user.photoURL, 'https://example.com/photo.jpg');
        expect(user.isOnline, true);
        expect(user.lastSeen, now);
        expect(user.role, 'user');
      });

      test('creates user model with default role when not specified', () {
        final now = DateTime.now();
        final user = UserModel(
          uid: 'user123',
          displayName: 'Jane Doe',
          email: 'jane@example.com',
          lastSeen: now,
        );

        expect(user.role, 'user'); // Default role
        expect(user.isOnline, false); // Default isOnline
        expect(user.photoURL, null); // Optional field
      });

      test('creates admin user with admin role', () {
        final now = DateTime.now();
        final admin = UserModel(
          uid: 'admin123',
          displayName: 'Admin User',
          email: 'admin@example.com',
          lastSeen: now,
          role: 'admin',
        );

        expect(admin.role, 'admin');
        expect(admin.uid, 'admin123');
        expect(admin.displayName, 'Admin User');
      });
    });

    group('Serialization', () {
      test('converts to Map correctly with all fields', () {
        final now = DateTime.now();
        final user = UserModel(
          uid: 'user123',
          displayName: 'John Doe',
          email: 'john@example.com',
          photoURL: 'https://example.com/photo.jpg',
          isOnline: true,
          lastSeen: now,
          role: 'user',
        );

        final map = user.toMap();

        expect(map['uid'], 'user123');
        expect(map['displayName'], 'John Doe');
        expect(map['email'], 'john@example.com');
        expect(map['photoURL'], 'https://example.com/photo.jpg');
        expect(map['isOnline'], true);
        expect(map['lastSeen'], now.millisecondsSinceEpoch);
        expect(map['role'], 'user');
      });

      test('converts to Map correctly with admin role', () {
        final now = DateTime.now();
        final admin = UserModel(
          uid: 'admin123',
          displayName: 'Admin User',
          email: 'admin@example.com',
          lastSeen: now,
          role: 'admin',
        );

        final map = admin.toMap();

        expect(map['role'], 'admin');
        expect(map['uid'], 'admin123');
      });

      test('converts from Map correctly with all fields', () {
        final now = DateTime.now();
        final map = {
          'uid': 'user123',
          'displayName': 'John Doe',
          'email': 'john@example.com',
          'photoURL': 'https://example.com/photo.jpg',
          'isOnline': true,
          'lastSeen': now.millisecondsSinceEpoch,
          'role': 'user',
        };

        final user = UserModel.fromMap(map);

        expect(user.uid, 'user123');
        expect(user.displayName, 'John Doe');
        expect(user.email, 'john@example.com');
        expect(user.photoURL, 'https://example.com/photo.jpg');
        expect(user.isOnline, true);
        expect(user.lastSeen.millisecondsSinceEpoch, now.millisecondsSinceEpoch);
        expect(user.role, 'user');
      });

      test('converts from Map with admin role', () {
        final now = DateTime.now();
        final map = {
          'uid': 'admin123',
          'displayName': 'Admin User',
          'email': 'admin@example.com',
          'lastSeen': now.millisecondsSinceEpoch,
          'role': 'admin',
        };

        final user = UserModel.fromMap(map);

        expect(user.role, 'admin');
        expect(user.uid, 'admin123');
      });

      test('converts from Map with default role when role is missing', () {
        final now = DateTime.now();
        final map = {
          'uid': 'user123',
          'displayName': 'John Doe',
          'email': 'john@example.com',
          'lastSeen': now.millisecondsSinceEpoch,
          // 'role' field intentionally missing
        };

        final user = UserModel.fromMap(map);

        expect(user.role, 'user'); // Should default to 'user'
      });

      test('converts from Map with default values for optional fields', () {
        final map = {
          'uid': '',
          'displayName': '',
          'email': '',
          'lastSeen': 0,
        };

        final user = UserModel.fromMap(map);

        expect(user.uid, '');
        expect(user.displayName, '');
        expect(user.email, '');
        expect(user.photoURL, null);
        expect(user.isOnline, false);
        expect(user.role, 'user');
      });

      test('roundtrip serialization preserves all data', () {
        final now = DateTime.now();
        final original = UserModel(
          uid: 'user123',
          displayName: 'John Doe',
          email: 'john@example.com',
          photoURL: 'https://example.com/photo.jpg',
          isOnline: true,
          lastSeen: now,
          role: 'user',
        );

        final map = original.toMap();
        final restored = UserModel.fromMap(map);

        expect(restored.uid, original.uid);
        expect(restored.displayName, original.displayName);
        expect(restored.email, original.email);
        expect(restored.photoURL, original.photoURL);
        expect(restored.isOnline, original.isOnline);
        expect(restored.lastSeen.millisecondsSinceEpoch, original.lastSeen.millisecondsSinceEpoch);
        expect(restored.role, original.role);
      });

      test('roundtrip serialization preserves admin role', () {
        final now = DateTime.now();
        final original = UserModel(
          uid: 'admin123',
          displayName: 'Admin User',
          email: 'admin@example.com',
          lastSeen: now,
          role: 'admin',
        );

        final map = original.toMap();
        final restored = UserModel.fromMap(map);

        expect(restored.role, 'admin');
        expect(restored.uid, original.uid);
      });
    });

    group('CopyWith', () {
      test('copyWith creates modified copy with new displayName', () {
        final now = DateTime.now();
        final original = UserModel(
          uid: 'user123',
          displayName: 'John Doe',
          email: 'john@example.com',
          lastSeen: now,
          role: 'user',
        );

        final modified = original.copyWith(
          displayName: 'Jane Doe',
        );

        expect(modified.displayName, 'Jane Doe');
        expect(modified.uid, original.uid); // Unchanged
        expect(modified.email, original.email); // Unchanged
        expect(modified.role, original.role); // Unchanged
      });

      test('copyWith can change role from user to admin', () {
        final now = DateTime.now();
        final user = UserModel(
          uid: 'user123',
          displayName: 'John Doe',
          email: 'john@example.com',
          lastSeen: now,
          role: 'user',
        );

        final admin = user.copyWith(role: 'admin');

        expect(admin.role, 'admin');
        expect(admin.uid, user.uid); // Unchanged
        expect(admin.displayName, user.displayName); // Unchanged
      });

      test('copyWith can change role from admin to user', () {
        final now = DateTime.now();
        final admin = UserModel(
          uid: 'admin123',
          displayName: 'Admin User',
          email: 'admin@example.com',
          lastSeen: now,
          role: 'admin',
        );

        final user = admin.copyWith(role: 'user');

        expect(user.role, 'user');
        expect(user.uid, admin.uid); // Unchanged
        expect(user.displayName, admin.displayName); // Unchanged
      });

      test('copyWith preserves role when not specified', () {
        final now = DateTime.now();
        final original = UserModel(
          uid: 'admin123',
          displayName: 'Admin User',
          email: 'admin@example.com',
          lastSeen: now,
          role: 'admin',
        );

        final modified = original.copyWith(
          displayName: 'Super Admin',
        );

        expect(modified.role, 'admin'); // Unchanged
        expect(modified.displayName, 'Super Admin'); // Changed
      });

      test('copyWith can update multiple fields including role', () {
        final now = DateTime.now();
        final later = now.add(const Duration(hours: 1));
        final original = UserModel(
          uid: 'user123',
          displayName: 'John Doe',
          email: 'john@example.com',
          isOnline: false,
          lastSeen: now,
          role: 'user',
        );

        final modified = original.copyWith(
          displayName: 'Admin John',
          isOnline: true,
          lastSeen: later,
          role: 'admin',
        );

        expect(modified.displayName, 'Admin John');
        expect(modified.isOnline, true);
        expect(modified.lastSeen, later);
        expect(modified.role, 'admin');
        expect(modified.uid, original.uid); // Unchanged
        expect(modified.email, original.email); // Unchanged
      });

      test('copyWith with no parameters returns identical copy', () {
        final now = DateTime.now();
        final original = UserModel(
          uid: 'user123',
          displayName: 'John Doe',
          email: 'john@example.com',
          isOnline: true,
          lastSeen: now,
          role: 'admin',
        );

        final copy = original.copyWith();

        expect(copy.uid, original.uid);
        expect(copy.displayName, original.displayName);
        expect(copy.email, original.email);
        expect(copy.photoURL, original.photoURL);
        expect(copy.isOnline, original.isOnline);
        expect(copy.lastSeen, original.lastSeen);
        expect(copy.role, original.role);
      });
    });

    group('Role Security', () {
      test('default role is user for security', () {
        final now = DateTime.now();
        final user = UserModel(
          uid: 'user123',
          displayName: 'Test User',
          email: 'test@example.com',
          lastSeen: now,
        );

        expect(user.role, 'user', reason: 'Default role should be user for least-privilege security');
      });

      test('role field is never null', () {
        final now = DateTime.now();

        // Test with explicit user role
        final user = UserModel(
          uid: 'user123',
          displayName: 'Test User',
          email: 'test@example.com',
          lastSeen: now,
          role: 'user',
        );
        expect(user.role, isNotNull);

        // Test with explicit admin role
        final admin = UserModel(
          uid: 'admin123',
          displayName: 'Admin User',
          email: 'admin@example.com',
          lastSeen: now,
          role: 'admin',
        );
        expect(admin.role, isNotNull);

        // Test with default role
        final defaultUser = UserModel(
          uid: 'user456',
          displayName: 'Default User',
          email: 'default@example.com',
          lastSeen: now,
        );
        expect(defaultUser.role, isNotNull);
      });

      test('role field from empty map defaults to user', () {
        final map = {
          'uid': 'user123',
          'displayName': 'Test User',
          'email': 'test@example.com',
          'lastSeen': DateTime.now().millisecondsSinceEpoch,
          'role': null, // Explicitly null
        };

        final user = UserModel.fromMap(map);

        expect(user.role, 'user');
      });
    });
  });
}
