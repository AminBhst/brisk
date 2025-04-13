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
    return AlertDialog(
      backgroundColor: theme.backgroundColor,
      title: Text(
        "Add Download To Queue",
        style: TextStyle(color: theme.textColor, fontWeight: FontWeight.bold, fontSize: 20),
      ),
      content: SizedBox(
        width: 400,
        height: 90,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Select Queue"),
            const SizedBox(height: 10),
            SizedBox(
              width: 400,
              child: DropdownButton<String>(
                value: selectedValue,
                menuMaxHeight: 200,
                menuWidth: 400,
                items: downloadQueues?.map((DownloadQueue value) {
                  return DropdownMenuItem<String>(
                    value: value.name,
                    child: SizedBox(
                      width: 376,
                      child: Text(value.name),
                    ),
                  );
                }).toList(),
                onChanged: (value) => setState(() => selectedValue = value),
              ),
            ),
          ],
        ),
      ),
      actions: [
        RoundedOutlinedButton(
          text: "Cancel",
          width: 80,
          borderColor: theme.cancelButtonColor.borderColor,
          textColor: theme.cancelButtonColor.textColor,
          backgroundColor: theme.cancelButtonColor.backgroundColor,
          hoverTextColor: theme.cancelButtonColor.hoverTextColor,
          onPressed: () => Navigator.of(context).pop(),
        ),
        RoundedOutlinedButton(
          text: "Add To Queue",
          width: 130,
          borderColor: theme.addButtonColor.borderColor,
          backgroundColor: theme.addButtonColor.backgroundColor,
          textColor: theme.addButtonColor.textColor,
          hoverTextColor: theme.addButtonColor.hoverTextColor,
          hoverBackgroundColor: theme.addButtonColor.hoverBackgroundColor,
          onPressed: onAddPressed,
        ),
      ],
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
