import 'dart:io';

import 'package:brisk/l10n/app_localizations.dart';
import 'package:brisk/util/platform.dart';
import 'package:flutter/cupertino.dart';
import 'package:tray_manager/tray_manager.dart';

Future<void> initTray(BuildContext context) async {
  final loc = AppLocalizations.of(context)!;
  Menu menu = Menu(
    items: [
      MenuItem(key: 'show_window', label: loc.tray_showWindow),
      MenuItem.separator(),
      MenuItem(key: 'exit_app', label: loc.tray_exitApp),
    ],
  );
  if (isFlatpak) {
    await trayManager.setIcon("io.github.BrisklyDev.Brisk");
  } else if (isSnap) {
		final snapEnv = Platform.environment['SNAP'];
    await trayManager.setIcon("$snapEnv/meta/gui/brisk.png");
  } else {
    await trayManager.setIcon(
      Platform.isWindows ? 'assets/icons/logo.ico' : 'assets/icons/logo.png',
    );
  }
  await trayManager.setContextMenu(menu);
}
