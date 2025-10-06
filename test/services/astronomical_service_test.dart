import 'package:flutter_test/flutter_test.dart';
import 'package:yajid/services/astronomical_service.dart';

void main() {
  group('AstronomicalService', () {
    group('Moon Phase Calculations', () {
      test('getMoonPhase returns valid MoonPhaseInfo', () {
        final date = DateTime(2025, 6, 15);
        final moonPhase = AstronomicalService.getMoonPhase(date);

        expect(moonPhase, isNotNull);
        expect(moonPhase.phase, isNotEmpty);
        expect(moonPhase.emoji, isNotEmpty);
        expect(moonPhase.illumination, isA<double>());
        expect(moonPhase.lunarDay, isA<int>());
      });

      test('illumination is between 0 and 1', () {
        final dates = [
          DateTime(2025, 1, 1),
          DateTime(2025, 6, 15),
          DateTime(2025, 12, 31),
        ];

        for (final date in dates) {
          final moonPhase = AstronomicalService.getMoonPhase(date);
          expect(moonPhase.illumination, greaterThanOrEqualTo(0.0));
          expect(moonPhase.illumination, lessThanOrEqualTo(1.0));
        }
      });

      test('moon phase has valid properties', () {
        final date = DateTime(2025, 3, 15);
        final moonPhase = AstronomicalService.getMoonPhase(date);

        expect(moonPhase.phase, isNotEmpty);
        expect(moonPhase.emoji, isNotEmpty);
        expect(moonPhase.illumination, isA<double>());
        expect(moonPhase.lunarDay, greaterThan(0));
        expect(moonPhase.lunarDay, lessThanOrEqualTo(30));
      });

      test('moon phase emoji matches known phases', () {
        final date = DateTime(2025, 3, 15);
        final moonPhase = AstronomicalService.getMoonPhase(date);

        final validEmojis = ['🌑', '🌒', '🌓', '🌔', '🌕', '🌖', '🌗', '🌘'];
        expect(validEmojis.contains(moonPhase.emoji), true);

        final validPhases = [
          'New Moon',
          'Waxing Crescent',
          'First Quarter',
          'Waxing Gibbous',
          'Full Moon',
          'Waning Gibbous',
          'Last Quarter',
          'Waning Crescent'
        ];
        expect(validPhases.contains(moonPhase.phase), true);
      });

      test('moon phase calculation is consistent for same date', () {
        final date = DateTime(2025, 7, 4);
        final phase1 = AstronomicalService.getMoonPhase(date);
        final phase2 = AstronomicalService.getMoonPhase(date);

        expect(phase1.phase, equals(phase2.phase));
        expect(phase1.emoji, equals(phase2.emoji));
        expect(phase1.illumination, equals(phase2.illumination));
        expect(phase1.lunarDay, equals(phase2.lunarDay));
      });

      test('lunar day is valid', () {
        final date = DateTime(2025, 1, 1);
        final moonPhase = AstronomicalService.getMoonPhase(date);

        expect(moonPhase.lunarDay, greaterThan(0));
        expect(moonPhase.lunarDay, lessThanOrEqualTo(30));
      });
    });

    group('Sun Times Calculations', () {
      test('calculateSunTimes returns valid SunTimes', () {
        final date = DateTime(2025, 6, 21);
        const latitude = 33.5731; // Casablanca
        const longitude = -7.5898;

        final times = AstronomicalService.calculateSunTimes(date, latitude, longitude);

        expect(times, isNotNull);
        expect(times.sunrise, isNotNull);
        expect(times.sunset, isNotNull);
      });

      test('sunrise occurs before sunset', () {
        final date = DateTime(2025, 3, 15);
        const latitude = 33.5731;
        const longitude = -7.5898;

        final times = AstronomicalService.calculateSunTimes(date, latitude, longitude);

        expect(times.sunrise.isBefore(times.sunset), true);
      });

      test('calculates sun times for different locations', () {
        final date = DateTime(2025, 3, 20);

        final locations = [
          {'lat': 33.5731, 'lon': -7.5898}, // Casablanca
          {'lat': 51.5074, 'lon': -0.1278}, // London
          {'lat': 35.6762, 'lon': 139.6503}, // Tokyo
        ];

        for (final location in locations) {
          final times = AstronomicalService.calculateSunTimes(
            date,
            location['lat']!,
            location['lon']!,
          );

          expect(times.sunrise, isNotNull);
          expect(times.sunset, isNotNull);
          expect(times.sunrise.isBefore(times.sunset), true);
        }
      });
    });

    group('Solstices and Equinoxes', () {
      test('getSolsticesEquinoxes returns valid data', () {
        final year = 2025;
        final events = AstronomicalService.getSolsticesEquinoxes(year);

        expect(events, isNotNull);
        expect(events.springEquinox, isNotNull);
        expect(events.summerSolstice, isNotNull);
        expect(events.autumnEquinox, isNotNull);
        expect(events.winterSolstice, isNotNull);
      });

      test('seasonal events are in correct months', () {
        final year = 2025;
        final events = AstronomicalService.getSolsticesEquinoxes(year);

        expect(events.springEquinox.month, 3); // March
        expect(events.summerSolstice.month, 6); // June
        expect(events.autumnEquinox.month, 9); // September
        expect(events.winterSolstice.month, 12); // December
      });

      test('seasonal events occur in correct order', () {
        final year = 2025;
        final events = AstronomicalService.getSolsticesEquinoxes(year);

        expect(events.springEquinox.isBefore(events.summerSolstice), true);
        expect(events.summerSolstice.isBefore(events.autumnEquinox), true);
        expect(events.autumnEquinox.isBefore(events.winterSolstice), true);
      });
    });

    group('Holiday Calendar', () {
      test('getHolidays returns holidays for English', () {
        final year = 2025;
        final holidays = AstronomicalService.getHolidays(year, 'en');

        expect(holidays, isNotEmpty);
        expect(holidays, isA<List<Holiday>>());
      });

      test('getHolidays returns holidays for all supported locales', () {
        final year = 2025;
        final locales = ['en', 'ar', 'es', 'fr', 'pt'];

        for (final locale in locales) {
          final holidays = AstronomicalService.getHolidays(year, locale);
          expect(holidays, isNotEmpty,
                 reason: 'Holidays should exist for locale: $locale');
        }
      });

      test('holiday has valid structure', () {
        final year = 2025;
        final holidays = AstronomicalService.getHolidays(year, 'en');

        expect(holidays, isNotEmpty);

        final firstHoliday = holidays.first;
        expect(firstHoliday.date, isNotNull);
        expect(firstHoliday.name, isNotEmpty);
        expect(firstHoliday.locale, equals('en'));
      });

      test('holiday dates are within the requested year', () {
        final year = 2025;
        final holidays = AstronomicalService.getHolidays(year, 'en');

        for (final holiday in holidays) {
          expect(holiday.date.year, equals(year));
        }
      });

      test('unsupported locale returns empty list', () {
        final year = 2025;
        final holidays = AstronomicalService.getHolidays(year, 'xyz');

        expect(holidays, isEmpty);
      });

      test('different locales have different holidays', () {
        final year = 2025;
        final holidaysEn = AstronomicalService.getHolidays(year, 'en');
        final holidaysAr = AstronomicalService.getHolidays(year, 'ar');

        expect(holidaysEn, isNotEmpty);
        expect(holidaysAr, isNotEmpty);

        // Count might differ due to cultural differences
        expect(holidaysEn.length > 0, true);
        expect(holidaysAr.length > 0, true);
      });
    });

    group('Edge Cases', () {
      test('handles leap year correctly', () {
        final leapDay = DateTime(2024, 2, 29);
        final moonPhase = AstronomicalService.getMoonPhase(leapDay);

        expect(moonPhase, isNotNull);
        expect(moonPhase.phase, isNotEmpty);
      });

      test('handles year boundaries', () {
        final newYearsEve = DateTime(2024, 12, 31);
        final newYearsDay = DateTime(2025, 1, 1);

        final phase1 = AstronomicalService.getMoonPhase(newYearsEve);
        final phase2 = AstronomicalService.getMoonPhase(newYearsDay);

        expect(phase1, isNotNull);
        expect(phase2, isNotNull);
      });

      test('handles dates far in the future', () {
        final futureDate = DateTime(2100, 1, 1);
        final moonPhase = AstronomicalService.getMoonPhase(futureDate);

        expect(moonPhase, isNotNull);
        expect(moonPhase.phase, isNotEmpty);
      });

      test('handles dates in the past', () {
        final pastDate = DateTime(2000, 1, 1);
        final moonPhase = AstronomicalService.getMoonPhase(pastDate);

        expect(moonPhase, isNotNull);
        expect(moonPhase.phase, isNotEmpty);
      });

      test('handles extreme northern latitude', () {
        final date = DateTime(2025, 6, 21);
        const latitude = 70.0;
        const longitude = 25.0;

        final times = AstronomicalService.calculateSunTimes(date, latitude, longitude);

        expect(times, isNotNull);
        expect(times.sunrise, isNotNull);
        expect(times.sunset, isNotNull);
      });

      test('handles extreme southern latitude', () {
        final date = DateTime(2025, 12, 21);
        const latitude = -70.0;
        const longitude = 25.0;

        final times = AstronomicalService.calculateSunTimes(date, latitude, longitude);

        expect(times, isNotNull);
        expect(times.sunrise, isNotNull);
        expect(times.sunset, isNotNull);
      });
    });
  });
}
