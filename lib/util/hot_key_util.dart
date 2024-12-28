import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

import 'download_addition_ui_util.dart';

class HotKeyUtil {
  static bool _isHotKeyRegistered = false;

  static void registerDefaultDownloadAdditionHotKey(BuildContext context) {
    if (_isHotKeyRegistered) return;
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
    _isHotKeyRegistered = true;
  }
}
