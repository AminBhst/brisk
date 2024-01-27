import 'package:brisk/db/hive_util.dart';
import 'package:brisk/provider/queue_provider.dart';
import 'package:brisk/widget/base/closable_window.dart';
import 'package:brisk/widget/base/error_dialog.dart';
import 'package:brisk/widget/base/rounded_outlined_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/download_queue.dart';

class CreateQueueWindow extends StatefulWidget {
  const CreateQueueWindow({Key? key}) : super(key: key);

  @override
  State<CreateQueueWindow> createState() => _CreateQueueWindowState();
}

class _CreateQueueWindowState extends State<CreateQueueWindow> {
  TextEditingController txtController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ClosableWindow(
      width: 350,
      height: 250,
      disableCloseButton: true,
      padding: EdgeInsets.only(top: 60),
      content: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Queue name : "),
              const SizedBox(width: 10),
              SizedBox(
                  width: 150,
                  child: TextField(
                    maxLines: 1,
                    cursorColor: Colors.indigo,
                    controller: txtController,
                    decoration: const InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white))),
                    style: const TextStyle(color: Colors.white),
                  ))
            ],
          ),
          const SizedBox(height: 50),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              RoundedOutlinedButton(
                width: 95,
                onPressed: () => Navigator.of(context).pop(),
                borderColor: Colors.red,
                textColor: Colors.red,
                text: "Cancel",
              ),
              const SizedBox(width: 10),
              RoundedOutlinedButton(
                width: 95,
                onPressed: () => onCreatePressed(context),
                borderColor: Colors.green,
                textColor: Colors.green,
                text: "Save",
              ),
            ],
          )
        ],
      ),
      actions: [],
    );
  }

  void onCreatePressed(BuildContext context) async {
    final provider = Provider.of<QueueProvider>(context, listen: false);
    final box = HiveUtil.instance.downloadQueueBox;
    final duplicateQueueName = box.values
        .where((queue) => queue.name == txtController.value.text)
        .isNotEmpty;
    if (duplicateQueueName) {
      showDialog(
        context: context,
        builder: (context) => ErrorDialog(
          title: "Queue with this name already exists!",
          height: 50,
          width: 400,
        ),
      );
    } else {
      final queue = DownloadQueue(name: txtController.value.text);
      await provider.saveQueue(queue);
      Navigator.of(context).pop();
    }
  }
}
