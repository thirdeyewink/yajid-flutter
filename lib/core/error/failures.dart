import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
///
/// Failures represent expected errors that can occur during normal operation
/// and should be handled gracefully by the UI.
abstract class Failure extends Equatable {
  final String message;
  final int? code;

  const Failure({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
}

/// Server-related failures
class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.code,
  });
}

/// Cache-related failures
class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.code,
  });
}

/// Network-related failures
class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.message,
    super.code,
  });
}

/// Authentication failures
class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.code,
  });

  // Common auth failure messages
  static const String invalidCredentials = 'Invalid email or password';
  static const String userNotFound = 'No user found with this email';
  static const String wrongPassword = 'Incorrect password';
  static const String emailAlreadyInUse = 'Email already in use';
  static const String weakPassword = 'Password is too weak';
  static const String userDisabled = 'This account has been disabled';
  static const String tooManyRequests = 'Too many attempts. Please try again later';
  static const String operationNotAllowed = 'This operation is not allowed';
  static const String invalidEmail = 'Invalid email address';
  static const String accountExistsWithDifferentCredential =
      'Account exists with different sign-in method';
  static const String invalidCredential = 'Invalid or expired credentials';
  static const String unauthorized = 'You are not authorized to perform this action';
  static const String sessionExpired = 'Your session has expired. Please log in again';
}

/// Validation failures
class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;

  const ValidationFailure({
    required super.message,
    super.code,
    this.fieldErrors,
  });

  @override
  List<Object?> get props => [message, code, fieldErrors];
}

/// Payment-related failures
class PaymentFailure extends Failure {
  const PaymentFailure({
    required super.message,
    super.code,
  });

  static const String insufficientFunds = 'Insufficient funds';
  static const String cardDeclined = 'Card was declined';
  static const String invalidCard = 'Invalid card information';
  static const String expiredCard = 'Card has expired';
  static const String paymentCancelled = 'Payment was cancelled';
  static const String paymentTimeout = 'Payment timed out';
  static const String unknownError = 'An unknown payment error occurred';
}

/// Gamification-related failures
class GamificationFailure extends Failure {
  const GamificationFailure({
    required super.message,
    super.code,
  });

  static const String insufficientPoints = 'Insufficient points for this action';
  static const String dailyLimitReached = 'Daily points limit reached';
  static const String invalidPointsAmount = 'Invalid points amount';
  static const String pointsCalculationError = 'Error calculating points';
  static const String badgeNotFound = 'Badge not found';
  static const String badgeAlreadyUnlocked = 'Badge already unlocked';
  static const String achievementNotFound = 'Achievement not found';
}

/// Booking-related failures
class BookingFailure extends Failure {
  const BookingFailure({
    required super.message,
    super.code,
  });

  static const String venueNotAvailable = 'Venue is not available for selected time';
  static const String capacityFull = 'Venue is at full capacity';
  static const String invalidBookingTime = 'Invalid booking time';
  static const String bookingNotFound = 'Booking not found';
  static const String bookingCancelled = 'Booking has been cancelled';
  static const String bookingExpired = 'Booking has expired';
  static const String duplicateBooking = 'You already have a booking for this time';
}

/// Storage failures
class StorageFailure extends Failure {
  const StorageFailure({
    required super.message,
    super.code,
  });

  static const String readError = 'Failed to read data from storage';
  static const String writeError = 'Failed to write data to storage';
  static const String deleteError = 'Failed to delete data from storage';
  static const String storageNotAvailable = 'Storage is not available';
}

/// Permission failures
class PermissionFailure extends Failure {
  const PermissionFailure({
    required super.message,
    super.code,
  });

  static const String cameraPermissionDenied = 'Camera permission denied';
  static const String locationPermissionDenied = 'Location permission denied';
  static const String notificationPermissionDenied = 'Notification permission denied';
  static const String storagePermissionDenied = 'Storage permission denied';
}

/// Social features failures
class SocialFailure extends Failure {
  const SocialFailure({
    required super.message,
    super.code,
  });

  static const String friendRequestAlreadySent = 'Friend request already sent';
  static const String alreadyFriends = 'Already friends with this user';
  static const String userNotFound = 'User not found';
  static const String cannotAddSelf = 'Cannot add yourself as friend';
  static const String friendRequestNotFound = 'Friend request not found';
}

/// Content moderation failures
class ModerationFailure extends Failure {
  const ModerationFailure({
    required super.message,
    super.code,
  });

  static const String inappropriateContent = 'Content contains inappropriate material';
  static const String spam = 'Content has been flagged as spam';
  static const String tooManyReports = 'Content has been reported too many times';
  static const String bannedWords = 'Content contains banned words';
}

/// File upload failures
class UploadFailure extends Failure {
  const UploadFailure({
    required super.message,
    super.code,
  });

  static const String fileTooLarge = 'File size exceeds maximum limit';
  static const String invalidFileType = 'Invalid file type';
  static const String uploadCancelled = 'Upload was cancelled';
  static const String uploadFailed = 'Upload failed';
  static const String networkError = 'Network error during upload';
}

/// Generic/Unknown failures
class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'An unknown error occurred',
    super.code,
  });
}

/// Timeout failures
class TimeoutFailure extends Failure {
  const TimeoutFailure({
    super.message = 'Operation timed out',
    super.code,
  });
}

/// Concurrent modification failures
class ConcurrentModificationFailure extends Failure {
  const ConcurrentModificationFailure({
    super.message = 'Resource was modified by another user',
    super.code,
  });
}
