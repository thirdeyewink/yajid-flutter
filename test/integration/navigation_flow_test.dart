import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yajid/widgets/shared_bottom_nav.dart';
import 'package:yajid/l10n/app_localizations.dart';

/// Integration test for app navigation flows
/// Tests user navigation between main screens using bottom navigation
void main() {
  group('Navigation Flow Integration Tests', () {
    testWidgets('User can navigate between all tabs', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const TestNavigationApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Initially on Home (AppBar title + Body text = 2 widgets)
      expect(find.text('Home Screen'), findsNWidgets(2));
      expect(find.text('Discover Screen'), findsNothing);

      // Navigate to Discover
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      expect(find.text('Home Screen'), findsNothing);
      expect(find.text('Discover Screen'), findsNWidgets(2));

      // Navigate to Add Content
      await tester.tap(find.byIcon(Icons.add_circle_outline));
      await tester.pumpAndSettle();

      expect(find.text('Add Content Screen'), findsNWidgets(2));

      // Navigate to Calendar
      await tester.tap(find.byIcon(Icons.calendar_today_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Calendar Screen'), findsNWidgets(2));

      // Navigate to Profile
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();

      expect(find.text('Profile Screen'), findsNWidgets(2));

      // Navigate back to Home
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();

      expect(find.text('Home Screen'), findsNWidgets(2));
    });

    testWidgets('Bottom nav highlights current tab', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const TestNavigationApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Get bottom nav bar
      final bottomNavBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );

      // Initially index 0 (Home)
      expect(bottomNavBar.currentIndex, 0);

      // Navigate to Profile (index 4)
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();

      final updatedBottomNavBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(updatedBottomNavBar.currentIndex, 4);
    });

    testWidgets('Navigation persists screen state', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const TestNavigationApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Enter text in home screen
      await tester.enterText(find.byType(TextField).first, 'Test State');
      await tester.pumpAndSettle();

      // Navigate away
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();

      // Navigate back
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();

      // State should be preserved
      expect(find.text('Test State'), findsOneWidget);
    });

    testWidgets('Rapid navigation does not cause crashes', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const TestNavigationApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Rapidly tap different tabs
      await tester.tap(find.byIcon(Icons.search));
      await tester.tap(find.byIcon(Icons.person));
      await tester.tap(find.byIcon(Icons.home));
      await tester.tap(find.byIcon(Icons.add_circle_outline));
      await tester.pumpAndSettle();

      // Should be on Add Content screen (AppBar + Body = 2 widgets)
      expect(find.text('Add Content Screen'), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    });

    testWidgets('Bottom navigation maintains proper order', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const TestNavigationApp(),
        ),
      );

      await tester.pumpAndSettle();

      final bottomNavBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );

      // Verify order: Home, Discover, Add, Calendar, Profile
      expect((bottomNavBar.items[0].icon as Icon).icon, Icons.home);
      expect((bottomNavBar.items[1].icon as Icon).icon, Icons.search);
      expect((bottomNavBar.items[2].icon as Icon).icon, Icons.add_circle_outline);
      expect((bottomNavBar.items[3].icon as Icon).icon, Icons.calendar_today_outlined);
      expect((bottomNavBar.items[4].icon as Icon).icon, Icons.person);
    });
  });
}

/// Test app with navigation between screens
class TestNavigationApp extends StatefulWidget {
  const TestNavigationApp({super.key});

  @override
  State<TestNavigationApp> createState() => _TestNavigationAppState();
}

class _TestNavigationAppState extends State<TestNavigationApp> {
  int _currentIndex = 0;
  final List<Widget> _screens = const [
    TestHomeScreen(),
    TestDiscoverScreen(),
    TestAddContentScreen(),
    TestCalendarScreen(),
    TestProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: SharedBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class TestHomeScreen extends StatefulWidget {
  const TestHomeScreen({super.key});

  @override
  State<TestHomeScreen> createState() => _TestHomeScreenState();
}

class _TestHomeScreenState extends State<TestHomeScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Screen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Home Screen'),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'Enter text',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TestDiscoverScreen extends StatelessWidget {
  const TestDiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discover Screen')),
      body: const Center(child: Text('Discover Screen')),
    );
  }
}

class TestAddContentScreen extends StatelessWidget {
  const TestAddContentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Content Screen')),
      body: const Center(child: Text('Add Content Screen')),
    );
  }
}

class TestCalendarScreen extends StatelessWidget {
  const TestCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendar Screen')),
      body: const Center(child: Text('Calendar Screen')),
    );
  }
}

class TestProfileScreen extends StatelessWidget {
  const TestProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile Screen')),
      body: const Center(child: Text('Profile Screen')),
    );
  }
}
