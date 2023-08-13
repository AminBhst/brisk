import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../base/settings_group.dart';

class WebExtensionSettingsDownloadGroup extends StatelessWidget {
  const WebExtensionSettingsDownloadGroup({super.key});

  @override
  Widget build(BuildContext context) {
    final textWidth = MediaQuery.of(context).size.width * 0.6 * 0.5;
    return SettingsGroup(
      height: 200,
      title: "Download Brisk Browser Extension",
      children: [
        Row(
          children: [
            SizedBox(
              width: textWidth,
              child: Text(
                "Click the link to open browser extension download page",
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () => launchUrl(
                Uri.parse('https://github.com/AminBhst/brisk_webextension'),
              ),
              icon: Icon(
                Icons.launch,
                color: Colors.white,
              ),
            )
          ],
        )
      ],
    );
  }
}
