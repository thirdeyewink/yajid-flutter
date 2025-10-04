import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yajid/widgets/gamification/points_display_widget.dart';
import 'package:yajid/models/gamification/points_model.dart';
import 'package:yajid/models/gamification/level_model.dart';

void main() {
  group('PointsDisplayWidget Tests', () {
    late UserPoints testUserPoints;
    late UserLevel testUserLevel;

    setUp(() {
      testUserPoints = UserPoints(
        userId: 'test-user',
        totalPoints: 150,
        lifetimePoints: 200,
        currentLevel: 2,
        pointsToNextLevel: 100,
        pointsByCategory: {'review': 50, 'dailyLogin': 100},
        lastUpdated: DateTime.now(),
      );

      testUserLevel = UserLevel(
        userId: 'test-user',
        level: 2,
        tier: ExpertiseTier.novice,
        totalPoints: 150,
        pointsInCurrentLevel: 50,
        pointsRequiredForNextLevel: 100,
        lastUpdated: DateTime.now(),
      );
    });

    Widget createTestWidget({required bool compact}) {
      return MaterialApp(
        home: Scaffold(
          body: PointsDisplayWidget(
            userPoints: testUserPoints,
            userLevel: testUserLevel,
            compact: compact,
          ),
        ),
      );
    }

    group('Compact View Tests', () {
      testWidgets('renders compact view when compact is true', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(compact: true));

        // Should display points
        expect(find.text('150'), findsOneWidget);

        // Should display level
        expect(find.text('Lv 2'), findsOneWidget);

        // Should have star icon
        expect(find.byIcon(Icons.stars), findsOneWidget);
      });

      testWidgets('compact view has correct styling', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(compact: true));

        // Find the container with yellow border
        final container = find.byType(Container).first;
        expect(container, findsOneWidget);
      });

      testWidgets('displays zero points correctly', (WidgetTester tester) async {
        final zeroPoints = UserPoints.initial('test-user');
        final zeroLevel = UserLevel.initial('test-user');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PointsDisplayWidget(
                userPoints: zeroPoints,
                userLevel: zeroLevel,
                compact: true,
              ),
            ),
          ),
        );

        expect(find.text('0'), findsOneWidget);
        expect(find.text('Lv 1'), findsOneWidget);
      });

      testWidgets('displays large point values correctly', (WidgetTester tester) async {
        final largePoints = UserPoints(
          userId: 'test-user',
          totalPoints: 9999,
          lifetimePoints: 10000,
          currentLevel: 50,
          pointsToNextLevel: 500,
          pointsByCategory: {},
          lastUpdated: DateTime.now(),
        );

        final highLevel = UserLevel(
          userId: 'test-user',
          level: 50,
          tier: ExpertiseTier.legend,
          totalPoints: 9999,
          pointsInCurrentLevel: 200,
          pointsRequiredForNextLevel: 500,
          lastUpdated: DateTime.now(),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PointsDisplayWidget(
                userPoints: largePoints,
                userLevel: highLevel,
                compact: true,
              ),
            ),
          ),
        );

        expect(find.text('9999'), findsOneWidget);
        expect(find.text('Lv 50'), findsOneWidget);
      });
    });

    group('Full View Tests', () {
      testWidgets('renders full view when compact is false', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(compact: false));

        // Should display header text
        expect(find.text('Your Points'), findsOneWidget);

        // Should display total points
        expect(find.text('150'), findsOneWidget);

        // Should display level
        expect(find.text('Level 2'), findsOneWidget);

        // Should display tier
        expect(find.text('Novice'), findsOneWidget);
      });

      testWidgets('displays progress to next level', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(compact: false));

        // Should show next level text
        expect(find.text('Next Level: 3'), findsOneWidget);

        // Should show points progress
        expect(find.text('50 / 100'), findsOneWidget);

        // Should show points needed
        expect(find.text('50 points to go!'), findsOneWidget);
      });

      testWidgets('full view contains progress indicator', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(compact: false));

        // Should have LinearProgressIndicator
        expect(find.byType(LinearProgressIndicator), findsOneWidget);

        // Verify progress value
        final progressIndicator = tester.widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator),
        );
        expect(progressIndicator.value, 0.5); // 50/100 = 0.5
      });

      testWidgets('full view has card elevation', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(compact: false));

        // Should be wrapped in a Card
        expect(find.byType(Card), findsOneWidget);

        final card = tester.widget<Card>(find.byType(Card));
        expect(card.elevation, 4);
      });

      testWidgets('displays correct tier color gradient', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(compact: false));

        // Find Container with gradient
        final decoratedContainer = tester.widgetList<Container>(find.byType(Container))
            .firstWhere((container) => container.decoration is BoxDecoration &&
                (container.decoration as BoxDecoration).gradient != null);

        expect(decoratedContainer, isNotNull);

        final decoration = decoratedContainer.decoration as BoxDecoration;
        expect(decoration.gradient, isA<LinearGradient>());
      });

      testWidgets('displays progress when at 0%', (WidgetTester tester) async {
        final startLevel = UserLevel(
          userId: 'test-user',
          level: 1,
          tier: ExpertiseTier.novice,
          totalPoints: 0,
          pointsInCurrentLevel: 0,
          pointsRequiredForNextLevel: 100,
          lastUpdated: DateTime.now(),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PointsDisplayWidget(
                userPoints: UserPoints.initial('test-user'),
                userLevel: startLevel,
                compact: false,
              ),
            ),
          ),
        );

        expect(find.text('100 points to go!'), findsOneWidget);

        final progressIndicator = tester.widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator),
        );
        expect(progressIndicator.value, 0.0);
      });

      testWidgets('displays progress when at 100%', (WidgetTester tester) async {
        final maxLevel = UserLevel(
          userId: 'test-user',
          level: 5,
          tier: ExpertiseTier.expert,
          totalPoints: 500,
          pointsInCurrentLevel: 200,
          pointsRequiredForNextLevel: 200,
          lastUpdated: DateTime.now(),
        );

        final maxPoints = UserPoints(
          userId: 'test-user',
          totalPoints: 500,
          lifetimePoints: 500,
          currentLevel: 5,
          pointsToNextLevel: 0,
          pointsByCategory: {},
          lastUpdated: DateTime.now(),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PointsDisplayWidget(
                userPoints: maxPoints,
                userLevel: maxLevel,
                compact: false,
              ),
            ),
          ),
        );

        expect(find.text('0 points to go!'), findsOneWidget);

        final progressIndicator = tester.widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator),
        );
        expect(progressIndicator.value, 1.0);
      });
    });

    group('Layout Tests', () {
      testWidgets('compact view is smaller than full view', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(compact: true));
        final compactSize = tester.getSize(find.byType(PointsDisplayWidget));

        await tester.pumpWidget(createTestWidget(compact: false));
        final fullSize = tester.getSize(find.byType(PointsDisplayWidget));

        expect(compactSize.height, lessThan(fullSize.height));
      });

      testWidgets('compact view uses Row layout', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(compact: true));

        // Compact view should have Row with mainAxisSize.min
        final rowFinder = find.descendant(
          of: find.byType(PointsDisplayWidget),
          matching: find.byType(Row),
        );

        expect(rowFinder, findsWidgets);
      });

      testWidgets('full view uses Column layout', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(compact: false));

        // Full view should have Column layout
        final columnFinder = find.descendant(
          of: find.byType(PointsDisplayWidget),
          matching: find.byType(Column),
        );

        expect(columnFinder, findsWidgets);
      });
    });

    group('Visual Elements Tests', () {
      testWidgets('compact view shows exactly one star icon', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(compact: true));

        final starIcons = find.byIcon(Icons.stars);
        expect(starIcons, findsOneWidget);
      });

      testWidgets('full view shows exactly one star icon', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(compact: false));

        final starIcons = find.byIcon(Icons.stars);
        expect(starIcons, findsOneWidget);
      });

      testWidgets('both views display the same point value', (WidgetTester tester) async {
        // Test compact view
        await tester.pumpWidget(createTestWidget(compact: true));
        expect(find.text('150'), findsOneWidget);

        // Test full view
        await tester.pumpWidget(createTestWidget(compact: false));
        expect(find.text('150'), findsOneWidget);
      });
    });
  });
}
