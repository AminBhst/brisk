import 'package:brisk/util/settings_cache.dart';
import 'package:flutter/cupertino.dart';

class LocaleProvider with ChangeNotifier {
  static final LocaleProvider instance = LocaleProvider._internal();

  LocaleProvider._internal();

  factory LocaleProvider() => instance;

  late Locale locale;

  static const locales = {
    "en": "English",
    "it": "Italiano",
    "fa": "فارسی",
    "zh": "中文",
  };

  void setCurrentLocale() {
    locale = Locale(SettingsCache.locale);
    notifyListeners();
  }
}
