import 'package:brisk/widget/setting/base/switch_setting.dart';
import 'package:flutter/material.dart';

import '../../../../util/settings_cache.dart';
import '../../base/settings_group.dart';
import '../../base/text_field_setting.dart';

class PortSettingsGroup extends StatefulWidget {
  const PortSettingsGroup({super.key});

  @override
  State<PortSettingsGroup> createState() => _WebExtensionSettingsGroupState();
}

class _WebExtensionSettingsGroupState extends State<PortSettingsGroup> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SettingsGroup(
      height: 175,
      title: "Browser Extension",
      children: [
        TextFieldSetting(
          onChanged: (value) => _onChanged(
            value,
            (parsedValue) => SettingsCache.extensionPort = parsedValue,
          ),
          width: 75,
          textWidth: size.width * 0.6 * 0.32,
          text: "Port",
          txtController: TextEditingController(
              text: SettingsCache.extensionPort.toString()),
        ),
        SwitchSetting(
          text: "Bring window to front on new download request",
          switchValue: SettingsCache.enableWindowToFront,
          onChanged: (val) =>
              setState(() => SettingsCache.enableWindowToFront = val),
        ),
      ],
    );
  }

  _onChanged(String value, Function(int parsedValue) setCache) {
    final numberValue = int.tryParse(value);
    if (numberValue == null) return;
    setState(() => setCache(numberValue));
  }
}
