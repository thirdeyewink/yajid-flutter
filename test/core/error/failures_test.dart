import 'package:flutter_test/flutter_test.dart';
import 'package:yajid/core/error/failures.dart';

void main() {
  group('Failure', () {
    test('Failure is an Equatable', () {
      final failure = ServerFailure(message: 'Test');

      expect(failure, isA<Failure>());
    });

    test('props includes message and code', () {
      final failure = ServerFailure(message: 'Error', code: 500);

      expect(failure.props, [failure.message, failure.code]);
    });

    test('two failures with same props are equal', () {
      final failure1 = ServerFailure(message: 'Error', code: 500);
      final failure2 = ServerFailure(message: 'Error', code: 500);

      expect(failure1, equals(failure2));
    });

    test('two failures with different props are not equal', () {
      final failure1 = ServerFailure(message: 'Error 1', code: 500);
      final failure2 = ServerFailure(message: 'Error 2', code: 500);

      expect(failure1, isNot(equals(failure2)));
    });
  });

  group('ServerFailure', () {
    test('extends Failure', () {
      final failure = ServerFailure(message: 'Server error');

      expect(failure, isA<Failure>());
    });

    test('creates with all fields', () {
      final failure = ServerFailure(
        message: 'Internal server error',
        code: 500,
      );

      expect(failure.message, 'Internal server error');
      expect(failure.code, 500);
    });

    test('creates without code', () {
      final failure = ServerFailure(message: 'Server error');

      expect(failure.message, 'Server error');
      expect(failure.code, null);
    });
  });

  group('CacheFailure', () {
    test('extends Failure', () {
      final failure = CacheFailure(message: 'Cache error');

      expect(failure, isA<Failure>());
    });

    test('creates with all fields', () {
      final failure = CacheFailure(
        message: 'Cache write failed',
        code: 600,
      );

      expect(failure.message, 'Cache write failed');
      expect(failure.code, 600);
    });
  });

  group('NetworkFailure', () {
    test('extends Failure', () {
      final failure = NetworkFailure(message: 'Network error');

      expect(failure, isA<Failure>());
    });

    test('creates with connection error', () {
      final failure = NetworkFailure(
        message: 'No internet connection',
        code: 0,
      );

      expect(failure.message, 'No internet connection');
      expect(failure.code, 0);
    });
  });

  group('AuthFailure', () {
    test('extends Failure', () {
      final failure = AuthFailure(message: 'Auth error');

      expect(failure, isA<Failure>());
    });

    test('has static constant messages', () {
      expect(AuthFailure.invalidCredentials, 'Invalid email or password');
      expect(AuthFailure.userNotFound, 'No user found with this email');
      expect(AuthFailure.wrongPassword, 'Incorrect password');
      expect(AuthFailure.emailAlreadyInUse, 'Email already in use');
      expect(AuthFailure.weakPassword, 'Password is too weak');
      expect(AuthFailure.userDisabled, 'This account has been disabled');
      expect(AuthFailure.tooManyRequests, 'Too many attempts. Please try again later');
      expect(AuthFailure.operationNotAllowed, 'This operation is not allowed');
      expect(AuthFailure.invalidEmail, 'Invalid email address');
      expect(AuthFailure.accountExistsWithDifferentCredential,
          'Account exists with different sign-in method');
      expect(AuthFailure.invalidCredential, 'Invalid or expired credentials');
      expect(AuthFailure.unauthorized, 'You are not authorized to perform this action');
      expect(AuthFailure.sessionExpired, 'Your session has expired. Please log in again');
    });

    test('all static constants are non-empty strings', () {
      expect(AuthFailure.invalidCredentials, isNotEmpty);
      expect(AuthFailure.userNotFound, isNotEmpty);
      expect(AuthFailure.wrongPassword, isNotEmpty);
      expect(AuthFailure.emailAlreadyInUse, isNotEmpty);
      expect(AuthFailure.weakPassword, isNotEmpty);
      expect(AuthFailure.userDisabled, isNotEmpty);
      expect(AuthFailure.tooManyRequests, isNotEmpty);
      expect(AuthFailure.operationNotAllowed, isNotEmpty);
      expect(AuthFailure.invalidEmail, isNotEmpty);
      expect(AuthFailure.sessionExpired, isNotEmpty);
    });

    test('can be created with static constant messages', () {
      final failure = AuthFailure(
        message: AuthFailure.invalidCredentials,
        code: 401,
      );

      expect(failure.message, 'Invalid email or password');
    });
  });

  group('ValidationFailure', () {
    test('extends Failure', () {
      final failure = ValidationFailure(message: 'Validation error');

      expect(failure, isA<Failure>());
    });

    test('creates with field errors', () {
      final failure = ValidationFailure(
        message: 'Validation failed',
        code: 400,
        fieldErrors: {
          'email': 'Invalid email',
          'password': 'Too short',
        },
      );

      expect(failure.message, 'Validation failed');
      expect(failure.code, 400);
      expect(failure.fieldErrors, isNotNull);
      expect(failure.fieldErrors!['email'], 'Invalid email');
    });

    test('props includes fieldErrors', () {
      final failure = ValidationFailure(
        message: 'Error',
        fieldErrors: {'field': 'error'},
      );

      expect(failure.props, [failure.message, failure.code, failure.fieldErrors]);
    });

    test('two ValidationFailures with same fieldErrors are equal', () {
      final failure1 = ValidationFailure(
        message: 'Error',
        fieldErrors: {'email': 'Invalid'},
      );
      final failure2 = ValidationFailure(
        message: 'Error',
        fieldErrors: {'email': 'Invalid'},
      );

      expect(failure1, equals(failure2));
    });
  });

  group('PaymentFailure', () {
    test('extends Failure', () {
      final failure = PaymentFailure(message: 'Payment error');

      expect(failure, isA<Failure>());
    });

    test('has static constant messages', () {
      expect(PaymentFailure.insufficientFunds, 'Insufficient funds');
      expect(PaymentFailure.cardDeclined, 'Card was declined');
      expect(PaymentFailure.invalidCard, 'Invalid card information');
      expect(PaymentFailure.expiredCard, 'Card has expired');
      expect(PaymentFailure.paymentCancelled, 'Payment was cancelled');
      expect(PaymentFailure.paymentTimeout, 'Payment timed out');
      expect(PaymentFailure.unknownError, 'An unknown payment error occurred');
    });

    test('all static constants are non-empty', () {
      expect(PaymentFailure.insufficientFunds, isNotEmpty);
      expect(PaymentFailure.cardDeclined, isNotEmpty);
      expect(PaymentFailure.invalidCard, isNotEmpty);
      expect(PaymentFailure.expiredCard, isNotEmpty);
      expect(PaymentFailure.paymentCancelled, isNotEmpty);
      expect(PaymentFailure.paymentTimeout, isNotEmpty);
      expect(PaymentFailure.unknownError, isNotEmpty);
    });

    test('can use static constants', () {
      final failure = PaymentFailure(
        message: PaymentFailure.cardDeclined,
        code: 402,
      );

      expect(failure.message, 'Card was declined');
    });
  });

  group('GamificationFailure', () {
    test('extends Failure', () {
      final failure = GamificationFailure(message: 'Gamification error');

      expect(failure, isA<Failure>());
    });

    test('has static constant messages', () {
      expect(GamificationFailure.insufficientPoints, 'Insufficient points for this action');
      expect(GamificationFailure.dailyLimitReached, 'Daily points limit reached');
      expect(GamificationFailure.invalidPointsAmount, 'Invalid points amount');
      expect(GamificationFailure.pointsCalculationError, 'Error calculating points');
      expect(GamificationFailure.badgeNotFound, 'Badge not found');
      expect(GamificationFailure.badgeAlreadyUnlocked, 'Badge already unlocked');
      expect(GamificationFailure.achievementNotFound, 'Achievement not found');
    });

    test('all static constants are non-empty', () {
      expect(GamificationFailure.insufficientPoints, isNotEmpty);
      expect(GamificationFailure.dailyLimitReached, isNotEmpty);
      expect(GamificationFailure.invalidPointsAmount, isNotEmpty);
      expect(GamificationFailure.pointsCalculationError, isNotEmpty);
      expect(GamificationFailure.badgeNotFound, isNotEmpty);
      expect(GamificationFailure.badgeAlreadyUnlocked, isNotEmpty);
      expect(GamificationFailure.achievementNotFound, isNotEmpty);
    });
  });

  group('BookingFailure', () {
    test('extends Failure', () {
      final failure = BookingFailure(message: 'Booking error');

      expect(failure, isA<Failure>());
    });

    test('has static constant messages', () {
      expect(BookingFailure.venueNotAvailable, 'Venue is not available for selected time');
      expect(BookingFailure.capacityFull, 'Venue is at full capacity');
      expect(BookingFailure.invalidBookingTime, 'Invalid booking time');
      expect(BookingFailure.bookingNotFound, 'Booking not found');
      expect(BookingFailure.bookingCancelled, 'Booking has been cancelled');
      expect(BookingFailure.bookingExpired, 'Booking has expired');
      expect(BookingFailure.duplicateBooking, 'You already have a booking for this time');
    });

    test('all static constants are non-empty', () {
      expect(BookingFailure.venueNotAvailable, isNotEmpty);
      expect(BookingFailure.capacityFull, isNotEmpty);
      expect(BookingFailure.invalidBookingTime, isNotEmpty);
      expect(BookingFailure.bookingNotFound, isNotEmpty);
      expect(BookingFailure.bookingCancelled, isNotEmpty);
      expect(BookingFailure.bookingExpired, isNotEmpty);
      expect(BookingFailure.duplicateBooking, isNotEmpty);
    });
  });

  group('StorageFailure', () {
    test('extends Failure', () {
      final failure = StorageFailure(message: 'Storage error');

      expect(failure, isA<Failure>());
    });

    test('has static constant messages', () {
      expect(StorageFailure.readError, 'Failed to read data from storage');
      expect(StorageFailure.writeError, 'Failed to write data to storage');
      expect(StorageFailure.deleteError, 'Failed to delete data from storage');
      expect(StorageFailure.storageNotAvailable, 'Storage is not available');
    });

    test('all static constants are non-empty', () {
      expect(StorageFailure.readError, isNotEmpty);
      expect(StorageFailure.writeError, isNotEmpty);
      expect(StorageFailure.deleteError, isNotEmpty);
      expect(StorageFailure.storageNotAvailable, isNotEmpty);
    });
  });

  group('PermissionFailure', () {
    test('extends Failure', () {
      final failure = PermissionFailure(message: 'Permission error');

      expect(failure, isA<Failure>());
    });

    test('has static constant messages', () {
      expect(PermissionFailure.cameraPermissionDenied, 'Camera permission denied');
      expect(PermissionFailure.locationPermissionDenied, 'Location permission denied');
      expect(PermissionFailure.notificationPermissionDenied, 'Notification permission denied');
      expect(PermissionFailure.storagePermissionDenied, 'Storage permission denied');
    });

    test('all static constants are non-empty', () {
      expect(PermissionFailure.cameraPermissionDenied, isNotEmpty);
      expect(PermissionFailure.locationPermissionDenied, isNotEmpty);
      expect(PermissionFailure.notificationPermissionDenied, isNotEmpty);
      expect(PermissionFailure.storagePermissionDenied, isNotEmpty);
    });
  });

  group('SocialFailure', () {
    test('extends Failure', () {
      final failure = SocialFailure(message: 'Social error');

      expect(failure, isA<Failure>());
    });

    test('has static constant messages', () {
      expect(SocialFailure.friendRequestAlreadySent, 'Friend request already sent');
      expect(SocialFailure.alreadyFriends, 'Already friends with this user');
      expect(SocialFailure.userNotFound, 'User not found');
      expect(SocialFailure.cannotAddSelf, 'Cannot add yourself as friend');
      expect(SocialFailure.friendRequestNotFound, 'Friend request not found');
    });

    test('all static constants are non-empty', () {
      expect(SocialFailure.friendRequestAlreadySent, isNotEmpty);
      expect(SocialFailure.alreadyFriends, isNotEmpty);
      expect(SocialFailure.userNotFound, isNotEmpty);
      expect(SocialFailure.cannotAddSelf, isNotEmpty);
      expect(SocialFailure.friendRequestNotFound, isNotEmpty);
    });
  });

  group('ModerationFailure', () {
    test('extends Failure', () {
      final failure = ModerationFailure(message: 'Moderation error');

      expect(failure, isA<Failure>());
    });

    test('has static constant messages', () {
      expect(ModerationFailure.inappropriateContent, 'Content contains inappropriate material');
      expect(ModerationFailure.spam, 'Content has been flagged as spam');
      expect(ModerationFailure.tooManyReports, 'Content has been reported too many times');
      expect(ModerationFailure.bannedWords, 'Content contains banned words');
    });

    test('all static constants are non-empty', () {
      expect(ModerationFailure.inappropriateContent, isNotEmpty);
      expect(ModerationFailure.spam, isNotEmpty);
      expect(ModerationFailure.tooManyReports, isNotEmpty);
      expect(ModerationFailure.bannedWords, isNotEmpty);
    });
  });

  group('UploadFailure', () {
    test('extends Failure', () {
      final failure = UploadFailure(message: 'Upload error');

      expect(failure, isA<Failure>());
    });

    test('has static constant messages', () {
      expect(UploadFailure.fileTooLarge, 'File size exceeds maximum limit');
      expect(UploadFailure.invalidFileType, 'Invalid file type');
      expect(UploadFailure.uploadCancelled, 'Upload was cancelled');
      expect(UploadFailure.uploadFailed, 'Upload failed');
      expect(UploadFailure.networkError, 'Network error during upload');
    });

    test('all static constants are non-empty', () {
      expect(UploadFailure.fileTooLarge, isNotEmpty);
      expect(UploadFailure.invalidFileType, isNotEmpty);
      expect(UploadFailure.uploadCancelled, isNotEmpty);
      expect(UploadFailure.uploadFailed, isNotEmpty);
      expect(UploadFailure.networkError, isNotEmpty);
    });
  });

  group('UnknownFailure', () {
    test('extends Failure', () {
      final failure = UnknownFailure();

      expect(failure, isA<Failure>());
    });

    test('has default message', () {
      final failure = UnknownFailure();

      expect(failure.message, 'An unknown error occurred');
    });

    test('can override default message', () {
      final failure = UnknownFailure(message: 'Custom unknown error');

      expect(failure.message, 'Custom unknown error');
    });

    test('creates with optional code', () {
      final failure = UnknownFailure(code: 999);

      expect(failure.code, 999);
    });
  });

  group('TimeoutFailure', () {
    test('extends Failure', () {
      final failure = TimeoutFailure();

      expect(failure, isA<Failure>());
    });

    test('has default message', () {
      final failure = TimeoutFailure();

      expect(failure.message, 'Operation timed out');
    });

    test('can override default message', () {
      final failure = TimeoutFailure(message: 'Custom timeout');

      expect(failure.message, 'Custom timeout');
    });
  });

  group('ConcurrentModificationFailure', () {
    test('extends Failure', () {
      final failure = ConcurrentModificationFailure();

      expect(failure, isA<Failure>());
    });

    test('has default message', () {
      final failure = ConcurrentModificationFailure();

      expect(failure.message, 'Resource was modified by another user');
    });

    test('can override default message', () {
      final failure = ConcurrentModificationFailure(
        message: 'Document modified concurrently',
      );

      expect(failure.message, 'Document modified concurrently');
    });
  });

  group('Failure Hierarchy', () {
    test('all failure types extend Failure', () {
      expect(ServerFailure(message: 'test'), isA<Failure>());
      expect(CacheFailure(message: 'test'), isA<Failure>());
      expect(NetworkFailure(message: 'test'), isA<Failure>());
      expect(AuthFailure(message: 'test'), isA<Failure>());
      expect(ValidationFailure(message: 'test'), isA<Failure>());
      expect(PaymentFailure(message: 'test'), isA<Failure>());
      expect(GamificationFailure(message: 'test'), isA<Failure>());
      expect(BookingFailure(message: 'test'), isA<Failure>());
      expect(StorageFailure(message: 'test'), isA<Failure>());
      expect(PermissionFailure(message: 'test'), isA<Failure>());
      expect(SocialFailure(message: 'test'), isA<Failure>());
      expect(ModerationFailure(message: 'test'), isA<Failure>());
      expect(UploadFailure(message: 'test'), isA<Failure>());
      expect(UnknownFailure(), isA<Failure>());
      expect(TimeoutFailure(), isA<Failure>());
      expect(ConcurrentModificationFailure(), isA<Failure>());
    });
  });

  group('Equatable Behavior', () {
    test('failures with identical data are equal', () {
      final failure1 = NetworkFailure(message: 'Network error', code: 0);
      final failure2 = NetworkFailure(message: 'Network error', code: 0);

      expect(failure1, equals(failure2));
      expect(failure1.hashCode, equals(failure2.hashCode));
    });

    test('failures with different messages are not equal', () {
      final failure1 = NetworkFailure(message: 'Error 1');
      final failure2 = NetworkFailure(message: 'Error 2');

      expect(failure1, isNot(equals(failure2)));
    });

    test('failures with different codes are not equal', () {
      final failure1 = ServerFailure(message: 'Error', code: 500);
      final failure2 = ServerFailure(message: 'Error', code: 501);

      expect(failure1, isNot(equals(failure2)));
    });

    test('ValidationFailure with different fieldErrors are not equal', () {
      final failure1 = ValidationFailure(
        message: 'Error',
        fieldErrors: {'field1': 'error'},
      );
      final failure2 = ValidationFailure(
        message: 'Error',
        fieldErrors: {'field2': 'error'},
      );

      expect(failure1, isNot(equals(failure2)));
    });
  });
}
