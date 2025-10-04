/// Base exception class for application-specific exceptions
///
/// Exceptions represent unexpected errors that occur during operation
/// and typically need to be caught and converted to Failures.
class AppException implements Exception {
  final String message;
  final int? code;
  final dynamic originalError;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => 'AppException: $message (code: $code)';
}

/// Server/API exceptions
class ServerException extends AppException {
  const ServerException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Cache exceptions
class CacheException extends AppException {
  const CacheException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Network exceptions
class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Authentication exceptions
class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Validation exceptions
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  const ValidationException({
    required super.message,
    super.code,
    super.originalError,
    this.fieldErrors,
  });

  @override
  String toString() {
    if (fieldErrors != null && fieldErrors!.isNotEmpty) {
      return 'ValidationException: $message, Errors: $fieldErrors';
    }
    return super.toString();
  }
}

/// Payment exceptions
class PaymentException extends AppException {
  const PaymentException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Gamification exceptions
class GamificationException extends AppException {
  const GamificationException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Booking exceptions
class BookingException extends AppException {
  const BookingException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Storage exceptions
class StorageException extends AppException {
  const StorageException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Permission exceptions
class PermissionException extends AppException {
  const PermissionException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Parsing/Serialization exceptions
class ParsingException extends AppException {
  const ParsingException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Timeout exceptions
class TimeoutException extends AppException {
  const TimeoutException({
    super.message = 'Operation timed out',
    super.code,
    super.originalError,
  });
}

/// Not found exceptions
class NotFoundException extends AppException {
  const NotFoundException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Unauthorized exceptions
class UnauthorizedException extends AppException {
  const UnauthorizedException({
    super.message = 'Unauthorized access',
    super.code = 401,
    super.originalError,
  });
}

/// Forbidden exceptions
class ForbiddenException extends AppException {
  const ForbiddenException({
    super.message = 'Access forbidden',
    super.code = 403,
    super.originalError,
  });
}

/// Conflict exceptions (e.g., duplicate entries)
class ConflictException extends AppException {
  const ConflictException({
    required super.message,
    super.code = 409,
    super.originalError,
  });
}

/// Rate limit exceptions
class RateLimitException extends AppException {
  final DateTime? retryAfter;

  const RateLimitException({
    super.message = 'Rate limit exceeded',
    super.code = 429,
    super.originalError,
    this.retryAfter,
  });
}

/// Maintenance mode exception
class MaintenanceException extends AppException {
  const MaintenanceException({
    super.message = 'Service is under maintenance',
    super.code = 503,
    super.originalError,
  });
}
