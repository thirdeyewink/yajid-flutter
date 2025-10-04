import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yajid/models/recommendation_model.dart';
import 'package:yajid/services/logging_service.dart';

/// Service for managing recommendations from Firestore
class RecommendationService {
  final FirebaseFirestore _firestore;
  final LoggingService _logger;
  final String _collectionName = 'recommendations';

  RecommendationService({
    FirebaseFirestore? firestore,
    LoggingService? logger,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _logger = logger ?? LoggingService();

  /// Get all recommendations with optional pagination
  /// [limit] - Maximum number of recommendations to fetch (default: 50)
  /// For better performance, use pagination instead of fetching all at once
  Future<List<Recommendation>> getAllRecommendations({int limit = 50}) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .orderBy('communityRating', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => Recommendation.fromFirestore(doc))
          .toList();
    } catch (e) {
      _logger.error('Error fetching all recommendations', e);
      return [];
    }
  }

  /// Get recommendations by category
  Future<List<Recommendation>> getRecommendationsByCategory(
    String category, {
    int limit = 20,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('category', isEqualTo: category)
          .orderBy('communityRating', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => Recommendation.fromFirestore(doc))
          .toList();
    } catch (e) {
      _logger.error('Error fetching recommendations for category: $category', e);
      return [];
    }
  }

  /// Get random recommendations (one from each category)
  /// Optimized to fetch all categories in parallel for better performance
  Future<List<Recommendation>> getRandomRecommendations() async {
    try {
      final categories = [
        'movies',
        'music',
        'books',
        'tv shows',
        'podcasts',
        'sports',
        'videogames',
        'brands',
        'recipes',
        'events',
        'activities',
        'businesses',
      ];

      // Fetch all categories in parallel (much faster than sequential)
      final futures = categories.map((category) =>
        getRecommendationsByCategory(category, limit: 10)
      ).toList();

      final results = await Future.wait(futures);
      final randomRecs = <Recommendation>[];
      final random = Random();

      // Pick one random recommendation from each category
      for (final categoryRecs in results) {
        if (categoryRecs.isNotEmpty) {
          final randomRec = categoryRecs[random.nextInt(categoryRecs.length)];
          randomRecs.add(randomRec);
        }
      }

      // Shuffle the final list
      randomRecs.shuffle();
      return randomRecs;
    } catch (e) {
      _logger.error('Error fetching random recommendations', e);
      return [];
    }
  }

  /// Get recommendations with pagination
  Future<List<Recommendation>> getRecommendationsPaginated({
    int limit = 10,
    DocumentSnapshot? startAfter,
    String? category,
  }) async {
    try {
      Query query = _firestore
          .collection(_collectionName)
          .orderBy('communityRating', descending: true);

      if (category != null && category != 'all') {
        query = query.where('category', isEqualTo: category);
      }

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      query = query.limit(limit);

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => Recommendation.fromFirestore(doc))
          .toList();
    } catch (e) {
      _logger.error('Error fetching paginated recommendations', e);
      return [];
    }
  }

  /// Stream recommendations (real-time updates)
  Stream<List<Recommendation>> streamRecommendations({
    String? category,
    int limit = 20,
  }) {
    try {
      Query query = _firestore
          .collection(_collectionName)
          .orderBy('communityRating', descending: true)
          .limit(limit);

      if (category != null && category != 'all') {
        query = query.where('category', isEqualTo: category);
      }

      return query.snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) => Recommendation.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      _logger.error('Error streaming recommendations', e);
      return Stream.value([]);
    }
  }

  /// Add a new recommendation
  Future<bool> addRecommendation(Recommendation recommendation) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(recommendation.id)
          .set(recommendation.toFirestore());

      _logger.info('Recommendation added: ${recommendation.title}');
      return true;
    } catch (e) {
      _logger.error('Error adding recommendation: ${recommendation.title}', e);
      return false;
    }
  }

  /// Update recommendation
  Future<bool> updateRecommendation(Recommendation recommendation) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(recommendation.id)
          .update(recommendation.toFirestore());

      _logger.info('Recommendation updated: ${recommendation.title}');
      return true;
    } catch (e) {
      _logger.error('Error updating recommendation: ${recommendation.title}', e);
      return false;
    }
  }

  /// Delete recommendation
  Future<bool> deleteRecommendation(String recommendationId) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(recommendationId)
          .delete();

      _logger.info('Recommendation deleted: $recommendationId');
      return true;
    } catch (e) {
      _logger.error('Error deleting recommendation: $recommendationId', e);
      return false;
    }
  }

  /// Update community rating
  Future<bool> updateCommunityRating(
    String recommendationId,
    double newRating,
  ) async {
    try {
      final docRef = _firestore.collection(_collectionName).doc(recommendationId);
      final doc = await docRef.get();

      if (!doc.exists) {
        _logger.error('Recommendation not found: $recommendationId', null);
        return false;
      }

      final data = doc.data()!;
      final currentRating = (data['communityRating'] ?? 0.0).toDouble();
      final currentCount = data['ratingCount'] ?? 0;

      // Calculate new average rating
      final totalRating = currentRating * currentCount + newRating;
      final newCount = currentCount + 1;
      final newAverage = totalRating / newCount;

      await docRef.update({
        'communityRating': newAverage,
        'ratingCount': newCount,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _logger.info('Community rating updated for: $recommendationId');
      return true;
    } catch (e) {
      _logger.error('Error updating community rating: recommendationId=$recommendationId', e);
      return false;
    }
  }

  /// Search recommendations by title
  Future<List<Recommendation>> searchRecommendations(String query) async {
    try {
      // Firestore doesn't support full-text search natively
      // This is a simple implementation - for production, use Algolia or ElasticSearch
      final snapshot = await _firestore
          .collection(_collectionName)
          .orderBy('title')
          .startAt([query])
          .endAt(['$query\uf8ff'])
          .limit(20)
          .get();

      return snapshot.docs
          .map((doc) => Recommendation.fromFirestore(doc))
          .toList();
    } catch (e) {
      _logger.error('Error searching recommendations: $query', e);
      return [];
    }
  }

  /// Get recommendation count by category
  Future<Map<String, int>> getRecommendationCountsByCategory() async {
    try {
      final Map<String, int> counts = {};
      final categories = [
        'movies',
        'music',
        'books',
        'tv shows',
        'podcasts',
        'sports',
        'videogames',
        'brands',
        'recipes',
        'events',
        'activities',
        'businesses',
      ];

      for (final category in categories) {
        final snapshot = await _firestore
            .collection(_collectionName)
            .where('category', isEqualTo: category)
            .count()
            .get();
        counts[category] = snapshot.count ?? 0;
      }

      return counts;
    } catch (e) {
      _logger.error('Error getting recommendation counts', e);
      return {};
    }
  }
}
