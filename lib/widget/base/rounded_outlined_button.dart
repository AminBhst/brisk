import 'package:flutter/material.dart';

class RoundedOutlinedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color borderColor;
  final Color textColor;
  final String text;
  final Color backgroundColor;

  const RoundedOutlinedButton({
    Key? key,
    required this.onPressed,
    required this.borderColor,
    required this.textColor,
    required this.text,
    this.backgroundColor = Colors.black38,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: MaterialStatePropertyAll(backgroundColor),
        shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0))),
        side: MaterialStateProperty.all(BorderSide(
          color: borderColor,
        )),
      ),
      child: Text(
        text,
        style: TextStyle(color: textColor),
      ),
    );
  }
}
