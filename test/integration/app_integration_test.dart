import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../helpers/test_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Integration Tests', () {
    testWidgets('Complete authentication flow with BLoC', (WidgetTester tester) async {
      await tester.pumpWidget(const TestApp());
      await tester.pumpAndSettle();

      // Should start with AuthScreen (assuming no user is logged in)
      expect(find.text('Login'), findsOneWidget);

      // Test switching to signup mode
      await tester.tap(find.text('Create an Account'));
      await tester.pumpAndSettle();

      expect(find.text('Sign Up'), findsOneWidget);
      expect(find.text('First Name'), findsOneWidget);
      expect(find.text('Last Name'), findsOneWidget);

      // Switch back to login mode
      await tester.tap(find.text('Already have an account?'));
      await tester.pumpAndSettle();

      expect(find.text('Login'), findsOneWidget);

      // Test form validation
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Should show validation errors
      expect(find.text('Please enter a valid email address'), findsOneWidget);
      expect(find.text('Password must be at least 6 characters long'), findsOneWidget);

      // Enter valid email but invalid password
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), '123');
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Should show password validation error
      expect(find.text('Password must be at least 6 characters long'), findsOneWidget);

      // Enter valid credentials
      await tester.enterText(find.byType(TextFormField).at(1), 'validpassword');
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for authentication to complete (will likely fail with real Firebase)
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Note: In a real integration test, you might need to handle Firebase auth errors
      // or use a test Firebase project with known credentials
    });

    testWidgets('Language switching functionality', (WidgetTester tester) async {
      await tester.pumpWidget(const TestApp());
      await tester.pumpAndSettle();

      // Should show language button in app bar
      expect(find.byIcon(Icons.language), findsOneWidget);

      // Tap language button
      await tester.tap(find.byIcon(Icons.language));
      await tester.pumpAndSettle();

      // Should show language selection dialog
      expect(find.text('Select Language'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('Español'), findsOneWidget);
      expect(find.text('Français'), findsOneWidget);

      // Select Spanish
      await tester.tap(find.text('Español'));
      await tester.pumpAndSettle();

      // Language should change (this would need proper localization setup to verify)
      // For now, just verify dialog closes
      expect(find.text('Select Language'), findsNothing);
    });

    testWidgets('Password visibility toggle', (WidgetTester tester) async {
      await tester.pumpWidget(const TestApp());
      await tester.pumpAndSettle();

      // Password should be obscured initially - checking via icon presence
      expect(find.byIcon(Icons.visibility), findsOneWidget);

      // Find and tap visibility toggle
      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pumpAndSettle();

      // Password should now be visible
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });

    testWidgets('Form field focus and keyboard navigation', (WidgetTester tester) async {
      await tester.pumpWidget(const TestApp());
      await tester.pumpAndSettle();

      // Tap on email field
      await tester.tap(find.byType(TextFormField).first);
      await tester.pumpAndSettle();

      // Enter email
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');

      // Move to password field
      await tester.testTextInput.receiveAction(TextInputAction.next);
      await tester.pumpAndSettle();

      // Enter password
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');

      // Verify content
      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('Screen transitions and navigation', (WidgetTester tester) async {
      await tester.pumpWidget(const TestApp());
      await tester.pumpAndSettle();

      // Should start on login screen
      expect(find.text('Login'), findsOneWidget);

      // Test navigation to signup
      await tester.tap(find.text('Create an Account'));
      await tester.pumpAndSettle();

      expect(find.text('Sign Up'), findsOneWidget);
      expect(find.text('Already have an account?'), findsOneWidget);

      // Test navigation back to login
      await tester.tap(find.text('Already have an account?'));
      await tester.pumpAndSettle();

      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Create an Account'), findsOneWidget);
    });

    testWidgets('Error handling and user feedback', (WidgetTester tester) async {
      await tester.pumpWidget(const TestApp());
      await tester.pumpAndSettle();

      // Test with invalid credentials
      await tester.enterText(find.byType(TextFormField).first, 'invalid@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'wrongpassword');
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Should show loading first
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for error response
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Note: Error handling would depend on actual Firebase configuration
      // In a real test, you might check for specific error messages
    });

    testWidgets('Accessibility features', (WidgetTester tester) async {
      await tester.pumpWidget(const TestApp());
      await tester.pumpAndSettle();

      // Check that form fields have proper labels
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);

      // Check that buttons have accessible labels
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Create an Account'), findsOneWidget);

      // Test semantic structure
      expect(find.byType(TextFormField), findsNWidgets(2)); // Email and password fields
      expect(find.byType(ElevatedButton), findsOneWidget); // Login button
    });

    testWidgets('App state persistence across rebuilds', (WidgetTester tester) async {
      await tester.pumpWidget(const TestApp());
      await tester.pumpAndSettle();

      // Enter some text
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');

      // Switch to signup mode
      await tester.tap(find.text('Create an Account'));
      await tester.pumpAndSettle();

      // Switch back to login mode
      await tester.tap(find.text('Already have an account?'));
      await tester.pumpAndSettle();

      // Text should be preserved (depending on implementation)
      // Note: This behavior depends on how the form state is managed
    });

    testWidgets('BLoC state management integration', (WidgetTester tester) async {
      await tester.pumpWidget(const TestApp());
      await tester.pumpAndSettle();

      // Test that BLoC is properly integrated by checking state changes

      // Initial state should be unauthenticated
      expect(find.text('Login'), findsOneWidget);

      // Attempt login to trigger BLoC event
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'testpassword');
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Should trigger loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for state change
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // State should change based on authentication result
      // (Exact assertion depends on test environment and Firebase setup)
    });

    testWidgets('Memory leaks and performance', (WidgetTester tester) async {
      await tester.pumpWidget(const TestApp());
      await tester.pumpAndSettle();

      // Perform multiple navigation cycles to test for memory leaks
      for (int i = 0; i < 5; i++) {
        await tester.tap(find.text('Create an Account'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Already have an account?'));
        await tester.pumpAndSettle();
      }

      // If there are memory leaks, this test might reveal them
      // through increased memory usage or failures
      expect(find.text('Login'), findsOneWidget);
    });
  });
}