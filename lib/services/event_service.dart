import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Create a new event
  Future<String> createEvent(EventModel event) async {
    try {
      final docRef = await _firestore.collection('events').add(event.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create event: $e');
    }
  }

  /// Get event by ID
  Future<EventModel?> getEventById(String eventId) async {
    try {
      final doc = await _firestore.collection('events').doc(eventId).get();
      if (doc.exists) {
        return EventModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get event: $e');
    }
  }

  /// Get all events for a user
  Stream<List<EventModel>> getUserEvents(String userId) {
    return _firestore
        .collection('events')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => EventModel.fromFirestore(doc)).toList());
  }

  /// Get upcoming events for a user
  Stream<List<EventModel>> getUpcomingEvents(String userId) {
    final now = DateTime.now();
    return _firestore
        .collection('events')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => EventModel.fromFirestore(doc)).toList());
  }

  /// Get past events for a user
  Stream<List<EventModel>> getPastEvents(String userId) {
    final now = DateTime.now();
    return _firestore
        .collection('events')
        .where('userId', isEqualTo: userId)
        .where('date', isLessThan: Timestamp.fromDate(now))
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => EventModel.fromFirestore(doc)).toList());
  }

  /// Get events for a specific date
  Stream<List<EventModel>> getEventsForDate(String userId, DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return _firestore
        .collection('events')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => EventModel.fromFirestore(doc)).toList());
  }

  /// Get events for a specific date range
  Stream<List<EventModel>> getEventsForDateRange(String userId, DateTime startDate, DateTime endDate) {
    return _firestore
        .collection('events')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => EventModel.fromFirestore(doc)).toList());
  }

  /// Update an event
  Future<void> updateEvent(String eventId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = Timestamp.fromDate(DateTime.now());
      await _firestore.collection('events').doc(eventId).update(updates);
    } catch (e) {
      throw Exception('Failed to update event: $e');
    }
  }

  /// Delete an event
  Future<void> deleteEvent(String eventId) async {
    try {
      await _firestore.collection('events').doc(eventId).delete();
    } catch (e) {
      throw Exception('Failed to delete event: $e');
    }
  }

  /// Get public events
  Stream<List<EventModel>> getPublicEvents() {
    return _firestore
        .collection('events')
        .where('isPublic', isEqualTo: true)
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => EventModel.fromFirestore(doc)).toList());
  }

  /// Get events user is invited to
  Stream<List<EventModel>> getInvitedEvents(String userId) {
    return _firestore
        .collection('events')
        .where('invitedUserIds', arrayContains: userId)
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => EventModel.fromFirestore(doc)).toList());
  }

  /// Add participant to event
  Future<void> addParticipant(String eventId, String participantName) async {
    try {
      await _firestore.collection('events').doc(eventId).update({
        'participants': FieldValue.arrayUnion([participantName]),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to add participant: $e');
    }
  }

  /// Remove participant from event
  Future<void> removeParticipant(String eventId, String participantName) async {
    try {
      await _firestore.collection('events').doc(eventId).update({
        'participants': FieldValue.arrayRemove([participantName]),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to remove participant: $e');
    }
  }

  /// Invite user to event
  Future<void> inviteUser(String eventId, String userId) async {
    try {
      await _firestore.collection('events').doc(eventId).update({
        'invitedUserIds': FieldValue.arrayUnion([userId]),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to invite user: $e');
    }
  }
}
