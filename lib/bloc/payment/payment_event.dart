import 'package:equatable/equatable.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

class ProcessCMIPayment extends PaymentEvent {
  final String userId;
  final String bookingId;
  final double amount;
  final String currency;
  final Map<String, dynamic> cardDetails;

  const ProcessCMIPayment({
    required this.userId,
    required this.bookingId,
    required this.amount,
    required this.currency,
    required this.cardDetails,
  });

  @override
  List<Object?> get props => [userId, bookingId, amount, currency, cardDetails];
}

class ProcessStripePayment extends PaymentEvent {
  final String userId;
  final String bookingId;
  final double amount;
  final String currency;
  final Map<String, dynamic> paymentMethodData;

  const ProcessStripePayment({
    required this.userId,
    required this.bookingId,
    required this.amount,
    required this.currency,
    required this.paymentMethodData,
  });

  @override
  List<Object?> get props => [userId, bookingId, amount, currency, paymentMethodData];
}

class LoadUserPayments extends PaymentEvent {
  final String userId;

  const LoadUserPayments(this.userId);

  @override
  List<Object?> get props => [userId];
}

class LoadPaymentById extends PaymentEvent {
  final String paymentId;

  const LoadPaymentById(this.paymentId);

  @override
  List<Object?> get props => [paymentId];
}

class ProcessRefund extends PaymentEvent {
  final String paymentId;
  final double amount;
  final String reason;

  const ProcessRefund({
    required this.paymentId,
    required this.amount,
    required this.reason,
  });

  @override
  List<Object?> get props => [paymentId, amount, reason];
}

class LoadUserTransactions extends PaymentEvent {
  final String userId;

  const LoadUserTransactions(this.userId);

  @override
  List<Object?> get props => [userId];
}
