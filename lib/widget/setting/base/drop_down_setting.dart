import 'package:flutter/material.dart';

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
    textWidth ?? MediaQuery.of(context).size.width * 0.6 * 0.5;
    return Row(
      children: [
        SizedBox(
          width: textWidth,
          child: Text(
            text,
            style: const TextStyle(color: Colors.white),
          ),
        ),
        const Spacer(),
        SizedBox(
          width: dropDownWidth,
          child: DropdownButton<String>(
            value: value,
            dropdownColor: Colors.black87,
            items: items.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: SizedBox(
                    width: dropDownItemTextWidth,
                    child: Text(value,
                        style: const TextStyle(color: Colors.white))),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        )
      ],
    );
  }
}
