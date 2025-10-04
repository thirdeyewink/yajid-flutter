import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yajid/services/payment_service.dart';
import 'package:yajid/models/payment_model.dart';

// Mock classes
class MockDocumentSnapshot<T> extends Mock implements DocumentSnapshot<T> {}

void main() {
  group('PaymentService', () {
    // PaymentService is initialized for future test implementations
    // ignore: unused_local_variable
    late PaymentService paymentService;

    setUp(() {
      paymentService = PaymentService();
    });

    group('PaymentModel', () {
      test('creates payment model with all required fields', () {
        final now = DateTime.now();
        final payment = PaymentModel(
          id: 'payment123',
          userId: 'user123',
          bookingId: 'booking123',
          amount: 200.0,
          currency: 'MAD',
          method: PaymentMethod.cmi,
          status: PaymentStatus.completed,
          createdAt: now,
          updatedAt: now,
          transactionId: 'txn123',
        );

        expect(payment.id, 'payment123');
        expect(payment.userId, 'user123');
        expect(payment.bookingId, 'booking123');
        expect(payment.amount, 200.0);
        expect(payment.currency, 'MAD');
        expect(payment.method, PaymentMethod.cmi);
        expect(payment.status, PaymentStatus.completed);
        expect(payment.transactionId, 'txn123');
      });

      test('converts payment model to Firestore format', () {
        final now = DateTime.now();
        final payment = PaymentModel(
          id: 'payment123',
          userId: 'user123',
          bookingId: 'booking123',
          amount: 200.0,
          currency: 'MAD',
          method: PaymentMethod.stripe,
          status: PaymentStatus.processing,
          createdAt: now,
          updatedAt: now,
          transactionId: 'pi_123',
          metadata: {'key': 'value'},
        );

        final data = payment.toFirestore();

        expect(data['userId'], 'user123');
        expect(data['bookingId'], 'booking123');
        expect(data['amount'], 200.0);
        expect(data['currency'], 'MAD');
        expect(data['method'], 'stripe');
        expect(data['status'], 'processing');
        expect(data['transactionId'], 'pi_123');
        expect(data['metadata'], isNotNull);
        expect(data['createdAt'], isA<Timestamp>());
      });

      test('creates payment model from Firestore snapshot', () {
        final now = DateTime.now();
        final mockSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();

        when(() => mockSnapshot.id).thenReturn('payment123');
        when(() => mockSnapshot.data()).thenReturn({
          'userId': 'user123',
          'bookingId': 'booking123',
          'amount': 200.0,
          'currency': 'MAD',
          'method': 'cmi',
          'status': 'completed',
          'createdAt': Timestamp.fromDate(now),
          'updatedAt': Timestamp.fromDate(now),
          'transactionId': 'CMI_123',
        });

        final payment = PaymentModel.fromFirestore(mockSnapshot);

        expect(payment.id, 'payment123');
        expect(payment.userId, 'user123');
        expect(payment.bookingId, 'booking123');
        expect(payment.amount, 200.0);
        expect(payment.method, PaymentMethod.cmi);
        expect(payment.status, PaymentStatus.completed);
      });

      test('handles all payment statuses correctly', () {
        final statuses = [
          PaymentStatus.pending,
          PaymentStatus.processing,
          PaymentStatus.completed,
          PaymentStatus.failed,
          PaymentStatus.refunded,
          PaymentStatus.partiallyRefunded,
        ];

        for (final status in statuses) {
          final payment = PaymentModel(
            id: 'payment123',
            userId: 'user123',
            bookingId: 'booking123',
            amount: 200.0,
            currency: 'MAD',
            method: PaymentMethod.creditCard,
            status: status,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          expect(payment.status, status);

          final data = payment.toFirestore();
          expect(data['status'], isNotNull);
        }
      });

      test('handles all payment methods correctly', () {
        final methods = [
          PaymentMethod.creditCard,
          PaymentMethod.debitCard,
          PaymentMethod.cmi,
          PaymentMethod.stripe,
          PaymentMethod.cash,
        ];

        for (final method in methods) {
          final payment = PaymentModel(
            id: 'payment123',
            userId: 'user123',
            bookingId: 'booking123',
            amount: 200.0,
            currency: 'MAD',
            method: method,
            status: PaymentStatus.pending,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          expect(payment.method, method);

          final data = payment.toFirestore();
          expect(data['method'], isNotNull);
        }
      });
    });

    group('TransactionModel', () {
      test('creates transaction model with all required fields', () {
        final now = DateTime.now();
        final transaction = TransactionModel(
          id: 'txn123',
          paymentId: 'payment123',
          userId: 'user123',
          amount: 200.0,
          currency: 'MAD',
          type: 'payment',
          timestamp: now,
          description: 'Payment for booking',
        );

        expect(transaction.id, 'txn123');
        expect(transaction.paymentId, 'payment123');
        expect(transaction.userId, 'user123');
        expect(transaction.amount, 200.0);
        expect(transaction.currency, 'MAD');
        expect(transaction.type, 'payment');
        expect(transaction.description, 'Payment for booking');
      });

      test('converts transaction model to Firestore format', () {
        final now = DateTime.now();
        final transaction = TransactionModel(
          id: 'txn123',
          paymentId: 'payment123',
          userId: 'user123',
          amount: -50.0, // Negative for refund
          currency: 'MAD',
          type: 'refund',
          timestamp: now,
          description: 'Partial refund',
          details: {'reason': 'Customer request'},
        );

        final data = transaction.toFirestore();

        expect(data['paymentId'], 'payment123');
        expect(data['userId'], 'user123');
        expect(data['amount'], -50.0);
        expect(data['currency'], 'MAD');
        expect(data['type'], 'refund');
        expect(data['description'], 'Partial refund');
        expect(data['details'], isNotNull);
        expect(data['timestamp'], isA<Timestamp>());
      });

      test('creates transaction model from Firestore snapshot', () {
        final now = DateTime.now();
        final mockSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();

        when(() => mockSnapshot.id).thenReturn('txn123');
        when(() => mockSnapshot.data()).thenReturn({
          'paymentId': 'payment123',
          'userId': 'user123',
          'amount': 200.0,
          'currency': 'MAD',
          'type': 'payment',
          'timestamp': Timestamp.fromDate(now),
          'description': 'Payment for booking',
        });

        final transaction = TransactionModel.fromFirestore(mockSnapshot);

        expect(transaction.id, 'txn123');
        expect(transaction.paymentId, 'payment123');
        expect(transaction.userId, 'user123');
        expect(transaction.amount, 200.0);
        expect(transaction.type, 'payment');
      });
    });

    group('PaymentService initialization', () {
      test('initializes with credentials', () {
        final service = PaymentService();
        service.initialize(
          cmiMerchantId: 'merchant123',
          cmiApiKey: 'key123',
          stripePublishableKey: 'pk_test_123',
          stripeSecretKey: 'sk_test_123',
        );

        // Service should be initialized without errors
        expect(service, isNotNull);
      });
    });
  });
}
