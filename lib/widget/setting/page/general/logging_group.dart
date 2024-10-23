import 'package:brisk/util/settings_cache.dart';
import 'package:brisk/widget/setting/base/settings_group.dart';
import 'package:brisk/widget/setting/base/switch_setting.dart';
import 'package:flutter/material.dart';

class LoggingGroup extends StatefulWidget {
  const LoggingGroup({super.key});

  @override
  State<LoggingGroup> createState() => _LoggingGroupState();
}

class _LoggingGroupState extends State<LoggingGroup> {
  @override
  Widget build(BuildContext context) {
    return SettingsGroup(
      height: 150,
      title: "Logger",
      children: [
        SwitchSetting(
          text: "Enable Engine Logger",
          switchValue: SettingsCache.loggerEnabled,
          onChanged: (val) =>
              setState(() => SettingsCache.loggerEnabled = val),
        ),
      ],
    );
  }
}
