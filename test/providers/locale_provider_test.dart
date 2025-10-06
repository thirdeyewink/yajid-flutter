import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yajid/locale_provider.dart';
import 'package:yajid/l10n/app_localizations.dart';

void main() {
  group('LocaleProvider', () {
    test('initial locale is English', () {
      final provider = LocaleProvider();

      expect(provider.locale, const Locale('en'));
    });

    test('setLocale changes locale to Spanish', () {
      final provider = LocaleProvider();
      bool notified = false;
      provider.addListener(() => notified = true);

      provider.setLocale(const Locale('es'));

      expect(provider.locale, const Locale('es'));
      expect(notified, true);
    });

    test('setLocale changes locale to French', () {
      final provider = LocaleProvider();

      provider.setLocale(const Locale('fr'));

      expect(provider.locale, const Locale('fr'));
    });

    test('setLocale changes locale to Arabic', () {
      final provider = LocaleProvider();

      provider.setLocale(const Locale('ar'));

      expect(provider.locale, const Locale('ar'));
    });

    test('setLocale changes locale to Portuguese', () {
      final provider = LocaleProvider();

      provider.setLocale(const Locale('pt'));

      expect(provider.locale, const Locale('pt'));
    });

    test('setLocale rejects unsupported locale', () {
      final provider = LocaleProvider();
      final initialLocale = provider.locale;

      provider.setLocale(const Locale('de')); // German not supported

      expect(provider.locale, initialLocale); // Should remain unchanged
    });

    test('setLocale does not notify when locale is unsupported', () {
      final provider = LocaleProvider();
      bool notified = false;
      provider.addListener(() => notified = true);

      provider.setLocale(const Locale('xyz')); // Unsupported

      expect(notified, false);
    });

    test('setLocale notifies listeners on valid change', () {
      final provider = LocaleProvider();
      int notificationCount = 0;
      provider.addListener(() => notificationCount++);

      provider.setLocale(const Locale('es'));
      provider.setLocale(const Locale('fr'));

      expect(notificationCount, 2);
    });

    test('setLocale works with language code only', () {
      final provider = LocaleProvider();

      provider.setLocale(const Locale('en'));

      expect(provider.locale.languageCode, 'en');
      expect(provider.locale.countryCode, null);
    });

    test('multiple locale changes work correctly', () {
      final provider = LocaleProvider();

      provider.setLocale(const Locale('es'));
      expect(provider.locale, const Locale('es'));

      provider.setLocale(const Locale('fr'));
      expect(provider.locale, const Locale('fr'));

      provider.setLocale(const Locale('ar'));
      expect(provider.locale, const Locale('ar'));

      provider.setLocale(const Locale('en'));
      expect(provider.locale, const Locale('en'));
    });

    test('setLocale with same locale still notifies', () {
      final provider = LocaleProvider();
      provider.setLocale(const Locale('es'));

      int notificationCount = 0;
      provider.addListener(() => notificationCount++);

      provider.setLocale(const Locale('es')); // Same locale

      expect(notificationCount, 1);
      expect(provider.locale, const Locale('es'));
    });

    test('supported locales include all expected locales', () {
      // This validates the integration with AppLocalizations
      final supportedLocales = AppLocalizations.supportedLocales;

      expect(supportedLocales.contains(const Locale('en')), true);
      expect(supportedLocales.contains(const Locale('es')), true);
      expect(supportedLocales.contains(const Locale('fr')), true);
      expect(supportedLocales.contains(const Locale('ar')), true);
      expect(supportedLocales.contains(const Locale('pt')), true);
    });

    test('locale provider follows ChangeNotifier pattern', () {
      final provider = LocaleProvider();

      expect(provider, isA<ChangeNotifier>());
    });

    test('removing listener stops notifications', () {
      final provider = LocaleProvider();
      int notificationCount = 0;
      void listener() => notificationCount++;

      provider.addListener(listener);
      provider.setLocale(const Locale('es'));
      expect(notificationCount, 1);

      provider.removeListener(listener);
      provider.setLocale(const Locale('fr'));
      expect(notificationCount, 1); // Still 1, not 2
    });

    test('locale persists across multiple operations', () {
      final provider = LocaleProvider();

      provider.setLocale(const Locale('ar'));
      final locale1 = provider.locale;
      final locale2 = provider.locale;

      expect(locale1, locale2);
      expect(locale1, const Locale('ar'));
    });
  });
}
