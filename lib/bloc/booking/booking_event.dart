import 'package:equatable/equatable.dart';
import '../../models/booking_model.dart';

abstract class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserBookings extends BookingEvent {
  final String userId;

  const LoadUserBookings(this.userId);

  @override
  List<Object?> get props => [userId];
}

class LoadUpcomingBookings extends BookingEvent {
  final String userId;

  const LoadUpcomingBookings(this.userId);

  @override
  List<Object?> get props => [userId];
}

class LoadPastBookings extends BookingEvent {
  final String userId;

  const LoadPastBookings(this.userId);

  @override
  List<Object?> get props => [userId];
}

class LoadBookingById extends BookingEvent {
  final String bookingId;

  const LoadBookingById(this.bookingId);

  @override
  List<Object?> get props => [bookingId];
}

class CreateBooking extends BookingEvent {
  final BookingModel booking;

  const CreateBooking(this.booking);

  @override
  List<Object?> get props => [booking];
}

class ConfirmBooking extends BookingEvent {
  final String bookingId;

  const ConfirmBooking(this.bookingId);

  @override
  List<Object?> get props => [bookingId];
}

class CancelBooking extends BookingEvent {
  final String bookingId;
  final String cancellationReason;

  const CancelBooking(this.bookingId, this.cancellationReason);

  @override
  List<Object?> get props => [bookingId, cancellationReason];
}

class LoadBookingStats extends BookingEvent {
  final String userId;

  const LoadBookingStats(this.userId);

  @override
  List<Object?> get props => [userId];
}
