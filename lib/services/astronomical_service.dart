import 'dart:math';
import 'package:lunar/lunar.dart';
import 'package:geolocator/geolocator.dart';

class AstronomicalService {
  /// Get moon phase for a specific date
  static MoonPhaseInfo getMoonPhase(DateTime date) {
    final lunar = Lunar.fromDate(date);
    final day = lunar.getDay();

    // Calculate moon phase based on lunar day
    String phase;
    String emoji;
    double illumination;

    if (day == 1) {
      phase = 'New Moon';
      emoji = '🌑';
      illumination = 0.0;
    } else if (day >= 2 && day <= 6) {
      phase = 'Waxing Crescent';
      emoji = '🌒';
      illumination = day / 15;
    } else if (day >= 7 && day <= 9) {
      phase = 'First Quarter';
      emoji = '🌓';
      illumination = 0.5;
    } else if (day >= 10 && day <= 13) {
      phase = 'Waxing Gibbous';
      emoji = '🌔';
      illumination = day / 15;
    } else if (day >= 14 && day <= 16) {
      phase = 'Full Moon';
      emoji = '🌕';
      illumination = 1.0;
    } else if (day >= 17 && day <= 21) {
      phase = 'Waning Gibbous';
      emoji = '🌖';
      illumination = 1.0 - ((day - 15) / 15);
    } else if (day >= 22 && day <= 24) {
      phase = 'Last Quarter';
      emoji = '🌗';
      illumination = 0.5;
    } else {
      phase = 'Waning Crescent';
      emoji = '🌘';
      illumination = 1.0 - ((day - 15) / 15);
    }

    return MoonPhaseInfo(
      phase: phase,
      emoji: emoji,
      illumination: illumination,
      lunarDay: day,
    );
  }

  /// Calculate sunrise and sunset times for a specific location and date
  static SunTimes calculateSunTimes(DateTime date, double latitude, double longitude) {
    final double julianDay = _calculateJulianDay(date);
    final double n = julianDay - 2451545.0 + 0.0008;

    // Mean solar time
    final double j = n - longitude / 360.0;

    // Solar mean anomaly
    final double m = (357.5291 + 0.98560028 * j) % 360;
    final double mRad = m * pi / 180;

    // Equation of center
    final double c = 1.9148 * sin(mRad) + 0.0200 * sin(2 * mRad) + 0.0003 * sin(3 * mRad);

    // Ecliptic longitude
    final double lambda = (m + c + 180 + 102.9372) % 360;
    final double lambdaRad = lambda * pi / 180;

    // Solar transit
    final double jTransit = 2451545.0 + j + 0.0053 * sin(mRad) - 0.0069 * sin(2 * lambdaRad);

    // Declination of the sun
    final double delta = asin(sin(lambdaRad) * sin(23.44 * pi / 180));

    // Hour angle
    final double latRad = latitude * pi / 180;
    final double cosOmega = (sin(-0.83 * pi / 180) - sin(latRad) * sin(delta)) / (cos(latRad) * cos(delta));

    // Check if sun rises/sets
    if (cosOmega > 1) {
      // Polar night
      return SunTimes(
        sunrise: null,
        sunset: null,
        isPolarNight: true,
        isPolarDay: false,
      );
    } else if (cosOmega < -1) {
      // Midnight sun
      return SunTimes(
        sunrise: null,
        sunset: null,
        isPolarNight: false,
        isPolarDay: true,
      );
    }

    final double omega = acos(cosOmega) * 180 / pi;

    // Calculate sunrise and sunset
    final double jRise = jTransit - omega / 360;
    final double jSet = jTransit + omega / 360;

    final DateTime sunrise = _julianDayToDateTime(jRise);
    final DateTime sunset = _julianDayToDateTime(jSet);

    return SunTimes(
      sunrise: sunrise,
      sunset: sunset,
      isPolarNight: false,
      isPolarDay: false,
    );
  }

  /// Calculate Julian Day from DateTime
  static double _calculateJulianDay(DateTime date) {
    final int a = (14 - date.month) ~/ 12;
    final int y = date.year + 4800 - a;
    final int m = date.month + 12 * a - 3;

    final int julianDayNumber = date.day + (153 * m + 2) ~/ 5 + 365 * y + y ~/ 4 - y ~/ 100 + y ~/ 400 - 32045;
    final double julianDay = julianDayNumber + (date.hour - 12) / 24.0 + date.minute / 1440.0 + date.second / 86400.0;

    return julianDay;
  }

