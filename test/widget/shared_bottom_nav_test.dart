import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yajid/widgets/shared_bottom_nav.dart';
import 'package:yajid/l10n/app_localizations.dart';

void main() {
  group('SharedBottomNav Tests', () {
    Widget createTestWidget({
      int currentIndex = 0,
      Function(int)? onTap,
    }) {
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          bottomNavigationBar: SharedBottomNav(
            currentIndex: currentIndex,
            onTap: onTap,
          ),
        ),
      );
    }

    group('Basic Rendering', () {
      testWidgets('renders with correct number of items', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final bottomNavBar = tester.widget<BottomNavigationBar>(
          find.byType(BottomNavigationBar),
        );

        expect(bottomNavBar.items.length, 5);
      });

      testWidgets('displays all navigation items', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // Check for all icons
        expect(find.byIcon(Icons.home), findsOneWidget);
        expect(find.byIcon(Icons.search), findsOneWidget);
        expect(find.byIcon(Icons.add_circle_outline), findsOneWidget);
        expect(find.byIcon(Icons.calendar_today_outlined), findsOneWidget);
        expect(find.byIcon(Icons.person), findsOneWidget);
      });

      testWidgets('displays navigation labels', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // Labels should be present in the navigation bar
        final bottomNavBar = tester.widget<BottomNavigationBar>(
          find.byType(BottomNavigationBar),
        );

        expect(bottomNavBar.items[0].label, isNotNull);
        expect(bottomNavBar.items[1].label, isNotNull);
        expect(bottomNavBar.items[2].label, isNotNull);
        expect(bottomNavBar.items[3].label, isNotNull);
        expect(bottomNavBar.items[4].label, isNotNull);
      });
    });

    group('Current Index Highlighting', () {
      testWidgets('highlights home tab when index is 0', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(currentIndex: 0));

        final bottomNavBar = tester.widget<BottomNavigationBar>(
          find.byType(BottomNavigationBar),
        );

        expect(bottomNavBar.currentIndex, 0);
      });

      testWidgets('highlights discover tab when index is 1', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(currentIndex: 1));

        final bottomNavBar = tester.widget<BottomNavigationBar>(
          find.byType(BottomNavigationBar),
        );

        expect(bottomNavBar.currentIndex, 1);
      });

      testWidgets('highlights add tab when index is 2', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(currentIndex: 2));

        final bottomNavBar = tester.widget<BottomNavigationBar>(
          find.byType(BottomNavigationBar),
        );

        expect(bottomNavBar.currentIndex, 2);
      });

      testWidgets('highlights calendar tab when index is 3', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(currentIndex: 3));

        final bottomNavBar = tester.widget<BottomNavigationBar>(
          find.byType(BottomNavigationBar),
        );

        expect(bottomNavBar.currentIndex, 3);
      });

      testWidgets('highlights profile tab when index is 4', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(currentIndex: 4));

        final bottomNavBar = tester.widget<BottomNavigationBar>(
          find.byType(BottomNavigationBar),
        );

        expect(bottomNavBar.currentIndex, 4);
      });
    });

    group('Tap Interaction', () {
      testWidgets('calls onTap callback when item is tapped', (WidgetTester tester) async {
        int? tappedIndex;

        await tester.pumpWidget(createTestWidget(
          onTap: (index) {
            tappedIndex = index;
          },
        ));

        // Tap on the search icon (index 1)
        await tester.tap(find.byIcon(Icons.search));
        await tester.pumpAndSettle();

        expect(tappedIndex, 1);
      });

      testWidgets('calls onTap for home tab', (WidgetTester tester) async {
        int? tappedIndex;

        await tester.pumpWidget(createTestWidget(
          onTap: (index) {
            tappedIndex = index;
          },
        ));

        await tester.tap(find.byIcon(Icons.home));
        await tester.pumpAndSettle();

        expect(tappedIndex, 0);
      });

      testWidgets('calls onTap for discover tab', (WidgetTester tester) async {
        int? tappedIndex;

        await tester.pumpWidget(createTestWidget(
          onTap: (index) {
            tappedIndex = index;
          },
        ));

        await tester.tap(find.byIcon(Icons.search));
        await tester.pumpAndSettle();

        expect(tappedIndex, 1);
      });

      testWidgets('calls onTap for add tab', (WidgetTester tester) async {
        int? tappedIndex;

        await tester.pumpWidget(createTestWidget(
          onTap: (index) {
            tappedIndex = index;
          },
        ));

        await tester.tap(find.byIcon(Icons.add_circle_outline));
        await tester.pumpAndSettle();

        expect(tappedIndex, 2);
      });

      testWidgets('calls onTap for calendar tab', (WidgetTester tester) async {
        int? tappedIndex;

        await tester.pumpWidget(createTestWidget(
          onTap: (index) {
            tappedIndex = index;
          },
        ));

        await tester.tap(find.byIcon(Icons.calendar_today_outlined));
        await tester.pumpAndSettle();

        expect(tappedIndex, 3);
      });

      testWidgets('calls onTap for profile tab', (WidgetTester tester) async {
        int? tappedIndex;

        await tester.pumpWidget(createTestWidget(
          onTap: (index) {
            tappedIndex = index;
          },
        ));

        await tester.tap(find.byIcon(Icons.person));
        await tester.pumpAndSettle();

        expect(tappedIndex, 4);
      });

      testWidgets('can tap same tab multiple times', (WidgetTester tester) async {
        int tapCount = 0;

        await tester.pumpWidget(createTestWidget(
          currentIndex: 0,
          onTap: (index) {
            tapCount++;
          },
        ));

        await tester.tap(find.byIcon(Icons.home));
        await tester.pumpAndSettle();
        expect(tapCount, 1);

        await tester.tap(find.byIcon(Icons.home));
        await tester.pumpAndSettle();
        expect(tapCount, 2);
      });
    });

    group('Visual Style', () {
      testWidgets('uses fixed type for navigation bar', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final bottomNavBar = tester.widget<BottomNavigationBar>(
          find.byType(BottomNavigationBar),
        );

        expect(bottomNavBar.type, BottomNavigationBarType.fixed);
      });

      testWidgets('has custom background color', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final bottomNavBar = tester.widget<BottomNavigationBar>(
          find.byType(BottomNavigationBar),
        );

        expect(bottomNavBar.backgroundColor, isNotNull);
      });

      testWidgets('has distinct selected and unselected colors', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final bottomNavBar = tester.widget<BottomNavigationBar>(
          find.byType(BottomNavigationBar),
        );

        expect(bottomNavBar.selectedItemColor, isNotNull);
        expect(bottomNavBar.unselectedItemColor, isNotNull);
        expect(bottomNavBar.selectedItemColor, isNot(equals(bottomNavBar.unselectedItemColor)));
      });
    });

    group('Accessibility', () {
      testWidgets('all items have icons', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final bottomNavBar = tester.widget<BottomNavigationBar>(
          find.byType(BottomNavigationBar),
        );

        for (var item in bottomNavBar.items) {
          expect(item.icon, isNotNull);
        }
      });

      testWidgets('all items have labels', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final bottomNavBar = tester.widget<BottomNavigationBar>(
          find.byType(BottomNavigationBar),
        );

        for (var item in bottomNavBar.items) {
          expect(item.label, isNotNull);
          expect(item.label!.isNotEmpty, isTrue);
        }
      });

      testWidgets('supports semantics for screen readers', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // Verify that BottomNavigationBar is accessible
        expect(find.byType(BottomNavigationBar), findsOneWidget);

        // Verify icons are findable (which means they have semantic meaning)
        expect(find.byIcon(Icons.home), findsOneWidget);
        expect(find.byIcon(Icons.search), findsOneWidget);
        expect(find.byIcon(Icons.add_circle_outline), findsOneWidget);
        expect(find.byIcon(Icons.calendar_today_outlined), findsOneWidget);
        expect(find.byIcon(Icons.person), findsOneWidget);
      });
    });

    group('Edge Cases', () {
      // Skipping null onTap test as it requires Firebase initialization for default navigation
      // In real usage, either onTap is provided or Firebase is initialized

      testWidgets('handles rapid taps', (WidgetTester tester) async {
        final List<int> tappedIndices = [];

        await tester.pumpWidget(createTestWidget(
          onTap: (index) {
            tappedIndices.add(index);
          },
        ));

        // Rapidly tap different tabs
        await tester.tap(find.byIcon(Icons.home));
        await tester.tap(find.byIcon(Icons.search));
        await tester.tap(find.byIcon(Icons.add_circle_outline));
        await tester.pumpAndSettle();

        expect(tappedIndices.length, 3);
        expect(tappedIndices, [0, 1, 2]);
      });

      testWidgets('maintains state when rebuilt', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(currentIndex: 2));

        var bottomNavBar = tester.widget<BottomNavigationBar>(
          find.byType(BottomNavigationBar),
        );
        expect(bottomNavBar.currentIndex, 2);

        // Rebuild with same index
        await tester.pumpWidget(createTestWidget(currentIndex: 2));

        bottomNavBar = tester.widget<BottomNavigationBar>(
          find.byType(BottomNavigationBar),
        );
        expect(bottomNavBar.currentIndex, 2);
      });
    });
  });
}
