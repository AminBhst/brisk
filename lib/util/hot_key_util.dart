import 'dart:io';

import 'package:brisk/util/tray_util.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:window_manager/window_manager.dart';

import 'download_addition_ui_util.dart';

class HotKeyUtil {
  static bool _isDownloadHotkeyRegistered = false;
  static bool _isMacosWindowHotkeyRegistered = false;

  static void registerMacOsDefaultWindowHotkeys() async {
    if (!Platform.isMacOS || _isMacosWindowHotkeyRegistered) return;
    //Show window thumbnail in dock, keep dock icon,
    // click window thumbnail or dock icon to restore window,
    // and the thumbnail disappears after restoration
    final hideHotkey = HotKey(
      key: LogicalKeyboardKey.keyH,
      modifiers: [HotKeyModifier.meta],
      scope: HotKeyScope.inapp,
    );
    //Hide window to tray, no dock icon, no thumbnail window
    final hideToTrayHotkey = HotKey(
      key: LogicalKeyboardKey.keyW,
      modifiers: [HotKeyModifier.meta],
      scope: HotKeyScope.inapp,
    );
    //Quit app / kill process
    final quitHotkey = HotKey(
      key: LogicalKeyboardKey.keyQ,
      modifiers: [HotKeyModifier.meta],
      scope: HotKeyScope.inapp,
    );

    await hotKeyManager.register(
      hideHotkey,
      keyDownHandler: (_) => windowManager.minimize(),
    );
    await hotKeyManager.register(
      hideToTrayHotkey,
      keyDownHandler: (_) => initTray().then((_) async {
        await windowManager.hide();
        windowManager.setSkipTaskbar(true);
      }),
    );
    await hotKeyManager.register(
      quitHotkey,
      keyDownHandler: (_) => windowManager.destroy().then((_) => exit(0)),
    );
    _isMacosWindowHotkeyRegistered = true;
  }
  static void registerDefaultDownloadAdditionHotKey(BuildContext context) {
    /*
      Command + N for MacOS
      Control + Alt + A for Windows/Linux
    */
    var modifiers = Platform.isMacOS
        ? [HotKeyModifier.meta]
        : [HotKeyModifier.control, HotKeyModifier.alt];
    var key =
        Platform.isMacOS ? LogicalKeyboardKey.keyN : LogicalKeyboardKey.keyA;
    if (_isDownloadHotkeyRegistered) return;
    final _hotkey = HotKey(
      key: key,
      modifiers: modifiers,
      scope: HotKeyScope.inapp,
    );
    hotKeyManager.register(
      _hotkey,
      keyDownHandler: (hotKey) async {
        String url = await FlutterClipboard.paste();
        DownloadAdditionUiUtil.handleDownloadAddition(context, url);
      },
    );
    _isDownloadHotkeyRegistered = true;
  }
}
