import 'package:brisk/widget/base/rounded_outlined_button.dart';
import 'package:flutter/material.dart';

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
    return AlertDialog(
      backgroundColor: Color.fromRGBO(35, 39, 46, 1),
      content: Container(
        child: Text(
          title,
          style: const TextStyle(color: Colors.white),
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
            onConfirmPressed();
          },
        ),
      ],
    );
  }
}
