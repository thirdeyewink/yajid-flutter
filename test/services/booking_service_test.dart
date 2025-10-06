import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yajid/models/booking_model.dart';

// Mock classes
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
// ignore: subtype_of_sealed_class
class MockCollectionReference<T> extends Mock implements CollectionReference<T> {}
// ignore: subtype_of_sealed_class
class MockDocumentSnapshot<T> extends Mock implements DocumentSnapshot<T> {}
class MockQuerySnapshot<T> extends Mock implements QuerySnapshot<T> {}

void main() {
  group('BookingService', () {
    group('BookingModel', () {
      test('creates booking model with all required fields', () {
        final now = DateTime.now();
        final startTime = now.add(const Duration(days: 1));
        final endTime = startTime.add(const Duration(hours: 2));

        final booking = BookingModel(
          id: 'booking123',
          userId: 'user123',
          venueId: 'venue123',
          venueName: 'Test Venue',
          startTime: startTime,
          endTime: endTime,
          numberOfPeople: 10,
          totalPrice: 200.0,
          currency: 'MAD',
          status: BookingStatus.pending,
          createdAt: now,
          updatedAt: now,
        );

        expect(booking.id, 'booking123');
        expect(booking.userId, 'user123');
        expect(booking.venueId, 'venue123');
        expect(booking.venueName, 'Test Venue');
        expect(booking.numberOfPeople, 10);
        expect(booking.totalPrice, 200.0);
        expect(booking.currency, 'MAD');
        expect(booking.status, BookingStatus.pending);
      });

      test('calculates duration in hours correctly', () {
        final startTime = DateTime(2025, 1, 1, 10, 0);
        final endTime = DateTime(2025, 1, 1, 12, 30);

        final booking = BookingModel(
          id: 'booking123',
          userId: 'user123',
          venueId: 'venue123',
          venueName: 'Test Venue',
          startTime: startTime,
          endTime: endTime,
          numberOfPeople: 10,
          totalPrice: 200.0,
          currency: 'MAD',
          status: BookingStatus.pending,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(booking.durationInHours, 2.5);
      });

      test('identifies upcoming bookings correctly', () {
        final futureStart = DateTime.now().add(const Duration(hours: 2));
        final futureEnd = futureStart.add(const Duration(hours: 2));

        final booking = BookingModel(
          id: 'booking123',
          userId: 'user123',
          venueId: 'venue123',
          venueName: 'Test Venue',
          startTime: futureStart,
          endTime: futureEnd,
          numberOfPeople: 10,
          totalPrice: 200.0,
          currency: 'MAD',
          status: BookingStatus.confirmed,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(booking.isUpcoming, isTrue);
        expect(booking.isPast, isFalse);
        expect(booking.isActive, isFalse);
      });

      test('identifies past bookings correctly', () {
        final pastStart = DateTime.now().subtract(const Duration(days: 1));
        final pastEnd = pastStart.add(const Duration(hours: 2));

        final booking = BookingModel(
          id: 'booking123',
          userId: 'user123',
          venueId: 'venue123',
          venueName: 'Test Venue',
          startTime: pastStart,
          endTime: pastEnd,
          numberOfPeople: 10,
          totalPrice: 200.0,
          currency: 'MAD',
          status: BookingStatus.completed,
          createdAt: pastStart,
          updatedAt: pastStart,
        );

        expect(booking.isPast, isTrue);
        expect(booking.isUpcoming, isFalse);
      });

      test('identifies active bookings correctly', () {
        final activeStart = DateTime.now().subtract(const Duration(hours: 1));
        final activeEnd = DateTime.now().add(const Duration(hours: 1));

        final booking = BookingModel(
          id: 'booking123',
          userId: 'user123',
          venueId: 'venue123',
          venueName: 'Test Venue',
          startTime: activeStart,
          endTime: activeEnd,
          numberOfPeople: 10,
          totalPrice: 200.0,
          currency: 'MAD',
          status: BookingStatus.confirmed,
          createdAt: activeStart,
          updatedAt: activeStart,
        );

        expect(booking.isActive, isTrue);
        expect(booking.isPast, isFalse);
        expect(booking.isUpcoming, isFalse);
      });

      test('determines if booking can be cancelled', () {
        final booking = BookingModel(
          id: 'booking123',
          userId: 'user123',
          venueId: 'venue123',
          venueName: 'Test Venue',
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(hours: 2)),
          numberOfPeople: 10,
          totalPrice: 200.0,
          currency: 'MAD',
          status: BookingStatus.confirmed,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(booking.canBeCancelled, isTrue);

        final completedBooking = booking.copyWith(status: BookingStatus.completed);
        expect(completedBooking.canBeCancelled, isFalse);

        final cancelledBooking = booking.copyWith(status: BookingStatus.cancelled);
        expect(cancelledBooking.canBeCancelled, isFalse);
      });

      test('converts booking model to Firestore format', () {
        final now = DateTime.now();
        final booking = BookingModel(
          id: 'booking123',
          userId: 'user123',
          venueId: 'venue123',
          venueName: 'Test Venue',
          startTime: now,
          endTime: now.add(const Duration(hours: 2)),
          numberOfPeople: 10,
          totalPrice: 200.0,
          currency: 'MAD',
          status: BookingStatus.pending,
          specialRequests: 'Wheelchair accessible',
          createdAt: now,
          updatedAt: now,
        );

        final data = booking.toFirestore();

        expect(data['userId'], 'user123');
        expect(data['venueId'], 'venue123');
        expect(data['venueName'], 'Test Venue');
        expect(data['numberOfPeople'], 10);
        expect(data['totalPrice'], 200.0);
        expect(data['currency'], 'MAD');
        expect(data['status'], 'pending');
        expect(data['specialRequests'], 'Wheelchair accessible');
        expect(data['startTime'], isA<Timestamp>());
        expect(data['endTime'], isA<Timestamp>());
      });

      test('creates booking model from Firestore snapshot', () {
        final now = DateTime.now();
        final mockSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();

        when(() => mockSnapshot.id).thenReturn('booking123');
        when(() => mockSnapshot.data()).thenReturn({
          'userId': 'user123',
          'venueId': 'venue123',
          'venueName': 'Test Venue',
          'startTime': Timestamp.fromDate(now),
          'endTime': Timestamp.fromDate(now.add(const Duration(hours: 2))),
          'numberOfPeople': 10,
          'totalPrice': 200.0,
          'currency': 'MAD',
          'status': 'pending',
          'createdAt': Timestamp.fromDate(now),
          'updatedAt': Timestamp.fromDate(now),
        });

        final booking = BookingModel.fromFirestore(mockSnapshot);

        expect(booking.id, 'booking123');
        expect(booking.userId, 'user123');
        expect(booking.venueId, 'venue123');
        expect(booking.venueName, 'Test Venue');
        expect(booking.numberOfPeople, 10);
        expect(booking.totalPrice, 200.0);
        expect(booking.status, BookingStatus.pending);
      });
    });
  });
}
