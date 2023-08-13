import 'package:flutter/material.dart';

class ErrorDialog extends StatelessWidget {
  final String text;
  final double width;
  final double height;
  final String? title;

  const ErrorDialog({
    super.key,
    this.text = '',
    this.width = 300,
    this.height = 30,
    this.title = null,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.all(10),
      backgroundColor: Colors.black,
      content: SizedBox(
        width: width,
        height: height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_rounded, color: Colors.red),
                const SizedBox(width: 10),
                if (title != null)
                  Text(
                    title!,
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
            Text(text, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
