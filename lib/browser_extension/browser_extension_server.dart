import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:brisk/constants/setting_options.dart';
import 'package:brisk/constants/setting_type.dart';
import 'package:brisk/db/hive_util.dart';
import 'package:brisk/download_engine/model/m3u8.dart';
import 'package:brisk/download_engine/util/m3u8_util.dart';
import 'package:brisk/model/download_item.dart';
import 'package:brisk/model/setting.dart';
import 'package:brisk/util/auto_updater_util.dart';
import 'package:brisk/util/download_addition_ui_util.dart';
import 'package:brisk/util/http_util.dart';
import 'package:brisk/util/parse_util.dart';
import 'package:brisk/util/settings_cache.dart';
import 'package:brisk/widget/base/error_dialog.dart';
import 'package:brisk/widget/download/m3u8_master_playlist_dialog.dart';
import 'package:brisk/widget/download/multi_download_addition_dialog.dart';
import 'package:brisk/widget/download/update_available_dialog.dart';
import 'package:brisk/widget/loader/file_info_loader.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:window_to_front/window_to_front.dart';
import 'package:window_manager/window_manager.dart';

class BrowserExtensionServer {
  static bool _isServerRunning = false;
  static bool _cancelClicked = false;
  static const String extensionVersion = "1.2.2";

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
        bool responseClosed = false;
        addCORSHeaders(request);
        try {
          final jsonBody = jsonDecode(String.fromCharCodes(body));
          final targetVersion = jsonBody["extensionVersion"];
          if (targetVersion == null) return;
          if (isNewVersionAvailable(extensionVersion, targetVersion)) {
            showNewBrowserExtensionVersion(context);
          }
          final success =
              await _handleDownloadAddition(jsonBody, context, request);
          await flushAndCloseResponse(request, success);
          responseClosed = true;
        } catch (e) {
          print("Error:: $e");
        } finally {
          if (!responseClosed) {
            await flushAndCloseResponse(request, false);
          }
        }
      }
    }
  }

  static void showNewBrowserExtensionVersion(BuildContext context) async {
    var lastNotify = HiveUtil.getSetting(
      SettingOptions.lastBrowserExtensionUpdateNotification,
    );
    if (lastNotify == null) {
      lastNotify = Setting(
        name: "lastBrowserExtensionUpdateNotification",
        value: "0",
        settingType: SettingType.system.name,
      );
      await HiveUtil.instance.settingBox.add(lastNotify);
    }
    if (int.parse(lastNotify.value) + 86400000 >
        DateTime.now().millisecondsSinceEpoch) {
      return;
    }
    final changeLog = await getLatestVersionChangeLog(
      browserExtension: true,
      removeChangeLogHeader: true,
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => UpdateAvailableDialog(
        isBrowserExtension: true,
        newVersion: extensionVersion,
        changeLog: changeLog,
        onUpdatePressed: () => launchUrlString(
          "https://github.com/AminBhst/brisk-browser-extension",
        ),
        onLaterPressed: () {
          lastNotify!.value = DateTime.now().millisecondsSinceEpoch.toString();
          lastNotify.save();
        },
      ),
    );
  }

  static Future<bool> _handleDownloadAddition(
      jsonBody, context, request) async {
    final type = jsonBody["type"] as String;
    switch (type.toLowerCase()) {
      case "single":
        return _handleSingleDownloadRequest(jsonBody, context, request);
      case "multi":
        _handleMultiDownloadRequest(jsonBody, context, request);
        return true;
      case "m3u8":
        _handleM3u8DownloadRequest(jsonBody, context, request);
        return true;
      default:
        return false;
    }
  }

  static void _handleM3u8DownloadRequest(jsonBody, context, request) async {
    bool canceled = false;
    showDialog(
      context: context,
      builder: (context) => FileInfoLoader(
        onCancelPressed: () {
          canceled = true;
          Navigator.of(context).pop();
        },
      ),
    );
    final url = jsonBody["m3u8Url"] as String;
    final refererHeader = jsonBody["refererHeader"] as String?;
    M3U8 m3u8;
    try {
      String m3u8Content = await fetchBodyString(
        url,
        proxySetting: SettingsCache.proxySetting,
        headers: refererHeader != null
            ? {
                HttpHeaders.refererHeader: refererHeader,
              }
            : {},
      );
      m3u8 = (await M3U8.fromString(
        m3u8Content,
        url,
        proxySetting: SettingsCache.proxySetting,
        refererHeader: refererHeader,
      ))!;
    } catch (e) {
      print(e);
      Navigator.of(context).pop();
      showDialog(
        context: context,
        builder: (_) => const ErrorDialog(
          textHeight: 0,
          height: 200,
          width: 380,
          title: "Failed to retrieve file info",
          description:
              "Something went wrong when trying to retrieve file information from this URL.",
          descriptionHint:
              "In some cases, retrying a few times may solve the issue. Otherwise, make sure the resource you're to reach is valid.",
        ),
      );
      return;
    }
    if (canceled) {
      return;
    }
    Navigator.of(context).pop();
    handleWindowToFront();
    if (m3u8.isMasterPlaylist) {
      _handleMasterPlaylist(m3u8, context);
      return;
    }
    DownloadAdditionUiUtil.handleM3u8Addition(m3u8, context);
  }

  static void _handleMasterPlaylist(M3U8 m3u8, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => M3u8MasterPlaylistDialog(m3u8: m3u8),
      barrierDismissible: false,
    );
  }

  static Future<void> flushAndCloseResponse(
    HttpRequest request,
    bool success,
  ) async {
    final body = jsonEncode({"captured": success});
    request.response.write(body);
    await request.response.close();
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
    requestFileInfoBatch(
      downloadItems.toList(),
      proxySetting: SettingsCache.proxySetting,
    ).then((fileInfos) {
      if (_cancelClicked) {
        return;
      }
      if (fileInfos == null || fileInfos.isEmpty) {
        return onFileInfoRetrievalError(context);
      }
      fileInfos.removeWhere(
        (fileInfo) => SettingsCache.extensionSkipCaptureRules.any(
          (rule) => rule.isSatisfiedByFileInfo(fileInfo),
        ),
      );
      handleWindowToFront();
      Navigator.of(context).pop();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => MultiDownloadAdditionDialog(fileInfos),
      );
    }).onError((error, stackTrace) => onFileInfoRetrievalError(context));
  }

  static void handleWindowToFront() {
    if (_windowToFrontEnabled) {
      windowManager.show().then((_) => WindowToFront.activate());
    }
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

  static Future<bool> _handleSingleDownloadRequest(
      jsonBody, context, request) async {
    final url = jsonBody['data']['url'];
    Completer<bool> completer = Completer();
    final downloadItem = DownloadItem.fromUrl(url);
    if (!isUrlValid(url)) {
      completer.complete(false);
    }
    final fileInfoResponse = DownloadAdditionUiUtil.requestFileInfo(url);
    fileInfoResponse.then((fileInfo) {
      final satisfied = SettingsCache.extensionSkipCaptureRules.any(
        (rule) => rule.isSatisfiedByFileInfo(fileInfo),
      );
      if (satisfied) {
        completer.complete(false);
        return;
      }
      handleWindowToFront();
      DownloadAdditionUiUtil.addDownload(
        downloadItem,
        fileInfo,
        context,
        false,
      );
      completer.complete(true);
    });
    return completer.future;
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
