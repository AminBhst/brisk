import 'package:brisk/provider/theme_provider.dart';
import 'package:brisk/widget/base/rounded_outlined_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    final theme =
        Provider.of<ThemeProvider>(context).activeTheme.alertDialogTheme;
    return AlertDialog(
      surfaceTintColor: theme.backgroundColor,
      backgroundColor: theme.backgroundColor,
      content: Container(
        height: 100,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text(
                widget.title,
                style: const TextStyle(fontSize: 17),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Checkbox(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                  side: MaterialStateBorderSide.resolveWith(
                    (states) => BorderSide(
                      width: 1.0,
                      color: theme.checkBoxColor.borderColor,
                    ),
                  ),
                  activeColor: theme.checkBoxColor.activeColor,
                  value: checkBoxValue,
                  onChanged: (value) => setState(() => checkBoxValue = value),
                ),
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