  /// Convert Julian Day to DateTime
  static DateTime _julianDayToDateTime(double julianDay) {
    final int z = julianDay.floor() + 32044;
    final int a = ((4 * z + 3) / 146097).floor();
    final int b = z - ((146097 * a) / 4).floor();
    final int c = ((4 * b + 3) / 1461).floor();
    final int d = b - ((1461 * c) / 4).floor();
    final int e = ((5 * d + 2) / 153).floor();

    final int day = d - ((153 * e + 2) / 5).floor() + 1;
    final int month = e + 3 - 12 * ((e + 3) / 12).floor();
    final int year = 100 * a + c - 4800 + ((e + 3) / 12).floor();

    final double fraction = julianDay - julianDay.floor();
    final int hour = ((fraction + 0.5) * 24).floor() % 24;
    final int minute = ((fraction + 0.5) * 24 * 60).floor() % 60;

    return DateTime(year, month, day, hour, minute);
  }

  /// Get solstices and equinoxes for a specific year
  static SolsticesEquinoxes getSolsticesEquinoxes(int year) {
    // Approximate dates for Northern Hemisphere
    // These are astronomical calculations that can vary by a day
    return SolsticesEquinoxes(
      springEquinox: _calculateSpringEquinox(year),
      summerSolstice: _calculateSummerSolstice(year),
      autumnEquinox: _calculateAutumnEquinox(year),
      winterSolstice: _calculateWinterSolstice(year),
    );
  }

  static DateTime _calculateSpringEquinox(int year) {
    // March equinox calculation (simplified)
    final double y = (year - 2000) / 1000.0;
    final double jde = 2451623.80984 + 365242.37404 * y + 0.05169 * y * y - 0.00411 * y * y * y;
    return _julianDayToDateTime(jde);
  }

  static DateTime _calculateSummerSolstice(int year) {
    // June solstice calculation (simplified)
    final double y = (year - 2000) / 1000.0;
    final double jde = 2451716.56767 + 365241.62603 * y + 0.00325 * y * y + 0.00888 * y * y * y;
    return _julianDayToDateTime(jde);
  }

  static DateTime _calculateAutumnEquinox(int year) {
    // September equinox calculation (simplified)
    final double y = (year - 2000) / 1000.0;
    final double jde = 2451810.21715 + 365242.01767 * y - 0.11575 * y * y + 0.00337 * y * y * y;
    return _julianDayToDateTime(jde);
  }

  static DateTime _calculateWinterSolstice(int year) {
    // December solstice calculation (simplified)
    final double y = (year - 2000) / 1000.0;
    final double jde = 2451900.05952 + 365242.74049 * y - 0.06223 * y * y - 0.00823 * y * y * y;
    return _julianDayToDateTime(jde);
  }

  /// Get holidays for a specific year and locale
  static List<Holiday> getHolidays(int year, String locale) {
    final List<Holiday> holidays = [];

    // Common international holidays
    holidays.addAll([
      Holiday(
        date: DateTime(year, 1, 1),
        name: _getLocalizedHolidayName('New Year\'s Day', locale),
        type: HolidayType.international,
      ),
      Holiday(
        date: DateTime(year, 12, 25),
        name: _getLocalizedHolidayName('Christmas Day', locale),
        type: HolidayType.international,
      ),
    ]);

    // Locale-specific holidays
    switch (locale) {
      case 'en':
        holidays.addAll(_getEnglishHolidays(year));
        break;
      case 'ar':
        holidays.addAll(_getArabicHolidays(year));
        break;
      case 'es':
        holidays.addAll(_getSpanishHolidays(year));
        break;
      case 'fr':
        holidays.addAll(_getFrenchHolidays(year));
        break;
      case 'pt':
        holidays.addAll(_getPortugueseHolidays(year));
        break;
    }

    // Sort by date
    holidays.sort((a, b) => a.date.compareTo(b.date));

    return holidays;
  }

