import 'package:cloud_firestore/cloud_firestore.dart';

enum BookingStatus {
  pending,
  confirmed,
  cancelled,
  completed,
  noShow,
}

class BookingModel {
  final String id;
  final String userId;
  final String venueId;
  final String venueName;
  final DateTime startTime;
  final DateTime endTime;
  final int numberOfPeople;
  final double totalPrice;
  final String currency;
  final BookingStatus status;
  final String? specialRequests;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? paymentId;
  final String? cancellationReason;
  final DateTime? cancelledAt;

  BookingModel({
    required this.id,
    required this.userId,
    required this.venueId,
    required this.venueName,
    required this.startTime,
    required this.endTime,
    required this.numberOfPeople,
    required this.totalPrice,
    required this.currency,
    required this.status,
    this.specialRequests,
    required this.createdAt,
    required this.updatedAt,
    this.paymentId,
    this.cancellationReason,
    this.cancelledAt,
  });

  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookingModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      venueId: data['venueId'] ?? '',
      venueName: data['venueName'] ?? '',
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      numberOfPeople: data['numberOfPeople'] ?? 0,
      totalPrice: (data['totalPrice'] ?? 0.0).toDouble(),
      currency: data['currency'] ?? 'MAD',
      status: _statusFromString(data['status'] ?? 'pending'),
      specialRequests: data['specialRequests'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      paymentId: data['paymentId'],
      cancellationReason: data['cancellationReason'],
      cancelledAt: (data['cancelledAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'venueId': venueId,
      'venueName': venueName,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'numberOfPeople': numberOfPeople,
      'totalPrice': totalPrice,
      'currency': currency,
      'status': _statusToString(status),
      if (specialRequests != null) 'specialRequests': specialRequests,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      if (paymentId != null) 'paymentId': paymentId,
      if (cancellationReason != null) 'cancellationReason': cancellationReason,
      if (cancelledAt != null) 'cancelledAt': Timestamp.fromDate(cancelledAt!),
    };
  }

  static BookingStatus _statusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return BookingStatus.pending;
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'cancelled':
        return BookingStatus.cancelled;
      case 'completed':
        return BookingStatus.completed;
      case 'noshow':
        return BookingStatus.noShow;
      default:
        return BookingStatus.pending;
    }
  }

  static String _statusToString(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return 'pending';
      case BookingStatus.confirmed:
        return 'confirmed';
      case BookingStatus.cancelled:
        return 'cancelled';
      case BookingStatus.completed:
        return 'completed';
      case BookingStatus.noShow:
        return 'noshow';
    }
  }

  BookingModel copyWith({
    String? id,
    String? userId,
    String? venueId,
    String? venueName,
    DateTime? startTime,
    DateTime? endTime,
    int? numberOfPeople,
    double? totalPrice,
    String? currency,
    BookingStatus? status,
    String? specialRequests,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? paymentId,
    String? cancellationReason,
    DateTime? cancelledAt,
  }) {
    return BookingModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      venueId: venueId ?? this.venueId,
      venueName: venueName ?? this.venueName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      numberOfPeople: numberOfPeople ?? this.numberOfPeople,
      totalPrice: totalPrice ?? this.totalPrice,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      specialRequests: specialRequests ?? this.specialRequests,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      paymentId: paymentId ?? this.paymentId,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      cancelledAt: cancelledAt ?? this.cancelledAt,
    );
  }

  /// Calculate duration in hours
  double get durationInHours {
    return endTime.difference(startTime).inMinutes / 60.0;
  }

  /// Check if booking is in the past
  bool get isPast {
    return endTime.isBefore(DateTime.now());
  }

  /// Check if booking is upcoming
  bool get isUpcoming {
    return startTime.isAfter(DateTime.now()) && status == BookingStatus.confirmed;
  }

  /// Check if booking is active (currently happening)
  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(endTime) && status == BookingStatus.confirmed;
  }

  /// Check if booking can be cancelled
  bool get canBeCancelled {
    return status == BookingStatus.pending || status == BookingStatus.confirmed;
  }
}
