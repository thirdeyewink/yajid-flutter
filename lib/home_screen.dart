import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yajid/screens/chat_list_screen.dart';
import 'package:yajid/screens/notifications_screen.dart';
import 'package:yajid/l10n/app_localizations.dart';
import 'package:yajid/services/user_profile_service.dart';
import 'package:yajid/theme/app_theme.dart';
import 'package:yajid/bloc/gamification/gamification_bloc.dart';
import 'package:yajid/bloc/gamification/gamification_event.dart';
import 'package:yajid/bloc/gamification/gamification_state.dart';
import 'package:yajid/widgets/gamification/points_display_widget.dart';
import 'package:yajid/models/gamification/points_model.dart';
import 'package:yajid/services/recommendation_service.dart';
import 'package:yajid/models/recommendation_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'all';
  List<String> _userCategories = [];
  String _userName = 'User';
  final UserProfileService _profileService = UserProfileService();
  final RecommendationService _recommendationService = RecommendationService();
  late GamificationBloc _gamificationBloc;
  bool _isLoading = true;
  bool _isLoadingRecommendations = false;
  String? _errorMessage;

  // Recommendations from Firestore
  List<Recommendation> _recommendations = [];

  // UI state for recommendations (not persisted)
  final Map<String, bool> _expandedStates = {};
  final Map<String, double> _userRatings = {};
  final Map<String, bool> _bookmarkedStates = {};

  // REMOVED: Hardcoded recommendations - now loaded from Firestore
  // Old data structure kept for reference during migration

  @override
  void initState() {
    super.initState();
    _gamificationBloc = GamificationBloc();
    _loadUserData();
    _initializeGamification();
    _generateRecommendations();
  }

  Future<void> _generateRecommendations() async {
    setState(() {
      _isLoadingRecommendations = true;
      _errorMessage = null;
    });

    try {
      // Fetch random recommendations from Firestore (one from each category)
      final recommendations = await _recommendationService.getRandomRecommendations();

      // If no recommendations found, auto-seed data
      if (recommendations.isEmpty) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Loading sample recommendations...';
          });
        }

        // Automatically seed data in background
        final seeded = await _autoSeedRecommendations();

        if (!seeded) {
          if (mounted) {
            setState(() {
              _recommendations = [];
              _errorMessage = 'Failed to load recommendations. Please check your internet connection.';
              _isLoadingRecommendations = false;
            });
          }
          return;
        }

        // Try loading again after seeding
        final newRecommendations = await _recommendationService.getRandomRecommendations();
        if (mounted) {
          setState(() {
            _recommendations = newRecommendations;
            _isLoadingRecommendations = false;
          });
        }
        return;
      }

      if (mounted) {
        setState(() {
          _recommendations = recommendations;
          _isLoadingRecommendations = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load recommendations: $e';
          _isLoadingRecommendations = false;
        });
      }
    }
  }

  /// Automatically seed recommendations data when collection is empty
  Future<bool> _autoSeedRecommendations() async {
    try {
      final now = DateTime.now();
      final seedData = _getQuickSeedData(now);

      // Add all recommendations in parallel for faster seeding
      final futures = seedData.map((rec) => _recommendationService.addRecommendation(rec)).toList();
      final results = await Future.wait(futures);

      // Check if at least 80% succeeded
      final successCount = results.where((r) => r).length;
      return successCount >= (seedData.length * 0.8);
    } catch (e) {
      return false;
    }
  }

  /// Get minimal seed data (2 items per category for fast auto-seeding)
  List<Recommendation> _getQuickSeedData(DateTime now) {
    return [
      // Movies
      Recommendation(id: 'movie_1', category: 'movies', title: 'The Dark Knight', creator: 'Christopher Nolan', details: 'Christian Bale, Heath Ledger', platform: 'Netflix', whyLike: 'Based on your love for action movies and superhero themes, this critically acclaimed Batman film offers complex characters and stunning cinematography.', communityRating: 4.8, ratingCount: 1250, tags: ['action', 'superhero', 'thriller'], createdAt: now, updatedAt: now),
      Recommendation(id: 'movie_2', category: 'movies', title: 'Inception', creator: 'Christopher Nolan', details: 'Leonardo DiCaprio', platform: 'Prime Video', whyLike: 'A mind-bending thriller that explores dreams within dreams.', communityRating: 4.7, ratingCount: 1180, tags: ['sci-fi', 'thriller'], createdAt: now, updatedAt: now),

      // Music
      Recommendation(id: 'music_1', category: 'music', title: 'Bohemian Rhapsody', creator: 'Queen', details: 'Freddie Mercury', platform: 'Spotify', whyLike: 'Classic rock with powerful vocals and innovative compositions.', communityRating: 4.9, ratingCount: 2300, tags: ['rock', 'classic'], createdAt: now, updatedAt: now),
      Recommendation(id: 'music_2', category: 'music', title: 'Hotel California', creator: 'Eagles', details: 'Don Henley', platform: 'Apple Music', whyLike: 'An iconic rock masterpiece with unforgettable guitar solos.', communityRating: 4.8, ratingCount: 1950, tags: ['rock', 'classic'], createdAt: now, updatedAt: now),

      // Books
      Recommendation(id: 'book_1', category: 'books', title: 'Dune', creator: 'Frank Herbert', details: 'Science Fiction', platform: 'Kindle', whyLike: 'Epic sci-fi with complex world-building and philosophical themes.', communityRating: 4.6, ratingCount: 890, tags: ['sci-fi', 'epic'], createdAt: now, updatedAt: now),
      Recommendation(id: 'book_2', category: 'books', title: '1984', creator: 'George Orwell', details: 'Dystopian Fiction', platform: 'Audible', whyLike: 'A thought-provoking dystopian novel.', communityRating: 4.7, ratingCount: 1420, tags: ['dystopian', 'classic'], createdAt: now, updatedAt: now),

      // TV Shows
      Recommendation(id: 'tv_1', category: 'tv shows', title: 'Breaking Bad', creator: 'Vince Gilligan', details: 'Bryan Cranston', platform: 'Netflix', whyLike: 'Intense drama with exceptional character development.', communityRating: 4.9, ratingCount: 3200, tags: ['drama', 'crime'], createdAt: now, updatedAt: now),
      Recommendation(id: 'tv_2', category: 'tv shows', title: 'Stranger Things', creator: 'Duffer Brothers', details: 'Millie Bobby Brown', platform: 'Netflix', whyLike: 'Nostalgic sci-fi thriller with 80s vibes.', communityRating: 4.6, ratingCount: 2850, tags: ['sci-fi', 'thriller'], createdAt: now, updatedAt: now),

      // Podcasts
      Recommendation(id: 'podcast_1', category: 'podcasts', title: 'The Daily', creator: 'New York Times', details: 'Michael Barbaro', platform: 'Spotify', whyLike: 'Daily news analysis and compelling storytelling.', communityRating: 4.5, ratingCount: 670, tags: ['news', 'daily'], createdAt: now, updatedAt: now),
      Recommendation(id: 'podcast_2', category: 'podcasts', title: 'How I Built This', creator: 'NPR', details: 'Guy Raz', platform: 'Apple Podcasts', whyLike: 'Inspiring entrepreneurship stories.', communityRating: 4.7, ratingCount: 1240, tags: ['business', 'entrepreneurship'], createdAt: now, updatedAt: now),

      // Sports
      Recommendation(id: 'sport_1', category: 'sports', title: 'Premier League: Arsenal vs Chelsea', creator: 'Premier League', details: 'Live Football', platform: 'ESPN+', whyLike: 'Exciting rivalry match with top-tier football.', communityRating: 4.7, ratingCount: 980, tags: ['football', 'live'], createdAt: now, updatedAt: now),
      Recommendation(id: 'sport_2', category: 'sports', title: 'NBA Finals Game 7', creator: 'NBA', details: 'Championship Basketball', platform: 'NBA TV', whyLike: 'The ultimate championship showdown.', communityRating: 4.8, ratingCount: 1560, tags: ['basketball', 'nba'], createdAt: now, updatedAt: now),

      // Video Games
      Recommendation(id: 'game_1', category: 'videogames', title: 'Zelda: Tears of the Kingdom', creator: 'Nintendo', details: 'Adventure RPG', platform: 'Nintendo Switch', whyLike: 'Expansive open-world adventure with innovative gameplay.', communityRating: 4.9, ratingCount: 2100, tags: ['adventure', 'rpg'], createdAt: now, updatedAt: now),
      Recommendation(id: 'game_2', category: 'videogames', title: 'Elden Ring', creator: 'FromSoftware', details: 'Action RPG', platform: 'Multi-platform', whyLike: 'Challenging fantasy adventure with stunning design.', communityRating: 4.7, ratingCount: 1820, tags: ['rpg', 'action'], createdAt: now, updatedAt: now),

      // Brands
      Recommendation(id: 'brand_1', category: 'brands', title: 'Patagonia', creator: 'Patagonia', details: 'Sustainable Fashion', platform: 'Online', whyLike: 'High-quality outdoor gear from an eco-conscious brand.', communityRating: 4.6, ratingCount: 720, tags: ['outdoor', 'sustainable'], createdAt: now, updatedAt: now),
      Recommendation(id: 'brand_2', category: 'brands', title: 'Apple Products', creator: 'Apple Inc.', details: 'Technology', platform: 'Apple Store', whyLike: 'Premium technology products known for design.', communityRating: 4.5, ratingCount: 3400, tags: ['technology', 'premium'], createdAt: now, updatedAt: now),

      // Recipes
      Recommendation(id: 'recipe_1', category: 'recipes', title: 'Margherita Pizza', creator: 'Italian Cuisine', details: 'Mozzarella, Basil', platform: 'AllRecipes', whyLike: 'Simple yet delicious authentic Italian pizza.', communityRating: 4.8, ratingCount: 1340, tags: ['italian', 'pizza'], createdAt: now, updatedAt: now),
      Recommendation(id: 'recipe_2', category: 'recipes', title: 'Homemade Sushi', creator: 'Japanese Cuisine', details: 'Fresh Fish, Rice', platform: 'Tasty', whyLike: 'Make restaurant-quality sushi at home.', communityRating: 4.6, ratingCount: 890, tags: ['japanese', 'sushi'], createdAt: now, updatedAt: now),

      // Events
      Recommendation(id: 'event_1', category: 'events', title: 'Summer Music Festival 2025', creator: 'City Events', details: 'Live Performances', platform: 'Eventbrite', whyLike: 'Amazing live music from top artists.', communityRating: 4.5, ratingCount: 560, tags: ['music', 'festival'], createdAt: now, updatedAt: now),
      Recommendation(id: 'event_2', category: 'events', title: 'Tech Conference 2025', creator: 'Tech Community', details: 'Networking', platform: 'Meetup', whyLike: 'Connect with industry leaders.', communityRating: 4.7, ratingCount: 780, tags: ['technology', 'networking'], createdAt: now, updatedAt: now),

      // Activities
      Recommendation(id: 'activity_1', category: 'activities', title: 'Sunset Kayaking', creator: 'Adventure Co', details: 'Outdoor Activity', platform: 'Local Tours', whyLike: 'Explore beautiful waterways during golden hour.', communityRating: 4.7, ratingCount: 420, tags: ['outdoor', 'water-sports'], createdAt: now, updatedAt: now),
      Recommendation(id: 'activity_2', category: 'activities', title: 'Rock Climbing', creator: 'Climb Zone', details: 'Indoor & Outdoor', platform: 'GetYourGuide', whyLike: 'Guided climbing for all skill levels.', communityRating: 4.6, ratingCount: 550, tags: ['outdoor', 'adventure'], createdAt: now, updatedAt: now),

      // Businesses
      Recommendation(id: 'business_1', category: 'businesses', title: 'TechStart Coworking', creator: 'TechStart', details: 'Coworking Space', platform: 'Local Directory', whyLike: 'Modern space with great amenities for entrepreneurs.', communityRating: 4.4, ratingCount: 280, tags: ['coworking', 'business'], createdAt: now, updatedAt: now),
      Recommendation(id: 'business_2', category: 'businesses', title: 'Cloud Kitchen Solutions', creator: 'FoodTech Inc', details: 'Restaurant Services', platform: 'Business Directory', whyLike: 'Professional kitchen facilities for food entrepreneurs.', communityRating: 4.5, ratingCount: 340, tags: ['food', 'business'], createdAt: now, updatedAt: now),
    ];
  }

  void _initializeGamification() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      _gamificationBloc.add(LoadGamificationData(userId));
      _checkDailyLogin(userId);
    }
  }

  Future<void> _checkDailyLogin(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastLoginDate = prefs.getString('last_login_date');
      final today = DateTime.now().toIso8601String().substring(0, 10); // YYYY-MM-DD

      if (lastLoginDate != today) {
        // Award points for daily login
        _gamificationBloc.add(AwardPoints(
          userId: userId,
          points: 10,
          category: PointsCategory.dailyLogin,
          description: 'Daily login bonus',
        ));

        // Save today's date
        await prefs.setString('last_login_date', today);
      }
    } catch (e) {
      // Silently fail - not critical
    }
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load user's name from profile service first, then Firebase Auth as fallback
      try {
        final profileData = await _profileService.getUserProfile();
        if (profileData != null && profileData['displayName'] != null && profileData['displayName'].isNotEmpty) {
          if (mounted) {
            setState(() {
              _userName = profileData['displayName'].split(' ').first; // First name only
            });
          }
        } else {
          // Fallback to Firebase Auth
          final user = FirebaseAuth.instance.currentUser;
          if (user != null && user.displayName != null) {
            if (mounted) {
              setState(() {
                _userName = user.displayName!.split(' ').first; // First name only
              });
            }
          }
        }
      } catch (e) {
        // Fallback to Firebase Auth if profile service fails
        final user = FirebaseAuth.instance.currentUser;
        if (user != null && user.displayName != null) {
          if (mounted) {
            setState(() {
              _userName = user.displayName!.split(' ').first; // First name only
            });
          }
        }
      }

      // Load user's categories from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final categories = prefs.getStringList('looking_for') ?? [];
      if (mounted) {
        setState(() {
          _userCategories = ['all', ...categories];
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _gamificationBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.screenBackground,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.black,
          elevation: 1,
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left section: Logo
                  AppTheme.buildLogo(size: 55.0),

                  // Center section: Gamification points display (centered)
                  Expanded(
                    child: Center(
                      child: BlocBuilder<GamificationBloc, GamificationState>(
                        bloc: _gamificationBloc,
                        buildWhen: (previous, current) {
                          // Rebuild whenever state changes to GamificationLoaded
                          return current is GamificationLoaded || current is GamificationLoading;
                        },
                        builder: (context, state) {
                          if (state is GamificationLoaded) {
                            return PointsDisplayWidget(
                              userPoints: state.userPoints,
                              userLevel: state.userLevel,
                              compact: true,
                            );
                          }
                          if (state is GamificationLoading) {
                            return const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            );
                          }
                          // Default/fallback display
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.yellow, width: 1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.stars, color: Colors.yellow, size: 16),
                                const SizedBox(width: 4),
                                const Text(
                                  '000',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.yellow,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text(
                                    'Lv 1',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Right section: Notifications and Inbox icons
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.mail_outline, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ChatListScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top section with For You and user name
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                    const SizedBox(height: 20),
                    // Hi User greeting with filter and refresh
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.hiUser(_userName),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.filter_list, size: 28),
                              onSelected: (String value) {
                                setState(() {
                                  _selectedCategory = value;
                                });
                              },
                              itemBuilder: (BuildContext context) {
                                return _userCategories.map<PopupMenuItem<String>>((String category) {
                                  return PopupMenuItem<String>(
                                    value: category,
                                    child: Row(
                                      children: [
                                        if (category == _selectedCategory)
                                          const Icon(Icons.check, size: 16, color: Colors.blue),
                                        if (category == _selectedCategory)
                                          const SizedBox(width: 8),
                                        Text(_getLocalizedCategoryName(category)),
                                      ],
                                    ),
                                  );
                                }).toList();
                              },
                            ),
                            IconButton(
                              icon: _isLoadingRecommendations
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.refresh, size: 28),
                              onPressed: _isLoadingRecommendations ? null : _generateRecommendations,
                              tooltip: 'Refresh recommendations',
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // "We think you might like" text
                    Text(
                      AppLocalizations.of(context)!.youMightLike,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),


              const SizedBox(height: 16),

              // Recommendations carousel with loading and error states
              Expanded(
                child: _buildRecommendationsView(),
              ),
            ],
          ),

              ],
            ),
    );
  }

  Widget _buildRecommendationsView() {
    // Show error state
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _generateRecommendations,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Show loading state
    if (_isLoadingRecommendations) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Show empty state (shouldn't happen with auto-seeding, but just in case)
    final filteredRecommendations = _getFilteredRecommendations();
    if (filteredRecommendations.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'No recommendations for this category',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              const Text(
                'Try selecting "All" or a different category',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedCategory = 'all';
                  });
                },
                icon: const Icon(Icons.apps),
                label: const Text('Show All Categories'),
              ),
            ],
          ),
        ),
      );
    }

    // Show recommendations carousel
    return PageView.builder(
      itemCount: filteredRecommendations.length,
      itemBuilder: (context, index) {
        final recommendation = filteredRecommendations[index];
        return _buildRecommendationCard(recommendation, index);
      },
    );
  }

  String _getLocalizedCategoryName(String category) {
    switch (category) {
      case 'all':
        return 'All';
      case 'movies':
        return AppLocalizations.of(context)!.movies;
      case 'music':
        return AppLocalizations.of(context)!.music;
      case 'tv shows':
        return AppLocalizations.of(context)!.tvShows;
      case 'podcasts':
        return AppLocalizations.of(context)!.podcasts;
      case 'sports':
        return AppLocalizations.of(context)!.sports;
      case 'books':
        return AppLocalizations.of(context)!.books;
      case 'videogames':
        return AppLocalizations.of(context)!.videogames;
      case 'brands':
        return AppLocalizations.of(context)!.brands;
      case 'recipes':
        return AppLocalizations.of(context)!.recipes;
      case 'events':
        return AppLocalizations.of(context)!.events;
      case 'activities':
        return AppLocalizations.of(context)!.activities;
      case 'businesses':
        return AppLocalizations.of(context)!.businesses;
      default:
        return category;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'movies':
        return Colors.red;
      case 'music':
        return Colors.purple;
      case 'tv shows':
        return Colors.orange;
      case 'podcasts':
        return Colors.green;
      case 'sports':
        return Colors.blue;
      case 'books':
        return Colors.brown;
      case 'videogames':
        return Colors.indigo;
      case 'brands':
        return Colors.pink;
      case 'recipes':
        return Colors.amber;
      case 'events':
        return Colors.teal;
      case 'activities':
        return Colors.lime;
      case 'businesses':
        return Colors.cyan;
      default:
        return Colors.grey;
    }
  }

  List<Recommendation> _getFilteredRecommendations() {
    if (_selectedCategory == 'all') {
      return _recommendations;
    }
    return _recommendations.where((rec) => rec.category == _selectedCategory).toList();
  }

  Widget _buildRecommendationCard(Recommendation recommendation, int index) {
    final categoryColor = _getCategoryColor(recommendation.category);
    final isExpanded = _expandedStates[recommendation.id] ?? false;
    final userRating = _userRatings[recommendation.id] ?? 0.0;
    final isBookmarked = _bookmarkedStates[recommendation.id] ?? false;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category tag with different colors - elevated
              Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getLocalizedCategoryName(recommendation.category),
                    style: TextStyle(
                      color: Color.lerp(categoryColor, Colors.black, 0.3)!,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Title
              Text(
                recommendation.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // Creator (Director/Author/Artist)
              Text(
                'By ${recommendation.creator}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 4),

              // Details (Actors/Genre/Description)
              Text(
                recommendation.details,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 8),

              // Platform
              Row(
                children: [
                  Icon(Icons.play_circle_outline, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    'Available on ${recommendation.platform}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Expandable "Why you might like it" section
              _buildExpandableSection(recommendation, isExpanded),

              // Spacer to push ratings and bookmark to bottom
              const Spacer(),

              // Bottom section with ratings and bookmark
              Column(
                children: [
                  // Community rating
                  Row(
                    children: [
                      const Text(
                        'Community Rating: ',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      _buildStarRating(recommendation.communityRating, false, recommendation.id),
                      const SizedBox(width: 8),
                      Text(
                        '(${recommendation.communityRating.toStringAsFixed(1)})',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // User rating
                  Row(
                    children: [
                      const Text(
                        'Your Rating: ',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      _buildStarRating(userRating, true, recommendation.id),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Bookmark button - elevated
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _toggleBookmark(index),
                      icon: Icon(
                        isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      ),
                      label: Text(
                        isBookmarked ? 'Remove from Bookmarks' : 'Add to Bookmarks',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isBookmarked ? Colors.orange : Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableSection(Recommendation recommendation, bool isExpanded) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _expandedStates[recommendation.id] = !isExpanded;
            });
          },
          child: Row(
            children: [
              const Text(
                'Why you might like it',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
              ),
              const Spacer(),
              Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
              ),
            ],
          ),
        ),
        if (isExpanded) ...[
          const SizedBox(height: 8),
          Text(
            recommendation.whyLike,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStarRating(double rating, bool isInteractive, String recommendationId) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (starIndex) {
        return GestureDetector(
          onTap: isInteractive ? () => _updateUserRating(recommendationId, starIndex + 1.0) : null,
          child: Icon(
            starIndex < rating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 20,
          ),
        );
      }),
    );
  }

  void _updateUserRating(String recommendationId, double rating) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    // Find the recommendation by id
    final recommendation = _recommendations.firstWhere(
      (rec) => rec.id == recommendationId,
      orElse: () => _recommendations.first,
    );

    // Update UI state first
    setState(() {
      _userRatings[recommendationId] = rating;
    });

    // Save rating to Firestore and remove from home screen
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('rated')
          .doc(recommendation.id)
          .set({
        'recommendationId': recommendation.id,
        'title': recommendation.title,
        'description': recommendation.whyLike,
        'category': recommendation.category,
        'tags': recommendation.tags,
        'communityRating': recommendation.communityRating,
        'userRating': rating,
        'imageUrl': recommendation.imageUrl ?? '',
        'ratedAt': FieldValue.serverTimestamp(),
      });

      // Award points for rating
      _gamificationBloc.add(AwardPoints(
        userId: userId,
        points: 20,
        category: PointsCategory.review,
        description: 'Rated "${recommendation.title}"',
        referenceId: recommendation.id,
      ));

      _showPointsEarnedSnackbar(20, 'Rating');

      // Remove from home screen
      setState(() {
        _recommendations.removeWhere((rec) => rec.id == recommendationId);
        _userRatings.remove(recommendationId);
        _expandedStates.remove(recommendationId);
        _bookmarkedStates.remove(recommendationId);
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Center(child: Text('Rating saved!')),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(child: Text('Failed to save rating: $e')),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _toggleBookmark(int index) async {
    final recommendation = _recommendations[index];
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) return;

    // Update UI state first
    setState(() {
      _bookmarkedStates[recommendation.id] = true;
    });

    // Save bookmark to Firestore and remove from home screen
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('bookmarks')
          .doc(recommendation.id)
          .set({
        'recommendationId': recommendation.id,
        'title': recommendation.title,
        'description': recommendation.whyLike,
        'category': recommendation.category,
        'tags': recommendation.tags,
        'communityRating': recommendation.communityRating,
        'imageUrl': recommendation.imageUrl ?? '',
        'bookmarkedAt': FieldValue.serverTimestamp(),
      });

      // Remove from home screen
      setState(() {
        _recommendations.removeAt(index);
        _userRatings.remove(recommendation.id);
        _expandedStates.remove(recommendation.id);
        _bookmarkedStates.remove(recommendation.id);
      });

      // Award points for bookmarking
      _gamificationBloc.add(AwardPoints(
        userId: userId,
        points: 10,
        category: PointsCategory.socialConnection,
        description: 'Bookmarked "${recommendation.title}"',
        referenceId: recommendation.id,
      ));

      _showPointsEarnedSnackbar(10, 'Bookmark');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Center(child: Text('Added to bookmarks')),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(child: Text('Failed to bookmark: $e')),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showPointsEarnedSnackbar(int points, String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.stars, color: Colors.white),
            const SizedBox(width: 8),
            Text('+$points points for $action!'),
          ],
        ),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}