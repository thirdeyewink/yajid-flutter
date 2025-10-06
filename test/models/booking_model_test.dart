import 'package:flutter_test/flutter_test.dart';
import 'package:yajid/models/booking_model.dart';

void main() {
  group('BookingModel', () {
    test('creates booking with all fields', () {
      final now = DateTime.now();
      final start = now.add(Duration(hours: 2));
      final end = start.add(Duration(hours: 3));

      final booking = BookingModel(
        id: 'booking123',
        userId: 'user456',
        venueId: 'venue789',
        venueName: 'Test Venue',
        startTime: start,
        endTime: end,
        numberOfPeople: 4,
        totalPrice: 500.0,
        currency: 'MAD',
        status: BookingStatus.confirmed,
        specialRequests: 'Window seat please',
        createdAt: now,
        updatedAt: now,
        paymentId: 'payment123',
      );

      expect(booking.id, 'booking123');
      expect(booking.userId, 'user456');
      expect(booking.venueId, 'venue789');
      expect(booking.venueName, 'Test Venue');
      expect(booking.startTime, start);
      expect(booking.endTime, end);
      expect(booking.numberOfPeople, 4);
      expect(booking.totalPrice, 500.0);
      expect(booking.currency, 'MAD');
      expect(booking.status, BookingStatus.confirmed);
      expect(booking.specialRequests, 'Window seat please');
      expect(booking.paymentId, 'payment123');
    });

    test('creates booking without optional fields', () {
      final now = DateTime.now();
      final start = now.add(Duration(hours: 1));
      final end = start.add(Duration(hours: 2));

      final booking = BookingModel(
        id: 'booking123',
        userId: 'user456',
        venueId: 'venue789',
        venueName: 'Test Venue',
        startTime: start,
        endTime: end,
        numberOfPeople: 2,
        totalPrice: 200.0,
        currency: 'MAD',
        status: BookingStatus.pending,
        createdAt: now,
        updatedAt: now,
      );

      expect(booking.specialRequests, null);
      expect(booking.paymentId, null);
      expect(booking.cancellationReason, null);
      expect(booking.cancelledAt, null);
    });

    test('copyWith updates specified fields', () {
      final now = DateTime.now();
      final start = now.add(Duration(hours: 1));
      final end = start.add(Duration(hours: 2));

      final original = BookingModel(
        id: 'booking123',
        userId: 'user456',
        venueId: 'venue789',
        venueName: 'Test Venue',
        startTime: start,
        endTime: end,
        numberOfPeople: 2,
        totalPrice: 200.0,
        currency: 'MAD',
        status: BookingStatus.pending,
        createdAt: now,
        updatedAt: now,
      );

      final updated = original.copyWith(
        status: BookingStatus.confirmed,
        numberOfPeople: 4,
        totalPrice: 400.0,
      );

      expect(updated.status, BookingStatus.confirmed);
      expect(updated.numberOfPeople, 4);
      expect(updated.totalPrice, 400.0);
      expect(updated.id, original.id); // Unchanged
      expect(updated.userId, original.userId); // Unchanged
    });
  });

  group('BookingStatus', () {
    test('has all expected statuses', () {
      expect(BookingStatus.values.contains(BookingStatus.pending), true);
      expect(BookingStatus.values.contains(BookingStatus.confirmed), true);
      expect(BookingStatus.values.contains(BookingStatus.cancelled), true);
      expect(BookingStatus.values.contains(BookingStatus.completed), true);
      expect(BookingStatus.values.contains(BookingStatus.noShow), true);
    });
  });

  group('durationInHours', () {
    test('calculates duration correctly for whole hours', () {
      final start = DateTime(2025, 6, 15, 14, 0);
      final end = DateTime(2025, 6, 15, 17, 0); // 3 hours later

      final booking = BookingModel(
        id: 'booking123',
        userId: 'user456',
        venueId: 'venue789',
        venueName: 'Test Venue',
        startTime: start,
        endTime: end,
        numberOfPeople: 2,
        totalPrice: 300.0,
        currency: 'MAD',
        status: BookingStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(booking.durationInHours, 3.0);
    });

    test('calculates duration correctly for partial hours', () {
      final start = DateTime(2025, 6, 15, 14, 0);
      final end = DateTime(2025, 6, 15, 15, 30); // 1.5 hours later

      final booking = BookingModel(
        id: 'booking123',
        userId: 'user456',
        venueId: 'venue789',
        venueName: 'Test Venue',
        startTime: start,
        endTime: end,
        numberOfPeople: 2,
        totalPrice: 150.0,
        currency: 'MAD',
        status: BookingStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(booking.durationInHours, 1.5);
    });

    test('calculates duration for short bookings', () {
      final start = DateTime(2025, 6, 15, 14, 0);
      final end = DateTime(2025, 6, 15, 14, 15); // 15 minutes

      final booking = BookingModel(
        id: 'booking123',
        userId: 'user456',
        venueId: 'venue789',
        venueName: 'Test Venue',
        startTime: start,
        endTime: end,
        numberOfPeople: 2,
        totalPrice: 50.0,
        currency: 'MAD',
        status: BookingStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(booking.durationInHours, 0.25); // 15 minutes = 0.25 hours
    });
  });

  group('isPast', () {
    test('returns true for past bookings', () {
      final past = DateTime.now().subtract(Duration(days: 1));
      final booking = BookingModel(
        id: 'booking123',
        userId: 'user456',
        venueId: 'venue789',
        venueName: 'Test Venue',
        startTime: past.subtract(Duration(hours: 2)),
        endTime: past,
        numberOfPeople: 2,
        totalPrice: 200.0,
        currency: 'MAD',
        status: BookingStatus.completed,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(booking.isPast, true);
    });

    test('returns false for future bookings', () {
      final future = DateTime.now().add(Duration(days: 1));
      final booking = BookingModel(
        id: 'booking123',
        userId: 'user456',
        venueId: 'venue789',
        venueName: 'Test Venue',
        startTime: future,
        endTime: future.add(Duration(hours: 2)),
        numberOfPeople: 2,
        totalPrice: 200.0,
        currency: 'MAD',
        status: BookingStatus.confirmed,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(booking.isPast, false);
    });
  });

  group('isUpcoming', () {
    test('returns true for confirmed future bookings', () {
      final future = DateTime.now().add(Duration(hours: 2));
      final booking = BookingModel(
        id: 'booking123',
        userId: 'user456',
        venueId: 'venue789',
        venueName: 'Test Venue',
        startTime: future,
        endTime: future.add(Duration(hours: 2)),
        numberOfPeople: 2,
        totalPrice: 200.0,
        currency: 'MAD',
        status: BookingStatus.confirmed,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(booking.isUpcoming, true);
    });

    test('returns false for pending future bookings', () {
      final future = DateTime.now().add(Duration(hours: 2));
      final booking = BookingModel(
        id: 'booking123',
        userId: 'user456',
        venueId: 'venue789',
        venueName: 'Test Venue',
        startTime: future,
        endTime: future.add(Duration(hours: 2)),
        numberOfPeople: 2,
        totalPrice: 200.0,
        currency: 'MAD',
        status: BookingStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(booking.isUpcoming, false);
    });

    test('returns false for past confirmed bookings', () {
      final past = DateTime.now().subtract(Duration(days: 1));
      final booking = BookingModel(
        id: 'booking123',
        userId: 'user456',
        venueId: 'venue789',
        venueName: 'Test Venue',
        startTime: past,
        endTime: past.add(Duration(hours: 2)),
        numberOfPeople: 2,
        totalPrice: 200.0,
        currency: 'MAD',
        status: BookingStatus.confirmed,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(booking.isUpcoming, false);
    });

    test('returns false for cancelled future bookings', () {
      final future = DateTime.now().add(Duration(hours: 2));
      final booking = BookingModel(
        id: 'booking123',
        userId: 'user456',
        venueId: 'venue789',
        venueName: 'Test Venue',
        startTime: future,
        endTime: future.add(Duration(hours: 2)),
        numberOfPeople: 2,
        totalPrice: 200.0,
        currency: 'MAD',
        status: BookingStatus.cancelled,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(booking.isUpcoming, false);
    });
  });

  group('isActive', () {
    test('returns true for confirmed current bookings', () {
      final now = DateTime.now();
      final start = now.subtract(Duration(minutes: 30));
      final end = now.add(Duration(minutes: 30));

      final booking = BookingModel(
        id: 'booking123',
        userId: 'user456',
        venueId: 'venue789',
        venueName: 'Test Venue',
        startTime: start,
        endTime: end,
        numberOfPeople: 2,
        totalPrice: 200.0,
        currency: 'MAD',
        status: BookingStatus.confirmed,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(booking.isActive, true);
    });

    test('returns false for pending current bookings', () {
      final now = DateTime.now();
      final start = now.subtract(Duration(minutes: 30));
      final end = now.add(Duration(minutes: 30));

      final booking = BookingModel(
        id: 'booking123',
        userId: 'user456',
        venueId: 'venue789',
        venueName: 'Test Venue',
        startTime: start,
        endTime: end,
        numberOfPeople: 2,
        totalPrice: 200.0,
        currency: 'MAD',
        status: BookingStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(booking.isActive, false);
    });

    test('returns false for future confirmed bookings', () {
      final future = DateTime.now().add(Duration(hours: 2));
      final booking = BookingModel(
        id: 'booking123',
        userId: 'user456',
        venueId: 'venue789',
        venueName: 'Test Venue',
        startTime: future,
        endTime: future.add(Duration(hours: 2)),
        numberOfPeople: 2,
        totalPrice: 200.0,
        currency: 'MAD',
        status: BookingStatus.confirmed,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(booking.isActive, false);
    });

    test('returns false for past confirmed bookings', () {
      final past = DateTime.now().subtract(Duration(days: 1));
      final booking = BookingModel(
        id: 'booking123',
        userId: 'user456',
        venueId: 'venue789',
        venueName: 'Test Venue',
        startTime: past.subtract(Duration(hours: 2)),
        endTime: past,
        numberOfPeople: 2,
        totalPrice: 200.0,
        currency: 'MAD',
        status: BookingStatus.confirmed,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(booking.isActive, false);
    });
  });

  group('canBeCancelled', () {
    test('returns true for pending bookings', () {
      final future = DateTime.now().add(Duration(hours: 2));
      final booking = BookingModel(
        id: 'booking123',
        userId: 'user456',
        venueId: 'venue789',
        venueName: 'Test Venue',
        startTime: future,
        endTime: future.add(Duration(hours: 2)),
        numberOfPeople: 2,
        totalPrice: 200.0,
        currency: 'MAD',
        status: BookingStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(booking.canBeCancelled, true);
    });

    test('returns true for confirmed bookings', () {
      final future = DateTime.now().add(Duration(hours: 2));
      final booking = BookingModel(
        id: 'booking123',
        userId: 'user456',
        venueId: 'venue789',
        venueName: 'Test Venue',
        startTime: future,
        endTime: future.add(Duration(hours: 2)),
        numberOfPeople: 2,
        totalPrice: 200.0,
        currency: 'MAD',
        status: BookingStatus.confirmed,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(booking.canBeCancelled, true);
    });

    test('returns false for cancelled bookings', () {
      final future = DateTime.now().add(Duration(hours: 2));
      final booking = BookingModel(
        id: 'booking123',
        userId: 'user456',
        venueId: 'venue789',
        venueName: 'Test Venue',
        startTime: future,
        endTime: future.add(Duration(hours: 2)),
        numberOfPeople: 2,
        totalPrice: 200.0,
        currency: 'MAD',
        status: BookingStatus.cancelled,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(booking.canBeCancelled, false);
    });

    test('returns false for completed bookings', () {
      final past = DateTime.now().subtract(Duration(days: 1));
      final booking = BookingModel(
        id: 'booking123',
        userId: 'user456',
        venueId: 'venue789',
        venueName: 'Test Venue',
        startTime: past.subtract(Duration(hours: 2)),
        endTime: past,
        numberOfPeople: 2,
        totalPrice: 200.0,
        currency: 'MAD',
        status: BookingStatus.completed,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(booking.canBeCancelled, false);
    });

    test('returns false for no-show bookings', () {
      final past = DateTime.now().subtract(Duration(days: 1));
      final booking = BookingModel(
        id: 'booking123',
        userId: 'user456',
        venueId: 'venue789',
        venueName: 'Test Venue',
        startTime: past.subtract(Duration(hours: 2)),
        endTime: past,
        numberOfPeople: 2,
        totalPrice: 200.0,
        currency: 'MAD',
        status: BookingStatus.noShow,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(booking.canBeCancelled, false);
    });
  });

  group('Edge Cases', () {
    test('handles large number of people', () {
      final future = DateTime.now().add(Duration(hours: 2));
      final booking = BookingModel(
        id: 'booking123',
        userId: 'user456',
        venueId: 'venue789',
        venueName: 'Test Venue',
        startTime: future,
        endTime: future.add(Duration(hours: 3)),
        numberOfPeople: 100,
        totalPrice: 5000.0,
        currency: 'MAD',
        status: BookingStatus.confirmed,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(booking.numberOfPeople, 100);
      expect(booking.totalPrice, 5000.0);
    });

    test('handles long duration bookings', () {
      final start = DateTime(2025, 6, 15, 10, 0);
      final end = DateTime(2025, 6, 15, 22, 0); // 12 hours

      final booking = BookingModel(
        id: 'booking123',
        userId: 'user456',
        venueId: 'venue789',
        venueName: 'Test Venue',
        startTime: start,
        endTime: end,
        numberOfPeople: 50,
        totalPrice: 10000.0,
        currency: 'MAD',
        status: BookingStatus.confirmed,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(booking.durationInHours, 12.0);
    });

    test('handles different currencies', () {
      final future = DateTime.now().add(Duration(hours: 2));
      final booking = BookingModel(
        id: 'booking123',
        userId: 'user456',
        venueId: 'venue789',
        venueName: 'Test Venue',
        startTime: future,
        endTime: future.add(Duration(hours: 2)),
        numberOfPeople: 2,
        totalPrice: 100.0,
        currency: 'USD',
        status: BookingStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(booking.currency, 'USD');
    });

    test('handles cancelled booking with reason', () {
      final future = DateTime.now().add(Duration(hours: 2));
      final cancelTime = DateTime.now();

      final booking = BookingModel(
        id: 'booking123',
        userId: 'user456',
        venueId: 'venue789',
        venueName: 'Test Venue',
        startTime: future,
        endTime: future.add(Duration(hours: 2)),
        numberOfPeople: 2,
        totalPrice: 200.0,
        currency: 'MAD',
        status: BookingStatus.cancelled,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        cancellationReason: 'Customer request',
        cancelledAt: cancelTime,
      );

      expect(booking.status, BookingStatus.cancelled);
      expect(booking.cancellationReason, 'Customer request');
      expect(booking.cancelledAt, cancelTime);
    });
  });
}
