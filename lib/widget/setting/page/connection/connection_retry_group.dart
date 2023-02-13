import 'package:brisk/widget/setting/base/settings_group.dart';
import 'package:brisk/widget/setting/base/text_field_setting.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../util/settings_cache.dart';

class ConnectionRetryGroup extends StatefulWidget {
  const ConnectionRetryGroup({super.key});

  @override
  State<ConnectionRetryGroup> createState() => _ConnectionRetryGroupState();
}

class _ConnectionRetryGroupState extends State<ConnectionRetryGroup> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SettingsGroup(
      height: 200,
      title: "Connection Retry",
      children: [
        TextFieldSetting(
          onChanged: (value) => _onChanged(
            value,
            (parsedValue) => SettingsCache.connectionRetryCount = parsedValue,
          ),
          width: 50,
          textWidth: size.width * 0.6 * 0.32,
          icon: const Text("-1 = infinite", style: TextStyle(color: Colors.white),),
          text: "Max connection retry count",
          keyboardType: const TextInputType.numberWithOptions(
            signed: true,
            decimal: false,
          ),
          txtController: TextEditingController(text: SettingsCache.connectionRetryCount.toString()),
        ),
        const SizedBox(height: 10),
        TextFieldSetting(
          onChanged: (value) => _onChanged(
            value,
            (parsedValue) => SettingsCache.connectionRetryTimeout = parsedValue,
          ),
          width: 71,
          textWidth: size.width * 0.6 * 0.32,
          text: "Connection retry timeout",
          icon: const Text("seconds", style: TextStyle(color: Colors.white),),
          txtController: TextEditingController(text: SettingsCache.connectionRetryTimeout.toString()),
        )
      ],
    );
  }

  _onChanged(String value, Function(int parsedValue) setCache) {
    final numberValue = int.tryParse(value);
    if (numberValue == null) return;
    setState(() => setCache(numberValue));
  }
}
