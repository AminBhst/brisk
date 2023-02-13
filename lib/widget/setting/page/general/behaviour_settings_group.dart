import 'package:brisk/widget/setting/base/settings_group.dart';
import 'package:brisk/widget/setting/base/switch_setting.dart';
import 'package:flutter/material.dart';

import '../../../../util/settings_cache.dart';

class BehaviourSettingsGroup extends StatefulWidget {
  const BehaviourSettingsGroup({super.key});

  @override
  State<BehaviourSettingsGroup> createState() => _BehaviourSettingsGroupState();
}

class _BehaviourSettingsGroupState extends State<BehaviourSettingsGroup> {
  @override
  Widget build(BuildContext context) {
    return SettingsGroup(
      title: "Behaviour",
      children: [
        SwitchSetting(
          text: "Launch on startup",
          switchValue: SettingsCache.launchOnStartUp,
          // onChanged: (val) =>
          //     setState(() => SettingsCache.launchOnStartUp = val),
        ),
        SwitchSetting(
          text: "Minimize to tray on close",
          switchValue: SettingsCache.minimizeToTrayOnClose,
          // onChanged: (val) =>
          //     setState(() => SettingsCache.minimizeToTrayOnClose = val),
        ),
        SwitchSetting(
          text: "Open download progress window when a new download has started",
          switchValue: SettingsCache.openDownloadProgressWindow,
          onChanged: (val) =>
              setState(() => SettingsCache.openDownloadProgressWindow = val),
        )
      ],
    );
  }
}
