import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/venue/venue_bloc.dart';
import '../bloc/venue/venue_event.dart';
import '../bloc/venue/venue_state.dart';
import '../widgets/venue_card_widget.dart';
import 'venue_detail_screen.dart';

class VenueSearchScreen extends StatefulWidget {
  const VenueSearchScreen({super.key});

  @override
  State<VenueSearchScreen> createState() => _VenueSearchScreenState();
}

class _VenueSearchScreenState extends State<VenueSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;
  double? _minPrice;
  double? _maxPrice;
  double? _minRating;
  int? _minCapacity;
  final List<String> _selectedAmenities = [];
  bool _showFilters = false;

  final List<String> _commonAmenities = [
    'WiFi',
    'Parking',
    'Air Conditioning',
    'Projector',
    'Whiteboard',
    'Kitchen',
    'Sound System',
    'Outdoor Space',
  ];

  @override
  void initState() {
    super.initState();
    // Load all venues on init
    context.read<VenueBloc>().add(const LoadVenues());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    context.read<VenueBloc>().add(SearchVenues(
          searchQuery: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
          category: _selectedCategory,
          minPrice: _minPrice,
          maxPrice: _maxPrice,
          minRating: _minRating,
          minCapacity: _minCapacity,
          amenities: _selectedAmenities.isEmpty ? null : _selectedAmenities,
        ));
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedCategory = null;
      _minPrice = null;
      _maxPrice = null;
      _minRating = null;
      _minCapacity = null;
      _selectedAmenities.clear();
    });
    context.read<VenueBloc>().add(const LoadVenues());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Venues'),
        actions: [
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_list_off : Icons.filter_list),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search venues...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {});
              },
              onSubmitted: (value) => _performSearch(),
            ),
          ),

          // Filters Section
          if (_showFilters) _buildFiltersSection(),

          // Search/Clear Buttons
          if (_showFilters)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _performSearch,
                      icon: const Icon(Icons.search),
                      label: const Text('Apply Filters'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: _clearFilters,
                    child: const Text('Clear'),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 8),

          // Results
          Expanded(
            child: BlocBuilder<VenueBloc, VenueState>(
              builder: (context, state) {
                if (state is VenueLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is VenuesLoaded) {
                  if (state.venues.isEmpty) {
                    return const Center(
                      child: Text('No venues found'),
                    );
                  }
                  return ListView.builder(
                    itemCount: state.venues.length,
                    itemBuilder: (context, index) {
                      final venue = state.venues[index];
                      return VenueCardWidget(
                        venue: venue,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VenueDetailScreen(venue: venue),
                            ),
                          );
                        },
                      );
                    },
                  );
                } else if (state is VenueError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(state.message),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<VenueBloc>().add(const LoadVenues());
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filters',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Category Filter
          const Text('Category', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: _selectedCategory == null,
                onSelected: (selected) {
                  setState(() {
                    _selectedCategory = null;
                  });
                },
              ),
              ChoiceChip(
                label: const Text('Restaurant'),
                selected: _selectedCategory == 'Restaurant',
                onSelected: (selected) {
                  setState(() {
                    _selectedCategory = selected ? 'Restaurant' : null;
                  });
                },
              ),
              ChoiceChip(
                label: const Text('Conference Room'),
                selected: _selectedCategory == 'Conference Room',
                onSelected: (selected) {
                  setState(() {
                    _selectedCategory = selected ? 'Conference Room' : null;
                  });
                },
              ),
              ChoiceChip(
                label: const Text('Event Space'),
                selected: _selectedCategory == 'Event Space',
                onSelected: (selected) {
                  setState(() {
                    _selectedCategory = selected ? 'Event Space' : null;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Price Range
          const Text('Price Range (per hour)', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Min',
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _minPrice = double.tryParse(value);
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Max',
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _maxPrice = double.tryParse(value);
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Rating Filter
          const Text('Minimum Rating', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [1, 2, 3, 4, 5].map((rating) {
              return ChoiceChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$rating'),
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                  ],
                ),
                selected: _minRating == rating.toDouble(),
                onSelected: (selected) {
                  setState(() {
                    _minRating = selected ? rating.toDouble() : null;
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Capacity Filter
          const Text('Minimum Capacity', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Number of people',
              isDense: true,
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                _minCapacity = int.tryParse(value);
              });
            },
          ),
          const SizedBox(height: 16),

          // Amenities Filter
          const Text('Amenities', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _commonAmenities.map((amenity) {
              return FilterChip(
                label: Text(amenity),
                selected: _selectedAmenities.contains(amenity),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedAmenities.add(amenity);
                    } else {
                      _selectedAmenities.remove(amenity);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
