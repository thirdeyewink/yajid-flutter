import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yajid/models/gamification/points_model.dart';
import 'package:yajid/models/gamification/level_model.dart';
import 'package:yajid/widgets/gamification/points_display_widget.dart';

/// Integration test for gamification user flows
/// Tests points earning, level progression, and UI updates
void main() {
  group('Gamification Flow Integration Tests', () {
    testWidgets('User points and level display updates correctly', (WidgetTester tester) async {
      UserPoints userPoints = UserPoints.initial('user123');
      UserLevel userLevel = UserLevel.initial('user123');

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                appBar: AppBar(
                  title: const Text('Gamification Test'),
                  actions: [
                    PointsDisplayWidget(
                      userPoints: userPoints,
                      userLevel: userLevel,
                      compact: true,
                    ),
                  ],
                ),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      PointsDisplayWidget(
                        userPoints: userPoints,
                        userLevel: userLevel,
                        compact: false,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            // Simulate earning points
                            userPoints = userPoints.copyWith(
                              totalPoints: userPoints.totalPoints + 50,
                              lifetimePoints: userPoints.lifetimePoints + 50,
                            );

                            // Check for level up
                            final newLevel = LevelCalculator.calculateLevel(
                              userPoints.totalPoints,
                            );
                            if (newLevel > userLevel.level) {
                              userLevel = userLevel.copyWith(level: newLevel);
                            }
                          });
                        },
                        child: const Text('Earn 50 Points'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Initial state: 0 points, level 1
      expect(find.text('0'), findsWidgets);
      expect(find.text('Lv 1'), findsOneWidget);
      expect(find.text('Level 1'), findsOneWidget);

      // Earn points
      await tester.tap(find.text('Earn 50 Points'));
      await tester.pumpAndSettle();

      // Should show updated points
      expect(find.text('50'), findsWidgets);
      expect(find.text('Lv 1'), findsOneWidget);

      // Earn more points to level up
      await tester.tap(find.text('Earn 50 Points'));
      await tester.pumpAndSettle();

      // Should level up to 2 (100+ points)
      expect(find.text('100'), findsWidgets);
      expect(find.text('Lv 2'), findsOneWidget);
      expect(find.text('Level 2'), findsOneWidget);
    });

    testWidgets('Points display shows progress to next level', (WidgetTester tester) async {
      final userPoints = UserPoints(
        userId: 'user123',
        totalPoints: 150,
        lifetimePoints: 150,
        currentLevel: 2,
        pointsToNextLevel: 100,
        pointsByCategory: {},
        lastUpdated: DateTime.now(),
      );

      final userLevel = UserLevel(
        userId: 'user123',
        level: 2,
        tier: ExpertiseTier.novice,
        totalPoints: 150,
        pointsInCurrentLevel: 50,
        pointsRequiredForNextLevel: 150,
        lastUpdated: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: PointsDisplayWidget(
                userPoints: userPoints,
                userLevel: userLevel,
                compact: false,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show progress information
      expect(find.text('Next Level: 3'), findsOneWidget);
      expect(find.text('50 / 150'), findsOneWidget);
      expect(find.textContaining('points to go'), findsOneWidget);

      // Should show progress bar
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      // Verify progress bar value
      final progressBar = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(progressBar.value, closeTo(0.33, 0.01)); // 50/150 ≈ 0.33
    });

    testWidgets('Gamification UI handles rapid point changes', (WidgetTester tester) async {
      UserPoints userPoints = UserPoints.initial('user123');
      UserLevel userLevel = UserLevel.initial('user123');

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Points: ${userPoints.totalPoints}'),
                      Text('Level: ${userLevel.level}'),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            userPoints = userPoints.copyWith(
                              totalPoints: userPoints.totalPoints + 10,
                            );
                            final newLevel = LevelCalculator.calculateLevel(
                              userPoints.totalPoints,
                            );
                            userLevel = userLevel.copyWith(level: newLevel);
                          });
                        },
                        child: const Text('Add 10 Points'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Rapidly add points multiple times
      for (int i = 0; i < 5; i++) {
        await tester.tap(find.text('Add 10 Points'));
        await tester.pump();
      }

      await tester.pumpAndSettle();

      // Should show 50 points
      expect(find.text('Points: 50'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Different expertise tiers display correctly', (WidgetTester tester) async {
      final tiers = [
        ExpertiseTier.novice,
        ExpertiseTier.expert,
        ExpertiseTier.master,
        ExpertiseTier.legend,
      ];

      for (final tier in tiers) {
        final userPoints = UserPoints(
          userId: 'user123',
          totalPoints: 1000,
          lifetimePoints: 1000,
          currentLevel: 10,
          pointsToNextLevel: 500,
          pointsByCategory: {},
          lastUpdated: DateTime.now(),
        );

        final userLevel = UserLevel(
          userId: 'user123',
          level: 10,
          tier: tier,
          totalPoints: 1000,
          pointsInCurrentLevel: 100,
          pointsRequiredForNextLevel: 500,
          lastUpdated: DateTime.now(),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PointsDisplayWidget(
                userPoints: userPoints,
                userLevel: userLevel,
                compact: false,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Should display tier name
        expect(find.text(tier.displayName), findsOneWidget);

        // Tear down for next iteration
        await tester.pumpWidget(Container());
      }
    });

    testWidgets('Compact and full views show consistent data', (WidgetTester tester) async {
      final userPoints = UserPoints(
        userId: 'user123',
        totalPoints: 250,
        lifetimePoints: 300,
        currentLevel: 3,
        pointsToNextLevel: 150,
        pointsByCategory: {},
        lastUpdated: DateTime.now(),
      );

      final userLevel = UserLevel(
        userId: 'user123',
        level: 3,
        tier: ExpertiseTier.novice,
        totalPoints: 250,
        pointsInCurrentLevel: 50,
        pointsRequiredForNextLevel: 200,
        lastUpdated: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                PointsDisplayWidget(
                  userPoints: userPoints,
                  userLevel: userLevel,
                  compact: true,
                ),
                PointsDisplayWidget(
                  userPoints: userPoints,
                  userLevel: userLevel,
                  compact: false,
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Both should show same points
      expect(find.text('250'), findsNWidgets(2));

      // Both should indicate level 3
      expect(find.text('Lv 3'), findsOneWidget);
      expect(find.text('Level 3'), findsOneWidget);
    });

    testWidgets('Level transition shows correct progression', (WidgetTester tester) async {
      // Start at edge of level 1 (99 points)
      UserPoints userPoints = UserPoints(
        userId: 'user123',
        totalPoints: 99,
        lifetimePoints: 99,
        currentLevel: 1,
        pointsToNextLevel: 1,
        pointsByCategory: {},
        lastUpdated: DateTime.now(),
      );

      UserLevel userLevel = UserLevel(
        userId: 'user123',
        level: 1,
        tier: ExpertiseTier.novice,
        totalPoints: 99,
        pointsInCurrentLevel: 99,
        pointsRequiredForNextLevel: 100,
        lastUpdated: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: Column(
                  children: [
                    Text('Level: ${userLevel.level}'),
                    Text('Points: ${userPoints.totalPoints}'),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          userPoints = userPoints.copyWith(
                            totalPoints: userPoints.totalPoints + 2,
                          );
                          final newLevel = LevelCalculator.calculateLevel(
                            userPoints.totalPoints,
                          );
                          userLevel = userLevel.copyWith(level: newLevel);
                        });
                      },
                      child: const Text('Add 2 Points'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should be level 1
      expect(find.text('Level: 1'), findsOneWidget);

      // Add 2 points to trigger level up
      await tester.tap(find.text('Add 2 Points'));
      await tester.pumpAndSettle();

      // Should level up to 2
      expect(find.text('Level: 2'), findsOneWidget);
      expect(find.text('Points: 101'), findsOneWidget);
    });
  });
}
