import 'package:brisk/provider/theme_provider.dart';
import 'package:brisk/widget/base/rounded_outlined_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AskDuplicationAction extends StatelessWidget {
  final bool fileDuplication;
  final VoidCallback onSkipPressed;
  final VoidCallback onCreateNewPressed;
  final VoidCallback onUpdateUrlPressed;

  const AskDuplicationAction({
    super.key,
    required this.fileDuplication,
    required this.onSkipPressed,
    required this.onCreateNewPressed,
    required this.onUpdateUrlPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).activeTheme;
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      backgroundColor: theme.alertDialogTheme.backgroundColor,
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
            "Duplicate Download",
            style: TextStyle(
                color: theme.alertDialogTheme.textColor,
                fontWeight: FontWeight.bold,
                fontSize: 20),
          ),
        ],
      ),
      content: Container(
        width: 400,
        child: Text(
          "This download already exists!\nPlease choose an action.",
          style: const TextStyle(fontSize: 17),
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            RoundedOutlinedButton.fromButtonColor(
              theme.alertDialogTheme.cancelButtonColor,
              text: "Skip",
              width: 80,
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(width: 5),
            RoundedOutlinedButton.fromButtonColor(
              theme.downloadInfoDialogTheme.addToListColor,
              text: "Update URL",
              onPressed: onUpdateUrlPressed,
            ),
            const SizedBox(width: 5),
            RoundedOutlinedButton.fromButtonColor(
              theme.alertDialogTheme.addButtonColor,
              text: "Add New",
              onPressed: onCreateNewPressed,
            ),
          ],
        )
      ],
    );
  }
}
