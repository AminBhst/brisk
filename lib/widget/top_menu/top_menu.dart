import 'dart:io';

import 'package:brisk/constants/file_type.dart';
import 'package:brisk/download_engine/download_command.dart';
import 'package:brisk/db/hive_util.dart';
import 'package:brisk/download_engine/segment/segment.dart';
import 'package:brisk/download_engine/util/temp_file_util.dart';
import 'package:brisk/model/download_item.dart';
import 'package:brisk/model/file_metadata.dart';
import 'package:brisk/provider/theme_provider.dart';
import 'package:brisk/util/download_addition_ui_util.dart';
import 'package:brisk/util/settings_cache.dart';
import 'package:path/path.dart';
import 'package:brisk/download_engine/model/download_item_model.dart';
import 'package:brisk/provider/pluto_grid_util.dart';
import 'package:brisk/util/responsive_util.dart';
import 'package:brisk/widget/base/checkbox_confirmation_dialog.dart';
import 'package:brisk/widget/download/add_url_dialog.dart';
import 'package:brisk/widget/top_menu/top_menu_button.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/src/model/pluto_row.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../download_engine/client/mock_http_client_proxy.dart';
import '../../provider/download_request_provider.dart';
import '../../util/file_util.dart';
import '../queue/add_to_queue_window.dart';

class TopMenu extends StatefulWidget {
  @override
  State<TopMenu> createState() => _TopMenuState();
}

class _TopMenuState extends State<TopMenu> {
  String url = '';

  late DownloadRequestProvider provider;

