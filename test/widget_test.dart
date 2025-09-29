// Basic Flutter widget test for the authentication app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:yajid/locale_provider.dart';
import 'package:yajid/theme_provider.dart';
import 'package:yajid/onboarding_provider.dart';
import 'package:yajid/services/logging_service.dart';

void main() {
  testWidgets('LocaleProvider and ThemeProvider can be created', (WidgetTester tester) async {
    // Test that our providers can be instantiated without errors
    final localeProvider = LocaleProvider();
    final themeProvider = ThemeProvider();

    expect(localeProvider, isNotNull);
    expect(themeProvider, isNotNull);
    expect(localeProvider.locale.languageCode, equals('en'));
    expect(themeProvider.isDarkMode, isFalse);
  });

  testWidgets('Providers work correctly in a MaterialApp', (WidgetTester tester) async {
    // Test a minimal app with our providers
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LocaleProvider()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: Consumer2<LocaleProvider, ThemeProvider>(
          builder: (context, localeProvider, themeProvider, child) {
            return MaterialApp(
              locale: localeProvider.locale,
              theme: themeProvider.isDarkMode ? ThemeData.dark() : ThemeData.light(),
              home: const Scaffold(
                body: Center(
                  child: Text('Test App'),
                ),
              ),
            );
          },
        ),
      ),
    );

    // Allow the widget to settle
    await tester.pumpAndSettle();

    // Verify the test app is displayed
    expect(find.text('Test App'), findsOneWidget);
  });

  testWidgets('ThemeProvider can toggle dark mode', (WidgetTester tester) async {
    final themeProvider = ThemeProvider();

    // Initial state should be light mode
    expect(themeProvider.isDarkMode, isFalse);

    // Toggle to dark mode
    themeProvider.setDarkMode(true);
    expect(themeProvider.isDarkMode, isTrue);

    // Toggle back to light mode
    themeProvider.setDarkMode(false);
    expect(themeProvider.isDarkMode, isFalse);
  });

  testWidgets('LocaleProvider can change locale', (WidgetTester tester) async {
    final localeProvider = LocaleProvider();

    // Initial state should be English
    expect(localeProvider.locale.languageCode, equals('en'));

    // Change to Spanish
    localeProvider.setLocale(const Locale('es'));
    expect(localeProvider.locale.languageCode, equals('es'));

    // Change to French
    localeProvider.setLocale(const Locale('fr'));
    expect(localeProvider.locale.languageCode, equals('fr'));
  });

  test('OnboardingProvider can be instantiated', () {
    final onboardingProvider = OnboardingProvider();

    // Should be able to create instance
    expect(onboardingProvider, isNotNull);
    expect(onboardingProvider.isLoading, isTrue);
  });

  test('LoggingService provides consistent instance', () {
    final logger1 = LoggingService();
    final logger2 = LoggingService();

    // Should be the same instance (singleton pattern)
    expect(identical(logger1, logger2), isTrue);
  });

  test('Supported locales include all expected languages', () {
    final localeProvider = LocaleProvider();

    // Test that all supported locales work
    const supportedLanguages = ['en', 'es', 'fr', 'ar', 'pt'];

    for (final lang in supportedLanguages) {
      localeProvider.setLocale(Locale(lang));
      expect(localeProvider.locale.languageCode, equals(lang));
    }
  });
}