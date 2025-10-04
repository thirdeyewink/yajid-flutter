import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Badge definition
class Badge extends Equatable {
  final String id;
  final String name;
  final String nameAr; // Arabic name
  final String description;
  final String descriptionAr; // Arabic description
  final BadgeCategory category;
  final BadgeTier tier;
  final String iconUrl;
  final int requiredProgress;
  final int pointsReward;
  final Map<String, dynamic>? unlockCriteria;

  const Badge({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.description,
    required this.descriptionAr,
    required this.category,
    required this.tier,
    required this.iconUrl,
    required this.requiredProgress,
    required this.pointsReward,
    this.unlockCriteria,
  });

  factory Badge.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Badge(
      id: doc.id,
      name: data['name'],
      nameAr: data['nameAr'] ?? data['name'],
      description: data['description'],
      descriptionAr: data['descriptionAr'] ?? data['description'],
      category: BadgeCategory.values.firstWhere(
        (e) => e.name == data['category'],
        orElse: () => BadgeCategory.other,
      ),
      tier: BadgeTier.values.firstWhere(
        (e) => e.name == data['tier'],
        orElse: () => BadgeTier.bronze,
      ),
      iconUrl: data['iconUrl'],
      requiredProgress: data['requiredProgress'] ?? 1,
      pointsReward: data['pointsReward'] ?? 0,
      unlockCriteria: data['unlockCriteria'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'nameAr': nameAr,
      'description': description,
      'descriptionAr': descriptionAr,
      'category': category.name,
      'tier': tier.name,
      'iconUrl': iconUrl,
      'requiredProgress': requiredProgress,
      'pointsReward': pointsReward,
      'unlockCriteria': unlockCriteria,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        nameAr,
        description,
        descriptionAr,
        category,
        tier,
        iconUrl,
        requiredProgress,
        pointsReward,
        unlockCriteria,
      ];
}

/// User's badge progress and unlocked badges
class UserBadge extends Equatable {
  final String userId;
  final String badgeId;
  final int currentProgress;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final DateTime lastUpdated;

  const UserBadge({
    required this.userId,
    required this.badgeId,
    required this.currentProgress,
    required this.isUnlocked,
    this.unlockedAt,
    required this.lastUpdated,
  });

  double get progressPercentage => (currentProgress / 100).clamp(0.0, 1.0);

