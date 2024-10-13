import 'package:flutter/material.dart';

class ErrorDialog extends StatelessWidget {
  final String text;
  final double width;
  final double height;
  final String? title;
  final double textHeight;
  final double textSpaceBetween;

  const ErrorDialog({
    super.key,
    this.text = '',
    this.width = 300,
    this.height = 60,
    this.title = null,
    this.textHeight = 90,
    this.textSpaceBetween = 0,
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                    height: 25,
                    child:
                        const Icon(Icons.warning_rounded, color: Colors.red)),
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
            SizedBox(height: textSpaceBetween),
            SizedBox(
                height: textHeight,
                child: Text(text, style: const TextStyle(color: Colors.red))),
          ],
        ),
      ),
    );
  }
}
