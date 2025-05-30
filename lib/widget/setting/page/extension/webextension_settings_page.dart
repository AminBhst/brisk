import 'package:brisk/widget/setting/page/extension/browser_extension_rules_group.dart';
import 'package:brisk/widget/setting/page/extension/webextension_settings_download_group.dart';
import 'package:brisk/widget/setting/page/extension/webextension_settings_group.dart';
import 'package:flutter/material.dart';

class WebExtensionSettingsPage extends StatelessWidget {
  const WebExtensionSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SizedBox(
        height: 500,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PortSettingsGroup(),
            const SizedBox(height: 15),
            BrowserExtensionRulesGroup(),
            const SizedBox(height: 15),
            WebExtensionSettingsDownloadGroup(),
          ],
        ),
      ),
    );
  }
}
