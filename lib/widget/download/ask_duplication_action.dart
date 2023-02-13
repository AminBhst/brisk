import 'package:brisk/widget/base/rounded_outlined_button.dart';
import 'package:flutter/material.dart';

class AskDuplicationAction extends StatelessWidget {
  final bool fileDuplication;
  final VoidCallback onSkipPressed;
  final VoidCallback onCreateNewPressed;

  const AskDuplicationAction({
    super.key,
    required this.fileDuplication,
    required this.onSkipPressed,
    required this.onCreateNewPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.all(2),
      backgroundColor: const Color.fromRGBO(25, 25, 25, 1),
      icon: const Icon(Icons.warning_amber_rounded,color: Colors.red,),
      content: SizedBox(
        width: 300,
        height: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Download Already exists!",
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                RoundedOutlinedButton(
                  text: "Skip Download",
                  borderColor: Colors.red,
                  textColor: Colors.red,
                  onPressed: onSkipPressed,
                ),
                const SizedBox(width: 15),
                RoundedOutlinedButton(
                  text: "Create New File",
                  textColor: Colors.blueGrey,
                  borderColor: Colors.blueGrey,
                  onPressed: onCreateNewPressed,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
