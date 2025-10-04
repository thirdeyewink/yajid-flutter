import 'package:equatable/equatable.dart';
import 'package:yajid/models/gamification/points_model.dart';
import 'package:yajid/models/gamification/badge_model.dart';
import 'package:yajid/models/gamification/level_model.dart';

/// Base class for gamification states
abstract class GamificationState extends Equatable {
  const GamificationState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class GamificationInitial extends GamificationState {}

/// Loading state
class GamificationLoading extends GamificationState {}

/// Data loaded successfully
class GamificationLoaded extends GamificationState {
  final UserPoints userPoints;
  final UserLevel userLevel;
  final List<UserBadge> userBadges;
  final List<PointsTransaction> pointsHistory;
  final int dailyPointsRemaining;

  const GamificationLoaded({
    required this.userPoints,
    required this.userLevel,
    required this.userBadges,
    this.pointsHistory = const [],
    this.dailyPointsRemaining = 500,
  });

  GamificationLoaded copyWith({
    UserPoints? userPoints,
    UserLevel? userLevel,
    List<UserBadge>? userBadges,
    List<PointsTransaction>? pointsHistory,
    int? dailyPointsRemaining,
  }) {
    return GamificationLoaded(
      userPoints: userPoints ?? this.userPoints,
      userLevel: userLevel ?? this.userLevel,
      userBadges: userBadges ?? this.userBadges,
      pointsHistory: pointsHistory ?? this.pointsHistory,
      dailyPointsRemaining: dailyPointsRemaining ?? this.dailyPointsRemaining,
    );
  }

  @override
  List<Object?> get props => [
        userPoints,
        userLevel,
        userBadges,
        pointsHistory,
        dailyPointsRemaining,
      ];
}

/// Points awarded successfully
class PointsAwarded extends GamificationState {
  final int pointsAwarded;
  final String category;
  final UserPoints updatedUserPoints;

  const PointsAwarded({
    required this.pointsAwarded,
    required this.category,
    required this.updatedUserPoints,
  });

  @override
  List<Object?> get props => [pointsAwarded, category, updatedUserPoints];
}

/// Points award failed (daily limit reached or invalid)
class PointsAwardFailed extends GamificationState {
  final String reason;

  const PointsAwardFailed(this.reason);

  @override
  List<Object?> get props => [reason];
}

/// Leaderboard loaded
class LeaderboardLoaded extends GamificationState {
  final List<LeaderboardEntry> leaderboard;

  const LeaderboardLoaded(this.leaderboard);

  @override
  List<Object?> get props => [leaderboard];
}

/// Error state
class GamificationError extends GamificationState {
  final String message;
  final dynamic error;

  const GamificationError(this.message, [this.error]);

  @override
  List<Object?> get props => [message, error];
}

/// Badge unlocked state
class BadgeUnlocked extends GamificationState {
  final String badgeId;
  final String badgeName;
  final int pointsAwarded;

  const BadgeUnlocked({
    required this.badgeId,
    required this.badgeName,
    required this.pointsAwarded,
  });

  @override
  List<Object?> get props => [badgeId, badgeName, pointsAwarded];
}

/// Level up state
class LeveledUp extends GamificationState {
  final int newLevel;
  final ExpertiseTier newTier;
  final int bonusPoints;

  const LeveledUp({
    required this.newLevel,
    required this.newTier,
    required this.bonusPoints,
  });

  @override
  List<Object?> get props => [newLevel, newTier, bonusPoints];
}
