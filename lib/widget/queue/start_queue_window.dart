import 'package:brisk/widget/base/closable_window.dart';
import 'package:brisk/widget/base/rounded_outlined_button.dart';
import 'package:flutter/material.dart';
import 'package:number_inc_dec/number_inc_dec.dart';

class StartQueueWindow extends StatefulWidget {
  final Function(int i) onStartPressed;

  const StartQueueWindow({Key? key, required this.onStartPressed})
      : super(key: key);

  @override
  State<StartQueueWindow> createState() => _StartQueueWindowState();
}

class _StartQueueWindowState extends State<StartQueueWindow> {
  TextEditingController txtController = TextEditingController(text: "1");

  @override
  Widget build(BuildContext context) {
    return ClosableWindow(
      width: 530,
      height: 250,
      content: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Number of simultaneous downloads : ",
                  style: TextStyle(color: Colors.white)),
              const SizedBox(width: 10),
              SizedBox(
                width: 90,
                child: NumberInputWithIncrementDecrement(
                  initialValue: 1,
                  style: TextStyle(color: Colors.white),
                  decIconColor: Colors.white,
                  incDecBgColor: Colors.white,
                  incIconColor: Colors.white,
                  controller: txtController,
                  min: 1,
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
                width: 80,
                onPressed: () {},
                borderColor: Colors.red,
                textColor: Colors.red,
                text: "Cancel",
              ),
              const SizedBox(width: 10),
              RoundedOutlinedButton(
                width: 80,
                onPressed: () {
                  widget.onStartPressed(int.parse(txtController.text));
                  Navigator.of(context).pop();
                },
                borderColor: Colors.green,
                textColor: Colors.green,
                text: "Start",
              ),
            ],
          )
        ],
      ),
      actions: [],
    );
  }
}
