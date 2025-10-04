/// Utility class for form validation
class Validators {
  Validators._();

  /// Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Password validation
  /// Requirements: Minimum 8 characters, at least one uppercase, one lowercase, one number
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    return null;
  }

  /// Confirm password validation
  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  /// Name validation (Arabic and Latin characters supported)
  static String? validateName(String? value, {int minLength = 2, int maxLength = 50}) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }

    final trimmed = value.trim();

    if (trimmed.length < minLength) {
      return 'Name must be at least $minLength characters';
    }

    if (trimmed.length > maxLength) {
      return 'Name must not exceed $maxLength characters';
    }

    // Allow Arabic, Latin letters, spaces, and hyphens
    final nameRegex = RegExp(r'^[\u0600-\u06FFa-zA-Z\s\-]+$');
    if (!nameRegex.hasMatch(trimmed)) {
      return 'Name can only contain letters, spaces, and hyphens';
    }

    return null;
  }

  /// Phone number validation (Moroccan format)
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Moroccan phone numbers: +212XXXXXXXXX or 0XXXXXXXXX (9 digits after 0)
    final moroccanPhoneRegex = RegExp(r'^(?:\+212|0)[5-7]\d{8}$');

    if (!moroccanPhoneRegex.hasMatch(cleaned)) {
      return 'Please enter a valid Moroccan phone number';
    }

    return null;
  }

  /// Required field validation
  static String? validateRequired(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Minimum length validation
  static String? validateMinLength(String? value, int minLength, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null; // Use validateRequired for empty check
    }

    if (value.length < minLength) {
      final name = fieldName ?? 'This field';
      return '$name must be at least $minLength characters';
    }

    return null;
  }

  /// Maximum length validation
  static String? validateMaxLength(String? value, int maxLength, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (value.length > maxLength) {
      final name = fieldName ?? 'This field';
      return '$name must not exceed $maxLength characters';
    }

    return null;
  }

  /// Numeric validation
  static String? validateNumeric(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    if (double.tryParse(value) == null) {
      final name = fieldName ?? 'This field';
      return '$name must be a valid number';
    }

    return null;
  }

  /// Integer validation
  static String? validateInteger(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    if (int.tryParse(value) == null) {
      final name = fieldName ?? 'This field';
      return '$name must be a valid integer';
    }

    return null;
  }

  /// Price validation (MAD - Moroccan Dirham)
  static String? validatePrice(String? value, {double? min, double? max}) {
    if (value == null || value.trim().isEmpty) {
      return 'Price is required';
    }

    final price = double.tryParse(value.replaceAll(',', '.'));

    if (price == null) {
      return 'Please enter a valid price';
    }

    if (price < 0) {
      return 'Price cannot be negative';
    }

    if (min != null && price < min) {
      return 'Price must be at least ${min.toStringAsFixed(2)} MAD';
    }

    if (max != null && price > max) {
      return 'Price must not exceed ${max.toStringAsFixed(2)} MAD';
    }

    return null;
  }

  /// Points validation (for gamification)
  static String? validatePoints(String? value, {int? min, int? max}) {
    if (value == null || value.trim().isEmpty) {
      return 'Points are required';
    }

    final points = int.tryParse(value);

    if (points == null) {
      return 'Please enter a valid points amount';
    }

    if (points < 0) {
      return 'Points cannot be negative';
    }

    if (min != null && points < min) {
      return 'Points must be at least $min';
    }

    if (max != null && points > max) {
      return 'Points must not exceed $max';
    }

    return null;
  }

  /// Date validation
  static String? validateDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Date is required';
    }

    try {
      DateTime.parse(value);
      return null;
    } catch (e) {
      return 'Please enter a valid date';
    }
  }

  /// Future date validation
  static String? validateFutureDate(String? value) {
    final dateError = validateDate(value);
    if (dateError != null) return dateError;

    final date = DateTime.parse(value!);
    if (date.isBefore(DateTime.now())) {
      return 'Date must be in the future';
    }

    return null;
  }

  /// Past date validation
  static String? validatePastDate(String? value) {
    final dateError = validateDate(value);
    if (dateError != null) return dateError;

    final date = DateTime.parse(value!);
    if (date.isAfter(DateTime.now())) {
      return 'Date must be in the past';
    }

    return null;
  }

  /// Age validation (18+)
  static String? validateAge(String? value, {int minimumAge = 18}) {
    final dateError = validatePastDate(value);
    if (dateError != null) return dateError;

    final birthDate = DateTime.parse(value!);
    final today = DateTime.now();
    final age = today.year - birthDate.year;
    final hasHadBirthdayThisYear =
        today.month > birthDate.month ||
        (today.month == birthDate.month && today.day >= birthDate.day);

    final actualAge = hasHadBirthdayThisYear ? age : age - 1;

    if (actualAge < minimumAge) {
      return 'You must be at least $minimumAge years old';
    }

    return null;
  }

  /// URL validation
  static String? validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // URL is optional in most cases
    }

    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );

    if (!urlRegex.hasMatch(value.trim())) {
      return 'Please enter a valid URL';
    }

    return null;
  }

  /// Rating validation (1-5)
  static String? validateRating(double? value) {
    if (value == null) {
      return 'Rating is required';
    }

    if (value < 1 || value > 5) {
      return 'Rating must be between 1 and 5';
    }

    return null;
  }

  /// Review text validation
  static String? validateReview(String? value, {int minLength = 10, int maxLength = 1000}) {
    if (value == null || value.trim().isEmpty) {
      return 'Review text is required';
    }

    final trimmed = value.trim();

    if (trimmed.length < minLength) {
      return 'Review must be at least $minLength characters';
    }

    if (trimmed.length > maxLength) {
      return 'Review must not exceed $maxLength characters';
    }

    return null;
  }

  /// Venue capacity validation
  static String? validateCapacity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Capacity is required';
    }

    final capacity = int.tryParse(value);

    if (capacity == null) {
      return 'Please enter a valid capacity';
    }

    if (capacity < 1) {
      return 'Capacity must be at least 1';
    }

    if (capacity > 10000) {
      return 'Capacity seems unrealistic';
    }

    return null;
  }

  /// Party size validation
  static String? validatePartySize(String? value, {int maxCapacity = 100}) {
    if (value == null || value.trim().isEmpty) {
      return 'Party size is required';
    }

    final partySize = int.tryParse(value);

    if (partySize == null) {
      return 'Please enter a valid party size';
    }

    if (partySize < 1) {
      return 'Party size must be at least 1';
    }

    if (partySize > maxCapacity) {
      return 'Party size exceeds venue capacity';
    }

    return null;
  }

  /// Combine multiple validators
  static String? Function(String?) combineValidators(
    List<String? Function(String?)> validators,
  ) {
    return (String? value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }
}
