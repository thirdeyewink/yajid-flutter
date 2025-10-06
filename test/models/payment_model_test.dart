import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yajid/models/payment_model.dart';

// Mock classes
// ignore: subtype_of_sealed_class
class MockDocumentSnapshot<T> extends Mock implements DocumentSnapshot<T> {}

void main() {
  group('PaymentModel', () {
    group('Model Creation', () {
      test('creates payment model with all required fields', () {
        final now = DateTime.now();
        final payment = PaymentModel(
          id: 'payment123',
          userId: 'user123',
          bookingId: 'booking123',
          amount: 500.0,
          currency: 'MAD',
          method: PaymentMethod.creditCard,
          status: PaymentStatus.pending,
          createdAt: now,
          updatedAt: now,
        );

        expect(payment.id, 'payment123');
        expect(payment.userId, 'user123');
        expect(payment.bookingId, 'booking123');
        expect(payment.amount, 500.0);
        expect(payment.currency, 'MAD');
        expect(payment.method, PaymentMethod.creditCard);
        expect(payment.status, PaymentStatus.pending);
        expect(payment.createdAt, now);
        expect(payment.updatedAt, now);
        expect(payment.transactionId, isNull);
        expect(payment.errorMessage, isNull);
        expect(payment.metadata, isNull);
      });

      test('creates payment model with optional fields', () {
        final now = DateTime.now();
        final payment = PaymentModel(
          id: 'payment123',
          userId: 'user123',
          bookingId: 'booking123',
          amount: 500.0,
          currency: 'MAD',
          method: PaymentMethod.cmi,
          status: PaymentStatus.completed,
          createdAt: now,
          updatedAt: now,
          transactionId: 'txn_abc123',
          errorMessage: null,
          metadata: {'gateway': 'cmi', 'region': 'morocco'},
        );

        expect(payment.transactionId, 'txn_abc123');
        expect(payment.metadata, {'gateway': 'cmi', 'region': 'morocco'});
      });
    });

    group('Payment Status Enum', () {
      test('all payment statuses can be created', () {
        expect(PaymentStatus.pending, isA<PaymentStatus>());
        expect(PaymentStatus.processing, isA<PaymentStatus>());
        expect(PaymentStatus.completed, isA<PaymentStatus>());
        expect(PaymentStatus.failed, isA<PaymentStatus>());
        expect(PaymentStatus.refunded, isA<PaymentStatus>());
        expect(PaymentStatus.partiallyRefunded, isA<PaymentStatus>());
      });

      test('converts status string to enum correctly', () {
        final now = DateTime.now();
        final testCases = {
          'pending': PaymentStatus.pending,
          'processing': PaymentStatus.processing,
          'completed': PaymentStatus.completed,
          'failed': PaymentStatus.failed,
          'refunded': PaymentStatus.refunded,
          'partiallyrefunded': PaymentStatus.partiallyRefunded,
        };

        for (final entry in testCases.entries) {
          final mockSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();
          when(() => mockSnapshot.id).thenReturn('payment123');
          when(() => mockSnapshot.data()).thenReturn({
            'status': entry.key,
            'userId': 'user123',
            'bookingId': 'booking123',
            'amount': 500.0,
            'currency': 'MAD',
            'method': 'creditcard',
            'createdAt': Timestamp.fromDate(now),
            'updatedAt': Timestamp.fromDate(now),
          });

          final payment = PaymentModel.fromFirestore(mockSnapshot);
          expect(payment.status, entry.value,
              reason: 'Status "${entry.key}" should convert to ${entry.value}');
        }
      });

      test('converts status enum to string correctly', () {
        final now = DateTime.now();
        final testCases = {
          PaymentStatus.pending: 'pending',
          PaymentStatus.processing: 'processing',
          PaymentStatus.completed: 'completed',
          PaymentStatus.failed: 'failed',
          PaymentStatus.refunded: 'refunded',
          PaymentStatus.partiallyRefunded: 'partiallyrefunded',
        };

        for (final entry in testCases.entries) {
          final payment = PaymentModel(
            id: 'payment123',
            userId: 'user123',
            bookingId: 'booking123',
            amount: 500.0,
            currency: 'MAD',
            method: PaymentMethod.creditCard,
            status: entry.key,
            createdAt: now,
            updatedAt: now,
          );

          final data = payment.toFirestore();
          expect(data['status'], entry.value,
              reason: 'Status ${entry.key} should convert to "${entry.value}"');
        }
      });

      test('handles invalid status string with default', () {
        final now = DateTime.now();
        final mockSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();
        when(() => mockSnapshot.id).thenReturn('payment123');
        when(() => mockSnapshot.data()).thenReturn({
          'status': 'invalid_status',
          'userId': 'user123',
          'bookingId': 'booking123',
          'amount': 500.0,
          'currency': 'MAD',
          'method': 'creditcard',
          'createdAt': Timestamp.fromDate(now),
          'updatedAt': Timestamp.fromDate(now),
        });

        final payment = PaymentModel.fromFirestore(mockSnapshot);
        expect(payment.status, PaymentStatus.pending);
      });

      test('handles case-insensitive status strings', () {
        final now = DateTime.now();
        final mockSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();
        when(() => mockSnapshot.id).thenReturn('payment123');
        when(() => mockSnapshot.data()).thenReturn({
          'status': 'COMPLETED',
          'userId': 'user123',
          'bookingId': 'booking123',
          'amount': 500.0,
          'currency': 'MAD',
          'method': 'creditcard',
          'createdAt': Timestamp.fromDate(now),
          'updatedAt': Timestamp.fromDate(now),
        });

        final payment = PaymentModel.fromFirestore(mockSnapshot);
        expect(payment.status, PaymentStatus.completed);
      });
    });

    group('Payment Method Enum', () {
      test('all payment methods can be created', () {
        expect(PaymentMethod.creditCard, isA<PaymentMethod>());
        expect(PaymentMethod.debitCard, isA<PaymentMethod>());
        expect(PaymentMethod.cmi, isA<PaymentMethod>());
        expect(PaymentMethod.stripe, isA<PaymentMethod>());
        expect(PaymentMethod.cash, isA<PaymentMethod>());
      });

      test('converts method string to enum correctly', () {
        final now = DateTime.now();
        final testCases = {
          'creditcard': PaymentMethod.creditCard,
          'debitcard': PaymentMethod.debitCard,
          'cmi': PaymentMethod.cmi,
          'stripe': PaymentMethod.stripe,
          'cash': PaymentMethod.cash,
        };

        for (final entry in testCases.entries) {
          final mockSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();
          when(() => mockSnapshot.id).thenReturn('payment123');
          when(() => mockSnapshot.data()).thenReturn({
            'userId': 'user123',
            'bookingId': 'booking123',
            'amount': 500.0,
            'currency': 'MAD',
            'method': entry.key,
            'status': 'pending',
            'createdAt': Timestamp.fromDate(now),
            'updatedAt': Timestamp.fromDate(now),
          });

          final payment = PaymentModel.fromFirestore(mockSnapshot);
          expect(payment.method, entry.value,
              reason: 'Method "${entry.key}" should convert to ${entry.value}');
        }
      });

      test('converts method enum to string correctly', () {
        final now = DateTime.now();
        final testCases = {
          PaymentMethod.creditCard: 'creditcard',
          PaymentMethod.debitCard: 'debitcard',
          PaymentMethod.cmi: 'cmi',
          PaymentMethod.stripe: 'stripe',
          PaymentMethod.cash: 'cash',
        };

        for (final entry in testCases.entries) {
          final payment = PaymentModel(
            id: 'payment123',
            userId: 'user123',
            bookingId: 'booking123',
            amount: 500.0,
            currency: 'MAD',
            method: entry.key,
            status: PaymentStatus.pending,
            createdAt: now,
            updatedAt: now,
          );

          final data = payment.toFirestore();
          expect(data['method'], entry.value,
              reason: 'Method ${entry.key} should convert to "${entry.value}"');
        }
      });

      test('handles invalid method string with default', () {
        final now = DateTime.now();
        final mockSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();
        when(() => mockSnapshot.id).thenReturn('payment123');
        when(() => mockSnapshot.data()).thenReturn({
          'userId': 'user123',
          'bookingId': 'booking123',
          'amount': 500.0,
          'currency': 'MAD',
          'method': 'invalid_method',
          'status': 'pending',
          'createdAt': Timestamp.fromDate(now),
          'updatedAt': Timestamp.fromDate(now),
        });

        final payment = PaymentModel.fromFirestore(mockSnapshot);
        expect(payment.method, PaymentMethod.creditCard);
      });

      test('handles case-insensitive method strings', () {
        final now = DateTime.now();
        final mockSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();
        when(() => mockSnapshot.id).thenReturn('payment123');
        when(() => mockSnapshot.data()).thenReturn({
          'userId': 'user123',
          'bookingId': 'booking123',
          'amount': 500.0,
          'currency': 'MAD',
          'method': 'CMI',
          'status': 'pending',
          'createdAt': Timestamp.fromDate(now),
          'updatedAt': Timestamp.fromDate(now),
        });

        final payment = PaymentModel.fromFirestore(mockSnapshot);
        expect(payment.method, PaymentMethod.cmi);
      });
    });

    group('Firestore Serialization', () {
      test('converts payment model to Firestore format', () {
        final now = DateTime.now();
        final payment = PaymentModel(
          id: 'payment123',
          userId: 'user123',
          bookingId: 'booking123',
          amount: 500.0,
          currency: 'MAD',
          method: PaymentMethod.creditCard,
          status: PaymentStatus.completed,
          createdAt: now,
          updatedAt: now,
        );

        final data = payment.toFirestore();

        expect(data['userId'], 'user123');
        expect(data['bookingId'], 'booking123');
        expect(data['amount'], 500.0);
        expect(data['currency'], 'MAD');
        expect(data['method'], 'creditcard');
        expect(data['status'], 'completed');
        expect(data['createdAt'], isA<Timestamp>());
        expect(data['updatedAt'], isA<Timestamp>());
      });

      test('includes optional fields when present', () {
        final now = DateTime.now();
        final payment = PaymentModel(
          id: 'payment123',
          userId: 'user123',
          bookingId: 'booking123',
          amount: 500.0,
          currency: 'MAD',
          method: PaymentMethod.cmi,
          status: PaymentStatus.completed,
          createdAt: now,
          updatedAt: now,
          transactionId: 'txn_abc123',
          errorMessage: null,
          metadata: {'gateway': 'cmi'},
        );

        final data = payment.toFirestore();

        expect(data['transactionId'], 'txn_abc123');
        expect(data['metadata'], {'gateway': 'cmi'});
      });

      test('excludes null optional fields', () {
        final now = DateTime.now();
        final payment = PaymentModel(
          id: 'payment123',
          userId: 'user123',
          bookingId: 'booking123',
          amount: 500.0,
          currency: 'MAD',
          method: PaymentMethod.creditCard,
          status: PaymentStatus.pending,
          createdAt: now,
          updatedAt: now,
        );

        final data = payment.toFirestore();

        expect(data.containsKey('transactionId'), false);
        expect(data.containsKey('errorMessage'), false);
        expect(data.containsKey('metadata'), false);
      });
    });

    group('Firestore Deserialization', () {
      test('creates payment model from Firestore snapshot', () {
        final now = DateTime.now();
        final mockSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();

        when(() => mockSnapshot.id).thenReturn('payment123');
        when(() => mockSnapshot.data()).thenReturn({
          'userId': 'user123',
          'bookingId': 'booking123',
          'amount': 500.0,
          'currency': 'MAD',
          'method': 'creditcard',
          'status': 'completed',
          'createdAt': Timestamp.fromDate(now),
          'updatedAt': Timestamp.fromDate(now),
        });

        final payment = PaymentModel.fromFirestore(mockSnapshot);

        expect(payment.id, 'payment123');
        expect(payment.userId, 'user123');
        expect(payment.bookingId, 'booking123');
        expect(payment.amount, 500.0);
        expect(payment.currency, 'MAD');
        expect(payment.method, PaymentMethod.creditCard);
        expect(payment.status, PaymentStatus.completed);
      });

      test('handles missing fields with defaults', () {
        final mockSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();

        when(() => mockSnapshot.id).thenReturn('payment123');
        when(() => mockSnapshot.data()).thenReturn({});

        final payment = PaymentModel.fromFirestore(mockSnapshot);

        expect(payment.id, 'payment123');
        expect(payment.userId, '');
        expect(payment.bookingId, '');
        expect(payment.amount, 0.0);
        expect(payment.currency, 'MAD');
        expect(payment.method, PaymentMethod.creditCard);
        expect(payment.status, PaymentStatus.pending);
      });

      test('parses optional fields from Firestore', () {
        final now = DateTime.now();
        final mockSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();

        when(() => mockSnapshot.id).thenReturn('payment123');
        when(() => mockSnapshot.data()).thenReturn({
          'userId': 'user123',
          'bookingId': 'booking123',
          'amount': 500.0,
          'currency': 'MAD',
          'method': 'cmi',
          'status': 'completed',
          'createdAt': Timestamp.fromDate(now),
          'updatedAt': Timestamp.fromDate(now),
          'transactionId': 'txn_abc123',
          'errorMessage': 'Payment gateway error',
          'metadata': {'gateway': 'cmi', 'retry': 2},
        });

        final payment = PaymentModel.fromFirestore(mockSnapshot);

        expect(payment.transactionId, 'txn_abc123');
        expect(payment.errorMessage, 'Payment gateway error');
        expect(payment.metadata, {'gateway': 'cmi', 'retry': 2});
      });

      test('handles integer amount as double', () {
        final mockSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();

        when(() => mockSnapshot.id).thenReturn('payment123');
        when(() => mockSnapshot.data()).thenReturn({
          'amount': 500, // Integer instead of double
        });

        final payment = PaymentModel.fromFirestore(mockSnapshot);

        expect(payment.amount, 500.0);
      });
    });

    group('Copy With', () {
      test('creates copy with updated status', () {
        final now = DateTime.now();
        final payment = PaymentModel(
          id: 'payment123',
          userId: 'user123',
          bookingId: 'booking123',
          amount: 500.0,
          currency: 'MAD',
          method: PaymentMethod.creditCard,
          status: PaymentStatus.pending,
          createdAt: now,
          updatedAt: now,
        );

        final updated = payment.copyWith(
          status: PaymentStatus.completed,
          transactionId: 'txn_abc123',
        );

        expect(updated.status, PaymentStatus.completed);
        expect(updated.transactionId, 'txn_abc123');
        expect(updated.id, payment.id); // Unchanged
        expect(updated.amount, payment.amount); // Unchanged
      });

      test('creates copy with error message', () {
        final now = DateTime.now();
        final payment = PaymentModel(
          id: 'payment123',
          userId: 'user123',
          bookingId: 'booking123',
          amount: 500.0,
          currency: 'MAD',
          method: PaymentMethod.creditCard,
          status: PaymentStatus.processing,
          createdAt: now,
          updatedAt: now,
        );

        final failed = payment.copyWith(
          status: PaymentStatus.failed,
          errorMessage: 'Insufficient funds',
        );

        expect(failed.status, PaymentStatus.failed);
        expect(failed.errorMessage, 'Insufficient funds');
      });

      test('copyWith preserves original values when no changes', () {
        final now = DateTime.now();
        final payment = PaymentModel(
          id: 'payment123',
          userId: 'user123',
          bookingId: 'booking123',
          amount: 500.0,
          currency: 'MAD',
          method: PaymentMethod.cmi,
          status: PaymentStatus.completed,
          createdAt: now,
          updatedAt: now,
          transactionId: 'txn_abc123',
        );

        final copy = payment.copyWith();

        expect(copy.id, payment.id);
        expect(copy.status, payment.status);
        expect(copy.transactionId, payment.transactionId);
      });
    });
  });

  group('TransactionModel', () {
    group('Model Creation', () {
      test('creates transaction model with all required fields', () {
        final now = DateTime.now();
        final transaction = TransactionModel(
          id: 'txn123',
          paymentId: 'payment123',
          userId: 'user123',
          amount: 500.0,
          currency: 'MAD',
          type: 'payment',
          timestamp: now,
        );

        expect(transaction.id, 'txn123');
        expect(transaction.paymentId, 'payment123');
        expect(transaction.userId, 'user123');
        expect(transaction.amount, 500.0);
        expect(transaction.currency, 'MAD');
        expect(transaction.type, 'payment');
        expect(transaction.timestamp, now);
        expect(transaction.description, isNull);
        expect(transaction.details, isNull);
      });

      test('creates transaction model with optional fields', () {
        final now = DateTime.now();
        final transaction = TransactionModel(
          id: 'txn123',
          paymentId: 'payment123',
          userId: 'user123',
          amount: 500.0,
          currency: 'MAD',
          type: 'refund',
          timestamp: now,
          description: 'Customer refund request',
          details: {'reason': 'cancelled', 'refundMethod': 'original'},
        );

        expect(transaction.description, 'Customer refund request');
        expect(transaction.details, {'reason': 'cancelled', 'refundMethod': 'original'});
      });
    });

    group('Transaction Types', () {
      test('handles payment transaction type', () {
        final now = DateTime.now();
        final transaction = TransactionModel(
          id: 'txn123',
          paymentId: 'payment123',
          userId: 'user123',
          amount: 500.0,
          currency: 'MAD',
          type: 'payment',
          timestamp: now,
        );

        expect(transaction.type, 'payment');
      });

      test('handles refund transaction type', () {
        final now = DateTime.now();
        final transaction = TransactionModel(
          id: 'txn123',
          paymentId: 'payment123',
          userId: 'user123',
          amount: -250.0, // Negative for refund
          currency: 'MAD',
          type: 'refund',
          timestamp: now,
        );

        expect(transaction.type, 'refund');
        expect(transaction.amount, -250.0);
      });

      test('handles chargeback transaction type', () {
        final now = DateTime.now();
        final transaction = TransactionModel(
          id: 'txn123',
          paymentId: 'payment123',
          userId: 'user123',
          amount: -500.0, // Negative for chargeback
          currency: 'MAD',
          type: 'chargeback',
          timestamp: now,
        );

        expect(transaction.type, 'chargeback');
      });
    });

    group('Firestore Serialization', () {
      test('converts transaction model to Firestore format', () {
        final now = DateTime.now();
        final transaction = TransactionModel(
          id: 'txn123',
          paymentId: 'payment123',
          userId: 'user123',
          amount: 500.0,
          currency: 'MAD',
          type: 'payment',
          timestamp: now,
        );

        final data = transaction.toFirestore();

        expect(data['paymentId'], 'payment123');
        expect(data['userId'], 'user123');
        expect(data['amount'], 500.0);
        expect(data['currency'], 'MAD');
        expect(data['type'], 'payment');
        expect(data['timestamp'], isA<Timestamp>());
      });

      test('includes optional fields when present', () {
        final now = DateTime.now();
        final transaction = TransactionModel(
          id: 'txn123',
          paymentId: 'payment123',
          userId: 'user123',
          amount: -250.0,
          currency: 'MAD',
          type: 'refund',
          timestamp: now,
          description: 'Partial refund',
          details: {'reason': 'damaged_item'},
        );

        final data = transaction.toFirestore();

        expect(data['description'], 'Partial refund');
        expect(data['details'], {'reason': 'damaged_item'});
      });

      test('excludes null optional fields', () {
        final now = DateTime.now();
        final transaction = TransactionModel(
          id: 'txn123',
          paymentId: 'payment123',
          userId: 'user123',
          amount: 500.0,
          currency: 'MAD',
          type: 'payment',
          timestamp: now,
        );

        final data = transaction.toFirestore();

        expect(data.containsKey('description'), false);
        expect(data.containsKey('details'), false);
      });
    });

    group('Firestore Deserialization', () {
      test('creates transaction model from Firestore snapshot', () {
        final now = DateTime.now();
        final mockSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();

        when(() => mockSnapshot.id).thenReturn('txn123');
        when(() => mockSnapshot.data()).thenReturn({
          'paymentId': 'payment123',
          'userId': 'user123',
          'amount': 500.0,
          'currency': 'MAD',
          'type': 'payment',
          'timestamp': Timestamp.fromDate(now),
        });

        final transaction = TransactionModel.fromFirestore(mockSnapshot);

        expect(transaction.id, 'txn123');
        expect(transaction.paymentId, 'payment123');
        expect(transaction.userId, 'user123');
        expect(transaction.amount, 500.0);
        expect(transaction.currency, 'MAD');
        expect(transaction.type, 'payment');
      });

      test('handles missing fields with defaults', () {
        final mockSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();

        when(() => mockSnapshot.id).thenReturn('txn123');
        when(() => mockSnapshot.data()).thenReturn({});

        final transaction = TransactionModel.fromFirestore(mockSnapshot);

        expect(transaction.id, 'txn123');
        expect(transaction.paymentId, '');
        expect(transaction.userId, '');
        expect(transaction.amount, 0.0);
        expect(transaction.currency, 'MAD');
        expect(transaction.type, 'payment');
      });

      test('parses optional fields from Firestore', () {
        final now = DateTime.now();
        final mockSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();

        when(() => mockSnapshot.id).thenReturn('txn123');
        when(() => mockSnapshot.data()).thenReturn({
          'paymentId': 'payment123',
          'userId': 'user123',
          'amount': -250.0,
          'currency': 'MAD',
          'type': 'refund',
          'timestamp': Timestamp.fromDate(now),
          'description': 'Customer refund',
          'details': {'method': 'original', 'processedBy': 'admin'},
        });

        final transaction = TransactionModel.fromFirestore(mockSnapshot);

        expect(transaction.description, 'Customer refund');
        expect(transaction.details, {'method': 'original', 'processedBy': 'admin'});
      });

      test('handles integer amount as double', () {
        final mockSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();

        when(() => mockSnapshot.id).thenReturn('txn123');
        when(() => mockSnapshot.data()).thenReturn({
          'amount': 500, // Integer instead of double
        });

        final transaction = TransactionModel.fromFirestore(mockSnapshot);

        expect(transaction.amount, 500.0);
      });
    });
  });
}
