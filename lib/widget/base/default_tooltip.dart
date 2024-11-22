import 'package:flutter/material.dart';

class DefaultTooltip extends StatelessWidget {
  final String message;
  final Widget child;

  const DefaultTooltip({super.key, required this.message, required this.child});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      textStyle: TextStyle(color: Colors.white),
      decoration: BoxDecoration(
        color: Color.fromRGBO(33, 33, 33, 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }
}
