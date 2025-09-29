import 'package:flutter/material.dart';
import 'package:yajid/l10n/app_localizations.dart';
import 'package:yajid/home_screen.dart';
import 'package:yajid/profile_screen.dart';
import 'package:yajid/screens/discover_screen.dart';

class AddContentScreen extends StatefulWidget {
  const AddContentScreen({super.key});

  @override
  State<AddContentScreen> createState() => _AddContentScreenState();
}

class _AddContentScreenState extends State<AddContentScreen> with TickerProviderStateMixin {
  int _currentIndex = 2; // Add tab is index 2
  late TabController _contentTabController;

  final List<String> _contentTypes = ['Recommendation', 'Review', 'List', 'Photo'];

  // Form controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  String _selectedCategory = 'Movies';
  double _rating = 5.0;
  bool _isSubmitting = false;

  final List<String> _categories = [
    'Movies', 'Music', 'Books', 'Restaurants', 'Games', 'TV Shows', 'Fashion', 'Travel'
  ];

  @override
  void initState() {
    super.initState();
    _contentTabController = TabController(length: _contentTypes.length, vsync: this);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    _contentTabController.dispose();
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
        // Discover - navigate to discover screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DiscoverScreen()),
        );
        break;
      case 2:
        // Add - already on add screen
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

  Future<void> _submitContent() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Center(child: Text('Please enter a title')),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(child: Text('${_contentTypes[_contentTabController.index]} created successfully!')),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Clear form
      _titleController.clear();
      _descriptionController.clear();
      _tagsController.clear();
      setState(() {
        _rating = 5.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Content'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        bottom: TabBar(
          controller: _contentTabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          tabs: _contentTypes.map((type) => Tab(text: type)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _contentTabController,
        children: [
          _buildRecommendationForm(),
          _buildReviewForm(),
          _buildListForm(),
          _buildPhotoForm(),
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

  Widget _buildRecommendationForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormHeader('Share Your Recommendation', 'Recommend something amazing to the community'),
          const SizedBox(height: 24),
          _buildCategoryDropdown(),
          const SizedBox(height: 16),
          _buildTitleField('What are you recommending?'),
          const SizedBox(height: 16),
          _buildDescriptionField('Why do you recommend this?'),
          const SizedBox(height: 16),
          _buildRatingSlider(),
          const SizedBox(height: 16),
          _buildTagsField(),
          const SizedBox(height: 24),
          _buildSubmitButton('Share Recommendation'),
        ],
      ),
    );
  }

  Widget _buildReviewForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormHeader('Write a Review', 'Share your honest opinion and rating'),
          const SizedBox(height: 24),
          _buildCategoryDropdown(),
          const SizedBox(height: 16),
          _buildTitleField('What are you reviewing?'),
          const SizedBox(height: 16),
          _buildDescriptionField('Write your detailed review'),
          const SizedBox(height: 16),
          _buildRatingSlider(),
          const SizedBox(height: 16),
          _buildTagsField(),
          const SizedBox(height: 24),
          _buildSubmitButton('Publish Review'),
        ],
      ),
    );
  }

  Widget _buildListForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormHeader('Create a List', 'Curate a collection of your favorites'),
          const SizedBox(height: 24),
          _buildCategoryDropdown(),
          const SizedBox(height: 16),
          _buildTitleField('List title (e.g., "Best Movies of 2023")'),
          const SizedBox(height: 16),
          _buildDescriptionField('Describe your list'),
          const SizedBox(height: 16),
          _buildTagsField(),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'List Items',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, size: 32, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Tap to add items to your list'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildSubmitButton('Create List'),
        ],
      ),
    );
  }

  Widget _buildPhotoForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormHeader('Share a Photo', 'Show the community what you love'),
          const SizedBox(height: 24),
          _buildCategoryDropdown(),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt, size: 48, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('Tap to add a photo'),
                        SizedBox(height: 8),
                        Text(
                          'Share a photo of your experience',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildTitleField('Caption your photo'),
          const SizedBox(height: 16),
          _buildDescriptionField('Tell the story behind this photo (optional)'),
          const SizedBox(height: 16),
          _buildTagsField(),
          const SizedBox(height: 24),
          _buildSubmitButton('Share Photo'),
        ],
      ),
    );
  }

  Widget _buildFormHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedCategory,
      decoration: const InputDecoration(
        labelText: 'Category',
        border: OutlineInputBorder(),
      ),
      items: _categories.map((category) {
        return DropdownMenuItem(
          value: category,
          child: Text(category),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategory = value!;
        });
      },
    );
  }

  Widget _buildTitleField(String hint) {
    return TextField(
      controller: _titleController,
      decoration: InputDecoration(
        labelText: 'Title',
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
      maxLength: 100,
    );
  }

  Widget _buildDescriptionField(String hint) {
    return TextField(
      controller: _descriptionController,
      decoration: InputDecoration(
        labelText: 'Description',
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
      maxLines: 4,
      maxLength: 500,
    );
  }

  Widget _buildRatingSlider() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rating',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _rating,
                    min: 1.0,
                    max: 5.0,
                    divisions: 8,
                    label: _rating.toString(),
                    onChanged: (value) {
                      setState(() {
                        _rating = value;
                      });
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        _rating.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsField() {
    return TextField(
      controller: _tagsController,
      decoration: const InputDecoration(
        labelText: 'Tags (optional)',
        hintText: 'Add tags separated by commas',
        border: OutlineInputBorder(),
        helperText: 'e.g., action, comedy, must-watch',
      ),
    );
  }

  Widget _buildSubmitButton(String text) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitContent,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        child: _isSubmitting
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('Publishing...'),
                ],
              )
            : Text(text),
      ),
    );
  }
}