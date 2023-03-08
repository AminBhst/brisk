import 'dart:async';

import 'package:brisk/constants/file_duplication_behaviour.dart';
import 'package:brisk/dao/download_item_dao.dart';
import 'package:brisk/db/HiveBoxes.dart';
import 'package:brisk/model/download_item.dart';
import 'package:brisk/model/file_metadata.dart';
import 'package:brisk/model/isolate/isolate_args_pair.dart';
import 'package:brisk/provider/download_request_provider.dart';
import 'package:brisk/util/file_util.dart';
import 'package:brisk/util/http_util.dart';
import 'package:brisk/widget/base/confirmation_dialog.dart';
import 'package:brisk/widget/base/rounded_outlined_button.dart';
import 'package:brisk/widget/base/error_dialog.dart';
import 'package:brisk/widget/loader/file_info_loader.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'dart:isolate';

import 'package:provider/provider.dart';
import '../../util/settings_cache.dart';
import 'ask_duplication_action.dart';
import 'download_info_dialog.dart';

class AddUrlDialog extends StatefulWidget {
  final bool updateDialog;
  final int? downloadId;

  const AddUrlDialog({super.key, this.updateDialog = false, this.downloadId});

  @override
  State<AddUrlDialog> createState() => _AddUrlDialogState();
}

class _AddUrlDialogState extends State<AddUrlDialog> {
  TextEditingController txtController = TextEditingController();
  Isolate? fileInfoExtractorIsolate;

  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
      useDefaultLoading: false,
      overlayWidget: FileInfoLoader(
        onCancelPressed: () => _cancelRequest(context),
      ),
      child: AlertDialog(
        insetPadding: const EdgeInsets.all(10),
        backgroundColor: const Color.fromRGBO(25, 25, 25, 1),
        title: Text(
            widget.updateDialog ? "Update Download URL" : "Add a Download URL",
            style: const TextStyle(color: Colors.white)),
        content: SizedBox(
          width: 400,
          height: 100,
          child: Row(
            children: [
              SizedBox(
                  width: 340,
                  child: TextField(
                    maxLines: 1,
                    cursorColor: Colors.indigo,
                    controller: txtController,
                    decoration: const InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white))),
                    style: const TextStyle(color: Colors.white),
                  )),
              const SizedBox(width: 20),
              IconButton(
                icon: const Icon(Icons.paste_rounded, color: Colors.white),
                onPressed: () async {
                  String url = await FlutterClipboard.paste();
                  setState(() => txtController.text = url);
                },
              )
            ],
          ),
        ),
        actions: <Widget>[
          RoundedOutlinedButton(
            text: "Cancel",
            width: 80,
            borderColor: Colors.red,
            textColor: Colors.red,
            onPressed: () => _onCancelPressed(context),
          ),
          RoundedOutlinedButton(
            text: widget.updateDialog ? "Update" : "Add",
            width: 80,
            borderColor: Colors.green,
            textColor: Colors.green,
            onPressed: () => _onAddPressed(context),
          ),
        ],
      ),
    );
  }

  void _onCancelPressed(BuildContext context) {
    txtController.text = '';
    Navigator.of(context).pop();
  }

  void _onAddPressed(BuildContext context) {
    final url = txtController.text;
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
          if (widget.updateDialog) {
            handleUpdateDownloadUrl(fileInfo, context, url);
          } else {
            addDownload(item, fileInfo, context);
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

  void addDownload(DownloadItem item, FileInfo fileInfo, BuildContext context) {
    item.supportsPause = fileInfo.supportsPause;
    item.contentLength = fileInfo.contentLength;
    item.fileName = fileInfo.fileName;
    item.fileType = FileUtil.detectFileType(fileInfo.fileName).name;
    final fileExists = FileUtil.checkFileDuplication(item.fileName);
    final dlDuplication = checkDownloadDuplication(item.fileName);
    if (dlDuplication || fileExists) {
      final behaviour = SettingsCache.fileDuplicationBehaviour;
      if (behaviour == FileDuplicationBehaviour.ask) {
        showAskDuplicationActionDialog(fileExists, item);
      } else if (behaviour == FileDuplicationBehaviour.skip) {
        Navigator.of(context).pop();
        showDownloadExistsSnackBar();
      }
    } else {
      showDownloadInfoDialog(item, false);
    }
  }

  void handleUpdateDownloadUrl(
      FileInfo fileInfo, BuildContext context, String url) {
    final dl = HiveBoxes.instance.downloadItemsBox.get(widget.downloadId!)!;
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
                onConfirmPressed: () => updateUrl(context, url, dl),
                title: "Are you sure you want to update the URL?",
              ));
    }
  }

  void updateUrl(BuildContext context, String url, DownloadItem dl) {
    final downloadProgress =
        Provider.of<DownloadRequestProvider>(context, listen: false)
            .downloads[widget.downloadId];
    downloadProgress?.downloadItem.downloadUrl = url;
    dl.downloadUrl = url;
    HiveBoxes.instance.downloadItemsBox.put(dl.key, dl);
    Navigator.of(context).pop();
  }

  Future<ReceivePort> _spawnFileInfoRetrieverIsolate(DownloadItem item) async {
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

  void _cancelRequest(BuildContext context) {
    fileInfoExtractorIsolate?.kill();
    context.loaderOverlay.hide();
  }

  void showAskDuplicationActionDialog(bool fileExists, DownloadItem item) {
    showDialog(
      context: context,
      builder: (context) => AskDuplicationAction(
        fileDuplication: fileExists,
        onCreateNewPressed: () {
          Navigator.of(context).pop();
          showDownloadInfoDialog(item, fileExists);
        },
        onSkipPressed: doubleNavigationPop,
      ),
      barrierDismissible: true,
    );
  }

  void showDownloadExistsSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      showCloseIcon: true,
      closeIconColor: Colors.white,
      content: Text(
        "Download already exists!",
        textAlign: TextAlign.center,
      ),
    ));
  }

  void showDownloadInfoDialog(DownloadItem item, bool dlExists) {
    Navigator.of(context).pop();
    item.filePath = FileUtil.getFilePath(item.fileName);
    showDialog(
      context: context,
      builder: (_) => DownloadInfoDialog(item),
      barrierDismissible: false,
    );
  }

  void doubleNavigationPop() {
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  Future<FileInfo> retrieveFileInfo(ReceivePort receivePort) async {
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

  bool checkDownloadDuplication(String fileName) {
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
