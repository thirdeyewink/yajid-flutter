import 'package:flutter/material.dart';
import 'package:yajid/l10n/app_localizations.dart';

class LocaleProvider with ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    if (!AppLocalizations.supportedLocales.contains(locale)) {
      return;
    }
    _locale = locale;
    notifyListeners();
  }
}
