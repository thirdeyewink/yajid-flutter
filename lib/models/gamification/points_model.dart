import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// User points balance and transaction history
class UserPoints extends Equatable {
  final String userId;
  final int totalPoints;
  final int lifetimePoints;
  final int currentLevel;
  final int pointsToNextLevel;
  final DateTime lastUpdated;
  final Map<String, int> pointsByCategory;

  const UserPoints({
    required this.userId,
    required this.totalPoints,
    required this.lifetimePoints,
    required this.currentLevel,
    required this.pointsToNextLevel,
    required this.lastUpdated,
    this.pointsByCategory = const {},
  });

  factory UserPoints.initial(String userId) {
    return UserPoints(
      userId: userId,
      totalPoints: 0,
      lifetimePoints: 0,
      currentLevel: 1,
      pointsToNextLevel: 100,
      lastUpdated: DateTime.now(),
      pointsByCategory: const {},
    );
  }

  factory UserPoints.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserPoints(
      userId: doc.id,
      totalPoints: data['totalPoints'] ?? 0,
      lifetimePoints: data['lifetimePoints'] ?? 0,
      currentLevel: data['currentLevel'] ?? 1,
      pointsToNextLevel: data['pointsToNextLevel'] ?? 100,
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
      pointsByCategory: Map<String, int>.from(data['pointsByCategory'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'totalPoints': totalPoints,
      'lifetimePoints': lifetimePoints,
      'currentLevel': currentLevel,
      'pointsToNextLevel': pointsToNextLevel,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'pointsByCategory': pointsByCategory,
    };
  }

  UserPoints copyWith({
    String? userId,
    int? totalPoints,
    int? lifetimePoints,
    int? currentLevel,
    int? pointsToNextLevel,
    DateTime? lastUpdated,
    Map<String, int>? pointsByCategory,
  }) {
    return UserPoints(
      userId: userId ?? this.userId,
      totalPoints: totalPoints ?? this.totalPoints,
      lifetimePoints: lifetimePoints ?? this.lifetimePoints,
      currentLevel: currentLevel ?? this.currentLevel,
      pointsToNextLevel: pointsToNextLevel ?? this.pointsToNextLevel,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      pointsByCategory: pointsByCategory ?? this.pointsByCategory,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        totalPoints,
        lifetimePoints,
        currentLevel,
        pointsToNextLevel,
        lastUpdated,
        pointsByCategory,
      ];
}

/// Points transaction record
class PointsTransaction extends Equatable {
  final String id;
  final String userId;
  final int points;
  final PointsTransactionType type;
  final String category;
  final String? description;
  final String? referenceId; // ID of related entity (venue, review, etc.)
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  const PointsTransaction({
    required this.id,
    required this.userId,
    required this.points,
    required this.type,
    required this.category,
    this.description,
    this.referenceId,
    required this.timestamp,
    this.metadata,
  });

  factory PointsTransaction.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PointsTransaction(
      id: doc.id,
      userId: data['userId'],
      points: data['points'],
      type: PointsTransactionType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => PointsTransactionType.other,
      ),
      category: data['category'],
      description: data['description'],
      referenceId: data['referenceId'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'points': points,
      'type': type.name,
      'category': category,
      'description': description,
      'referenceId': referenceId,
      'timestamp': Timestamp.fromDate(timestamp),
      'metadata': metadata,
    };
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        points,
        type,
        category,
        description,
        referenceId,
        timestamp,
        metadata,
      ];
}

/// Types of points transactions
enum PointsTransactionType {
  earned, // User earned points
  spent, // User spent points (e.g., auction bid)
  expired, // Points expired
  adjusted, // Manual adjustment by admin
  refunded, // Points refunded (e.g., cancelled booking)
  bonus, // Bonus points awarded
  penalty, // Penalty points deducted
  other,
}

/// Points earning categories (from PRD-001)
enum PointsCategory {
  venueVisit, // Check-in at venue: 10-50 points
  review, // Write review: 20-100 points
  photoUpload, // Upload photos: 10-30 points
  socialShare, // Share activity: 5-15 points
  friendReferral, // Refer friend: 200 points
  firstVisit, // First time at venue: 100 points bonus
  dailyLogin, // Daily login: 5-15 points
  weeklyChallenge, // Complete weekly challenge: 100-300 points
  eventAttendance, // Attend event: 50-200 points
  profileComplete, // Complete profile: 50 points
  socialConnection, // Connect with friends: 10 points
  helpfulReview, // Review marked helpful: 5 points
  achievementUnlock, // Unlock achievement: varies
  levelUp, // Level up bonus: 100 points
  other,
}

extension PointsCategoryExtension on PointsCategory {
  String get displayName {
    switch (this) {
      case PointsCategory.venueVisit:
        return 'Venue Visit';
      case PointsCategory.review:
        return 'Review';
      case PointsCategory.photoUpload:
        return 'Photo Upload';
      case PointsCategory.socialShare:
        return 'Social Share';
      case PointsCategory.friendReferral:
        return 'Friend Referral';
      case PointsCategory.firstVisit:
        return 'First Visit';
      case PointsCategory.dailyLogin:
        return 'Daily Login';
      case PointsCategory.weeklyChallenge:
        return 'Weekly Challenge';
      case PointsCategory.eventAttendance:
        return 'Event Attendance';
      case PointsCategory.profileComplete:
        return 'Profile Complete';
      case PointsCategory.socialConnection:
        return 'Social Connection';
      case PointsCategory.helpfulReview:
        return 'Helpful Review';
      case PointsCategory.achievementUnlock:
        return 'Achievement';
      case PointsCategory.levelUp:
        return 'Level Up';
      case PointsCategory.other:
        return 'Other';
    }
  }

