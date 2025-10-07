import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:yajid/models/gamification/points_model.dart';
import 'package:yajid/models/gamification/badge_model.dart';
import 'package:yajid/models/gamification/level_model.dart';
import 'package:yajid/services/logging_service.dart';

/// Service for managing gamification features (points, badges, levels)
class GamificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final LoggingService _logger = LoggingService();

  // Collection references
  static const String _userPointsCollection = 'user_points';
  static const String _pointsTransactionsCollection = 'points_transactions';
  static const String _userBadgesCollection = 'user_badges';
  static const String _userLevelsCollection = 'user_levels';
  static const String _dailyPointsLimitCollection = 'daily_points_limit';

  /// Initialize user gamification data
  Future<void> initializeUser(String userId) async {
    try {
      final batch = _firestore.batch();

      // Initialize user points
      final userPointsRef = _firestore.collection(_userPointsCollection).doc(userId);
      batch.set(userPointsRef, UserPoints.initial(userId).toFirestore());

      // Initialize user level
      final userLevelRef = _firestore.collection(_userLevelsCollection).doc(userId);
      batch.set(userLevelRef, UserLevel.initial(userId).toFirestore());

      // Initialize daily points limit
      final dailyLimitRef = _firestore
          .collection(_dailyPointsLimitCollection)
          .doc('${userId}_${_getTodayDateString()}');
      batch.set(dailyLimitRef, DailyPointsLimit(
        userId: userId,
        date: DateTime.now(),
        pointsEarnedToday: 0,
      ).toFirestore());

      await batch.commit();
      _logger.info('Initialized gamification for user: $userId');
    } catch (e) {
      _logger.error('Error initializing gamification for user $userId', e);
      rethrow;
    }
  }

  /// Award points to a user for an activity
  /// Uses Cloud Functions for secure server-side validation and processing
  /// [referenceId] is used for idempotency - provide a unique ID for each awardable action
  /// to prevent duplicate points awards (e.g., bookmarkId, ratingId, reviewId)
  Future<bool> awardPoints({
    required String userId,
    required int points,
    required PointsCategory category,
    String? description,
    String? referenceId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Call Cloud Function for secure points awarding
      // All validation, daily limits, and database updates happen server-side
      final callable = _functions.httpsCallable('awardPoints');

      final result = await callable.call<Map<String, dynamic>>({
        'points': points,
        'category': category.name,
        'description': description ?? 'Earned $points points for ${category.name}',
        'referenceId': referenceId,
        'metadata': metadata,
      });

      final data = result.data;
      final success = data['success'] as bool? ?? false;

      if (success) {
        _logger.info('Awarded $points points to user $userId for ${category.name}');
      } else {
        final reason = data['reason'] as String?;
        final message = data['message'] as String?;
        _logger.warning(
          'Failed to award points to user $userId: ${reason ?? message ?? 'Unknown error'}',
        );
      }

      return success;
    } on FirebaseFunctionsException catch (e) {
      _logger.error(
        'Cloud Function error awarding points to user $userId: ${e.code} - ${e.message}',
        e,
      );
      return false;
    } catch (e) {
      _logger.error('Error awarding points to user $userId', e);
      return false;
    }
  }

  /// Get user points
  Future<UserPoints?> getUserPoints(String userId) async {
    try {
      final doc = await _firestore.collection(_userPointsCollection).doc(userId).get();
      return doc.exists ? UserPoints.fromFirestore(doc) : null;
    } catch (e) {
      _logger.error('Error getting user points for $userId', e);
      return null;
    }
  }

  /// Get user level
  Future<UserLevel?> getUserLevel(String userId) async {
    try {
      final doc = await _firestore.collection(_userLevelsCollection).doc(userId).get();
      return doc.exists ? UserLevel.fromFirestore(doc) : null;
    } catch (e) {
      _logger.error('Error getting user level for $userId', e);
      return null;
    }
  }

  /// Get user badges
  Future<List<UserBadge>> getUserBadges(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_userBadgesCollection)
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs.map((doc) => UserBadge.fromFirestore(doc)).toList();
    } catch (e) {
      _logger.error('Error getting user badges for $userId', e);
      return [];
    }
  }

  /// Get points transaction history
  Future<List<PointsTransaction>> getPointsHistory(
    String userId, {
    int limit = 50,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(_pointsTransactionsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => PointsTransaction.fromFirestore(doc)).toList();
    } catch (e) {
      _logger.error('Error getting points history for $userId', e);
      return [];
    }
  }

  /// Get leaderboard using Cloud Function
  Future<List<LeaderboardEntry>> getLeaderboard({
    int limit = 100,
    int? startAfter,
  }) async {
    try {
      final callable = _functions.httpsCallable('getLeaderboard');
      final result = await callable.call<Map<String, dynamic>>({
        'limit': limit,
        if (startAfter != null) 'startAfter': startAfter,
      });

      final data = result.data;
      final success = data['success'] as bool? ?? false;

      if (success) {
        final leaderboardData = data['leaderboard'] as List<dynamic>? ?? [];
        return leaderboardData
            .map((entry) => LeaderboardEntry.fromMap(entry as Map<String, dynamic>))
            .toList();
      }

      return [];
    } on FirebaseFunctionsException catch (e) {
      _logger.error('Cloud Function error getting leaderboard: ${e.code} - ${e.message}', e);
      return [];
    } catch (e) {
      _logger.error('Error getting leaderboard', e);
      return [];
    }
  }

  /// Get weekly leaderboard (users with points earned in the last 7 days)
  Future<List<LeaderboardEntry>> getWeeklyLeaderboard({int limit = 100}) async {
    try {
      // TODO: Implement actual weekly points tracking when backend supports it
      final querySnapshot = await _firestore
          .collection('gamification')
          .orderBy('totalPoints', descending: true)
          .limit(limit)
          .get();

      final entries = <LeaderboardEntry>[];
      int rank = 1;

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final userName = data['userName'] as String? ?? 'Unknown';
        final totalPoints = data['totalPoints'] as int? ?? 0;
        final level = data['level'] as int? ?? 1;
        final tierString = data['tier'] as String? ?? 'novice';
        final tier = ExpertiseTier.values.firstWhere(
          (t) => t.name == tierString,
          orElse: () => ExpertiseTier.novice,
        );

        entries.add(LeaderboardEntry(
          userId: doc.id,
          userName: userName,
          totalPoints: totalPoints,
          level: level,
          tier: tier,
          rank: rank++,
        ));
      }

      return entries;
    } catch (e) {
      _logger.error('Error getting weekly leaderboard', e);
      return [];
    }
  }

  /// Get monthly leaderboard (users with points earned in the last 30 days)
  Future<List<LeaderboardEntry>> getMonthlyLeaderboard({int limit = 100}) async {
    try {
      // TODO: Implement actual monthly points tracking when backend supports it
      final querySnapshot = await _firestore
          .collection('gamification')
          .orderBy('totalPoints', descending: true)
          .limit(limit)
          .get();

      final entries = <LeaderboardEntry>[];
      int rank = 1;

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final userName = data['userName'] as String? ?? 'Unknown';
        final totalPoints = data['totalPoints'] as int? ?? 0;
        final level = data['level'] as int? ?? 1;
        final tierString = data['tier'] as String? ?? 'novice';
        final tier = ExpertiseTier.values.firstWhere(
          (t) => t.name == tierString,
          orElse: () => ExpertiseTier.novice,
        );

        entries.add(LeaderboardEntry(
          userId: doc.id,
          userName: userName,
          totalPoints: totalPoints,
          level: level,
          tier: tier,
          rank: rank++,
        ));
      }

      return entries;
    } catch (e) {
      _logger.error('Error getting monthly leaderboard', e);
      return [];
    }
  }

  /// Get friends leaderboard (requires friends list implementation)
  Future<List<LeaderboardEntry>> getFriendsLeaderboard({
    required String userId,
    int limit = 100,
  }) async {
    try {
      // First, get user's friends list from their profile
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final friendIds = (userDoc.data()?['friends'] as List<dynamic>?)
          ?.cast<String>() ?? [];

      if (friendIds.isEmpty) {
        return [];
      }

      // Get gamification data for all friends
      // Note: Firestore 'in' query limited to 10 items, so we batch if needed
      final batches = <List<String>>[];
      for (var i = 0; i < friendIds.length; i += 10) {
        batches.add(
          friendIds.sublist(
            i,
            i + 10 > friendIds.length ? friendIds.length : i + 10,
          ),
        );
      }

      final allFriendsData = <LeaderboardEntry>[];

      for (var batch in batches) {
        final querySnapshot = await _firestore
            .collection('gamification')
            .where(FieldPath.documentId, whereIn: batch)
            .get();

        for (var doc in querySnapshot.docs) {
          final data = doc.data();
          final userName = data['userName'] as String? ?? 'Unknown';
          final totalPoints = data['totalPoints'] as int? ?? 0;
          final level = data['level'] as int? ?? 1;
          final tierString = data['tier'] as String? ?? 'novice';
          final tier = ExpertiseTier.values.firstWhere(
            (t) => t.name == tierString,
            orElse: () => ExpertiseTier.novice,
          );

          allFriendsData.add(LeaderboardEntry(
            userId: doc.id,
            userName: userName,
            totalPoints: totalPoints,
            level: level,
            tier: tier,
            rank: 0, // Will be assigned after sorting
          ));
        }
      }

      // Sort by total points and assign ranks
      allFriendsData.sort((a, b) => b.totalPoints.compareTo(a.totalPoints));

      final rankedData = <LeaderboardEntry>[];
      for (var i = 0; i < allFriendsData.length && i < limit; i++) {
        rankedData.add(allFriendsData[i].copyWith(rank: i + 1));
      }

      return rankedData;
    } catch (e) {
      _logger.error('Error getting friends leaderboard', e);
      return [];
    }
  }

  /// Get user's rank on leaderboard using Cloud Function
  Future<int?> getUserRank(String userId) async {
    try {
      final callable = _functions.httpsCallable('getUserRank');
      final result = await callable.call<Map<String, dynamic>>({
        'userId': userId,
      });

      final data = result.data;
      final success = data['success'] as bool? ?? false;

      if (success) {
        return data['rank'] as int?;
      }

      return null;
    } on FirebaseFunctionsException catch (e) {
      _logger.error('Cloud Function error getting user rank: ${e.code} - ${e.message}', e);
      return null;
    } catch (e) {
      _logger.error('Error getting user rank for $userId', e);
      return null;
    }
  }

  /// Manually trigger badge unlock check using Cloud Function
  Future<List<String>> checkBadgeUnlocks(String userId) async {
    try {
      final callable = _functions.httpsCallable('checkBadgeUnlocks');
      final result = await callable.call<Map<String, dynamic>>({
        'userId': userId,
      });

      final data = result.data;
      final success = data['success'] as bool? ?? false;

      if (success) {
        final newBadges = data['newBadges'] as List<dynamic>? ?? [];
        return newBadges.map((badge) => badge.toString()).toList();
      }

      return [];
    } on FirebaseFunctionsException catch (e) {
      _logger.error('Cloud Function error checking badges: ${e.code} - ${e.message}', e);
      return [];
    } catch (e) {
      _logger.error('Error checking badge unlocks for $userId', e);
      return [];
    }
  }

  /// Helper to get today's date as string (YYYY-MM-DD)
  String _getTodayDateString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Get daily points remaining
  Future<int> getDailyPointsRemaining(String userId) async {
    try {
      final today = _getTodayDateString();
      final dailyLimitDoc = await _firestore
          .collection(_dailyPointsLimitCollection)
          .doc('${userId}_$today')
          .get();

      if (!dailyLimitDoc.exists) {
        return 500; // Default daily limit
      }

      final dailyLimit = DailyPointsLimit.fromFirestore(dailyLimitDoc);
      return dailyLimit.remainingPoints;
    } catch (e) {
      _logger.error('Error getting daily points remaining for $userId', e);
      return 0;
    }
  }
}