  factory UserBadge.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserBadge(
      userId: data['userId'],
      badgeId: doc.id,
      currentProgress: data['currentProgress'] ?? 0,
      isUnlocked: data['isUnlocked'] ?? false,
      unlockedAt: (data['unlockedAt'] as Timestamp?)?.toDate(),
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'currentProgress': currentProgress,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt != null ? Timestamp.fromDate(unlockedAt!) : null,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  UserBadge copyWith({
    String? userId,
    String? badgeId,
    int? currentProgress,
    bool? isUnlocked,
    DateTime? unlockedAt,
    DateTime? lastUpdated,
  }) {
    return UserBadge(
      userId: userId ?? this.userId,
      badgeId: badgeId ?? this.badgeId,
      currentProgress: currentProgress ?? this.currentProgress,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        badgeId,
        currentProgress,
        isUnlocked,
        unlockedAt,
        lastUpdated,
      ];
}

/// Badge categories (from DSG-007)
enum BadgeCategory {
  explorer, // Location-based achievements
  foodie, // Restaurant and cuisine variety
  social, // Friend referrals and connections
  contributor, // Reviews and photos
  event, // Cultural and seasonal participation
  achievement, // General achievements
  special, // Limited time or special badges
  other,
}

extension BadgeCategoryExtension on BadgeCategory {
  String get displayName {
    switch (this) {
      case BadgeCategory.explorer:
        return 'Explorer';
      case BadgeCategory.foodie:
        return 'Foodie';
      case BadgeCategory.social:
        return 'Social';
      case BadgeCategory.contributor:
        return 'Contributor';
      case BadgeCategory.event:
        return 'Event';
      case BadgeCategory.achievement:
        return 'Achievement';
      case BadgeCategory.special:
        return 'Special';
      case BadgeCategory.other:
        return 'Other';
    }
  }

  String get displayNameAr {
    switch (this) {
      case BadgeCategory.explorer:
        return 'مستكشف';
      case BadgeCategory.foodie:
        return 'ذواق الطعام';
      case BadgeCategory.social:
        return 'اجتماعي';
      case BadgeCategory.contributor:
        return 'مساهم';
      case BadgeCategory.event:
        return 'فعاليات';
      case BadgeCategory.achievement:
        return 'إنجاز';
      case BadgeCategory.special:
        return 'خاص';
      case BadgeCategory.other:
        return 'أخرى';
    }
  }

  String get iconName {
    switch (this) {
      case BadgeCategory.explorer:
        return 'explore';
      case BadgeCategory.foodie:
        return 'restaurant';
      case BadgeCategory.social:
        return 'group';
      case BadgeCategory.contributor:
        return 'edit';
      case BadgeCategory.event:
        return 'event';
      case BadgeCategory.achievement:
        return 'emoji_events';
      case BadgeCategory.special:
        return 'stars';
      case BadgeCategory.other:
        return 'more_horiz';
    }
  }
}

/// Badge tiers (difficulty/rarity levels)
enum BadgeTier {
  bronze, // Common, easy to get
  silver, // Uncommon, moderate difficulty
  gold, // Rare, challenging
  platinum, // Very rare, very challenging
  diamond, // Ultra rare, extremely challenging
}

extension BadgeTierExtension on BadgeTier {
  String get displayName {
    switch (this) {
      case BadgeTier.bronze:
        return 'Bronze';
      case BadgeTier.silver:
        return 'Silver';
      case BadgeTier.gold:
        return 'Gold';
      case BadgeTier.platinum:
        return 'Platinum';
      case BadgeTier.diamond:
        return 'Diamond';
    }
  }

  String get displayNameAr {
    switch (this) {
      case BadgeTier.bronze:
        return 'برونزية';
      case BadgeTier.silver:
        return 'فضية';
      case BadgeTier.gold:
        return 'ذهبية';
      case BadgeTier.platinum:
        return 'بلاتينية';
      case BadgeTier.diamond:
        return 'ماسية';
    }
  }

  /// Color code for UI (from DSG-007)
  String get colorHex {
    switch (this) {
      case BadgeTier.bronze:
        return '#CD7F32'; // Badge Bronze
      case BadgeTier.silver:
        return '#9CA3AF'; // Badge Silver
      case BadgeTier.gold:
        return '#FFC107'; // Points Gold
      case BadgeTier.platinum:
        return '#E5E4E2';
      case BadgeTier.diamond:
        return '#B9F2FF';
    }
  }

  /// Points reward for unlocking badge of this tier
  int get pointsReward {
    switch (this) {
      case BadgeTier.bronze:
        return 50;
      case BadgeTier.silver:
        return 100;
      case BadgeTier.gold:
        return 200;
      case BadgeTier.platinum:
        return 350;
      case BadgeTier.diamond:
        return 500;
    }
  }
}

/// Predefined badge examples (from WF-006)
class PredefinedBadges {
  // Explorer Badges
  static const Badge firstVenueVisit = Badge(
    id: 'badge_first_venue',
    name: 'First Steps',
    nameAr: 'الخطوات الأولى',
    description: 'Visit your first venue',
    descriptionAr: 'قم بزيارة مكانك الأول',
    category: BadgeCategory.explorer,
    tier: BadgeTier.bronze,
    iconUrl: 'assets/badges/first_venue.png',
    requiredProgress: 1,
    pointsReward: 50,
  );

  static const Badge cityExplorer = Badge(
    id: 'badge_city_explorer',
    name: 'City Explorer',
    nameAr: 'مستكشف المدينة',
    description: 'Visit 10 different venues',
    descriptionAr: 'قم بزيارة 10 أماكن مختلفة',
    category: BadgeCategory.explorer,
    tier: BadgeTier.silver,
    iconUrl: 'assets/badges/city_explorer.png',
    requiredProgress: 10,
    pointsReward: 100,
  );

  // Foodie Badges
  static const Badge tastemaker = Badge(
    id: 'badge_tastemaker',
    name: 'Tastemaker',
    nameAr: 'خبير المذاق',
    description: 'Try 5 different cuisines',
    descriptionAr: 'جرب 5 مطابخ مختلفة',
    category: BadgeCategory.foodie,
    tier: BadgeTier.bronze,
    iconUrl: 'assets/badges/tastemaker.png',
    requiredProgress: 5,
    pointsReward: 50,
  );

  // Social Badges
  static const Badge socialButterfly = Badge(
    id: 'badge_social_butterfly',
    name: 'Social Butterfly',
    nameAr: 'فراشة اجتماعية',
    description: 'Connect with 10 friends',
    descriptionAr: 'تواصل مع 10 أصدقاء',
    category: BadgeCategory.social,
    tier: BadgeTier.silver,
    iconUrl: 'assets/badges/social_butterfly.png',
    requiredProgress: 10,
    pointsReward: 100,
  );

  // Contributor Badges
  static const Badge reviewer = Badge(
    id: 'badge_reviewer',
    name: 'Reviewer',
    nameAr: 'مراجع',
    description: 'Write your first review',
    descriptionAr: 'اكتب أول مراجعة لك',
    category: BadgeCategory.contributor,
    tier: BadgeTier.bronze,
    iconUrl: 'assets/badges/reviewer.png',
    requiredProgress: 1,
    pointsReward: 50,
  );

  static const Badge topCritic = Badge(
    id: 'badge_top_critic',
    name: 'Top Critic',
    nameAr: 'ناقد متميز',
    description: 'Write 50 reviews',
    descriptionAr: 'اكتب 50 مراجعة',
    category: BadgeCategory.contributor,
    tier: BadgeTier.gold,
    iconUrl: 'assets/badges/top_critic.png',
    requiredProgress: 50,
    pointsReward: 200,
  );

  // Event Badges
  static const Badge ramadanSpecial = Badge(
    id: 'badge_ramadan_2025',
    name: 'Ramadan 2025',
    nameAr: 'رمضان 2025',
    description: 'Visit during Ramadan 2025',
    descriptionAr: 'قم بالزيارة خلال رمضان 2025',
    category: BadgeCategory.event,
    tier: BadgeTier.gold,
    iconUrl: 'assets/badges/ramadan_2025.png',
    requiredProgress: 1,
    pointsReward: 100,
  );

  /// Get all predefined badges
  static List<Badge> get all => [
        firstVenueVisit,
        cityExplorer,
        tastemaker,
        socialButterfly,
        reviewer,
        topCritic,
        ramadanSpecial,
      ];
}
