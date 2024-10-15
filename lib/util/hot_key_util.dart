import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

import 'download_addition_ui_util.dart';

// void registerDefaultDownloadAdditionHotKey(BuildContext context) {
//   HotKey _hotKey = HotKey(
//     KeyCode.keyA,
//     modifiers: [KeyModifier.alt, KeyModifier.control],
//     scope: HotKeyScope.inapp,
//   );
//   hotKeyManager.register(
//     _hotKey,
//     keyDownHandler: (hotKey) async {
//       String url = await FlutterClipboard.paste();
//       DownloadAdditionUiUtil.handleDownloadAddition(context, url);
//     },
//   );
// }