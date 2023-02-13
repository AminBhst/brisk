import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OutLinedTextField extends StatelessWidget {
  final TextEditingController controller;
  final Color fillColor;
  final Color textColor;
  final bool readOnly;
  final Function(String value)? onChanged;
  final TextInputType keyboardType;
  final List<TextInputFormatter> inputFormatters;

  const OutLinedTextField({
    super.key,
    required this.controller,
    this.fillColor = Colors.black12,
    this.textColor = Colors.white,
    this.readOnly = false,
    this.keyboardType = TextInputType.text,
    this.inputFormatters = const [],
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
        readOnly: readOnly,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        cursorColor: Colors.white,
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(color: Colors.white, fontSize: 13),
        decoration: InputDecoration(
          focusColor: Colors.white38,
          fillColor: Colors.black12,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.blueGrey, width: 2.0),
            borderRadius: BorderRadius.circular(10.0),
          ),
          filled: true,
          iconColor: Colors.red,
        ));
  }
}
