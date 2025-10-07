import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// User level and expertise tier
class UserLevel extends Equatable {
  final String userId;
  final int level;
  final ExpertiseTier tier;
  final int totalPoints;
  final int pointsInCurrentLevel;
  final int pointsRequiredForNextLevel;
  final DateTime lastUpdated;

  const UserLevel({
    required this.userId,
    required this.level,
    required this.tier,
    required this.totalPoints,
    required this.pointsInCurrentLevel,
    required this.pointsRequiredForNextLevel,
    required this.lastUpdated,
  });

  double get progressToNextLevel {
    if (pointsRequiredForNextLevel == 0) return 1.0;
    return (pointsInCurrentLevel / pointsRequiredForNextLevel).clamp(0.0, 1.0);
  }

  int get pointsNeededForNextLevel {
    return pointsRequiredForNextLevel - pointsInCurrentLevel;
  }

  factory UserLevel.initial(String userId) {
    return UserLevel(
      userId: userId,
      level: 1,
      tier: ExpertiseTier.novice,
      totalPoints: 0,
      pointsInCurrentLevel: 0,
      pointsRequiredForNextLevel: 100,
      lastUpdated: DateTime.now(),
    );
  }

  factory UserLevel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserLevel(
      userId: doc.id,
      level: data['level'] ?? 1,
      tier: ExpertiseTier.values.firstWhere(
        (e) => e.name == data['tier'],
        orElse: () => ExpertiseTier.novice,
      ),
      totalPoints: data['totalPoints'] ?? 0,
      pointsInCurrentLevel: data['pointsInCurrentLevel'] ?? 0,
      pointsRequiredForNextLevel: data['pointsRequiredForNextLevel'] ?? 100,
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'level': level,
      'tier': tier.name,
      'totalPoints': totalPoints,
      'pointsInCurrentLevel': pointsInCurrentLevel,
      'pointsRequiredForNextLevel': pointsRequiredForNextLevel,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  UserLevel copyWith({
    String? userId,
    int? level,
    ExpertiseTier? tier,
    int? totalPoints,
    int? pointsInCurrentLevel,
    int? pointsRequiredForNextLevel,
    DateTime? lastUpdated,
  }) {
    return UserLevel(
      userId: userId ?? this.userId,
      level: level ?? this.level,
      tier: tier ?? this.tier,
      totalPoints: totalPoints ?? this.totalPoints,
      pointsInCurrentLevel: pointsInCurrentLevel ?? this.pointsInCurrentLevel,
      pointsRequiredForNextLevel:
          pointsRequiredForNextLevel ?? this.pointsRequiredForNextLevel,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        level,
        tier,
        totalPoints,
        pointsInCurrentLevel,
        pointsRequiredForNextLevel,
        lastUpdated,
      ];
}

/// Expertise tiers (from DSG-007 and WF-006)
/// Points thresholds define when user reaches each tier
enum ExpertiseTier {
  novice, // 0-99 points
  explorer, // 100-399 points
  adventurer, // 400-899 points
  expert, // 900-1599 points
  master, // 1600-2499 points
  legend, // 2500+ points
}

extension ExpertiseTierExtension on ExpertiseTier {
  String get displayName {
    switch (this) {
      case ExpertiseTier.novice:
        return 'Novice';
      case ExpertiseTier.explorer:
        return 'Explorer';
      case ExpertiseTier.adventurer:
        return 'Adventurer';
      case ExpertiseTier.expert:
        return 'Expert';
      case ExpertiseTier.master:
        return 'Master';
      case ExpertiseTier.legend:
        return 'Legend';
    }
  }

  String get displayNameAr {
    switch (this) {
      case ExpertiseTier.novice:
        return 'مبتدئ';
      case ExpertiseTier.explorer:
        return 'مستكشف';
      case ExpertiseTier.adventurer:
        return 'مغامر';
      case ExpertiseTier.expert:
        return 'خبير';
      case ExpertiseTier.master:
        return 'أستاذ';
      case ExpertiseTier.legend:
        return 'أسطورة';
    }
  }

  /// Points range for this tier (from WF-006)
  (int min, int max) get pointsRange {
    switch (this) {
      case ExpertiseTier.novice:
        return (0, 99);
      case ExpertiseTier.explorer:
        return (100, 399);
      case ExpertiseTier.adventurer:
        return (400, 899);
      case ExpertiseTier.expert:
        return (900, 1599);
      case ExpertiseTier.master:
        return (1600, 2499);
      case ExpertiseTier.legend:
        return (2500, 999999); // No upper limit for legend
    }
  }

  /// Color for UI display (from DSG-007)
  String get colorHex {
    switch (this) {
      case ExpertiseTier.novice:
        return '#9CA3AF'; // Gray
      case ExpertiseTier.explorer:
        return '#CD7F32'; // Bronze
      case ExpertiseTier.adventurer:
        return '#9CA3AF'; // Silver
      case ExpertiseTier.expert:
        return '#FFC107'; // Gold
      case ExpertiseTier.master:
        return '#E5E4E2'; // Platinum
      case ExpertiseTier.legend:
        return '#8B5CF6'; // Level Purple (Diamond)
    }
  }

  /// Icon name for this tier
  String get iconName {
    switch (this) {
      case ExpertiseTier.novice:
        return 'circle';
      case ExpertiseTier.explorer:
        return 'explore';
      case ExpertiseTier.adventurer:
        return 'landscape';
      case ExpertiseTier.expert:
        return 'military_tech';
      case ExpertiseTier.master:
        return 'workspace_premium';
      case ExpertiseTier.legend:
        return 'auto_awesome';
    }
  }

  /// Benefits at this tier
  List<String> get benefits {
    switch (this) {
      case ExpertiseTier.novice:
        return [
          'Basic access to platform',
          'Earn points for activities',
          'Unlock bronze badges',
        ];
      case ExpertiseTier.explorer:
        return [
          'All Novice benefits',
          '10% bonus points on reviews',
          'Unlock silver badges',
          'Access to weekly challenges',
        ];
      case ExpertiseTier.adventurer:
        return [
          'All Explorer benefits',
          '20% bonus points on reviews',
          'Unlock gold badges',
          'Priority booking for events',
          'Early access to new features',
        ];
      case ExpertiseTier.expert:
        return [
          'All Adventurer benefits',
          '30% bonus points on reviews',
          'Unlock platinum badges',
          'Exclusive event invitations',
          'Profile badge display',
        ];
      case ExpertiseTier.master:
        return [
          'All Expert benefits',
          '40% bonus points on reviews',
          'Unlock diamond badges',
          'VIP customer support',
          'Influence on platform features',
        ];
      case ExpertiseTier.legend:
        return [
          'All Master benefits',
          '50% bonus points on reviews',
          'Exclusive legend badge',
          'Beta tester status',
          'Personal concierge service',
          'Featured in app',
        ];
    }
  }

  /// Get tier from total points
  static ExpertiseTier fromPoints(int points) {
    if (points < 100) return ExpertiseTier.novice;
    if (points < 400) return ExpertiseTier.explorer;
    if (points < 900) return ExpertiseTier.adventurer;
    if (points < 1600) return ExpertiseTier.expert;
    if (points < 2500) return ExpertiseTier.master;
    return ExpertiseTier.legend;
  }

  /// Get next tier
  ExpertiseTier? get nextTier {
    switch (this) {
      case ExpertiseTier.novice:
        return ExpertiseTier.explorer;
      case ExpertiseTier.explorer:
        return ExpertiseTier.adventurer;
      case ExpertiseTier.adventurer:
        return ExpertiseTier.expert;
      case ExpertiseTier.expert:
        return ExpertiseTier.master;
      case ExpertiseTier.master:
        return ExpertiseTier.legend;
      case ExpertiseTier.legend:
        return null; // Already at max
    }
  }
}

/// Level up rewards
class LevelUpReward extends Equatable {
  final int level;
  final int bonusPoints;
  final List<String> unlockedFeatures;
  final String? specialBadgeId;

  const LevelUpReward({
    required this.level,
    required this.bonusPoints,
    this.unlockedFeatures = const [],
    this.specialBadgeId,
  });

  factory LevelUpReward.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LevelUpReward(
      level: data['level'],
      bonusPoints: data['bonusPoints'] ?? 100,
      unlockedFeatures: List<String>.from(data['unlockedFeatures'] ?? []),
      specialBadgeId: data['specialBadgeId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'level': level,
      'bonusPoints': bonusPoints,
      'unlockedFeatures': unlockedFeatures,
      'specialBadgeId': specialBadgeId,
    };
  }

  @override
  List<Object?> get props => [level, bonusPoints, unlockedFeatures, specialBadgeId];
}

/// Leaderboard entry
class LeaderboardEntry extends Equatable {
  final String userId;
  final String userName;
  final String? userAvatarUrl;
  final int totalPoints;
  final int level;
  final ExpertiseTier tier;
  final int rank;
  final int previousRank;

  const LeaderboardEntry({
    required this.userId,
    required this.userName,
    this.userAvatarUrl,
    required this.totalPoints,
    required this.level,
    required this.tier,
    required this.rank,
    this.previousRank = 0,
  });

  int get rankChange => previousRank - rank;

  bool get isRankImproved => rankChange > 0;

  factory LeaderboardEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LeaderboardEntry(
      userId: doc.id,
      userName: data['userName'] ?? data['displayName'] ?? 'Anonymous',
      userAvatarUrl: data['userAvatarUrl'] ?? data['profileImageUrl'],
      totalPoints: data['totalPoints'] ?? 0,
      level: data['level'] ?? 1,
      tier: ExpertiseTier.values.firstWhere(
        (e) => e.name == data['tier'],
        orElse: () => ExpertiseTier.novice,
      ),
      rank: data['rank'] ?? 0,
      previousRank: data['previousRank'] ?? 0,
    );
  }

  factory LeaderboardEntry.fromMap(Map<String, dynamic> data) {
    return LeaderboardEntry(
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? data['displayName'] ?? 'Anonymous',
      userAvatarUrl: data['userAvatarUrl'] ?? data['profileImageUrl'],
      totalPoints: data['totalPoints'] ?? 0,
      level: data['level'] ?? 1,
      tier: ExpertiseTier.values.firstWhere(
        (e) => e.name == data['tier'],
        orElse: () => ExpertiseTier.novice,
      ),
      rank: data['rank'] ?? 0,
      previousRank: data['previousRank'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userName': userName,
      'userAvatarUrl': userAvatarUrl,
      'totalPoints': totalPoints,
      'level': level,
      'tier': tier.name,
      'rank': rank,
      'previousRank': previousRank,
    };
  }

  LeaderboardEntry copyWith({
    String? userId,
    String? userName,
    String? userAvatarUrl,
    int? totalPoints,
    int? level,
    ExpertiseTier? tier,
    int? rank,
    int? previousRank,
  }) {
    return LeaderboardEntry(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      totalPoints: totalPoints ?? this.totalPoints,
      level: level ?? this.level,
      tier: tier ?? this.tier,
      rank: rank ?? this.rank,
      previousRank: previousRank ?? this.previousRank,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        userName,
        userAvatarUrl,
        totalPoints,
        level,
        tier,
        rank,
        previousRank,
      ];
}

/// Points calculation utility
class LevelCalculator {
  /// Calculate level from total points
  /// Uses exponential formula: points needed = 100 * (1.5 ^ (level - 1))
  static int calculateLevel(int totalPoints) {
    if (totalPoints < 100) return 1;

    int level = 1;
    int pointsForNextLevel = 100;
    int accumulatedPoints = 0;

    while (accumulatedPoints + pointsForNextLevel <= totalPoints) {
      accumulatedPoints += pointsForNextLevel;
      level++;
      pointsForNextLevel = (100 * _pow(1.5, level - 1)).round();
    }

    return level;
  }

  /// Calculate points required for a specific level
  static int pointsRequiredForLevel(int level) {
    if (level <= 1) return 0;

    int totalPoints = 0;
    for (int i = 1; i < level; i++) {
      totalPoints += (100 * _pow(1.5, i - 1)).round();
    }

    return totalPoints;
  }

  /// Calculate points required for next level from current level
  static int pointsForNextLevel(int currentLevel) {
    return (100 * _pow(1.5, currentLevel)).round();
  }

  /// Helper power function
  static double _pow(double base, int exponent) {
    double result = 1.0;
    for (int i = 0; i < exponent; i++) {
      result *= base;
    }
    return result;
  }
}
