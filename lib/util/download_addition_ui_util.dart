import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:brisk/constants/download_type.dart';
import 'package:brisk/constants/file_type.dart';
import 'package:brisk/download_engine/download_status.dart';
import 'package:brisk/download_engine/model/m3u8.dart';
import 'package:brisk/model/isolate/isolate_args.dart';
import 'package:brisk/setting/proxy/proxy_setting.dart';
import 'package:brisk/util/settings_cache.dart';
import 'package:brisk/widget/base/info_dialog.dart';
import 'package:brisk/widget/download/download_info_dialog.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:brisk/constants/file_duplication_behaviour.dart';
import 'package:brisk/db/hive_util.dart';
import 'package:brisk/model/download_item.dart';
import 'package:brisk/model/file_metadata.dart';
import 'package:brisk/provider/download_request_provider.dart';
import 'package:brisk/widget/base/error_dialog.dart';
import 'package:brisk/widget/download/ask_duplication_action.dart';
import 'file_util.dart';
import 'http_util.dart';

class DownloadAdditionUiUtil {
  static Isolate? fileInfoExtractorIsolate;

  static void cancelRequest(BuildContext context) {
    fileInfoExtractorIsolate?.kill();
    context.loaderOverlay.hide();
  }

  static Future<FileInfo> requestFileInfo(String url) async {
    final Completer<FileInfo> completer = Completer();
    var item = DownloadItem.fromUrl(url);
    _spawnFileInfoRetrieverIsolate(item).then((rPort) {
      retrieveFileInfo(rPort).then((fileInfo) {
        completer.complete(fileInfo);
      }).onError(
        (e, s) {
          _cancelRequest(null);
          completer.completeError("Failed to get file information");
        },
      );
    });
    return completer.future;
  }

  static void handleDownloadAddition(BuildContext context, String url,
      {bool updateDialog = false, int? downloadId, additionalPop = false}) {
    if (!isUrlValid(url)) {
      showDialog(
        context: context,
        builder: (_) => const ErrorDialog(
          width: 400,
          height: 205,
          textHeight: 15,
          title: 'Invalid URL',
          description:
              "The URL you've entered appears to be invalid.\nPlease check the format and try again.",
          descriptionHint: "Make sure the URL:\n"
              "\t • Starts with https:// or http://\n"
              "\t • Contains a valid domain name\n"
              "\t • Contains no invalid characters ",
        ),
      );
      return;
    }
    final item = DownloadItem.fromUrl(url);
    _spawnFileInfoRetrieverIsolate(item).then((rPort) {
      context.loaderOverlay.show();
      retrieveFileInfo(rPort).then((fileInfo) {
        fileInfo.url = url;
        context.loaderOverlay.hide();
        if (updateDialog) {
          handleUpdateDownloadUrl(fileInfo, context, downloadId!);
        } else {
          addDownload(item, fileInfo, context, additionalPop);
        }
      }).onError(
        (e, s) {
          /// TODO Add log files
          _cancelRequest(context);
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
        },
      );
    });
  }

  static void handleM3u8Addition(M3U8 m3u8, BuildContext context) {
    if (m3u8.encryptionDetails.encryptionMethod ==
        M3U8EncryptionMethod.SAMPLE_AES) {
      showDialog(
        context: context,
        builder: (context) => ErrorDialog(
          height: 100,
          width: 380,
          title: "Unsupported Encryption",
          description: "SAMPLE-AES encryption is not supported!",
        ),
      );
      return;
    }
    final fileName =
        m3u8.fileName.substring(0, m3u8.fileName.lastIndexOf(".")) + ".ts";
    final downloadItem = DownloadItem(
      uid: const Uuid().v4(),
      fileName: fileName,
      downloadUrl: m3u8.url,
      startDate: DateTime.now(),
      progress: 0,
      contentLength: -1,
      filePath: FileUtil.getFilePath(fileName),
      downloadType: DownloadType.M3U8.name,
      fileType: DLFileType.video.name,
      supportsPause: true,
      extraInfo: {
        "duration": m3u8.totalDuration,
        "m3u8Content": m3u8.stringContent,
        "refererHeader": m3u8.refererHeader,
      },
    );
    showDialog(
      context: context,
      builder: (context) => DownloadInfoDialog(
        downloadItem,
        isM3u8: true,
        newDownload: true,
      ),
      barrierDismissible: false,
    );
  }

  static void addDownload(
    DownloadItem item,
    FileInfo fileInfo,
    BuildContext context,
    bool additionalPop,
  ) {
    item
      ..supportsPause = fileInfo.supportsPause
      ..contentLength = fileInfo.contentLength
      ..fileName = fileInfo.fileName
      ..fileType = FileUtil.detectFileType(fileInfo.fileName).name;
    final dlDuplication = checkDownloadDuplication(item.fileName);
    if (dlDuplication) {
      final behaviour = SettingsCache.fileDuplicationBehaviour;
      switch (behaviour) {
        case FileDuplicationBehaviour.ask:
          showAskDuplicationActionDialog(
              context, item, additionalPop, fileInfo);
          break;
        case FileDuplicationBehaviour.skip:
          _skipDownload(context, additionalPop);
          break;
        case FileDuplicationBehaviour.add:
          showDownloadInfoDialog(context, item, additionalPop);
          break;
        case FileDuplicationBehaviour.updateUrl:
          _onUpdateUrlPressed(false, context, fileInfo,
              showUpdatedSnackbar: true);
          break;
      }
    } else {
      showDownloadInfoDialog(context, item, additionalPop);
    }
  }

