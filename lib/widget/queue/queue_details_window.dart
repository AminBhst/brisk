import 'package:brisk/db/hive_boxes.dart';
import 'package:brisk/model/download_queue.dart';
import 'package:brisk/widget/base/closable_window.dart';
import 'package:brisk/widget/base/rounded_outlined_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../util/file_util.dart';

class QueueDetailsWindow extends StatefulWidget {
  const QueueDetailsWindow({Key? key}) : super(key: key);

  @override
  State<QueueDetailsWindow> createState() => _QueueDetailsWindowState();
}

class _QueueDetailsWindowState extends State<QueueDetailsWindow> {
  DownloadQueue queue = HiveBoxes.instance.downloadQueueBox.values.first;

  @override
  Widget build(BuildContext context) {
    return ClosableWindow(
      width: 800,
      height: 500,
      content: SizedBox(
        child: Column(
          children: [
            SizedBox(
              width: 600,
              height: 300,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 600,
                    height: 900,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.fromBorderSide(
                        BorderSide(color: Colors.white12),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: ReorderableListView.builder(
                        buildDefaultDragHandles: false,
                        itemBuilder: (context, index) {
                          final dl = HiveBoxes.instance.downloadItemsBox
                              .get(queue.downloadItemsIds![index])!;
                          return ListTile(
                            key: ValueKey(dl.key),
                            leading: SizedBox(
                              width: 25,
                              height: 25,
                              child: SvgPicture.asset(
                                FileUtil.resolveFileTypeIconPath(dl.fileType),
                                color: FileUtil.resolveFileTypeIconColor(
                                    dl.fileType),
                              ),
                            ),
                            title: Text(dl.fileName,
                                style: TextStyle(color: Colors.white)),
                            trailing: SizedBox(
                              width: 100,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => onRemovePressed(index),
                                  ),
                                  ReorderableDragStartListener(
                                    index: index,
                                    child: const Icon(Icons.drag_handle,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        itemCount: itemCount,
                        onReorder: onReorder,
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 50),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RoundedOutlinedButton(
                  onPressed: onCancelPressed,
                  borderColor: Colors.red,
                  textColor: Colors.red,
                  width: 80,
                  text: "Cancel",
                ),
                const SizedBox(width: 50),
                RoundedOutlinedButton(
                  onPressed: onSavePressed,
                  borderColor: Colors.green,
                  textColor: Colors.green,
                  width: 80,
                  text: "Save",
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  void onSavePressed() async {
    await queue.save();
    Navigator.of(context).pop();
  }

  void onCancelPressed() {
    queue = HiveBoxes.instance.downloadQueueBox.get(queue.key)!;
    Navigator.of(context).pop();
  }

  int get itemCount =>
      queue.downloadItemsIds == null ? 0 : queue.downloadItemsIds!.length;

  void onReorder(int oldIndex, int newIndex) {
    final len = queue.downloadItemsIds!.length;
    if (newIndex >= len) newIndex = len - 1;
    if (oldIndex >= len) oldIndex = len - 1;
    final id = queue.downloadItemsIds!.removeAt(oldIndex);
    queue.downloadItemsIds!.insert(newIndex, id);
  }

  void onRemovePressed(int index) =>
      setState(() => queue.downloadItemsIds!.removeAt(index));
}
