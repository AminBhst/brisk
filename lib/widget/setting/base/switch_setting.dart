import 'package:flutter/material.dart';

class SwitchSetting extends StatelessWidget {
  final String text;
  final bool switchValue;
  final Function(bool value)? onChanged;
  const SwitchSetting({super.key, required this.text, this.onChanged, required this.switchValue});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.6 * 0.5,
          child: Text(
            text,
            style: const TextStyle(overflow: TextOverflow.clip, color: Colors.white),
          ),
        ),
        const Spacer(),
        Switch(
          value: switchValue,
          onChanged: onChanged,
          activeColor: Colors.greenAccent,
        ),
      ],
    );
  }
}