  static void _skipDownload(BuildContext context, bool additionalPop) {
    if (additionalPop) {
      Navigator.of(context).pop();
    }
    _showSnackBar(context, "Download already exists!");
  }

  static void handleUpdateDownloadUrl(
      FileInfo fileInfo, BuildContext context, int downloadId) {
    final dl = HiveUtil.instance.downloadItemsBox.get(downloadId)!;
    if (dl.contentLength != fileInfo.contentLength) {
      showDialog(
        context: context,
        builder: (context) => const ErrorDialog(
          width: 400,
          height: 100,
          title: "URL Update Error",
          description: "The given URL does not refer to the same file!",
        ),
      );
    } else {
      updateUrl(context, fileInfo.url, dl, downloadId);
    }
  }

  static void updateUrl(
      BuildContext context, String url, DownloadItem dl, int downloadId) {
    final downloadProgress =
        Provider.of<DownloadRequestProvider>(context, listen: false)
            .downloads[downloadId];
    downloadProgress?.downloadItem.downloadUrl = url;
    dl.downloadUrl = url;
    HiveUtil.instance.downloadItemsBox.put(dl.key, dl);
    Navigator.of(context).pop();
    showDialog(
      context: context,
      builder: (context) => InfoDialog(
        titleText: "URL updated successfully!",
        titleIcon: Icon(Icons.done),
        titleIconBackgroundColor: Colors.lightGreen,
      ),
    );
  }

  static Future<ReceivePort> _spawnFileInfoRetrieverIsolate(
      DownloadItem item) async {
    final ReceivePort receivePort = ReceivePort();
    fileInfoExtractorIsolate =
        await Isolate.spawn<IsolateArgsPair<DownloadItem, ProxySetting>>(
      requestFileInfoIsolate,
      IsolateArgsPair(receivePort.sendPort, item, SettingsCache.proxySetting),
      paused: true,
    );
    fileInfoExtractorIsolate?.addErrorListener(receivePort.sendPort);
    fileInfoExtractorIsolate
        ?.resume(fileInfoExtractorIsolate!.pauseCapability!);
    return receivePort;
  }

  static void _cancelRequest(BuildContext? context) {
    fileInfoExtractorIsolate?.kill();
    if (context != null) {
      context.loaderOverlay.hide();
    }
  }

  static void showAskDuplicationActionDialog(BuildContext context,
      DownloadItem item, bool additionalPop, FileInfo fileInfo) {
    showDialog(
      context: context,
      builder: (context) => AskDuplicationAction(
        fileDuplication: false,
        onCreateNewPressed: () {
          Navigator.of(context).pop();
          showDownloadInfoDialog(context, item, additionalPop);
        },
        onSkipPressed: () => _onSkipPressed(context, additionalPop),
        onUpdateUrlPressed: () => _onUpdateUrlPressed(true, context, fileInfo),
      ),
      barrierDismissible: true,
    );
  }

  static void _onUpdateUrlPressed(bool pop, context, FileInfo fileInfo,
      {bool showUpdatedSnackbar = false}) async {
    if (pop) {
      Navigator.of(context).pop();
    }
    final downloadItem_boxValue = HiveUtil.instance.downloadItemsBox.values
        .where((item) =>
            item.fileName == fileInfo.fileName &&
            item.contentLength == fileInfo.contentLength &&
            item.status != DownloadStatus.assembleComplete)
        .first;
    downloadItem_boxValue.downloadUrl = fileInfo.url;
    await downloadItem_boxValue.save();
    if (!showUpdatedSnackbar) return;
    _showSnackBar(context, "Updated Download URL");
  }

  static void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      showCloseIcon: true,
      closeIconColor: Colors.white,
      content: Text(
        message,
        textAlign: TextAlign.center,
      ),
    ));
  }

  static void _onSkipPressed(BuildContext context, bool additionalPop) {
    if (additionalPop) {
      Navigator.of(context)
        ..pop()
        ..pop();
    } else {
      Navigator.of(context).pop();
    }
  }

  static void showDownloadInfoDialog(
      BuildContext context, DownloadItem item, bool additionalPop) {
    if (additionalPop) {
      Navigator.of(context).pop();
    }
    final rule = SettingsCache.fileSavePathRules.firstOrNullWhere(
      (rule) => rule.isSatisfiedByDownloadItem(item),
    );
    item.filePath = rule == null
        ? FileUtil.getFilePath(item.fileName)
        : FileUtil.getFilePath(
            item.fileName,
            baseSaveDir: Directory(rule.savePath),
            useTypeBasedSubDirs: false,
          );
    showDialog(
      context: context,
      builder: (_) => DownloadInfoDialog(item, newDownload: true),
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

  static bool checkDownloadDuplication(String fileName) {
    return HiveUtil.instance.downloadItemsBox.values
        .where((dl) => dl.fileName == fileName)
        .isNotEmpty;
  }
}

Future<void> requestFileInfoIsolate(IsolateArgsPair args) async {
  final result = await requestFileInfo(args.firstObject, args.secondObject);
  args.sendPort.send(result);
}
