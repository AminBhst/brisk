import 'package:flutter/material.dart';

class RoundedOutlinedButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Color borderColor;
  final Color textColor;
  final String text;
  final Color backgroundColor;
  final double? width;
  Color? hoverBackgroundColor;
  Color? hoverTextColor;
  final double borderRadius;

  RoundedOutlinedButton({
    Key? key,
    required this.onPressed,
    required this.borderColor,
    required this.textColor,
    required this.text,
    this.backgroundColor = Colors.black38,
    this.width,
    this.hoverBackgroundColor,
    this.hoverTextColor,
    this.borderRadius = 5.0,
  }) : super(key: key);

  @override
  State<RoundedOutlinedButton> createState() => _RoundedOutlinedButtonState();
}

class _RoundedOutlinedButtonState extends State<RoundedOutlinedButton> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      child: OutlinedButton(
        onPressed: widget.onPressed,
        onHover: (val) => setState(() => hover = val),
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(
            widget.hoverBackgroundColor == null
                ? (hover ? widget.borderColor : widget.backgroundColor)
                : (hover
                    ? widget.hoverBackgroundColor
                    : widget.backgroundColor),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
              widget.borderRadius,
            )),
          ),
          side: WidgetStateProperty.all(
            BorderSide(
              color: widget.borderColor,
            ),
          ),
        ),
        child: Text(
          widget.text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: widget.hoverTextColor == null
                ? (hover ? Colors.white : widget.textColor)
                : (hover ? widget.hoverTextColor : widget.textColor),
          ),
        ),
      ),
    );
  }
}
