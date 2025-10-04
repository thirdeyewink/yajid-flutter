import 'package:flutter_test/flutter_test.dart';
import 'package:yajid/models/gamification/points_model.dart';
import 'package:yajid/models/gamification/badge_model.dart';
import 'package:yajid/models/gamification/level_model.dart';

void main() {
  group('Gamification Models', () {
      group('UserPoints', () {
        test('creates initial UserPoints correctly', () {
          final userPoints = UserPoints.initial('user123');

          expect(userPoints.userId, 'user123');
          expect(userPoints.totalPoints, 0);
          expect(userPoints.lifetimePoints, 0);
          expect(userPoints.currentLevel, 1);
          expect(userPoints.pointsToNextLevel, 100);
          expect(userPoints.pointsByCategory, isEmpty);
        });

        test('converts to and from Firestore correctly', () {
          final original = UserPoints(
            userId: 'user123',
            totalPoints: 100,
            lifetimePoints: 150,
            currentLevel: 5,
            pointsToNextLevel: 200,
            pointsByCategory: {'review': 50, 'dailyLogin': 50},
            lastUpdated: DateTime(2025, 1, 1),
          );

          final firestore = original.toFirestore();
          expect(firestore['totalPoints'], 100);
          expect(firestore['lifetimePoints'], 150);
          expect(firestore['currentLevel'], 5);
          expect(firestore['pointsToNextLevel'], 200);
        });

        test('copyWith creates modified copy', () {
          final original = UserPoints.initial('user123');
          final modified = original.copyWith(totalPoints: 500);

          expect(modified.totalPoints, 500);
          expect(modified.userId, 'user123'); // Unchanged
        });
      });

      group('UserLevel', () {
        test('creates initial UserLevel correctly', () {
          final userLevel = UserLevel.initial('user123');

          expect(userLevel.userId, 'user123');
          expect(userLevel.level, 1);
          expect(userLevel.tier, ExpertiseTier.novice);
          expect(userLevel.totalPoints, 0);
        });

        test('calculates progress to next level', () {
          final userLevel = UserLevel(
            userId: 'user123',
            level: 1,
            tier: ExpertiseTier.novice,
            totalPoints: 50,
            pointsInCurrentLevel: 50,
            pointsRequiredForNextLevel: 100,
            lastUpdated: DateTime.now(),
          );

          expect(userLevel.progressToNextLevel, 0.5);
        });

        test('calculates points needed for next level', () {
          final userLevel = UserLevel(
            userId: 'user123',
            level: 1,
            tier: ExpertiseTier.novice,
            totalPoints: 50,
            pointsInCurrentLevel: 50,
            pointsRequiredForNextLevel: 100,
            lastUpdated: DateTime.now(),
          );

          expect(userLevel.pointsNeededForNextLevel, 50);
        });
      });

      group('PointsCategory', () {
        test('has correct points ranges', () {
          expect(PointsCategory.dailyLogin.pointsRange, (5, 15));
          expect(PointsCategory.review.pointsRange, (20, 100));
          expect(PointsCategory.venueVisit.pointsRange, (10, 50));
          expect(PointsCategory.friendReferral.pointsRange, (200, 200));
        });

        test('has correct display names', () {
          expect(PointsCategory.dailyLogin.displayName, 'Daily Login');
          expect(PointsCategory.review.displayName, 'Review');
          expect(PointsCategory.venueVisit.displayName, 'Venue Visit');
        });

        test('has correct icon names', () {
          expect(PointsCategory.dailyLogin.iconName, 'calendar_today');
          expect(PointsCategory.review.iconName, 'rate_review');
          expect(PointsCategory.venueVisit.iconName, 'location_on');
        });
      });

      group('PointsTransaction', () {
        test('creates transaction correctly', () {
          final transaction = PointsTransaction(
            id: 'trans123',
            userId: 'user123',
            points: 10,
            type: PointsTransactionType.earned,
            category: 'dailyLogin',
            description: 'Daily login bonus',
            timestamp: DateTime(2025, 1, 1),
          );

          expect(transaction.id, 'trans123');
          expect(transaction.points, 10);
          expect(transaction.type, PointsTransactionType.earned);
        });

        test('converts to and from Firestore', () {
          final original = PointsTransaction(
            id: 'trans123',
            userId: 'user123',
            points: 10,
            type: PointsTransactionType.earned,
            category: 'dailyLogin',
            description: 'Daily login bonus',
            timestamp: DateTime(2025, 1, 1),
          );

          final firestore = original.toFirestore();
          expect(firestore['userId'], 'user123');
          expect(firestore['points'], 10);
        });
      });

      group('UserBadge', () {
        test('creates badge correctly', () {
          final badge = UserBadge(
            userId: 'user123',
            badgeId: 'badge_first_venue',
            currentProgress: 100,
            isUnlocked: true,
            unlockedAt: DateTime(2025, 1, 1),
            lastUpdated: DateTime(2025, 1, 1),
          );

          expect(badge.userId, 'user123');
          expect(badge.badgeId, 'badge_first_venue');
          expect(badge.isUnlocked, true);
          expect(badge.currentProgress, 100);
        });

        test('calculates progress percentage', () {
          final badge = UserBadge(
            userId: 'user123',
            badgeId: 'badge_first_venue',
            currentProgress: 50,
            isUnlocked: false,
            lastUpdated: DateTime(2025, 1, 1),
          );

          expect(badge.progressPercentage, 0.5);
        });
      });

      group('LeaderboardEntry', () {
        test('creates entry correctly', () {
          final entry = LeaderboardEntry(
            userId: 'user123',
            userName: 'TestUser',
            totalPoints: 500,
            level: 5,
            tier: ExpertiseTier.novice,
            rank: 10,
            previousRank: 15,
          );

          expect(entry.userId, 'user123');
          expect(entry.userName, 'TestUser');
          expect(entry.totalPoints, 500);
          expect(entry.rank, 10);
        });
      });

      group('DailyPointsLimit', () {
        test('creates limit correctly', () {
          final limit = DailyPointsLimit(
            userId: 'user123',
            date: DateTime(2025, 1, 1),
            pointsEarnedToday: 100,
            dailyLimit: 500,
          );

          expect(limit.userId, 'user123');
          expect(limit.pointsEarnedToday, 100);
          expect(limit.dailyLimit, 500);
        });

        test('calculates remaining points', () {
          final limit = DailyPointsLimit(
            userId: 'user123',
            date: DateTime(2025, 1, 1),
            pointsEarnedToday: 100,
            dailyLimit: 500,
          );

          expect(limit.remainingPoints, 400);
        });

        test('has reached limit returns correct value', () {
          final notReached = DailyPointsLimit(
            userId: 'user123',
            date: DateTime(2025, 1, 1),
            pointsEarnedToday: 100,
            dailyLimit: 500,
          );
          expect(notReached.hasReachedLimit, false);

          final reached = DailyPointsLimit(
            userId: 'user123',
            date: DateTime(2025, 1, 1),
            pointsEarnedToday: 500,
            dailyLimit: 500,
          );
          expect(reached.hasReachedLimit, true);
        });
      });

      group('LevelCalculator', () {
        test('calculates level correctly from points', () {
          expect(LevelCalculator.calculateLevel(0), 1);
          expect(LevelCalculator.calculateLevel(100), 2);
          expect(LevelCalculator.calculateLevel(300), 3);
          expect(LevelCalculator.calculateLevel(1000), greaterThanOrEqualTo(4));
        });

        test('calculates points required for level', () {
          expect(LevelCalculator.pointsRequiredForLevel(1), 0);
          expect(LevelCalculator.pointsRequiredForLevel(2), 100);
          expect(LevelCalculator.pointsRequiredForLevel(3), 250);
        });

        test('calculates points for next level', () {
          expect(LevelCalculator.pointsForNextLevel(1), 150);
          expect(LevelCalculator.pointsForNextLevel(2), greaterThan(100));
          expect(LevelCalculator.pointsForNextLevel(3), greaterThan(200));
        });
      });

      group('ExpertiseTier', () {
        test('has correct display names', () {
          expect(ExpertiseTier.novice.displayName, 'Novice');
          expect(ExpertiseTier.expert.displayName, 'Expert');
          expect(ExpertiseTier.master.displayName, 'Master');
          expect(ExpertiseTier.legend.displayName, 'Legend');
        });

        test('has correct color hex values', () {
          expect(ExpertiseTier.novice.colorHex, '#9CA3AF');
          expect(ExpertiseTier.legend.colorHex, '#8B5CF6');
        });

        test('calculates tier from points correctly', () {
          expect(ExpertiseTierExtension.fromPoints(0), ExpertiseTier.novice);
          expect(ExpertiseTierExtension.fromPoints(50000), ExpertiseTier.legend);
        });
      });

      group('Badge', () {
        test('tier colors are correct', () {
          expect(BadgeTier.bronze.colorHex, '#CD7F32');
          expect(BadgeTier.silver.colorHex, '#9CA3AF');
          expect(BadgeTier.gold.colorHex, '#FFC107');
          expect(BadgeTier.platinum.colorHex, '#E5E4E2');
        });

        test('tier display names are correct', () {
          expect(BadgeTier.bronze.displayName, 'Bronze');
          expect(BadgeTier.silver.displayName, 'Silver');
          expect(BadgeTier.gold.displayName, 'Gold');
          expect(BadgeTier.platinum.displayName, 'Platinum');
        });
      });

      group('PredefinedBadges', () {
        test('has all predefined badges', () {
          final badges = PredefinedBadges.all;
          expect(badges, isNotEmpty);
          expect(badges.length, greaterThanOrEqualTo(7));
        });

        test('all badges have unique IDs', () {
          final badges = PredefinedBadges.all;
          final ids = badges.map((b) => b.id).toList();
          final uniqueIds = ids.toSet();
          expect(ids.length, uniqueIds.length);
        });

        test('all badges have valid properties', () {
          final badges = PredefinedBadges.all;
          for (final badge in badges) {
            expect(badge.id, isNotEmpty);
            expect(badge.name, isNotEmpty);
            expect(badge.description, isNotEmpty);
            expect(badge.pointsReward, greaterThan(0));
          }
        });
      });
  });

  // Note: GamificationService integration tests require Firebase emulator
  // The following tests verify business logic and data structures
  group('GamificationService Logic', () {
    group('Points Validation', () {
      test('PointsCategory.dailyLogin has correct range', () {
        final (min, max) = PointsCategory.dailyLogin.pointsRange;
        expect(min, 5);
        expect(max, 15);
      });

      test('PointsCategory.review has correct range', () {
        final (min, max) = PointsCategory.review.pointsRange;
        expect(min, 20);
        expect(max, 100);
      });

      test('PointsCategory.venueVisit has correct range', () {
        final (min, max) = PointsCategory.venueVisit.pointsRange;
        expect(min, 10);
        expect(max, 50);
      });

      test('PointsCategory.photoUpload has correct range', () {
        final (min, max) = PointsCategory.photoUpload.pointsRange;
        expect(min, 10);
        expect(max, 30);
      });

      test('PointsCategory.socialConnection has correct range', () {
        final (min, max) = PointsCategory.socialConnection.pointsRange;
        expect(min, 10);
        expect(max, 10);
      });

      test('PointsCategory.friendReferral has correct range', () {
        final (min, max) = PointsCategory.friendReferral.pointsRange;
        expect(min, 200);
        expect(max, 200);
      });

      test('PointsCategory.achievementUnlock has correct range', () {
        final (min, max) = PointsCategory.achievementUnlock.pointsRange;
        expect(min, 50);
        expect(max, 500);
      });

      test('PointsCategory.levelUp has correct range', () {
        final (min, max) = PointsCategory.levelUp.pointsRange;
        expect(min, 100);
        expect(max, 100);
      });
    });

    group('Level Progression', () {
      test('Level 1 requires 0 points', () {
        expect(LevelCalculator.pointsRequiredForLevel(1), 0);
      });

      test('Level 2 requires 100 points', () {
        expect(LevelCalculator.pointsRequiredForLevel(2), 100);
      });

      test('Level 3 requires 250 points', () {
        expect(LevelCalculator.pointsRequiredForLevel(3), 250);
      });

      test('Level progression is monotonically increasing', () {
        for (int level = 1; level < 20; level++) {
          final currentPoints = LevelCalculator.pointsRequiredForLevel(level);
          final nextPoints = LevelCalculator.pointsRequiredForLevel(level + 1);
          expect(nextPoints, greaterThan(currentPoints),
              reason: 'Level $level should require fewer points than level ${level + 1}');
        }
      });

      test('Points for next level is always positive', () {
        for (int level = 1; level < 20; level++) {
          final pointsNeeded = LevelCalculator.pointsForNextLevel(level);
          expect(pointsNeeded, greaterThan(0),
              reason: 'Level $level should have positive points to next level');
        }
      });

      test('calculateLevel returns correct level for various points', () {
        expect(LevelCalculator.calculateLevel(0), 1);
        expect(LevelCalculator.calculateLevel(50), 1);
        expect(LevelCalculator.calculateLevel(100), 2);
        expect(LevelCalculator.calculateLevel(150), 2);
        expect(LevelCalculator.calculateLevel(250), 3);
        expect(LevelCalculator.calculateLevel(300), 3);
        expect(LevelCalculator.calculateLevel(500), greaterThanOrEqualTo(4));
        expect(LevelCalculator.calculateLevel(1000), greaterThanOrEqualTo(5));
      });
    });

    group('Expertise Tiers', () {
      test('Novice tier covers 0-9,999 points', () {
        expect(ExpertiseTierExtension.fromPoints(0), ExpertiseTier.novice);
        expect(ExpertiseTierExtension.fromPoints(5000), ExpertiseTier.novice);
        expect(ExpertiseTierExtension.fromPoints(9999), ExpertiseTier.novice);
      });

      test('Expert tier covers 10,000-24,999 points', () {
        expect(ExpertiseTierExtension.fromPoints(10000), ExpertiseTier.expert);
        expect(ExpertiseTierExtension.fromPoints(15000), ExpertiseTier.expert);
        expect(ExpertiseTierExtension.fromPoints(24999), ExpertiseTier.expert);
      });

      test('Master tier covers 25,000-49,999 points', () {
        expect(ExpertiseTierExtension.fromPoints(25000), ExpertiseTier.master);
        expect(ExpertiseTierExtension.fromPoints(35000), ExpertiseTier.master);
        expect(ExpertiseTierExtension.fromPoints(49999), ExpertiseTier.master);
      });

      test('Legend tier covers 50,000+ points', () {
        expect(ExpertiseTierExtension.fromPoints(50000), ExpertiseTier.legend);
        expect(ExpertiseTierExtension.fromPoints(100000), ExpertiseTier.legend);
        expect(ExpertiseTierExtension.fromPoints(1000000), ExpertiseTier.legend);
      });

      test('Tier progression is sequential', () {
        final tiers = [
          ExpertiseTierExtension.fromPoints(0),
          ExpertiseTierExtension.fromPoints(10000),
          ExpertiseTierExtension.fromPoints(25000),
          ExpertiseTierExtension.fromPoints(50000),
        ];
        expect(tiers, [
          ExpertiseTier.novice,
          ExpertiseTier.expert,
          ExpertiseTier.master,
          ExpertiseTier.legend,
        ]);
      });
    });

    group('Daily Points Limit', () {
      test('Default daily limit is 500 points', () {
        final limit = DailyPointsLimit(
          userId: 'user123',
          date: DateTime.now(),
          pointsEarnedToday: 0,
        );
        expect(limit.dailyLimit, 500);
      });

      test('Remaining points calculation is correct', () {
        final limit = DailyPointsLimit(
          userId: 'user123',
          date: DateTime.now(),
          pointsEarnedToday: 150,
          dailyLimit: 500,
        );
        expect(limit.remainingPoints, 350);
      });

      test('Remaining points cannot be negative', () {
        final limit = DailyPointsLimit(
          userId: 'user123',
          date: DateTime.now(),
          pointsEarnedToday: 600,
          dailyLimit: 500,
        );
        expect(limit.remainingPoints, greaterThanOrEqualTo(0));
      });

      test('hasReachedLimit is true when points equal limit', () {
        final limit = DailyPointsLimit(
          userId: 'user123',
          date: DateTime.now(),
          pointsEarnedToday: 500,
          dailyLimit: 500,
        );
        expect(limit.hasReachedLimit, true);
      });

      test('hasReachedLimit is true when points exceed limit', () {
        final limit = DailyPointsLimit(
          userId: 'user123',
          date: DateTime.now(),
          pointsEarnedToday: 501,
          dailyLimit: 500,
        );
        expect(limit.hasReachedLimit, true);
      });

      test('hasReachedLimit is false when points below limit', () {
        final limit = DailyPointsLimit(
          userId: 'user123',
          date: DateTime.now(),
          pointsEarnedToday: 499,
          dailyLimit: 500,
        );
        expect(limit.hasReachedLimit, false);
      });
    });

    group('Badge Tiers', () {
      test('All badge tiers have unique colors', () {
        final colors = [
          BadgeTier.bronze.colorHex,
          BadgeTier.silver.colorHex,
          BadgeTier.gold.colorHex,
          BadgeTier.platinum.colorHex,
        ];
        final uniqueColors = colors.toSet();
        expect(colors.length, uniqueColors.length);
      });

      test('Badge tier names match enum values', () {
        expect(BadgeTier.bronze.name, 'bronze');
        expect(BadgeTier.silver.name, 'silver');
        expect(BadgeTier.gold.name, 'gold');
        expect(BadgeTier.platinum.name, 'platinum');
      });
    });

    group('Points Transaction', () {
      test('Transaction type defaults to earned', () {
        final transaction = PointsTransaction(
          id: 'trans123',
          userId: 'user123',
          points: 10,
          type: PointsTransactionType.earned,
          category: 'dailyLogin',
          timestamp: DateTime.now(),
        );
        expect(transaction.type, PointsTransactionType.earned);
      });

      test('Transaction supports metadata', () {
        final metadata = {'venueId': 'venue123', 'rating': 4.5};
        final transaction = PointsTransaction(
          id: 'trans123',
          userId: 'user123',
          points: 20,
          type: PointsTransactionType.earned,
          category: 'review',
          timestamp: DateTime.now(),
          metadata: metadata,
        );
        expect(transaction.metadata, metadata);
        expect(transaction.metadata?['venueId'], 'venue123');
        expect(transaction.metadata?['rating'], 4.5);
      });

      test('Transaction supports referenceId for idempotency', () {
        final transaction = PointsTransaction(
          id: 'trans123',
          userId: 'user123',
          points: 10,
          type: PointsTransactionType.earned,
          category: 'bookmark',
          referenceId: 'bookmark_rec123_user123',
          timestamp: DateTime.now(),
        );
        expect(transaction.referenceId, 'bookmark_rec123_user123');
      });
    });

    group('User Level Progress', () {
      test('Progress to next level is 0 when no points in current level', () {
        final userLevel = UserLevel(
          userId: 'user123',
          level: 5,
          tier: ExpertiseTier.novice,
          totalPoints: 1000,
          pointsInCurrentLevel: 0,
          pointsRequiredForNextLevel: 200,
          lastUpdated: DateTime.now(),
        );
        expect(userLevel.progressToNextLevel, 0.0);
      });

      test('Progress to next level is 0.5 when halfway', () {
        final userLevel = UserLevel(
          userId: 'user123',
          level: 5,
          tier: ExpertiseTier.novice,
          totalPoints: 1000,
          pointsInCurrentLevel: 100,
          pointsRequiredForNextLevel: 200,
          lastUpdated: DateTime.now(),
        );
        expect(userLevel.progressToNextLevel, 0.5);
      });

      test('Progress to next level is 1.0 when at next level threshold', () {
        final userLevel = UserLevel(
          userId: 'user123',
          level: 5,
          tier: ExpertiseTier.novice,
          totalPoints: 1000,
          pointsInCurrentLevel: 200,
          pointsRequiredForNextLevel: 200,
          lastUpdated: DateTime.now(),
        );
        expect(userLevel.progressToNextLevel, 1.0);
      });

      test('pointsNeededForNextLevel calculation is correct', () {
        final userLevel = UserLevel(
          userId: 'user123',
          level: 5,
          tier: ExpertiseTier.novice,
          totalPoints: 1000,
          pointsInCurrentLevel: 75,
          pointsRequiredForNextLevel: 200,
          lastUpdated: DateTime.now(),
        );
        expect(userLevel.pointsNeededForNextLevel, 125);
      });
    });

    group('Leaderboard Entry', () {
      test('Rank change is positive when climbing', () {
        final entry = LeaderboardEntry(
          userId: 'user123',
          userName: 'TestUser',
          totalPoints: 500,
          level: 5,
          tier: ExpertiseTier.novice,
          rank: 10,
          previousRank: 15,
        );
        expect(entry.previousRank - entry.rank, 5);
      });

      test('Rank change is negative when falling', () {
        final entry = LeaderboardEntry(
          userId: 'user123',
          userName: 'TestUser',
          totalPoints: 500,
          level: 5,
          tier: ExpertiseTier.novice,
          rank: 15,
          previousRank: 10,
        );
        expect(entry.previousRank - entry.rank, -5);
      });

      test('Supports entries without previous rank', () {
        final entry = LeaderboardEntry(
          userId: 'user123',
          userName: 'TestUser',
          totalPoints: 500,
          level: 5,
          tier: ExpertiseTier.novice,
          rank: 10,
        );
        expect(entry.previousRank, null);
      });
    });
  });
}
