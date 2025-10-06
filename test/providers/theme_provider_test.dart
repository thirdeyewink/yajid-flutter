import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yajid/theme_provider.dart';

void main() {
  group('ThemeProvider', () {
    test('initial theme is light mode', () {
      final provider = ThemeProvider();

      expect(provider.isDarkMode, false);
    });

    test('initial themeData is light theme', () {
      final provider = ThemeProvider();

      expect(provider.themeData.brightness, Brightness.light);
    });

    test('toggleTheme switches to dark mode', () {
      final provider = ThemeProvider();

      provider.toggleTheme();

      expect(provider.isDarkMode, true);
      expect(provider.themeData.brightness, Brightness.dark);
    });

    test('toggleTheme switches back to light mode', () {
      final provider = ThemeProvider();

      provider.toggleTheme(); // to dark
      provider.toggleTheme(); // back to light

      expect(provider.isDarkMode, false);
      expect(provider.themeData.brightness, Brightness.light);
    });

    test('toggleTheme notifies listeners', () {
      final provider = ThemeProvider();
      bool notified = false;
      provider.addListener(() => notified = true);

      provider.toggleTheme();

      expect(notified, true);
    });

    test('setDarkMode sets dark mode to true', () {
      final provider = ThemeProvider();

      provider.setDarkMode(true);

      expect(provider.isDarkMode, true);
      expect(provider.themeData.brightness, Brightness.dark);
    });

    test('setDarkMode sets dark mode to false', () {
      final provider = ThemeProvider();
      provider.setDarkMode(true); // First set to dark

      provider.setDarkMode(false);

      expect(provider.isDarkMode, false);
      expect(provider.themeData.brightness, Brightness.light);
    });

    test('setDarkMode notifies listeners', () {
      final provider = ThemeProvider();
      int notificationCount = 0;
      provider.addListener(() => notificationCount++);

      provider.setDarkMode(true);
      provider.setDarkMode(false);

      expect(notificationCount, 2);
    });

    test('multiple toggles work correctly', () {
      final provider = ThemeProvider();

      provider.toggleTheme(); // dark
      expect(provider.isDarkMode, true);

      provider.toggleTheme(); // light
      expect(provider.isDarkMode, false);

      provider.toggleTheme(); // dark
      expect(provider.isDarkMode, true);

      provider.toggleTheme(); // light
      expect(provider.isDarkMode, false);
    });

    test('light theme has correct primary color', () {
      final provider = ThemeProvider();

      final theme = provider.themeData;

      expect(theme.colorScheme.primary, Colors.black);
    });

    test('dark theme has correct primary color', () {
      final provider = ThemeProvider();
      provider.setDarkMode(true);

      final theme = provider.themeData;

      expect(theme.colorScheme.primary, Colors.white);
    });

    test('light theme has white scaffold background', () {
      final provider = ThemeProvider();

      final theme = provider.themeData;

      expect(theme.scaffoldBackgroundColor, Colors.white);
    });

    test('dark theme has black scaffold background', () {
      final provider = ThemeProvider();
      provider.setDarkMode(true);

      final theme = provider.themeData;

      expect(theme.scaffoldBackgroundColor, Colors.black);
    });

    test('light theme has white app bar', () {
      final provider = ThemeProvider();

      final theme = provider.themeData;

      expect(theme.appBarTheme.backgroundColor, Colors.white);
      expect(theme.appBarTheme.foregroundColor, Colors.black);
    });

    test('dark theme has black app bar', () {
      final provider = ThemeProvider();
      provider.setDarkMode(true);

      final theme = provider.themeData;

      expect(theme.appBarTheme.backgroundColor, Colors.black);
      expect(theme.appBarTheme.foregroundColor, Colors.white);
    });

    test('both themes have zero app bar elevation', () {
      final lightProvider = ThemeProvider();
      final darkProvider = ThemeProvider();
      darkProvider.setDarkMode(true);

      expect(lightProvider.themeData.appBarTheme.elevation, 0);
      expect(darkProvider.themeData.appBarTheme.elevation, 0);
    });

    test('light theme has rounded card shape', () {
      final provider = ThemeProvider();

      final theme = provider.themeData;
      final shape = theme.cardTheme.shape as RoundedRectangleBorder;

      expect(shape.borderRadius, BorderRadius.circular(15));
    });

    test('dark theme has rounded card shape', () {
      final provider = ThemeProvider();
      provider.setDarkMode(true);

      final theme = provider.themeData;
      final shape = theme.cardTheme.shape as RoundedRectangleBorder;

      expect(shape.borderRadius, BorderRadius.circular(15));
    });

    test('both themes use Material 3', () {
      final lightProvider = ThemeProvider();
      final darkProvider = ThemeProvider();
      darkProvider.setDarkMode(true);

      expect(lightProvider.themeData.useMaterial3, true);
      expect(darkProvider.themeData.useMaterial3, true);
    });

    test('light theme elevated button has black background', () {
      final provider = ThemeProvider();

      final theme = provider.themeData;
      final buttonStyle = theme.elevatedButtonTheme.style!;

      expect(buttonStyle.backgroundColor?.resolve({}), Colors.black);
      expect(buttonStyle.foregroundColor?.resolve({}), Colors.white);
    });

    test('dark theme elevated button has white background', () {
      final provider = ThemeProvider();
      provider.setDarkMode(true);

      final theme = provider.themeData;
      final buttonStyle = theme.elevatedButtonTheme.style!;

      expect(buttonStyle.backgroundColor?.resolve({}), Colors.white);
      expect(buttonStyle.foregroundColor?.resolve({}), Colors.black);
    });

    test('light theme outlined button has black foreground', () {
      final provider = ThemeProvider();

      final theme = provider.themeData;
      final buttonStyle = theme.outlinedButtonTheme.style!;

      expect(buttonStyle.foregroundColor?.resolve({}), Colors.black);
    });

    test('dark theme outlined button has white foreground', () {
      final provider = ThemeProvider();
      provider.setDarkMode(true);

      final theme = provider.themeData;
      final buttonStyle = theme.outlinedButtonTheme.style!;

      expect(buttonStyle.foregroundColor?.resolve({}), Colors.white);
    });

    test('button shapes have 8px border radius', () {
      final provider = ThemeProvider();

      final theme = provider.themeData;
      final elevatedShape = theme.elevatedButtonTheme.style!.shape?.resolve({})
          as RoundedRectangleBorder;
      final outlinedShape = theme.outlinedButtonTheme.style!.shape?.resolve({})
          as RoundedRectangleBorder;

      expect(elevatedShape.borderRadius, BorderRadius.circular(8));
      expect(outlinedShape.borderRadius, BorderRadius.circular(8));
    });

    test('theme provider follows ChangeNotifier pattern', () {
      final provider = ThemeProvider();

      expect(provider, isA<ChangeNotifier>());
    });

    test('setDarkMode with same value still notifies', () {
      final provider = ThemeProvider();
      provider.setDarkMode(true);

      int notificationCount = 0;
      provider.addListener(() => notificationCount++);

      provider.setDarkMode(true); // Same value

      expect(notificationCount, 1);
    });

    test('removing listener stops notifications', () {
      final provider = ThemeProvider();
      int notificationCount = 0;
      void listener() => notificationCount++;

      provider.addListener(listener);
      provider.toggleTheme();
      expect(notificationCount, 1);

      provider.removeListener(listener);
      provider.toggleTheme();
      expect(notificationCount, 1); // Still 1, not 2
    });

    test('theme data changes when mode changes', () {
      final provider = ThemeProvider();
      final lightTheme = provider.themeData;

      provider.toggleTheme();
      final darkTheme = provider.themeData;

      expect(lightTheme, isNot(equals(darkTheme)));
      expect(lightTheme.brightness, isNot(equals(darkTheme.brightness)));
    });

    test('light theme color scheme is complete', () {
      final provider = ThemeProvider();
      final colorScheme = provider.themeData.colorScheme;

      expect(colorScheme.brightness, Brightness.light);
      expect(colorScheme.primary, isNotNull);
      expect(colorScheme.secondary, isNotNull);
      expect(colorScheme.surface, isNotNull);
      expect(colorScheme.error, isNotNull);
    });

    test('dark theme color scheme is complete', () {
      final provider = ThemeProvider();
      provider.setDarkMode(true);
      final colorScheme = provider.themeData.colorScheme;

      expect(colorScheme.brightness, Brightness.dark);
      expect(colorScheme.primary, isNotNull);
      expect(colorScheme.secondary, isNotNull);
      expect(colorScheme.surface, isNotNull);
      expect(colorScheme.error, isNotNull);
    });

    test('both themes have input decoration theme', () {
      final lightProvider = ThemeProvider();
      final darkProvider = ThemeProvider();
      darkProvider.setDarkMode(true);

      expect(lightProvider.themeData.inputDecorationTheme, isNotNull);
      expect(darkProvider.themeData.inputDecorationTheme, isNotNull);
    });

    test('both themes have card theme', () {
      final lightProvider = ThemeProvider();
      final darkProvider = ThemeProvider();
      darkProvider.setDarkMode(true);

      expect(lightProvider.themeData.cardTheme, isNotNull);
      expect(darkProvider.themeData.cardTheme, isNotNull);
    });

    test('both themes have switch theme', () {
      final lightProvider = ThemeProvider();
      final darkProvider = ThemeProvider();
      darkProvider.setDarkMode(true);

      expect(lightProvider.themeData.switchTheme, isNotNull);
      expect(darkProvider.themeData.switchTheme, isNotNull);
    });
  });
}
