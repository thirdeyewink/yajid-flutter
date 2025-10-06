// Run this with: node seed_recommendations.js
// Make sure to install: npm install firebase-admin

const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json'); // You'll need to download this from Firebase Console

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

const recommendations = [
  // Movies
  { id: 'movie_1', category: 'movies', title: 'The Dark Knight', creator: 'Christopher Nolan', details: 'Christian Bale, Heath Ledger', platform: 'Netflix', whyLike: 'Based on your love for action movies and superhero themes, this critically acclaimed Batman film offers complex characters and stunning cinematography.', communityRating: 4.8, ratingCount: 1250, tags: ['action', 'superhero', 'thriller'] },
  { id: 'movie_2', category: 'movies', title: 'Inception', creator: 'Christopher Nolan', details: 'Leonardo DiCaprio', platform: 'Prime Video', whyLike: 'A mind-bending thriller that explores dreams within dreams.', communityRating: 4.7, ratingCount: 1180, tags: ['sci-fi', 'thriller'] },

  // Music
  { id: 'music_1', category: 'music', title: 'Bohemian Rhapsody', creator: 'Queen', details: 'Freddie Mercury', platform: 'Spotify', whyLike: 'Classic rock with powerful vocals and innovative compositions.', communityRating: 4.9, ratingCount: 2300, tags: ['rock', 'classic'] },
  { id: 'music_2', category: 'music', title: 'Hotel California', creator: 'Eagles', details: 'Don Henley', platform: 'Apple Music', whyLike: 'An iconic rock masterpiece with unforgettable guitar solos.', communityRating: 4.8, ratingCount: 1950, tags: ['rock', 'classic'] },

  // Books
  { id: 'book_1', category: 'books', title: 'Dune', creator: 'Frank Herbert', details: 'Science Fiction', platform: 'Kindle', whyLike: 'Epic sci-fi with complex world-building and philosophical themes.', communityRating: 4.6, ratingCount: 890, tags: ['sci-fi', 'epic'] },
  { id: 'book_2', category: 'books', title: '1984', creator: 'George Orwell', details: 'Dystopian Fiction', platform: 'Audible', whyLike: 'A thought-provoking dystopian novel.', communityRating: 4.7, ratingCount: 1420, tags: ['dystopian', 'classic'] },

  // TV Shows
  { id: 'tv_1', category: 'tv shows', title: 'Breaking Bad', creator: 'Vince Gilligan', details: 'Bryan Cranston', platform: 'Netflix', whyLike: 'Intense drama with exceptional character development.', communityRating: 4.9, ratingCount: 3200, tags: ['drama', 'crime'] },
  { id: 'tv_2', category: 'tv shows', title: 'Stranger Things', creator: 'Duffer Brothers', details: 'Millie Bobby Brown', platform: 'Netflix', whyLike: 'Nostalgic sci-fi thriller with 80s vibes.', communityRating: 4.6, ratingCount: 2850, tags: ['sci-fi', 'thriller'] },

  // Podcasts
  { id: 'podcast_1', category: 'podcasts', title: 'The Daily', creator: 'New York Times', details: 'Michael Barbaro', platform: 'Spotify', whyLike: 'Daily news analysis and compelling storytelling.', communityRating: 4.5, ratingCount: 670, tags: ['news', 'daily'] },
  { id: 'podcast_2', category: 'podcasts', title: 'How I Built This', creator: 'NPR', details: 'Guy Raz', platform: 'Apple Podcasts', whyLike: 'Inspiring entrepreneurship stories.', communityRating: 4.7, ratingCount: 1240, tags: ['business', 'entrepreneurship'] },

  // Sports
  { id: 'sport_1', category: 'sports', title: 'Premier League: Arsenal vs Chelsea', creator: 'Premier League', details: 'Live Football', platform: 'ESPN+', whyLike: 'Exciting rivalry match with top-tier football.', communityRating: 4.7, ratingCount: 980, tags: ['football', 'live'] },
  { id: 'sport_2', category: 'sports', title: 'NBA Finals Game 7', creator: 'NBA', details: 'Championship Basketball', platform: 'NBA TV', whyLike: 'The ultimate championship showdown.', communityRating: 4.8, ratingCount: 1560, tags: ['basketball', 'nba'] },

  // Video Games
  { id: 'game_1', category: 'videogames', title: 'Zelda: Tears of the Kingdom', creator: 'Nintendo', details: 'Adventure RPG', platform: 'Nintendo Switch', whyLike: 'Expansive open-world adventure with innovative gameplay.', communityRating: 4.9, ratingCount: 2100, tags: ['adventure', 'rpg'] },
  { id: 'game_2', category: 'videogames', title: 'Elden Ring', creator: 'FromSoftware', details: 'Action RPG', platform: 'Multi-platform', whyLike: 'Challenging fantasy adventure with stunning design.', communityRating: 4.7, ratingCount: 1820, tags: ['rpg', 'action'] },

  // Brands
  { id: 'brand_1', category: 'brands', title: 'Patagonia', creator: 'Patagonia', details: 'Sustainable Fashion', platform: 'Online', whyLike: 'High-quality outdoor gear from an eco-conscious brand.', communityRating: 4.6, ratingCount: 720, tags: ['outdoor', 'sustainable'] },
  { id: 'brand_2', category: 'brands', title: 'Apple Products', creator: 'Apple Inc.', details: 'Technology', platform: 'Apple Store', whyLike: 'Premium technology products known for design.', communityRating: 4.5, ratingCount: 3400, tags: ['technology', 'premium'] },

  // Recipes
  { id: 'recipe_1', category: 'recipes', title: 'Margherita Pizza', creator: 'Italian Cuisine', details: 'Mozzarella, Basil', platform: 'AllRecipes', whyLike: 'Simple yet delicious authentic Italian pizza.', communityRating: 4.8, ratingCount: 1340, tags: ['italian', 'pizza'] },
  { id: 'recipe_2', category: 'recipes', title: 'Homemade Sushi', creator: 'Japanese Cuisine', details: 'Fresh Fish, Rice', platform: 'Tasty', whyLike: 'Make restaurant-quality sushi at home.', communityRating: 4.6, ratingCount: 890, tags: ['japanese', 'sushi'] },

  // Events
  { id: 'event_1', category: 'events', title: 'Summer Music Festival 2025', creator: 'City Events', details: 'Live Performances', platform: 'Eventbrite', whyLike: 'Amazing live music from top artists.', communityRating: 4.5, ratingCount: 560, tags: ['music', 'festival'] },
  { id: 'event_2', category: 'events', title: 'Tech Conference 2025', creator: 'Tech Community', details: 'Networking', platform: 'Meetup', whyLike: 'Connect with industry leaders.', communityRating: 4.7, ratingCount: 780, tags: ['technology', 'networking'] },

  // Activities
  { id: 'activity_1', category: 'activities', title: 'Sunset Kayaking', creator: 'Adventure Co', details: 'Outdoor Activity', platform: 'Local Tours', whyLike: 'Explore beautiful waterways during golden hour.', communityRating: 4.7, ratingCount: 420, tags: ['outdoor', 'water-sports'] },
  { id: 'activity_2', category: 'activities', title: 'Rock Climbing', creator: 'Climb Zone', details: 'Indoor & Outdoor', platform: 'GetYourGuide', whyLike: 'Guided climbing for all skill levels.', communityRating: 4.6, ratingCount: 550, tags: ['outdoor', 'adventure'] },

  // Businesses
  { id: 'business_1', category: 'businesses', title: 'TechStart Coworking', creator: 'TechStart', details: 'Coworking Space', platform: 'Local Directory', whyLike: 'Modern space with great amenities for entrepreneurs.', communityRating: 4.4, ratingCount: 280, tags: ['coworking', 'business'] },
  { id: 'business_2', category: 'businesses', title: 'Cloud Kitchen Solutions', creator: 'FoodTech Inc', details: 'Restaurant Services', platform: 'Business Directory', whyLike: 'Professional kitchen facilities for food entrepreneurs.', communityRating: 4.5, ratingCount: 340, tags: ['food', 'business'] },
];

async function seedRecommendations() {
  try {
    const batch = db.batch();
    const now = admin.firestore.Timestamp.now();

    recommendations.forEach(rec => {
      const docRef = db.collection('recommendations').doc(rec.id);
      batch.set(docRef, {
        ...rec,
        createdAt: now,
        updatedAt: now
      });
    });

    await batch.commit();
    console.log('✅ Successfully seeded', recommendations.length, 'recommendations!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error seeding recommendations:', error);
    process.exit(1);
  }
}

seedRecommendations();
