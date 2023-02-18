import 'package:flutter/material.dart';

class ErrorDialog extends StatelessWidget {
  final String text;
  final double width;

  const ErrorDialog({super.key, required this.text, this.width = 300});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.all(10),
      backgroundColor: Colors.black,
      content: SizedBox(
        width: width,
        height: 30,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.warning_rounded,color: Colors.red),
            const SizedBox(width: 10),
            Text(text,style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
