import 'dart:io';

import 'package:brisk/l10n/app_localizations.dart';
import 'package:brisk/util/platform.dart';
import 'package:flutter/cupertino.dart';
import 'package:tray_manager/tray_manager.dart';

class TrayHandler {
  static bool isInTrayEnabled = false;
  static bool _isTrayInDownloadingMode = false;

  static Future<void> setTray(BuildContext context) async {
    final loc = AppLocalizations.of(context)!;
    Menu menu = Menu(
      items: [
        MenuItem(key: 'show_window', label: loc.tray_showWindow),
        MenuItem.separator(),
        MenuItem(key: 'exit_app', label: loc.tray_exitApp),
      ],
    );
    await trayManager.setIcon(trayInactiveIcon);
    await trayManager.setContextMenu(menu);
    isInTrayEnabled = true;
  }

  static Future<void> setTrayInactive() async {
    if (!isInTrayEnabled || !_isTrayInDownloadingMode) return;
    _isTrayInDownloadingMode = false;
    trayManager.setIcon(trayInactiveIcon);
  }

  static Future<void> setTrayDownloading() async {
    if (!isInTrayEnabled || _isTrayInDownloadingMode) return;
    _isTrayInDownloadingMode = true;
    await trayManager.setIcon(trayDownloadingIcon);
  }

  static String get trayDownloadingIcon {
    if (isFlatpak) {
      return "io.github.BrisklyDev.Brisk.trayActive";
    }
    if (isSnap) {
      final snapEnv = Platform.environment['SNAP'];
      return "$snapEnv/meta/gui/tray-active.png";
    }
    if (isWindows) {
      return "assets/icons/tray-active.ico";
    }
    return "assets/icons/tray-active.png";
  }

  static String get trayInactiveIcon {
    if (isFlatpak) {
      return isDarkMode
          ? "io.github.BrisklyDev.Brisk.trayInactiveDark"
          : "io.github.BrisklyDev.Brisk.trayInactiveLight";
    }
    if (isSnap) {
      final snapEnv = Platform.environment['SNAP'];
      return isDarkMode
          ? "$snapEnv/meta/gui/tray-inactive-light.png"
          : "$snapEnv/meta/gui/tray-inactive-dark.png";
    }
    if (isWindows) {
      return isDarkMode
          ? "assets/icons/tray-inactive-dark.ico"
          : "assets/icons/tray-inactive-light.ico";
    }
    return isDarkMode
        ? "assets/icons/tray-inactive-dark.png"
        : "assets/icons/tray-inactive-light.png";
  }

  static Future<void> handleSystemThemeChange() async {
    if (!isInTrayEnabled || _isTrayInDownloadingMode) return;
    bool isDarkMode =
        WidgetsBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark;
    String icon;
    if (isFlatpak) {
      icon = isDarkMode
          ? "io.github.BrisklyDev.Brisk.trayInactiveDark"
          : "io.github.BrisklyDev.Brisk.trayInactiveLight";
    } else if (isSnap) {
      final snapEnv = Platform.environment['SNAP'];
      icon = isDarkMode
          ? "$snapEnv/meta/gui/tray-inactive-light.png"
          : "$snapEnv/meta/gui/tray-inactive-dark.png";
    } else if (isWindows) {
      icon = isDarkMode
          ? "assets/icons/tray-inactive-dark.ico"
          : "assets/icons/tray-inactive-light.ico";
    } else {
      icon = isDarkMode
          ? "assets/icons/tray-inactive-dark.png"
          : "assets/icons/tray-inactive-light.png";
    }
    await trayManager.setIcon(icon);
  }
