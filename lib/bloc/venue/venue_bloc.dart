import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'venue_event.dart';
import 'venue_state.dart';
import '../../services/venue_service.dart';
import '../../models/venue_model.dart';
import 'dart:async';

class VenueBloc extends Bloc<VenueEvent, VenueState> {
  final VenueService _venueService;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription? _venuesSubscription;
  StreamSubscription? _reviewsSubscription;

  VenueBloc({VenueService? venueService})
      : _venueService = venueService ?? VenueService(),
        super(const VenueInitial()) {
    on<LoadVenues>(_onLoadVenues);
    on<LoadVenueById>(_onLoadVenueById);
    on<SearchVenues>(_onSearchVenues);
    on<LoadNearbyVenues>(_onLoadNearbyVenues);
    on<LoadVenuesByCategory>(_onLoadVenuesByCategory);
    on<LoadVenueReviews>(_onLoadVenueReviews);
    on<AddVenueReview>(_onAddVenueReview);
    on<CheckVenueAvailability>(_onCheckVenueAvailability);
    on<LoadVenueCategories>(_onLoadVenueCategories);
  }

  Future<void> _onLoadVenues(
    LoadVenues event,
    Emitter<VenueState> emit,
  ) async {
    emit(const VenueLoading());
    await _venuesSubscription?.cancel();

    _venuesSubscription = _venueService.getVenues().listen(
      (venues) {
        emit(VenuesLoaded(venues));
      },
      onError: (error) {
        emit(VenueError('Failed to load venues: $error'));
      },
    );
  }

  Future<void> _onLoadVenueById(
    LoadVenueById event,
    Emitter<VenueState> emit,
  ) async {
    emit(const VenueLoading());
    try {
      final venue = await _venueService.getVenueById(event.venueId);
      if (venue != null) {
        emit(VenueDetailLoaded(venue));
      } else {
        emit(const VenueError('Venue not found'));
      }
    } catch (e) {
      emit(VenueError('Failed to load venue: $e'));
    }
  }

  Future<void> _onSearchVenues(
    SearchVenues event,
    Emitter<VenueState> emit,
  ) async {
    emit(const VenueLoading());
    await _venuesSubscription?.cancel();

    _venuesSubscription = _venueService
        .searchVenues(
          searchQuery: event.searchQuery,
          category: event.category,
          minPrice: event.minPrice,
          maxPrice: event.maxPrice,
          minRating: event.minRating,
          minCapacity: event.minCapacity,
          amenities: event.amenities,
        )
        .listen(
      (venues) {
        emit(VenuesLoaded(venues));
      },
      onError: (error) {
        emit(VenueError('Failed to search venues: $error'));
      },
    );
  }

  Future<void> _onLoadNearbyVenues(
    LoadNearbyVenues event,
    Emitter<VenueState> emit,
  ) async {
    emit(const VenueLoading());
    try {
      final venues = await _venueService.getNearbyVenues(
        latitude: event.latitude,
        longitude: event.longitude,
        radiusInKm: event.radiusInKm,
      );
      emit(VenuesLoaded(venues));
    } catch (e) {
      emit(VenueError('Failed to load nearby venues: $e'));
    }
  }

  Future<void> _onLoadVenuesByCategory(
    LoadVenuesByCategory event,
    Emitter<VenueState> emit,
  ) async {
    emit(const VenueLoading());
    await _venuesSubscription?.cancel();

    _venuesSubscription = _venueService.getVenuesByCategory(event.category).listen(
      (venues) {
        emit(VenuesLoaded(venues));
      },
      onError: (error) {
        emit(VenueError('Failed to load venues by category: $error'));
      },
    );
  }

  Future<void> _onLoadVenueReviews(
    LoadVenueReviews event,
    Emitter<VenueState> emit,
  ) async {
    emit(const VenueLoading());
    await _reviewsSubscription?.cancel();

    _reviewsSubscription = _venueService.getVenueReviews(event.venueId).listen(
      (reviews) {
        emit(VenueReviewsLoaded(reviews));
      },
      onError: (error) {
        emit(VenueError('Failed to load reviews: $error'));
      },
    );
  }

  Future<void> _onAddVenueReview(
    AddVenueReview event,
    Emitter<VenueState> emit,
  ) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      emit(const VenueError('You must be logged in to add a review'));
      return;
    }

    emit(const VenueLoading());
    try {
      final review = VenueReviewModel(
        id: '',
        venueId: event.venueId,
        userId: currentUser.uid,
        userName: currentUser.displayName ?? 'Anonymous',
        userPhotoUrl: currentUser.photoURL,
        rating: event.rating,
        comment: event.comment,
        createdAt: DateTime.now(),
        photoUrls: event.photoUrls,
      );

      final success = await _venueService.addVenueReview(review);
      if (success) {
        emit(const VenueReviewAdded());
      } else {
        emit(const VenueError('Failed to add review'));
      }
    } catch (e) {
      emit(VenueError('Failed to add review: $e'));
    }
  }

  Future<void> _onCheckVenueAvailability(
    CheckVenueAvailability event,
    Emitter<VenueState> emit,
  ) async {
    emit(const VenueLoading());
    try {
      final isAvailable = await _venueService.checkAvailability(
        venueId: event.venueId,
        startTime: event.startTime,
        endTime: event.endTime,
      );

      emit(VenueAvailabilityChecked(
        isAvailable: isAvailable,
        message: isAvailable
            ? 'Venue is available for the selected time'
            : 'Venue is not available for the selected time',
      ));
    } catch (e) {
      emit(VenueError('Failed to check availability: $e'));
    }
  }

  Future<void> _onLoadVenueCategories(
    LoadVenueCategories event,
    Emitter<VenueState> emit,
  ) async {
    emit(const VenueLoading());
    try {
      final categories = await _venueService.getVenueCategories();
      emit(VenueCategoriesLoaded(categories));
    } catch (e) {
      emit(VenueError('Failed to load categories: $e'));
    }
  }

  @override
  Future<void> close() {
    _venuesSubscription?.cancel();
    _reviewsSubscription?.cancel();
    return super.close();
  }
}
