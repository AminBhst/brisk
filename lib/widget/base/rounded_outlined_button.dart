import 'package:brisk/theme/application_theme.dart';
import 'package:flutter/material.dart';

class RoundedOutlinedButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Color borderColor;
  final Color textColor;
  final String? text;
  final Color backgroundColor;
  final double? width;
  final double? height;
  Color? hoverBackgroundColor;
  Color? hoverTextColor;
  final double borderRadius;
  final Widget? icon;
  final MainAxisAlignment mainAxisAlignment;

  RoundedOutlinedButton({
    Key? key,
    required this.onPressed,
    required this.borderColor,
    required this.textColor,
    required this.text,
    this.backgroundColor = Colors.black38,
    this.width,
    this.height = 35,
    this.hoverBackgroundColor,
    this.hoverTextColor,
    this.borderRadius = 8.0,
    this.icon = null,
    this.mainAxisAlignment = MainAxisAlignment.center,
  }) : super(key: key);

  factory RoundedOutlinedButton.fromButtonColor(
    ButtonColor buttonColor, {
    Key? key,
    required VoidCallback? onPressed,
    required String text,
    double? width,
    double? height = 35,
    double borderRadius = 8.0,
    Widget? icon = null,
    mainAxisAlignment = MainAxisAlignment.center,
  }) {
    return RoundedOutlinedButton(
      text: text,
      width: width,
      height: height,
      borderColor: buttonColor.borderColor,
      hoverTextColor: buttonColor.hoverTextColor,
      backgroundColor: buttonColor.backgroundColor,
      hoverBackgroundColor: buttonColor.hoverBackgroundColor,
      textColor: buttonColor.textColor,
      onPressed: onPressed,
      icon: icon,
      mainAxisAlignment: mainAxisAlignment,
      borderRadius: borderRadius,
    );
  }

  @override
  State<RoundedOutlinedButton> createState() => _RoundedOutlinedButtonState();
}

class _RoundedOutlinedButtonState extends State<RoundedOutlinedButton> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
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
                borderRadius: BorderRadius.circular(widget.borderRadius)),
          ),
          side: WidgetStateProperty.all(
            BorderSide(
              color: widget.borderColor,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: widget.mainAxisAlignment,
          children: [
            if (widget.icon != null) widget.icon!,
            if (widget.icon != null && widget.text != null) SizedBox(width: 5),
            if (widget.text != null)
              Text(
                widget.text!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: widget.hoverTextColor == null
                      ? (hover ? Colors.white : widget.textColor)
                      : (hover ? widget.hoverTextColor : widget.textColor),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
