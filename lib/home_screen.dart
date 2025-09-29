import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yajid/screens/chat_list_screen.dart';
import 'package:yajid/screens/discover_screen.dart';
import 'package:yajid/screens/add_content_screen.dart';
import 'package:yajid/screens/calendar_screen.dart';
import 'package:yajid/l10n/app_localizations.dart';
import 'package:yajid/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  String _selectedCategory = 'all';
  List<String> _userCategories = [];
  String _userName = 'User';

  // Mock recommendation data
  final List<Map<String, dynamic>> _recommendations = [
    {
      'category': 'movies',
      'title': 'The Dark Knight',
      'director': 'Christopher Nolan',
      'actors': 'Christian Bale, Heath Ledger',
      'platform': 'Netflix',
      'whyLike': 'Based on your love for action movies and superhero themes, this critically acclaimed Batman film offers complex characters and stunning cinematography.',
      'communityRating': 4.8,
      'userRating': 0.0,
      'isBookmarked': false,
    },
    {
      'category': 'music',
      'title': 'Bohemian Rhapsody',
      'director': 'Queen',
      'actors': 'Freddie Mercury, Brian May',
      'platform': 'Spotify',
      'whyLike': 'Your music preferences suggest you enjoy classic rock with powerful vocals and innovative compositions.',
      'communityRating': 4.9,
      'userRating': 0.0,
      'isBookmarked': false,
    },
    {
      'category': 'books',
      'title': 'Dune',
      'director': 'Frank Herbert',
      'actors': 'Science Fiction Classic',
      'platform': 'Kindle',
      'whyLike': 'Given your interest in complex world-building and philosophical themes, this epic sci-fi novel will captivate you.',
      'communityRating': 4.6,
      'userRating': 0.0,
      'isBookmarked': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    // Show success snackbar when home screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(child: Text(AppLocalizations.of(context)!.successfullyLoggedIn)),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    });
  }

  Future<void> _loadUserData() async {
    // Load user's name from Firebase Auth
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.displayName != null) {
      setState(() {
        _userName = user.displayName!.split(' ').first; // First name only
      });
    }

    // Load user's categories from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final categories = prefs.getStringList('looking_for') ?? [];
    setState(() {
      _userCategories = ['all', ...categories];
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Handle navigation based on tab
    switch (index) {
      case 0:
        // Recommendations - stay on home
        break;
      case 1:
        // Discover - navigate to discover screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DiscoverScreen()),
        );
        break;
      case 2:
        // Add - navigate to add content screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AddContentScreen()),
        );
        break;
      case 3:
        // Calendar - navigate to calendar screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const CalendarScreen()),
        );
        break;
      case 4:
        // Profile
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
        break;
    }
  }

  void _onProfileTap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    );
  }

  void _onFriendsTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Center(child: Text(AppLocalizations.of(context)!.friendsFeatureComingSoon)),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        title: Image.asset(
          'assets/images/logo.jpg',
          height: 64, // 80% of 80 = 64
          width: 64,  // 80% of 80 = 64
          fit: BoxFit.contain,
        ),
        centerTitle: true,
        actions: [
          // Notifications badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  // TODO: Navigate to notifications screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Center(child: Text(AppLocalizations.of(context)!.notificationsFeatureComingSoon)),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: const Text(
                    '3',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          // Messages badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.message_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ChatListScreen()),
                  );
                },
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: const Text(
                    '7',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
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
                    Text(
                      'Hello, $_userName!',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Filter menu
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _userCategories.length,
                  itemBuilder: (context, index) {
                    final category = _userCategories[index];
                    final isSelected = _selectedCategory == category;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(
                          _getLocalizedCategoryName(category),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                        backgroundColor: Colors.grey.shade200,
                        selectedColor: Colors.blue,
                        checkmarkColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Recommendations carousel
              Expanded(
                child: PageView.builder(
                  itemCount: _getFilteredRecommendations().length,
                  itemBuilder: (context, index) {
                    final recommendation = _getFilteredRecommendations()[index];
                    return _buildRecommendationCard(recommendation, index);
                  },
                ),
              ),
            ],
          ),

        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black,
        selectedItemColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.black
            : Colors.white,
        unselectedItemColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.black54
            : Colors.white70,
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.auto_awesome),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.search),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.add_circle_outline),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.calendar_today_outlined),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: '',
          ),
        ],
      ),
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

  List<Map<String, dynamic>> _getFilteredRecommendations() {
    if (_selectedCategory == 'all') {
      return _recommendations;
    }
    return _recommendations.where((rec) => rec['category'] == _selectedCategory).toList();
  }

  Widget _buildRecommendationCard(Map<String, dynamic> recommendation, int index) {
    final categoryColor = _getCategoryColor(recommendation['category']);

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
              // Category tag with different colors
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getLocalizedCategoryName(recommendation['category']),
                  style: TextStyle(
                    color: Color.lerp(categoryColor, Colors.black, 0.3)!,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Title
              Text(
                recommendation['title'],
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // Director/Author
              Text(
                'By ${recommendation['director']}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 4),

              // Actors/Details
              Text(
                recommendation['actors'],
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
                    'Available on ${recommendation['platform']}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Expandable "Why you might like it" section
              _buildExpandableSection(recommendation, index),

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
                      _buildStarRating(recommendation['communityRating'], false, index),
                      const SizedBox(width: 8),
                      Text(
                        '(${recommendation['communityRating'].toStringAsFixed(1)})',
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
                      _buildStarRating(recommendation['userRating'], true, index),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Bookmark button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _toggleBookmark(index),
                      icon: Icon(
                        recommendation['isBookmarked'] ? Icons.bookmark : Icons.bookmark_border,
                      ),
                      label: Text(
                        recommendation['isBookmarked'] ? 'Remove from Bookmarks' : 'Add to Bookmarks',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: recommendation['isBookmarked'] ? Colors.orange : categoryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
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

  Widget _buildExpandableSection(Map<String, dynamic> recommendation, int index) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  recommendation['isExpanded'] = !(recommendation['isExpanded'] ?? false);
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
                    (recommendation['isExpanded'] ?? false)
                        ? Icons.expand_less
                        : Icons.expand_more,
                  ),
                ],
              ),
            ),
            if (recommendation['isExpanded'] ?? false) ...[
              const SizedBox(height: 8),
              Text(
                recommendation['whyLike'],
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildStarRating(double rating, bool isInteractive, int index) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (starIndex) {
        return GestureDetector(
          onTap: isInteractive ? () => _updateUserRating(index, starIndex + 1.0) : null,
          child: Icon(
            starIndex < rating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 20,
          ),
        );
      }),
    );
  }

  void _updateUserRating(int recommendationIndex, double rating) {
    setState(() {
      _recommendations[recommendationIndex]['userRating'] = rating;
    });
  }

  void _toggleBookmark(int index) {
    setState(() {
      _recommendations[index]['isBookmarked'] = !_recommendations[index]['isBookmarked'];
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Center(
          child: Text(
            _recommendations[index]['isBookmarked']
                ? 'Added to bookmarks'
                : 'Removed from bookmarks',
          ),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}