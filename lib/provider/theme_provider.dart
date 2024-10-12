import 'package:brisk/theme/application_theme.dart';
import 'package:brisk/theme/application_theme_holder.dart';
import 'package:flutter/cupertino.dart';

class ThemeProvider with ChangeNotifier {
  ApplicationTheme activeTheme = ApplicationThemeHolder.activeTheme;

  void updateActiveTheme() {
    this.activeTheme = ApplicationThemeHolder.activeTheme;
    notifyListeners();
  }
}
