import 'package:brisk/db/hive_util.dart';
import 'package:brisk/widget/queue/queue_list_item.dart';
import 'package:flutter/material.dart';

class DownloadQueueList extends StatelessWidget {
  DownloadQueueList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Material(
      type: MaterialType.transparency,
      child: Container(
        height: size.height - 70,
        width: size.width * 0.8,
        color: Color.fromRGBO(40, 46, 58, 1),
        child: Column(
          children: buildQueues(context),
        ),
      ),
    );
  }

  List<Widget> buildQueues(BuildContext context) {
    return HiveUtil.instance.downloadQueueBox.values.map((e) {
      return QueueListItem(queue: e);
    }).toList();
  }
}
