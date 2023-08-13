import 'dart:convert';
import 'dart:io';

import 'package:brisk/db/hive_util.dart';
import 'package:brisk/util/download_addition_ui_util.dart';
import 'package:brisk/util/parse_util.dart';
import 'package:brisk/widget/base/error_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:window_to_front/window_to_front.dart';

/// TODO : UPDATE URL AUTOMATICALLY
class BrowserExtensionServer {
  static bool _isServerRunning = false;

  /// TODO catch port usage exception
  static void start(BuildContext context) async {
    if (_isServerRunning) return;
    final port = HiveUtil.instance.settingBox.get(17)?.value ?? '3020';
    final enableWindowToFront =
        HiveUtil.instance.settingBox.get(16)?.value ?? 'true';
    var server;
    try {
      _isServerRunning = true;
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, int.parse(port));
    } catch (e) {
      _showPortInUseError(context, port);
      return;
    }
    await for (var request in server) {
      request.listen((event) async {
        final json = jsonDecode(String.fromCharCodes(event));
        if (parseBool(enableWindowToFront)) {
          WindowToFront.activate();
        }
        /// TODO make use of cookies
        DownloadAdditionUiUtil.handleDownloadAddition(context, json['url']);
        await request.response.flush();
        await request.response.close();
        return;
      });
    }
  }

  static void _showPortInUseError(BuildContext context, String port) {
    showDialog(
        context: context,
        builder: (context) => ErrorDialog(
            width: 750,
            height: 100,
            title: "Port ${port} is already in use by another process!",
            text:
                "\nFor optimal browser integration, please change the extension port in [Settings->Extension->Port] then restart the app."
                " Finally, set the same port number for the browser extension by clicking on its icon."));
  }
}
