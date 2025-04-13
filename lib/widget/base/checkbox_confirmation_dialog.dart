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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      title: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: Color.fromRGBO(245, 158, 11, 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Align(
                alignment: const Alignment(0, -0.16),
                child: const Icon(
                  Icons.warning_rounded,
                  color: Color.fromRGBO(245, 158, 11, 1),
                  size: 35,
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          Text(
            "Confirm Action",
            style: TextStyle(
                color: theme.textColor,
                fontWeight: FontWeight.bold,
                fontSize: 20),
          ),
        ],
      ),
      content: Container(
        width: 450,
        height: 90,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  side: WidgetStateBorderSide.resolveWith(
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
        RoundedOutlinedButton.fromButtonColor(
          theme.deleteCancelColor,
          text: "Cancel",
          width: 80,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        RoundedOutlinedButton.fromButtonColor(
          theme.deleteConfirmColor,
          text: "Yes, Delete",
          width: 101,
          onPressed: () {
            Navigator.of(context).pop();
            widget.onConfirmPressed(checkBoxValue!);
          },
        ),
      ],
    );
  }
}
