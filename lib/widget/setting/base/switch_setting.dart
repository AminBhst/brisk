import 'package:brisk/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SwitchSetting extends StatelessWidget {
  final String text;
  final bool switchValue;
  final Function(bool value)? onChanged;

  const SwitchSetting(
      {super.key,
      required this.text,
      this.onChanged,
      required this.switchValue});

  @override
  Widget build(BuildContext context) {
    final theme =
        Provider.of<ThemeProvider>(context).activeTheme.settingTheme.pageTheme;
    return Row(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.6 * 0.5,
          child: Text(
            text,
            style: TextStyle(
              overflow: TextOverflow.clip,
              color: theme.titleTextColor,
            ),
          ),
        ),
        const Spacer(),
        Switch(
          value: switchValue,
          onChanged: onChanged,
          hoverColor: theme.widgetColor.switchColor.hoverColor,
          activeColor: theme.widgetColor.switchColor.activeColor,
          focusColor: theme.widgetColor.switchColor.focusColor,
        ),
      ],
    );
  }
}
