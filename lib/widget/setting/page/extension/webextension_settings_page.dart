import 'package:brisk/widget/setting/page/extension/webextension_settings_download_group.dart';
import 'package:brisk/widget/setting/page/extension/webextension_settings_group.dart';
import 'package:flutter/material.dart';

class WebExtensionSettingsPage extends StatelessWidget {
  const WebExtensionSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            PortSettingsGroup(),
            Text(
              '*Changes require a restart',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 10),
            WebExtensionSettingsDownloadGroup(),
          ],
        ),
      ),
    );
  }
}
