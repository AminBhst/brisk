import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:brisk/db/hive_util.dart';
import 'package:brisk/model/download_item.dart';
import 'package:brisk/model/file_metadata.dart';
import 'package:brisk/model/isolate/isolate_args_pair.dart';
import 'package:brisk/util/download_addition_ui_util.dart';
import 'package:brisk/util/http_util.dart';
import 'package:brisk/util/parse_util.dart';
import 'package:brisk/widget/base/error_dialog.dart';
import 'package:brisk/widget/download/multi_download_addition_dialog.dart';
import 'package:brisk/widget/loader/file_info_loader.dart';
import 'package:flutter/material.dart';
import 'package:window_to_front/window_to_front.dart';

class BrowserExtensionServer {
  static bool _isServerRunning = false;
  static int _requestRateLimitMillis = 1000;

  static void setup(BuildContext context) async {
    if (_isServerRunning) return;

    final port = _extensionPort;
    try {
      _isServerRunning = true;
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
      handleExtensionRequests(server, context);
    } catch (e) {
      _showPortInUseError(context, port.toString());
    }
  }

  static int _latestRequestServed = 0;

  static Future<void> handleExtensionRequests(server, context) async {
    await for (final request in server) {
      await for (final body in request) {
        if (_tooManyRequestsReached) {
          await handleTooManyRequests(request);
          continue;
        }
        _latestRequestServed = DateTime.now().millisecondsSinceEpoch;
        final jsonBody = jsonDecode(String.fromCharCodes(body));
        if (_windowToFrontEnabled) {
          WindowToFront.activate();
        }
        await _handleDownloadAddition(jsonBody, context, request);
      }
    }
  }

  static Future<void> handleTooManyRequests(HttpRequest request) async {
    request.response.statusCode = HttpStatus.tooManyRequests;
    await request.response.flush();
    await request.response.close();
  }

  static get _tooManyRequestsReached =>
      _latestRequestServed + _requestRateLimitMillis >
      DateTime.now().millisecondsSinceEpoch;

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

  static void _handleMultiDownloadRequest(
      jsonBody, context, HttpRequest request) {
    List downloadHrefs = jsonBody["data"]["downloadHrefs"];
    if (downloadHrefs.isEmpty) return;
    final downloadItems = downloadHrefs.map((e) => DownloadItem.fromUrl(e));
    _showLoadingDialog(context);
    _spawnFileInfoRetrieverIsolate(downloadItems.toList()).then((rPort) {
      retrieveFilesInfo(rPort).then((fileInfos) {
        Navigator.of(context).pop();
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => MultiDownloadAdditionDialog(fileInfos),
        );
        _cancelRequest(context);
      }).onError(
        (e, ee) {
          _cancelRequest(context);
          showDialog(
            context: context,
            builder: (_) => const ErrorDialog(
              text: 'Could not retrieve file information!',
            ),
          );
        },
      );
    });
  }

  static void _showLoadingDialog(context) {
    showDialog(
      context: context,
      builder: (_) => FileInfoLoader(onCancelPressed: () {
        _cancelRequest(context);
        Navigator.of(context).pop();
      }),
    );
  }

  static Future<List<FileInfo>> retrieveFilesInfo(
      ReceivePort receivePort) async {
    final Completer<List<FileInfo>> completer = Completer();
    receivePort.listen((message) {
      if (message is List<FileInfo>) {
        completer.complete(message);
      } else {
        completer.completeError(message);
      }
    });
    return completer.future;
  }

  static void _cancelRequest(BuildContext context) {
    fileInfoExtractorIsolate?.kill(priority: 0);
  }

  static Isolate? fileInfoExtractorIsolate = null;

  static Future<ReceivePort> _spawnFileInfoRetrieverIsolate(
      List<DownloadItem> downloadItems) async {
    final ReceivePort receivePort = ReceivePort();
    fileInfoExtractorIsolate =
        await Isolate.spawn<IsolateArgsPair<List<DownloadItem>>>(
      requestFileInfoIsolate,
      IsolateArgsPair(receivePort.sendPort, downloadItems),
      paused: true,
    );
    fileInfoExtractorIsolate?.addErrorListener(receivePort.sendPort);
    fileInfoExtractorIsolate
        ?.resume(fileInfoExtractorIsolate!.pauseCapability!);
    return receivePort;
  }

  static Future<void> requestFileInfoIsolate(IsolateArgsPair args) async {
    final result = await requestFileInfoBatch(args.obj);
    args.sendPort.send(result);
  }

  static void _handleSingleDownloadRequest(jsonBody, context, request) async {
    DownloadAdditionUiUtil.handleDownloadAddition(
        context, jsonBody['data']['url']);
    addCORSHeaders(request);
    request.response.statusCode = HttpStatus.ok;
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
