import 'package:flutter_test/flutter_test.dart';
import 'package:yajid/core/utils/validators.dart';

void main() {
  group('Validators', () {
    group('validateEmail', () {
      test('valid email', () {
        expect(Validators.validateEmail('test@example.com'), null);
      });

      test('invalid email', () {
        expect(Validators.validateEmail(null), 'Email is required');
        expect(Validators.validateEmail('invalid'), 'Please enter a valid email address');
      });
    });

    group('validatePassword', () {
      test('valid password', () {
        expect(Validators.validatePassword('Password123'), null);
      });

      test('invalid password', () {
        expect(Validators.validatePassword(null), 'Password is required');
        expect(Validators.validatePassword('short'), 'Password must be at least 8 characters');
        expect(Validators.validatePassword('password123'), 'Password must contain at least one uppercase letter');
        expect(Validators.validatePassword('PASSWORD123'), 'Password must contain at least one lowercase letter');
        expect(Validators.validatePassword('Password'), 'Password must contain at least one number');
      });
    });

    group('validateConfirmPassword', () {
      test('matching passwords', () {
        expect(Validators.validateConfirmPassword('Pass123', 'Pass123'), null);
      });

      test('non-matching passwords', () {
        expect(Validators.validateConfirmPassword(null, 'Pass123'), 'Please confirm your password');
        expect(Validators.validateConfirmPassword('Pass123', 'Pass456'), 'Passwords do not match');
      });
    });

    group('validateName', () {
      test('valid names', () {
        expect(Validators.validateName('John'), null);
        expect(Validators.validateName('محمد'), null);
      });

      test('invalid names', () {
        expect(Validators.validateName(null), 'Name is required');
        expect(Validators.validateName('A'), 'Name must be at least 2 characters');
        expect(Validators.validateName('John123'), 'Name can only contain letters, spaces, and hyphens');
      });
    });

    group('validatePhoneNumber', () {
      test('valid Moroccan phones', () {
        expect(Validators.validatePhoneNumber('0612345678'), null);
        expect(Validators.validatePhoneNumber('+212612345678'), null);
      });

      test('invalid phones', () {
        expect(Validators.validatePhoneNumber(null), 'Phone number is required');
        expect(Validators.validatePhoneNumber('1234'), 'Please enter a valid Moroccan phone number');
      });
    });

    group('validatePrice', () {
      test('valid prices', () {
        expect(Validators.validatePrice('100'), null);
        expect(Validators.validatePrice('99.99'), null);
      });

      test('invalid prices', () {
        expect(Validators.validatePrice(null), 'Price is required');
        expect(Validators.validatePrice('abc'), 'Please enter a valid price');
        expect(Validators.validatePrice('-50'), 'Price cannot be negative');
      });
    });

    group('validatePoints', () {
      test('valid points', () {
        expect(Validators.validatePoints('100'), null);
      });

      test('invalid points', () {
        expect(Validators.validatePoints(null), 'Points are required');
        expect(Validators.validatePoints('abc'), 'Please enter a valid points amount');
        expect(Validators.validatePoints('-10'), 'Points cannot be negative');
      });
    });

    group('validateDate', () {
      test('valid dates', () {
        expect(Validators.validateDate('2025-06-15'), null);
      });

      test('invalid dates', () {
        expect(Validators.validateDate(null), 'Date is required');
        expect(Validators.validateDate('invalid'), 'Please enter a valid date');
      });
    });

    group('validateRating', () {
      test('valid ratings', () {
        expect(Validators.validateRating(3.5), null);
        expect(Validators.validateRating(1.0), null);
        expect(Validators.validateRating(5.0), null);
      });

      test('invalid ratings', () {
        expect(Validators.validateRating(null), 'Rating is required');
        expect(Validators.validateRating(0.0), 'Rating must be between 1 and 5');
        expect(Validators.validateRating(6.0), 'Rating must be between 1 and 5');
      });
    });

    group('validateUrl', () {
      test('valid URLs', () {
        expect(Validators.validateUrl('https://example.com'), null);
        expect(Validators.validateUrl(null), null); // Optional field
      });

      test('invalid URLs', () {
        expect(Validators.validateUrl('invalid'), 'Please enter a valid URL');
      });
    });

    group('validateReview', () {
      test('valid reviews', () {
        expect(Validators.validateReview('This is a great product!'), null);
      });

      test('invalid reviews', () {
        expect(Validators.validateReview(null), 'Review text is required');
        expect(Validators.validateReview('Short'), 'Review must be at least 10 characters');
      });
    });

    group('validateCapacity', () {
      test('valid capacity', () {
        expect(Validators.validateCapacity('10'), null);
      });

      test('invalid capacity', () {
        expect(Validators.validateCapacity(null), 'Capacity is required');
        expect(Validators.validateCapacity('abc'), 'Please enter a valid capacity');
        expect(Validators.validateCapacity('0'), 'Capacity must be at least 1');
      });
    });
  });
}
