import 'package:flutter_bloc/flutter_bloc.dart';
import 'payment_event.dart';
import 'payment_state.dart';
import '../../services/payment_service.dart';
import 'dart:async';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final PaymentService _paymentService;
  StreamSubscription? _paymentsSubscription;
  StreamSubscription? _transactionsSubscription;

  PaymentBloc({PaymentService? paymentService})
      : _paymentService = paymentService ?? PaymentService(),
        super(const PaymentInitial()) {
    on<ProcessCMIPayment>(_onProcessCMIPayment);
    on<ProcessStripePayment>(_onProcessStripePayment);
    on<LoadUserPayments>(_onLoadUserPayments);
    on<LoadPaymentById>(_onLoadPaymentById);
    on<ProcessRefund>(_onProcessRefund);
    on<LoadUserTransactions>(_onLoadUserTransactions);
  }

  Future<void> _onProcessCMIPayment(
    ProcessCMIPayment event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentProcessing());
    try {
      final payment = await _paymentService.processCMIPayment(
        userId: event.userId,
        bookingId: event.bookingId,
        amount: event.amount,
        currency: event.currency,
        cardDetails: event.cardDetails,
      );

      if (payment != null) {
        emit(PaymentSuccess(payment));
      } else {
        emit(const PaymentFailed('Payment processing failed'));
      }
    } catch (e) {
      emit(PaymentFailed('Error processing payment: $e'));
    }
  }

  Future<void> _onProcessStripePayment(
    ProcessStripePayment event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentProcessing());
    try {
      final payment = await _paymentService.processStripePayment(
        userId: event.userId,
        bookingId: event.bookingId,
        amount: event.amount,
        currency: event.currency,
        paymentMethodData: event.paymentMethodData,
      );

      if (payment != null) {
        emit(PaymentSuccess(payment));
      } else {
        emit(const PaymentFailed('Payment processing failed'));
      }
    } catch (e) {
      emit(PaymentFailed('Error processing payment: $e'));
    }
  }

  Future<void> _onLoadUserPayments(
    LoadUserPayments event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentProcessing());
    await _paymentsSubscription?.cancel();

    _paymentsSubscription = _paymentService.getUserPayments(event.userId).listen(
      (payments) {
        emit(PaymentsLoaded(payments));
      },
      onError: (error) {
        emit(PaymentError('Failed to load payments: $error'));
      },
    );
  }

  Future<void> _onLoadPaymentById(
    LoadPaymentById event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentProcessing());
    try {
      final payment = await _paymentService.getPaymentById(event.paymentId);
      if (payment != null) {
        emit(PaymentDetailLoaded(payment));
      } else {
        emit(const PaymentError('Payment not found'));
      }
    } catch (e) {
      emit(PaymentError('Failed to load payment: $e'));
    }
  }

  Future<void> _onProcessRefund(
    ProcessRefund event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentProcessing());
    try {
      final success = await _paymentService.processRefund(
        paymentId: event.paymentId,
        amount: event.amount,
        reason: event.reason,
      );

      if (success) {
        emit(const RefundProcessed());
      } else {
        emit(const PaymentError('Refund processing failed'));
      }
    } catch (e) {
      emit(PaymentError('Failed to process refund: $e'));
    }
  }

  Future<void> _onLoadUserTransactions(
    LoadUserTransactions event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentProcessing());
    await _transactionsSubscription?.cancel();

    _transactionsSubscription = _paymentService.getUserTransactions(event.userId).listen(
      (transactions) {
        emit(TransactionsLoaded(transactions));
      },
      onError: (error) {
        emit(PaymentError('Failed to load transactions: $error'));
      },
    );
  }

  @override
  Future<void> close() {
    _paymentsSubscription?.cancel();
    _transactionsSubscription?.cancel();
    return super.close();
  }
}
