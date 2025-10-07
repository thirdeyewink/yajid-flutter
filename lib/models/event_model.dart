import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String id;
  final String userId;
  final String title;
  final String type;
  final String description;
  final String place;
  final DateTime date;
  final String time;
  final int durationMinutes;
  final List<String> participants;
  final String? videoLink;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPublic;
  final List<String> invitedUserIds;
  final String category;

  EventModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.type,
    required this.description,
    required this.place,
    required this.date,
    required this.time,
    required this.durationMinutes,
    required this.participants,
    this.videoLink,
    required this.createdAt,
    required this.updatedAt,
    required this.isPublic,
    required this.invitedUserIds,
    required this.category,
  });

  factory EventModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EventModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      type: data['type'] ?? '',
      description: data['description'] ?? '',
      place: data['place'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      time: data['time'] ?? '',
      durationMinutes: data['durationMinutes'] ?? 60,
      participants: List<String>.from(data['participants'] ?? []),
      videoLink: data['videoLink'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      isPublic: data['isPublic'] ?? false,
      invitedUserIds: List<String>.from(data['invitedUserIds'] ?? []),
      category: data['category'] ?? 'event',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'type': type,
      'description': description,
      'place': place,
      'date': Timestamp.fromDate(date),
      'time': time,
      'durationMinutes': durationMinutes,
      'participants': participants,
      'videoLink': videoLink,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isPublic': isPublic,
      'invitedUserIds': invitedUserIds,
      'category': category,
    };
  }

  EventModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? type,
    String? description,
    String? place,
    DateTime? date,
    String? time,
    int? durationMinutes,
    List<String>? participants,
    String? videoLink,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPublic,
    List<String>? invitedUserIds,
    String? category,
  }) {
    return EventModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      type: type ?? this.type,
      description: description ?? this.description,
      place: place ?? this.place,
      date: date ?? this.date,
      time: time ?? this.time,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      participants: participants ?? this.participants,
      videoLink: videoLink ?? this.videoLink,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPublic: isPublic ?? this.isPublic,
      invitedUserIds: invitedUserIds ?? this.invitedUserIds,
      category: category ?? this.category,
    );
  }

  DateTime get endTime {
    final timeParts = time.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = timeParts.length > 1 ? int.parse(timeParts[1].replaceAll(RegExp(r'[^0-9]'), '')) : 0;

    return DateTime(
      date.year,
      date.month,
      date.day,
      hour,
      minute,
    ).add(Duration(minutes: durationMinutes));
  }

  DateTime get startTime {
    final timeParts = time.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = timeParts.length > 1 ? int.parse(timeParts[1].replaceAll(RegExp(r'[^0-9]'), '')) : 0;

    return DateTime(
      date.year,
      date.month,
      date.day,
      hour,
      minute,
    );
  }

  bool get isPast {
    return endTime.isBefore(DateTime.now());
  }

  bool get isUpcoming {
    return startTime.isAfter(DateTime.now());
  }

  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(endTime);
  }
}
