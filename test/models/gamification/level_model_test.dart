import 'package:flutter_test/flutter_test.dart';
import 'package:yajid/models/gamification/level_model.dart';

void main() {
  group('UserLevel', () {
    test('initial creates level 1 user', () {
      final level = UserLevel.initial('user123');

      expect(level.userId, 'user123');
      expect(level.level, 1);
      expect(level.tier, ExpertiseTier.novice);
      expect(level.totalPoints, 0);
      expect(level.pointsInCurrentLevel, 0);
      expect(level.pointsRequiredForNextLevel, 100);
    });

    test('progressToNextLevel calculates correctly', () {
      final level = UserLevel(
        userId: 'user123',
        level: 5,
        tier: ExpertiseTier.explorer,
        totalPoints: 500,
        pointsInCurrentLevel: 50,
        pointsRequiredForNextLevel: 100,
        lastUpdated: DateTime.now(),
      );

      expect(level.progressToNextLevel, 0.5); // 50/100 = 0.5
    });

    test('progressToNextLevel clamps to 1.0', () {
      final level = UserLevel(
        userId: 'user123',
        level: 5,
        tier: ExpertiseTier.explorer,
        totalPoints: 500,
        pointsInCurrentLevel: 150,
        pointsRequiredForNextLevel: 100,
        lastUpdated: DateTime.now(),
      );

      expect(level.progressToNextLevel, 1.0); // Clamped at 1.0
    });

    test('pointsNeededForNextLevel calculates correctly', () {
      final level = UserLevel(
        userId: 'user123',
        level: 5,
        tier: ExpertiseTier.explorer,
        totalPoints: 500,
        pointsInCurrentLevel: 75,
        pointsRequiredForNextLevel: 100,
        lastUpdated: DateTime.now(),
      );

      expect(level.pointsNeededForNextLevel, 25); // 100 - 75
    });

    test('copyWith updates specified fields', () {
      final now = DateTime.now();
      final original = UserLevel.initial('user123');

      final updated = original.copyWith(
        level: 5,
        totalPoints: 500,
        tier: ExpertiseTier.explorer,
      );

      expect(updated.level, 5);
      expect(updated.totalPoints, 500);
      expect(updated.tier, ExpertiseTier.explorer);
      expect(updated.userId, original.userId); // Unchanged
    });
  });

  group('ExpertiseTier', () {
    test('displayName returns correct values', () {
      expect(ExpertiseTier.novice.displayName, 'Novice');
      expect(ExpertiseTier.explorer.displayName, 'Explorer');
      expect(ExpertiseTier.adventurer.displayName, 'Adventurer');
      expect(ExpertiseTier.expert.displayName, 'Expert');
      expect(ExpertiseTier.master.displayName, 'Master');
      expect(ExpertiseTier.legend.displayName, 'Legend');
    });

    test('displayNameAr returns correct Arabic names', () {
      expect(ExpertiseTier.novice.displayNameAr, 'مبتدئ');
      expect(ExpertiseTier.explorer.displayNameAr, 'مستكشف');
      expect(ExpertiseTier.adventurer.displayNameAr, 'مغامر');
      expect(ExpertiseTier.expert.displayNameAr, 'خبير');
      expect(ExpertiseTier.master.displayNameAr, 'أستاذ');
      expect(ExpertiseTier.legend.displayNameAr, 'أسطورة');
    });

    test('pointsRange returns correct ranges', () {
      expect(ExpertiseTier.novice.pointsRange, (0, 99));
      expect(ExpertiseTier.explorer.pointsRange, (100, 399));
      expect(ExpertiseTier.adventurer.pointsRange, (400, 899));
      expect(ExpertiseTier.expert.pointsRange, (900, 1599));
      expect(ExpertiseTier.master.pointsRange, (1600, 2499));
      expect(ExpertiseTier.legend.pointsRange, (2500, 999999));
    });

    test('colorHex returns valid color codes', () {
      expect(ExpertiseTier.novice.colorHex, '#9CA3AF');
      expect(ExpertiseTier.explorer.colorHex, '#CD7F32');
      expect(ExpertiseTier.adventurer.colorHex, '#9CA3AF');
      expect(ExpertiseTier.expert.colorHex, '#FFC107');
      expect(ExpertiseTier.master.colorHex, '#E5E4E2');
      expect(ExpertiseTier.legend.colorHex, '#8B5CF6');
    });

    test('iconName returns valid icon names', () {
      expect(ExpertiseTier.novice.iconName, 'circle');
      expect(ExpertiseTier.explorer.iconName, 'explore');
      expect(ExpertiseTier.adventurer.iconName, 'landscape');
      expect(ExpertiseTier.expert.iconName, 'military_tech');
      expect(ExpertiseTier.master.iconName, 'workspace_premium');
      expect(ExpertiseTier.legend.iconName, 'auto_awesome');
    });

    test('benefits lists are not empty', () {
      for (final tier in ExpertiseTier.values) {
        expect(tier.benefits, isNotEmpty);
      }
    });

    test('fromPoints returns correct tier', () {
      expect(ExpertiseTierExtension.fromPoints(0), ExpertiseTier.novice);
      expect(ExpertiseTierExtension.fromPoints(50), ExpertiseTier.novice);
      expect(ExpertiseTierExtension.fromPoints(99), ExpertiseTier.novice);
      expect(ExpertiseTierExtension.fromPoints(100), ExpertiseTier.explorer);
      expect(ExpertiseTierExtension.fromPoints(250), ExpertiseTier.explorer);
      expect(ExpertiseTierExtension.fromPoints(400), ExpertiseTier.adventurer);
      expect(ExpertiseTierExtension.fromPoints(700), ExpertiseTier.adventurer);
      expect(ExpertiseTierExtension.fromPoints(900), ExpertiseTier.expert);
      expect(ExpertiseTierExtension.fromPoints(1200), ExpertiseTier.expert);
      expect(ExpertiseTierExtension.fromPoints(1600), ExpertiseTier.master);
      expect(ExpertiseTierExtension.fromPoints(2000), ExpertiseTier.master);
      expect(ExpertiseTierExtension.fromPoints(2500), ExpertiseTier.legend);
      expect(ExpertiseTierExtension.fromPoints(10000), ExpertiseTier.legend);
    });

    test('nextTier returns correct progression', () {
      expect(ExpertiseTier.novice.nextTier, ExpertiseTier.explorer);
      expect(ExpertiseTier.explorer.nextTier, ExpertiseTier.adventurer);
      expect(ExpertiseTier.adventurer.nextTier, ExpertiseTier.expert);
      expect(ExpertiseTier.expert.nextTier, ExpertiseTier.master);
      expect(ExpertiseTier.master.nextTier, ExpertiseTier.legend);
      expect(ExpertiseTier.legend.nextTier, null); // Max tier
    });
  });

  group('LeaderboardEntry', () {
    test('rankChange calculates correctly', () {
      final entry = LeaderboardEntry(
        userId: 'user123',
        userName: 'Test User',
        totalPoints: 1000,
        level: 5,
        tier: ExpertiseTier.explorer,
        rank: 3,
        previousRank: 5,
      );

      expect(entry.rankChange, 2); // Improved from 5 to 3
    });

    test('isRankImproved true when rank decreased', () {
      final entry = LeaderboardEntry(
        userId: 'user123',
        userName: 'Test User',
        totalPoints: 1000,
        level: 5,
        tier: ExpertiseTier.explorer,
        rank: 3,
        previousRank: 5,
      );

      expect(entry.isRankImproved, true);
    });

    test('isRankImproved false when rank increased', () {
      final entry = LeaderboardEntry(
        userId: 'user123',
        userName: 'Test User',
        totalPoints: 1000,
        level: 5,
        tier: ExpertiseTier.explorer,
        rank: 5,
        previousRank: 3,
      );

      expect(entry.isRankImproved, false);
    });

    test('fromMap handles missing display name', () {
      final data = {
        'userId': 'user123',
        'totalPoints': 500,
        'level': 3,
        'tier': 'explorer',
        'rank': 10,
      };

      final entry = LeaderboardEntry.fromMap(data);
      expect(entry.userName, 'Anonymous'); // Default when missing
    });
  });

  group('LevelCalculator', () {
    test('calculateLevel returns 1 for 0-99 points', () {
      expect(LevelCalculator.calculateLevel(0), 1);
      expect(LevelCalculator.calculateLevel(50), 1);
      expect(LevelCalculator.calculateLevel(99), 1);
    });

    test('calculateLevel returns correct level for various points', () {
      expect(LevelCalculator.calculateLevel(100), 2); // Exactly level 2
      expect(LevelCalculator.calculateLevel(150), 2); // Still level 2
      expect(LevelCalculator.calculateLevel(250), 3); // Level 3
      expect(LevelCalculator.calculateLevel(500), 4); // Level 4
    });

    test('pointsRequiredForLevel calculates correctly', () {
      expect(LevelCalculator.pointsRequiredForLevel(1), 0); // Start at level 1
      expect(LevelCalculator.pointsRequiredForLevel(2), 100); // Need 100 for level 2
      expect(LevelCalculator.pointsRequiredForLevel(3), greaterThan(100)); // Level 3 needs more
    });

    test('pointsForNextLevel uses exponential formula', () {
      final level1to2 = LevelCalculator.pointsForNextLevel(1);
      final level2to3 = LevelCalculator.pointsForNextLevel(2);
      final level3to4 = LevelCalculator.pointsForNextLevel(3);

      expect(level1to2, 150); // 100 * 1.5^1
      expect(level2to3, greaterThan(level1to2)); // Increases exponentially
      expect(level3to4, greaterThan(level2to3)); // Continues to increase
    });

    test('calculateLevel and pointsRequiredForLevel are consistent', () {
      for (int level = 2; level <= 10; level++) {
        final pointsNeeded = LevelCalculator.pointsRequiredForLevel(level);
        final calculatedLevel = LevelCalculator.calculateLevel(pointsNeeded);
        expect(calculatedLevel, level);
      }
    });

    test('handles large point values', () {
      final level = LevelCalculator.calculateLevel(100000);
      expect(level, greaterThan(10)); // Should be high level
      expect(level, lessThan(100)); // But not unreasonably high
    });
  });

  group('LevelUpReward', () {
    test('creates reward with all fields', () {
      final reward = LevelUpReward(
        level: 5,
        bonusPoints: 100,
        unlockedFeatures: ['feature1', 'feature2'],
        specialBadgeId: 'badge123',
      );

      expect(reward.level, 5);
      expect(reward.bonusPoints, 100);
      expect(reward.unlockedFeatures.length, 2);
      expect(reward.specialBadgeId, 'badge123');
    });

    test('creates reward with default empty features', () {
      final reward = LevelUpReward(
        level: 1,
        bonusPoints: 50,
      );

      expect(reward.unlockedFeatures, isEmpty);
      expect(reward.specialBadgeId, null);
    });
  });
}
