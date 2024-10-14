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
    final theme =
        Provider.of<ThemeProvider>(context).activeTheme.alertDialogTheme;
    return AlertDialog(
      insetPadding: const EdgeInsets.all(2),
      backgroundColor: theme.backgroundColor,
      icon:
          const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 40),
      content: SizedBox(
        width: 430,
        height: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Download already exists!",
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 50),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  RoundedOutlinedButton(
                    text: "Skip",
                    borderColor: Colors.redAccent,
                    textColor: Colors.white,
                    backgroundColor: Colors.redAccent,
                    onPressed: onSkipPressed,
                  ),
                  const SizedBox(width: 15),
                  RoundedOutlinedButton(
                    text: "Add New",
                    textColor: Colors.green,
                    borderColor: Colors.green,
                    onPressed: onCreateNewPressed,
                  ),
                  const SizedBox(width: 15),
                  RoundedOutlinedButton(
                    text: "Update URL",
                    textColor: Colors.blueGrey,
                    borderColor: Colors.blueGrey,
                    onPressed: onUpdateUrlPressed,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
