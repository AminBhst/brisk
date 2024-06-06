import 'package:brisk/widget/base/rounded_outlined_button.dart';
import 'package:flutter/material.dart';

class AppExitDialog extends StatefulWidget {
  final Function(bool) onExitPressed;
  final Function(bool) onMinimizeToTrayPressed;

  const AppExitDialog({
    super.key,
    required this.onExitPressed,
    required this.onMinimizeToTrayPressed,
  });

  @override
  State<AppExitDialog> createState() => _AppExitDialogState();
}

class _AppExitDialogState extends State<AppExitDialog> {
  bool rememberChecked = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Container(
        height: 80,
        width: 500,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "Choose an action",
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Checkbox(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                  side: MaterialStateBorderSide.resolveWith(
                    (states) => BorderSide(width: 1.0, color: Colors.grey),
                  ),
                  activeColor: Colors.blueGrey,
                  value: rememberChecked,
                  onChanged: (value) => setState(
                    () => rememberChecked = value!,
                  ),
                ),
                Text("Remember this decision"),
              ],
            )
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        RoundedOutlinedButton(
          text: "Cancel",
          textColor: Colors.red,
          borderColor: Colors.red,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        RoundedOutlinedButton(
          text: "Exit",
          textColor: Colors.redAccent,
          borderColor: Colors.redAccent,
          onPressed: () {
            Navigator.of(context).pop();
            widget.onExitPressed(rememberChecked);
          },
        ),
        RoundedOutlinedButton(
          text: "Minimize to tray",
          width: 155,
          textColor: Colors.teal,
          borderColor: Colors.teal,
          onPressed: () {
            Navigator.of(context).pop();
            widget.onMinimizeToTrayPressed(rememberChecked);
          },
        ),
      ],
    );
  }
}
