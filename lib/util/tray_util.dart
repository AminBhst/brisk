import 'dart:io';

import 'package:brisk/util/platform.dart';
import 'package:tray_manager/tray_manager.dart';

Future<void> initTray() async {
  Menu menu = Menu(
    items: [
      MenuItem(
        key: 'show_window',
        label: 'Show Window',
      ),
      MenuItem.separator(),
      MenuItem(
        key: 'exit_app',
        label: 'Exit App',
      ),
    ],
  );
  if (isFlatpak) {
    await trayManager.setIcon("com.aminbhst.Brisk");
  } else {
    await trayManager.setIcon(
      Platform.isWindows ? 'assets/icons/logo.ico' : 'assets/icons/logo.png',
    );
  }
  await trayManager.setContextMenu(menu);
}
