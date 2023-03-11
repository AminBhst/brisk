import 'package:brisk/constants/download_command.dart';
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

class TopMenu extends StatelessWidget {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

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

  void onAddToQueuePressed(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddToQueueWindow(),
    );
  }

  void onRemovePressed(BuildContext context) {
    final stateManager =
        PlutoGridStateManagerProvider.plutoStateManager;
    if (stateManager!.checkedRows.isEmpty) return;
      showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
          onConfirmPressed: () {
            PlutoGridStateManagerProvider.doOperationOnCheckedRows((id, row) async {
              stateManager.removeRows([row]);
              FileUtil.deleteDownloadTempDirectory(id);
              provider.executeDownloadCommand(
                  id, DownloadCommand.clearConnections);
              HiveBoxes.instance.downloadItemsBox.delete(id);
              deleteDownloadFromQueues(id);
              provider.downloads.removeWhere((key, _) => key == id);
            });
            stateManager.notifyListeners();
          },
          title: "Are you sure you want to delete the selected downloads?"),
    );
  }

  void deleteDownloadFromQueues(int id) {
    final queuesContainingDownload = HiveBoxes.instance.downloadQueueBox.values
        .where((element) =>
            element.downloadItemsIds != null &&
            element.downloadItemsIds!.contains(id));
    for (final queue in queuesContainingDownload) {
      queue.downloadItemsIds?.remove(id);
      HiveBoxes.instance.downloadQueueBox.put(queue.key, queue);
    }
  }
}
