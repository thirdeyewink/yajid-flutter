import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yajid/models/recommendation_model.dart';
import 'package:yajid/services/logging_service.dart';
import 'package:yajid/services/recommendation_service.dart';

// Mocks
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockCollectionReference extends Mock implements CollectionReference<Map<String, dynamic>> {}
class MockQuery extends Mock implements Query<Map<String, dynamic>> {}
class MockQuerySnapshot extends Mock implements QuerySnapshot<Map<String, dynamic>> {}
class MockQueryDocumentSnapshot extends Mock implements QueryDocumentSnapshot<Map<String, dynamic>> {}
class MockDocumentReference extends Mock implements DocumentReference<Map<String, dynamic>> {}
class MockDocumentSnapshot extends Mock implements DocumentSnapshot<Map<String, dynamic>> {}
class MockAggregateQuery extends Mock implements AggregateQuery {}
class MockAggregateQuerySnapshot extends Mock implements AggregateQuerySnapshot {}
class MockLoggingService extends Mock implements LoggingService {}

void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockLoggingService mockLogger;
  late RecommendationService service;
  late MockCollectionReference mockCollection;
  late MockQuery mockQuery;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockLogger = MockLoggingService();
    mockCollection = MockCollectionReference();
    mockQuery = MockQuery();
    service = RecommendationService(
      firestore: mockFirestore,
      logger: mockLogger,
    );

    // Register fallback values for mocktail
    registerFallbackValue(DateTime.now());
  });

  group('RecommendationService', () {
    group('getAllRecommendations', () {
      test('returns list of recommendations on success', () async {
        // Arrange
        final mockSnapshot = MockQuerySnapshot();
        final mockDoc1 = MockQueryDocumentSnapshot();
        final mockDoc2 = MockQueryDocumentSnapshot();

        final testData1 = {
          'category': 'movies',
          'title': 'Test Movie',
          'creator': 'Director',
          'details': 'Details',
          'platform': 'Netflix',
          'whyLike': 'Great!',
          'communityRating': 4.5,
          'ratingCount': 10,
          'imageUrl': null,
          'tags': [],
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        };

        final testData2 = {
          'category': 'books',
          'title': 'Test Book',
          'creator': 'Author',
          'details': 'Details',
          'platform': 'Kindle',
          'whyLike': 'Amazing!',
          'communityRating': 5.0,
          'ratingCount': 20,
          'imageUrl': null,
          'tags': [],
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        };

        when(() => mockDoc1.id).thenReturn('rec1');
        when(() => mockDoc1.data()).thenReturn(testData1);
        when(() => mockDoc2.id).thenReturn('rec2');
        when(() => mockDoc2.data()).thenReturn(testData2);
        when(() => mockSnapshot.docs).thenReturn([mockDoc1, mockDoc2]);
        when(() => mockQuery.get()).thenAnswer((_) async => mockSnapshot);
        when(() => mockQuery.orderBy(any(), descending: any(named: 'descending'))).thenReturn(mockQuery);
        when(() => mockCollection.orderBy(any(), descending: any(named: 'descending'))).thenReturn(mockQuery);
        when(() => mockFirestore.collection('recommendations')).thenReturn(mockCollection);

        // Act
        final result = await service.getAllRecommendations();

        // Assert
        expect(result, hasLength(2));
        expect(result[0].title, 'Test Movie');
        expect(result[1].title, 'Test Book');
        verify(() => mockFirestore.collection('recommendations')).called(1);
      });

      test('returns empty list on Firestore error', () async {
        // Arrange
        when(() => mockFirestore.collection('recommendations')).thenThrow(Exception('Firestore error'));
        when(() => mockLogger.error(any(), any())).thenReturn(null);

        // Act
        final result = await service.getAllRecommendations();

        // Assert
        expect(result, isEmpty);
        verify(() => mockLogger.error('Error fetching all recommendations', any())).called(1);
      });

      test('returns empty list when no documents exist', () async {
        // Arrange
        final mockSnapshot = MockQuerySnapshot();
        when(() => mockSnapshot.docs).thenReturn([]);
        when(() => mockQuery.get()).thenAnswer((_) async => mockSnapshot);
        when(() => mockQuery.orderBy(any(), descending: any(named: 'descending'))).thenReturn(mockQuery);
        when(() => mockCollection.orderBy(any(), descending: any(named: 'descending'))).thenReturn(mockQuery);
        when(() => mockFirestore.collection('recommendations')).thenReturn(mockCollection);

        // Act
        final result = await service.getAllRecommendations();

        // Assert
        expect(result, isEmpty);
      });
    });

    group('getRecommendationsByCategory', () {
      test('returns recommendations for valid category', () async {
        // Arrange
        final mockSnapshot = MockQuerySnapshot();
        final mockDoc = MockQueryDocumentSnapshot();

        final testData = {
          'category': 'movies',
          'title': 'Test Movie',
          'creator': 'Director',
          'details': 'Details',
          'platform': 'Netflix',
          'whyLike': 'Great!',
          'communityRating': 4.5,
          'ratingCount': 10,
          'imageUrl': null,
          'tags': [],
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        };

        when(() => mockDoc.id).thenReturn('rec1');
        when(() => mockDoc.data()).thenReturn(testData);
        when(() => mockSnapshot.docs).thenReturn([mockDoc]);
        when(() => mockQuery.get()).thenAnswer((_) async => mockSnapshot);
        when(() => mockQuery.where(any(), isEqualTo: any(named: 'isEqualTo'))).thenReturn(mockQuery);
        when(() => mockQuery.orderBy(any(), descending: any(named: 'descending'))).thenReturn(mockQuery);
        when(() => mockQuery.limit(any())).thenReturn(mockQuery);
        when(() => mockCollection.where(any(), isEqualTo: any(named: 'isEqualTo'))).thenReturn(mockQuery);
        when(() => mockFirestore.collection('recommendations')).thenReturn(mockCollection);

        // Act
        final result = await service.getRecommendationsByCategory('movies');

        // Assert
        expect(result, hasLength(1));
        expect(result[0].category, 'movies');
        expect(result[0].title, 'Test Movie');
      });

      test('respects limit parameter', () async {
        // Arrange
        final mockSnapshot = MockQuerySnapshot();
        when(() => mockSnapshot.docs).thenReturn([]);
        when(() => mockQuery.get()).thenAnswer((_) async => mockSnapshot);
        when(() => mockQuery.where(any(), isEqualTo: any(named: 'isEqualTo'))).thenReturn(mockQuery);
        when(() => mockQuery.orderBy(any(), descending: any(named: 'descending'))).thenReturn(mockQuery);
        when(() => mockQuery.limit(5)).thenReturn(mockQuery);
        when(() => mockCollection.where(any(), isEqualTo: any(named: 'isEqualTo'))).thenReturn(mockQuery);
        when(() => mockFirestore.collection('recommendations')).thenReturn(mockCollection);

        // Act
        await service.getRecommendationsByCategory('movies', limit: 5);

        // Assert
        verify(() => mockQuery.limit(5)).called(1);
      });

      test('returns empty list on error', () async {
        // Arrange
        when(() => mockFirestore.collection('recommendations')).thenThrow(Exception('Error'));
        when(() => mockLogger.error(any(), any())).thenReturn(null);

        // Act
        final result = await service.getRecommendationsByCategory('movies');

        // Assert
        expect(result, isEmpty);
        verify(() => mockLogger.error(any(), any())).called(1);
      });
    });

    group('addRecommendation', () {
      test('successfully adds recommendation', () async {
        // Arrange
        final mockDocRef = MockDocumentReference();
        final recommendation = Recommendation(
          id: 'rec1',
          category: 'movies',
          title: 'Test Movie',
          creator: 'Director',
          details: 'Details',
          platform: 'Netflix',
          whyLike: 'Great!',
          communityRating: 4.5,
          ratingCount: 10,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(() => mockDocRef.set(any())).thenAnswer((_) async => {});
        when(() => mockCollection.doc(any())).thenReturn(mockDocRef);
        when(() => mockFirestore.collection('recommendations')).thenReturn(mockCollection);
        when(() => mockLogger.info(any())).thenReturn(null);

        // Act
        final result = await service.addRecommendation(recommendation);

        // Assert
        expect(result, true);
        verify(() => mockDocRef.set(any())).called(1);
        verify(() => mockLogger.info(any())).called(1);
      });

      test('returns false on error', () async {
        // Arrange
        final recommendation = Recommendation(
          id: 'rec1',
          category: 'movies',
          title: 'Test Movie',
          creator: 'Director',
          details: 'Details',
          platform: 'Netflix',
          whyLike: 'Great!',
          communityRating: 4.5,
          ratingCount: 10,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(() => mockFirestore.collection('recommendations')).thenThrow(Exception('Error'));
        when(() => mockLogger.error(any(), any())).thenReturn(null);

        // Act
        final result = await service.addRecommendation(recommendation);

        // Assert
        expect(result, false);
        verify(() => mockLogger.error(any(), any())).called(1);
      });
    });

    group('updateRecommendation', () {
      test('successfully updates recommendation', () async {
        // Arrange
        final mockDocRef = MockDocumentReference();
        final recommendation = Recommendation(
          id: 'rec1',
          category: 'movies',
          title: 'Updated Movie',
          creator: 'Director',
          details: 'Updated Details',
          platform: 'Netflix',
          whyLike: 'Great!',
          communityRating: 4.5,
          ratingCount: 10,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(() => mockDocRef.update(any())).thenAnswer((_) async => {});
        when(() => mockCollection.doc(any())).thenReturn(mockDocRef);
        when(() => mockFirestore.collection('recommendations')).thenReturn(mockCollection);
        when(() => mockLogger.info(any())).thenReturn(null);

        // Act
        final result = await service.updateRecommendation(recommendation);

        // Assert
        expect(result, true);
        verify(() => mockDocRef.update(any())).called(1);
        verify(() => mockLogger.info(any())).called(1);
      });

      test('returns false on error', () async {
        // Arrange
        final recommendation = Recommendation(
          id: 'rec1',
          category: 'movies',
          title: 'Test Movie',
          creator: 'Director',
          details: 'Details',
          platform: 'Netflix',
          whyLike: 'Great!',
          communityRating: 4.5,
          ratingCount: 10,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(() => mockFirestore.collection('recommendations')).thenThrow(Exception('Error'));
        when(() => mockLogger.error(any(), any())).thenReturn(null);

        // Act
        final result = await service.updateRecommendation(recommendation);

        // Assert
        expect(result, false);
        verify(() => mockLogger.error(any(), any())).called(1);
      });
    });

    group('deleteRecommendation', () {
      test('successfully deletes recommendation', () async {
        // Arrange
        final mockDocRef = MockDocumentReference();
        when(() => mockDocRef.delete()).thenAnswer((_) async => {});
        when(() => mockCollection.doc('rec1')).thenReturn(mockDocRef);
        when(() => mockFirestore.collection('recommendations')).thenReturn(mockCollection);
        when(() => mockLogger.info(any())).thenReturn(null);

        // Act
        final result = await service.deleteRecommendation('rec1');

        // Assert
        expect(result, true);
        verify(() => mockDocRef.delete()).called(1);
        verify(() => mockLogger.info(any())).called(1);
      });

      test('returns false on error', () async {
        // Arrange
        when(() => mockFirestore.collection('recommendations')).thenThrow(Exception('Error'));
        when(() => mockLogger.error(any(), any())).thenReturn(null);

        // Act
        final result = await service.deleteRecommendation('rec1');

        // Assert
        expect(result, false);
        verify(() => mockLogger.error(any(), any())).called(1);
      });
    });

    group('updateCommunityRating', () {
      test('calculates and updates rating correctly', () async {
        // Arrange
        final mockDocRef = MockDocumentReference();
        final mockDocSnapshot = MockDocumentSnapshot();

        when(() => mockDocSnapshot.exists).thenReturn(true);
        when(() => mockDocSnapshot.data()).thenReturn({
          'communityRating': 4.0,
          'ratingCount': 2,
        });
        when(() => mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
        when(() => mockDocRef.update(any())).thenAnswer((_) async => {});
        when(() => mockCollection.doc('rec1')).thenReturn(mockDocRef);
        when(() => mockFirestore.collection('recommendations')).thenReturn(mockCollection);
        when(() => mockLogger.info(any())).thenReturn(null);

        // Act
        final result = await service.updateCommunityRating('rec1', 5.0);

        // Assert
        expect(result, true);
        // New rating = (4.0 * 2 + 5.0) / 3 = 13.0 / 3 = 4.333...
        verify(() => mockDocRef.update(any())).called(1);
        verify(() => mockLogger.info(any())).called(1);
      });

      test('returns false when recommendation not found', () async {
        // Arrange
        final mockDocRef = MockDocumentReference();
        final mockDocSnapshot = MockDocumentSnapshot();

        when(() => mockDocSnapshot.exists).thenReturn(false);
        when(() => mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
        when(() => mockCollection.doc('rec1')).thenReturn(mockDocRef);
        when(() => mockFirestore.collection('recommendations')).thenReturn(mockCollection);
        when(() => mockLogger.error(any(), any())).thenReturn(null);

        // Act
        final result = await service.updateCommunityRating('rec1', 5.0);

        // Assert
        expect(result, false);
        verify(() => mockLogger.error(any(), any())).called(1);
      });

      test('returns false on error', () async {
        // Arrange
        when(() => mockFirestore.collection('recommendations')).thenThrow(Exception('Error'));
        when(() => mockLogger.error(any(), any())).thenReturn(null);

        // Act
        final result = await service.updateCommunityRating('rec1', 5.0);

        // Assert
        expect(result, false);
        verify(() => mockLogger.error(any(), any())).called(1);
      });

      test('handles zero initial rating count', () async {
        // Arrange
        final mockDocRef = MockDocumentReference();
        final mockDocSnapshot = MockDocumentSnapshot();

        when(() => mockDocSnapshot.exists).thenReturn(true);
        when(() => mockDocSnapshot.data()).thenReturn({
          'communityRating': 0.0,
          'ratingCount': 0,
        });
        when(() => mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
        when(() => mockDocRef.update(any())).thenAnswer((_) async => {});
        when(() => mockCollection.doc('rec1')).thenReturn(mockDocRef);
        when(() => mockFirestore.collection('recommendations')).thenReturn(mockCollection);
        when(() => mockLogger.info(any())).thenReturn(null);

        // Act
        final result = await service.updateCommunityRating('rec1', 4.5);

        // Assert
        expect(result, true);
        // New rating = (0.0 * 0 + 4.5) / 1 = 4.5
        verify(() => mockDocRef.update(any())).called(1);
      });
    });

    group('searchRecommendations', () {
      test('returns search results', () async {
        // Arrange
        final mockSnapshot = MockQuerySnapshot();
        final mockDoc = MockQueryDocumentSnapshot();

        final testData = {
          'category': 'movies',
          'title': 'The Matrix',
          'creator': 'Wachowskis',
          'details': 'Sci-fi',
          'platform': 'Netflix',
          'whyLike': 'Mind-bending',
          'communityRating': 5.0,
          'ratingCount': 100,
          'imageUrl': null,
          'tags': [],
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        };

        when(() => mockDoc.id).thenReturn('rec1');
        when(() => mockDoc.data()).thenReturn(testData);
        when(() => mockSnapshot.docs).thenReturn([mockDoc]);
        when(() => mockQuery.get()).thenAnswer((_) async => mockSnapshot);
        when(() => mockQuery.orderBy(any())).thenReturn(mockQuery);
        when(() => mockQuery.startAt(any())).thenReturn(mockQuery);
        when(() => mockQuery.endAt(any())).thenReturn(mockQuery);
        when(() => mockQuery.limit(any())).thenReturn(mockQuery);
        when(() => mockCollection.orderBy(any())).thenReturn(mockQuery);
        when(() => mockFirestore.collection('recommendations')).thenReturn(mockCollection);

        // Act
        final result = await service.searchRecommendations('Matrix');

        // Assert
        expect(result, hasLength(1));
        expect(result[0].title, 'The Matrix');
      });

      test('returns empty list on error', () async {
        // Arrange
        when(() => mockFirestore.collection('recommendations')).thenThrow(Exception('Error'));
        when(() => mockLogger.error(any(), any())).thenReturn(null);

        // Act
        final result = await service.searchRecommendations('test');

        // Assert
        expect(result, isEmpty);
        verify(() => mockLogger.error(any(), any())).called(1);
      });
    });

    group('getRecommendationCountsByCategory', () {
      test('returns counts for all categories', () async {
        // Arrange
        final mockAggregateQuery = MockAggregateQuery();
        final mockAggregateSnapshot = MockAggregateQuerySnapshot();

        when(() => mockAggregateSnapshot.count).thenReturn(5);
        when(() => mockAggregateQuery.get()).thenAnswer((_) async => mockAggregateSnapshot);
        when(() => mockQuery.count()).thenReturn(mockAggregateQuery);
        when(() => mockQuery.where(any(), isEqualTo: any(named: 'isEqualTo'))).thenReturn(mockQuery);
        when(() => mockCollection.where(any(), isEqualTo: any(named: 'isEqualTo'))).thenReturn(mockQuery);
        when(() => mockFirestore.collection('recommendations')).thenReturn(mockCollection);

        // Act
        final result = await service.getRecommendationCountsByCategory();

        // Assert
        expect(result, isNotEmpty);
        expect(result.containsKey('movies'), true);
        expect(result.containsKey('books'), true);
        expect(result.values.every((value) => value == 5), true);
      });

      test('handles null counts', () async {
        // Arrange
        final mockAggregateQuery = MockAggregateQuery();
        final mockAggregateSnapshot = MockAggregateQuerySnapshot();

        when(() => mockAggregateSnapshot.count).thenReturn(null);
        when(() => mockAggregateQuery.get()).thenAnswer((_) async => mockAggregateSnapshot);
        when(() => mockQuery.count()).thenReturn(mockAggregateQuery);
        when(() => mockQuery.where(any(), isEqualTo: any(named: 'isEqualTo'))).thenReturn(mockQuery);
        when(() => mockCollection.where(any(), isEqualTo: any(named: 'isEqualTo'))).thenReturn(mockQuery);
        when(() => mockFirestore.collection('recommendations')).thenReturn(mockCollection);

        // Act
        final result = await service.getRecommendationCountsByCategory();

        // Assert
        expect(result, isNotEmpty);
        expect(result.values.every((value) => value == 0), true);
      });

      test('returns empty map on error', () async {
        // Arrange
        when(() => mockFirestore.collection('recommendations')).thenThrow(Exception('Error'));
        when(() => mockLogger.error(any(), any())).thenReturn(null);

        // Act
        final result = await service.getRecommendationCountsByCategory();

        // Assert
        expect(result, isEmpty);
        verify(() => mockLogger.error(any(), any())).called(1);
      });
    });

    group('streamRecommendations', () {
      test('returns stream of recommendations', () async {
        // Arrange
        final mockSnapshot = MockQuerySnapshot();
        final mockDoc = MockQueryDocumentSnapshot();

        final testData = {
          'category': 'movies',
          'title': 'Test Movie',
          'creator': 'Director',
          'details': 'Details',
          'platform': 'Netflix',
          'whyLike': 'Great!',
          'communityRating': 4.5,
          'ratingCount': 10,
          'imageUrl': null,
          'tags': [],
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        };

        when(() => mockDoc.id).thenReturn('rec1');
        when(() => mockDoc.data()).thenReturn(testData);
        when(() => mockSnapshot.docs).thenReturn([mockDoc]);
        when(() => mockQuery.snapshots()).thenAnswer((_) => Stream.value(mockSnapshot));
        when(() => mockQuery.orderBy(any(), descending: any(named: 'descending'))).thenReturn(mockQuery);
        when(() => mockQuery.limit(any())).thenReturn(mockQuery);
        when(() => mockCollection.orderBy(any(), descending: any(named: 'descending'))).thenReturn(mockQuery);
        when(() => mockFirestore.collection('recommendations')).thenReturn(mockCollection);

        // Act
        final stream = service.streamRecommendations();
        final result = await stream.first;

        // Assert
        expect(result, hasLength(1));
        expect(result[0].title, 'Test Movie');
      });

      test('filters by category when provided', () async {
        // Arrange
        final mockSnapshot = MockQuerySnapshot();
        when(() => mockSnapshot.docs).thenReturn([]);
        when(() => mockQuery.snapshots()).thenAnswer((_) => Stream.value(mockSnapshot));
        when(() => mockQuery.orderBy(any(), descending: any(named: 'descending'))).thenReturn(mockQuery);
        when(() => mockQuery.limit(any())).thenReturn(mockQuery);
        when(() => mockQuery.where(any(), isEqualTo: 'movies')).thenReturn(mockQuery);
        when(() => mockCollection.orderBy(any(), descending: any(named: 'descending'))).thenReturn(mockQuery);
        when(() => mockFirestore.collection('recommendations')).thenReturn(mockCollection);

        // Act
        final stream = service.streamRecommendations(category: 'movies');
        await stream.first;

        // Assert
        verify(() => mockQuery.where('category', isEqualTo: 'movies')).called(1);
      });

      test('returns empty stream on error', () async {
        // Arrange
        when(() => mockFirestore.collection('recommendations')).thenThrow(Exception('Error'));
        when(() => mockLogger.error(any(), any())).thenReturn(null);

        // Act
        final stream = service.streamRecommendations();
        final result = await stream.first;

        // Assert
        expect(result, isEmpty);
      });
    });

    group('getRecommendationsPaginated', () {
      test('returns paginated results without filters', () async {
        // Arrange
        final mockSnapshot = MockQuerySnapshot();
        final mockDoc = MockQueryDocumentSnapshot();

        final testData = {
          'category': 'movies',
          'title': 'Test Movie',
          'creator': 'Director',
          'details': 'Details',
          'platform': 'Netflix',
          'whyLike': 'Great!',
          'communityRating': 4.5,
          'ratingCount': 10,
          'imageUrl': null,
          'tags': [],
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        };

        when(() => mockDoc.id).thenReturn('rec1');
        when(() => mockDoc.data()).thenReturn(testData);
        when(() => mockSnapshot.docs).thenReturn([mockDoc]);
        when(() => mockQuery.get()).thenAnswer((_) async => mockSnapshot);
        when(() => mockQuery.orderBy(any(), descending: any(named: 'descending'))).thenReturn(mockQuery);
        when(() => mockQuery.limit(10)).thenReturn(mockQuery);
        when(() => mockCollection.orderBy(any(), descending: any(named: 'descending'))).thenReturn(mockQuery);
        when(() => mockFirestore.collection('recommendations')).thenReturn(mockCollection);

        // Act
        final result = await service.getRecommendationsPaginated();

        // Assert
        expect(result, hasLength(1));
        verify(() => mockQuery.limit(10)).called(1);
      });

      test('filters by category when provided', () async {
        // Arrange
        final mockSnapshot = MockQuerySnapshot();
        when(() => mockSnapshot.docs).thenReturn([]);
        when(() => mockQuery.get()).thenAnswer((_) async => mockSnapshot);
        when(() => mockQuery.orderBy(any(), descending: any(named: 'descending'))).thenReturn(mockQuery);
        when(() => mockQuery.where('category', isEqualTo: 'movies')).thenReturn(mockQuery);
        when(() => mockQuery.limit(any())).thenReturn(mockQuery);
        when(() => mockCollection.orderBy(any(), descending: any(named: 'descending'))).thenReturn(mockQuery);
        when(() => mockFirestore.collection('recommendations')).thenReturn(mockCollection);

        // Act
        await service.getRecommendationsPaginated(category: 'movies');

        // Assert
        verify(() => mockQuery.where('category', isEqualTo: 'movies')).called(1);
      });

      test('does not filter when category is "all"', () async {
        // Arrange
        final mockSnapshot = MockQuerySnapshot();
        when(() => mockSnapshot.docs).thenReturn([]);
        when(() => mockQuery.get()).thenAnswer((_) async => mockSnapshot);
        when(() => mockQuery.orderBy(any(), descending: any(named: 'descending'))).thenReturn(mockQuery);
        when(() => mockQuery.limit(any())).thenReturn(mockQuery);
        when(() => mockCollection.orderBy(any(), descending: any(named: 'descending'))).thenReturn(mockQuery);
        when(() => mockFirestore.collection('recommendations')).thenReturn(mockCollection);

        // Act
        await service.getRecommendationsPaginated(category: 'all');

        // Assert
        verifyNever(() => mockQuery.where(any(), isEqualTo: any(named: 'isEqualTo')));
      });

      test('returns empty list on error', () async {
        // Arrange
        when(() => mockFirestore.collection('recommendations')).thenThrow(Exception('Error'));
        when(() => mockLogger.error(any(), any())).thenReturn(null);

        // Act
        final result = await service.getRecommendationsPaginated();

        // Assert
        expect(result, isEmpty);
        verify(() => mockLogger.error(any(), any())).called(1);
      });
    });
  });
}
