import 'package:brisk/provider/pluto_grid_check_row_provider.dart';
import 'package:brisk/provider/queue_provider.dart';
import 'package:brisk/provider/theme_provider.dart';
import 'package:brisk/util/responsive_util.dart';
import 'package:brisk/widget/download/queue_schedule_handler.dart';
import 'package:brisk/widget/queue/schedule_dialog.dart';
import 'package:brisk/widget/top_menu/top_menu_button.dart';
import 'package:brisk/widget/top_menu/top_menu_util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:brisk/download_engine/download_command.dart';
import 'package:brisk/db/hive_util.dart';
import 'package:brisk/provider/download_request_provider.dart';
import 'package:brisk/provider/pluto_grid_util.dart';
import 'package:brisk/widget/base/delete_confirmation_dialog.dart';
import 'package:brisk/widget/queue/add_to_queue_window.dart';

/// TODO merge with top menu
class DownloadQueueTopMenu extends StatelessWidget {
  DownloadQueueTopMenu({Key? key}) : super(key: key);

  String url = '';
  late DownloadRequestProvider provider;

  TextEditingController txtController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<DownloadRequestProvider>(context, listen: false);
    Provider.of<PlutoGridCheckRowProvider>(context);
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
              onTap: () => onSchedulePressed(context),
              title: 'Schedule',
              fontSize: 12,
              icon: Icon(
                Icons.schedule_rounded,
                color: topMenuTheme.startQueueColor.iconColor,
              ),
              onHoverColor: topMenuTheme.startQueueColor.hoverBackgroundColor,
            ),
          ),
          TopMenuButton(
            onTap: onStopAllPressed,
            title: 'Stop Queue',
            fontSize: 12,
            icon: Icon(
              Icons.stop_circle_rounded,
              color: topMenuTheme.stopQueueColor.iconColor,
            ),
            onHoverColor: topMenuTheme.stopQueueColor.hoverBackgroundColor,
          ),
          TopMenuButton(
            onTap: isDownloadButtonEnabled(provider) ? onDownloadPressed : null,
            title: 'Download',
            icon: Icon(
              Icons.download_rounded,
              color: isDownloadButtonEnabled(provider)
                  ? topMenuTheme.downloadColor.iconColor
                  : Color.fromRGBO(79, 79, 79, 0.5),
            ),
            onHoverColor: topMenuTheme.downloadColor.hoverBackgroundColor,
            textColor: isDownloadButtonEnabled(provider)
                ? topMenuTheme.downloadColor.textColor
                : Color.fromRGBO(79, 79, 79, 1),
          ),
          TopMenuButton(
            onTap: isPauseButtonEnabled(provider) ? onStopPressed : null,
            title: 'Stop',
            icon: Icon(
              Icons.stop_rounded,
              color: isPauseButtonEnabled(provider)
                  ? topMenuTheme.stopColor.iconColor
                  : Color.fromRGBO(79, 79, 79, 0.5),
            ),
            onHoverColor: topMenuTheme.stopColor.hoverBackgroundColor,
            textColor: isPauseButtonEnabled(provider)
                ? topMenuTheme.stopColor.textColor
                : Color.fromRGBO(79, 79, 79, 1),
          ),
          TopMenuButton(
            onTap: () => onRemovePressed(context),
            title: 'Remove',
            icon: Icon(
              Icons.delete,
              color: topMenuTheme.removeColor.iconColor,
            ),
            onHoverColor: topMenuTheme.removeColor.hoverBackgroundColor,
          ),
        ],
      ),
    );
  }

  void onSchedulePressed(BuildContext context) async {
    final provider = Provider.of<QueueProvider>(context, listen: false);
    final queue =
        HiveUtil.instance.downloadQueueBox.get(provider.selectedQueueId)!;
    showDialog(
      context: context,
      builder: (context) => ScheduleDialog(
        queue: queue,
        onAcceptClicked: ({
          DateTime? scheduledEnd,
          DateTime? scheduledStart,
          required shutdownAfterCompletion,
          required simultaneousDownloads,
        }) {
          QueueScheduleHandler.schedule(
            queue,
            context,
            shutdownAfterCompletion: shutdownAfterCompletion,
            simultaneousDownloads: simultaneousDownloads,
            scheduledStart: scheduledStart,
            scheduledEnd: scheduledEnd,
          );
        },
      ),
      barrierDismissible: false,
    );
  }

  void onDownloadPressed() {
    PlutoGridUtil.doOperationOnCheckedRows((id, _) {
      provider.executeDownloadCommand(id, DownloadCommand.start);
    });
  }

  void onStopPressed() {
    PlutoGridUtil.doOperationOnCheckedRows((id, _) {
      QueueScheduleHandler.runningDownloads.forEach((queue, ids) {
        if (ids.contains(id)) ids.remove(id);
      });
      QueueScheduleHandler.stoppedDownloads.add(id);
      provider.executeDownloadCommand(id, DownloadCommand.pause);
    });
  }

  void onStopAllPressed() {
    QueueScheduleHandler.runningDownloads = {};
    QueueScheduleHandler.downloadCheckerTimer?.cancel();
    QueueScheduleHandler.downloadCheckerTimer = null;
    provider.downloads.forEach((id, _) {
      provider.executeDownloadCommand(id, DownloadCommand.pause);
      QueueScheduleHandler.stoppedDownloads.add(id);
    });
  }

  void onAddToQueuePressed(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddToQueueWindow(),
    );
  }

  void onRemovePressed(BuildContext context) {
    final queueProvider = Provider.of<QueueProvider>(context, listen: false);
    if (PlutoGridUtil.plutoStateManager!.checkedRows.isEmpty) return;
    showDialog(
      context: context,
      builder: (context) => DeleteConfirmationDialog(
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
