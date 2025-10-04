import 'package:equatable/equatable.dart';

abstract class VenueEvent extends Equatable {
  const VenueEvent();

  @override
  List<Object?> get props => [];
}

class LoadVenues extends VenueEvent {
  const LoadVenues();
}

class LoadVenueById extends VenueEvent {
  final String venueId;

  const LoadVenueById(this.venueId);

  @override
  List<Object?> get props => [venueId];
}

class SearchVenues extends VenueEvent {
  final String? searchQuery;
  final String? category;
  final double? minPrice;
  final double? maxPrice;
  final double? minRating;
  final int? minCapacity;
  final List<String>? amenities;

  const SearchVenues({
    this.searchQuery,
    this.category,
    this.minPrice,
    this.maxPrice,
    this.minRating,
    this.minCapacity,
    this.amenities,
  });

  @override
  List<Object?> get props => [
        searchQuery,
        category,
        minPrice,
        maxPrice,
        minRating,
        minCapacity,
        amenities,
      ];
}

class LoadNearbyVenues extends VenueEvent {
  final double latitude;
  final double longitude;
  final double radiusInKm;

  const LoadNearbyVenues({
    required this.latitude,
    required this.longitude,
    this.radiusInKm = 10.0,
  });

  @override
  List<Object?> get props => [latitude, longitude, radiusInKm];
}

class LoadVenuesByCategory extends VenueEvent {
  final String category;

  const LoadVenuesByCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class LoadVenueReviews extends VenueEvent {
  final String venueId;

  const LoadVenueReviews(this.venueId);

  @override
  List<Object?> get props => [venueId];
}

class AddVenueReview extends VenueEvent {
  final String venueId;
  final double rating;
  final String comment;
  final List<String>? photoUrls;

  const AddVenueReview({
    required this.venueId,
    required this.rating,
    required this.comment,
    this.photoUrls,
  });

  @override
  List<Object?> get props => [venueId, rating, comment, photoUrls];
}

class CheckVenueAvailability extends VenueEvent {
  final String venueId;
  final DateTime startTime;
  final DateTime endTime;

  const CheckVenueAvailability({
    required this.venueId,
    required this.startTime,
    required this.endTime,
  });

  @override
  List<Object?> get props => [venueId, startTime, endTime];
}

class LoadVenueCategories extends VenueEvent {
  const LoadVenueCategories();
}
