import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yajid/models/recommendation_model.dart';
import 'package:yajid/l10n/app_localizations.dart';

/// Integration test for recommendation browsing flow
/// Tests the complete user journey from viewing to filtering recommendations
void main() {
  group('Recommendation Flow Integration Tests', () {
    testWidgets('User can browse and filter recommendations', (WidgetTester tester) async {
      final now = DateTime.now();
      // Create test recommendations
      final testRecommendations = <Recommendation>[
        Recommendation(
          id: 'rec1',
          title: 'Test Movie',
          category: 'movies',
          creator: 'Director Name',
          details: 'A great movie',
          platform: 'Netflix',
          whyLike: 'Great story',
          communityRating: 4.5,
          imageUrl: 'https://example.com/image1.jpg',
          createdAt: now,
          updatedAt: now,
        ),
        Recommendation(
          id: 'rec2',
          title: 'Test Restaurant',
          category: 'businesses',
          creator: 'Chef Name',
          details: 'A nice restaurant',
          platform: 'Local',
          whyLike: 'Great food',
          communityRating: 4.0,
          imageUrl: 'https://example.com/image2.jpg',
          createdAt: now,
          updatedAt: now,
        ),
        Recommendation(
          id: 'rec3',
          title: 'Test Book',
          category: 'books',
          creator: 'Author Name',
          details: 'An amazing book',
          platform: 'Kindle',
          whyLike: 'Great read',
          communityRating: 5.0,
          imageUrl: 'https://example.com/image3.jpg',
          createdAt: now,
          updatedAt: now,
        ),
      ];

      // Build a simple test app with recommendations
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: TestRecommendationScreen(recommendations: testRecommendations),
        ),
      );

      await tester.pumpAndSettle();

      // Verify initial state shows all recommendations
      expect(find.text('Test Movie'), findsOneWidget);
      expect(find.text('Test Restaurant'), findsOneWidget);
      expect(find.text('Test Book'), findsOneWidget);

      // Test filtering by category
      await tester.tap(find.text('Movies'));
      await tester.pumpAndSettle();

      // Should show only movies
      expect(find.text('Test Movie'), findsOneWidget);
      expect(find.text('Test Restaurant'), findsNothing);
      expect(find.text('Test Book'), findsNothing);

      // Test showing all again
      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();

      expect(find.text('Test Movie'), findsOneWidget);
      expect(find.text('Test Restaurant'), findsOneWidget);
      expect(find.text('Test Book'), findsOneWidget);

      // Test filtering by books
      await tester.tap(find.text('Books'));
      await tester.pumpAndSettle();

      expect(find.text('Test Book'), findsOneWidget);
      expect(find.text('Test Movie'), findsNothing);
    });

    testWidgets('User can search recommendations', (WidgetTester tester) async {
      final now = DateTime.now();
      final testRecommendations = <Recommendation>[
        Recommendation(
          id: 'rec1',
          title: 'The Great Movie',
          category: 'movies',
          creator: 'Director',
          details: 'Details',
          platform: 'Netflix',
          whyLike: 'Reason',
          communityRating: 4.5,
          createdAt: now,
          updatedAt: now,
        ),
        Recommendation(
          id: 'rec2',
          title: 'Amazing Restaurant',
          category: 'businesses',
          creator: 'Chef',
          details: 'Details',
          platform: 'Local',
          whyLike: 'Reason',
          communityRating: 4.0,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: TestRecommendationScreen(recommendations: testRecommendations),
        ),
      );

      await tester.pumpAndSettle();

      // Find search field and enter text
      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      await tester.enterText(searchField, 'Movie');
      await tester.pumpAndSettle();

      // Should show only matching items
      expect(find.text('The Great Movie'), findsOneWidget);
      expect(find.text('Amazing Restaurant'), findsNothing);

      // Clear search
      await tester.enterText(searchField, '');
      await tester.pumpAndSettle();

      // Should show all again
      expect(find.text('The Great Movie'), findsOneWidget);
      expect(find.text('Amazing Restaurant'), findsOneWidget);
    });

    testWidgets('User can sort recommendations by rating', (WidgetTester tester) async {
      final now = DateTime.now();
      final testRecommendations = <Recommendation>[
        Recommendation(
          id: 'rec1',
          title: 'Low Rated',
          category: 'movies',
          creator: 'Director',
          details: 'Details',
          platform: 'Netflix',
          whyLike: 'Reason',
          communityRating: 3.0,
          createdAt: now,
          updatedAt: now,
        ),
        Recommendation(
          id: 'rec2',
          title: 'High Rated',
          category: 'movies',
          creator: 'Director',
          details: 'Details',
          platform: 'Netflix',
          whyLike: 'Reason',
          communityRating: 5.0,
          createdAt: now,
          updatedAt: now,
        ),
        Recommendation(
          id: 'rec3',
          title: 'Medium Rated',
          category: 'movies',
          creator: 'Director',
          details: 'Details',
          platform: 'Netflix',
          whyLike: 'Reason',
          communityRating: 4.0,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: TestRecommendationScreen(recommendations: testRecommendations),
        ),
      );

      await tester.pumpAndSettle();

      // Tap sort button
      await tester.tap(find.byIcon(Icons.sort));
      await tester.pumpAndSettle();

      // After sorting, high rated should appear first
      final textWidgets = tester.widgetList<Text>(find.byType(Text));
      final names = textWidgets
          .where((widget) => widget.data != null)
          .map((widget) => widget.data!)
          .where((text) => text.contains('Rated'))
          .toList();

      expect(names.first, contains('High'));
    });

    testWidgets('Recommendations display rating stars correctly', (WidgetTester tester) async {
      final now = DateTime.now();
      final testRecommendations = <Recommendation>[
        Recommendation(
          id: 'rec1',
          title: 'Test Item',
          category: 'movies',
          creator: 'Director',
          details: 'Details',
          platform: 'Netflix',
          whyLike: 'Reason',
          communityRating: 4.5,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: TestRecommendationScreen(recommendations: testRecommendations),
        ),
      );

      await tester.pumpAndSettle();

      // Should show rating text
      expect(find.textContaining('4.5'), findsOneWidget);

      // Should show star icon
      expect(find.byIcon(Icons.star), findsWidgets);
    });
  });
}

