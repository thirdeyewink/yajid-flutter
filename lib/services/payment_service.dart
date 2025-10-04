import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import '../models/payment_model.dart';

/// Payment service for handling payments via CMI (Moroccan cards) and Stripe (international cards)
///
/// NOTE: This is a stub implementation. Full integration requires:
/// - CMI payment gateway SDK and credentials
/// - Stripe Flutter SDK (flutter_stripe package)
/// - PCI DSS compliance certification
/// - Secure backend server for payment processing
class PaymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger();

  static const String _paymentsCollection = 'payments';
  static const String _transactionsCollection = 'transactions';

  // TODO: Add CMI and Stripe API keys to environment variables
  // These should NEVER be hardcoded or committed to version control
  // ignore: unused_field
  String? _cmiMerchantId;
  // ignore: unused_field
  String? _cmiApiKey;
  // ignore: unused_field
  String? _stripePublishableKey;
  // ignore: unused_field
  String? _stripeSecretKey;

  /// Initialize payment service with credentials
  void initialize({
    String? cmiMerchantId,
    String? cmiApiKey,
    String? stripePublishableKey,
    String? stripeSecretKey,
  }) {
    _cmiMerchantId = cmiMerchantId;
    _cmiApiKey = cmiApiKey;
    _stripePublishableKey = stripePublishableKey;
    _stripeSecretKey = stripeSecretKey;
    _logger.i('Payment service initialized');
  }

  /// Create a payment record
  Future<String?> createPayment(PaymentModel payment) async {
    try {
      final docRef = await _firestore
          .collection(_paymentsCollection)
          .add(payment.toFirestore());

      _logger.i('Payment record created: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      _logger.e('Error creating payment: $e');
      return null;
    }
  }

  /// Process payment via CMI (Moroccan payment gateway)
  ///
  /// NOTE: This is a stub. Actual implementation requires:
  /// 1. CMI payment gateway SDK integration
  /// 2. Secure backend server to handle payment requests
  /// 3. PCI DSS compliance
  Future<PaymentModel?> processCMIPayment({
    required String userId,
    required String bookingId,
    required double amount,
    required String currency,
    required Map<String, dynamic> cardDetails,
  }) async {
    try {
      _logger.i('Processing CMI payment for booking: $bookingId');

      // TODO: Implement actual CMI integration
      // This would involve:
      // 1. Validating card details
      // 2. Creating payment request to CMI gateway
      // 3. Handling 3D Secure authentication
      // 4. Processing response

      // Stub implementation - simulate payment
      await Future.delayed(const Duration(seconds: 2));

      final payment = PaymentModel(
        id: '',
        userId: userId,
        bookingId: bookingId,
        amount: amount,
        currency: currency,
        method: PaymentMethod.cmi,
        status: PaymentStatus.completed,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        transactionId: 'CMI_${DateTime.now().millisecondsSinceEpoch}',
        metadata: {'gateway': 'cmi', 'test_mode': true},
      );

      final paymentId = await createPayment(payment);
      if (paymentId != null) {
        await _recordTransaction(
          paymentId: paymentId,
          userId: userId,
          amount: amount,
          currency: currency,
          type: 'payment',
          description: 'CMI payment for booking $bookingId',
        );
        return payment.copyWith(id: paymentId);
      }

      return null;
    } catch (e) {
      _logger.e('Error processing CMI payment: $e');
      return null;
    }
  }

  /// Process payment via Stripe (International cards)
  ///
  /// NOTE: This is a stub. Actual implementation requires:
  /// 1. flutter_stripe package
  /// 2. Stripe account and API keys
  /// 3. Backend server for payment intent creation
  /// 4. PCI DSS compliance
  Future<PaymentModel?> processStripePayment({
    required String userId,
    required String bookingId,
    required double amount,
    required String currency,
    required Map<String, dynamic> paymentMethodData,
  }) async {
    try {
      _logger.i('Processing Stripe payment for booking: $bookingId');

      // TODO: Implement actual Stripe integration
      // This would involve:
      // 1. Creating PaymentIntent on backend
      // 2. Confirming payment with Stripe SDK
      // 3. Handling SCA (Strong Customer Authentication)
      // 4. Processing webhook events

      // Stub implementation - simulate payment
      await Future.delayed(const Duration(seconds: 2));

      final payment = PaymentModel(
        id: '',
        userId: userId,
        bookingId: bookingId,
        amount: amount,
        currency: currency,
        method: PaymentMethod.stripe,
        status: PaymentStatus.completed,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        transactionId: 'pi_${DateTime.now().millisecondsSinceEpoch}',
        metadata: {'gateway': 'stripe', 'test_mode': true},
      );

      final paymentId = await createPayment(payment);
      if (paymentId != null) {
        await _recordTransaction(
          paymentId: paymentId,
          userId: userId,
          amount: amount,
          currency: currency,
          type: 'payment',
          description: 'Stripe payment for booking $bookingId',
        );
        return payment.copyWith(id: paymentId);
      }

      return null;
    } catch (e) {
      _logger.e('Error processing Stripe payment: $e');
      return null;
    }
  }

  /// Get payment by ID
  Future<PaymentModel?> getPaymentById(String paymentId) async {
    try {
      final doc = await _firestore
          .collection(_paymentsCollection)
          .doc(paymentId)
          .get();

      if (doc.exists) {
        return PaymentModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      _logger.e('Error getting payment: $e');
      return null;
    }
  }

  /// Get all payments for a user
  Stream<List<PaymentModel>> getUserPayments(String userId) {
    try {
      return _firestore
          .collection(_paymentsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => PaymentModel.fromFirestore(doc))
              .toList());
    } catch (e) {
      _logger.e('Error getting user payments: $e');
      return Stream.value([]);
    }
  }

  /// Update payment status
  Future<bool> updatePaymentStatus(
    String paymentId,
    PaymentStatus status, {
    String? errorMessage,
  }) async {
    try {
      final updateData = {
        'status': _statusToString(status),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (errorMessage != null) {
        updateData['errorMessage'] = errorMessage;
      }

      await _firestore
          .collection(_paymentsCollection)
          .doc(paymentId)
          .update(updateData);

      _logger.i('Payment status updated: $paymentId -> $status');
      return true;
    } catch (e) {
      _logger.e('Error updating payment status: $e');
      return false;
    }
  }

  /// Process refund
  Future<bool> processRefund({
    required String paymentId,
    required double amount,
    required String reason,
  }) async {
    try {
      final payment = await getPaymentById(paymentId);
      if (payment == null) {
        _logger.w('Payment not found for refund: $paymentId');
        return false;
      }

      if (payment.status != PaymentStatus.completed) {
        _logger.w('Cannot refund payment with status: ${payment.status}');
        return false;
      }

      // TODO: Implement actual refund via payment gateway
      // This would call CMI or Stripe refund API

      // Update payment status
      final isPartialRefund = amount < payment.amount;
      final newStatus = isPartialRefund
          ? PaymentStatus.partiallyRefunded
          : PaymentStatus.refunded;

      await updatePaymentStatus(paymentId, newStatus);

      // Record refund transaction
      await _recordTransaction(
        paymentId: paymentId,
        userId: payment.userId,
        amount: -amount, // Negative for refund
        currency: payment.currency,
        type: 'refund',
        description: 'Refund: $reason',
      );

      _logger.i('Refund processed: $paymentId, amount: $amount');
      return true;
    } catch (e) {
      _logger.e('Error processing refund: $e');
      return false;
    }
  }

  /// Record a transaction
  Future<void> _recordTransaction({
    required String paymentId,
    required String userId,
    required double amount,
    required String currency,
    required String type,
    String? description,
    Map<String, dynamic>? details,
  }) async {
    try {
      final transaction = TransactionModel(
        id: '',
        paymentId: paymentId,
        userId: userId,
        amount: amount,
        currency: currency,
        type: type,
        timestamp: DateTime.now(),
        description: description,
        details: details,
      );

      await _firestore
          .collection(_transactionsCollection)
          .add(transaction.toFirestore());

      _logger.i('Transaction recorded: $type, amount: $amount $currency');
    } catch (e) {
      _logger.e('Error recording transaction: $e');
    }
  }

  /// Get transaction history for a user
  Stream<List<TransactionModel>> getUserTransactions(String userId) {
    try {
      return _firestore
          .collection(_transactionsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => TransactionModel.fromFirestore(doc))
              .toList());
    } catch (e) {
      _logger.e('Error getting user transactions: $e');
      return Stream.value([]);
    }
  }

  String _statusToString(PaymentStatus status) {
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
}
