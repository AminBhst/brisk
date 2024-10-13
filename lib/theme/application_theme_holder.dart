import 'package:brisk/theme/application_theme.dart';
import 'package:brisk/util/settings_cache.dart';
import 'package:flutter/material.dart';

class ApplicationThemeHolder {
  static final List<ApplicationTheme> themes = [briskV2Dark, briskOld];
  static late ApplicationTheme activeTheme = briskV2Dark;

  static void setActiveTheme() {
    activeTheme = themes
        .where((t) => t.themeId == SettingsCache.applicationThemeId)
        .first;
  }
}

ApplicationTheme briskV2Dark = ApplicationTheme(
  themeId: "Brisk v2 Dark",
  topMenuTheme: TopMenuTheme(
    backgroundColor: const Color.fromRGBO(20, 20, 20, 0.85),
    addUrlColor: const ButtonColor(
      iconColor: const Color.fromRGBO(56, 209, 82, 0.9),
      hoverIconColor: const Color.fromRGBO(56, 209, 82, 0.9),
      hoverBackgroundColor: const Color.fromRGBO(56, 209, 82, 0.2),
    ),
    downloadColor: const ButtonColor(
      iconColor: const Color.fromRGBO(56, 209, 82, 0.9),
      hoverIconColor: const Color.fromRGBO(56, 209, 82, 0.9),
      hoverBackgroundColor: const Color.fromRGBO(56, 209, 82, 0.2),
    ),
    stopColor: const ButtonColor(
      iconColor: Color.fromRGBO(163, 23, 30, 1),
      hoverIconColor: Color.fromRGBO(163, 23, 30, 1),
      hoverBackgroundColor: Color.fromRGBO(163, 23, 30, 0.3),
    ),
    stopAllColor: const ButtonColor(
      iconColor: Color.fromRGBO(163, 23, 30, 1),
      hoverIconColor: Color.fromRGBO(163, 23, 30, 1),
      hoverBackgroundColor: Color.fromRGBO(163, 23, 30, 0.3),
    ),
    removeColor: const ButtonColor(
      iconColor: Color.fromRGBO(163, 23, 30, 1),
      hoverIconColor: Color.fromRGBO(163, 23, 30, 1),
      hoverBackgroundColor: Color.fromRGBO(163, 23, 30, 0.3),
    ),
    addToQueueColor: const ButtonColor(
      iconColor: Color.fromRGBO(0, 128, 128, 1),
      hoverIconColor: Color.fromRGBO(0, 128, 128, 1),
      hoverBackgroundColor: Color.fromRGBO(0, 128, 128, 0.3),
    ),
    extensionColor: const ButtonColor(
      iconColor: Color.fromRGBO(0, 128, 128, 1),
      hoverIconColor: Color.fromRGBO(0, 128, 128, 1),
      hoverBackgroundColor: Color.fromRGBO(0, 128, 128, 0.3),
    ),
    createQueueColor: const ButtonColor(
      iconColor: const Color.fromRGBO(56, 209, 82, 0.9),
      hoverIconColor: const Color.fromRGBO(56, 209, 82, 0.9),
      hoverBackgroundColor: const Color.fromRGBO(56, 209, 82, 0.2),
    ),
    startQueueColor: const ButtonColor(
      iconColor: const Color.fromRGBO(56, 209, 82, 0.9),
      hoverIconColor: const Color.fromRGBO(56, 209, 82, 0.9),
      hoverBackgroundColor: const Color.fromRGBO(56, 209, 82, 0.2),
    ),
    stopQueueColor: const ButtonColor(
      iconColor: Color.fromRGBO(163, 23, 30, 1),
      hoverIconColor: Color.fromRGBO(163, 23, 30, 1),
      hoverBackgroundColor: Color.fromRGBO(163, 23, 30, 0.3),
    ),
  ),
  sideMenuTheme: SideMenuTheme(
    backgroundColor: const Color.fromRGBO(20, 20, 20, 1),
    briskLogoColor: Color.fromRGBO(53, 89, 143, 1),
    activeTabIconColor: Colors.white,
    activeTabBackgroundColor: Color.fromRGBO(53, 89, 143, 1),
    tabHoverColor: Color.fromRGBO(64, 65, 66, 0.3),
    tabIconColor: Colors.white,
    tabBackgroundColor: Colors.transparent,
    expansionTileExpandedColor: Color.fromRGBO(64, 65, 66, 0.8),
    expansionTileItemActiveColor: Color.fromRGBO(10, 126, 242, 0.8),
    expansionTileItemHoverColor: Color.fromRGBO(64, 65, 66, 0.2),
  ),
  downloadGridTheme: DownloadGridTheme(
    backgroundColor: const Color.fromRGBO(30, 30, 30, 1),
    activeRowColor: Colors.black26,
    checkedRowColor: Color.fromRGBO(36, 63, 103, 1),
    borderColor: Colors.black26,
    rowColor: Colors.black26,
  ),
  settingTheme: SettingTheme(
    windowBackgroundColor: const Color.fromRGBO(25, 25, 25, 1),
    pageTheme: SettingPageTheme(
      pageBackgroundColor: Colors.black26,
      groupBackgroundColor: const Color.fromRGBO(42, 43, 43, 1),
      groupTitleTextColor: Colors.white,
      titleTextColor: Colors.white,
      dropDownBackgroundColor: Colors.black87,
      dropDownItemHoverBackgroundColor: Colors.black87,
      dropDownItemActiveBackgroundColor: Colors.black87,
      dropDownItemTextColor: Colors.white,
    ),
    sideMenuTheme: SettingSideMenuTheme(
      backgroundColor: Colors.black26,
      activeTabBackgroundColor: Colors.transparent,
      activeTabIconColor: Colors.white,
      inactiveTabIconColor: Colors.white,
      inactiveTabHoverBackgroundColor: const Color.fromRGBO(38, 38, 38, 1),
    ),
    cancelButtonColor: ButtonColor(
      iconColor: Colors.transparent,
      hoverIconColor: Colors.transparent,
      hoverBackgroundColor: Colors.red,
      hoverTextColor: Colors.white,
      borderColor: Colors.red,
      borderHoverColor: Colors.red,
    ),
    saveButtonColor: ButtonColor(
      iconColor: Colors.transparent,
      hoverIconColor: Colors.transparent,
      hoverBackgroundColor: Colors.green,
      hoverTextColor: Colors.white,
      borderColor: Colors.green,
      borderHoverColor: Colors.green,
    ),
    resetDefaultsButtonColor: ButtonColor(
      iconColor: Colors.transparent,
      hoverIconColor: Colors.transparent,
      hoverBackgroundColor: Colors.blueGrey,
      hoverTextColor: Colors.white,
      borderColor: Colors.blueGrey,
      borderHoverColor: Colors.blueGrey,
    ),
  ),
  queuePageTheme: QueuePageTheme(
    backgroundColor: const Color.fromRGBO(30, 30, 30, 1),
    queueItemIconColor: Colors.white38,
    queueItemTitleTextColor: Colors.white,
    queueItemTitleDetailsTextColor: Colors.grey,
    queueItemHoverColor: Colors.white12,
  ),
);

