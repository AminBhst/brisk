import 'package:brisk/widget/setting/page/general/behaviour_settings_group.dart';
import 'package:brisk/widget/setting/page/general/logging_group.dart';
import 'package:brisk/widget/setting/page/general/notification_settings_group.dart';
import 'package:brisk/widget/setting/page/general/ui_setting_group.dart';
import 'package:flutter/material.dart';

import 'download_hotkey_settings_group.dart';

class GeneralSettingsPage extends StatelessWidget {
  const GeneralSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          NotificationSettingsGroup(),
          UISettingGroup(),
          DownloadHotkeySettingsGroup(),
          BehaviourSettingsGroup(),
          LoggingGroup(),
        ],
      ),
    );
  }
}
