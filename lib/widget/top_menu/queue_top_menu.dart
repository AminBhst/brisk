import 'dart:async';

import 'package:brisk/constants/download_command.dart';
import 'package:brisk/constants/download_status.dart';
import 'package:brisk/dao/download_item_dao.dart';
import 'package:brisk/db/hive_boxes.dart';
import 'package:brisk/model/download_queue.dart';
import 'package:brisk/provider/pluto_grid_state_manager_provider.dart';
import 'package:brisk/widget/base/closable_window.dart';
import 'package:brisk/widget/base/confirmation_dialog.dart';
import 'package:brisk/widget/download/add_url_dialog.dart';
import 'package:brisk/widget/queue/create_queue_window.dart';
import 'package:brisk/widget/top_menu/top_menu_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';

import '../../dao/download_queue_dao.dart';
import '../../provider/download_request_provider.dart';
import '../../util/file_util.dart';
import '../queue/add_to_queue_window.dart';
import '../queue/start_queue_window.dart';

class QueueTopMenu extends StatelessWidget {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Timer? timer;
  int simultaneousDownloads = 1;
  List<int> runningRequests = [];

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
              onTap: () => onStartQueuePressed(context),
              title: 'Start Queue',
              icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
              onHoverColor: Colors.green,
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
            onTap: () => onCreateQueuePressed(context),
            title: 'Create Queue',
            icon: const Icon(Icons.queue_outlined, color: Colors.white),
            fontSize: 11.5,
            onHoverColor: Colors.teal,
          ),
        ],
      ),
    );
  }

  void onDownloadPressed() {
    PlutoGridStateManagerProvider.doOperationOnCheckedRows((id, _) {
      provider.executeDownloadCommand(id, DownloadCommand.start);
    });
  }

  void onStopPressed() {
    PlutoGridStateManagerProvider.doOperationOnCheckedRows((id, _) {
      provider.executeDownloadCommand(id, DownloadCommand.pause);
    });
  }

  void onStopAllPressed() {
    provider.downloads.forEach((id, _) {
      provider.executeDownloadCommand(id, DownloadCommand.pause);
    });
  }

  void onCreateQueuePressed(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CreateQueueWindow(),
    );
  }

  void onAddToQueuePressed(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddToQueueWindow(),
    );
  }

  void runQueueTimer(int i) {
    simultaneousDownloads = i;
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      List<int> toRemove = [];
      runningRequests.forEach((request) {
        final download = provider.downloads[request];
        if (download != null &&
            download.status == DownloadStatus.assembleComplete) {
          toRemove.add(request);
        }
      });
      toRemove.forEach((id) => runningRequests.remove(id));
      final requestsToStart = simultaneousDownloads - runningRequests.length;
      for (int i = 0; i < requestsToStart; i++) {
        final row = fetchQueueRow();
        final id = row.cells['id']!.value;
        provider.executeDownloadCommand(id, DownloadCommand.start);
        runningRequests.add(id);
      }
    });
  }

  PlutoRow fetchQueueRow() {
    return PlutoGridStateManagerProvider.plutoStateManager!.rows
        .where((row) =>
            row.cells['status']!.value != DownloadStatus.assembleComplete &&
            !runningRequests.contains(row.cells['id']!.value))
        .toList()
        .first;
  }

  void onStartQueuePressed(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => StartQueueWindow(
        onStartPressed: (int i) {
          runQueueTimer(i);
        },
      ),
    );
  }

  void onRemovePressed(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
          onConfirmPressed: () {
            final stateManager =
                PlutoGridStateManagerProvider.plutoStateManager;
            PlutoGridStateManagerProvider.doOperationOnCheckedRows(
                (id, row) async {
              stateManager?.removeRows([row]);
              FileUtil.deleteDownloadTempDirectory(id);
              provider.executeDownloadCommand(
                  id, DownloadCommand.clearConnections);
              HiveBoxes.instance.downloadItemsBox.delete(id);
              provider.downloads.removeWhere((key, _) => key == id);
            });
            stateManager?.notifyListeners();
          },
          title: "Are you sure you want to delete the selected downloads?"),
    );
  }
}