/// Test widget that simulates recommendation screen behavior
class TestRecommendationScreen extends StatefulWidget {
  final List<Recommendation> recommendations;

  const TestRecommendationScreen({
    super.key,
    required this.recommendations,
  });

  @override
  State<TestRecommendationScreen> createState() => _TestRecommendationScreenState();
}

class _TestRecommendationScreenState extends State<TestRecommendationScreen> {
  List<Recommendation> filteredRecommendations = [];
  String? selectedCategory;
  String searchQuery = '';
  bool sortByRating = false;

  @override
  void initState() {
    super.initState();
    filteredRecommendations = widget.recommendations;
  }

  void _filterRecommendations() {
    var filtered = widget.recommendations;

    // Apply category filter
    if (selectedCategory != null) {
      filtered = filtered
          .where((rec) => rec.category == selectedCategory)
          .toList();
    }

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      filtered = filtered
          .where((rec) =>
              rec.title.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }

    // Apply sorting
    if (sortByRating) {
      filtered.sort((a, b) => b.communityRating.compareTo(a.communityRating));
    }

    setState(() {
      filteredRecommendations = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recommendations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {
              setState(() {
                sortByRating = !sortByRating;
                _filterRecommendations();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search field
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                searchQuery = value;
                _filterRecommendations();
              },
            ),
          ),
          // Category filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: selectedCategory == null,
                  onSelected: (selected) {
                    setState(() {
                      selectedCategory = null;
                      _filterRecommendations();
                    });
                  },
                ),
                FilterChip(
                  label: const Text('Movies'),
                  selected: selectedCategory == 'movies',
                  onSelected: (selected) {
                    setState(() {
                      selectedCategory = 'movies';
                      _filterRecommendations();
                    });
                  },
                ),
                FilterChip(
                  label: const Text('Books'),
                  selected: selectedCategory == 'books',
                  onSelected: (selected) {
                    setState(() {
                      selectedCategory = 'books';
                      _filterRecommendations();
                    });
                  },
                ),
              ],
            ),
          ),
          // Recommendations list
          Expanded(
            child: ListView.builder(
              itemCount: filteredRecommendations.length,
              itemBuilder: (context, index) {
                final rec = filteredRecommendations[index];
                return ListTile(
                  title: Text(rec.title),
                  subtitle: Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text('${rec.communityRating}'),
                    ],
                  ),
                  trailing: Text(rec.category),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
