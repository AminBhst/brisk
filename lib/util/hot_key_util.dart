// import 'package:clipboard/clipboard.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/services.dart';
// import 'package:hotkey_manager/hotkey_manager.dart';
//
// import 'download_addition_ui_util.dart';
//
// void registerDefaultDownloadAdditionHotKey(BuildContext context) {
//   final _hotkey = HotKey(
//     key: LogicalKeyboardKey.keyA,
//     modifiers: [HotKeyModifier.control, HotKeyModifier.alt],
//     scope: HotKeyScope.inapp,
//   );
//   hotKeyManager.register(
//     _hotkey,
//     keyDownHandler: (hotKey) async {
//       String url = await FlutterClipboard.paste();
//       DownloadAdditionUiUtil.handleDownloadAddition(context, url);
//     },
//   );
// }
