import 'dart:io';

import 'package:brisk/constants/download_command.dart';
import 'package:brisk/db/hive_boxes.dart';
import 'package:brisk/provider/pluto_grid_util.dart';
import 'package:brisk/widget/base/checkbox_confirmation_dialog.dart';
import 'package:brisk/widget/download/add_url_dialog.dart';
import 'package:brisk/widget/top_menu/top_menu_button.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/src/model/pluto_row.dart';
import 'package:provider/provider.dart';

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
    final size = MediaQuery.of(context).size;
    return Container(
      width: size.width * 0.80,
      height: 70,
      color: const Color.fromRGBO(46, 54, 67, 1),
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
              icon: const Icon(Icons.add_rounded, color: Colors.white),
            ),
          ),
          TopMenuButton(
            onTap: onDownloadPressed,
            title: 'Download',
            icon: const Icon(Icons.download_rounded, color: Colors.white),
            onHoverColor: Colors.green,
          ),
          TopMenuButton(
            onTap: onStopPressed,
            title: 'Stop',
            icon: const Icon(Icons.stop_rounded, color: Colors.white),
            onHoverColor: Colors.redAccent,
          ),
          TopMenuButton(
            onTap: onStopAllPressed,
            title: 'Stop All',
            icon: const Icon(Icons.stop_circle_outlined, color: Colors.white),
            onHoverColor: Colors.redAccent,
          ),
          TopMenuButton(
            onTap: () => onRemovePressed(context),
            title: 'Remove',
            icon: const Icon(Icons.delete, color: Colors.white),
            onHoverColor: Colors.red,
          ),
          TopMenuButton(
            onTap: () => onAddToQueuePressed(context),
            title: 'Add to queue',
            icon: const Icon(Icons.queue, color: Colors.white),
            fontSize: 11.5,
            onHoverColor: Colors.teal,
          ),
        ],
      ),
    );
  }

  void onDownloadPressed() {
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
      final downloadItem = HiveBoxes.instance.downloadItemsBox.get(id);
      final file = File(downloadItem!.filePath);
      if (file.existsSync()) {
        file.delete();
      }
    }
    HiveBoxes.instance.downloadItemsBox.delete(id);
    HiveBoxes.instance.removeDownloadFromQueues(id);
    provider.downloads.removeWhere((key, _) => key == id);
  }
}
