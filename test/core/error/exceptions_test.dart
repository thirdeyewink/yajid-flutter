import 'package:flutter_test/flutter_test.dart';
import 'package:yajid/core/error/exceptions.dart';

void main() {
  group('AppException', () {
    test('creates exception with all fields', () {
      final error = Exception('Original error');
      final exception = AppException(
        message: 'Test error',
        code: 500,
        originalError: error,
      );

      expect(exception.message, 'Test error');
      expect(exception.code, 500);
      expect(exception.originalError, error);
    });

    test('creates exception without optional fields', () {
      final exception = AppException(message: 'Test error');

      expect(exception.message, 'Test error');
      expect(exception.code, null);
      expect(exception.originalError, null);
    });

    test('toString returns formatted message', () {
      final exception = AppException(message: 'Test error', code: 500);

      expect(exception.toString(), 'AppException: Test error (code: 500)');
    });

    test('toString works with null code', () {
      final exception = AppException(message: 'Test error');

      expect(exception.toString(), contains('Test error'));
      expect(exception.toString(), contains('code: null'));
    });

    test('implements Exception', () {
      final exception = AppException(message: 'Test');

      expect(exception, isA<Exception>());
    });
  });

  group('ServerException', () {
    test('extends AppException', () {
      final exception = ServerException(message: 'Server error');

      expect(exception, isA<AppException>());
    });

    test('creates with all fields', () {
      final exception = ServerException(
        message: 'Internal server error',
        code: 500,
        originalError: 'DB connection failed',
      );

      expect(exception.message, 'Internal server error');
      expect(exception.code, 500);
      expect(exception.originalError, 'DB connection failed');
    });

    test('creates without optional fields', () {
      final exception = ServerException(message: 'Server error');

      expect(exception.message, 'Server error');
      expect(exception.code, null);
      expect(exception.originalError, null);
    });
  });

  group('CacheException', () {
    test('extends AppException', () {
      final exception = CacheException(message: 'Cache error');

      expect(exception, isA<AppException>());
    });

    test('creates with all fields', () {
      final exception = CacheException(
        message: 'Cache write failed',
        code: 600,
        originalError: 'Disk full',
      );

      expect(exception.message, 'Cache write failed');
      expect(exception.code, 600);
    });
  });

  group('NetworkException', () {
    test('extends AppException', () {
      final exception = NetworkException(message: 'Network error');

      expect(exception, isA<AppException>());
    });

    test('creates with connection error details', () {
      final exception = NetworkException(
        message: 'No internet connection',
        code: 0,
      );

      expect(exception.message, 'No internet connection');
      expect(exception.code, 0);
    });
  });

  group('AuthException', () {
    test('extends AppException', () {
      final exception = AuthException(message: 'Auth error');

      expect(exception, isA<AppException>());
    });

    test('creates with authentication error', () {
      final exception = AuthException(
        message: 'Invalid credentials',
        code: 401,
      );

      expect(exception.message, 'Invalid credentials');
      expect(exception.code, 401);
    });
  });

  group('ValidationException', () {
    test('extends AppException', () {
      final exception = ValidationException(message: 'Validation error');

      expect(exception, isA<AppException>());
    });

    test('creates with field errors', () {
      final exception = ValidationException(
        message: 'Validation failed',
        code: 400,
        fieldErrors: {
          'email': 'Invalid email format',
          'password': 'Password too short',
        },
      );

      expect(exception.message, 'Validation failed');
      expect(exception.code, 400);
      expect(exception.fieldErrors, isNotNull);
      expect(exception.fieldErrors!['email'], 'Invalid email format');
      expect(exception.fieldErrors!['password'], 'Password too short');
    });

    test('creates without field errors', () {
      final exception = ValidationException(message: 'Validation failed');

      expect(exception.fieldErrors, null);
    });

    test('toString includes field errors', () {
      final exception = ValidationException(
        message: 'Validation failed',
        fieldErrors: {'email': 'Invalid'},
      );

      final str = exception.toString();
      expect(str, contains('Validation failed'));
      expect(str, contains('Errors:'));
      expect(str, contains('email'));
    });

    test('toString without field errors uses parent toString', () {
      final exception = ValidationException(message: 'Validation failed', code: 400);

      final str = exception.toString();
      expect(str, contains('AppException'));
      expect(str, contains('Validation failed'));
      expect(str, contains('400'));
    });
  });

  group('PaymentException', () {
    test('extends AppException', () {
      final exception = PaymentException(message: 'Payment error');

      expect(exception, isA<AppException>());
    });

    test('creates with payment error details', () {
      final exception = PaymentException(
        message: 'Card declined',
        code: 402,
      );

      expect(exception.message, 'Card declined');
      expect(exception.code, 402);
    });
  });

  group('GamificationException', () {
    test('extends AppException', () {
      final exception = GamificationException(message: 'Gamification error');

      expect(exception, isA<AppException>());
    });

    test('creates with gamification error', () {
      final exception = GamificationException(
        message: 'Insufficient points',
        code: 400,
      );

      expect(exception.message, 'Insufficient points');
    });
  });

  group('BookingException', () {
    test('extends AppException', () {
      final exception = BookingException(message: 'Booking error');

      expect(exception, isA<AppException>());
    });

    test('creates with booking error', () {
      final exception = BookingException(
        message: 'Venue not available',
        code: 409,
      );

      expect(exception.message, 'Venue not available');
      expect(exception.code, 409);
    });
  });

  group('StorageException', () {
    test('extends AppException', () {
      final exception = StorageException(message: 'Storage error');

      expect(exception, isA<AppException>());
    });

    test('creates with storage error', () {
      final exception = StorageException(
        message: 'Upload failed',
        code: 500,
      );

      expect(exception.message, 'Upload failed');
    });
  });

  group('PermissionException', () {
    test('extends AppException', () {
      final exception = PermissionException(message: 'Permission error');

      expect(exception, isA<AppException>());
    });

    test('creates with permission denial', () {
      final exception = PermissionException(
        message: 'Camera access denied',
        code: 403,
      );

      expect(exception.message, 'Camera access denied');
      expect(exception.code, 403);
    });
  });

  group('ParsingException', () {
    test('extends AppException', () {
      final exception = ParsingException(message: 'Parsing error');

      expect(exception, isA<AppException>());
    });

    test('creates with parsing error', () {
      final exception = ParsingException(
        message: 'Invalid JSON',
        code: 422,
      );

      expect(exception.message, 'Invalid JSON');
    });
  });

  group('TimeoutException', () {
    test('extends AppException', () {
      final exception = TimeoutException();

      expect(exception, isA<AppException>());
    });

    test('has default message', () {
      final exception = TimeoutException();

      expect(exception.message, 'Operation timed out');
    });

    test('can override default message', () {
      final exception = TimeoutException(message: 'Custom timeout message');

      expect(exception.message, 'Custom timeout message');
    });

    test('creates with optional code', () {
      final exception = TimeoutException(code: 408);

      expect(exception.code, 408);
    });
  });

  group('NotFoundException', () {
    test('extends AppException', () {
      final exception = NotFoundException(message: 'Not found');

      expect(exception, isA<AppException>());
    });

    test('creates with not found error', () {
      final exception = NotFoundException(
        message: 'Resource not found',
        code: 404,
      );

      expect(exception.message, 'Resource not found');
      expect(exception.code, 404);
    });
  });

  group('UnauthorizedException', () {
    test('extends AppException', () {
      final exception = UnauthorizedException();

      expect(exception, isA<AppException>());
    });

    test('has default message', () {
      final exception = UnauthorizedException();

      expect(exception.message, 'Unauthorized access');
    });

    test('has default code', () {
      final exception = UnauthorizedException();

      expect(exception.code, 401);
    });

    test('can override defaults', () {
      final exception = UnauthorizedException(
        message: 'Custom unauthorized',
        code: 499,
      );

      expect(exception.message, 'Custom unauthorized');
      expect(exception.code, 499);
    });
  });

  group('ForbiddenException', () {
    test('extends AppException', () {
      final exception = ForbiddenException();

      expect(exception, isA<AppException>());
    });

    test('has default message', () {
      final exception = ForbiddenException();

      expect(exception.message, 'Access forbidden');
    });

    test('has default code 403', () {
      final exception = ForbiddenException();

      expect(exception.code, 403);
    });

    test('can override defaults', () {
      final exception = ForbiddenException(message: 'Admin access required');

      expect(exception.message, 'Admin access required');
      expect(exception.code, 403); // Code remains 403
    });
  });

  group('ConflictException', () {
    test('extends AppException', () {
      final exception = ConflictException(message: 'Conflict');

      expect(exception, isA<AppException>());
    });

    test('has default code 409', () {
      final exception = ConflictException(message: 'Resource already exists');

      expect(exception.code, 409);
    });

    test('requires message', () {
      final exception = ConflictException(message: 'Duplicate entry');

      expect(exception.message, 'Duplicate entry');
    });

    test('can override code', () {
      final exception = ConflictException(
        message: 'Conflict',
        code: 400,
      );

      expect(exception.code, 400);
    });
  });

  group('RateLimitException', () {
    test('extends AppException', () {
      final exception = RateLimitException();

      expect(exception, isA<AppException>());
    });

    test('has default message', () {
      final exception = RateLimitException();

      expect(exception.message, 'Rate limit exceeded');
    });

    test('has default code 429', () {
      final exception = RateLimitException();

      expect(exception.code, 429);
    });

    test('stores retryAfter date', () {
      final retryDate = DateTime.now().add(Duration(minutes: 15));
      final exception = RateLimitException(retryAfter: retryDate);

      expect(exception.retryAfter, retryDate);
    });

    test('retryAfter is optional', () {
      final exception = RateLimitException();

      expect(exception.retryAfter, null);
    });
  });

  group('MaintenanceException', () {
    test('extends AppException', () {
      final exception = MaintenanceException();

      expect(exception, isA<AppException>());
    });

    test('has default message', () {
      final exception = MaintenanceException();

      expect(exception.message, 'Service is under maintenance');
    });

    test('has default code 503', () {
      final exception = MaintenanceException();

      expect(exception.code, 503);
    });

    test('can override defaults', () {
      final exception = MaintenanceException(
        message: 'Scheduled maintenance in progress',
        code: 502,
      );

      expect(exception.message, 'Scheduled maintenance in progress');
      expect(exception.code, 502);
    });
  });

  group('Exception Hierarchy', () {
    test('all exception types extend AppException', () {
      expect(ServerException(message: 'test'), isA<AppException>());
      expect(CacheException(message: 'test'), isA<AppException>());
      expect(NetworkException(message: 'test'), isA<AppException>());
      expect(AuthException(message: 'test'), isA<AppException>());
      expect(ValidationException(message: 'test'), isA<AppException>());
      expect(PaymentException(message: 'test'), isA<AppException>());
      expect(GamificationException(message: 'test'), isA<AppException>());
      expect(BookingException(message: 'test'), isA<AppException>());
      expect(StorageException(message: 'test'), isA<AppException>());
      expect(PermissionException(message: 'test'), isA<AppException>());
      expect(ParsingException(message: 'test'), isA<AppException>());
      expect(TimeoutException(), isA<AppException>());
      expect(NotFoundException(message: 'test'), isA<AppException>());
      expect(UnauthorizedException(), isA<AppException>());
      expect(ForbiddenException(), isA<AppException>());
      expect(ConflictException(message: 'test'), isA<AppException>());
      expect(RateLimitException(), isA<AppException>());
      expect(MaintenanceException(), isA<AppException>());
    });

    test('all exception types implement Exception', () {
      expect(ServerException(message: 'test'), isA<Exception>());
      expect(NetworkException(message: 'test'), isA<Exception>());
      expect(AuthException(message: 'test'), isA<Exception>());
    });
  });
}