  TextEditingController txtController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<DownloadRequestProvider>(context, listen: false);
    final topMenuTheme =
        Provider.of<ThemeProvider>(context).activeTheme.topMenuTheme;
    final size = MediaQuery.of(context).size;
    return Container(
      width: resolveWindowWidth(size),
      height: 70,
      color: topMenuTheme.backgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: TopMenuButton(
              onTap: () => showDialog(
                context: context,
                builder: (_) => AddUrlDialog(),
                barrierDismissible: false,
              ),
              title: 'Add URL',
              icon: Icon(
                Icons.add_rounded,
                color: topMenuTheme.addUrlColor.iconColor,
              ),
              onHoverColor: topMenuTheme.addUrlColor.hoverBackgroundColor,
              textColor: topMenuTheme.addUrlColor.textColor,
            ),
          ),
          // TopMenuButton(
          //
          //   /// TODO comment in production
          //   onTap: () => onMockDownloadPressed(context),
          //   title: 'Mock',
          //   icon: const Icon(Icons.not_started_outlined, color: Colors.red),
          //   onHoverColor: Colors.red,
          // ),
          // TopMenuButton(
          //   /// TODO comment in production
          //   onTap: () => onMockDownloadPressed(context),
          //   title: 'Mock',
          //   icon: const Icon(Icons.not_started_outlined, color: Colors.red),
          //   onHoverColor: Colors.red,
          // ),
          TopMenuButton(
            onTap: onDownloadPressed,
            title: 'Download',
            icon: Icon(
              Icons.download_rounded,
              color: topMenuTheme.downloadColor.iconColor,
            ),
            onHoverColor: topMenuTheme.downloadColor.hoverBackgroundColor,
            textColor: topMenuTheme.downloadColor.textColor,
          ),
          TopMenuButton(
            onTap: onStopPressed,
            title: 'Stop',
            icon: Icon(
              Icons.stop_rounded,
              color: topMenuTheme.stopColor.iconColor,
            ),
            onHoverColor: topMenuTheme.stopColor.hoverBackgroundColor,
            textColor: topMenuTheme.stopColor.textColor,
          ),
          TopMenuButton(
            onTap: onStopAllPressed,
            title: 'Stop All',
            icon: Icon(
              Icons.stop_circle_outlined,
              color: topMenuTheme.stopAllColor.iconColor,
            ),
            onHoverColor: topMenuTheme.stopAllColor.hoverBackgroundColor,
            textColor: topMenuTheme.stopAllColor.textColor,
          ),
          TopMenuButton(
            onTap: () => onRemovePressed(context),
            title: 'Remove',
            icon: Icon(
              Icons.delete,
              color: topMenuTheme.removeColor.iconColor,
            ),
            onHoverColor: topMenuTheme.removeColor.hoverBackgroundColor,
            textColor: topMenuTheme.removeColor.textColor,
          ),
          TopMenuButton(
            onTap: () => onAddToQueuePressed(context),
            title: 'Add To Queue',
            icon: Icon(
              Icons.queue,
              color: topMenuTheme.addToQueueColor.iconColor,
            ),
            fontSize: 10.5,
            onHoverColor: topMenuTheme.addToQueueColor.hoverBackgroundColor,
            textColor: topMenuTheme.addToQueueColor.textColor,
          ),
          SizedBox(width: 5),
          // Container(color: Colors.white, width: 1, height: 40),
          TopMenuButton(
            title: 'Get Extension',
            fontSize: 11,
            icon: Icon(
              Icons.extension,
              color: topMenuTheme.extensionColor.iconColor,
            ),
            onTap: () => launchUrlString(
              'https://github.com/AminBhst/brisk-browser-extension',
            ),
            onHoverColor: topMenuTheme.extensionColor.hoverBackgroundColor,
            textColor: topMenuTheme.extensionColor.textColor,
          ),
          SizedBox(width: 5),
          // Container(color: Colors.white, width: 1, height: 40),
          // TopMenuButton(
          //   title: 'Build',
          //   icon: Icon(
          //     Icons.extension,
          //     color: Colors.red,
          //   ),
          //   onTap: () {
          //     final dlitem = HiveUtil.instance.downloadItemsBox.getAt(0);
          //     final itemModel = DownloadItemModel.fromDownloadItem(dlitem!);
          //     FileUtil.doooo(itemModel.uid);
          //     assembleFile(
          //         itemModel, SettingsCache.temporaryDir, SettingsCache.saveDir);
          //     print("DONE");
          //   },
          // ),
        ],
      ),
    );
  }

  static bool assembleFile(DownloadItemModel downloadItem,
      Directory baseTempDir, Directory baseSaveDir) {
    ayo(downloadItem);
    final tempPath = join(baseTempDir.path, downloadItem.uid);
    final tempDir = Directory(tempPath);

    final tempFies = tempDir.listSync().map((o) => o as File).toList()
      ..sort(sortByByteRanges);

    File fileToWrite = File(downloadItem.filePath);
    if (fileToWrite.existsSync()) {
      final newFilePath = FileUtil.getFilePath(
        downloadItem.fileName,
        baseSaveDir: baseSaveDir,
        checkFileDuplicationOnly: true,
      );
      fileToWrite = File(newFilePath);
    }
    fileToWrite.createSync(recursive: true);
    print("Creating file...");
    for (var file in tempFies) {
      final bytes = file.readAsBytesSync();
      fileToWrite.writeAsBytesSync(bytes, mode: FileMode.writeOnlyAppend);
    }
    final assembleSuccessful =
        fileToWrite.lengthSync() == downloadItem.contentLength;
    print(
        "SUCCESS ????????????????????????? ${assembleSuccessful} ::::  ${fileToWrite.lengthSync()} SHOULD BE ${downloadItem.contentLength}");
    if (assembleSuccessful) {
      // _connectionIsolates[downloadItem.id]?.values.forEach((isolate) {
      //   isolate.kill();
      // });
      // tempDir.delete(recursive: true);
    }
    return assembleSuccessful;
  }

  static void ayo(DownloadItemModel downloadItem) {
    print("Validating temp files integrity...");
    final tempPath = join(
        Directory("C:\\Users\\RyeWell\\Downloads\\Brisk\\Temp").path,
        downloadItem.uid);
    final tempDir = Directory(tempPath);
    final tempFies = getTempFilesSorted(tempDir);
    for (int i = 0; i < tempFies.length; i++) {
      if (i == tempFies.length - 1) {
        return;
      }
      final file = tempFies[i];
      final nextFile = tempFies[i + 1];
      final startNext = getStartByteFromTempFile(nextFile);
      final end = getEndByteFromTempFile(file);
      final start = getStartByteFromTempFile(file);
      if (startNext - 1 != end) {
        print(
            "Found inconsistent temp file :: ${basename(file.path)} == ${basename(nextFile.path)}");
      }
      if (end - start + 1 != file.lengthSync()) {
        print("Found bad length ::: ${basename(file.path)}");
      }
      final badTemps = tempFies.where((f) => f != file).where((f) {
        final startF = getStartByteFromTempFile(f);
        final endF = getEndByteFromTempFile(f);
        final fSeg = Segment(startF, endF);
        final sseg = Segment(start, end);
        final overlaps = fSeg.overlapsWithOther(sseg);
        // isInRangeOfOther(Segment(start, end)) || Segment(startF, endF).overlapsWithOther(Segment(start, end));
        final overlappss = sseg.overlapsWithOther(fSeg);
        if (overlaps || overlappss) {
          print("OVERLAPS!!!!!");
          print("fSeg = $fSeg sseg = $sseg");
        }
        return false;
      }).toList();
      for (final t in badTemps) {
        print("Found bad temp!!");
      }
    }
  }

  void onMockDownloadPressed(BuildContext context) async {
    final item = DownloadItem.fromUrl(mockDownloadUrl);
    item.contentLength = 65945577;
    item.fileName = "Mozilla.Firefox.zip";
    item.fileType = DLFileType.compressed.name;
    item.supportsPause = true;
    final fileInfo = FileInfo(
      item.supportsPause,
      item.fileName,
      item.contentLength,
    );
    DownloadAdditionUiUtil.addDownload(item, fileInfo, context, false);
  }

  void onDownloadPressed() async {
    PlutoGridUtil.doOperationOnCheckedRows((id, _) {
      provider.executeDownloadCommand(id, DownloadCommand.start);
    });
  }

  void onStopPressed() {
    PlutoGridUtil.doOperationOnCheckedRows((id, _) {
      provider.executeDownloadCommand(id, DownloadCommand.pause);
    });
  }

  void onStopAllPressed() {
    provider.downloads.forEach((id, _) {
      provider.executeDownloadCommand(id, DownloadCommand.pause);
    });
  }

  void onAddToQueuePressed(BuildContext context) {
    if (PlutoGridUtil.plutoStateManager!.checkedRows.isEmpty) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AddToQueueWindow(),
    );
  }

  void onRemovePressed(BuildContext context) {
    final stateManager = PlutoGridUtil.plutoStateManager;
    if (stateManager!.checkedRows.isEmpty) return;
    showDialog(
      context: context,
      builder: (context) => CheckboxConfirmationDialog(
        onConfirmPressed: (deleteFile) {
          PlutoGridUtil.doOperationOnCheckedRows((id, row) {
            deleteOnCheckedRows(row, id, deleteFile);
          });
          stateManager.notifyListeners();
        },
        title: "Are you sure you want to delete the selected downloads?",
        checkBoxTitle: 'Delete downloaded file',
      ),
    );
  }

  void deleteOnCheckedRows(PlutoRow row, int id, bool deleteFile) {
    PlutoGridUtil.plutoStateManager!.removeRows([row]);
    FileUtil.deleteDownloadTempDirectory(id);
    provider.executeDownloadCommand(id, DownloadCommand.clearConnections);
    if (deleteFile) {
      final downloadItem = HiveUtil.instance.downloadItemsBox.get(id);
      final file = File(downloadItem!.filePath);
      if (file.existsSync()) {
        file.delete();
      }
    }
    HiveUtil.instance.downloadItemsBox.delete(id);
    HiveUtil.instance.removeDownloadFromQueues(id);
    provider.downloads.removeWhere((key, _) => key == id);
  }
}
