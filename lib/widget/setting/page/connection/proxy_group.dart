import 'package:brisk/provider/theme_provider.dart';
import 'package:brisk/util/settings_cache.dart';
import 'package:brisk/widget/setting/base/settings_group.dart';
import 'package:brisk/widget/setting/base/switch_setting.dart';
import 'package:brisk/widget/setting/base/text_field_setting.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class ProxyGroup extends StatefulWidget {
  const ProxyGroup({super.key});

  @override
  State<ProxyGroup> createState() => _ProxyGroupState();
}

class _ProxyGroupState extends State<ProxyGroup> {
  TextEditingController addressController =
      TextEditingController(text: SettingsCache.proxyAddress);
  TextEditingController portController =
      TextEditingController(text: SettingsCache.proxyPort);
  TextEditingController usernameController =
      TextEditingController(text: SettingsCache.proxyUsername);
  TextEditingController passwordController =
      TextEditingController(text: SettingsCache.proxyPassword);

  @override
  Widget build(BuildContext context) {
    final theme =
        Provider.of<ThemeProvider>(context).activeTheme.settingTheme.pageTheme;
    final size = MediaQuery.of(context).size;
    return SettingsGroup(
      height: 350,
      title: "Proxy",
      children: [
        SwitchSetting(
          text: "Proxy Enabled",
          switchValue: SettingsCache.proxyEnabled,
          onChanged: (value) => setState(
            () => SettingsCache.proxyEnabled = value,
          ),
        ),
        const SizedBox(height: 10),
        TextFieldSetting(
          onChanged: (value) => setState(
            () => SettingsCache.proxyAddress = value,
          ),
          textWidth: size.width * 0.6 * 0.2,
          width: size.width * 0.6 * 0.3,
          text: "Proxy Address",
          txtController: addressController,
        ),
        const SizedBox(height: 10),
        TextFieldSetting(
          keyboardType: TextInputType.number,
          onChanged: (value) => setState(
            () => SettingsCache.proxyPort = value,
          ),
          textWidth: size.width * 0.6 * 0.2,
          width: size.width * 0.6 * 0.3,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^[0-9]*$')),
          ],
          text: "Proxy Port",
          txtController: portController,
        ),
        const SizedBox(height: 10),
        TextFieldSetting(
          onChanged: (value) => setState(
            () => SettingsCache.proxyUsername = value,
          ),
          textWidth: size.width * 0.6 * 0.2,
          width: size.width * 0.6 * 0.3,
          text: "Proxy Username",
          txtController: usernameController,
        ),
        const SizedBox(height: 10),
        TextFieldSetting(
          obscureText: true,
          onChanged: (value) => setState(
            () => SettingsCache.proxyPassword = value,
          ),
          textWidth: size.width * 0.6 * 0.2,
          width: size.width * 0.6 * 0.3,
          text: "Proxy Password",
          txtController: passwordController,
        )
      ],
    );
  }
}
