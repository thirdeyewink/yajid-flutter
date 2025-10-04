import 'package:equatable/equatable.dart';
import '../../models/booking_model.dart';

abstract class BookingState extends Equatable {
  const BookingState();

  @override
  List<Object?> get props => [];
}

class BookingInitial extends BookingState {
  const BookingInitial();
}

class BookingLoading extends BookingState {
  const BookingLoading();
}

class BookingsLoaded extends BookingState {
  final List<BookingModel> bookings;

  const BookingsLoaded(this.bookings);

  @override
  List<Object?> get props => [bookings];
}

class BookingDetailLoaded extends BookingState {
  final BookingModel booking;

  const BookingDetailLoaded(this.booking);

  @override
  List<Object?> get props => [booking];
}

class BookingCreated extends BookingState {
  final String bookingId;

  const BookingCreated(this.bookingId);

  @override
  List<Object?> get props => [bookingId];
}

class BookingConfirmed extends BookingState {
  const BookingConfirmed();
}

class BookingCancelled extends BookingState {
  const BookingCancelled();
}

class BookingStatsLoaded extends BookingState {
  final Map<String, int> stats;

  const BookingStatsLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

class BookingError extends BookingState {
  final String message;

  const BookingError(this.message);

  @override
  List<Object?> get props => [message];
}
