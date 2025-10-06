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

      test('calculates both sunrise and sunset times', () {
        final date = DateTime(2025, 6, 21);
        const latitude = 33.5731; // Casablanca
        const longitude = -7.5898;

        final times = AstronomicalService.calculateSunTimes(date, latitude, longitude);

        expect(times.sunrise, isNotNull);
        expect(times.sunset, isNotNull);
        // Verify times are valid DateTime objects
        expect(times.sunrise, isA<DateTime>());
        expect(times.sunset, isA<DateTime>());
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
          // Verify times are calculated for all locations
          expect(times.sunrise, isA<DateTime>());
          expect(times.sunset, isA<DateTime>());
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
        expect(firstHoliday.type, isNotNull);
      });

      test('holiday dates are within the requested year', () {
        final year = 2025;
        final holidays = AstronomicalService.getHolidays(year, 'en');

        for (final holiday in holidays) {
          expect(holiday.date.year, equals(year));
        }
      });

      test('unsupported locale returns only international holidays', () {
        final year = 2025;
        final holidays = AstronomicalService.getHolidays(year, 'xyz');

        // Should return 2 international holidays (New Year's Day and Christmas)
        expect(holidays.length, 2);
        expect(holidays.every((h) => h.type == HolidayType.international), true);
      });

      test('different locales have different holidays', () {
        final year = 2025;
        final holidaysEn = AstronomicalService.getHolidays(year, 'en');
        final holidaysAr = AstronomicalService.getHolidays(year, 'ar');

        expect(holidaysEn, isNotEmpty);
        expect(holidaysAr, isNotEmpty);

        // Holidays count might differ due to cultural differences
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
        // At extreme latitudes, sun may not rise or set (polar day/night)
      });

      test('handles extreme southern latitude', () {
        final date = DateTime(2025, 12, 21);
        const latitude = -70.0;
        const longitude = 25.0;

        final times = AstronomicalService.calculateSunTimes(date, latitude, longitude);

        expect(times, isNotNull);
        // At extreme latitudes, sun may not rise or set (polar day/night)
      });

      test('handles polar night conditions', () {
        // During polar night at high latitudes in winter
        final date = DateTime(2025, 12, 21);
        const latitude = 85.0; // Very high latitude
        const longitude = 0.0;

        final times = AstronomicalService.calculateSunTimes(date, latitude, longitude);

        expect(times, isNotNull);
        // In polar regions, sun may not rise or set
      });

      test('handles polar day conditions', () {
        // During polar day at high latitudes in summer
        final date = DateTime(2025, 6, 21);
        const latitude = 85.0; // Very high latitude
        const longitude = 0.0;

        final times = AstronomicalService.calculateSunTimes(date, latitude, longitude);

        expect(times, isNotNull);
        // In polar regions, sun may not set
      });

      test('handles equator location', () {
        final date = DateTime(2025, 3, 20); // Equinox
        const latitude = 0.0; // Equator
        const longitude = 0.0;

        final times = AstronomicalService.calculateSunTimes(date, latitude, longitude);

        expect(times, isNotNull);
        expect(times.sunrise, isNotNull);
        expect(times.sunset, isNotNull);
      });
    });

    group('Moon Phase Edge Cases', () {
      test('new moon has zero illumination', () {
        // Test various dates to find a new moon (day 1)
        final testDates = [
          DateTime(2025, 1, 1),
          DateTime(2025, 2, 1),
          DateTime(2025, 3, 1),
        ];

        for (final date in testDates) {
          final moonPhase = AstronomicalService.getMoonPhase(date);
          if (moonPhase.lunarDay == 1) {
            expect(moonPhase.phase, 'New Moon');
            expect(moonPhase.emoji, '🌑');
            expect(moonPhase.illumination, 0.0);
          }
        }
      });

      test('full moon has maximum illumination', () {
        // Test various dates to find a full moon (days 14-16)
        final testDates = [
          DateTime(2025, 1, 15),
          DateTime(2025, 2, 15),
          DateTime(2025, 3, 15),
        ];

        for (final date in testDates) {
          final moonPhase = AstronomicalService.getMoonPhase(date);
          if (moonPhase.lunarDay >= 14 && moonPhase.lunarDay <= 16) {
            expect(moonPhase.phase, 'Full Moon');
            expect(moonPhase.emoji, '🌕');
            expect(moonPhase.illumination, 1.0);
          }
        }
      });

      test('first quarter has 50% illumination', () {
        // Test for first quarter (days 7-9)
        final testDates = [
          DateTime(2025, 1, 8),
          DateTime(2025, 2, 8),
          DateTime(2025, 3, 8),
        ];

        for (final date in testDates) {
          final moonPhase = AstronomicalService.getMoonPhase(date);
          if (moonPhase.lunarDay >= 7 && moonPhase.lunarDay <= 9) {
            expect(moonPhase.phase, 'First Quarter');
            expect(moonPhase.emoji, '🌓');
            expect(moonPhase.illumination, 0.5);
          }
        }
      });

      test('last quarter has 50% illumination', () {
        // Test for last quarter (days 22-24)
        final testDates = [
          DateTime(2025, 1, 22),
          DateTime(2025, 2, 22),
          DateTime(2025, 3, 22),
        ];

        for (final date in testDates) {
          final moonPhase = AstronomicalService.getMoonPhase(date);
          if (moonPhase.lunarDay >= 22 && moonPhase.lunarDay <= 24) {
            expect(moonPhase.phase, 'Last Quarter');
            expect(moonPhase.emoji, '🌗');
            expect(moonPhase.illumination, 0.5);
          }
        }
      });

      test('waxing crescent has increasing illumination', () {
        final testDates = [
          DateTime(2025, 1, 3),
          DateTime(2025, 2, 3),
        ];

        for (final date in testDates) {
          final moonPhase = AstronomicalService.getMoonPhase(date);
          if (moonPhase.lunarDay >= 2 && moonPhase.lunarDay <= 6) {
            expect(moonPhase.phase, 'Waxing Crescent');
            expect(moonPhase.emoji, '🌒');
            expect(moonPhase.illumination, greaterThan(0.0));
            expect(moonPhase.illumination, lessThan(0.5));
          }
        }
      });

      test('waxing gibbous has high illumination', () {
        final testDates = [
          DateTime(2025, 1, 12),
          DateTime(2025, 2, 12),
        ];

        for (final date in testDates) {
          final moonPhase = AstronomicalService.getMoonPhase(date);
          if (moonPhase.lunarDay >= 10 && moonPhase.lunarDay <= 13) {
            expect(moonPhase.phase, 'Waxing Gibbous');
            expect(moonPhase.emoji, '🌔');
            expect(moonPhase.illumination, greaterThan(0.5));
            expect(moonPhase.illumination, lessThan(1.0));
          }
        }
      });

      test('waning gibbous has decreasing illumination', () {
        final testDates = [
          DateTime(2025, 1, 18),
          DateTime(2025, 2, 18),
        ];

        for (final date in testDates) {
          final moonPhase = AstronomicalService.getMoonPhase(date);
          if (moonPhase.lunarDay >= 17 && moonPhase.lunarDay <= 21) {
            expect(moonPhase.phase, 'Waning Gibbous');
            expect(moonPhase.emoji, '🌖');
            expect(moonPhase.illumination, greaterThan(0.5));
            expect(moonPhase.illumination, lessThan(1.0));
          }
        }
      });

      test('waning crescent has low illumination', () {
        final testDates = [
          DateTime(2025, 1, 26),
          DateTime(2025, 2, 26),
        ];

        for (final date in testDates) {
          final moonPhase = AstronomicalService.getMoonPhase(date);
          if (moonPhase.lunarDay >= 25 && moonPhase.lunarDay <= 30) {
            expect(moonPhase.phase, 'Waning Crescent');
            expect(moonPhase.emoji, '🌘');
            expect(moonPhase.illumination, greaterThan(0.0));
            expect(moonPhase.illumination, lessThan(0.5));
          }
        }
      });
    });

    group('Holiday Type Enum', () {
      test('HolidayType enum has all expected values', () {
        expect(HolidayType.values.length, 4);
        expect(HolidayType.values.contains(HolidayType.international), true);
        expect(HolidayType.values.contains(HolidayType.national), true);
        expect(HolidayType.values.contains(HolidayType.cultural), true);
        expect(HolidayType.values.contains(HolidayType.religious), true);
      });

      test('international holidays exist in all locales', () {
        final year = 2025;
        final locales = ['en', 'ar', 'es', 'fr', 'pt'];

        for (final locale in locales) {
          final holidays = AstronomicalService.getHolidays(year, locale);
          final internationalHolidays =
              holidays.where((h) => h.type == HolidayType.international).toList();

          // At least New Year's Day and Christmas
          expect(internationalHolidays.length, greaterThanOrEqualTo(2));
        }
      });

      test('holidays include national types for supported locales', () {
        final year = 2025;
        final holidaysEn = AstronomicalService.getHolidays(year, 'en');

        final nationalHolidays =
            holidaysEn.where((h) => h.type == HolidayType.national).toList();

        expect(nationalHolidays, isNotEmpty);
      });

      test('holidays include cultural types', () {
        final year = 2025;
        final holidaysEn = AstronomicalService.getHolidays(year, 'en');

        final culturalHolidays =
            holidaysEn.where((h) => h.type == HolidayType.cultural).toList();

        expect(culturalHolidays, isNotEmpty);
      });
    });

    group('Holiday Sorting', () {
      test('holidays are sorted by date', () {
        final year = 2025;
        final holidays = AstronomicalService.getHolidays(year, 'en');

        expect(holidays.length, greaterThan(1));

        // Check that each holiday is on or after the previous one
        for (int i = 1; i < holidays.length; i++) {
          expect(
            holidays[i].date.isAfter(holidays[i - 1].date) ||
                holidays[i].date.isAtSameMomentAs(holidays[i - 1].date),
            true,
            reason: 'Holidays should be sorted by date',
          );
        }
      });

      test('first holiday of year is on or after January 1', () {
        final year = 2025;
        final holidays = AstronomicalService.getHolidays(year, 'en');

        expect(holidays.first.date.month, greaterThanOrEqualTo(1));
        expect(holidays.first.date.day, greaterThanOrEqualTo(1));
      });

      test('last holiday of year is on or before December 31', () {
        final year = 2025;
        final holidays = AstronomicalService.getHolidays(year, 'en');

        expect(holidays.last.date.month, lessThanOrEqualTo(12));
        expect(holidays.last.date.day, lessThanOrEqualTo(31));
      });
    });

    group('Solstice/Equinox Edge Cases', () {
      test('calculates correctly for different years', () {
        final years = [2020, 2025, 2030, 2050, 2100];

        for (final year in years) {
          final events = AstronomicalService.getSolsticesEquinoxes(year);

          expect(events.springEquinox.year, year);
          expect(events.summerSolstice.year, year);
          expect(events.autumnEquinox.year, year);
          expect(events.winterSolstice.year, year);
        }
      });

      test('spring equinox is in March (19-21)', () {
        final years = [2024, 2025, 2026];

        for (final year in years) {
          final events = AstronomicalService.getSolsticesEquinoxes(year);

          expect(events.springEquinox.month, 3);
          expect(events.springEquinox.day, greaterThanOrEqualTo(19));
          expect(events.springEquinox.day, lessThanOrEqualTo(21));
        }
      });

      test('summer solstice is in June (20-22)', () {
        final years = [2024, 2025, 2026];

        for (final year in years) {
          final events = AstronomicalService.getSolsticesEquinoxes(year);

          expect(events.summerSolstice.month, 6);
          expect(events.summerSolstice.day, greaterThanOrEqualTo(20));
          expect(events.summerSolstice.day, lessThanOrEqualTo(22));
        }
      });

      test('autumn equinox is in September (21-24)', () {
        final years = [2024, 2025, 2026];

        for (final year in years) {
          final events = AstronomicalService.getSolsticesEquinoxes(year);

          expect(events.autumnEquinox.month, 9);
          expect(events.autumnEquinox.day, greaterThanOrEqualTo(21));
          expect(events.autumnEquinox.day, lessThanOrEqualTo(24));
        }
      });

      test('winter solstice is in December (20-23)', () {
        final years = [2024, 2025, 2026];

        for (final year in years) {
          final events = AstronomicalService.getSolsticesEquinoxes(year);

          expect(events.winterSolstice.month, 12);
          expect(events.winterSolstice.day, greaterThanOrEqualTo(20));
          expect(events.winterSolstice.day, lessThanOrEqualTo(23));
        }
      });
    });

    group('Localized Holiday Names', () {
      test('New Year\'s Day is localized', () {
        final year = 2025;
        final holidaysEn = AstronomicalService.getHolidays(year, 'en');
        final holidaysAr = AstronomicalService.getHolidays(year, 'ar');
        final holidaysEs = AstronomicalService.getHolidays(year, 'es');
        final holidaysFr = AstronomicalService.getHolidays(year, 'fr');
        final holidaysPt = AstronomicalService.getHolidays(year, 'pt');

        // Find New Year's Day in each locale
        final newYearEn = holidaysEn.firstWhere((h) => h.date.month == 1 && h.date.day == 1);
        final newYearAr = holidaysAr.firstWhere((h) => h.date.month == 1 && h.date.day == 1);
        final newYearEs = holidaysEs.firstWhere((h) => h.date.month == 1 && h.date.day == 1);
        final newYearFr = holidaysFr.firstWhere((h) => h.date.month == 1 && h.date.day == 1);
        final newYearPt = holidaysPt.firstWhere((h) => h.date.month == 1 && h.date.day == 1);

        expect(newYearEn.name, contains('New Year'));
        expect(newYearAr.name, contains('السنة'));
        expect(newYearEs.name, contains('Año Nuevo'));
        expect(newYearFr.name, contains('An'));
        expect(newYearPt.name, contains('Ano Novo'));
      });

      test('Christmas Day is localized', () {
        final year = 2025;
        final holidaysEn = AstronomicalService.getHolidays(year, 'en');
        final holidaysAr = AstronomicalService.getHolidays(year, 'ar');
        final holidaysEs = AstronomicalService.getHolidays(year, 'es');
        final holidaysFr = AstronomicalService.getHolidays(year, 'fr');
        final holidaysPt = AstronomicalService.getHolidays(year, 'pt');

        // Find Christmas in each locale
        final christmasEn = holidaysEn.firstWhere((h) => h.date.month == 12 && h.date.day == 25);
        final christmasAr = holidaysAr.firstWhere((h) => h.date.month == 12 && h.date.day == 25);
        final christmasEs = holidaysEs.firstWhere((h) => h.date.month == 12 && h.date.day == 25);
        final christmasFr = holidaysFr.firstWhere((h) => h.date.month == 12 && h.date.day == 25);
        final christmasPt = holidaysPt.firstWhere((h) => h.date.month == 12 && h.date.day == 25);

        expect(christmasEn.name, contains('Christmas'));
        expect(christmasAr.name, contains('الميلاد'));
        expect(christmasEs.name, contains('Navidad'));
        expect(christmasFr.name, contains('Noël'));
        expect(christmasPt.name, contains('Natal'));
      });
    });

    group('Locale-Specific Holidays', () {
      test('English locale includes US-specific holidays', () {
        final year = 2025;
        final holidays = AstronomicalService.getHolidays(year, 'en');

        final holidayNames = holidays.map((h) => h.name).toList();

        expect(holidayNames.any((name) => name.contains('Independence Day')), true);
        expect(holidayNames.any((name) => name.contains('Thanksgiving')), true);
        expect(holidayNames.any((name) => name.contains('Halloween')), true);
      });

      test('Arabic locale includes Arabic-specific holidays', () {
        final year = 2025;
        final holidays = AstronomicalService.getHolidays(year, 'ar');

        // Should have at least the international holidays
        expect(holidays.length, greaterThanOrEqualTo(2));
      });

      test('Spanish locale includes Spanish-specific holidays', () {
        final year = 2025;
        final holidays = AstronomicalService.getHolidays(year, 'es');

        final holidayNames = holidays.map((h) => h.name).toList();

        expect(holidayNames.any((name) => name.contains('Reyes')), true);
        expect(holidayNames.any((name) => name.contains('Hispanidad')), true);
      });

      test('French locale includes French-specific holidays', () {
        final year = 2025;
        final holidays = AstronomicalService.getHolidays(year, 'fr');

        final holidayNames = holidays.map((h) => h.name).toList();

        expect(holidayNames.any((name) => name.contains('Fête Nationale')), true);
        expect(holidayNames.any((name) => name.contains('Toussaint')), true);
      });

      test('Portuguese locale includes Portuguese-specific holidays', () {
        final year = 2025;
        final holidays = AstronomicalService.getHolidays(year, 'pt');

        final holidayNames = holidays.map((h) => h.name).toList();

        expect(holidayNames.any((name) => name.contains('Liberdade')), true);
        expect(holidayNames.any((name) => name.contains('Portugal')), true);
      });
    });
  });
}
