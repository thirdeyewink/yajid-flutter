import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/event_service.dart';
import 'event_event.dart';
import 'event_state.dart';

class EventBloc extends Bloc<EventEvent, EventState> {
  final EventService _eventService;
  StreamSubscription? _eventsSubscription;

  EventBloc(this._eventService) : super(const EventInitial()) {
    on<CreateEvent>(_onCreateEvent);
    on<LoadUserEvents>(_onLoadUserEvents);
    on<LoadUpcomingEvents>(_onLoadUpcomingEvents);
    on<LoadPastEvents>(_onLoadPastEvents);
    on<LoadEventsForDate>(_onLoadEventsForDate);
    on<LoadEventsForDateRange>(_onLoadEventsForDateRange);
    on<LoadEventById>(_onLoadEventById);
    on<UpdateEvent>(_onUpdateEvent);
    on<DeleteEvent>(_onDeleteEvent);
    on<AddParticipant>(_onAddParticipant);
    on<RemoveParticipant>(_onRemoveParticipant);
    on<LoadPublicEvents>(_onLoadPublicEvents);
    on<LoadInvitedEvents>(_onLoadInvitedEvents);
    on<InviteUser>(_onInviteUser);
  }

  Future<void> _onCreateEvent(CreateEvent event, Emitter<EventState> emit) async {
    emit(const EventLoading());
    try {
      final eventId = await _eventService.createEvent(event.event);
      emit(EventCreated(eventId));
    } catch (e) {
      emit(EventError(e.toString()));
    }
  }

  Future<void> _onLoadUserEvents(LoadUserEvents event, Emitter<EventState> emit) async {
    emit(const EventLoading());
    try {
      await _eventsSubscription?.cancel();
      _eventsSubscription = _eventService.getUserEvents(event.userId).listen(
        (events) {
          emit(EventsLoaded(events));
        },
        onError: (error) {
          emit(EventError(error.toString()));
        },
      );
    } catch (e) {
      emit(EventError(e.toString()));
    }
  }

  Future<void> _onLoadUpcomingEvents(LoadUpcomingEvents event, Emitter<EventState> emit) async {
    emit(const EventLoading());
    try {
      await _eventsSubscription?.cancel();
      _eventsSubscription = _eventService.getUpcomingEvents(event.userId).listen(
        (events) {
          emit(EventsLoaded(events));
        },
        onError: (error) {
          emit(EventError(error.toString()));
        },
      );
    } catch (e) {
      emit(EventError(e.toString()));
    }
  }

  Future<void> _onLoadPastEvents(LoadPastEvents event, Emitter<EventState> emit) async {
    emit(const EventLoading());
    try {
      await _eventsSubscription?.cancel();
      _eventsSubscription = _eventService.getPastEvents(event.userId).listen(
        (events) {
          emit(EventsLoaded(events));
        },
        onError: (error) {
          emit(EventError(error.toString()));
        },
      );
    } catch (e) {
      emit(EventError(e.toString()));
    }
  }

  Future<void> _onLoadEventsForDate(LoadEventsForDate event, Emitter<EventState> emit) async {
    emit(const EventLoading());
    try {
      await _eventsSubscription?.cancel();
      _eventsSubscription = _eventService.getEventsForDate(event.userId, event.date).listen(
        (events) {
          emit(EventsLoaded(events));
        },
        onError: (error) {
          emit(EventError(error.toString()));
        },
      );
    } catch (e) {
      emit(EventError(e.toString()));
    }
  }

  Future<void> _onLoadEventsForDateRange(LoadEventsForDateRange event, Emitter<EventState> emit) async {
    emit(const EventLoading());
    try {
      await _eventsSubscription?.cancel();
      _eventsSubscription = _eventService.getEventsForDateRange(event.userId, event.startDate, event.endDate).listen(
        (events) {
          emit(EventsLoaded(events));
        },
        onError: (error) {
          emit(EventError(error.toString()));
        },
      );
    } catch (e) {
      emit(EventError(e.toString()));
    }
  }

  Future<void> _onLoadEventById(LoadEventById event, Emitter<EventState> emit) async {
    emit(const EventLoading());
    try {
      final eventData = await _eventService.getEventById(event.eventId);
      if (eventData != null) {
        emit(EventDetailLoaded(eventData));
      } else {
        emit(const EventError('Event not found'));
      }
    } catch (e) {
      emit(EventError(e.toString()));
    }
  }

  Future<void> _onUpdateEvent(UpdateEvent event, Emitter<EventState> emit) async {
    emit(const EventLoading());
    try {
      await _eventService.updateEvent(event.eventId, event.updates);
      emit(const EventUpdated());
    } catch (e) {
      emit(EventError(e.toString()));
    }
  }

  Future<void> _onDeleteEvent(DeleteEvent event, Emitter<EventState> emit) async {
    emit(const EventLoading());
    try {
      await _eventService.deleteEvent(event.eventId);
      emit(const EventDeleted());
    } catch (e) {
      emit(EventError(e.toString()));
    }
  }

  Future<void> _onAddParticipant(AddParticipant event, Emitter<EventState> emit) async {
    emit(const EventLoading());
    try {
      await _eventService.addParticipant(event.eventId, event.participantName);
      emit(const EventUpdated());
    } catch (e) {
      emit(EventError(e.toString()));
    }
  }

  Future<void> _onRemoveParticipant(RemoveParticipant event, Emitter<EventState> emit) async {
    emit(const EventLoading());
    try {
      await _eventService.removeParticipant(event.eventId, event.participantName);
      emit(const EventUpdated());
    } catch (e) {
      emit(EventError(e.toString()));
    }
  }

  Future<void> _onLoadPublicEvents(LoadPublicEvents event, Emitter<EventState> emit) async {
    emit(const EventLoading());
    try {
      await _eventsSubscription?.cancel();
      _eventsSubscription = _eventService.getPublicEvents().listen(
        (events) {
          emit(EventsLoaded(events));
        },
        onError: (error) {
          emit(EventError(error.toString()));
        },
      );
    } catch (e) {
      emit(EventError(e.toString()));
    }
  }

  Future<void> _onLoadInvitedEvents(LoadInvitedEvents event, Emitter<EventState> emit) async {
    emit(const EventLoading());
    try {
      await _eventsSubscription?.cancel();
      _eventsSubscription = _eventService.getInvitedEvents(event.userId).listen(
        (events) {
          emit(EventsLoaded(events));
        },
        onError: (error) {
          emit(EventError(error.toString()));
        },
      );
    } catch (e) {
      emit(EventError(e.toString()));
    }
  }

  Future<void> _onInviteUser(InviteUser event, Emitter<EventState> emit) async {
    emit(const EventLoading());
    try {
      await _eventService.inviteUser(event.eventId, event.userId);
      emit(const EventUpdated());
    } catch (e) {
      emit(EventError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _eventsSubscription?.cancel();
    return super.close();
  }
}
