import 'package:cloud_firestore/cloud_firestore.dart';

enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  refunded,
  partiallyRefunded,
}

enum PaymentMethod {
  creditCard,
  debitCard,
  cmi, // CMI payment gateway for Moroccan cards
  stripe, // Stripe for international cards
  cash,
}

class PaymentModel {
  final String id;
  final String userId;
  final String bookingId;
  final double amount;
  final String currency;
  final PaymentMethod method;
  final PaymentStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? transactionId; // External payment gateway transaction ID
  final String? errorMessage;
  final Map<String, dynamic>? metadata;

  PaymentModel({
    required this.id,
    required this.userId,
    required this.bookingId,
    required this.amount,
    required this.currency,
    required this.method,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.transactionId,
    this.errorMessage,
    this.metadata,
  });

  factory PaymentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PaymentModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      bookingId: data['bookingId'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      currency: data['currency'] ?? 'MAD',
      method: _methodFromString(data['method'] ?? 'creditCard'),
      status: _statusFromString(data['status'] ?? 'pending'),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      transactionId: data['transactionId'],
      errorMessage: data['errorMessage'],
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'bookingId': bookingId,
      'amount': amount,
      'currency': currency,
      'method': _methodToString(method),
      'status': _statusToString(status),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      if (transactionId != null) 'transactionId': transactionId,
      if (errorMessage != null) 'errorMessage': errorMessage,
      if (metadata != null) 'metadata': metadata,
    };
  }

  static PaymentStatus _statusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return PaymentStatus.pending;
      case 'processing':
        return PaymentStatus.processing;
      case 'completed':
        return PaymentStatus.completed;
      case 'failed':
        return PaymentStatus.failed;
      case 'refunded':
        return PaymentStatus.refunded;
      case 'partiallyrefunded':
        return PaymentStatus.partiallyRefunded;
      default:
        return PaymentStatus.pending;
    }
  }

  static String _statusToString(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return 'pending';
      case PaymentStatus.processing:
        return 'processing';
      case PaymentStatus.completed:
        return 'completed';
      case PaymentStatus.failed:
        return 'failed';
      case PaymentStatus.refunded:
        return 'refunded';
      case PaymentStatus.partiallyRefunded:
        return 'partiallyrefunded';
    }
  }

  static PaymentMethod _methodFromString(String method) {
    switch (method.toLowerCase()) {
      case 'creditcard':
        return PaymentMethod.creditCard;
      case 'debitcard':
        return PaymentMethod.debitCard;
      case 'cmi':
        return PaymentMethod.cmi;
      case 'stripe':
        return PaymentMethod.stripe;
      case 'cash':
        return PaymentMethod.cash;
      default:
        return PaymentMethod.creditCard;
    }
  }

  static String _methodToString(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.creditCard:
        return 'creditcard';
      case PaymentMethod.debitCard:
        return 'debitcard';
      case PaymentMethod.cmi:
        return 'cmi';
      case PaymentMethod.stripe:
        return 'stripe';
      case PaymentMethod.cash:
        return 'cash';
    }
  }

  PaymentModel copyWith({
    String? id,
    String? userId,
    String? bookingId,
    double? amount,
    String? currency,
    PaymentMethod? method,
    PaymentStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? transactionId,
    String? errorMessage,
    Map<String, dynamic>? metadata,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      bookingId: bookingId ?? this.bookingId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      method: method ?? this.method,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      transactionId: transactionId ?? this.transactionId,
      errorMessage: errorMessage ?? this.errorMessage,
      metadata: metadata ?? this.metadata,
    );
  }
}

class TransactionModel {
  final String id;
  final String paymentId;
  final String userId;
  final double amount;
  final String currency;
  final String type; // 'payment', 'refund', 'chargeback'
  final DateTime timestamp;
  final String? description;
  final Map<String, dynamic>? details;

  TransactionModel({
    required this.id,
    required this.paymentId,
    required this.userId,
    required this.amount,
    required this.currency,
    required this.type,
    required this.timestamp,
    this.description,
    this.details,
  });

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      paymentId: data['paymentId'] ?? '',
      userId: data['userId'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      currency: data['currency'] ?? 'MAD',
      type: data['type'] ?? 'payment',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      description: data['description'],
      details: data['details'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'paymentId': paymentId,
      'userId': userId,
      'amount': amount,
      'currency': currency,
      'type': type,
      'timestamp': Timestamp.fromDate(timestamp),
      if (description != null) 'description': description,
      if (details != null) 'details': details,
    };
  }
}
