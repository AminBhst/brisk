import 'dart:async';
import 'dart:isolate';

import 'package:brisk/util/settings_cache.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';

import '../constants/file_duplication_behaviour.dart';
import '../db/hive_boxes.dart';
import '../model/download_item.dart';
import '../model/file_metadata.dart';
import '../model/isolate/isolate_args_pair.dart';
import '../provider/download_request_provider.dart';
import '../widget/base/confirmation_dialog.dart';
import '../widget/base/error_dialog.dart';
import '../widget/download/ask_duplication_action.dart';
import '../widget/download/download_info_dialog.dart';
import 'file_util.dart';
import 'http_util.dart';

class AddDownloadUiUtil {
  static Isolate? fileInfoExtractorIsolate;

  static void cancelRequest(BuildContext context) {
    fileInfoExtractorIsolate?.kill();
    context.loaderOverlay.hide();
  }

  static void handleDownloadAddition(BuildContext context, String url,
      {bool updateDialog = false, int? downloadId, additionalPop = false}) {
    if (!isUrlValid(url)) {
      showDialog(
        context: context,
        builder: (_) => const ErrorDialog(text: 'Invalid URL'),
      );
    } else {
      final item = DownloadItem.fromUrl(url);
      _spawnFileInfoRetrieverIsolate(item).then((rPort) {
        context.loaderOverlay.show();
        retrieveFileInfo(rPort).then((fileInfo) {
          context.loaderOverlay.hide();
          if (updateDialog) {
            handleUpdateDownloadUrl(fileInfo, context, url, downloadId!);
          } else {
            addDownload(item, fileInfo, context, additionalPop);
          }
        }).onError(
          (_, __) {
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
  }

  static void addDownload(DownloadItem item, FileInfo fileInfo,
      BuildContext context, bool additionalPop) {
    item.supportsPause = fileInfo.supportsPause;
    item.contentLength = fileInfo.contentLength;
    item.fileName = fileInfo.fileName;
    item.fileType = FileUtil.detectFileType(fileInfo.fileName).name;
    final fileExists = FileUtil.checkFileDuplication(item.fileName);
    final dlDuplication = checkDownloadDuplication(context, item.fileName);
    if (dlDuplication || fileExists) {
      final behaviour = SettingsCache.fileDuplicationBehaviour;
      if (behaviour == FileDuplicationBehaviour.ask) {
        showAskDuplicationActionDialog(
            context, fileExists, item, additionalPop);
      } else if (behaviour == FileDuplicationBehaviour.skip) {
        if (additionalPop) {
          Navigator.of(context).pop();
        }
        showDownloadExistsSnackBar(context);
      }
    } else {
      showDownloadInfoDialog(context, item, false, additionalPop);
    }
  }

  static void handleUpdateDownloadUrl(
      FileInfo fileInfo, BuildContext context, String url, int downloadId) {
    final dl = HiveBoxes.instance.downloadItemsBox.get(downloadId)!;
    if (dl.contentLength != fileInfo.contentLength) {
      showDialog(
          context: context,
          builder: (context) => const ErrorDialog(
                width: 400,
                text: "The given URL does not refer to the same file",
              ));
    } else {
      showDialog(
          context: context,
          builder: (context) => ConfirmationDialog(
                onConfirmPressed: () => updateUrl(context, url, dl, downloadId),
                title: "Are you sure you want to update the URL?",
              ));
    }
  }

  static void updateUrl(
      BuildContext context, String url, DownloadItem dl, int downloadId) {
    final downloadProgress =
        Provider.of<DownloadRequestProvider>(context, listen: false)
            .downloads[downloadId];
    downloadProgress?.downloadItem.downloadUrl = url;
    dl.downloadUrl = url;
    HiveBoxes.instance.downloadItemsBox.put(dl.key, dl);
    Navigator.of(context).pop();
  }

  static Future<ReceivePort> _spawnFileInfoRetrieverIsolate(
      DownloadItem item) async {
    final ReceivePort receivePort = ReceivePort();
    fileInfoExtractorIsolate =
        await Isolate.spawn<IsolateArgsPair<DownloadItem>>(
      requestFileInfoIsolate,
      IsolateArgsPair(receivePort.sendPort, item),
      paused: true,
    );
    fileInfoExtractorIsolate?.addErrorListener(receivePort.sendPort);
    fileInfoExtractorIsolate
        ?.resume(fileInfoExtractorIsolate!.pauseCapability!);
    return receivePort;
  }

  static void _cancelRequest(BuildContext context) {
    fileInfoExtractorIsolate?.kill();
    context.loaderOverlay.hide();
  }

  static void showAskDuplicationActionDialog(BuildContext context,
      bool fileExists, DownloadItem item, bool additionalPop) {
    showDialog(
      context: context,
      builder: (context) => AskDuplicationAction(
        fileDuplication: fileExists,
        onCreateNewPressed: () {
          Navigator.of(context).pop();
          showDownloadInfoDialog(context, item, fileExists, additionalPop);
        },
        onSkipPressed: () {
          if (additionalPop) {
            Navigator.of(context)
              ..pop()
              ..pop();
          } else {
            Navigator.of(context).pop();
          }
        },
      ),
      barrierDismissible: true,
    );
  }

  static void showDownloadExistsSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      showCloseIcon: true,
      closeIconColor: Colors.white,
      content: Text(
        "Download already exists!",
        textAlign: TextAlign.center,
      ),
    ));
  }

  static void showDownloadInfoDialog(BuildContext context, DownloadItem item,
      bool dlExists, bool additionalPop) {
    if (additionalPop) {
      Navigator.of(context).pop();
    }
    item.filePath = FileUtil.getFilePath(item.fileName);
    showDialog(
      context: context,
      builder: (_) => DownloadInfoDialog(item),
      barrierDismissible: false,
    );
  }

  static Future<FileInfo> retrieveFileInfo(ReceivePort receivePort) async {
    final Completer<FileInfo> completer = Completer();
    receivePort.listen((message) {
      if (message is FileInfo) {
        completer.complete(message);
      } else {
        completer.completeError(message);
      }
    });
    return completer.future;
  }

  static bool checkDownloadDuplication(BuildContext context, String fileName) {
    final provider =
        Provider.of<DownloadRequestProvider>(context, listen: false);
    return provider.downloads.values
        .where((dl) => dl.downloadItem.fileName == fileName)
        .isNotEmpty;
  }
}

Future<void> requestFileInfoIsolate(IsolateArgsPair args) async {
  final result = await requestFileInfo(args.obj);
  args.sendPort.send(result);
}
