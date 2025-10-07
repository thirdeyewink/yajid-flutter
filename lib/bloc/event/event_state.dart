import 'package:equatable/equatable.dart';
import '../../models/event_model.dart';

abstract class EventState extends Equatable {
  const EventState();

  @override
  List<Object?> get props => [];
}

class EventInitial extends EventState {
  const EventInitial();
}

class EventLoading extends EventState {
  const EventLoading();
}

class EventsLoaded extends EventState {
  final List<EventModel> events;

  const EventsLoaded(this.events);

  @override
  List<Object?> get props => [events];
}

class EventDetailLoaded extends EventState {
  final EventModel event;

  const EventDetailLoaded(this.event);

  @override
  List<Object?> get props => [event];
}

class EventCreated extends EventState {
  final String eventId;

  const EventCreated(this.eventId);

  @override
  List<Object?> get props => [eventId];
}

class EventUpdated extends EventState {
  const EventUpdated();
}

class EventDeleted extends EventState {
  const EventDeleted();
}

class EventError extends EventState {
  final String message;

  const EventError(this.message);

  @override
  List<Object?> get props => [message];
}
