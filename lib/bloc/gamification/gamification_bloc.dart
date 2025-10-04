import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yajid/bloc/gamification/gamification_event.dart';
import 'package:yajid/bloc/gamification/gamification_state.dart';
import 'package:yajid/services/gamification_service.dart';
import 'package:yajid/models/gamification/points_model.dart';
import 'package:yajid/models/gamification/level_model.dart';

/// BLoC for managing gamification state
class GamificationBloc extends Bloc<GamificationEvent, GamificationState> {
  final GamificationService _gamificationService;

  GamificationBloc({
    GamificationService? gamificationService,
  })  : _gamificationService = gamificationService ?? GamificationService(),
        super(GamificationInitial()) {
    on<InitializeGamification>(_onInitializeGamification);
    on<LoadGamificationData>(_onLoadGamificationData);
    on<AwardPoints>(_onAwardPoints);
    on<LoadPointsHistory>(_onLoadPointsHistory);
    on<LoadUserBadges>(_onLoadUserBadges);
    on<LoadLeaderboard>(_onLoadLeaderboard);
    on<RefreshGamificationData>(_onRefreshGamificationData);
  }

  /// Initialize gamification for a new user
  Future<void> _onInitializeGamification(
    InitializeGamification event,
    Emitter<GamificationState> emit,
  ) async {
    try {
      emit(GamificationLoading());
      await _gamificationService.initializeUser(event.userId);

      // Load data after initialization
      add(LoadGamificationData(event.userId));
    } catch (e) {
      emit(GamificationError('Failed to initialize gamification', e));
    }
  }

  /// Load all gamification data for a user
  Future<void> _onLoadGamificationData(
    LoadGamificationData event,
    Emitter<GamificationState> emit,
  ) async {
    try {
      emit(GamificationLoading());

      // Load all gamification data in parallel
      final results = await Future.wait([
        _gamificationService.getUserPoints(event.userId),
        _gamificationService.getUserLevel(event.userId),
        _gamificationService.getUserBadges(event.userId),
        _gamificationService.getPointsHistory(event.userId, limit: 20),
        _gamificationService.getDailyPointsRemaining(event.userId),
      ]);

      final userPoints = results[0] as UserPoints?;
      final userLevel = results[1] as UserLevel?;
      final userBadges = results[2] as List;
      final pointsHistory = results[3] as List;
      final dailyPointsRemaining = results[4] as int;

      if (userPoints == null || userLevel == null) {
        // Initialize if data doesn't exist
        add(InitializeGamification(event.userId));
        return;
      }

      emit(GamificationLoaded(
        userPoints: userPoints,
        userLevel: userLevel,
        userBadges: userBadges.cast(),
        pointsHistory: pointsHistory.cast(),
        dailyPointsRemaining: dailyPointsRemaining,
      ));
    } catch (e) {
      emit(GamificationError('Failed to load gamification data', e));
    }
  }

  /// Award points to a user
  Future<void> _onAwardPoints(
    AwardPoints event,
    Emitter<GamificationState> emit,
  ) async {
    try {
      final success = await _gamificationService.awardPoints(
        userId: event.userId,
        points: event.points,
        category: event.category,
        description: event.description,
        referenceId: event.referenceId,
        metadata: event.metadata,
      );

      if (success) {
        // Reload gamification data to get updated values
        add(LoadGamificationData(event.userId));
      } else {
        emit(const PointsAwardFailed('Daily points limit reached or invalid points amount'));
      }
    } catch (e) {
      emit(GamificationError('Failed to award points', e));
    }
  }

  /// Load points transaction history
  Future<void> _onLoadPointsHistory(
    LoadPointsHistory event,
    Emitter<GamificationState> emit,
  ) async {
    try {
      if (state is! GamificationLoaded) return;

      final currentState = state as GamificationLoaded;
      final pointsHistory = await _gamificationService.getPointsHistory(
        event.userId,
        limit: event.limit,
      );

      emit(currentState.copyWith(pointsHistory: pointsHistory));
    } catch (e) {
      emit(GamificationError('Failed to load points history', e));
    }
  }

  /// Load user badges
  Future<void> _onLoadUserBadges(
    LoadUserBadges event,
    Emitter<GamificationState> emit,
  ) async {
    try {
      if (state is! GamificationLoaded) return;

      final currentState = state as GamificationLoaded;
      final userBadges = await _gamificationService.getUserBadges(event.userId);

      emit(currentState.copyWith(userBadges: userBadges));
    } catch (e) {
      emit(GamificationError('Failed to load user badges', e));
    }
  }

  /// Load leaderboard
  Future<void> _onLoadLeaderboard(
    LoadLeaderboard event,
    Emitter<GamificationState> emit,
  ) async {
    try {
      final leaderboard = await _gamificationService.getLeaderboard(
        limit: event.limit,
      );

      emit(LeaderboardLoaded(leaderboard));
    } catch (e) {
      emit(GamificationError('Failed to load leaderboard', e));
    }
  }

  /// Refresh gamification data
  Future<void> _onRefreshGamificationData(
    RefreshGamificationData event,
    Emitter<GamificationState> emit,
  ) async {
    try {
      // Don't emit loading state for refresh to avoid UI flicker
      final results = await Future.wait([
        _gamificationService.getUserPoints(event.userId),
        _gamificationService.getUserLevel(event.userId),
        _gamificationService.getUserBadges(event.userId),
        _gamificationService.getPointsHistory(event.userId, limit: 20),
        _gamificationService.getDailyPointsRemaining(event.userId),
      ]);

      final userPoints = results[0] as UserPoints?;
      final userLevel = results[1] as UserLevel?;
      final userBadges = results[2] as List;
      final pointsHistory = results[3] as List;
      final dailyPointsRemaining = results[4] as int;

      if (userPoints != null && userLevel != null) {
        emit(GamificationLoaded(
          userPoints: userPoints,
          userLevel: userLevel,
          userBadges: userBadges.cast(),
          pointsHistory: pointsHistory.cast(),
          dailyPointsRemaining: dailyPointsRemaining,
        ));
      }
    } catch (e) {
      emit(GamificationError('Failed to refresh gamification data', e));
    }
  }
}
