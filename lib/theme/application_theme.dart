import 'package:flutter/material.dart';

class ApplicationTheme {
  final String themeId;

  final SideMenuTheme sideMenuTheme;
  final TopMenuTheme topMenuTheme;
  final DownloadGridTheme downloadGridTheme;
  final QueuePageTheme queuePageTheme;
  final SettingTheme settingTheme;
  final DownloadInfoTheme downloadInfoDialogTheme;
  final Color rightClickMenuBackgroundColor;
  AlertDialogTheme alertDialogTheme;
  DownloadProgressDialogTheme downloadProgressDialogTheme;

  ApplicationTheme({
    required this.themeId,
    required this.sideMenuTheme,
    required this.topMenuTheme,
    required this.downloadGridTheme,
    required this.queuePageTheme,
    required this.settingTheme,
    required this.alertDialogTheme,
    required this.downloadProgressDialogTheme,
    required this.downloadInfoDialogTheme,
    this.rightClickMenuBackgroundColor = const Color.fromRGBO(20, 20, 20, 1),
  });
}

class DownloadInfoTheme {
  final ButtonColor openFileColor;
  final ButtonColor openFileLocationColor;
  final ButtonColor downloadColor;
  final ButtonColor addToListColor;
  final ButtonColor cancelColor;

  DownloadInfoTheme({
    required this.openFileColor,
    required this.openFileLocationColor,
    required this.downloadColor,
    required this.addToListColor,
    required this.cancelColor,
  });
}

class QueuePageTheme {
  final Color backgroundColor;
  final Color queueItemIconColor;
  final Color queueItemTitleTextColor;
  final Color queueItemTitleDetailsTextColor;
  final Color queueItemHoverColor;

  QueuePageTheme({
    required this.backgroundColor,
    required this.queueItemIconColor,
    required this.queueItemTitleTextColor,
    required this.queueItemTitleDetailsTextColor,
    required this.queueItemHoverColor,
  });
}

class SideMenuTheme {
  final Color backgroundColor;
  final Color briskLogoColor;
  final Color activeTabIconColor;
  final Color activeTabBackgroundColor;
  final Color tabIconColor;
  final Color tabBackgroundColor;
  final Color tabHoverColor;
  final Color expansionTileExpandedColor;
  final Color expansionTileItemHoverColor;
  final Color expansionTileItemActiveColor;

