import 'package:flutter/material.dart';

class NumberBadge extends StatelessWidget {
  final String number;
  final Color color;

  const NumberBadge({
    super.key,
    required this.number,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 20,
      decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          color: color),
      child: Center(
          child: Text(
        number,
        style: const TextStyle(color: Colors.white),
      )),
    );
  }
}
