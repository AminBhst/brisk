import 'package:brisk/db/hive_util.dart';
import 'package:brisk/model/download_queue.dart';
import 'package:brisk/provider/theme_provider.dart';
import 'package:brisk/widget/base/closable_window.dart';
import 'package:brisk/widget/base/rounded_outlined_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../provider/queue_provider.dart';
import '../../util/file_util.dart';

class QueueDetailsWindow extends StatefulWidget {
  final DownloadQueue queue;

  QueueDetailsWindow({Key? key, required this.queue}) : super(key: key);

  @override
  State<QueueDetailsWindow> createState() => _QueueDetailsWindowState();
}

class _QueueDetailsWindowState extends State<QueueDetailsWindow> {
  late List<int>? downloadIds = [];

  @override
  void initState() {
    downloadIds = [...?widget.queue.downloadItemsIds];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme =
        Provider.of<ThemeProvider>(context).activeTheme.alertDialogTheme;
    final size = MediaQuery.of(context).size;
    return AlertDialog(
      actionsPadding: EdgeInsets.all(0),
      contentPadding: EdgeInsets.all(0),
      titlePadding: EdgeInsets.all(0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(25),
            child: Text(
              "Edit Queue Items",
              style: TextStyle(
                  color: theme.textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
          ),
          Container(
            width: resolveDialogWidth(size),
            height: 1,
            color: Color.fromRGBO(65, 65, 65, 1.0),
          )
        ],
      ),
      backgroundColor: theme.backgroundColor,
      content: SizedBox(
        width: resolveDialogWidth(size),
        height: resolveListHeight(size),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              width: resolveDialogWidth(size),
              height: resolveRowHeight(size),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  downloadIds == null || downloadIds!.isEmpty
                      ? Container(
                          width: 300,
                          height: resolveListHeight(size),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                "assets/icons/blank.svg",
                                height: 90,
                                width: 90,
                                colorFilter: ColorFilter.mode(
                                  theme.placeHolderIconColor,
                                  BlendMode.srcIn,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "Queue Is Empty",
                                style: TextStyle(
                                  color: theme.placeHolderIconColor,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container(
                          width: resolveDialogWidth(size) - 20,
                          height: resolveListHeight(size),
                          child: ReorderableListView.builder(
                            buildDefaultDragHandles: false,
                            itemBuilder: (context, index) {
                              final dl = HiveUtil.instance.downloadItemsBox.get(
                                  HiveUtil.instance.downloadQueueBox
                                      .get(widget.queue.key)!
                                      .downloadItemsIds![index])!;
                              return Container(
                                key: ValueKey(dl.key),
                                margin: const EdgeInsets.symmetric(
                                  vertical: 4,
                                  horizontal: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.itemContainerBackgroundColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                  ),
                                  leading: SizedBox(
                                    width: 60,
                                    child: Row(
                                      children: [
                                        ReorderableDragStartListener(
                                          index: index,
                                          child: const Icon(
                                            Icons.drag_indicator_rounded,
                                            color: Colors.white70,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 30,
                                          height: 30,
                                          child: SvgPicture.asset(
                                            FileUtil.resolveFileTypeIconPath(
                                              dl.fileType,
                                            ),
                                            colorFilter: ColorFilter.mode(
                                              FileUtil.resolveFileTypeIconColor(
                                                dl.fileType,
                                              ),
                                              BlendMode.srcIn,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  title: Text(
                                    dl.fileName,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  trailing: SizedBox(
                                    width: 40,
                                    child: Material(
                                      color: Colors.transparent,
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.white54,
                                        ),
                                        splashRadius: 20,
                                        onPressed: () => onRemovePressed(index),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                            itemCount: itemCount,
                            onReorder: onReorder,
                          ),
                        ),
                ],
              ),
            ),
            // Container(
            //   width: resolveDialogWidth(size),
            //   height: 1,
            //   color: Color.fromRGBO(65, 65, 65, 1.0),
            // )
          ],
        ),
      ),
      actions: [
        Container(
          color: Colors.black12,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                RoundedOutlinedButton.fromButtonColor(
                  theme.cancelButtonColor,
                  onPressed: onCancelPressed,
                  width: 95,
                  text: "Cancel",
                ),
                const SizedBox(width: 10),
                RoundedOutlinedButton.fromButtonColor(
                  theme.addButtonColor,
                  onPressed: onSavePressed,
                  width: 120,
                  text: "Save Changes",
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  double resolveDialogWidth(Size size) {
    if (size.width < 430) {
      return 300;
    }
    if (size.width < 480) {
      return 350;
    }
    if (size.width < 580) {
      return 400;
    }
    return 500;
  }

  double resolveListHeight(Size size) {
    if (size.height < 300) {
      return 80;
    }
    if (size.height < 370) {
      return 130;
    }
    if (size.height < 420) {
      return 200;
    }
    if (size.height < 480) {
      return 270;
    }
    return 340;
  }

  double resolveButtonMargin(Size size) {
    double margin = 50;
    if (size.height < 600) {
      margin = 20;
    }
    if (size.height < 500) {
      margin = 0;
    }
    return margin;
  }

  double resolveRowHeight(Size size) {
    if (size.height < 300) {
      return 80;
    }
    if (size.height < 370) {
      return 130;
    }
    if (size.height < 420) {
      return 200;
    }
    if (size.height < 480) {
      return 250;
    }
    return 310;
  }

  void onSavePressed() async {
    await widget.queue.save();
    Provider.of<QueueProvider>(context, listen: false).notifyListeners();
    Navigator.of(context).pop();
  }

  void onCancelPressed() {
    widget.queue.downloadItemsIds = downloadIds;
    Navigator.of(context).pop();
  }

  int get itemCount => widget.queue.downloadItemsIds == null
      ? 0
      : widget.queue.downloadItemsIds!.length;

  void onReorder(int oldIndex, int newIndex) {
    final len = widget.queue.downloadItemsIds!.length;
    if (newIndex >= len) newIndex = len - 1;
    if (oldIndex >= len) oldIndex = len - 1;
    final id = widget.queue.downloadItemsIds!.removeAt(oldIndex);
    widget.queue.downloadItemsIds!.insert(newIndex, id);
  }

  void onRemovePressed(int index) =>
      setState(() => widget.queue.downloadItemsIds!.removeAt(index));
}