ApplicationTheme briskOld = ApplicationTheme(
  themeId: "Signature Blue",
  sideMenuTheme: SideMenuTheme(
    backgroundColor: const Color.fromRGBO(55, 64, 81, 1),
    briskLogoColor: Colors.white,
    activeTabIconColor: Colors.white,
    activeTabBackgroundColor: Colors.blueGrey,
    tabHoverColor: Colors.blueGrey,
    tabIconColor: Colors.white,
    tabBackgroundColor: Colors.transparent,
    expansionTileExpandedColor: Colors.blueGrey,
    expansionTileItemActiveColor: Colors.lightBlue,
    expansionTileItemHoverColor: Colors.lightBlue,
  ),
  topMenuTheme: TopMenuTheme(
    backgroundColor: const Color.fromRGBO(46, 54, 67, 1),
    addUrlColor: ButtonColor(
      iconColor: Colors.white,
      hoverIconColor: Colors.white,
      hoverBackgroundColor: Colors.blueGrey,
    ),
    downloadColor: ButtonColor(
      iconColor: Colors.white,
      hoverIconColor: Colors.white,
      hoverBackgroundColor: Colors.green,
    ),
    stopColor: ButtonColor(
      iconColor: Colors.white,
      hoverIconColor: Colors.white,
      hoverBackgroundColor: Colors.redAccent,
    ),
    stopAllColor: ButtonColor(
      iconColor: Colors.white,
      hoverIconColor: Colors.white,
      hoverBackgroundColor: Colors.redAccent,
    ),
    removeColor: ButtonColor(
      iconColor: Colors.white,
      hoverIconColor: Colors.white,
      hoverBackgroundColor: Colors.red,
    ),
    addToQueueColor: ButtonColor(
      iconColor: Colors.white,
      hoverIconColor: Colors.white,
      hoverBackgroundColor: Colors.teal,
    ),
    extensionColor: ButtonColor(
      iconColor: Colors.white,
      hoverIconColor: Colors.white,
      hoverBackgroundColor: Colors.blueGrey,
    ),
    createQueueColor: ButtonColor(
      iconColor: Colors.white,
      hoverIconColor: Colors.white,
      hoverBackgroundColor: Colors.green,
    ),
    startQueueColor: ButtonColor(
      iconColor: Colors.white,
      hoverIconColor: Colors.white,
      hoverBackgroundColor: Colors.green,
    ),
    stopQueueColor: ButtonColor(
      iconColor: Colors.white,
      hoverIconColor: Colors.white,
      hoverBackgroundColor: Colors.redAccent,
    ),
  ),
  downloadGridTheme: DownloadGridTheme(
    backgroundColor: Color.fromRGBO(40, 46, 58, 1),
    activeRowColor: Colors.black26,
    checkedRowColor: Colors.blueGrey,
    borderColor: Colors.black26,
    rowColor: Color.fromRGBO(49, 56, 72, 1),
  ),
  settingTheme: SettingTheme(
    windowBackgroundColor: const Color.fromRGBO(25, 25, 25, 1),
    pageTheme: SettingPageTheme(
      pageBackgroundColor: Colors.black26,
      groupBackgroundColor: const Color.fromRGBO(42, 43, 43, 1),
      groupTitleTextColor: Colors.white,
      titleTextColor: Colors.white,
      dropDownBackgroundColor: Colors.black87,
      dropDownItemHoverBackgroundColor: Colors.black87,
      dropDownItemActiveBackgroundColor: Colors.black87,
      dropDownItemTextColor: Colors.white,
    ),
    sideMenuTheme: SettingSideMenuTheme(
      backgroundColor: Colors.black26,
      activeTabBackgroundColor: Colors.transparent,
      activeTabIconColor: Colors.white,
      inactiveTabIconColor: Colors.white,
      inactiveTabHoverBackgroundColor: const Color.fromRGBO(38, 38, 38, 1),
    ),
    cancelButtonColor: ButtonColor(
      iconColor: Colors.transparent,
      hoverIconColor: Colors.transparent,
      hoverBackgroundColor: Colors.red,
      hoverTextColor: Colors.white,
      borderColor: Colors.red,
      borderHoverColor: Colors.red,
    ),
    saveButtonColor: ButtonColor(
      iconColor: Colors.transparent,
      hoverIconColor: Colors.transparent,
      hoverBackgroundColor: Colors.green,
      hoverTextColor: Colors.white,
      borderColor: Colors.green,
      borderHoverColor: Colors.green,
    ),
    resetDefaultsButtonColor: ButtonColor(
      iconColor: Colors.transparent,
      hoverIconColor: Colors.transparent,
      hoverBackgroundColor: Colors.blueGrey,
      hoverTextColor: Colors.white,
      borderColor: Colors.blueGrey,
      borderHoverColor: Colors.blueGrey,
    ),
  ),
  queuePageTheme: QueuePageTheme(
    backgroundColor: Color.fromRGBO(40, 46, 58, 1),
    queueItemIconColor: Colors.white38,
    queueItemTitleTextColor: Colors.white,
    queueItemTitleDetailsTextColor: Colors.grey,
    queueItemHoverColor: Colors.white12,
  ),
);
