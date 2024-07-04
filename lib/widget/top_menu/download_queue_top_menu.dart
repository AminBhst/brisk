import 'dart:async';

import 'package:brisk/provider/queue_provider.dart';
import 'package:brisk/util/responsive_util.dart';
import 'package:brisk/widget/top_menu/top_menu_button.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';

import '../../download_engine/download_command.dart';
import '../../constants/download_status.dart';
import '../../db/hive_util.dart';
import '../../provider/download_request_provider.dart';
import '../../provider/pluto_grid_util.dart';
import '../base/confirmation_dialog.dart';
import '../queue/add_to_queue_window.dart';
import '../queue/start_queue_window.dart';

class DownloadQueueTopMenu extends StatelessWidget {
  DownloadQueueTopMenu({Key? key}) : super(key: key);
  Timer? timer;
  int simultaneousDownloads = 1;
  List<int> runningRequests = [];
  List<int> stoppedRequests = [];

  String url = '';
  late DownloadRequestProvider provider;

  TextEditingController txtController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<DownloadRequestProvider>(context, listen: false);
    final size = MediaQuery.of(context).size;
    return Container(
      width: resolveWindowWidth(size),
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
              fontSize: 12,
              icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
              onHoverColor: Colors.green,
            ),
          ),
          TopMenuButton(
            onTap: onStopAllPressed,
            title: 'Stop Queue',
            fontSize: 12,
            icon: const Icon(Icons.stop_circle_rounded, color: Colors.white),
            onHoverColor: Colors.redAccent,
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
            onTap: () => onRemovePressed(context),
            title: 'Remove',
            icon: const Icon(Icons.delete, color: Colors.white),
            onHoverColor: Colors.red,
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
      runningRequests.removeWhere((dlId) => dlId == id);
      stoppedRequests.add(id);
      provider.executeDownloadCommand(id, DownloadCommand.pause);
    });
  }

  void onStopAllPressed() {
    runningRequests = [];
    timer?.cancel();
    timer = null;
    provider.downloads.forEach((id, _) {
      provider.executeDownloadCommand(id, DownloadCommand.pause);
    });
  }

  void onAddToQueuePressed(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddToQueueWindow(),
    );
  }

  void runQueueTimer(int i) {
    if (timer != null) return;
    simultaneousDownloads = i;
    stoppedRequests = [];
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      List<int> toRemove = [];
      runningRequests.forEach((request) {
        final download = provider.downloads[request];
        if (download != null &&
            (download.status == DownloadStatus.assembleComplete ||
                download.status == DownloadStatus.assembleFailed)) {
          toRemove.add(request);
        }
      });
      toRemove.forEach((id) => runningRequests.remove(id));
      final requestsToStart = simultaneousDownloads - runningRequests.length;
      for (int i = 0; i < requestsToStart; i++) {
        final row = fetchNextQueueRow();
        final id = row.cells['id']!.value;
        provider.executeDownloadCommand(id, DownloadCommand.start);
        runningRequests.add(id);
      }
    });
  }

  PlutoRow fetchNextQueueRow() {
    return PlutoGridUtil.plutoStateManager!.rows
        .where((row) =>
            row.cells['status']!.value != DownloadStatus.assembleComplete &&
            !runningRequests.contains(row.cells['id']!.value) &&
            !stoppedRequests.contains(row.cells['id']!.value))
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
    final queueProvider = Provider.of<QueueProvider>(context, listen: false);
    if (PlutoGridUtil.plutoStateManager!.checkedRows.isEmpty) return;
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title:
            "Are you sure you want to remove the selected downloads from the queue?",
        onConfirmPressed: () async {
          final queue = HiveUtil.instance.downloadQueueBox
              .get(queueProvider.selectedQueueId)!;
          if (queue.downloadItemsIds == null) return;
          PlutoGridUtil.doOperationOnCheckedRows((id, row) async {
            queue.downloadItemsIds!.removeWhere((dlId) => dlId == id);
            PlutoGridUtil.plutoStateManager?.removeRows([row]);
          });
          await queue.save();
          PlutoGridUtil.plutoStateManager?.notifyListeners();
        },
      ),
    );
  }
}
