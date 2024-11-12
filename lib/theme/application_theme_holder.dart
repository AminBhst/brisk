import 'package:brisk/theme/application_theme.dart';
import 'package:brisk/util/settings_cache.dart';
import 'package:flutter/material.dart';

class ApplicationThemeHolder {
  static final List<ApplicationTheme> themes = [celestialDark, signatureBlue];
  static late ApplicationTheme activeTheme = celestialDark;

  static void setActiveTheme() {
    activeTheme = themes
        .where((t) => t.themeId == SettingsCache.applicationThemeId)
        .first;
  }
}

ApplicationTheme celestialDark = ApplicationTheme(
  themeId: "Celestial Dark",
  downloadProgressWindowTheme: DownloadProgressWindowTheme(
    windowBackgroundColor: const Color.fromRGBO(25, 25, 25, 1),
    detailsContainerBorderColor: Colors.white10,
    detailsContainerBackgroundColor: const Color.fromRGBO(25, 25, 25, 0.7),
    detailsContainerTextColor: Colors.white,
    infoContainerBorderColor: Colors.white24,
    infoContainerBackgroundColor: const Color.fromRGBO(25, 25, 25, 0.7),
    infoContainerTextColor: Colors.white,
  ),
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
    checkForUpdateColor: const ButtonColor(
      iconColor: Color.fromRGBO(0, 128, 128, 1),
      hoverIconColor: Color.fromRGBO(0, 128, 128, 1),
      hoverBackgroundColor: Color.fromRGBO(0, 128, 128, 0.3),
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
    activeRowColor: const Color.fromRGBO(49, 48, 48, 1),
    checkedRowColor: Color.fromRGBO(36, 63, 103, 1),
    borderColor: Colors.black26,
    rowColor: Colors.black26,
  ),
  settingTheme: SettingTheme(
    windowBackgroundColor: const Color.fromRGBO(20, 20, 20, 1),
    pageTheme: SettingPageTheme(
        pageBackgroundColor: const Color.fromRGBO(15, 15, 15, 1),
        groupBackgroundColor: const Color.fromRGBO(42, 43, 43, 1),
        groupTitleTextColor: Colors.white,
        titleTextColor: Colors.white,
        widgetColor: SettingWidgetColor(
          launchIconColor: Colors.white,
          switchColor: SwitchColor(
            activeColor: Colors.green,
            focusColor: Colors.lightGreen,
          ),
          dropDownColor: DropDownColor(
            dropDownBackgroundColor: Color.fromRGBO(25, 25, 25, 1),
            ItemTextColor: Colors.white,
          ),
          textFieldColor: TextFieldColor(
            focusBorderColor: const Color.fromRGBO(53, 89, 143, 1),
            borderColor: Colors.white70,
            fillColor: Colors.black12,
            textColor: Colors.white,
            cursorColor: Colors.white,
          ),
          aboutIconColor: Colors.white70,
        )),
    sideMenuTheme: SettingSideMenuTheme(
      backgroundColor: const Color.fromRGBO(15, 15, 15, 1),
      activeTabBackgroundColor: const Color.fromRGBO(53, 89, 143, 1),
      activeTabIconColor: Colors.white,
      inactiveTabIconColor: Colors.white,
      inactiveTabHoverBackgroundColor: const Color.fromRGBO(38, 38, 38, 1),
    ),
    cancelButtonColor: ButtonColor(
      iconColor: Colors.transparent,
      hoverIconColor: Colors.transparent,
      textColor: Colors.red,
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
      textColor: Colors.green,
      borderColor: Colors.green,
      borderHoverColor: Colors.green,
    ),
    resetDefaultsButtonColor: ButtonColor(
      iconColor: Colors.transparent,
      hoverIconColor: Colors.transparent,
      hoverBackgroundColor: Color.fromRGBO(53, 89, 143, 1),
      hoverTextColor: Colors.white,
      borderColor: Color.fromRGBO(53, 89, 143, 1),
      textColor: Color.fromRGBO(53, 89, 143, 1),
      borderHoverColor: Color.fromRGBO(53, 89, 143, 1),
    ),
  ),
  queuePageTheme: QueuePageTheme(
    backgroundColor: const Color.fromRGBO(30, 30, 30, 1),
    queueItemIconColor: Colors.white38,
    queueItemTitleTextColor: Colors.white,
    queueItemTitleDetailsTextColor: Colors.grey,
    queueItemHoverColor: Colors.white12,
  ),
  alertDialogTheme: AlertDialogTheme(
    backgroundColor: const Color.fromRGBO(20, 20, 20, 1),
    innerContainerBorderColor: Colors.white30,
    textColor: Colors.white,
    iconColor: Colors.white,
    checkBoxColor: CheckBoxColor(
      borderColor: Colors.grey,
      activeColor: Color.fromRGBO(53, 89, 143, 1),
    ),
    placeHolderIconColor: Colors.white10,
    placeHolderTextColor: Colors.white10,
    addButtonColor: ButtonColor(
      iconColor: Colors.transparent,
      hoverIconColor: Colors.transparent,
      hoverBackgroundColor: Colors.green,
      hoverTextColor: Colors.white,
      textColor: Colors.green,
      borderColor: Colors.green,
      borderHoverColor: Colors.green,
    ),
    cancelButtonColor: ButtonColor(
      iconColor: Colors.transparent,
      hoverIconColor: Colors.transparent,
      textColor: Colors.red,
      hoverBackgroundColor: Colors.red,
      hoverTextColor: Colors.white,
      borderColor: Colors.red,
      borderHoverColor: Colors.red,
    ),
    urlFieldColor: TextFieldColor(
      focusBorderColor: Colors.white,
      borderColor: Colors.white,
      textColor: Colors.white,
    ),
  ),
);

