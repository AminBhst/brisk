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
    final size = MediaQuery.of(context).size;
    return SettingsGroup(
      title: "Download Connections",
      height: 170,
      children: [
        DropDownSetting(
          onChanged: (value) {
            if (value == null || value.isEmpty) return;
            setState(
              () => SettingsCache.connectionsNumber = int.parse(value),
            );
          },
          text: "Number of regular download connections",
          textWidth: size.width < 1683 ? size.width * 0.3 : 505,
          items: [1, 2, 4, 8, 16].map((e) => e.toString()).toList(),
          value: SettingsCache.connectionsNumber.toString(),
        ),
        DropDownSetting(
          onChanged: (value) {
            if (value == null || value.isEmpty) return;
            setState(
              () => SettingsCache.m3u8ConnectionNumber = int.parse(value),
            );
          },
          text: "Number of video stream download connections",
          textWidth: size.width < 1683 ? size.width * 0.3 : 505,
          items: [1, 2, 4, 8, 16].map((e) => e.toString()).toList(),
          value: SettingsCache.m3u8ConnectionNumber.toString(),
        ),
      ],
    );
  }
}
