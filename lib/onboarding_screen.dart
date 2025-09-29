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
    'businesses'
  ];

  final Set<String> _selectedCategories = <String>{};

  final List<OnboardingPage> _pages = const [
    OnboardingPage(
      icon: Icons.security,
      titleKey: 'onboardingSecurityTitle',
      descriptionKey: 'onboardingSecurityDescription',
      color: Colors.green,
    ),
    OnboardingPage(
      icon: Icons.people,
      titleKey: 'onboardingCommunityTitle',
      descriptionKey: 'onboardingCommunityDescription',
      color: Colors.purple,
    ),
    OnboardingPage(
      icon: Icons.rocket_launch,
      titleKey: 'onboardingReadyTitle',
      descriptionKey: 'onboardingReadyDescription',
      color: Colors.orange,
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length) { // Total pages is _pages.length + 1, so last page index is _pages.length
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
    // TODO: Save to Firebase user profile
    // For now, save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('looking_for', _selectedCategories.toList());
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
      default:
        return category;
    }
  }

  Widget _buildRecommendationsPage() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppLocalizations.of(context)!.whatRecommendationsAreLookingFor,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.selectCategoriesForRecommendations,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: _recommendationCategories.map((category) {
                  final isSelected = _selectedCategories.contains(category);
                  return FilterChip(
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
                        if (selected) {
                          _selectedCategories.add(category);
                        } else {
                          _selectedCategories.remove(category);
                        }
                      });
                    },
                    backgroundColor: Colors.grey.shade200,
                    selectedColor: Colors.blue,
                    checkmarkColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
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
          'assets/images/logo.jpg',
          height: 64, // 80% of 80 = 64
          width: 64,  // 80% of 80 = 64
          fit: BoxFit.contain,
        ),
        centerTitle: true,
        actions: [
          if (_currentPage < _pages.length)
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
              itemCount: _pages.length + 1, // +1 for the recommendations page
              itemBuilder: (context, index) {
                if (index == 0) {
                  // Custom recommendations page
                  return _buildRecommendationsPage();
                }
                final page = _pages[index - 1]; // Adjust index for the pages list
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
                    _pages.length + 1, // +1 for recommendations page
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? (index == 0 ? Colors.blue : _pages[index - 1].color)
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
                              : _pages[_currentPage - 1].color,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 48),
                          elevation: 0,
                        ),
                        child: Text(
                          _currentPage < _pages.length
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