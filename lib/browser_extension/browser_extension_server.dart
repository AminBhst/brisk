import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:brisk/constants/setting_options.dart';
import 'package:brisk/db/hive_util.dart';
import 'package:brisk/model/download_item.dart';
import 'package:brisk/util/download_addition_ui_util.dart';
import 'package:brisk/util/http_util.dart';
import 'package:brisk/util/parse_util.dart';
import 'package:brisk/util/settings_cache.dart';
import 'package:brisk/widget/base/confirmation_dialog.dart';
import 'package:brisk/widget/base/error_dialog.dart';
import 'package:brisk/widget/download/multi_download_addition_dialog.dart';
import 'package:brisk/widget/loader/file_info_loader.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:window_to_front/window_to_front.dart';
import 'package:window_manager/window_manager.dart';

class BrowserExtensionServer {
  static bool _isServerRunning = false;
  static bool _cancelClicked = false;
  static const String extensionVersion = "1.1.3";

  static void setup(BuildContext context) async {
    if (_isServerRunning) return;

    final port = _extensionPort;
    try {
      _isServerRunning = true;
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
      handleExtensionRequests(server, context);
    } catch (e) {
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
        addCORSHeaders(request);
        try {
          final jsonBody = jsonDecode(String.fromCharCodes(body));
          final targetVersion = jsonBody["extensionVersion"];
          if (targetVersion == null ||
              isNewVersionAvailable(extensionVersion, targetVersion)) {
            showNewBrowserExtensionVersion(context);
            await flushAndCloseResponse(request);
            continue;
          }
          _handleDownloadAddition(jsonBody, context, request);
        } catch (e) {
          print(e);
        }
      }
      await flushAndCloseResponse(request);
    }
  }

  static void showNewBrowserExtensionVersion(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title:
            "A new version of Brisk browser extension is available. The extension will not function until you update to the latest version."
            "\nDo you want to be redirected to the extension download page?",
        onConfirmPressed: () => launchUrlString(
          "https://github.com/AminBhst/brisk-browser-extension/releases/latest",
        ),
      ),
    );
  }

  static void _handleDownloadAddition(jsonBody, context, request) {
    final type = jsonBody["type"];
    if (type == "single") {
      _handleSingleDownloadRequest(jsonBody, context, request);
    }
    if (type == "multi") {
      _handleMultiDownloadRequest(jsonBody, context, request);
    }
  }

  static Future<void> flushAndCloseResponse(HttpRequest request) async {
    await request.response.flush();
    request.response.write("");
  }

  static void addCORSHeaders(HttpRequest httpRequest) {
    httpRequest.response.headers.add("Access-Control-Allow-Origin", "*");
    httpRequest.response.headers.add("Access-Control-Allow-Headers", "*");
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
      if (_cancelClicked) {
        return;
      }
      if (fileInfos == null || fileInfos.isEmpty) {
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

  static void _handleSingleDownloadRequest(jsonBody, context, request) {
    final url = jsonBody['data']['url'];
    final downloadItem = DownloadItem.fromUrl(url);
    if (!isUrlValid(url)) {
      request.response.statusCode = HttpStatus.badRequest;
      return;
    }
    final fileInfoResponse = DownloadAdditionUiUtil.requestFileInfo(url);
    fileInfoResponse.then((fileInfo) {
      final satisfied = SettingsCache.extensionSkipCaptureRules.any(
        (rule) => rule.isSatisfied(fileInfo),
      );
      if (satisfied) {
        request.response.statusCode = HttpStatus.notAcceptable;
        return;
      }
      if (_windowToFrontEnabled) {
        windowManager.show().then((_) => WindowToFront.activate());
      }
      DownloadAdditionUiUtil.addDownload(
        downloadItem,
        fileInfo,
        context,
        false,
      );
      request.response.statusCode = HttpStatus.ok;
    });
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