ApplicationTheme signatureBlue = ApplicationTheme(
  themeId: "Signature Blue",
  downloadProgressWindowTheme: DownloadProgressWindowTheme(
    windowBackgroundColor: Color.fromRGBO(33, 43, 49, 1.0),
    detailsContainerBorderColor: Colors.white24,
    detailsContainerBackgroundColor: Color.fromRGBO(33, 43, 49, 8.0),
    detailsContainerTextColor: Colors.white,
    infoContainerBorderColor: Colors.white24,
    infoContainerBackgroundColor: Color.fromRGBO(33, 43, 49, 9.0),
    infoContainerTextColor: Colors.white,
  ),
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
  alertDialogTheme: AlertDialogTheme(
    backgroundColor: Color.fromRGBO(33, 43, 49, 1.0),
    innerContainerBorderColor: Colors.white38,
    textColor: Colors.white,
    iconColor: Colors.white,
    placeHolderIconColor: Colors.white10,
    placeHolderTextColor: Colors.white10,
    checkBoxColor: CheckBoxColor(
      borderColor: Colors.grey,
      activeColor: Colors.blueGrey,
    ),
    addButtonColor: ButtonColor(
      iconColor: Colors.transparent,
      hoverIconColor: Colors.transparent,
      hoverBackgroundColor: Colors.green,
      hoverTextColor: Colors.white,
      textColor: Colors.green,
      borderColor: Colors.green,
      borderHoverColor: Colors.green,
    ),
    cancelButtonColor: ButtonColor(
      iconColor: Colors.transparent,
      hoverIconColor: Colors.transparent,
      textColor: Colors.red,
      hoverBackgroundColor: Colors.red,
      hoverTextColor: Colors.white,
      borderColor: Colors.red,
      borderHoverColor: Colors.red,
    ),
    urlFieldColor: TextFieldColor(
      focusBorderColor: Colors.white,
      borderColor: Colors.white,
      textColor: Colors.white,
    ),
  ),
  topMenuTheme: TopMenuTheme(
    backgroundColor: const Color.fromRGBO(46, 54, 67, 1),
    addUrlColor: ButtonColor(
      iconColor: Colors.white,
      hoverIconColor: Colors.white,
      hoverBackgroundColor: Colors.blueGrey,
    ),
    checkForUpdateColor: ButtonColor(
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
    windowBackgroundColor: Color.fromRGBO(33, 43, 49, 1.0),
    pageTheme: SettingPageTheme(
      pageBackgroundColor: Colors.black26,
      groupBackgroundColor: Color.fromRGBO(33, 43, 49, 6.0),
      groupTitleTextColor: Colors.white,
      titleTextColor: Colors.white,
      widgetColor: SettingWidgetColor(
        switchColor: SwitchColor(
          activeColor: Colors.green,
          focusColor: Colors.lightGreen,
          hoverColor: Colors.greenAccent,
        ),
        dropDownColor: DropDownColor(
          dropDownBackgroundColor: Colors.black26,
          ItemTextColor: Colors.white,
        ),
        textFieldColor: TextFieldColor(
          focusBorderColor: Colors.blueGrey,
          borderColor: Colors.white,
          fillColor: Colors.black12,
          textColor: Colors.white,
          cursorColor: Colors.white,
        ),
        aboutIconColor: Colors.white70,
      ),
    ),
    sideMenuTheme: SettingSideMenuTheme(
      backgroundColor: Colors.black26,
      activeTabBackgroundColor: Colors.blueGrey,
      activeTabIconColor: Colors.white,
      inactiveTabIconColor: Colors.white,
      inactiveTabHoverBackgroundColor: Colors.black26,
    ),
    cancelButtonColor: ButtonColor(
      iconColor: Colors.transparent,
      hoverIconColor: Colors.transparent,
      textColor: Colors.red,
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
      textColor: Colors.green,
      borderColor: Colors.green,
      borderHoverColor: Colors.green,
    ),
    resetDefaultsButtonColor: ButtonColor(
      iconColor: Colors.transparent,
      hoverIconColor: Colors.transparent,
      hoverBackgroundColor: Colors.blueGrey,
      hoverTextColor: Colors.white,
      borderColor: Colors.blueGrey,
      textColor: Colors.blueGrey,
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
