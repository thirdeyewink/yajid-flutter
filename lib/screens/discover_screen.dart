import 'package:flutter/material.dart';
import 'package:yajid/theme/app_theme.dart';
import 'package:yajid/services/recommendation_service.dart';
import 'package:yajid/models/recommendation_model.dart';
import 'package:yajid/l10n/app_localizations.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  String _selectedFilter = 'all';
  String _selectedMediaFilter = 'all'; // Secondary filter for media
  final RecommendationService _recommendationService = RecommendationService();
  Map<String, List<Recommendation>> _categoryGroups = {};
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showMapView = false;
  String _nearbyFilter = 'all'; // all, nearby
  String _openingHoursFilter = 'all'; // all, open_now, open_24h

  // Location-based search keywords
  final List<String> _locationKeywords = [
    'event', 'restaurant', 'coffee', 'shop', 'bar', 'club', 'museum',
    'gym', 'rooftop', 'venue', 'activity', 'experience', 'cafe', 'hotel'
  ];

  @override
  void initState() {
    super.initState();
    _loadDiscoverContent();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDiscoverContent() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Fetch all recommendations
      final allRecommendations = await _recommendationService.getAllRecommendations();

      // Group by category
      final Map<String, List<Recommendation>> groups = {};
      for (final rec in allRecommendations) {
        if (!groups.containsKey(rec.category)) {
          groups[rec.category] = [];
        }
        groups[rec.category]!.add(rec);
      }

      if (mounted) {
        setState(() {
          _categoryGroups = groups;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load content: $e';
          _isLoading = false;
        });
      }
    }
  }

  bool _isLocationBasedSearch() {
    final query = _searchQuery.toLowerCase();
    return _locationKeywords.any((keyword) => query.contains(keyword)) ||
           _selectedFilter == 'events' ||
           _selectedFilter == 'places' ||
           _selectedFilter == 'experiences';
  }

  List<String> _getCategoriesForFilter(String filter) {
    switch (filter) {
      case 'all':
        return _categoryGroups.keys.toList();
      case 'media':
        if (_selectedMediaFilter == 'all') {
          return ['movies', 'music', 'books', 'tv shows', 'podcasts', 'sports', 'videogames'];
        } else {
          return [_selectedMediaFilter];
        }
      case 'events':
        return ['events'];
      case 'places':
        return ['businesses'];
      case 'experiences':
        return ['activities'];
      case 'services':
        return ['businesses'];
      case 'brands':
        return ['brands'];
      case 'people':
        return ['people'];
      case 'sports_teams':
        return ['sports_teams'];
      case 'public_figures':
        return ['public_figures'];
      case 'recipes':
        return ['recipes'];
      default:
        return [];
    }
  }

  void _showMediaFilterSheet() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            child: Container(
              width: 280,
              height: double.infinity,
              color: Colors.white,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 40, right: 8),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Filter Media',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildMediaFilterOption('all', 'All Media'),
                  _buildMediaFilterOption('movies', 'Movies'),
                  _buildMediaFilterOption('music', 'Music'),
                  _buildMediaFilterOption('books', 'Books'),
                  _buildMediaFilterOption('tv shows', 'TV Shows'),
                  _buildMediaFilterOption('podcasts', 'Podcasts'),
                  _buildMediaFilterOption('sports', 'Sports'),
                  _buildMediaFilterOption('videogames', 'Video Games'),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
    );
  }

  Widget _buildMediaFilterOption(String value, String label) {
    final isSelected = _selectedMediaFilter == value;
    final categoryColor = _getCategoryColor(value);

    return ListTile(
      contentPadding: const EdgeInsets.only(left: 16, right: 16),
      leading: Icon(
        _getCategoryIcon(value),
        color: isSelected ? categoryColor : Colors.grey.shade700,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? categoryColor : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: categoryColor.withValues(alpha: 0.1),
      onTap: () {
        setState(() {
          _selectedMediaFilter = value;
        });
        Navigator.pop(context);
      },
    );
  }

  List<MapEntry<String, List<Recommendation>>> _getFilteredGroups() {
    final allowedCategories = _getCategoriesForFilter(_selectedFilter);

    var groups = _categoryGroups.entries
        .where((entry) => allowedCategories.contains(entry.key))
        .toList();

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      groups = groups.map((entry) {
        final filteredItems = entry.value.where((item) {
          return item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                 item.creator.toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();
        return MapEntry(entry.key, filteredItems);
      }).where((entry) => entry.value.isNotEmpty).toList();
    }

    return groups;
  }

  void _showLocationFiltersDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Filters'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nearby', style: TextStyle(fontWeight: FontWeight.bold)),
            // ignore: deprecated_member_use
            RadioListTile<String>(
              title: const Text('All'),
              value: 'all',
              // ignore: deprecated_member_use
              groupValue: _nearbyFilter,
              // ignore: deprecated_member_use
              onChanged: (value) {
                setState(() {
                  _nearbyFilter = value!;
                });
                Navigator.pop(context);
              },
            ),
            // ignore: deprecated_member_use
            RadioListTile<String>(
              title: const Text('Nearby (5 km)'),
              value: 'nearby',
              // ignore: deprecated_member_use
              groupValue: _nearbyFilter,
              // ignore: deprecated_member_use
              onChanged: (value) {
                setState(() {
                  _nearbyFilter = value!;
                });
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
            const Text('Opening Hours', style: TextStyle(fontWeight: FontWeight.bold)),
            // ignore: deprecated_member_use
            RadioListTile<String>(
              title: const Text('All'),
              value: 'all',
              // ignore: deprecated_member_use
              groupValue: _openingHoursFilter,
              // ignore: deprecated_member_use
              onChanged: (value) {
                setState(() {
                  _openingHoursFilter = value!;
                });
                Navigator.pop(context);
              },
            ),
            // ignore: deprecated_member_use
            RadioListTile<String>(
              title: const Text('Open Now'),
              value: 'open_now',
              // ignore: deprecated_member_use
              groupValue: _openingHoursFilter,
              // ignore: deprecated_member_use
              onChanged: (value) {
                setState(() {
                  _openingHoursFilter = value!;
                });
                Navigator.pop(context);
              },
            ),
            // ignore: deprecated_member_use
            RadioListTile<String>(
              title: const Text('Open 24 Hours'),
              value: 'open_24h',
              // ignore: deprecated_member_use
              groupValue: _openingHoursFilter,
              // ignore: deprecated_member_use
              onChanged: (value) {
                setState(() {
                  _openingHoursFilter = value!;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _nearbyFilter = 'all';
                _openingHoursFilter = 'all';
              });
              Navigator.pop(context);
            },
            child: const Text('Reset'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            child: Container(
              width: 280,
              height: double.infinity,
              color: Colors.white,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 40, right: 8),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Filter by Category',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFilterOption('all', 'All'),
                  _buildFilterOption('media', 'Media'),
                  _buildFilterOption('events', 'Events'),
                  _buildFilterOption('places', 'Places'),
                  _buildFilterOption('experiences', 'Experiences'),
                  _buildFilterOption('services', 'Services'),
                  _buildFilterOption('brands', 'Brands'),
                  _buildFilterOption('people', AppLocalizations.of(context)!.people),
                  _buildFilterOption('sports_teams', AppLocalizations.of(context)!.sportsTeams),
                  _buildFilterOption('public_figures', 'Public Figures'),
                  _buildFilterOption('recipes', 'Recipes'),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
    );
  }

  Widget _buildFilterOption(String value, String label) {
    final isSelected = _selectedFilter == value;
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 16, right: 16),
      leading: Icon(
        _getFilterIcon(value),
        color: isSelected ? Colors.blue : Colors.grey.shade700,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.blue : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: value == 'media' && isSelected
          ? IconButton(
              icon: const Icon(Icons.chevron_right, color: Colors.blue),
              onPressed: () {
                Navigator.pop(context);
                _showMediaFilterSheet();
              },
            )
          : null,
      selected: isSelected,
      selectedTileColor: Colors.blue.shade50,
      onTap: () {
        setState(() {
          _selectedFilter = value;
          if (value != 'media') {
            _selectedMediaFilter = 'all'; // Reset media filter when changing category
          }
          _showMapView = _isLocationBasedSearch();
        });
        if (value == 'media') {
          Navigator.pop(context);
          _showMediaFilterSheet();
        } else {
          Navigator.pop(context);
        }
      },
    );
  }

  IconData _getFilterIcon(String filter) {
    switch (filter) {
      case 'all':
        return Icons.apps;
      case 'media':
        return Icons.play_circle_outline;
      case 'events':
        return Icons.event;
      case 'places':
        return Icons.place;
      case 'experiences':
        return Icons.explore;
      case 'services':
        return Icons.business_center;
      case 'brands':
        return Icons.local_offer;
      case 'people':
        return Icons.people;
      case 'sports_teams':
        return Icons.sports;
      case 'public_figures':
        return Icons.person_outline;
      case 'recipes':
        return Icons.restaurant_menu;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: AppTheme.buildLogo(size: 45.0),
        leadingWidth: 70,
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search by title or creator...',
              hintStyle: const TextStyle(color: Colors.white70),
              border: InputBorder.none,
              prefixIcon: const Icon(Icons.search, color: Colors.white70),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white70),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
                _showMapView = _isLocationBasedSearch();
              });
            },
          ),
        ),
        actions: [
          if (_isLocationBasedSearch()) ...[
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.location_on, color: Colors.white),
                  onPressed: _showLocationFiltersDialog,
                ),
                if (_nearbyFilter != 'all' || _openingHoursFilter != 'all')
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const SizedBox(width: 8, height: 8),
                    ),
                  ),
              ],
            ),
            IconButton(
              icon: Icon(
                _showMapView ? Icons.list : Icons.map,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _showMapView = !_showMapView;
                });
              },
            ),
          ],
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list, color: Colors.white),
                onPressed: _showFilterSheet,
              ),
              if (_selectedFilter != 'all' || (_selectedFilter == 'media' && _selectedMediaFilter != 'all'))
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: const SizedBox(width: 8, height: 8),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: _showMapView ? _buildMapView() : _buildFindContent(),
    );
  }

  Widget _buildMapView() {
    final filteredGroups = _getFilteredGroups();
    final allItems = filteredGroups.expand((group) => group.value).toList();

    return Stack(
      children: [
        // Map placeholder
        Container(
          color: Colors.grey.shade200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map, size: 100, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'Map View',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Interactive map coming soon',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Active filters chip
        if (_nearbyFilter != 'all' || _openingHoursFilter != 'all')
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Wrap(
              spacing: 8,
              children: [
                if (_nearbyFilter == 'nearby')
                  Chip(
                    label: const Text('Nearby (5 km)'),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () {
                      setState(() {
                        _nearbyFilter = 'all';
                      });
                    },
                    backgroundColor: Colors.blue.shade100,
                  ),
                if (_openingHoursFilter == 'open_now')
                  Chip(
                    label: const Text('Open Now'),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () {
                      setState(() {
                        _openingHoursFilter = 'all';
                      });
                    },
                    backgroundColor: Colors.green.shade100,
                  ),
                if (_openingHoursFilter == 'open_24h')
                  Chip(
                    label: const Text('Open 24 Hours'),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () {
                      setState(() {
                        _openingHoursFilter = 'all';
                      });
                    },
                    backgroundColor: Colors.orange.shade100,
                  ),
              ],
            ),
          ),
        // Results list at bottom
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 280,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${allItems.length} results',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _showMapView = false;
                          });
                        },
                        icon: const Icon(Icons.list),
                        label: const Text('List View'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: allItems.length > 10 ? 10 : allItems.length,
                    itemBuilder: (context, index) {
                      final item = allItems[index];
                      // Get category from the item
                      final itemCategory = filteredGroups
                          .firstWhere((group) => group.value.contains(item))
                          .key;
                      return _buildItemCard(item, itemCategory);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFindContent() {
    // Show loading state
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Show error state
    if (_errorMessage != null) {
      return Center(
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
              onPressed: _loadDiscoverContent,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final filteredGroups = _getFilteredGroups();

    if (filteredGroups.isEmpty) {
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
              'No content available',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try seeding data from Settings > Developer',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Active filters indicator
        if (_selectedFilter == 'media' && _selectedMediaFilter != 'all')
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Chip(
                  avatar: Icon(_getCategoryIcon(_selectedMediaFilter), size: 16, color: _getCategoryColor(_selectedMediaFilter)),
                  label: Text(
                    _selectedMediaFilter[0].toUpperCase() + _selectedMediaFilter.substring(1),
                    style: TextStyle(color: _getCategoryColor(_selectedMediaFilter)),
                  ),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () {
                    setState(() {
                      _selectedMediaFilter = 'all';
                    });
                  },
                  backgroundColor: _getCategoryColor(_selectedMediaFilter).withValues(alpha: 0.2),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: _showMediaFilterSheet,
                  icon: const Icon(Icons.tune, size: 16),
                  label: const Text('Change'),
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredGroups.length,
            itemBuilder: (context, index) {
              final categoryGroup = filteredGroups[index];
              return _buildCollectionCard(categoryGroup);
            },
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'all':
        return Colors.blue;
      case 'movies':
        return Colors.red;
      case 'music':
        return Colors.purple;
      case 'books':
        return Colors.orange;
      case 'tv shows':
        return Colors.blue;
      case 'podcasts':
        return Colors.green;
      case 'sports':
        return Colors.teal;
      case 'videogames':
        return Colors.indigo;
      case 'brands':
        return Colors.pink;
      case 'recipes':
        return Colors.amber;
      case 'events':
        return Colors.deepOrange;
      case 'activities':
        return Colors.cyan;
      case 'businesses':
        return Colors.brown;
      case 'people':
        return Colors.lightBlue;
      case 'sports_teams':
        return Colors.green;
      case 'public_figures':
        return Colors.deepPurple;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'all':
        return Icons.apps;
      case 'movies':
        return Icons.movie;
      case 'music':
        return Icons.music_note;
      case 'books':
        return Icons.book;
      case 'tv shows':
        return Icons.tv;
      case 'podcasts':
        return Icons.podcasts;
      case 'sports':
        return Icons.sports_soccer;
      case 'videogames':
        return Icons.sports_esports;
      case 'brands':
        return Icons.local_offer;
      case 'recipes':
        return Icons.restaurant_menu;
      case 'events':
        return Icons.event;
      case 'activities':
        return Icons.explore;
      case 'businesses':
        return Icons.business;
      case 'people':
        return Icons.people;
      case 'sports_teams':
        return Icons.sports;
      case 'public_figures':
        return Icons.person;
      default:
        return Icons.category;
    }
  }

  Widget _buildCollectionCard(MapEntry<String, List<Recommendation>> categoryGroup) {
    final category = categoryGroup.key;
    final items = categoryGroup.value;
    final categoryTitle = category[0].toUpperCase() + category.substring(1);
    final categoryColor = _getCategoryColor(category);

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
                  child: Row(
                    children: [
                      Icon(_getCategoryIcon(category), color: categoryColor, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '$categoryTitle (${items.length})',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: Text(categoryTitle),
                  backgroundColor: categoryColor.withValues(alpha: 0.2),
                  labelStyle: TextStyle(
                    color: categoryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 240,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: items.length > 10 ? 10 : items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _buildItemCard(item, category);
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
                      content: Center(child: Text('View all $categoryTitle coming soon')),
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

  Widget _buildItemCard(Recommendation item, String category) {
    final categoryColor = _getCategoryColor(category);

    // Mock data for additional fields (in a real app, these would come from the item object)
    final releaseDate = '2024';
    final streamingPlatform = 'Netflix';
    final director = 'Christopher Nolan';
    final studio = 'Warner Bros';

    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with category badge
            Stack(
              children: [
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    color: Colors.grey.shade200,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.image,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: categoryColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      category.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  // Creator/Director
                  Text(
                    category == 'movies' || category == 'tv shows' ? director : item.creator,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Release date & Platform
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 10, color: Colors.grey.shade500),
                      const SizedBox(width: 2),
                      Text(
                        releaseDate,
                        style: TextStyle(fontSize: 9, color: Colors.grey.shade600),
                      ),
                      const SizedBox(width: 8),
                      if (category == 'movies' || category == 'tv shows') ...[
                        Icon(Icons.play_circle_outline, size: 10, color: categoryColor),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            streamingPlatform,
                            style: TextStyle(fontSize: 9, color: categoryColor),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Studio/Label
                  if (category == 'movies' || category == 'tv shows' || category == 'music')
                    Row(
                      children: [
                        Icon(Icons.business, size: 10, color: Colors.grey.shade500),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            studio,
                            style: TextStyle(fontSize: 9, color: Colors.grey.shade600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 4),
                  // Rating
                  Row(
                    children: [
                      const Icon(Icons.star, size: 12, color: Colors.amber),
                      const SizedBox(width: 2),
                      Text(
                        item.communityRating.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}