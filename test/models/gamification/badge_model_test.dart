import 'package:flutter_test/flutter_test.dart';
import 'package:yajid/models/gamification/badge_model.dart';

void main() {
  group('Badge', () {
    test('creates badge with all fields', () {
      final badge = Badge(
        id: 'badge123',
        name: 'Test Badge',
        nameAr: 'شارة اختبار',
        description: 'Test Description',
        descriptionAr: 'وصف الاختبار',
        category: BadgeCategory.explorer,
        tier: BadgeTier.gold,
        iconUrl: 'https://example.com/badge.png',
        requiredProgress: 10,
        pointsReward: 100,
        unlockCriteria: {'visits': 10},
      );

      expect(badge.id, 'badge123');
      expect(badge.name, 'Test Badge');
      expect(badge.nameAr, 'شارة اختبار');
      expect(badge.description, 'Test Description');
      expect(badge.descriptionAr, 'وصف الاختبار');
      expect(badge.category, BadgeCategory.explorer);
      expect(badge.tier, BadgeTier.gold);
      expect(badge.iconUrl, 'https://example.com/badge.png');
      expect(badge.requiredProgress, 10);
      expect(badge.pointsReward, 100);
      expect(badge.unlockCriteria?['visits'], 10);
    });

    test('creates badge without optional criteria', () {
      final badge = Badge(
        id: 'badge123',
        name: 'Simple Badge',
        nameAr: 'شارة بسيطة',
        description: 'Simple',
        descriptionAr: 'بسيط',
        category: BadgeCategory.social,
        tier: BadgeTier.bronze,
        iconUrl: 'icon.png',
        requiredProgress: 1,
        pointsReward: 50,
      );

      expect(badge.unlockCriteria, null);
    });
  });

  group('UserBadge', () {
    test('creates user badge with all fields', () {
      final now = DateTime.now();
      final userBadge = UserBadge(
        userId: 'user123',
        badgeId: 'badge456',
        currentProgress: 75,
        isUnlocked: false,
        lastUpdated: now,
      );

      expect(userBadge.userId, 'user123');
      expect(userBadge.badgeId, 'badge456');
      expect(userBadge.currentProgress, 75);
      expect(userBadge.isUnlocked, false);
      expect(userBadge.unlockedAt, null);
      expect(userBadge.lastUpdated, now);
    });

    test('progressPercentage calculates correctly', () {
      final userBadge = UserBadge(
        userId: 'user123',
        badgeId: 'badge456',
        currentProgress: 50,
        isUnlocked: false,
        lastUpdated: DateTime.now(),
      );

      expect(userBadge.progressPercentage, 0.5); // 50/100
    });

    test('progressPercentage clamps at 1.0', () {
      final userBadge = UserBadge(
        userId: 'user123',
        badgeId: 'badge456',
        currentProgress: 150,
        isUnlocked: true,
        lastUpdated: DateTime.now(),
      );

      expect(userBadge.progressPercentage, 1.0); // Clamped
    });

    test('progressPercentage handles zero progress', () {
      final userBadge = UserBadge(
        userId: 'user123',
        badgeId: 'badge456',
        currentProgress: 0,
        isUnlocked: false,
        lastUpdated: DateTime.now(),
      );

      expect(userBadge.progressPercentage, 0.0);
    });

    test('copyWith updates specified fields', () {
      final now = DateTime.now();
      final later = now.add(Duration(hours: 1));
      final original = UserBadge(
        userId: 'user123',
        badgeId: 'badge456',
        currentProgress: 50,
        isUnlocked: false,
        lastUpdated: now,
      );

      final updated = original.copyWith(
        currentProgress: 100,
        isUnlocked: true,
        unlockedAt: later,
      );

      expect(updated.currentProgress, 100);
      expect(updated.isUnlocked, true);
      expect(updated.unlockedAt, later);
      expect(updated.userId, original.userId); // Unchanged
    });
  });

  group('BadgeCategory', () {
    test('displayName returns correct values', () {
      expect(BadgeCategory.explorer.displayName, 'Explorer');
      expect(BadgeCategory.foodie.displayName, 'Foodie');
      expect(BadgeCategory.social.displayName, 'Social');
      expect(BadgeCategory.contributor.displayName, 'Contributor');
      expect(BadgeCategory.event.displayName, 'Event');
      expect(BadgeCategory.achievement.displayName, 'Achievement');
      expect(BadgeCategory.special.displayName, 'Special');
      expect(BadgeCategory.other.displayName, 'Other');
    });

    test('displayNameAr returns correct Arabic names', () {
      expect(BadgeCategory.explorer.displayNameAr, 'مستكشف');
      expect(BadgeCategory.foodie.displayNameAr, 'ذواق الطعام');
      expect(BadgeCategory.social.displayNameAr, 'اجتماعي');
      expect(BadgeCategory.contributor.displayNameAr, 'مساهم');
      expect(BadgeCategory.event.displayNameAr, 'فعاليات');
      expect(BadgeCategory.achievement.displayNameAr, 'إنجاز');
      expect(BadgeCategory.special.displayNameAr, 'خاص');
      expect(BadgeCategory.other.displayNameAr, 'أخرى');
    });

    test('iconName returns valid icon names', () {
      expect(BadgeCategory.explorer.iconName, 'explore');
      expect(BadgeCategory.foodie.iconName, 'restaurant');
      expect(BadgeCategory.social.iconName, 'group');
      expect(BadgeCategory.contributor.iconName, 'edit');
      expect(BadgeCategory.event.iconName, 'event');
      expect(BadgeCategory.achievement.iconName, 'emoji_events');
      expect(BadgeCategory.special.iconName, 'stars');
      expect(BadgeCategory.other.iconName, 'more_horiz');
    });

    test('all categories have non-empty names', () {
      for (final category in BadgeCategory.values) {
        expect(category.displayName, isNotEmpty);
        expect(category.displayNameAr, isNotEmpty);
        expect(category.iconName, isNotEmpty);
      }
    });
  });

  group('BadgeTier', () {
    test('displayName returns correct values', () {
      expect(BadgeTier.bronze.displayName, 'Bronze');
      expect(BadgeTier.silver.displayName, 'Silver');
      expect(BadgeTier.gold.displayName, 'Gold');
      expect(BadgeTier.platinum.displayName, 'Platinum');
      expect(BadgeTier.diamond.displayName, 'Diamond');
    });

    test('displayNameAr returns correct Arabic names', () {
      expect(BadgeTier.bronze.displayNameAr, 'برونزية');
      expect(BadgeTier.silver.displayNameAr, 'فضية');
      expect(BadgeTier.gold.displayNameAr, 'ذهبية');
      expect(BadgeTier.platinum.displayNameAr, 'بلاتينية');
      expect(BadgeTier.diamond.displayNameAr, 'ماسية');
    });

    test('colorHex returns valid hex color codes', () {
      expect(BadgeTier.bronze.colorHex, '#CD7F32');
      expect(BadgeTier.silver.colorHex, '#9CA3AF');
      expect(BadgeTier.gold.colorHex, '#FFC107');
      expect(BadgeTier.platinum.colorHex, '#E5E4E2');
      expect(BadgeTier.diamond.colorHex, '#B9F2FF');
    });

    test('colorHex starts with hash symbol', () {
      for (final tier in BadgeTier.values) {
        expect(tier.colorHex.startsWith('#'), true);
      }
    });

    test('pointsReward increases with tier', () {
      expect(BadgeTier.bronze.pointsReward, 50);
      expect(BadgeTier.silver.pointsReward, 100);
      expect(BadgeTier.gold.pointsReward, 200);
      expect(BadgeTier.platinum.pointsReward, 350);
      expect(BadgeTier.diamond.pointsReward, 500);

      // Verify progression
      expect(BadgeTier.silver.pointsReward, greaterThan(BadgeTier.bronze.pointsReward));
      expect(BadgeTier.gold.pointsReward, greaterThan(BadgeTier.silver.pointsReward));
      expect(BadgeTier.platinum.pointsReward, greaterThan(BadgeTier.gold.pointsReward));
      expect(BadgeTier.diamond.pointsReward, greaterThan(BadgeTier.platinum.pointsReward));
    });

    test('all tiers have positive points rewards', () {
      for (final tier in BadgeTier.values) {
        expect(tier.pointsReward, greaterThan(0));
      }
    });
  });

  group('PredefinedBadges', () {
    test('all predefined badges have valid structure', () {
      for (final badge in PredefinedBadges.all) {
        expect(badge.id, isNotEmpty);
        expect(badge.name, isNotEmpty);
        expect(badge.nameAr, isNotEmpty);
        expect(badge.description, isNotEmpty);
        expect(badge.descriptionAr, isNotEmpty);
        expect(badge.iconUrl, isNotEmpty);
        expect(badge.requiredProgress, greaterThan(0));
        expect(badge.pointsReward, greaterThan(0));
      }
    });

    test('firstVenueVisit badge has correct properties', () {
      final badge = PredefinedBadges.firstVenueVisit;

      expect(badge.id, 'badge_first_venue');
      expect(badge.name, 'First Steps');
      expect(badge.nameAr, 'الخطوات الأولى');
      expect(badge.category, BadgeCategory.explorer);
      expect(badge.tier, BadgeTier.bronze);
      expect(badge.requiredProgress, 1);
      expect(badge.pointsReward, 50);
    });

    test('cityExplorer badge has correct properties', () {
      final badge = PredefinedBadges.cityExplorer;

      expect(badge.id, 'badge_city_explorer');
      expect(badge.name, 'City Explorer');
      expect(badge.nameAr, 'مستكشف المدينة');
      expect(badge.category, BadgeCategory.explorer);
      expect(badge.tier, BadgeTier.silver);
      expect(badge.requiredProgress, 10);
      expect(badge.pointsReward, 100);
    });

    test('tastemaker badge has correct properties', () {
      final badge = PredefinedBadges.tastemaker;

      expect(badge.id, 'badge_tastemaker');
      expect(badge.name, 'Tastemaker');
      expect(badge.nameAr, 'خبير المذاق');
      expect(badge.category, BadgeCategory.foodie);
      expect(badge.tier, BadgeTier.bronze);
      expect(badge.requiredProgress, 5);
    });

    test('socialButterfly badge has correct properties', () {
      final badge = PredefinedBadges.socialButterfly;

      expect(badge.id, 'badge_social_butterfly');
      expect(badge.category, BadgeCategory.social);
      expect(badge.tier, BadgeTier.silver);
      expect(badge.requiredProgress, 10);
    });

    test('reviewer badge has correct properties', () {
      final badge = PredefinedBadges.reviewer;

      expect(badge.id, 'badge_reviewer');
      expect(badge.category, BadgeCategory.contributor);
      expect(badge.tier, BadgeTier.bronze);
      expect(badge.requiredProgress, 1);
    });

    test('topCritic badge has correct properties', () {
      final badge = PredefinedBadges.topCritic;

      expect(badge.id, 'badge_top_critic');
      expect(badge.category, BadgeCategory.contributor);
      expect(badge.tier, BadgeTier.gold);
      expect(badge.requiredProgress, 50);
      expect(badge.pointsReward, 200);
    });

    test('ramadanSpecial badge has correct properties', () {
      final badge = PredefinedBadges.ramadanSpecial;

      expect(badge.id, 'badge_ramadan_2025');
      expect(badge.category, BadgeCategory.event);
      expect(badge.tier, BadgeTier.gold);
      expect(badge.requiredProgress, 1);
    });

    test('all list contains all predefined badges', () {
      expect(PredefinedBadges.all.length, 7);
      expect(PredefinedBadges.all.contains(PredefinedBadges.firstVenueVisit), true);
      expect(PredefinedBadges.all.contains(PredefinedBadges.cityExplorer), true);
      expect(PredefinedBadges.all.contains(PredefinedBadges.tastemaker), true);
      expect(PredefinedBadges.all.contains(PredefinedBadges.socialButterfly), true);
      expect(PredefinedBadges.all.contains(PredefinedBadges.reviewer), true);
      expect(PredefinedBadges.all.contains(PredefinedBadges.topCritic), true);
      expect(PredefinedBadges.all.contains(PredefinedBadges.ramadanSpecial), true);
    });

    test('explorer badges have increasing difficulty', () {
      final first = PredefinedBadges.firstVenueVisit;
      final city = PredefinedBadges.cityExplorer;

      expect(city.requiredProgress, greaterThan(first.requiredProgress));
      expect(city.pointsReward, greaterThan(first.pointsReward));
    });

    test('contributor badges have increasing difficulty', () {
      final reviewer = PredefinedBadges.reviewer;
      final topCritic = PredefinedBadges.topCritic;

      expect(topCritic.requiredProgress, greaterThan(reviewer.requiredProgress));
      expect(topCritic.pointsReward, greaterThan(reviewer.pointsReward));
    });

    test('all badges have unique IDs', () {
      final ids = PredefinedBadges.all.map((b) => b.id).toList();
      final uniqueIds = ids.toSet();
      expect(ids.length, uniqueIds.length);
    });

    test('badges span multiple categories', () {
      final categories = PredefinedBadges.all.map((b) => b.category).toSet();
      expect(categories.length, greaterThan(1)); // Multiple categories represented
    });

    test('badges span multiple tiers', () {
      final tiers = PredefinedBadges.all.map((b) => b.tier).toSet();
      expect(tiers.length, greaterThan(1)); // Multiple tiers represented
    });
  });
}
