import 'package:brisk/widget/base/rounded_outlined_button.dart';
import 'package:flutter/material.dart';

class CheckboxConfirmationDialog extends StatefulWidget {
  final Function(bool value) onConfirmPressed;
  final String title;
  final String checkBoxTitle;

  const CheckboxConfirmationDialog({
    Key? key,
    required this.onConfirmPressed,
    required this.title,
    required this.checkBoxTitle,
  }) : super(key: key);

  @override
  State<CheckboxConfirmationDialog> createState() =>
      _CheckedBoxedConfirmationDialogState();
}

class _CheckedBoxedConfirmationDialogState
    extends State<CheckboxConfirmationDialog> {
  bool? checkBoxValue = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color.fromRGBO(25, 25, 25, 1),
      content: Container(
        height: 75,
        color: const Color.fromRGBO(25, 25, 25, 1),
        child: Column(
          children: [
            Text(
              widget.title,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Checkbox(
                    activeColor: Colors.blueGrey,
                    value: checkBoxValue,
                    onChanged: (value) =>
                        setState(() => checkBoxValue = value)),
                Text(
                  widget.checkBoxTitle,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            )
          ],
        ),
      ),
      actions: [
        RoundedOutlinedButton(
          text: "No",
          textColor: Colors.red,
          borderColor: Colors.red,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        RoundedOutlinedButton(
          text: "Yes",
          textColor: Colors.green,
          borderColor: Colors.green,
          onPressed: () {
            Navigator.of(context).pop();
            widget.onConfirmPressed(checkBoxValue!);
          },
        ),
      ],
    );
  }
}
