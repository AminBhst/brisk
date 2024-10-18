import 'package:brisk/widget/setting/base/settings_group.dart';
import 'package:brisk/widget/setting/base/switch_setting.dart';
import 'package:flutter/material.dart';

import '../../../../util/settings_cache.dart';

class NotificationSettingsGroup extends StatefulWidget {
  const NotificationSettingsGroup({super.key});

  @override
  State<NotificationSettingsGroup> createState() =>
      _NotificationSettingsGroupState();
}

class _NotificationSettingsGroupState extends State<NotificationSettingsGroup> {
  @override
  Widget build(BuildContext context) {
    return SettingsGroup(
      height: 170,
      title: "Notification",
      children: [
        SwitchSetting(
          text: "Notification on download completion",
          switchValue: SettingsCache.notificationOnDownloadCompletion,
          onChanged: (val) => setState(
              () => SettingsCache.notificationOnDownloadCompletion = val),
        ),
        SwitchSetting(
          text: "Notification on download failure",
          switchValue: SettingsCache.notificationOnDownloadFailure,
          onChanged: (val) =>
              setState(() => SettingsCache.notificationOnDownloadFailure = val),
        ),
      ],
    );
  }
}