  SideMenuTheme({
    required this.backgroundColor,
    required this.briskLogoColor,
    required this.activeTabIconColor,
    required this.activeTabBackgroundColor,
    required this.tabIconColor,
    required this.tabHoverColor,
    required this.expansionTileExpandedColor,
    required this.expansionTileItemHoverColor,
    required this.expansionTileItemActiveColor,
    this.tabBackgroundColor = Colors.transparent,
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
  final ButtonColor createQueueColor;
  final ButtonColor startQueueColor;
  final ButtonColor scheduleQueueColor;
  final ButtonColor stopQueueColor;
  final ButtonColor checkForUpdateColor;

  TopMenuTheme({
    required this.backgroundColor,
    required this.addUrlColor,
    required this.downloadColor,
    required this.stopColor,
    required this.stopAllColor,
    required this.removeColor,
    required this.addToQueueColor,
    required this.extensionColor,
    required this.createQueueColor,
    required this.startQueueColor,
    required this.stopQueueColor,
    required this.checkForUpdateColor,
    required this.scheduleQueueColor,
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

class AlertDialogTheme {
  final Color backgroundColor;
  final Color textColor;
  final Color iconColor;
  final ButtonColor addButtonColor;
  final ButtonColor cancelButtonColor;
  final ButtonColor deleteConfirmColor;
  final ButtonColor deleteCancelColor;
  final Color itemContainerBackgroundColor;
  final TextFieldColor urlFieldColor;
  final CheckBoxColor checkBoxColor;
  final Color innerContainerBorderColor;
  final Color placeHolderIconColor;
  final Color placeHolderTextColor;

  AlertDialogTheme({
    required this.backgroundColor,
    required this.textColor,
    required this.iconColor,
    required this.addButtonColor,
    required this.cancelButtonColor,
    required this.urlFieldColor,
    required this.checkBoxColor,
    required this.innerContainerBorderColor,
    required this.placeHolderIconColor,
    required this.placeHolderTextColor,
    required this.deleteConfirmColor,
    required this.deleteCancelColor,
    required this.itemContainerBackgroundColor,
  });
}

class CheckBoxColor {
  final Color borderColor;
  final Color activeColor;

  CheckBoxColor({
    required this.borderColor,
    required this.activeColor,
  });
}

class DownloadProgressDialogTheme {
  final Color windowBackgroundColor;
  final Color detailsContainerBorderColor;
  final Color detailsContainerBackgroundColor;
  final Color detailsContainerTextColor;
  final Color infoContainerBorderColor;
  final Color infoContainerBackgroundColor;
  final Color infoContainerTextColor;
  final Color assemblingStatusProgressColor;
  final Color validatingFilesStatusProgressColor;
  final ProgressIndicatorColor totalProgressColor;
  final ProgressIndicatorColor connectionProgressColor;
  final ButtonColor pauseColor;
  final ButtonColor resumeColor;

  DownloadProgressDialogTheme({
    required this.windowBackgroundColor,
    required this.detailsContainerBorderColor,
    required this.detailsContainerBackgroundColor,
    required this.detailsContainerTextColor,
    required this.infoContainerBorderColor,
    required this.infoContainerBackgroundColor,
    required this.infoContainerTextColor,
    required this.pauseColor,
    required this.resumeColor,
    this.totalProgressColor = const ProgressIndicatorColor(
      color: Colors.green,
      backgroundColor: Color.fromRGBO(47, 44, 44, 0.9),
    ),
    this.connectionProgressColor = const ProgressIndicatorColor(
      color: Colors.indigoAccent,
      backgroundColor: Color.fromRGBO(47, 44, 44, 0.95),
    ),
    this.assemblingStatusProgressColor = Colors.green,
    this.validatingFilesStatusProgressColor = Colors.blueAccent,
  });
}

class ProgressIndicatorColor {
  final Color backgroundColor;
  final Color color;

  const ProgressIndicatorColor({
    required this.backgroundColor,
    required this.color,
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
  final Color itemAccentColor;
  final SettingWidgetColor widgetColor;

  SettingPageTheme({
    required this.pageBackgroundColor,
    required this.groupBackgroundColor,
    required this.groupTitleTextColor,
    required this.titleTextColor,
    required this.widgetColor,
    required this.itemAccentColor,
  });
}

class SettingWidgetColor {
  final SwitchColor switchColor;
  final DropDownColor dropDownColor;
  final TextFieldColor textFieldColor;
  Color launchIconColor;
  final Color aboutIconColor;

  SettingWidgetColor({
    required this.switchColor,
    required this.dropDownColor,
    required this.textFieldColor,
    this.launchIconColor = Colors.white,
    required this.aboutIconColor,
  });
}

class TextFieldColor {
  final Color focusBorderColor;
  final Color borderColor;
  final Color? fillColor;
  final Color textColor;
  Color? cursorColor;
  Color? hoverColor;

  TextFieldColor({
    required this.focusBorderColor,
    required this.borderColor,
    this.fillColor,
    required this.textColor,
    this.cursorColor,
    this.hoverColor,
  });
}

class DropDownColor {
  final Color dropDownBackgroundColor;
  final Color ItemTextColor;

  DropDownColor({
    required this.dropDownBackgroundColor,
    required this.ItemTextColor,
  });
}

class SwitchColor {
  Color? activeColor;
  Color? hoverColor;
  Color? focusColor;

  SwitchColor({
    this.activeColor,
    this.hoverColor,
    this.focusColor,
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
  final Color backgroundColor;
  final Color hoverIconColor;
  final Color hoverTextColor;
  final Color hoverBackgroundColor;

  const ButtonColor({
    required this.iconColor,
    required this.hoverIconColor,
    required this.hoverBackgroundColor,
    this.hoverTextColor = Colors.white60,
    this.backgroundColor = Colors.transparent,
    this.textColor = Colors.white60,
    this.borderColor = Colors.transparent,
    this.borderHoverColor = Colors.transparent,
  });
}
