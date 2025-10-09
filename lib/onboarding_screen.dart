import 'package:flutter/material.dart';
import 'package:yajid/l10n/app_localizations.dart';
import 'package:yajid/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:yajid/onboarding_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Recommendation categories
  final List<String> _recommendationCategories = [
    'movies',
    'music',
    'tv shows',
    'podcasts',
    'sports',
    'books',
    'videogames',
    'brands',
    'recipes',
    'events',
    'activities',
    'businesses',
    'restaurants',
    'bars',
    'clubs',
    'coffee shops',
    'shops',
    'services',
    'people',
    'friendships',
    'experiences',
    'dating',
    'trips',
    'sight seeing',
    'documentary',
    'stand up comedy',
    'anime',
    'manga',
    'cartoons'
  ];

  final Set<String> _selectedCategories = <String>{};

  // Skills
  final List<String> _predefinedSkills = [
    'Programming',
    'Design',
    'Marketing',
    'Writing',
    'Photography',
    'Video Editing',
    'Public Speaking',
    'Leadership',
    'Project Management',
    'Data Analysis',
    'Cooking',
    'Music',
    'Teaching',
    'Sales',
    'Customer Service',
    'Foreign Languages',
    'Accounting',
    'Engineering',
  ];

  final Set<String> _selectedSkills = <String>{};
  final TextEditingController _customSkillController = TextEditingController();

  // Interests
  final Map<String, List<String>> _interestCategories = {
    'Music': ['Pop', 'Rock', 'Hip Hop', 'Jazz', 'Classical', 'Electronic', 'Country', 'R&B', 'Rap', 'Trap', 'Techno', 'House', 'EDM', 'Psytrance', 'Trip Hop', 'Folk', 'Blues', 'Reggae', 'Soul', 'Funk', 'Indie', 'Alternative', 'Metal', 'Punk'],
    'Movies': ['Action', 'Comedy', 'Drama', 'Thriller', 'Sci-Fi', 'Horror', 'Romance', 'Documentary', 'Animation', 'Musical', 'Western', 'Crime', 'Biography', 'War', 'Adventure', 'Family', 'Fantasy', 'Mystery', 'Noir', 'Historical'],
    'Books': ['Fiction', 'Non-Fiction', 'Mystery', 'Fantasy', 'Biography', 'Self-Help', 'History', 'Poetry', 'Thriller', 'Romance', 'Horror', 'Science', 'Philosophy', 'Religion', 'Comics', 'Graphic Novels', 'Classics', 'Contemporary'],
    'Games': ['Action', 'RPG', 'Strategy', 'Sports', 'Puzzle', 'Adventure', 'Simulation', 'Fighting', 'Racing', 'Shooter', 'MMORPG', 'MOBA', 'Battle Royale', 'Roguelike', 'Platformer', 'Sandbox', 'Survival', 'Horror'],
    'Food': ['Italian', 'Chinese', 'Japanese', 'Mexican', 'Indian', 'Thai', 'French', 'Mediterranean', 'Greek', 'Spanish', 'Lebanese', 'Korean', 'Vietnamese', 'Turkish', 'Brazilian', 'Moroccan', 'American', 'Fusion'],
    'Activities': ['Reading', 'Gaming', 'Sports', 'Hiking', 'Traveling', 'Cooking', 'Art', 'Photography', 'Dancing', 'Painting', 'Music', 'Writing', 'Fitness', 'Yoga', 'Meditation', 'Swimming', 'Running', 'Cycling'],
  };

  final Map<String, Set<String>> _selectedInterests = {
    'Music': {},
    'Movies': {},
    'Books': {},
    'Games': {},
    'Food': {},
    'Activities': {},
  };

  final TextEditingController _customInterestController = TextEditingController();
  String _currentInterestCategory = 'Music';

  final List<OnboardingPage> _pages = const [
    OnboardingPage(
      icon: Icons.rocket_launch,
      titleKey: 'onboardingReadyTitle',
      descriptionKey: 'onboardingReadyDescription',
      color: Colors.orange,
    ),
  ];

  @override
  void dispose() {
    _customSkillController.dispose();
    _customInterestController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length + 2) { // Total pages is _pages.length + 3 (recommendations + skills + interests + other pages)
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _completeOnboarding() async {
    // Save selected categories to user profile
    if (_selectedCategories.isNotEmpty) {
      await _saveRecommendationPreferences();
    }

    // Save selected skills to user profile
    if (_selectedSkills.isNotEmpty) {
      await _saveSkillsPreferences();
    }

    // Save selected interests to user profile
    await _saveInterestsPreferences();

    if (mounted) {
      await Provider.of<OnboardingProvider>(context, listen: false).completeOnboarding();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    }
  }

  Future<void> _saveRecommendationPreferences() async {
    // Save to SharedPreferences for now
    // Future enhancement: Save to Firebase user profile for cross-device sync
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('looking_for', _selectedCategories.toList());
  }

  Future<void> _saveSkillsPreferences() async {
    // Save to SharedPreferences for now
    // Future enhancement: Save to Firebase user profile for cross-device sync
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('user_skills', _selectedSkills.toList());
  }

  String _normalizeSkill(String skill) {
    // Normalize skill name: trim whitespace, capitalize first letter of each word
    return skill
        .trim()
        .split(' ')
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  void _addCustomSkill() {
    final skill = _customSkillController.text.trim();
    if (skill.isEmpty) return;

    final normalizedSkill = _normalizeSkill(skill);

    // Check for duplicates (case-insensitive)
    final isDuplicate = _selectedSkills.any(
      (s) => s.toLowerCase() == normalizedSkill.toLowerCase()
    ) || _predefinedSkills.any(
      (s) => s.toLowerCase() == normalizedSkill.toLowerCase()
    );

    if (!isDuplicate) {
      setState(() {
        _selectedSkills.add(normalizedSkill);
        _customSkillController.clear();
      });
    } else {
      // Skill already exists, just clear the field
      _customSkillController.clear();
    }
  }

  Future<void> _saveInterestsPreferences() async {
    // Save to SharedPreferences for now
    // Future enhancement: Save to Firebase user profile for cross-device sync
    final prefs = await SharedPreferences.getInstance();

    // Flatten all interests into a single map
    final Map<String, List<String>> allInterests = {};
    _selectedInterests.forEach((category, interests) {
      if (interests.isNotEmpty) {
        allInterests[category] = interests.toList();
      }
    });

    // Save as JSON string
    if (allInterests.isNotEmpty) {
      // For now, save each category separately
      allInterests.forEach((category, interests) async {
        await prefs.setStringList('interests_$category', interests);
      });
    }
  }

  String _normalizeInterest(String interest) {
    // Normalize interest name: trim whitespace, capitalize first letter of each word
    return interest
        .trim()
        .split(' ')
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  void _addCustomInterest() {
    final interest = _customInterestController.text.trim();
    if (interest.isEmpty) return;

    final normalizedInterest = _normalizeInterest(interest);

    // Check for duplicates (case-insensitive) in current category
    final currentCategoryInterests = _selectedInterests[_currentInterestCategory]!;
    final predefinedInterests = _interestCategories[_currentInterestCategory]!;

    final isDuplicate = currentCategoryInterests.any(
      (i) => i.toLowerCase() == normalizedInterest.toLowerCase()
    ) || predefinedInterests.any(
      (i) => i.toLowerCase() == normalizedInterest.toLowerCase()
    );

    if (!isDuplicate) {
      setState(() {
        currentCategoryInterests.add(normalizedInterest);
        _customInterestController.clear();
      });
    } else {
      // Interest already exists, just clear the field
      _customInterestController.clear();
    }
  }

  String _getLocalizedCategoryName(String category) {
    switch (category) {
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
      case 'restaurants':
        return AppLocalizations.of(context)!.restaurants;
      case 'bars':
        return AppLocalizations.of(context)!.bars;
      case 'clubs':
        return AppLocalizations.of(context)!.clubs;
      case 'coffee shops':
        return AppLocalizations.of(context)!.coffeeShops;
      case 'shops':
        return AppLocalizations.of(context)!.shops;
      case 'services':
        return AppLocalizations.of(context)!.services;
      case 'people':
        return AppLocalizations.of(context)!.people;
      case 'friendships':
        return AppLocalizations.of(context)!.friendships;
      case 'experiences':
        return AppLocalizations.of(context)!.experiences;
      case 'dating':
        return AppLocalizations.of(context)!.dating;
      case 'trips':
        return AppLocalizations.of(context)!.trips;
      case 'sight seeing':
        return AppLocalizations.of(context)!.sightSeeing;
      case 'documentary':
        return AppLocalizations.of(context)!.documentary;
      case 'stand up comedy':
        return AppLocalizations.of(context)!.standUpComedy;
      case 'anime':
        return AppLocalizations.of(context)!.anime;
      case 'manga':
        return AppLocalizations.of(context)!.manga;
      case 'cartoons':
        return AppLocalizations.of(context)!.cartoons;
      default:
        return category;
    }
  }

  Widget _buildRecommendationsPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        children: [
          // Title
          Text(
            AppLocalizations.of(context)!.whatRecommendationsAreLookingFor,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)!.selectCategoriesForRecommendations,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Recommendations chips - fills available space without scrolling
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Wrap(
                spacing: 6.0,
                runSpacing: 6.0,
                alignment: WrapAlignment.center,
                children: _recommendationCategories.map((category) {
                  final isSelected = _selectedCategories.contains(category);
                  return InkWell(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedCategories.remove(category);
                        } else {
                          _selectedCategories.add(category);
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: isSelected ? const LinearGradient(
                          colors: [Color(0xFF1976D2), Color(0xFF1565C0)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ) : null,
                        color: isSelected ? null : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? Colors.blue.shade700 : Colors.grey.shade300,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isSelected)
                            const Padding(
                              padding: EdgeInsets.only(right: 4),
                              child: Icon(Icons.check, color: Colors.white, size: 14),
                            ),
                          Text(
                            _getLocalizedCategoryName(category),
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        children: [
          // Title
          Text(
            AppLocalizations.of(context)!.whatAreYourSkills,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)!.selectYourSkillsOrAddCustom,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Custom skill input field - more compact
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _customSkillController,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.addCustomSkill,
                    hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.green, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    isDense: true,
                  ),
                  onSubmitted: (_) => _addCustomSkill(),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                height: 38,
                width: 38,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: _addCustomSkill,
                  icon: const Icon(Icons.add, color: Colors.white, size: 20),
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Skills chips - fills available space without scrolling
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Wrap(
                spacing: 6.0,
                runSpacing: 6.0,
                alignment: WrapAlignment.center,
                children: [
                  // Predefined skills
                  ..._predefinedSkills.map((skill) {
                    final isSelected = _selectedSkills.contains(skill);
                    return InkWell(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedSkills.remove(skill);
                          } else {
                            _selectedSkills.add(skill);
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: isSelected ? const LinearGradient(
                            colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ) : null,
                          color: isSelected ? null : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? Colors.green.shade700 : Colors.grey.shade300,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isSelected)
                              const Padding(
                                padding: EdgeInsets.only(right: 4),
                                child: Icon(Icons.check, color: Colors.white, size: 14),
                              ),
                            Text(
                              skill,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black87,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  // Custom skills (not in predefined list)
                  ..._selectedSkills
                      .where((skill) => !_predefinedSkills.contains(skill))
                      .map((skill) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check, color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            skill,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 4),
                          InkWell(
                            onTap: () {
                              setState(() {
                                _selectedSkills.remove(skill);
                              });
                            },
                            child: const Icon(Icons.close, color: Colors.white, size: 14),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestsPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        children: [
          // Title
          Text(
            AppLocalizations.of(context)!.whatAreYourInterests,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)!.selectInterestsToPersonalize,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Category tabs in grid
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              alignment: WrapAlignment.center,
              children: _interestCategories.keys.map((category) {
                final isSelected = _currentInterestCategory == category;
                return InkWell(
                  onTap: () {
                    setState(() {
                      _currentInterestCategory = category;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.purple : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? Colors.purple : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected ? [
                        BoxShadow(
                          color: Colors.purple.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ] : null,
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // Custom interest input field - more compact
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _customInterestController,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.addCustomInterest,
                    hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.purple, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    isDense: true,
                  ),
                  onSubmitted: (_) => _addCustomInterest(),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                height: 38,
                width: 38,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: _addCustomInterest,
                  icon: const Icon(Icons.add, color: Colors.white, size: 20),
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Interests chips - fills available space without scrolling
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Wrap(
                spacing: 6.0,
                runSpacing: 6.0,
                children: [
                  // Predefined interests for current category
                  ..._interestCategories[_currentInterestCategory]!.map((interest) {
                    final isSelected = _selectedInterests[_currentInterestCategory]!.contains(interest);
                    return InkWell(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedInterests[_currentInterestCategory]!.remove(interest);
                          } else {
                            _selectedInterests[_currentInterestCategory]!.add(interest);
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: isSelected ? const LinearGradient(
                            colors: [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ) : null,
                          color: isSelected ? null : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? Colors.purple.shade700 : Colors.grey.shade300,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isSelected)
                              const Padding(
                                padding: EdgeInsets.only(right: 4),
                                child: Icon(Icons.check, color: Colors.white, size: 14),
                              ),
                            Text(
                              interest,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black87,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  // Custom interests (not in predefined list)
                  ..._selectedInterests[_currentInterestCategory]!
                      .where((interest) => !_interestCategories[_currentInterestCategory]!.contains(interest))
                      .map((interest) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check, color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            interest,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 4),
                          InkWell(
                            onTap: () {
                              setState(() {
                                _selectedInterests[_currentInterestCategory]!.remove(interest);
                              });
                            },
                            child: const Icon(Icons.close, color: Colors.white, size: 14),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Image.asset(
          'assets/images/light_yajid_logo.png',
          height: 64, // 80% of 80 = 64
          width: 64,  // 80% of 80 = 64
          fit: BoxFit.contain,
        ),
        centerTitle: true,
        actions: [
          if (_currentPage < _pages.length + 2)
            TextButton(
              onPressed: _skipOnboarding,
              child: Text(
                AppLocalizations.of(context)!.skip,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: _pages.length + 3, // +3 for recommendations, skills, and interests pages
              itemBuilder: (context, index) {
                if (index == 0) {
                  // Custom recommendations page
                  return _buildRecommendationsPage();
                } else if (index == 1) {
                  // Custom skills page
                  return _buildSkillsPage();
                } else if (index == 2) {
                  // Custom interests page
                  return _buildInterestsPage();
                }
                final page = _pages[index - 3]; // Adjust index for the pages list
                return Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: page.color.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          page.icon,
                          size: 60,
                          color: page.color,
                        ),
                      ),
                      const SizedBox(height: 48),
                      Text(
                        _getLocalizedText(page.titleKey),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _getLocalizedText(page.descriptionKey),
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                // Page indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length + 3, // +3 for recommendations, skills, and interests pages
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? (index == 0
                                ? Colors.blue
                                : index == 1
                                  ? Colors.green
                                  : index == 2
                                    ? Colors.purple
                                    : _pages[index - 3].color)
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Navigation buttons
                Row(
                  children: [
                    if (_currentPage > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _previousPage,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey.shade600,
                            side: BorderSide(color: Colors.grey.shade300),
                            minimumSize: const Size(double.infinity, 48),
                          ),
                          child: Text(AppLocalizations.of(context)!.previous),
                        ),
                      ),
                    if (_currentPage > 0) const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _currentPage == 0
                              ? Colors.blue
                              : _currentPage == 1
                                ? Colors.green
                                : _currentPage == 2
                                  ? Colors.purple
                                  : _pages[_currentPage - 3].color,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 48),
                          elevation: 0,
                        ),
                        child: Text(
                          _currentPage < _pages.length + 2
                              ? AppLocalizations.of(context)!.next
                              : AppLocalizations.of(context)!.getStarted,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getLocalizedText(String key) {
    final localizations = AppLocalizations.of(context)!;
    switch (key) {
      case 'onboardingWelcomeTitle':
        return localizations.onboardingWelcomeTitle;
      case 'onboardingWelcomeDescription':
        return localizations.onboardingWelcomeDescription;
      case 'onboardingSecurityTitle':
        return localizations.onboardingSecurityTitle;
      case 'onboardingSecurityDescription':
        return localizations.onboardingSecurityDescription;
      case 'onboardingCommunityTitle':
        return localizations.onboardingCommunityTitle;
      case 'onboardingCommunityDescription':
        return localizations.onboardingCommunityDescription;
      case 'onboardingReadyTitle':
        return localizations.onboardingReadyTitle;
      case 'onboardingReadyDescription':
        return localizations.onboardingReadyDescription;
      default:
        return key;
    }
  }
}

class OnboardingPage {
  final IconData icon;
  final String titleKey;
  final String descriptionKey;
  final Color color;

  const OnboardingPage({
    required this.icon,
    required this.titleKey,
    required this.descriptionKey,
    required this.color,
  });
}