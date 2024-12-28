import 'package:brisk/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class OutLinedTextField extends StatelessWidget {
  final TextEditingController controller;
  final Color fillColor;
  final Color textColor;
  final bool readOnly;
  final Function(String value)? onChanged;
  final TextInputType keyboardType;
  final List<TextInputFormatter> inputFormatters;
  final bool obscureText;

  const OutLinedTextField({
    super.key,
    required this.controller,
    this.fillColor = Colors.black12,
    this.textColor = Colors.white,
    this.readOnly = false,
    this.keyboardType = TextInputType.text,
    this.inputFormatters = const [],
    this.onChanged,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context)
        .activeTheme
        .settingTheme
        .pageTheme
        .widgetColor
        .textFieldColor;
    return TextField(
        obscureText: obscureText,
        readOnly: readOnly,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        cursorColor: Colors.white,
        controller: controller,
        onChanged: onChanged,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr,
        style: TextStyle(color: theme.textColor, fontSize: 13),
        decoration: InputDecoration(
          focusColor: Colors.white38,
          fillColor: theme.fillColor,
          hoverColor: theme.hoverColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: theme.borderColor, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: theme.focusBorderColor, width: 2.0),
            borderRadius: BorderRadius.circular(10.0),
          ),
          filled: true,
          // iconColor: Colors.red,
        ));
  }
}
