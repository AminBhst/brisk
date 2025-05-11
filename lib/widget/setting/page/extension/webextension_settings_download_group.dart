import 'package:brisk/l10n/app_localizations.dart';
import 'package:brisk/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../base/settings_group.dart';

class WebExtensionSettingsDownloadGroup extends StatelessWidget {
  const WebExtensionSettingsDownloadGroup({super.key});

  @override
  Widget build(BuildContext context) {
    final textWidth = MediaQuery.of(context).size.width * 0.6 * 0.5;
    final theme =
        Provider.of<ThemeProvider>(context).activeTheme.settingTheme.pageTheme;
    final loc = AppLocalizations.of(context)!;
    return SettingsGroup(
      height: 130,
      title: loc.settings_downloadBrowserExtension,
      children: [
        Row(
          children: [
            SizedBox(
              width: textWidth,
              child: Text(
                loc.settings_downloadBrowserExtension_installExtension,
                style: TextStyle(color: theme.titleTextColor),
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () => launchUrl(
                Uri.parse(
                    'https://github.com/AminBhst/brisk-browser-extension'),
              ),
              icon: Icon(
                Icons.launch,
                color: theme.widgetColor.launchIconColor,
              ),
            )
          ],
        )
      ],
    );
  }
}
