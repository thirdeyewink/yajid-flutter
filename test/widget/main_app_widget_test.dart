import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:yajid/main.dart';
import 'package:yajid/bloc/auth/auth_bloc.dart';
import 'package:yajid/bloc/auth/auth_state.dart';
import 'package:yajid/bloc/navigation/navigation_bloc.dart';
import 'package:yajid/bloc/navigation/navigation_state.dart';
import 'package:yajid/bloc/navigation/navigation_event.dart';
import 'package:yajid/bloc/profile/profile_bloc.dart';
import 'package:yajid/bloc/profile/profile_state.dart';
import 'package:yajid/auth_screen.dart';
import 'package:yajid/home_screen.dart';
import 'package:yajid/onboarding_screen.dart';
import 'package:yajid/onboarding_provider.dart';
import 'package:yajid/locale_provider.dart';
import 'package:yajid/theme_provider.dart';
import 'package:yajid/l10n/app_localizations.dart';

// Mock classes
class MockAuthBloc extends Mock implements AuthBloc {
  @override
  Future<void> close() async {}
}
class MockNavigationBloc extends Mock implements NavigationBloc {
  @override
  Future<void> close() async {}
}
class MockProfileBloc extends Mock implements ProfileBloc {
  @override
  Future<void> close() async {}
}
class MockUser extends Mock implements User {}
class MockOnboardingProvider extends Mock implements OnboardingProvider {}
class MockLocaleProvider extends Mock implements LocaleProvider {}
class MockThemeProvider extends Mock implements ThemeProvider {}

