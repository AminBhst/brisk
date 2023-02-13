import 'package:brisk/constants/download_command.dart';
import 'package:brisk/dao/download_item_dao.dart';
import 'package:brisk/provider/pluto_grid_state_manager_provider.dart';
import 'package:brisk/widget/base/confirmation_dialog.dart';
import 'package:brisk/widget/download/add_url_dialog.dart';
import 'package:brisk/widget/top_menu/top_menu_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';

import '../../provider/download_request_provider.dart';
import '../../util/file_util.dart';

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
        ],
      ),
    );
  }

  void onDownloadPressed() {
    doOperationOnCheckedRows((id, _) {
      provider.executeDownloadCommand(id, DownloadCommand.start);
    });
  }

  void onStopPressed() {
    doOperationOnCheckedRows((id, _) {
      provider.executeDownloadCommand(id, DownloadCommand.pause);
    });
  }

  void onStopAllPressed() {
    provider.downloads.forEach((id, _) {
      provider.executeDownloadCommand(id, DownloadCommand.pause);
    });
  }

  void onRemovePressed(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
          onConfirmPressed: () {
            final stateManager =
                PlutoGridStateManagerProvider.plutoStateManager;
            doOperationOnCheckedRows((id, row) async {
              stateManager?.removeRows([row]);
              FileUtil.deleteDownloadTempDirectory(id);
              provider.executeDownloadCommand(
                  id, DownloadCommand.clearConnections);
              await DownloadItemDao.instance.deleteById(id);
              provider.downloads.removeWhere((key, _) => key == id);
            });
            stateManager?.notifyListeners();
          },
          title: "Are you sure you want to delete the selected downloads?"),
    );
  }

  void doOperationOnCheckedRows(Function(int id, PlutoRow row) operation) {
    final selectedRows =
        PlutoGridStateManagerProvider.plutoStateManager?.checkedRows;
    if (selectedRows == null) return;
    for (var row in selectedRows) {
      final id = row.cells["id"]!.value;
      operation(id, row);
    }
  }
}
