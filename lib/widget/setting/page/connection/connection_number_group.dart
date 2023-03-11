import 'package:brisk/widget/setting/base/drop_down_setting.dart';
import 'package:brisk/widget/setting/base/settings_group.dart';
import 'package:flutter/material.dart';

import '../../../../util/settings_cache.dart';

class ConnectionNumberGroup extends StatefulWidget {
  const ConnectionNumberGroup({super.key});

  @override
  State<ConnectionNumberGroup> createState() => _ConnectionNumberGroupState();
}

class _ConnectionNumberGroupState extends State<ConnectionNumberGroup> {
  @override
  Widget build(BuildContext context) {
    return SettingsGroup(
      height: 150,
      children: [
        DropDownSetting(
          onChanged: _onChanged,
          text: "Number of download connections",
          items: [1, 2, 4, 8].map((e) => e.toString()).toList(),
          value: SettingsCache.connectionsNumber.toString(),
        ),
      ],
    );
  }

  void _onChanged(String? value) {
    if (value == null || value.isEmpty) return;
    setState(() => SettingsCache.connectionsNumber = int.parse(value));
  }
}