  String get iconName {
    switch (this) {
      case PointsCategory.venueVisit:
        return 'location_on';
      case PointsCategory.review:
        return 'rate_review';
      case PointsCategory.photoUpload:
        return 'photo_camera';
      case PointsCategory.socialShare:
        return 'share';
      case PointsCategory.friendReferral:
        return 'person_add';
      case PointsCategory.firstVisit:
        return 'stars';
      case PointsCategory.dailyLogin:
        return 'calendar_today';
      case PointsCategory.weeklyChallenge:
        return 'emoji_events';
      case PointsCategory.eventAttendance:
        return 'event';
      case PointsCategory.profileComplete:
        return 'account_circle';
      case PointsCategory.socialConnection:
        return 'group';
      case PointsCategory.helpfulReview:
        return 'thumb_up';
      case PointsCategory.achievementUnlock:
        return 'military_tech';
      case PointsCategory.levelUp:
        return 'trending_up';
      case PointsCategory.other:
        return 'more_horiz';
    }
  }

  /// Get points range for this category
  (int min, int max) get pointsRange {
    switch (this) {
      case PointsCategory.venueVisit:
        return (10, 50);
      case PointsCategory.review:
        return (20, 100);
      case PointsCategory.photoUpload:
        return (10, 30);
      case PointsCategory.socialShare:
        return (5, 15);
      case PointsCategory.friendReferral:
        return (200, 200);
      case PointsCategory.firstVisit:
        return (100, 100);
      case PointsCategory.dailyLogin:
        return (5, 15);
      case PointsCategory.weeklyChallenge:
        return (100, 300);
      case PointsCategory.eventAttendance:
        return (50, 200);
      case PointsCategory.profileComplete:
        return (50, 50);
      case PointsCategory.socialConnection:
        return (10, 10);
      case PointsCategory.helpfulReview:
        return (5, 5);
      case PointsCategory.achievementUnlock:
        return (50, 500);
      case PointsCategory.levelUp:
        return (100, 100);
      case PointsCategory.other:
        return (0, 0);
    }
  }
}

/// Daily points limit tracker
class DailyPointsLimit {
  final String userId;
  final DateTime date;
  final int pointsEarnedToday;
  final int dailyLimit;

  const DailyPointsLimit({
    required this.userId,
    required this.date,
    required this.pointsEarnedToday,
    this.dailyLimit = 500, // From PRD-001
  });

  bool get hasReachedLimit => pointsEarnedToday >= dailyLimit;

  int get remainingPoints => dailyLimit - pointsEarnedToday;

  factory DailyPointsLimit.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DailyPointsLimit(
      userId: doc.id,
      date: (data['date'] as Timestamp).toDate(),
      pointsEarnedToday: data['pointsEarnedToday'] ?? 0,
      dailyLimit: data['dailyLimit'] ?? 500,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'date': Timestamp.fromDate(date),
      'pointsEarnedToday': pointsEarnedToday,
      'dailyLimit': dailyLimit,
    };
  }
}
