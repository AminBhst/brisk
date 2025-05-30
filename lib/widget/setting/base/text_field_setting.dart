import 'package:brisk/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../base/outlined_text_field.dart';

class TextFieldSetting extends StatelessWidget {
  final String text;
  final TextInputType keyboardType;
  final List<TextInputFormatter> inputFormatters;
  final Widget? icon;
  final double width;
  final double? textWidth;
  final Function(String value)? onChanged;
  final TextEditingController txtController;
  bool obscureText;
  final Widget? suffixIcon;

  TextFieldSetting({
    super.key,
    required this.text,
    this.icon,
    this.width = 300,
    this.keyboardType = TextInputType.text,
    this.inputFormatters = const [],
    this.onChanged,
    this.textWidth,
    required this.txtController,
    this.obscureText = false,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme =
        Provider.of<ThemeProvider>(context).activeTheme.settingTheme.pageTheme;
    textWidth ?? MediaQuery.of(context).size.width * 0.6 * 0.5;
    return Row(
      children: [
        SizedBox(
          width: textWidth,
          child: Text(
            text,
            style: TextStyle(
              color: theme.titleTextColor,
              fontSize: 14,
            ),
          ),
        ),
        const Spacer(),
        const SizedBox(width: 10),
        SizedBox(
          width: width,
          height: 50,
          child: OutLinedTextField(
            inputFormatters: inputFormatters,
            obscureText: obscureText,
            controller: txtController,
            keyboardType: keyboardType,
            onChanged: onChanged,
            suffixIcon: suffixIcon,
          ),
        ),
        SizedBox(width: icon != null ? 10 : 0),
        icon != null ? icon! : Container(),
      ],
    );
  }
}
