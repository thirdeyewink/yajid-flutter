import 'package:equatable/equatable.dart';
import '../../models/venue_model.dart';

abstract class VenueState extends Equatable {
  const VenueState();

  @override
  List<Object?> get props => [];
}

class VenueInitial extends VenueState {
  const VenueInitial();
}

class VenueLoading extends VenueState {
  const VenueLoading();
}

class VenuesLoaded extends VenueState {
  final List<VenueModel> venues;

  const VenuesLoaded(this.venues);

  @override
  List<Object?> get props => [venues];
}

class VenueDetailLoaded extends VenueState {
  final VenueModel venue;

  const VenueDetailLoaded(this.venue);

  @override
  List<Object?> get props => [venue];
}

class VenueReviewsLoaded extends VenueState {
  final List<VenueReviewModel> reviews;

  const VenueReviewsLoaded(this.reviews);

  @override
  List<Object?> get props => [reviews];
}

class VenueAvailabilityChecked extends VenueState {
  final bool isAvailable;
  final String message;

  const VenueAvailabilityChecked({
    required this.isAvailable,
    required this.message,
  });

  @override
  List<Object?> get props => [isAvailable, message];
}

class VenueCategoriesLoaded extends VenueState {
  final List<String> categories;

  const VenueCategoriesLoaded(this.categories);

  @override
  List<Object?> get props => [categories];
}

class VenueError extends VenueState {
  final String message;

  const VenueError(this.message);

  @override
  List<Object?> get props => [message];
}

class VenueReviewAdded extends VenueState {
  const VenueReviewAdded();
}
