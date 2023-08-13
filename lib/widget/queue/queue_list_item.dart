import 'package:brisk/db/hive_util.dart';
import 'package:brisk/model/download_queue.dart';
import 'package:brisk/widget/base/confirmation_dialog.dart';
import 'package:brisk/widget/queue/queue_details_window.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/queue_provider.dart';

class QueueListItem extends StatelessWidget {
  QueueListItem({Key? key, required this.queue}) : super(key: key);
  DownloadQueue queue;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: ListTile(
        hoverColor: Colors.white12,
        onTap: () => onQueueTap(context),
        leading: Padding(
          padding: EdgeInsets.only(left: 10),
          child: Icon(
            Icons.queue_rounded,
            color: Colors.white38,
          ),
        ),
        title: Text(queue.name, style: TextStyle(color: Colors.white)),
        subtitle: Text(
          "${queue.downloadItemsIds == null ? 0 : queue.downloadItemsIds!.length} Downloads in queue",
          style: TextStyle(color: Colors.grey),
        ),
        trailing: SizedBox(
          width: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.more_vert_rounded, color: Colors.white),
                onPressed: () => onDetailsTap(context),
              ),
              queue.name == "Main"
                  ? SizedBox(width: 40)
                  : IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => onDeleteTap(context),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  void onDeleteTap(BuildContext context) {
    final provider = Provider.of<QueueProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
          onConfirmPressed: () async => await provider.deleteQueue(queue),
          title: "Are you sure you want to delete ${queue.name} queue?"),
    );
  }

  void onQueueTap(BuildContext context) {
    final provider = Provider.of<QueueProvider>(context, listen: false);
    provider.setQueueTopMenu(false);
    provider.setDownloadQueueTopMenu(true);
    provider.setQueueTabSelected(false);
    provider.setSelectedQueue(queue.key);
  }

  void onDetailsTap(BuildContext context) {
    queue = HiveUtil.instance.downloadQueueBox.get(queue.key)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => QueueDetailsWindow(queue: queue),
    );
  }
}
