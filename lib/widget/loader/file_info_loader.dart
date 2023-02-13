import 'package:brisk/widget/base/rounded_outlined_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class FileInfoLoader extends StatelessWidget {
  final VoidCallback onCancelPressed;

  const FileInfoLoader({super.key, required this.onCancelPressed});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color.fromRGBO(25, 25, 25, 1),
      content: SizedBox(
        width: 250,
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            Text(
              'Retrieving file information...',
              style: TextStyle(color: Colors.white, fontSize: 15),
            ),
            SizedBox(width: 10),
            SpinKitRing(color: Colors.blueAccent, size: 30)
          ],
        ),
      ),
      actions: [
        RoundedOutlinedButton(
          text: "Cancel",
          textColor: Colors.red,
          borderColor: Colors.red,
          onPressed: onCancelPressed,
        )
      ],
    );
  }
}
