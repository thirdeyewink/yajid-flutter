import 'package:flutter_bloc/flutter_bloc.dart';
import 'booking_event.dart';
import 'booking_state.dart';
import '../../services/booking_service.dart';
import 'dart:async';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final BookingService _bookingService;
  StreamSubscription? _bookingsSubscription;

  BookingBloc({BookingService? bookingService})
      : _bookingService = bookingService ?? BookingService(),
        super(const BookingInitial()) {
    on<LoadUserBookings>(_onLoadUserBookings);
    on<LoadUpcomingBookings>(_onLoadUpcomingBookings);
    on<LoadPastBookings>(_onLoadPastBookings);
    on<LoadBookingById>(_onLoadBookingById);
    on<CreateBooking>(_onCreateBooking);
    on<ConfirmBooking>(_onConfirmBooking);
    on<CancelBooking>(_onCancelBooking);
    on<LoadBookingStats>(_onLoadBookingStats);
  }

  Future<void> _onLoadUserBookings(
    LoadUserBookings event,
    Emitter<BookingState> emit,
  ) async {
    emit(const BookingLoading());
    await _bookingsSubscription?.cancel();

    _bookingsSubscription = _bookingService.getUserBookings(event.userId).listen(
      (bookings) {
        emit(BookingsLoaded(bookings));
      },
      onError: (error) {
        emit(BookingError('Failed to load bookings: $error'));
      },
    );
  }

  Future<void> _onLoadUpcomingBookings(
    LoadUpcomingBookings event,
    Emitter<BookingState> emit,
  ) async {
    emit(const BookingLoading());
    await _bookingsSubscription?.cancel();

    _bookingsSubscription = _bookingService.getUpcomingBookings(event.userId).listen(
      (bookings) {
        emit(BookingsLoaded(bookings));
      },
      onError: (error) {
        emit(BookingError('Failed to load upcoming bookings: $error'));
      },
    );
  }

  Future<void> _onLoadPastBookings(
    LoadPastBookings event,
    Emitter<BookingState> emit,
  ) async {
    emit(const BookingLoading());
    await _bookingsSubscription?.cancel();

    _bookingsSubscription = _bookingService.getPastBookings(event.userId).listen(
      (bookings) {
        emit(BookingsLoaded(bookings));
      },
      onError: (error) {
        emit(BookingError('Failed to load past bookings: $error'));
      },
    );
  }

  Future<void> _onLoadBookingById(
    LoadBookingById event,
    Emitter<BookingState> emit,
  ) async {
    emit(const BookingLoading());
    try {
      final booking = await _bookingService.getBookingById(event.bookingId);
      if (booking != null) {
        emit(BookingDetailLoaded(booking));
      } else {
        emit(const BookingError('Booking not found'));
      }
    } catch (e) {
      emit(BookingError('Failed to load booking: $e'));
    }
  }

  Future<void> _onCreateBooking(
    CreateBooking event,
    Emitter<BookingState> emit,
  ) async {
    emit(const BookingLoading());
    try {
      final bookingId = await _bookingService.createBooking(event.booking);
      if (bookingId != null) {
        emit(BookingCreated(bookingId));
      } else {
        emit(const BookingError('Failed to create booking. Venue may not be available.'));
      }
    } catch (e) {
      emit(BookingError('Failed to create booking: $e'));
    }
  }

  Future<void> _onConfirmBooking(
    ConfirmBooking event,
    Emitter<BookingState> emit,
  ) async {
    emit(const BookingLoading());
    try {
      final success = await _bookingService.confirmBooking(event.bookingId);
      if (success) {
        emit(const BookingConfirmed());
      } else {
        emit(const BookingError('Failed to confirm booking'));
      }
    } catch (e) {
      emit(BookingError('Failed to confirm booking: $e'));
    }
  }

  Future<void> _onCancelBooking(
    CancelBooking event,
    Emitter<BookingState> emit,
  ) async {
    emit(const BookingLoading());
    try {
      final success = await _bookingService.cancelBooking(
        event.bookingId,
        event.cancellationReason,
      );
      if (success) {
        emit(const BookingCancelled());
      } else {
        emit(const BookingError('Failed to cancel booking'));
      }
    } catch (e) {
      emit(BookingError('Failed to cancel booking: $e'));
    }
  }

  Future<void> _onLoadBookingStats(
    LoadBookingStats event,
    Emitter<BookingState> emit,
  ) async {
    emit(const BookingLoading());
    try {
      final stats = await _bookingService.getUserBookingStats(event.userId);
      emit(BookingStatsLoaded(stats));
    } catch (e) {
      emit(BookingError('Failed to load booking stats: $e'));
    }
  }

  @override
  Future<void> close() {
    _bookingsSubscription?.cancel();
    return super.close();
  }
}
