import 'package:flutter_test/flutter_test.dart';
import 'package:yajid/models/gamification/points_model.dart';

void main() {
  group('UserPoints', () {
    test('initial creates zero-points user', () {
      final points = UserPoints.initial('user123');

      expect(points.userId, 'user123');
      expect(points.totalPoints, 0);
      expect(points.lifetimePoints, 0);
      expect(points.currentLevel, 1);
      expect(points.pointsToNextLevel, 100);
      expect(points.pointsByCategory, isEmpty);
    });

    test('copyWith updates specified fields', () {
      final original = UserPoints.initial('user123');

      final updated = original.copyWith(
        totalPoints: 500,
        lifetimePoints: 600,
        currentLevel: 5,
      );

      expect(updated.totalPoints, 500);
      expect(updated.lifetimePoints, 600);
      expect(updated.currentLevel, 5);
      expect(updated.userId, original.userId); // Unchanged
    });

    test('tracks points by category', () {
      final points = UserPoints(
        userId: 'user123',
        totalPoints: 200,
        lifetimePoints: 200,
        currentLevel: 2,
        pointsToNextLevel: 50,
        lastUpdated: DateTime.now(),
        pointsByCategory: {
          'review': 100,
          'venueVisit': 50,
          'socialShare': 50,
        },
      );

      expect(points.pointsByCategory['review'], 100);
      expect(points.pointsByCategory['venueVisit'], 50);
      expect(points.pointsByCategory['socialShare'], 50);
    });
  });

  group('PointsTransaction', () {
    test('creates transaction with all fields', () {
      final now = DateTime.now();
      final transaction = PointsTransaction(
        id: 'txn123',
        userId: 'user123',
        points: 50,
        type: PointsTransactionType.earned,
        category: 'review',
        description: 'Wrote a review',
        referenceId: 'review_456',
        timestamp: now,
        metadata: {'venueId': 'venue789'},
      );

      expect(transaction.id, 'txn123');
      expect(transaction.userId, 'user123');
      expect(transaction.points, 50);
      expect(transaction.type, PointsTransactionType.earned);
      expect(transaction.category, 'review');
      expect(transaction.description, 'Wrote a review');
      expect(transaction.referenceId, 'review_456');
      expect(transaction.metadata?['venueId'], 'venue789');
    });
  });

  group('PointsTransactionType', () {
    test('has all expected types', () {
      expect(PointsTransactionType.values.contains(PointsTransactionType.earned), true);
      expect(PointsTransactionType.values.contains(PointsTransactionType.spent), true);
      expect(PointsTransactionType.values.contains(PointsTransactionType.expired), true);
      expect(PointsTransactionType.values.contains(PointsTransactionType.adjusted), true);
      expect(PointsTransactionType.values.contains(PointsTransactionType.refunded), true);
      expect(PointsTransactionType.values.contains(PointsTransactionType.bonus), true);
      expect(PointsTransactionType.values.contains(PointsTransactionType.penalty), true);
    });
  });

  group('PointsCategory', () {
    test('displayName returns correct values', () {
      expect(PointsCategory.venueVisit.displayName, 'Venue Visit');
      expect(PointsCategory.review.displayName, 'Review');
      expect(PointsCategory.photoUpload.displayName, 'Photo Upload');
      expect(PointsCategory.socialShare.displayName, 'Social Share');
      expect(PointsCategory.friendReferral.displayName, 'Friend Referral');
      expect(PointsCategory.firstVisit.displayName, 'First Visit');
      expect(PointsCategory.dailyLogin.displayName, 'Daily Login');
      expect(PointsCategory.weeklyChallenge.displayName, 'Weekly Challenge');
      expect(PointsCategory.eventAttendance.displayName, 'Event Attendance');
      expect(PointsCategory.profileComplete.displayName, 'Profile Complete');
      expect(PointsCategory.socialConnection.displayName, 'Social Connection');
      expect(PointsCategory.helpfulReview.displayName, 'Helpful Review');
      expect(PointsCategory.achievementUnlock.displayName, 'Achievement');
      expect(PointsCategory.levelUp.displayName, 'Level Up');
    });

    test('iconName returns valid icon names', () {
      expect(PointsCategory.venueVisit.iconName, 'location_on');
      expect(PointsCategory.review.iconName, 'rate_review');
      expect(PointsCategory.photoUpload.iconName, 'photo_camera');
      expect(PointsCategory.socialShare.iconName, 'share');
      expect(PointsCategory.friendReferral.iconName, 'person_add');
    });

    test('pointsRange returns correct ranges for each category', () {
      expect(PointsCategory.venueVisit.pointsRange, (10, 50));
      expect(PointsCategory.review.pointsRange, (20, 100));
      expect(PointsCategory.photoUpload.pointsRange, (10, 30));
      expect(PointsCategory.socialShare.pointsRange, (5, 15));
      expect(PointsCategory.friendReferral.pointsRange, (200, 200));
      expect(PointsCategory.firstVisit.pointsRange, (100, 100));
      expect(PointsCategory.dailyLogin.pointsRange, (5, 15));
      expect(PointsCategory.weeklyChallenge.pointsRange, (100, 300));
      expect(PointsCategory.eventAttendance.pointsRange, (50, 200));
      expect(PointsCategory.profileComplete.pointsRange, (50, 50));
      expect(PointsCategory.socialConnection.pointsRange, (10, 10));
      expect(PointsCategory.helpfulReview.pointsRange, (5, 5));
      expect(PointsCategory.achievementUnlock.pointsRange, (50, 500));
      expect(PointsCategory.levelUp.pointsRange, (100, 100));
    });

    test('pointsRange min is less than or equal to max', () {
      for (final category in PointsCategory.values) {
        final range = category.pointsRange;
        expect(range.$1, lessThanOrEqualTo(range.$2),
            reason: 'Category ${category.name} has invalid range');
      }
    });

    test('fixed-value categories have equal min and max', () {
      expect(PointsCategory.friendReferral.pointsRange.$1,
          PointsCategory.friendReferral.pointsRange.$2);
      expect(PointsCategory.firstVisit.pointsRange.$1,
          PointsCategory.firstVisit.pointsRange.$2);
      expect(PointsCategory.profileComplete.pointsRange.$1,
          PointsCategory.profileComplete.pointsRange.$2);
    });

    test('all categories have non-negative points', () {
      for (final category in PointsCategory.values) {
        final range = category.pointsRange;
        expect(range.$1, greaterThanOrEqualTo(0));
        expect(range.$2, greaterThanOrEqualTo(0));
      }
    });
  });

  group('DailyPointsLimit', () {
    test('creates with default limit', () {
      final now = DateTime.now();
      final limit = DailyPointsLimit(
        userId: 'user123',
        date: now,
        pointsEarnedToday: 250,
      );

      expect(limit.userId, 'user123');
      expect(limit.date, now);
      expect(limit.pointsEarnedToday, 250);
      expect(limit.dailyLimit, 500); // Default from PRD
    });

    test('hasReachedLimit true when at limit', () {
      final limit = DailyPointsLimit(
        userId: 'user123',
        date: DateTime.now(),
        pointsEarnedToday: 500,
        dailyLimit: 500,
      );

      expect(limit.hasReachedLimit, true);
    });

    test('hasReachedLimit true when over limit', () {
      final limit = DailyPointsLimit(
        userId: 'user123',
        date: DateTime.now(),
        pointsEarnedToday: 600,
        dailyLimit: 500,
      );

      expect(limit.hasReachedLimit, true);
    });

    test('hasReachedLimit false when under limit', () {
      final limit = DailyPointsLimit(
        userId: 'user123',
        date: DateTime.now(),
        pointsEarnedToday: 250,
        dailyLimit: 500,
      );

      expect(limit.hasReachedLimit, false);
    });

    test('remainingPoints calculates correctly', () {
      final limit = DailyPointsLimit(
        userId: 'user123',
        date: DateTime.now(),
        pointsEarnedToday: 350,
        dailyLimit: 500,
      );

      expect(limit.remainingPoints, 150); // 500 - 350
    });

    test('remainingPoints is negative when over limit', () {
      final limit = DailyPointsLimit(
        userId: 'user123',
        date: DateTime.now(),
        pointsEarnedToday: 600,
        dailyLimit: 500,
      );

      expect(limit.remainingPoints, -100); // 500 - 600
    });

    test('remainingPoints is zero at exact limit', () {
      final limit = DailyPointsLimit(
        userId: 'user123',
        date: DateTime.now(),
        pointsEarnedToday: 500,
        dailyLimit: 500,
      );

      expect(limit.remainingPoints, 0);
    });

    test('supports custom daily limits', () {
      final limit = DailyPointsLimit(
        userId: 'user123',
        date: DateTime.now(),
        pointsEarnedToday: 400,
        dailyLimit: 1000, // Custom limit
      );

      expect(limit.dailyLimit, 1000);
      expect(limit.hasReachedLimit, false);
      expect(limit.remainingPoints, 600);
    });
  });
}