void main() {
  group('Main App Widget Tests', () {
    late MockAuthBloc mockAuthBloc;
    late MockNavigationBloc mockNavigationBloc;
    late MockProfileBloc mockProfileBloc;
    late MockUser mockUser;
    late MockOnboardingProvider mockOnboardingProvider;
    late MockLocaleProvider mockLocaleProvider;
    late MockThemeProvider mockThemeProvider;

    setUp(() {
      mockAuthBloc = MockAuthBloc();
      mockNavigationBloc = MockNavigationBloc();
      mockProfileBloc = MockProfileBloc();
      mockUser = MockUser();
      mockOnboardingProvider = MockOnboardingProvider();
      mockLocaleProvider = MockLocaleProvider();
      mockThemeProvider = MockThemeProvider();

      // Setup default mock behaviors
      when(() => mockAuthBloc.state).thenReturn(const AuthInitial());
      when(() => mockAuthBloc.stream).thenAnswer((_) => Stream.value(const AuthInitial()));
      when(() => mockNavigationBloc.state).thenReturn(const NavigationState(
        currentTab: NavigationTab.home,
        currentIndex: 0,
      ));
      when(() => mockNavigationBloc.stream).thenAnswer((_) => Stream.value(const NavigationState(
        currentTab: NavigationTab.home,
        currentIndex: 0,
      )));
      when(() => mockProfileBloc.state).thenReturn(const ProfileInitial());
      when(() => mockProfileBloc.stream).thenAnswer((_) => Stream.value(const ProfileInitial()));
      when(() => mockUser.uid).thenReturn('test-uid');
      when(() => mockUser.email).thenReturn('test@example.com');
      when(() => mockOnboardingProvider.isLoading).thenReturn(false);
      when(() => mockOnboardingProvider.isOnboardingCompleted).thenReturn(true);
      when(() => mockLocaleProvider.locale).thenReturn(const Locale('en', 'US'));
      when(() => mockThemeProvider.themeData).thenReturn(ThemeData.light());
    });

    Widget createTestApp({AuthState? authState}) {
      when(() => mockAuthBloc.state).thenReturn(authState ?? const AuthInitial());

      return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: mockLocaleProvider),
          ChangeNotifierProvider.value(value: mockThemeProvider),
          ChangeNotifierProvider.value(value: mockOnboardingProvider),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>(create: (_) => mockAuthBloc),
            BlocProvider<NavigationBloc>(create: (_) => mockNavigationBloc),
            BlocProvider<ProfileBloc>(create: (_) => mockProfileBloc),
          ],
          child: Consumer2<LocaleProvider, ThemeProvider>(
            builder: (context, localeProvider, themeProvider, child) {
              return MaterialApp(
                title: 'Yajid Social',
                theme: themeProvider.themeData,
                locale: localeProvider.locale,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: const AuthWrapper(),
              );
            },
          ),
        ),
      );
    }

    testWidgets('should show loading indicator when AuthInitial', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show loading indicator when AuthLoading', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(authState: const AuthLoading()));
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show AuthScreen when AuthUnauthenticated', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(authState: const AuthUnauthenticated()));
      await tester.pumpAndSettle();

      expect(find.byType(AuthScreen), findsOneWidget);
    });

    testWidgets('should show OnboardingScreen when authenticated but onboarding not completed', (WidgetTester tester) async {
      when(() => mockOnboardingProvider.isOnboardingCompleted).thenReturn(false);

      await tester.pumpWidget(createTestApp(authState: AuthAuthenticated(user: mockUser)));
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingScreen), findsOneWidget);
    });

    testWidgets('should show HomeScreen when authenticated and onboarding completed', (WidgetTester tester) async {
      when(() => mockOnboardingProvider.isOnboardingCompleted).thenReturn(true);

      await tester.pumpWidget(createTestApp(authState: AuthAuthenticated(user: mockUser)));
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('should show loading indicator when onboarding provider is loading', (WidgetTester tester) async {
      when(() => mockOnboardingProvider.isLoading).thenReturn(true);

      await tester.pumpWidget(createTestApp(authState: AuthAuthenticated(user: mockUser)));
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should have correct app title', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      final MaterialApp materialApp = tester.widget(find.byType(MaterialApp));
      expect(materialApp.title, equals('Yajid Social'));
    });

    testWidgets('should support multiple locales', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      final MaterialApp materialApp = tester.widget(find.byType(MaterialApp));

      expect(materialApp.supportedLocales.length, greaterThan(1));
      expect(materialApp.supportedLocales.any((locale) => locale.languageCode == 'en'), true);
      expect(materialApp.supportedLocales.any((locale) => locale.languageCode == 'es'), true);
      expect(materialApp.supportedLocales.any((locale) => locale.languageCode == 'fr'), true);
      expect(materialApp.supportedLocales.any((locale) => locale.languageCode == 'ar'), true);
      expect(materialApp.supportedLocales.any((locale) => locale.languageCode == 'pt'), true);
    });

    testWidgets('should respond to auth state changes', (WidgetTester tester) async {
      // Start with unauthenticated state
      await tester.pumpWidget(createTestApp(authState: const AuthUnauthenticated()));
      await tester.pumpAndSettle();

      expect(find.byType(AuthScreen), findsOneWidget);

      // Change to authenticated state
      when(() => mockAuthBloc.state).thenReturn(AuthAuthenticated(user: mockUser));
      when(() => mockAuthBloc.stream).thenAnswer((_) => Stream.value(AuthAuthenticated(user: mockUser)));

      // Trigger rebuild by emitting new state
      await tester.pump();

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(AuthScreen), findsNothing);
    });

    testWidgets('should properly dispose of BLoCs', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Remove the widget tree
      await tester.pumpWidget(Container());

      // BLoCs should be disposed (can't directly test this, but no exceptions should occur)
      expect(tester.takeException(), isNull);
    });
  });

  group('AuthWrapper Widget Tests', () {
    late MockAuthBloc mockAuthBloc;
    late MockUser mockUser;
    late MockOnboardingProvider mockOnboardingProvider;
    late MockLocaleProvider mockLocaleProvider;
    late MockThemeProvider mockThemeProvider;

    setUp(() {
      mockAuthBloc = MockAuthBloc();
      mockUser = MockUser();
      mockOnboardingProvider = MockOnboardingProvider();
      mockLocaleProvider = MockLocaleProvider();
      mockThemeProvider = MockThemeProvider();

      when(() => mockAuthBloc.state).thenReturn(const AuthInitial());
      when(() => mockAuthBloc.stream).thenAnswer((_) => Stream.value(const AuthInitial()));
      when(() => mockUser.uid).thenReturn('test-uid');
      when(() => mockOnboardingProvider.isLoading).thenReturn(false);
      when(() => mockOnboardingProvider.isOnboardingCompleted).thenReturn(true);
      when(() => mockLocaleProvider.locale).thenReturn(const Locale('en', 'US'));
      when(() => mockThemeProvider.themeData).thenReturn(ThemeData.light());
    });

    Widget createAuthWrapperTest({AuthState? authState}) {
      when(() => mockAuthBloc.state).thenReturn(authState ?? const AuthInitial());

      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider<AuthBloc>(
          create: (_) => mockAuthBloc,
          child: MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: mockLocaleProvider),
              ChangeNotifierProvider.value(value: mockThemeProvider),
              ChangeNotifierProvider.value(value: mockOnboardingProvider),
            ],
            child: const AuthWrapper(),
          ),
        ),
      );
    }

    testWidgets('AuthWrapper shows loading for AuthInitial', (WidgetTester tester) async {
      await tester.pumpWidget(createAuthWrapperTest());
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('AuthWrapper shows loading for AuthLoading', (WidgetTester tester) async {
      await tester.pumpWidget(createAuthWrapperTest(authState: const AuthLoading()));
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('AuthWrapper shows AuthScreen for unauthenticated user', (WidgetTester tester) async {
      await tester.pumpWidget(createAuthWrapperTest(authState: const AuthUnauthenticated()));
      await tester.pumpAndSettle();

      expect(find.byType(AuthScreen), findsOneWidget);
    });

    testWidgets('AuthWrapper shows OnboardingScreen for authenticated user without onboarding', (WidgetTester tester) async {
      when(() => mockOnboardingProvider.isOnboardingCompleted).thenReturn(false);

      await tester.pumpWidget(createAuthWrapperTest(authState: AuthAuthenticated(user: mockUser)));
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingScreen), findsOneWidget);
    });

    testWidgets('AuthWrapper shows HomeScreen for authenticated user with onboarding completed', (WidgetTester tester) async {
      when(() => mockOnboardingProvider.isOnboardingCompleted).thenReturn(true);

      await tester.pumpWidget(createAuthWrapperTest(authState: AuthAuthenticated(user: mockUser)));
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });
}