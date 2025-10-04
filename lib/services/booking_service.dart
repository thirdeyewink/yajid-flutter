import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import '../models/booking_model.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger();

  static const String _bookingsCollection = 'bookings';

  /// Create a new booking
  Future<String?> createBooking(BookingModel booking) async {
    try {
      // Check if the venue is available for the time slot
      final isAvailable = await _checkVenueAvailability(
        booking.venueId,
        booking.startTime,
        booking.endTime,
      );

      if (!isAvailable) {
        _logger.w('Venue is not available for the selected time slot');
        return null;
      }

      final docRef = await _firestore
          .collection(_bookingsCollection)
          .add(booking.toFirestore());

      _logger.i('Booking created with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      _logger.e('Error creating booking: $e');
      return null;
    }
  }

  /// Get a booking by ID
  Future<BookingModel?> getBookingById(String bookingId) async {
    try {
      final doc = await _firestore
          .collection(_bookingsCollection)
          .doc(bookingId)
          .get();

      if (doc.exists) {
        return BookingModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      _logger.e('Error getting booking: $e');
      return null;
    }
  }

  /// Get all bookings for a user
  Stream<List<BookingModel>> getUserBookings(String userId) {
    try {
      return _firestore
          .collection(_bookingsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('startTime', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => BookingModel.fromFirestore(doc))
              .toList());
    } catch (e) {
      _logger.e('Error getting user bookings: $e');
      return Stream.value([]);
    }
  }

  /// Get upcoming bookings for a user
  Stream<List<BookingModel>> getUpcomingBookings(String userId) {
    try {
      return _firestore
          .collection(_bookingsCollection)
          .where('userId', isEqualTo: userId)
          .where('startTime', isGreaterThan: Timestamp.now())
          .where('status', whereIn: ['pending', 'confirmed'])
          .orderBy('startTime')
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => BookingModel.fromFirestore(doc))
              .toList());
    } catch (e) {
      _logger.e('Error getting upcoming bookings: $e');
      return Stream.value([]);
    }
  }

  /// Get past bookings for a user
  Stream<List<BookingModel>> getPastBookings(String userId) {
    try {
      return _firestore
          .collection(_bookingsCollection)
          .where('userId', isEqualTo: userId)
          .where('endTime', isLessThan: Timestamp.now())
          .orderBy('endTime', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => BookingModel.fromFirestore(doc))
              .toList());
    } catch (e) {
      _logger.e('Error getting past bookings: $e');
      return Stream.value([]);
    }
  }

  /// Get bookings for a specific venue
  Stream<List<BookingModel>> getVenueBookings(String venueId) {
    try {
      return _firestore
          .collection(_bookingsCollection)
          .where('venueId', isEqualTo: venueId)
          .orderBy('startTime', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => BookingModel.fromFirestore(doc))
              .toList());
    } catch (e) {
      _logger.e('Error getting venue bookings: $e');
      return Stream.value([]);
    }
  }

  /// Update booking status
  Future<bool> updateBookingStatus(
    String bookingId,
    BookingStatus status,
  ) async {
    try {
      await _firestore.collection(_bookingsCollection).doc(bookingId).update({
        'status': _statusToString(status),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _logger.i('Booking status updated: $bookingId -> $status');
      return true;
    } catch (e) {
      _logger.e('Error updating booking status: $e');
      return false;
    }
  }

  /// Confirm a booking
  Future<bool> confirmBooking(String bookingId) async {
    return await updateBookingStatus(bookingId, BookingStatus.confirmed);
  }

  /// Cancel a booking
  Future<bool> cancelBooking(
    String bookingId,
    String cancellationReason,
  ) async {
    try {
      await _firestore.collection(_bookingsCollection).doc(bookingId).update({
        'status': 'cancelled',
        'cancellationReason': cancellationReason,
        'cancelledAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _logger.i('Booking cancelled: $bookingId');
      return true;
    } catch (e) {
      _logger.e('Error cancelling booking: $e');
      return false;
    }
  }

  /// Complete a booking
  Future<bool> completeBooking(String bookingId) async {
    return await updateBookingStatus(bookingId, BookingStatus.completed);
  }

  /// Mark booking as no-show
  Future<bool> markAsNoShow(String bookingId) async {
    return await updateBookingStatus(bookingId, BookingStatus.noShow);
  }

  /// Update booking payment ID
  Future<bool> updateBookingPayment(String bookingId, String paymentId) async {
    try {
      await _firestore.collection(_bookingsCollection).doc(bookingId).update({
        'paymentId': paymentId,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _logger.i('Booking payment updated: $bookingId');
      return true;
    } catch (e) {
      _logger.e('Error updating booking payment: $e');
      return false;
    }
  }

  /// Check if venue is available for a time slot
  Future<bool> _checkVenueAvailability(
    String venueId,
    DateTime startTime,
    DateTime endTime,
  ) async {
    try {
      // Get all confirmed bookings for the venue that overlap with the requested time
      final snapshot = await _firestore
          .collection(_bookingsCollection)
          .where('venueId', isEqualTo: venueId)
          .where('status', whereIn: ['pending', 'confirmed'])
          .get();

      for (final doc in snapshot.docs) {
        final booking = BookingModel.fromFirestore(doc);

        // Check for time overlap
        final hasOverlap = startTime.isBefore(booking.endTime) &&
            endTime.isAfter(booking.startTime);

        if (hasOverlap) {
          _logger.w('Time slot overlap detected with booking: ${doc.id}');
          return false;
        }
      }

      return true;
    } catch (e) {
      _logger.e('Error checking venue availability: $e');
      return false;
    }
  }

  /// Get available time slots for a venue on a specific date
  Future<List<Map<String, DateTime>>> getAvailableTimeSlots({
    required String venueId,
    required DateTime date,
    int slotDurationMinutes = 60,
  }) async {
    try {
      // Define operating hours (can be customized per venue)
      final openingHour = 9;
      final closingHour = 22;

      // Get all bookings for the date
      final startOfDay = DateTime(date.year, date.month, date.day, openingHour);
      final endOfDay = DateTime(date.year, date.month, date.day, closingHour);

      final snapshot = await _firestore
          .collection(_bookingsCollection)
          .where('venueId', isEqualTo: venueId)
          .where('status', whereIn: ['pending', 'confirmed'])
          .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('startTime', isLessThan: Timestamp.fromDate(endOfDay))
          .get();

      final bookedSlots = snapshot.docs
          .map((doc) => BookingModel.fromFirestore(doc))
          .toList();

      // Generate all possible time slots
      final List<Map<String, DateTime>> availableSlots = [];
      DateTime currentSlot = startOfDay;

      while (currentSlot.isBefore(endOfDay)) {
        final slotEnd = currentSlot.add(Duration(minutes: slotDurationMinutes));

        // Check if this slot overlaps with any booking
        bool isAvailable = true;
        for (final booking in bookedSlots) {
          if (currentSlot.isBefore(booking.endTime) &&
              slotEnd.isAfter(booking.startTime)) {
            isAvailable = false;
            break;
          }
        }

        if (isAvailable) {
          availableSlots.add({
            'start': currentSlot,
            'end': slotEnd,
          });
        }

        currentSlot = slotEnd;
      }

      return availableSlots;
    } catch (e) {
      _logger.e('Error getting available time slots: $e');
      return [];
    }
  }

  String _statusToString(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return 'pending';
      case BookingStatus.confirmed:
        return 'confirmed';
      case BookingStatus.cancelled:
        return 'cancelled';
      case BookingStatus.completed:
        return 'completed';
      case BookingStatus.noShow:
        return 'noshow';
    }
  }

  /// Delete a booking (hard delete - use with caution)
  Future<bool> deleteBooking(String bookingId) async {
    try {
      await _firestore.collection(_bookingsCollection).doc(bookingId).delete();
      _logger.i('Booking deleted: $bookingId');
      return true;
    } catch (e) {
      _logger.e('Error deleting booking: $e');
      return false;
    }
  }

  /// Get booking statistics for a user
  Future<Map<String, int>> getUserBookingStats(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_bookingsCollection)
          .where('userId', isEqualTo: userId)
          .get();

      final bookings = snapshot.docs
          .map((doc) => BookingModel.fromFirestore(doc))
          .toList();

      return {
        'total': bookings.length,
        'upcoming': bookings.where((b) => b.isUpcoming).length,
        'completed': bookings.where((b) => b.status == BookingStatus.completed).length,
        'cancelled': bookings.where((b) => b.status == BookingStatus.cancelled).length,
      };
    } catch (e) {
      _logger.e('Error getting booking stats: $e');
      return {'total': 0, 'upcoming': 0, 'completed': 0, 'cancelled': 0};
    }
  }
}
