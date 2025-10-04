import 'package:equatable/equatable.dart';
import '../../models/payment_model.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {
  const PaymentInitial();
}

class PaymentProcessing extends PaymentState {
  const PaymentProcessing();
}

class PaymentSuccess extends PaymentState {
  final PaymentModel payment;

  const PaymentSuccess(this.payment);

  @override
  List<Object?> get props => [payment];
}

class PaymentFailed extends PaymentState {
  final String message;

  const PaymentFailed(this.message);

  @override
  List<Object?> get props => [message];
}

class PaymentsLoaded extends PaymentState {
  final List<PaymentModel> payments;

  const PaymentsLoaded(this.payments);

  @override
  List<Object?> get props => [payments];
}

class PaymentDetailLoaded extends PaymentState {
  final PaymentModel payment;

  const PaymentDetailLoaded(this.payment);

  @override
  List<Object?> get props => [payment];
}

class RefundProcessed extends PaymentState {
  const RefundProcessed();
}

class TransactionsLoaded extends PaymentState {
  final List<TransactionModel> transactions;

  const TransactionsLoaded(this.transactions);

  @override
  List<Object?> get props => [transactions];
}

class PaymentError extends PaymentState {
  final String message;

  const PaymentError(this.message);

  @override
  List<Object?> get props => [message];
}