  static List<Holiday> _getEnglishHolidays(int year) {
    return [
      Holiday(date: DateTime(year, 2, 14), name: 'Valentine\'s Day', type: HolidayType.cultural),
      Holiday(date: DateTime(year, 7, 4), name: 'Independence Day (US)', type: HolidayType.national),
      Holiday(date: DateTime(year, 10, 31), name: 'Halloween', type: HolidayType.cultural),
      Holiday(date: DateTime(year, 11, 11), name: 'Veterans Day (US)', type: HolidayType.national),
      Holiday(date: DateTime(year, 11, 28), name: 'Thanksgiving (US)', type: HolidayType.national),
    ];
  }

  static List<Holiday> _getArabicHolidays(int year) {
    return [
      Holiday(date: DateTime(year, 1, 1), name: 'رأس السنة الميلادية', type: HolidayType.international),
      Holiday(date: DateTime(year, 9, 23), name: 'اليوم الوطني السعودي', type: HolidayType.national),
      // Note: Islamic holidays follow lunar calendar, would need additional calculation
    ];
  }

  static List<Holiday> _getSpanishHolidays(int year) {
    return [
      Holiday(date: DateTime(year, 1, 6), name: 'Día de Reyes', type: HolidayType.cultural),
      Holiday(date: DateTime(year, 10, 12), name: 'Día de la Hispanidad', type: HolidayType.national),
      Holiday(date: DateTime(year, 11, 1), name: 'Día de Todos los Santos', type: HolidayType.cultural),
    ];
  }

  static List<Holiday> _getFrenchHolidays(int year) {
    return [
      Holiday(date: DateTime(year, 7, 14), name: 'Fête Nationale', type: HolidayType.national),
      Holiday(date: DateTime(year, 11, 1), name: 'Toussaint', type: HolidayType.cultural),
      Holiday(date: DateTime(year, 11, 11), name: 'Armistice 1918', type: HolidayType.national),
    ];
  }

  static List<Holiday> _getPortugueseHolidays(int year) {
    return [
      Holiday(date: DateTime(year, 4, 25), name: 'Dia da Liberdade', type: HolidayType.national),
      Holiday(date: DateTime(year, 6, 10), name: 'Dia de Portugal', type: HolidayType.national),
      Holiday(date: DateTime(year, 10, 5), name: 'Implantação da República', type: HolidayType.national),
    ];
  }

  static String _getLocalizedHolidayName(String englishName, String locale) {
    final Map<String, Map<String, String>> translations = {
      'New Year\'s Day': {
        'en': 'New Year\'s Day',
        'ar': 'رأس السنة',
        'es': 'Año Nuevo',
        'fr': 'Jour de l\'An',
        'pt': 'Ano Novo',
      },
      'Christmas Day': {
        'en': 'Christmas Day',
        'ar': 'عيد الميلاد',
        'es': 'Navidad',
        'fr': 'Noël',
        'pt': 'Natal',
      },
    };

    return translations[englishName]?[locale] ?? englishName;
  }

  /// Get current location
  static Future<Position?> getCurrentLocation() async {
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition();
    } catch (e) {
      return null;
    }
  }
}

/// Moon phase information
class MoonPhaseInfo {
  final String phase;
  final String emoji;
  final double illumination; // 0.0 to 1.0
  final int lunarDay;

  MoonPhaseInfo({
    required this.phase,
    required this.emoji,
    required this.illumination,
    required this.lunarDay,
  });
}

/// Sun times information
class SunTimes {
  final DateTime? sunrise;
  final DateTime? sunset;
  final bool isPolarNight;
  final bool isPolarDay;

  SunTimes({
    this.sunrise,
    this.sunset,
    required this.isPolarNight,
    required this.isPolarDay,
  });
}

/// Solstices and equinoxes
class SolsticesEquinoxes {
  final DateTime springEquinox;
  final DateTime summerSolstice;
  final DateTime autumnEquinox;
  final DateTime winterSolstice;

  SolsticesEquinoxes({
    required this.springEquinox,
    required this.summerSolstice,
    required this.autumnEquinox,
    required this.winterSolstice,
  });
}

/// Holiday information
class Holiday {
  final DateTime date;
  final String name;
  final HolidayType type;

  Holiday({
    required this.date,
    required this.name,
    required this.type,
  });
}

enum HolidayType {
  international,
  national,
  cultural,
  religious,
}
