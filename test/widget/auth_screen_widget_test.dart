import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:yajid/auth_screen.dart';
import 'package:yajid/bloc/auth/auth_bloc.dart';
import 'package:yajid/bloc/auth/auth_state.dart';
import 'package:yajid/bloc/auth/auth_event.dart';
import 'package:yajid/locale_provider.dart';
import 'package:yajid/l10n/app_localizations.dart';

// Mock classes
class MockAuthBloc extends Mock implements AuthBloc {
  @override
  Future<void> close() async {}
}
class MockUser extends Mock implements User {}

void main() {
  group('AuthScreen Widget Tests', () {
    late MockAuthBloc mockAuthBloc;
    late MockUser mockUser;

    setUp(() {
      mockAuthBloc = MockAuthBloc();
      mockUser = MockUser();

      // Setup default mock behaviors
      when(() => mockAuthBloc.state).thenReturn(const AuthInitial());
      when(() => mockAuthBloc.stream).thenAnswer((_) => Stream.value(const AuthInitial()));
      when(() => mockUser.uid).thenReturn('test-uid');
      when(() => mockUser.email).thenReturn('test@example.com');
    });

    Widget createTestWidget({AuthState? initialState}) {
      when(() => mockAuthBloc.state).thenReturn(initialState ?? const AuthInitial());

      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => LocaleProvider()),
          ],
          child: BlocProvider<AuthBloc>(
            create: (_) => mockAuthBloc,
            child: const AuthScreen(),
          ),
        ),
      );
    }

    testWidgets('should render login form by default', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Create an Account'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);
    });

    testWidgets('should show loading indicator when AuthLoading state', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(initialState: const AuthLoading()));
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Please wait...'), findsOneWidget);
    });

    testWidgets('should switch to signup form when create account is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Initially should show login form
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('First Name'), findsNothing);

      // Tap create account button
      await tester.tap(find.text('Create an Account'));
      await tester.pumpAndSettle();

      // Should now show signup form
      expect(find.text('Sign Up'), findsOneWidget);
      expect(find.text('First Name'), findsOneWidget);
      expect(find.text('Last Name'), findsOneWidget);
      expect(find.text('Phone Number'), findsOneWidget);
      expect(find.text('Sex'), findsOneWidget);
      expect(find.text('Birthday'), findsOneWidget);
      expect(find.text('Already have an account?'), findsOneWidget);
    });

    testWidgets('should validate email field', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find email field and login button
      final emailField = find.byType(TextFormField).first;
      final loginButton = find.text('Login');

      // Enter invalid email
      await tester.enterText(emailField, 'invalid-email');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.text('Please enter a valid email address'), findsOneWidget);
    });

    testWidgets('should validate password field', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find password field and login button
      final passwordField = find.byType(TextFormField).at(1); // Second TextFormField is password
      final loginButton = find.text('Login');

      // Enter short password
      await tester.enterText(passwordField, '123');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.text('Password must be at least 6 characters long'), findsOneWidget);
    });

    testWidgets('should trigger AuthSignInRequested when login form is submitted', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find form fields
      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).at(1);
      final loginButton = find.text('Login');

      // Enter valid credentials
      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'password123');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Verify that AuthSignInRequested was called
      verify(() => mockAuthBloc.add(const AuthSignInRequested(
        email: 'test@example.com',
        password: 'password123',
      ))).called(1);
    });

    testWidgets('should trigger AuthSignUpRequested when signup form is submitted', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Switch to signup form
      await tester.tap(find.text('Create an Account'));
      await tester.pumpAndSettle();

      // Find form fields in signup mode
      final firstNameField = find.byType(TextFormField).first;
      final lastNameField = find.byType(TextFormField).at(1);
      final emailField = find.byType(TextFormField).at(2);
      final passwordField = find.byType(TextFormField).at(3);
      final phoneField = find.byType(TextFormField).at(4);
      final signUpButton = find.text('Sign Up');

      // Enter valid signup data
      await tester.enterText(firstNameField, 'John');
      await tester.enterText(lastNameField, 'Doe');
      await tester.enterText(emailField, 'john@example.com');
      await tester.enterText(passwordField, 'password123');
      await tester.enterText(phoneField, '1234567890');

      // Select gender
      await tester.tap(find.byType(DropdownButtonFormField));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Male').last);
      await tester.pumpAndSettle();

      // Select birthday
      await tester.tap(find.byIcon(Icons.calendar_today_outlined));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Submit form
      await tester.tap(signUpButton);
      await tester.pumpAndSettle();

      // Verify that AuthSignUpRequested was called with correct data
      verify(() => mockAuthBloc.add(any(that: isA<AuthSignUpRequested>().having(
        (event) => event.email,
        'email',
        'john@example.com',
      ).having(
        (event) => event.firstName,
        'firstName',
        'John',
      ).having(
        (event) => event.lastName,
        'lastName',
        'Doe',
      )))).called(1);
    });

    testWidgets('should trigger AuthPasswordResetRequested when forgot password is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter email
      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'test@example.com');

      // Tap forgot password
      await tester.tap(find.text('Forgot Password?'));
      await tester.pumpAndSettle();

      // Verify that AuthPasswordResetRequested was called
      verify(() => mockAuthBloc.add(const AuthPasswordResetRequested(
        email: 'test@example.com',
      ))).called(1);
    });

    testWidgets('should trigger AuthGoogleSignInRequested when Google sign in is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find and tap Google sign in button
      final googleButton = find.text('Sign in with Google');
      await tester.tap(googleButton);
      await tester.pumpAndSettle();

      // Verify that AuthGoogleSignInRequested was called
      verify(() => mockAuthBloc.add(const AuthGoogleSignInRequested())).called(1);
    });

    testWidgets('should show error snackbar when AuthError state is emitted', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Simulate AuthError state
      when(() => mockAuthBloc.stream).thenAnswer((_) => Stream.value(
        const AuthError(message: 'Login failed'),
      ));

      // Trigger a rebuild
      await tester.pump();

      // Should show error snackbar
      expect(find.text('Login failed'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('should show success snackbar when AuthPasswordResetSent state is emitted', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Simulate AuthPasswordResetSent state
      when(() => mockAuthBloc.stream).thenAnswer((_) => Stream.value(
        const AuthPasswordResetSent(email: 'test@example.com'),
      ));

      // Trigger a rebuild
      await tester.pump();

      // Should show success snackbar
      expect(find.text('Password reset email sent'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('should disable buttons when loading', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(initialState: const AuthLoading()));
      await tester.pumpAndSettle();

      // All interactive buttons should be disabled (not found because they're replaced by loading indicator)
      expect(find.text('Login'), findsNothing);
      expect(find.text('Sign in with Google'), findsNothing);
      expect(find.text('Create an Account'), findsNothing);
    });

    testWidgets('should show language selector in app bar', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should have language icon in app bar
      expect(find.byIcon(Icons.language), findsOneWidget);

      // Tap language icon
      await tester.tap(find.byIcon(Icons.language));
      await tester.pumpAndSettle();

      // Should show language dialog
      expect(find.text('Select Language'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('Español'), findsOneWidget);
      expect(find.text('Français'), findsOneWidget);
    });

    testWidgets('should toggle password visibility', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Initially should show visibility icon (password hidden)
      expect(find.byIcon(Icons.visibility), findsOneWidget);

      // Tap visibility toggle
      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pumpAndSettle();

      // Password should now be visible (icon changes to visibility_off)
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });
  });
}