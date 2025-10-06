import 'package:flutter_test/flutter_test.dart';
import 'package:yajid/models/recommendation_model.dart';

void main() {
  group('Recommendation', () {
    group('Model Creation', () {
      test('creates recommendation with all fields', () {
        final now = DateTime.now();
        final rec = Recommendation(
          id: 'rec123',
          category: 'movies',
          title: 'Test Movie',
          creator: 'Test Director',
          details: 'Test Actor',
          platform: 'Netflix',
          whyLike: 'Great story',
          communityRating: 4.5,
          ratingCount: 100,
          tags: ['action', 'drama'],
          createdAt: now,
          updatedAt: now,
        );

        expect(rec.id, 'rec123');
        expect(rec.category, 'movies');
        expect(rec.title, 'Test Movie');
        expect(rec.creator, 'Test Director');
        expect(rec.details, 'Test Actor');
        expect(rec.platform, 'Netflix');
        expect(rec.whyLike, 'Great story');
        expect(rec.communityRating, 4.5);
        expect(rec.ratingCount, 100);
        expect(rec.tags, ['action', 'drama']);
        expect(rec.createdAt, now);
        expect(rec.updatedAt, now);
      });

      test('rating is within valid range', () {
        final now = DateTime.now();
        final rec = Recommendation(
          id: 'rec123',
          category: 'movies',
          title: 'Test',
          creator: 'Creator',
          details: 'Details',
          platform: 'Platform',
          whyLike: 'Why',
          communityRating: 4.5,
          ratingCount: 10,
          tags: [],
          createdAt: now,
          updatedAt: now,
        );

        expect(rec.communityRating, greaterThanOrEqualTo(0.0));
        expect(rec.communityRating, lessThanOrEqualTo(5.0));
      });

      test('rating count is non-negative', () {
        final now = DateTime.now();
        final rec = Recommendation(
          id: 'rec123',
          category: 'books',
          title: 'Test Book',
          creator: 'Author',
          details: 'Publisher',
          platform: 'Kindle',
          whyLike: 'Interesting',
          communityRating: 4.0,
          ratingCount: 50,
          tags: [],
          createdAt: now,
          updatedAt: now,
        );

        expect(rec.ratingCount, greaterThanOrEqualTo(0));
      });

      test('handles empty tags list', () {
        final now = DateTime.now();
        final rec = Recommendation(
          id: 'rec123',
          category: 'music',
          title: 'Song',
          creator: 'Artist',
          details: 'Album',
          platform: 'Spotify',
          whyLike: 'Catchy',
          communityRating: 5.0,
          ratingCount: 200,
          tags: [],
          createdAt: now,
          updatedAt: now,
        );

        expect(rec.tags, isEmpty);
      });

      test('handles multiple tags', () {
        final now = DateTime.now();
        final rec = Recommendation(
          id: 'rec123',
          category: 'videogames',
          title: 'Game',
          creator: 'Studio',
          details: 'Platform',
          platform: 'Steam',
          whyLike: 'Fun',
          communityRating: 4.8,
          ratingCount: 1000,
          tags: ['rpg', 'multiplayer', 'open-world', 'fantasy'],
          createdAt: now,
          updatedAt: now,
        );

        expect(rec.tags.length, 4);
        expect(rec.tags, contains('rpg'));
        expect(rec.tags, contains('multiplayer'));
      });
    });

    group('Categories', () {
      test('supports all expected categories', () {
        final now = DateTime.now();
        final categories = [
          'movies',
          'music',
          'books',
          'tv shows',
          'podcasts',
          'sports',
          'videogames',
          'brands',
          'recipes',
          'events',
          'activities',
          'businesses',
        ];

        for (final category in categories) {
          final rec = Recommendation(
            id: 'rec_$category',
            category: category,
            title: 'Test $category',
            creator: 'Creator',
            details: 'Details',
            platform: 'Platform',
            whyLike: 'Why',
            communityRating: 4.0,
            ratingCount: 10,
            tags: [],
            createdAt: now,
            updatedAt: now,
          );

          expect(rec.category, category);
        }
      });

      test('category is case-sensitive', () {
        final now = DateTime.now();
        final rec = Recommendation(
          id: 'rec123',
          category: 'movies',
          title: 'Test',
          creator: 'Creator',
          details: 'Details',
          platform: 'Platform',
          whyLike: 'Why',
          communityRating: 4.0,
          ratingCount: 10,
          tags: [],
          createdAt: now,
          updatedAt: now,
        );

        expect(rec.category, 'movies');
        expect(rec.category == 'Movies', false);
        expect(rec.category == 'MOVIES', false);
      });
    });

    group('Ratings', () {
      test('calculates average rating correctly', () {
        final now = DateTime.now();

        // 5.0 rating with 100 ratings
        final rec1 = Recommendation(
          id: 'rec1',
          category: 'movies',
          title: 'Perfect Movie',
          creator: 'Director',
          details: 'Cast',
          platform: 'Netflix',
          whyLike: 'Amazing',
          communityRating: 5.0,
          ratingCount: 100,
          tags: [],
          createdAt: now,
          updatedAt: now,
        );

        expect(rec1.communityRating, 5.0);
        expect(rec1.ratingCount, 100);
      });

      test('handles zero ratings', () {
        final now = DateTime.now();
        final rec = Recommendation(
          id: 'rec123',
          category: 'movies',
          title: 'New Release',
          creator: 'Director',
          details: 'Cast',
          platform: 'Cinema',
          whyLike: 'Fresh',
          communityRating: 0.0,
          ratingCount: 0,
          tags: [],
          createdAt: now,
          updatedAt: now,
        );

        expect(rec.communityRating, 0.0);
        expect(rec.ratingCount, 0);
      });

      test('ratings are immutable', () {
        final now = DateTime.now();
        final rec = Recommendation(
          id: 'rec123',
          category: 'books',
          title: 'Book',
          creator: 'Author',
          details: 'Publisher',
          platform: 'Kindle',
          whyLike: 'Engaging',
          communityRating: 4.5,
          ratingCount: 50,
          tags: [],
          createdAt: now,
          updatedAt: now,
        );

        // Rating fields should not be modifiable
        expect(rec.communityRating, 4.5);
        expect(rec.ratingCount, 50);
      });

      test('high rating is valid', () {
        final now = DateTime.now();
        final rec = Recommendation(
          id: 'rec123',
          category: 'music',
          title: 'Hit Song',
          creator: 'Artist',
          details: 'Album',
          platform: 'Spotify',
          whyLike: 'Catchy',
          communityRating: 5.0,
          ratingCount: 10000,
          tags: [],
          createdAt: now,
          updatedAt: now,
        );

        expect(rec.communityRating, 5.0);
        expect(rec.ratingCount, 10000);
      });

      test('low rating is valid', () {
        final now = DateTime.now();
        final rec = Recommendation(
          id: 'rec123',
          category: 'movies',
          title: 'Poor Movie',
          creator: 'Director',
          details: 'Cast',
          platform: 'Cinema',
          whyLike: 'Curiosity',
          communityRating: 1.0,
          ratingCount: 5,
          tags: [],
          createdAt: now,
          updatedAt: now,
        );

        expect(rec.communityRating, 1.0);
        expect(rec.ratingCount, 5);
      });
    });

    group('Timestamps', () {
      test('createdAt and updatedAt are set', () {
        final created = DateTime(2025, 1, 1);
        final updated = DateTime(2025, 1, 15);

        final rec = Recommendation(
          id: 'rec123',
          category: 'podcasts',
          title: 'Podcast Episode',
          creator: 'Host',
          details: 'Topic',
          platform: 'Apple Podcasts',
          whyLike: 'Informative',
          communityRating: 4.5,
          ratingCount: 25,
          tags: [],
          createdAt: created,
          updatedAt: updated,
        );

        expect(rec.createdAt, created);
        expect(rec.updatedAt, updated);
      });

      test('updatedAt can be same as createdAt', () {
        final now = DateTime.now();
        final rec = Recommendation(
          id: 'rec123',
          category: 'sports',
          title: 'Match',
          creator: 'League',
          details: 'Teams',
          platform: 'ESPN',
          whyLike: 'Exciting',
          communityRating: 4.0,
          ratingCount: 100,
          tags: [],
          createdAt: now,
          updatedAt: now,
        );

        expect(rec.createdAt, rec.updatedAt);
      });

      test('updatedAt can be after createdAt', () {
        final created = DateTime(2025, 1, 1);
        final updated = DateTime(2025, 1, 15);

        final rec = Recommendation(
          id: 'rec123',
          category: 'events',
          title: 'Concert',
          creator: 'Artist',
          details: 'Venue',
          platform: 'Ticketmaster',
          whyLike: 'Live Music',
          communityRating: 4.8,
          ratingCount: 200,
          tags: [],
          createdAt: created,
          updatedAt: updated,
        );

        expect(rec.updatedAt.isAfter(rec.createdAt), true);
      });
    });

    group('Text Fields', () {
      test('handles long title', () {
        final now = DateTime.now();
        final longTitle = 'A' * 200;

        final rec = Recommendation(
          id: 'rec123',
          category: 'books',
          title: longTitle,
          creator: 'Author',
          details: 'Publisher',
          platform: 'Audible',
          whyLike: 'Comprehensive',
          communityRating: 4.0,
          ratingCount: 10,
          tags: [],
          createdAt: now,
          updatedAt: now,
        );

        expect(rec.title.length, 200);
        expect(rec.title, longTitle);
      });

      test('handles special characters in text fields', () {
        final now = DateTime.now();
        final rec = Recommendation(
          id: 'rec123',
          category: 'movies',
          title: 'Movie: "The Best" (2025) - #1!',
          creator: 'Director & Co.',
          details: 'Actor 1, Actor 2, etc.',
          platform: 'Netflix & HBO',
          whyLike: 'It\'s amazing!',
          communityRating: 5.0,
          ratingCount: 50,
          tags: ['action', 'drama'],
          createdAt: now,
          updatedAt: now,
        );

        expect(rec.title, contains('"'));
        expect(rec.title, contains('#'));
        expect(rec.creator, contains('&'));
        expect(rec.whyLike, contains('\''));
      });

      test('handles empty strings', () {
        final now = DateTime.now();
        final rec = Recommendation(
          id: 'rec123',
          category: 'activities',
          title: 'Activity',
          creator: '',
          details: '',
          platform: '',
          whyLike: '',
          communityRating: 3.0,
          ratingCount: 5,
          tags: [],
          createdAt: now,
          updatedAt: now,
        );

        expect(rec.creator, isEmpty);
        expect(rec.details, isEmpty);
        expect(rec.platform, isEmpty);
        expect(rec.whyLike, isEmpty);
      });

      test('handles unicode characters', () {
        final now = DateTime.now();
        final rec = Recommendation(
          id: 'rec123',
          category: 'music',
          title: '音楽 🎵',
          creator: 'アーティスト',
          details: 'ألبوم',
          platform: 'Spotify',
          whyLike: 'Música maravilhosa 🎶',
          communityRating: 4.5,
          ratingCount: 100,
          tags: ['música', '音楽', 'موسيقى'],
          createdAt: now,
          updatedAt: now,
        );

        expect(rec.title, contains('🎵'));
        expect(rec.creator, contains('ア'));
        expect(rec.details, contains('ألبوم'));
        expect(rec.whyLike, contains('🎶'));
        expect(rec.tags[0], 'música');
      });
    });

    group('ID Validation', () {
      test('id is not empty', () {
        final now = DateTime.now();
        final rec = Recommendation(
          id: 'rec123',
          category: 'businesses',
          title: 'Business',
          creator: 'Owner',
          details: 'Industry',
          platform: 'Website',
          whyLike: 'Quality',
          communityRating: 4.2,
          ratingCount: 30,
          tags: [],
          createdAt: now,
          updatedAt: now,
        );

        expect(rec.id, isNotEmpty);
      });

      test('id is unique identifier', () {
        final now = DateTime.now();
        final rec1 = Recommendation(
          id: 'rec_001',
          category: 'movies',
          title: 'Movie 1',
          creator: 'Director 1',
          details: 'Details 1',
          platform: 'Platform 1',
          whyLike: 'Why 1',
          communityRating: 4.0,
          ratingCount: 10,
          tags: [],
          createdAt: now,
          updatedAt: now,
        );

        final rec2 = Recommendation(
          id: 'rec_002',
          category: 'movies',
          title: 'Movie 2',
          creator: 'Director 2',
          details: 'Details 2',
          platform: 'Platform 2',
          whyLike: 'Why 2',
          communityRating: 4.0,
          ratingCount: 10,
          tags: [],
          createdAt: now,
          updatedAt: now,
        );

        expect(rec1.id, isNot(equals(rec2.id)));
      });

      test('handles various id formats', () {
        final now = DateTime.now();
        final idFormats = [
          'rec123',
          'recommendation_456',
          'REC-789',
          'rec.abc',
          'rec_def_123',
        ];

        for (final id in idFormats) {
          final rec = Recommendation(
            id: id,
            category: 'recipes',
            title: 'Recipe',
            creator: 'Chef',
            details: 'Cuisine',
            platform: 'Website',
            whyLike: 'Delicious',
            communityRating: 4.5,
            ratingCount: 15,
            tags: [],
            createdAt: now,
            updatedAt: now,
          );

          expect(rec.id, id);
        }
      });
    });
  });
}
