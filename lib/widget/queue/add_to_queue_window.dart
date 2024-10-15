import 'package:brisk/db/hive_util.dart';
import 'package:brisk/provider/pluto_grid_util.dart';
import 'package:brisk/provider/theme_provider.dart';
import 'package:brisk/widget/base/closable_window.dart';
import 'package:brisk/widget/base/rounded_outlined_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../model/download_queue.dart';

class AddToQueueWindow extends StatefulWidget {
  const AddToQueueWindow({Key? key}) : super(key: key);

  @override
  State<AddToQueueWindow> createState() => _AddToQueueWindowState();
}

class _AddToQueueWindowState extends State<AddToQueueWindow> {
  List<DownloadQueue>? downloadQueues = [];
  String? selectedValue;

  @override
  Widget build(BuildContext context) {
    setDownloadQueues();
    final theme =
        Provider.of<ThemeProvider>(context).activeTheme.alertDialogTheme;
    return ClosableWindow(
      width: 300,
      height: 250,
      backgroundColor: theme.backgroundColor,
      disableCloseButton: true,
      padding: EdgeInsets.only(top: 50),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Select Queue : "),
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: DropdownButton<String>(
                  value: selectedValue,
                  menuMaxHeight: 200,
                  items: downloadQueues?.map((DownloadQueue value) {
                    return DropdownMenuItem<String>(
                      value: value.name,
                      child: SizedBox(
                        width: 100,
                        child: Text(value.name),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => selectedValue = value),
                ),
              )
            ],
          ),
          const SizedBox(height: 50),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              RoundedOutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                borderColor: theme.cancelButtonColor.borderColor,
                hoverTextColor: theme.cancelButtonColor.hoverTextColor,
                hoverBackgroundColor:
                    theme.cancelButtonColor.hoverBackgroundColor,
                textColor: theme.cancelButtonColor.textColor,
                text: "Cancel",
                width: 95,
              ),
              const SizedBox(width: 10),
              RoundedOutlinedButton(
                onPressed: onAddPressed,
                borderColor: theme.addButtonColor.borderColor,
                hoverTextColor: theme.addButtonColor.hoverTextColor,
                hoverBackgroundColor: theme.addButtonColor.hoverBackgroundColor,
                textColor: theme.addButtonColor.textColor,
                text: "Add",
                width: 95,
              ),
            ],
          )
        ],
      ),
      actions: [],
    );
  }

  void onAddPressed() async {
    final selectedQueue =
        downloadQueues?.where((queue) => queue.name == selectedValue).first;
    final selectedRows = PlutoGridUtil.plutoStateManager?.checkedRows;
    if (selectedQueue == null || selectedRows == null) return;
    final queue = HiveUtil.instance.downloadQueueBox.get(selectedQueue.key)!;
    for (var row in selectedRows) {
      final id = row.cells["id"]!.value;
      queue.downloadItemsIds ??= [];
      if (queue.downloadItemsIds!.any((item) => item == id)) continue;
      queue.downloadItemsIds = [...queue.downloadItemsIds!];
      queue.downloadItemsIds!.add(id);
      HiveUtil.instance.downloadQueueBox.put(queue.key, queue);
    }
    Navigator.of(context).pop();
  }

  void setDownloadQueues() {
    setState(() {
      downloadQueues = HiveUtil.instance.downloadQueueBox.values.toList();
    });
  }
}
