import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import '../models/venue_model.dart';
import 'dart:math' show cos, sqrt, asin;

class VenueService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger();

  static const String _venuesCollection = 'venues';
  static const String _reviewsCollection = 'venue_reviews';

  /// Get all active venues
  Stream<List<VenueModel>> getVenues() {
    try {
      return _firestore
          .collection(_venuesCollection)
          .where('isActive', isEqualTo: true)
          .orderBy('rating', descending: true)
          .snapshots()
          .map((snapshot) =>
              snapshot.docs.map((doc) => VenueModel.fromFirestore(doc)).toList());
    } catch (e) {
      _logger.e('Error getting venues: $e');
      return Stream.value([]);
    }
  }

  /// Get a single venue by ID
  Future<VenueModel?> getVenueById(String venueId) async {
    try {
      final doc = await _firestore.collection(_venuesCollection).doc(venueId).get();
      if (doc.exists) {
        return VenueModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      _logger.e('Error getting venue by ID: $e');
      return null;
    }
  }

  /// Search venues with filters
  Stream<List<VenueModel>> searchVenues({
    String? searchQuery,
    String? category,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    int? minCapacity,
    List<String>? amenities,
  }) {
    try {
      Query query = _firestore
          .collection(_venuesCollection)
          .where('isActive', isEqualTo: true);

      // Category filter
      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }

      // Rating filter
      if (minRating != null) {
        query = query.where('rating', isGreaterThanOrEqualTo: minRating);
      }

      // Price range filter
      if (minPrice != null) {
        query = query.where('pricePerHour', isGreaterThanOrEqualTo: minPrice);
      }
      if (maxPrice != null) {
        query = query.where('pricePerHour', isLessThanOrEqualTo: maxPrice);
      }

      // Capacity filter
      if (minCapacity != null) {
        query = query.where('capacity', isGreaterThanOrEqualTo: minCapacity);
      }

      // Amenities filter
      if (amenities != null && amenities.isNotEmpty) {
        query = query.where('amenities', arrayContainsAny: amenities);
      }

      return query.snapshots().map((snapshot) {
        List<VenueModel> venues =
            snapshot.docs.map((doc) => VenueModel.fromFirestore(doc)).toList();

        // Text search filter (client-side)
        if (searchQuery != null && searchQuery.isNotEmpty) {
          final lowerQuery = searchQuery.toLowerCase();
          venues = venues.where((venue) {
            return venue.name.toLowerCase().contains(lowerQuery) ||
                venue.description.toLowerCase().contains(lowerQuery) ||
                venue.address.toLowerCase().contains(lowerQuery);
          }).toList();
        }

        return venues;
      });
    } catch (e) {
      _logger.e('Error searching venues: $e');
      return Stream.value([]);
    }
  }

  /// Get venues by category
  Stream<List<VenueModel>> getVenuesByCategory(String category) {
    try {
      return _firestore
          .collection(_venuesCollection)
          .where('isActive', isEqualTo: true)
          .where('category', isEqualTo: category)
          .orderBy('rating', descending: true)
          .snapshots()
          .map((snapshot) =>
              snapshot.docs.map((doc) => VenueModel.fromFirestore(doc)).toList());
    } catch (e) {
      _logger.e('Error getting venues by category: $e');
      return Stream.value([]);
    }
  }

  /// Get nearby venues based on coordinates
  Future<List<VenueModel>> getNearbyVenues({
    required double latitude,
    required double longitude,
    double radiusInKm = 10.0,
  }) async {
    try {
      // Fetch all active venues
      final snapshot = await _firestore
          .collection(_venuesCollection)
          .where('isActive', isEqualTo: true)
          .get();

      final venues =
          snapshot.docs.map((doc) => VenueModel.fromFirestore(doc)).toList();

      // Filter by distance
      final nearbyVenues = venues.where((venue) {
        final distance = _calculateDistance(
          latitude,
          longitude,
          venue.latitude,
          venue.longitude,
        );
        return distance <= radiusInKm;
      }).toList();

      // Sort by distance
      nearbyVenues.sort((a, b) {
        final distanceA = _calculateDistance(latitude, longitude, a.latitude, a.longitude);
        final distanceB = _calculateDistance(latitude, longitude, b.latitude, b.longitude);
        return distanceA.compareTo(distanceB);
      });

      return nearbyVenues;
    } catch (e) {
      _logger.e('Error getting nearby venues: $e');
      return [];
    }
  }

  /// Calculate distance between two coordinates (Haversine formula)
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const p = 0.017453292519943295; // Math.PI / 180
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }

  /// Create a new venue
  Future<String?> createVenue(VenueModel venue) async {
    try {
      final docRef = await _firestore
          .collection(_venuesCollection)
          .add(venue.toFirestore());
      _logger.i('Venue created with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      _logger.e('Error creating venue: $e');
      return null;
    }
  }

  /// Update an existing venue
  Future<bool> updateVenue(String venueId, VenueModel venue) async {
    try {
      await _firestore
          .collection(_venuesCollection)
          .doc(venueId)
          .update(venue.toFirestore());
      _logger.i('Venue updated: $venueId');
      return true;
    } catch (e) {
      _logger.e('Error updating venue: $e');
      return false;
    }
  }

  /// Delete a venue (soft delete - mark as inactive)
  Future<bool> deleteVenue(String venueId) async {
    try {
      await _firestore
          .collection(_venuesCollection)
          .doc(venueId)
          .update({'isActive': false, 'updatedAt': FieldValue.serverTimestamp()});
      _logger.i('Venue deleted: $venueId');
      return true;
    } catch (e) {
      _logger.e('Error deleting venue: $e');
      return false;
    }
  }

  /// Get reviews for a venue
  Stream<List<VenueReviewModel>> getVenueReviews(String venueId) {
    try {
      return _firestore
          .collection(_reviewsCollection)
          .where('venueId', isEqualTo: venueId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => VenueReviewModel.fromFirestore(doc))
              .toList());
    } catch (e) {
      _logger.e('Error getting venue reviews: $e');
      return Stream.value([]);
    }
  }

  /// Add a review for a venue
  Future<bool> addVenueReview(VenueReviewModel review) async {
    try {
      // Add the review
      await _firestore
          .collection(_reviewsCollection)
          .add(review.toFirestore());

      // Update venue rating
      await _updateVenueRating(review.venueId);

      _logger.i('Review added for venue: ${review.venueId}');
      return true;
    } catch (e) {
      _logger.e('Error adding venue review: $e');
      return false;
    }
  }

  /// Update venue rating based on all reviews
  Future<void> _updateVenueRating(String venueId) async {
    try {
      final reviewsSnapshot = await _firestore
          .collection(_reviewsCollection)
          .where('venueId', isEqualTo: venueId)
          .get();

      if (reviewsSnapshot.docs.isEmpty) {
        return;
      }

      final reviews = reviewsSnapshot.docs
          .map((doc) => VenueReviewModel.fromFirestore(doc))
          .toList();

      final totalRating = reviews.fold<double>(
        0.0,
        (total, review) => total + review.rating,
      );
      final averageRating = totalRating / reviews.length;

      await _firestore.collection(_venuesCollection).doc(venueId).update({
        'rating': averageRating,
        'reviewCount': reviews.length,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _logger.i('Updated rating for venue $venueId: $averageRating (${reviews.length} reviews)');
    } catch (e) {
      _logger.e('Error updating venue rating: $e');
    }
  }

  /// Check venue availability for a specific date and time
  Future<bool> checkAvailability({
    required String venueId,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      // Get the venue
      final venue = await getVenueById(venueId);
      if (venue == null || !venue.isActive) {
        return false;
      }

      // Check day of week availability
      final dayOfWeek = _getDayOfWeekString(startTime.weekday);
      if (venue.availability[dayOfWeek] == false) {
        return false;
      }

      // Check for existing bookings (will be implemented with booking service)
      // For now, return true if the day is available
      return true;
    } catch (e) {
      _logger.e('Error checking venue availability: $e');
      return false;
    }
  }

  /// Convert weekday number to string
  String _getDayOfWeekString(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'monday';
      case DateTime.tuesday:
        return 'tuesday';
      case DateTime.wednesday:
        return 'wednesday';
      case DateTime.thursday:
        return 'thursday';
      case DateTime.friday:
        return 'friday';
      case DateTime.saturday:
        return 'saturday';
      case DateTime.sunday:
        return 'sunday';
      default:
        return 'monday';
    }
  }

  /// Get venue categories
  Future<List<String>> getVenueCategories() async {
    try {
      final snapshot = await _firestore
          .collection(_venuesCollection)
          .where('isActive', isEqualTo: true)
          .get();

      final categories = snapshot.docs
          .map((doc) => (doc.data()['category'] as String?) ?? '')
          .where((category) => category.isNotEmpty)
          .toSet()
          .toList();

      categories.sort();
      return categories;
    } catch (e) {
      _logger.e('Error getting venue categories: $e');
      return [];
    }
  }
}
