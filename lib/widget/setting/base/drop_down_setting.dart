import 'package:brisk/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DropDownSetting extends StatelessWidget {
  final List<String> items;
  final String text;
  final String value;
  final double? textWidth;
  final double? dropDownWidth;
  final double? dropDownItemTextWidth;
  final Function(String? value) onChanged;

  const DropDownSetting({
    super.key,
    required this.items,
    required this.text,
    required this.value,
    required this.onChanged,
    this.textWidth,
    this.dropDownWidth,
    this.dropDownItemTextWidth,
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
            style: TextStyle(color: theme.titleTextColor),
          ),
        ),
        const Spacer(),
        SizedBox(
          width: dropDownWidth,
          child: DropdownButton<String>(
            value: value,
            dropdownColor:
                theme.widgetColor.dropDownColor.dropDownBackgroundColor,
            items: items.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: SizedBox(
                  width: dropDownItemTextWidth,
                  child: Text(
                    value,
                    style: TextStyle(
                      color: theme.widgetColor.dropDownColor.ItemTextColor,
                    ),
                  ),
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        )
      ],
    );
  }
}
