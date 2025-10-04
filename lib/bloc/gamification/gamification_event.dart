import 'package:equatable/equatable.dart';
import 'package:yajid/models/gamification/points_model.dart';

/// Base class for gamification events
abstract class GamificationEvent extends Equatable {
  const GamificationEvent();

  @override
  List<Object?> get props => [];
}

/// Initialize gamification for a user
class InitializeGamification extends GamificationEvent {
  final String userId;

  const InitializeGamification(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Load user gamification data
class LoadGamificationData extends GamificationEvent {
  final String userId;

  const LoadGamificationData(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Award points to user
class AwardPoints extends GamificationEvent {
  final String userId;
  final int points;
  final PointsCategory category;
  final String? description;
  final String? referenceId;
  final Map<String, dynamic>? metadata;

  const AwardPoints({
    required this.userId,
    required this.points,
    required this.category,
    this.description,
    this.referenceId,
    this.metadata,
  });

  @override
  List<Object?> get props => [userId, points, category, description, referenceId, metadata];
}

/// Load points transaction history
class LoadPointsHistory extends GamificationEvent {
  final String userId;
  final int limit;

  const LoadPointsHistory(this.userId, {this.limit = 50});

  @override
  List<Object?> get props => [userId, limit];
}

/// Load user badges
class LoadUserBadges extends GamificationEvent {
  final String userId;

  const LoadUserBadges(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Load leaderboard
class LoadLeaderboard extends GamificationEvent {
  final int limit;

  const LoadLeaderboard({this.limit = 100});

  @override
  List<Object?> get props => [limit];
}

/// Refresh gamification data
class RefreshGamificationData extends GamificationEvent {
  final String userId;

  const RefreshGamificationData(this.userId);

  @override
  List<Object?> get props => [userId];
}
