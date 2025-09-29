import 'package:flutter/material.dart';
import 'package:yajid/l10n/app_localizations.dart';
import 'package:yajid/home_screen.dart';
import 'package:yajid/profile_screen.dart';
import 'package:yajid/screens/chat_list_screen.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> with TickerProviderStateMixin {
  int _currentIndex = 1; // Discover tab is index 1
  final TextEditingController _searchController = TextEditingController();
  late TabController _categoryTabController;
  String _selectedFilter = 'All';

  final List<String> _filters = ['All', 'Movies', 'Music', 'Books', 'Restaurants', 'Games'];

  // Sample discover content
  final List<Map<String, dynamic>> _discoverItems = [
    {
      'title': 'Trending Movies This Week',
      'category': 'Movies',
      'type': 'collection',
      'items': [
        {
          'title': 'Oppenheimer',
          'subtitle': 'Christopher Nolan',
          'rating': 4.8,
          'image': 'https://via.placeholder.com/150',
        },
        {
          'title': 'Barbie',
          'subtitle': 'Greta Gerwig',
          'rating': 4.6,
          'image': 'https://via.placeholder.com/150',
        },
      ],
    },
    {
      'title': 'New Music Releases',
      'category': 'Music',
      'type': 'collection',
      'items': [
        {
          'title': 'Midnights',
          'subtitle': 'Taylor Swift',
          'rating': 4.9,
          'image': 'https://via.placeholder.com/150',
        },
        {
          'title': 'Harry\'s House',
          'subtitle': 'Harry Styles',
          'rating': 4.7,
          'image': 'https://via.placeholder.com/150',
        },
      ],
    },
    {
      'title': 'Bestselling Books',
      'category': 'Books',
      'type': 'collection',
      'items': [
        {
          'title': 'Fourth Wing',
          'subtitle': 'Rebecca Yarros',
          'rating': 4.5,
          'image': 'https://via.placeholder.com/150',
        },
        {
          'title': 'Tomorrow, and Tomorrow, and Tomorrow',
          'subtitle': 'Gabrielle Zevin',
          'rating': 4.3,
          'image': 'https://via.placeholder.com/150',
        },
      ],
    },
    {
      'title': 'Popular Restaurants',
      'category': 'Restaurants',
      'type': 'collection',
      'items': [
        {
          'title': 'The French Laundry',
          'subtitle': 'Fine Dining',
          'rating': 4.9,
          'image': 'https://via.placeholder.com/150',
        },
        {
          'title': 'Joe\'s Pizza',
          'subtitle': 'Casual Dining',
          'rating': 4.4,
          'image': 'https://via.placeholder.com/150',
        },
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _categoryTabController = TabController(length: _filters.length, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _categoryTabController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Handle navigation based on tab
    switch (index) {
      case 0:
        // Recommendations - navigate to home
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
        break;
      case 1:
        // Discover - already on discover screen
        break;
      case 2:
        // Add - show snackbar or navigate to add screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(child: Text(AppLocalizations.of(context)!.addFeatureComingSoon)),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        break;
      case 3:
        // Calendar - show snackbar or navigate to calendar screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(child: Text(AppLocalizations.of(context)!.calendarFeatureComingSoon)),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        break;
      case 4:
        // Profile - navigate to profile screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
        break;
    }
  }

  void _onCategoryTabChanged(int index) {
    setState(() {
      _selectedFilter = _filters[index];
    });
  }

  List<Map<String, dynamic>> _getFilteredItems() {
    if (_selectedFilter == 'All') {
      return _discoverItems;
    }
    return _discoverItems.where((item) => item['category'] == _selectedFilter).toList();
  }

  void _onSearchChanged(String query) {
    // Implement search functionality
    setState(() {
      // For now, just trigger a rebuild
      // In a real app, this would filter the discover items based on the search query
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatListScreen()),
              );
            },
            tooltip: 'Messages',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search for movies, music, books...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                ),
              ),
              // Category Tabs
              TabBar(
                controller: _categoryTabController,
                isScrollable: true,
                labelColor: Colors.blue,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.blue,
                onTap: _onCategoryTabChanged,
                tabs: _filters.map((filter) => Tab(text: filter)).toList(),
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _categoryTabController,
        children: _filters.map((filter) => _buildDiscoverContent()).toList(),
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

  Widget _buildDiscoverContent() {
    final filteredItems = _getFilteredItems();

    if (filteredItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No items found for $_selectedFilter',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different category or search term',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        final collection = filteredItems[index];
        return _buildCollectionCard(collection);
      },
    );
  }

  Widget _buildCollectionCard(Map<String, dynamic> collection) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    collection['title'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Chip(
                  label: Text(collection['category']),
                  backgroundColor: Colors.blue.shade100,
                  labelStyle: const TextStyle(
                    color: Colors.blue,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: collection['items'].length,
                itemBuilder: (context, index) {
                  final item = collection['items'][index];
                  return _buildItemCard(item);
                },
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Center(child: Text('View all ${collection['category']} coming soon')),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.arrow_forward),
                label: const Text('See All'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade200,
            ),
            child: const Icon(
              Icons.image,
              size: 32,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item['title'],
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            item['subtitle'],
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            children: [
              const Icon(Icons.star, size: 12, color: Colors.amber),
              const SizedBox(width: 2),
              Text(
                item['rating'].toString(),
                style: const TextStyle(fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}