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
    final hideHotkey = HotKey(
      key: LogicalKeyboardKey.keyH,
      modifiers: [HotKeyModifier.meta],
      scope: HotKeyScope.inapp,
    );
    final hideToTrayHotkey = HotKey(
      key: LogicalKeyboardKey.keyW,
      modifiers: [HotKeyModifier.meta],
      scope: HotKeyScope.inapp,
    );
    final quitHotkey = HotKey(
      key: LogicalKeyboardKey.keyQ,
      modifiers: [HotKeyModifier.meta],
      scope: HotKeyScope.inapp,
    );

    await hotKeyManager.register(
      hideHotkey,
      keyDownHandler: (_) => windowManager.hide(),
    );
    await hotKeyManager.register(
      hideToTrayHotkey,
      keyDownHandler: (_) => initTray().then((_) => windowManager.hide()),
    );
    await hotKeyManager.register(
      quitHotkey,
      keyDownHandler: (_) => windowManager.destroy().then((_) => exit(0)),
    );
    _isMacosWindowHotkeyRegistered = true;
  }

  static void registerDefaultDownloadAdditionHotKey(BuildContext context) {
    if (_isDownloadHotkeyRegistered) return;
    final _hotkey = HotKey(
      key: LogicalKeyboardKey.keyA,
      modifiers: [HotKeyModifier.control, HotKeyModifier.alt],
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
