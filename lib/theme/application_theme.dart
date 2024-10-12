import 'package:flutter/material.dart';

class ApplicationTheme {
  final String themeId;

  final SideMenuTheme sideMenuTheme;
  final TopMenuTheme topMenuTheme;
  final DownloadGridTheme downloadGridTheme;
  final SettingTheme settingTheme;

  ApplicationTheme({
    required this.themeId,
    required this.sideMenuTheme,
    required this.topMenuTheme,
    required this.downloadGridTheme,
    required this.settingTheme,
  });
}

class SideMenuTheme {
  final Color backgroundColor;
  final Color briskLogoColor;

  SideMenuTheme({
    required this.backgroundColor,
    required this.briskLogoColor,
  });
}

class TopMenuTheme {
  final Color backgroundColor;
  final ButtonColor addUrlColor;
  final ButtonColor downloadColor;
  final ButtonColor stopColor;
  final ButtonColor stopAllColor;
  final ButtonColor removeColor;
  final ButtonColor addToQueueColor;
  final ButtonColor extensionColor;

  TopMenuTheme({
    required this.backgroundColor,
    required this.addUrlColor,
    required this.downloadColor,
    required this.stopColor,
    required this.stopAllColor,
    required this.removeColor,
    required this.addToQueueColor,
    required this.extensionColor,
  });
}

class DownloadGridTheme {
  final Color backgroundColor;
  final Color activeRowColor;
  final Color checkedRowColor;
  final Color borderColor;
  final Color rowColor;

  DownloadGridTheme({
    required this.backgroundColor,
    required this.activeRowColor,
    required this.checkedRowColor,
    required this.borderColor,
    required this.rowColor,
  });
}

class SettingTheme {
  final windowBackgroundColor;
  final SettingPageTheme pageTheme;
  final SettingSideMenuTheme sideMenuTheme;
  final ButtonColor cancelButtonColor;
  final ButtonColor saveButtonColor;
  final ButtonColor resetDefaultsButtonColor;

  SettingTheme({
    required this.windowBackgroundColor,
    required this.pageTheme,
    required this.sideMenuTheme,
    required this.cancelButtonColor,
    required this.saveButtonColor,
    required this.resetDefaultsButtonColor,
  });
}

class SettingPageTheme {
  final Color pageBackgroundColor;
  final Color groupBackgroundColor;
  final Color groupTitleTextColor;
  final Color titleTextColor;
  final Color dropDownBackgroundColor;
  final Color dropDownItemHoverBackgroundColor;
  final Color dropDownItemActiveBackgroundColor;
  final Color dropDownItemTextColor;

  SettingPageTheme({
    required this.pageBackgroundColor,
    required this.groupBackgroundColor,
    required this.groupTitleTextColor,
    required this.titleTextColor,
    required this.dropDownBackgroundColor,
    required this.dropDownItemHoverBackgroundColor,
    required this.dropDownItemActiveBackgroundColor,
    required this.dropDownItemTextColor,
  });
}

class SettingSideMenuTheme {
  final Color backgroundColor;
  final Color activeTabBackgroundColor;
  final Color activeTabIconColor;
  final Color inactiveTabIconColor;
  final Color inactiveTabHoverBackgroundColor;

  SettingSideMenuTheme({
    required this.backgroundColor,
    required this.activeTabBackgroundColor,
    required this.activeTabIconColor,
    required this.inactiveTabIconColor,
    required this.inactiveTabHoverBackgroundColor,
  });
}

class ButtonColor {
  final Color iconColor;
  final Color textColor;
  final Color borderColor;
  final Color borderHoverColor;
  final Color BackgroundColor;
  final Color hoverIconColor;
  final Color hoverTextColor;
  final Color hoverBackgroundColor;

  const ButtonColor({
    required this.iconColor,
    required this.hoverIconColor,
    required this.hoverBackgroundColor,
    this.hoverTextColor = Colors.white60,
    this.BackgroundColor = Colors.transparent,
    this.textColor = Colors.white60,
    this.borderColor = Colors.transparent,
    this.borderHoverColor = Colors.transparent,
  });
}
