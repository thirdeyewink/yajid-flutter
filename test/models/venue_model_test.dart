import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yajid/models/venue_model.dart';

// Mock classes
class MockDocumentSnapshot<T> extends Mock implements DocumentSnapshot<T> {}

void main() {
  group('VenueModel', () {
    group('Model Creation', () {
      test('creates venue model with all required fields', () {
        final now = DateTime.now();
        final venue = VenueModel(
          id: 'venue123',
          name: 'Test Venue',
          description: 'A great test venue',
          category: 'restaurant',
          address: '123 Test St, Casablanca',
          latitude: 33.5731,
          longitude: -7.5898,
          photoUrls: ['photo1.jpg', 'photo2.jpg'],
          pricePerHour: 500.0,
          currency: 'MAD',
          rating: 4.5,
          reviewCount: 120,
          ownerId: 'owner123',
          amenities: ['wifi', 'parking', 'ac'],
          capacity: 50,
          availability: {
            'monday': true,
            'tuesday': true,
            'wednesday': false,
          },
          createdAt: now,
          updatedAt: now,
          isActive: true,
        );

        expect(venue.id, 'venue123');
        expect(venue.name, 'Test Venue');
        expect(venue.description, 'A great test venue');
        expect(venue.category, 'restaurant');
        expect(venue.address, '123 Test St, Casablanca');
        expect(venue.latitude, 33.5731);
        expect(venue.longitude, -7.5898);
        expect(venue.photoUrls, ['photo1.jpg', 'photo2.jpg']);
        expect(venue.pricePerHour, 500.0);
        expect(venue.currency, 'MAD');
        expect(venue.rating, 4.5);
        expect(venue.reviewCount, 120);
        expect(venue.ownerId, 'owner123');
        expect(venue.amenities, ['wifi', 'parking', 'ac']);
        expect(venue.capacity, 50);
        expect(venue.availability['monday'], true);
        expect(venue.availability['wednesday'], false);
        expect(venue.createdAt, now);
        expect(venue.updatedAt, now);
        expect(venue.isActive, true);
      });

      test('creates venue model with optional fields', () {
        final now = DateTime.now();
        final venue = VenueModel(
          id: 'venue123',
          name: 'Test Venue',
          description: 'A great test venue',
          category: 'restaurant',
          address: '123 Test St',
          latitude: 33.5731,
          longitude: -7.5898,
          photoUrls: [],
          pricePerHour: 500.0,
          currency: 'MAD',
          rating: 0.0,
          reviewCount: 0,
          ownerId: 'owner123',
          amenities: [],
          capacity: 50,
          availability: {},
          createdAt: now,
          updatedAt: now,
          isActive: true,
          phoneNumber: '+212-123-456-789',
          email: 'venue@example.com',
          website: 'https://testvenue.com',
          operatingHours: {
            'monday': {'open': '09:00', 'close': '18:00'},
            'tuesday': {'open': '09:00', 'close': '18:00'},
          },
        );

        expect(venue.phoneNumber, '+212-123-456-789');
        expect(venue.email, 'venue@example.com');
        expect(venue.website, 'https://testvenue.com');
        expect(venue.operatingHours, isNotNull);
        expect(venue.operatingHours!['monday']['open'], '09:00');
      });
    });

    group('Firestore Serialization', () {
      test('converts venue model to Firestore format', () {
        final now = DateTime.now();
        final venue = VenueModel(
          id: 'venue123',
          name: 'Test Venue',
          description: 'A great test venue',
          category: 'restaurant',
          address: '123 Test St',
          latitude: 33.5731,
          longitude: -7.5898,
          photoUrls: ['photo1.jpg'],
          pricePerHour: 500.0,
          currency: 'MAD',
          rating: 4.5,
          reviewCount: 120,
          ownerId: 'owner123',
          amenities: ['wifi'],
          capacity: 50,
          availability: {'monday': true},
          createdAt: now,
          updatedAt: now,
          isActive: true,
        );

        final data = venue.toFirestore();

        expect(data['name'], 'Test Venue');
        expect(data['description'], 'A great test venue');
        expect(data['category'], 'restaurant');
        expect(data['address'], '123 Test St');
        expect(data['latitude'], 33.5731);
        expect(data['longitude'], -7.5898);
        expect(data['photoUrls'], ['photo1.jpg']);
        expect(data['pricePerHour'], 500.0);
        expect(data['currency'], 'MAD');
        expect(data['rating'], 4.5);
        expect(data['reviewCount'], 120);
        expect(data['ownerId'], 'owner123');
        expect(data['amenities'], ['wifi']);
        expect(data['capacity'], 50);
        expect(data['availability'], {'monday': true});
        expect(data['isActive'], true);
        expect(data['createdAt'], isA<Timestamp>());
        expect(data['updatedAt'], isA<Timestamp>());
      });

      test('converts venue model with optional fields to Firestore', () {
        final now = DateTime.now();
        final venue = VenueModel(
          id: 'venue123',
          name: 'Test Venue',
          description: 'Description',
          category: 'restaurant',
          address: '123 Test St',
          latitude: 33.5731,
          longitude: -7.5898,
          photoUrls: [],
          pricePerHour: 500.0,
          currency: 'MAD',
          rating: 4.5,
          reviewCount: 120,
          ownerId: 'owner123',
          amenities: [],
          capacity: 50,
          availability: {},
          createdAt: now,
          updatedAt: now,
          isActive: true,
          phoneNumber: '+212-123-456-789',
          email: 'venue@example.com',
          website: 'https://testvenue.com',
          operatingHours: {'monday': {'open': '09:00', 'close': '18:00'}},
        );

        final data = venue.toFirestore();

        expect(data['phoneNumber'], '+212-123-456-789');
        expect(data['email'], 'venue@example.com');
        expect(data['website'], 'https://testvenue.com');
        expect(data['operatingHours'], isNotNull);
      });

      test('excludes null optional fields from Firestore', () {
        final now = DateTime.now();
        final venue = VenueModel(
          id: 'venue123',
          name: 'Test Venue',
          description: 'Description',
          category: 'restaurant',
          address: '123 Test St',
          latitude: 33.5731,
          longitude: -7.5898,
          photoUrls: [],
          pricePerHour: 500.0,
          currency: 'MAD',
          rating: 4.5,
          reviewCount: 120,
          ownerId: 'owner123',
          amenities: [],
          capacity: 50,
          availability: {},
          createdAt: now,
          updatedAt: now,
          isActive: true,
        );

        final data = venue.toFirestore();

        expect(data.containsKey('phoneNumber'), false);
        expect(data.containsKey('email'), false);
        expect(data.containsKey('website'), false);
        expect(data.containsKey('operatingHours'), false);
      });
    });

    group('Firestore Deserialization', () {
      test('creates venue model from Firestore snapshot', () {
        final now = DateTime.now();
        final mockSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();

        when(() => mockSnapshot.id).thenReturn('venue123');
        when(() => mockSnapshot.data()).thenReturn({
          'name': 'Test Venue',
          'description': 'A great test venue',
          'category': 'restaurant',
          'address': '123 Test St',
          'latitude': 33.5731,
          'longitude': -7.5898,
          'photoUrls': ['photo1.jpg', 'photo2.jpg'],
          'pricePerHour': 500.0,
          'currency': 'MAD',
          'rating': 4.5,
          'reviewCount': 120,
          'ownerId': 'owner123',
          'amenities': ['wifi', 'parking'],
          'capacity': 50,
          'availability': {'monday': true, 'tuesday': false},
          'createdAt': Timestamp.fromDate(now),
          'updatedAt': Timestamp.fromDate(now),
          'isActive': true,
        });

        final venue = VenueModel.fromFirestore(mockSnapshot);

        expect(venue.id, 'venue123');
        expect(venue.name, 'Test Venue');
        expect(venue.description, 'A great test venue');
        expect(venue.category, 'restaurant');
        expect(venue.pricePerHour, 500.0);
        expect(venue.rating, 4.5);
        expect(venue.reviewCount, 120);
        expect(venue.amenities, ['wifi', 'parking']);
        expect(venue.capacity, 50);
        expect(venue.isActive, true);
      });

      test('handles missing fields with defaults', () {
        final mockSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();

        when(() => mockSnapshot.id).thenReturn('venue123');
        when(() => mockSnapshot.data()).thenReturn({});

        final venue = VenueModel.fromFirestore(mockSnapshot);

        expect(venue.id, 'venue123');
        expect(venue.name, '');
        expect(venue.description, '');
        expect(venue.category, '');
        expect(venue.address, '');
        expect(venue.latitude, 0.0);
        expect(venue.longitude, 0.0);
        expect(venue.photoUrls, []);
        expect(venue.pricePerHour, 0.0);
        expect(venue.currency, 'MAD');
        expect(venue.rating, 0.0);
        expect(venue.reviewCount, 0);
        expect(venue.ownerId, '');
        expect(venue.amenities, []);
        expect(venue.capacity, 0);
        expect(venue.availability, {});
        expect(venue.isActive, true);
      });

      test('parses optional fields from Firestore', () {
        final now = DateTime.now();
        final mockSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();

        when(() => mockSnapshot.id).thenReturn('venue123');
        when(() => mockSnapshot.data()).thenReturn({
          'name': 'Test Venue',
          'description': 'Description',
          'category': 'restaurant',
          'address': '123 Test St',
          'latitude': 33.5731,
          'longitude': -7.5898,
          'photoUrls': [],
          'pricePerHour': 500.0,
          'currency': 'MAD',
          'rating': 4.5,
          'reviewCount': 120,
          'ownerId': 'owner123',
          'amenities': [],
          'capacity': 50,
          'availability': {},
          'createdAt': Timestamp.fromDate(now),
          'updatedAt': Timestamp.fromDate(now),
          'isActive': true,
          'phoneNumber': '+212-123-456-789',
          'email': 'venue@example.com',
          'website': 'https://testvenue.com',
          'operatingHours': {'monday': {'open': '09:00', 'close': '18:00'}},
        });

        final venue = VenueModel.fromFirestore(mockSnapshot);

        expect(venue.phoneNumber, '+212-123-456-789');
        expect(venue.email, 'venue@example.com');
        expect(venue.website, 'https://testvenue.com');
        expect(venue.operatingHours, isNotNull);
      });

      test('handles integer values as doubles', () {
        final mockSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();

        when(() => mockSnapshot.id).thenReturn('venue123');
        when(() => mockSnapshot.data()).thenReturn({
          'name': 'Test',
          'latitude': 33, // Integer instead of double
          'longitude': -7, // Integer instead of double
          'pricePerHour': 500, // Integer instead of double
          'rating': 4, // Integer instead of double
        });

        final venue = VenueModel.fromFirestore(mockSnapshot);

        expect(venue.latitude, 33.0);
        expect(venue.longitude, -7.0);
        expect(venue.pricePerHour, 500.0);
        expect(venue.rating, 4.0);
      });
    });

    group('Copy With', () {
      test('creates copy with updated fields', () {
        final now = DateTime.now();
        final venue = VenueModel(
          id: 'venue123',
          name: 'Test Venue',
          description: 'Description',
          category: 'restaurant',
          address: '123 Test St',
          latitude: 33.5731,
          longitude: -7.5898,
          photoUrls: [],
          pricePerHour: 500.0,
          currency: 'MAD',
          rating: 4.5,
          reviewCount: 120,
          ownerId: 'owner123',
          amenities: [],
          capacity: 50,
          availability: {},
          createdAt: now,
          updatedAt: now,
          isActive: true,
        );

        final updated = venue.copyWith(
          name: 'Updated Venue',
          rating: 4.8,
          reviewCount: 150,
        );

        expect(updated.name, 'Updated Venue');
        expect(updated.rating, 4.8);
        expect(updated.reviewCount, 150);
        expect(updated.id, venue.id); // Unchanged
        expect(updated.pricePerHour, venue.pricePerHour); // Unchanged
      });

      test('copyWith preserves original values when no changes', () {
        final now = DateTime.now();
        final venue = VenueModel(
          id: 'venue123',
          name: 'Test Venue',
          description: 'Description',
          category: 'restaurant',
          address: '123 Test St',
          latitude: 33.5731,
          longitude: -7.5898,
          photoUrls: ['photo1.jpg'],
          pricePerHour: 500.0,
          currency: 'MAD',
          rating: 4.5,
          reviewCount: 120,
          ownerId: 'owner123',
          amenities: ['wifi'],
          capacity: 50,
          availability: {'monday': true},
          createdAt: now,
          updatedAt: now,
          isActive: true,
        );

        final copy = venue.copyWith();

        expect(copy.id, venue.id);
        expect(copy.name, venue.name);
        expect(copy.rating, venue.rating);
        expect(copy.photoUrls, venue.photoUrls);
        expect(copy.amenities, venue.amenities);
        expect(copy.availability, venue.availability);
      });
    });
  });

  group('VenueReviewModel', () {
    group('Model Creation', () {
      test('creates review model with all required fields', () {
        final now = DateTime.now();
        final review = VenueReviewModel(
          id: 'review123',
          venueId: 'venue123',
          userId: 'user123',
          userName: 'John Doe',
          rating: 4.5,
          comment: 'Great venue!',
          createdAt: now,
        );

        expect(review.id, 'review123');
        expect(review.venueId, 'venue123');
        expect(review.userId, 'user123');
        expect(review.userName, 'John Doe');
        expect(review.rating, 4.5);
        expect(review.comment, 'Great venue!');
        expect(review.createdAt, now);
        expect(review.userPhotoUrl, isNull);
        expect(review.photoUrls, isNull);
      });

      test('creates review model with optional fields', () {
        final now = DateTime.now();
        final review = VenueReviewModel(
          id: 'review123',
          venueId: 'venue123',
          userId: 'user123',
          userName: 'John Doe',
          userPhotoUrl: 'https://example.com/photo.jpg',
          rating: 4.5,
          comment: 'Great venue!',
          createdAt: now,
          photoUrls: ['review1.jpg', 'review2.jpg'],
        );

        expect(review.userPhotoUrl, 'https://example.com/photo.jpg');
        expect(review.photoUrls, ['review1.jpg', 'review2.jpg']);
      });
    });

    group('Firestore Serialization', () {
      test('converts review model to Firestore format', () {
        final now = DateTime.now();
        final review = VenueReviewModel(
          id: 'review123',
          venueId: 'venue123',
          userId: 'user123',
          userName: 'John Doe',
          rating: 4.5,
          comment: 'Great venue!',
          createdAt: now,
        );

        final data = review.toFirestore();

        expect(data['venueId'], 'venue123');
        expect(data['userId'], 'user123');
        expect(data['userName'], 'John Doe');
        expect(data['rating'], 4.5);
        expect(data['comment'], 'Great venue!');
        expect(data['createdAt'], isA<Timestamp>());
        expect(data.containsKey('userPhotoUrl'), false);
        expect(data.containsKey('photoUrls'), false);
      });

      test('includes optional fields in Firestore', () {
        final now = DateTime.now();
        final review = VenueReviewModel(
          id: 'review123',
          venueId: 'venue123',
          userId: 'user123',
          userName: 'John Doe',
          userPhotoUrl: 'https://example.com/photo.jpg',
          rating: 4.5,
          comment: 'Great venue!',
          createdAt: now,
          photoUrls: ['review1.jpg'],
        );

        final data = review.toFirestore();

        expect(data['userPhotoUrl'], 'https://example.com/photo.jpg');
        expect(data['photoUrls'], ['review1.jpg']);
      });
    });

    group('Firestore Deserialization', () {
      test('creates review model from Firestore snapshot', () {
        final now = DateTime.now();
        final mockSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();

        when(() => mockSnapshot.id).thenReturn('review123');
        when(() => mockSnapshot.data()).thenReturn({
          'venueId': 'venue123',
          'userId': 'user123',
          'userName': 'John Doe',
          'rating': 4.5,
          'comment': 'Great venue!',
          'createdAt': Timestamp.fromDate(now),
        });

        final review = VenueReviewModel.fromFirestore(mockSnapshot);

        expect(review.id, 'review123');
        expect(review.venueId, 'venue123');
        expect(review.userId, 'user123');
        expect(review.userName, 'John Doe');
        expect(review.rating, 4.5);
        expect(review.comment, 'Great venue!');
      });

      test('handles missing fields with defaults', () {
        final mockSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();

        when(() => mockSnapshot.id).thenReturn('review123');
        when(() => mockSnapshot.data()).thenReturn({});

        final review = VenueReviewModel.fromFirestore(mockSnapshot);

        expect(review.id, 'review123');
        expect(review.venueId, '');
        expect(review.userId, '');
        expect(review.userName, '');
        expect(review.rating, 0.0);
        expect(review.comment, '');
        expect(review.userPhotoUrl, isNull);
        expect(review.photoUrls, isNull);
      });

      test('parses optional fields from Firestore', () {
        final now = DateTime.now();
        final mockSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();

        when(() => mockSnapshot.id).thenReturn('review123');
        when(() => mockSnapshot.data()).thenReturn({
          'venueId': 'venue123',
          'userId': 'user123',
          'userName': 'John Doe',
          'userPhotoUrl': 'https://example.com/photo.jpg',
          'rating': 4.5,
          'comment': 'Great venue!',
          'createdAt': Timestamp.fromDate(now),
          'photoUrls': ['review1.jpg', 'review2.jpg'],
        });

        final review = VenueReviewModel.fromFirestore(mockSnapshot);

        expect(review.userPhotoUrl, 'https://example.com/photo.jpg');
        expect(review.photoUrls, ['review1.jpg', 'review2.jpg']);
      });

      test('handles integer rating as double', () {
        final mockSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();

        when(() => mockSnapshot.id).thenReturn('review123');
        when(() => mockSnapshot.data()).thenReturn({
          'rating': 5, // Integer instead of double
        });

        final review = VenueReviewModel.fromFirestore(mockSnapshot);

        expect(review.rating, 5.0);
      });
    });
  });
}
