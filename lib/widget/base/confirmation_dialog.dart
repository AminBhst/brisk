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
      backgroundColor: theme.backgroundColor,
      content: Container(
        child: Text(
          title,
          style: const TextStyle(fontSize: 17),
        ),
      ),
      actions: [
        RoundedOutlinedButton(
          text: "No",
          borderColor: theme.cancelButtonColor.borderColor,
          hoverTextColor: theme.cancelButtonColor.hoverTextColor,
          hoverBackgroundColor: theme.cancelButtonColor.hoverBackgroundColor,
          textColor: theme.cancelButtonColor.textColor,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        RoundedOutlinedButton(
          text: "Yes",
          borderColor: theme.addButtonColor.borderColor,
          hoverTextColor: theme.addButtonColor.hoverTextColor,
          hoverBackgroundColor: theme.addButtonColor.hoverBackgroundColor,
          textColor: theme.addButtonColor.textColor,
          onPressed: () {
            Navigator.of(context).pop();
            onConfirmPressed();
          },
        ),
      ],
    );
  }
}
