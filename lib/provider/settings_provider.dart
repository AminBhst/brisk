import 'package:flutter/material.dart';

import '../util/settings_cache.dart';

class SettingsProvider with ChangeNotifier {
  final PageController settingsPageController = PageController(initialPage: 0);
  int? selectedTabId = 0;
  String? tempPath = SettingsCache.temporaryDir.path;
  String? savePath = SettingsCache.saveDir.path;

  void setSavePath(String path) {
    savePath = path;
    notifyListeners();
  }

  void setTempPath(String path) {
    tempPath = path;
  }

  void setSelectedSettingsTab(int tabId) {
    selectedTabId = tabId;
    settingsPageController.jumpToPage(tabId);
    notifyListeners();
  }

  void resetSettingCache() {
    SettingsCache.setCachedSettings();
    notifyListeners();
  }
}
