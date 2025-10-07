import 'package:equatable/equatable.dart';
import '../../models/event_model.dart';

abstract class EventEvent extends Equatable {
  const EventEvent();

  @override
  List<Object?> get props => [];
}

class CreateEvent extends EventEvent {
  final EventModel event;

  const CreateEvent(this.event);

  @override
  List<Object?> get props => [event];
}

class LoadUserEvents extends EventEvent {
  final String userId;

  const LoadUserEvents(this.userId);

  @override
  List<Object?> get props => [userId];
}

class LoadUpcomingEvents extends EventEvent {
  final String userId;

  const LoadUpcomingEvents(this.userId);

  @override
  List<Object?> get props => [userId];
}

class LoadPastEvents extends EventEvent {
  final String userId;

  const LoadPastEvents(this.userId);

  @override
  List<Object?> get props => [userId];
}

class LoadEventsForDate extends EventEvent {
  final String userId;
  final DateTime date;

  const LoadEventsForDate(this.userId, this.date);

  @override
  List<Object?> get props => [userId, date];
}

class LoadEventsForDateRange extends EventEvent {
  final String userId;
  final DateTime startDate;
  final DateTime endDate;

  const LoadEventsForDateRange(this.userId, this.startDate, this.endDate);

  @override
  List<Object?> get props => [userId, startDate, endDate];
}

class LoadEventById extends EventEvent {
  final String eventId;

  const LoadEventById(this.eventId);

  @override
  List<Object?> get props => [eventId];
}

class UpdateEvent extends EventEvent {
  final String eventId;
  final Map<String, dynamic> updates;

  const UpdateEvent(this.eventId, this.updates);

  @override
  List<Object?> get props => [eventId, updates];
}

class DeleteEvent extends EventEvent {
  final String eventId;

  const DeleteEvent(this.eventId);

  @override
  List<Object?> get props => [eventId];
}

class AddParticipant extends EventEvent {
  final String eventId;
  final String participantName;

  const AddParticipant(this.eventId, this.participantName);

  @override
  List<Object?> get props => [eventId, participantName];
}

class RemoveParticipant extends EventEvent {
  final String eventId;
  final String participantName;

  const RemoveParticipant(this.eventId, this.participantName);

  @override
  List<Object?> get props => [eventId, participantName];
}

class LoadPublicEvents extends EventEvent {
  const LoadPublicEvents();
}

class LoadInvitedEvents extends EventEvent {
  final String userId;

  const LoadInvitedEvents(this.userId);

  @override
  List<Object?> get props => [userId];
}

class InviteUser extends EventEvent {
  final String eventId;
  final String userId;

  const InviteUser(this.eventId, this.userId);

  @override
  List<Object?> get props => [eventId, userId];
}
