import 'package:brisk/util/settings_cache.dart';
import 'package:flutter/cupertino.dart';

class LocaleProvider with ChangeNotifier {
  static final LocaleProvider instance = LocaleProvider._internal();

  LocaleProvider._internal();

  factory LocaleProvider() => instance;

  late Locale locale;

  static const locales = {
    "en": "English",
    "fa": "فارسی",
    "it": "Italiano"
  };

  void setCurrentLocale() {
    locale = Locale(SettingsCache.locale);
    notifyListeners();
  }
}
