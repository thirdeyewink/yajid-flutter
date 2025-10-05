// ignore_for_file: avoid_print

import 'package:firebase_core/firebase_core.dart';
import 'package:yajid/firebase_options.dart';
import 'package:yajid/models/recommendation_model.dart';
import 'package:yajid/services/recommendation_service.dart';

/// Seed script to populate Firestore with initial recommendation data
///
/// To run this script:
/// 1. Make sure Firebase is configured
/// 2. Run: dart lib/scripts/seed_recommendations.dart
///
/// WARNING: This will add data to your Firestore database
Future<void> main() async {
  print('🌱 Starting recommendation seed script...\n');

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized\n');
  } catch (e) {
    print('❌ Error initializing Firebase: $e');
    return;
  }

  final service = RecommendationService();
  final now = DateTime.now();

  // Seed data
  final List<Recommendation> recommendations = [
    // Movies
    Recommendation(
      id: 'movie_1',
      category: 'movies',
      title: 'The Dark Knight',
      creator: 'Christopher Nolan',
      details: 'Christian Bale, Heath Ledger',
      platform: 'Netflix',
      whyLike: 'Based on your love for action movies and superhero themes, this critically acclaimed Batman film offers complex characters and stunning cinematography.',
      communityRating: 4.8,
      ratingCount: 1250,
      tags: ['action', 'superhero', 'thriller'],
      createdAt: now,
      updatedAt: now,
    ),
    Recommendation(
      id: 'movie_2',
      category: 'movies',
      title: 'Inception',
      creator: 'Christopher Nolan',
      details: 'Leonardo DiCaprio, Tom Hardy',
      platform: 'Prime Video',
      whyLike: 'A mind-bending thriller that explores dreams within dreams with stunning visuals and an intricate plot.',
      communityRating: 4.7,
      ratingCount: 1180,
      tags: ['sci-fi', 'thriller', 'mind-bending'],
      createdAt: now,
      updatedAt: now,
    ),

    // Music
    Recommendation(
      id: 'music_1',
      category: 'music',
      title: 'Bohemian Rhapsody',
      creator: 'Queen',
      details: 'Freddie Mercury, Brian May',
      platform: 'Spotify',
      whyLike: 'Your music preferences suggest you enjoy classic rock with powerful vocals and innovative compositions.',
      communityRating: 4.9,
      ratingCount: 2300,
      tags: ['rock', 'classic', 'queen'],
      createdAt: now,
      updatedAt: now,
    ),
    Recommendation(
      id: 'music_2',
      category: 'music',
      title: 'Hotel California',
      creator: 'Eagles',
      details: 'Don Henley, Glenn Frey',
      platform: 'Apple Music',
      whyLike: 'An iconic rock masterpiece with haunting lyrics and unforgettable guitar solos.',
      communityRating: 4.8,
      ratingCount: 1950,
      tags: ['rock', 'classic', '70s'],
      createdAt: now,
      updatedAt: now,
    ),

    // Books
    Recommendation(
      id: 'book_1',
      category: 'books',
      title: 'Dune',
      creator: 'Frank Herbert',
      details: 'Science Fiction Classic',
      platform: 'Kindle',
      whyLike: 'Given your interest in complex world-building and philosophical themes, this epic sci-fi novel will captivate you.',
      communityRating: 4.6,
      ratingCount: 890,
      tags: ['sci-fi', 'epic', 'philosophy'],
      createdAt: now,
      updatedAt: now,
    ),
    Recommendation(
      id: 'book_2',
      category: 'books',
      title: '1984',
      creator: 'George Orwell',
      details: 'Dystopian Fiction',
      platform: 'Audible',
      whyLike: 'A thought-provoking dystopian novel that remains eerily relevant to modern society.',
      communityRating: 4.7,
      ratingCount: 1420,
      tags: ['dystopian', 'classic', 'philosophy'],
      createdAt: now,
      updatedAt: now,
    ),

    // TV Shows
    Recommendation(
      id: 'tv_1',
      category: 'tv shows',
      title: 'Breaking Bad',
      creator: 'Vince Gilligan',
      details: 'Bryan Cranston, Aaron Paul',
      platform: 'Netflix',
      whyLike: 'An intense drama with exceptional character development and gripping storytelling.',
      communityRating: 4.9,
      ratingCount: 3200,
      tags: ['drama', 'crime', 'intense'],
      createdAt: now,
      updatedAt: now,
    ),
    Recommendation(
      id: 'tv_2',
      category: 'tv shows',
      title: 'Stranger Things',
      creator: 'Duffer Brothers',
      details: 'Millie Bobby Brown, Finn Wolfhard',
      platform: 'Netflix',
      whyLike: 'A nostalgic sci-fi thriller with great characters and 80s vibes.',
      communityRating: 4.6,
      ratingCount: 2850,
      tags: ['sci-fi', 'thriller', '80s'],
      createdAt: now,
      updatedAt: now,
    ),

    // Podcasts
    Recommendation(
      id: 'podcast_1',
      category: 'podcasts',
      title: 'The Daily',
      creator: 'The New York Times',
      details: 'Michael Barbaro',
      platform: 'Spotify',
      whyLike: 'Stay informed with daily news analysis and compelling storytelling.',
      communityRating: 4.5,
      ratingCount: 670,
      tags: ['news', 'daily', 'journalism'],
      createdAt: now,
      updatedAt: now,
    ),
    Recommendation(
      id: 'podcast_2',
      category: 'podcasts',
      title: 'How I Built This',
      creator: 'NPR',
      details: 'Guy Raz',
      platform: 'Apple Podcasts',
      whyLike: 'Inspiring entrepreneurship stories from founders of famous companies.',
      communityRating: 4.7,
      ratingCount: 1240,
      tags: ['business', 'entrepreneurship', 'inspiration'],
      createdAt: now,
      updatedAt: now,
    ),

    // Sports
    Recommendation(
      id: 'sport_1',
      category: 'sports',
      title: 'Premier League Match: Arsenal vs Chelsea',
      creator: 'Premier League',
      details: 'Live Football',
      platform: 'ESPN+',
      whyLike: 'Catch the exciting rivalry match with top-tier football action.',
      communityRating: 4.7,
      ratingCount: 980,
      tags: ['football', 'premier-league', 'live'],
      createdAt: now,
      updatedAt: now,
    ),
    Recommendation(
      id: 'sport_2',
      category: 'sports',
      title: 'NBA Finals Game 7',
      creator: 'NBA',
      details: 'Championship Basketball',
      platform: 'NBA TV',
      whyLike: 'The ultimate showdown for the championship title.',
      communityRating: 4.8,
      ratingCount: 1560,
      tags: ['basketball', 'nba', 'championship'],
      createdAt: now,
      updatedAt: now,
    ),

    // Video Games
    Recommendation(
      id: 'game_1',
      category: 'videogames',
      title: 'The Legend of Zelda: Tears of the Kingdom',
      creator: 'Nintendo',
      details: 'Adventure RPG',
      platform: 'Nintendo Switch',
      whyLike: 'An expansive open-world adventure with innovative gameplay mechanics.',
      communityRating: 4.9,
      ratingCount: 2100,
      tags: ['adventure', 'rpg', 'open-world'],
      createdAt: now,
      updatedAt: now,
    ),
    Recommendation(
      id: 'game_2',
      category: 'videogames',
      title: 'Elden Ring',
      creator: 'FromSoftware',
      details: 'Action RPG',
      platform: 'Multi-platform',
      whyLike: 'A challenging yet rewarding fantasy adventure with stunning world design.',
      communityRating: 4.7,
      ratingCount: 1820,
      tags: ['rpg', 'action', 'challenging'],
      createdAt: now,
      updatedAt: now,
    ),

    // Brands
    Recommendation(
      id: 'brand_1',
      category: 'brands',
      title: 'Patagonia Outdoor Gear',
      creator: 'Patagonia',
      details: 'Sustainable Fashion',
      platform: 'Online Store',
      whyLike: 'High-quality outdoor gear from an environmentally conscious brand.',
      communityRating: 4.6,
      ratingCount: 720,
      tags: ['outdoor', 'sustainable', 'quality'],
      createdAt: now,
      updatedAt: now,
    ),
    Recommendation(
      id: 'brand_2',
      category: 'brands',
      title: 'Apple Products',
      creator: 'Apple Inc.',
      details: 'Technology & Innovation',
      platform: 'Apple Store',
      whyLike: 'Premium technology products known for design and user experience.',
      communityRating: 4.5,
      ratingCount: 3400,
      tags: ['technology', 'premium', 'innovation'],
      createdAt: now,
      updatedAt: now,
    ),

    // Recipes
    Recommendation(
      id: 'recipe_1',
      category: 'recipes',
      title: 'Classic Margherita Pizza',
      creator: 'Italian Cuisine',
      details: 'Fresh Mozzarella, Basil, Tomatoes',
      platform: 'AllRecipes',
      whyLike: 'A simple yet delicious authentic Italian pizza recipe.',
      communityRating: 4.8,
      ratingCount: 1340,
      tags: ['italian', 'pizza', 'easy'],
      createdAt: now,
      updatedAt: now,
    ),
    Recommendation(
      id: 'recipe_2',
      category: 'recipes',
      title: 'Homemade Sushi Rolls',
      creator: 'Japanese Cuisine',
      details: 'Fresh Fish, Rice, Nori',
      platform: 'Tasty',
      whyLike: 'Learn to make restaurant-quality sushi at home.',
      communityRating: 4.6,
      ratingCount: 890,
      tags: ['japanese', 'sushi', 'seafood'],
      createdAt: now,
      updatedAt: now,
    ),

    // Events
    Recommendation(
      id: 'event_1',
      category: 'events',
      title: 'Summer Music Festival 2025',
      creator: 'City Events',
      details: 'Live Performances',
      platform: 'Eventbrite',
      whyLike: 'Experience amazing live music from top artists in your area.',
      communityRating: 4.5,
      ratingCount: 560,
      tags: ['music', 'festival', 'live'],
      createdAt: now,
      updatedAt: now,
    ),
    Recommendation(
      id: 'event_2',
      category: 'events',
      title: 'Tech Conference 2025',
      creator: 'Tech Community',
      details: 'Networking & Innovation',
      platform: 'Meetup',
      whyLike: 'Connect with industry leaders and learn about cutting-edge technology.',
      communityRating: 4.7,
      ratingCount: 780,
      tags: ['technology', 'networking', 'conference'],
      createdAt: now,
      updatedAt: now,
    ),

    // Activities
    Recommendation(
      id: 'activity_1',
      category: 'activities',
      title: 'Sunset Kayaking Tour',
      creator: 'Adventure Co',
      details: 'Outdoor Activity',
      platform: 'Local Tours',
      whyLike: 'Explore beautiful waterways during golden hour.',
      communityRating: 4.7,
      ratingCount: 420,
      tags: ['outdoor', 'water-sports', 'sunset'],
      createdAt: now,
      updatedAt: now,
    ),
    Recommendation(
      id: 'activity_2',
      category: 'activities',
      title: 'Rock Climbing Experience',
      creator: 'Climb Zone',
      details: 'Indoor & Outdoor Climbing',
      platform: 'GetYourGuide',
      whyLike: 'Challenge yourself with guided rock climbing for all skill levels.',
      communityRating: 4.6,
      ratingCount: 550,
      tags: ['outdoor', 'adventure', 'fitness'],
      createdAt: now,
      updatedAt: now,
    ),

    // Businesses
    Recommendation(
      id: 'business_1',
      category: 'businesses',
      title: 'TechStart Coworking Space',
      creator: 'TechStart',
      details: 'Business Services',
      platform: 'Local Directory',
      whyLike: 'Modern coworking space with great amenities for entrepreneurs.',
      communityRating: 4.4,
      ratingCount: 280,
      tags: ['coworking', 'business', 'startup'],
      createdAt: now,
      updatedAt: now,
    ),
    Recommendation(
      id: 'business_2',
      category: 'businesses',
      title: 'Cloud Kitchen Solutions',
      creator: 'FoodTech Inc',
      details: 'Restaurant Services',
      platform: 'Business Directory',
      whyLike: 'Professional kitchen facilities for food entrepreneurs and delivery services.',
      communityRating: 4.5,
      ratingCount: 340,
      tags: ['food', 'business', 'kitchen'],
      createdAt: now,
      updatedAt: now,
    ),
  ];

  // Add recommendations to Firestore
  int successCount = 0;
  int failCount = 0;

  print('📝 Adding ${recommendations.length} recommendations to Firestore...\n');

  for (final rec in recommendations) {
    final success = await service.addRecommendation(rec);
    if (success) {
      successCount++;
      print('✅ Added: ${rec.title} (${rec.category})');
    } else {
      failCount++;
      print('❌ Failed: ${rec.title} (${rec.category})');
    }
  }

  print('\n${'=' * 50}');
  print('✨ Seed script completed!');
  print('Success: $successCount');
  print('Failed: $failCount');
  print('=' * 50);
}
