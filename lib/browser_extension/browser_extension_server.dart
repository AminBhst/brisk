import 'dart:convert';
import 'dart:io';

import 'package:brisk/db/hive_util.dart';
import 'package:brisk/util/download_addition_ui_util.dart';
import 'package:brisk/util/parse_util.dart';
import 'package:brisk/widget/base/error_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:window_to_front/window_to_front.dart';

class BrowserExtensionServer {
  static bool _isServerRunning = false;

  static void start(BuildContext context) async {
    if (_isServerRunning) return;

    final port = _extensionPort;
    try {
      _isServerRunning = true;
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
      await handleExtensionRequests(server, _windowToFrontEnabled, context);
    } catch (e) {
      _showPortInUseError(context, port.toString());
    }
  }

  static Future<void> handleExtensionRequests(
      server, bool windowToFront, BuildContext context) async {
    await for (HttpRequest request in server) {
      request.listen((body) async {
        final jsonBody = jsonDecode(String.fromCharCodes(body));
        if (windowToFront) {
          WindowToFront.activate();
        }
        _handleDownloadAddition(jsonBody, context, request);
      });
    }
  }

  static void _handleDownloadAddition(jsonBody, context, request) async {
    final type = jsonBody["type"];
    if (type == "single") {
      _handleSingleDownloadRequest(jsonBody, context, request);
    }
    if (type == "multi") {
      _handleMultiDownloadRequest(jsonBody, context, request);
    }
  }

  static void _handleMultiDownloadRequest(jsonBody, context, request) {
    List downloadHrefs = jsonBody["data"]["downloadHrefs"];
    if (downloadHrefs.isEmpty) return;

  }

  static void _handleSingleDownloadRequest(jsonBody, context, request) async {
    DownloadAdditionUiUtil.handleDownloadAddition(context, jsonBody['url']);
    addCORSHeaders(request);
    request.response.statusCode = HttpStatus.ok;
    await request.response.close();
  }

  static void addCORSHeaders(HttpRequest httpRequest) {
    httpRequest.response.headers.add("Access-Control-Allow-Origin", "*");
    httpRequest.response.headers.add("Access-Control-Allow-Headers", "*");
  }

  static int get _extensionPort =>
      int.parse(HiveUtil.instance.settingBox.get(17)?.value ?? '3020');

  static bool get _windowToFrontEnabled =>
      parseBool(HiveUtil.instance.settingBox.get(16)?.value ?? 'true');

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
