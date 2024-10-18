import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:brisk/constants/setting_options.dart';
import 'package:brisk/db/hive_util.dart';
import 'package:brisk/model/download_item.dart';
import 'package:brisk/util/download_addition_ui_util.dart';
import 'package:brisk/util/http_util.dart';
import 'package:brisk/util/parse_util.dart';
import 'package:brisk/widget/base/error_dialog.dart';
import 'package:brisk/widget/download/multi_download_addition_dialog.dart';
import 'package:brisk/widget/loader/file_info_loader.dart';
import 'package:flutter/material.dart';
import 'package:window_to_front/window_to_front.dart';
import 'package:window_manager/window_manager.dart';

class BrowserExtensionServer {
  static bool _isServerRunning = false;
  static bool _cancelClicked = false;

  static void setup(BuildContext context) async {
    if (_isServerRunning) return;

    final port = _extensionPort;
    try {
      _isServerRunning = true;
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
      handleExtensionRequests(server, context);
    } catch (e) {
      print("ERROR $e");
      if (e.toString().contains("Invalid port")) {
        _showInvalidPortError(context, port.toString());
        return;
      }
      if (e.toString().contains("Only one usage of each socket address")) {
        _showPortInUseError(context, port.toString());
        return;
      }
      _showUnexpectedError(context, port.toString(), e);
    }
  }

  static Future<void> handleExtensionRequests(server, context) async {
    await for (HttpRequest request in server) {
      await for (final body in request) {
        final jsonBody = jsonDecode(String.fromCharCodes(body));
        if (_windowToFrontEnabled) {
          await windowManager.show();
          WindowToFront.activate();
        }
        await _handleDownloadAddition(jsonBody, context, request);
      }
    }
  }

  static Future<void> _handleDownloadAddition(
      jsonBody, context, request) async {
    final type = jsonBody["type"];
    if (type == "single") {
      _handleSingleDownloadRequest(jsonBody, context, request);
    }
    if (type == "multi") {
      _handleMultiDownloadRequest(jsonBody, context, request);
    }
    await request.response.flush();
    await request.response.close();
  }

  static void _handleMultiDownloadRequest(jsonBody, context, request) {
    List downloadHrefs = jsonBody["data"]["downloadHrefs"];
    if (downloadHrefs.isEmpty) return;
    downloadHrefs = downloadHrefs.toSet().toList() // removes duplicates
      ..removeWhere((url) => !isUrlValid(url));
    final downloadItems =
        downloadHrefs.map((e) => DownloadItem.fromUrl(e)).toList();
    _cancelClicked = false;
    _showLoadingDialog(context);
    requestFileInfoBatch(downloadItems.toList()).then((fileInfos) {
      if (_cancelClicked || fileInfos == null || fileInfos.isEmpty) {
        return onFileInfoRetrievalError(context);
      }
      Navigator.of(context).pop();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => MultiDownloadAdditionDialog(fileInfos),
      );
    }).onError((error, stackTrace) => onFileInfoRetrievalError(context));
  }

  /// TODO add log file
  static onFileInfoRetrievalError(context) {
    print("ER");
    Navigator.of(context).pop();
    showDialog(
      context: context,
      builder: (_) => const ErrorDialog(
        textHeight: 0,
        title: "Could not retrieve file information!",
      ),
    );
  }

  static void _showLoadingDialog(context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => FileInfoLoader(onCancelPressed: () {
        _cancelClicked = true;
        Navigator.of(context).pop();
      }),
    );
  }

  static void _handleSingleDownloadRequest(jsonBody, context, request) async {
    DownloadAdditionUiUtil.handleDownloadAddition(
      context,
      jsonBody['data']['url'],
    );
    addCORSHeaders(request);
    request.response.statusCode = HttpStatus.ok;
  }

  static void addCORSHeaders(HttpRequest httpRequest) {
    httpRequest.response.headers.add("Access-Control-Allow-Origin", "*");
    httpRequest.response.headers.add("Access-Control-Allow-Headers", "*");
  }

  static int get _extensionPort => int.parse(
        HiveUtil.getSetting(SettingOptions.extensionPort)?.value ?? "3020",
      );

  static bool get _windowToFrontEnabled => parseBool(
        HiveUtil.getSetting(SettingOptions.enableWindowToFront)?.value ??
            "true",
      );

  static void _showPortInUseError(BuildContext context, String port) {
    showDialog(
        context: context,
        builder: (context) => ErrorDialog(
            width: 750,
            height: 130,
            textHeight: 70,
            title: "Port ${port} is already in use by another process!",
            text:
                "\nFor optimal browser integration, please change the extension port in [Settings->Extension->Port] then restart the app."
                " Finally, set the same port number for the browser extension by clicking on its icon."));
  }

  static void _showInvalidPortError(BuildContext context, String port) {
    showDialog(
      context: context,
      builder: (context) => ErrorDialog(
          width: 750,
          height: 85,
          textHeight: 40,
          textSpaceBetween: 18,
          title: "Port $port is invalid!",
          text:
              "Please set a valid port value in app settings, then set the same value for the browser extension"),
    );
  }

  static void _showUnexpectedError(BuildContext context, String port, e) {
    showDialog(
      context: context,
      builder: (context) => ErrorDialog(
        width: 750,
        height: 200,
        textHeight: 40,
        textSpaceBetween: 10,
        title: "Failed to listen to port $port! ${e.runtimeType}",
        text: e.toString(),
      ),
    );
  }
}
