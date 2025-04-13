import 'package:brisk/provider/theme_provider.dart';
import 'package:brisk/widget/base/rounded_outlined_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConfirmationDialog extends StatelessWidget {
  final VoidCallback onConfirmPressed;
  final String title;

  const ConfirmationDialog({
    super.key,
    required this.onConfirmPressed,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme =
        Provider.of<ThemeProvider>(context).activeTheme.alertDialogTheme;
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      backgroundColor: theme.backgroundColor,
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
        width: 400,
        child: Text(
          title,
          style: const TextStyle(fontSize: 17),
        ),
      ),
      actions: [
        RoundedOutlinedButton(
          text: "Cancel",
          width: 80,
          borderColor: theme.deleteCancelColor.borderColor,
          hoverTextColor: theme.deleteCancelColor.hoverTextColor,
          hoverBackgroundColor: theme.deleteCancelColor.hoverBackgroundColor,
          backgroundColor: theme.deleteCancelColor.backgroundColor,
          textColor: theme.deleteCancelColor.textColor,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        RoundedOutlinedButton(
          text: "Yes, Delete",
          width: 101,
          borderColor: theme.deleteConfirmColor.borderColor,
          hoverTextColor: theme.deleteConfirmColor.hoverTextColor,
          backgroundColor: theme.deleteConfirmColor.backgroundColor,
          hoverBackgroundColor: theme.deleteConfirmColor.hoverBackgroundColor,
          textColor: theme.deleteConfirmColor.textColor,
          onPressed: () {
            Navigator.of(context).pop();
            onConfirmPressed();
          },
        ),
      ],
    );
  }
}
