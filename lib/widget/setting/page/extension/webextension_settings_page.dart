import 'package:brisk/l10n/app_localizations.dart';
import 'package:brisk/provider/theme_provider.dart';
import 'package:brisk/widget/setting/page/extension/browser_extension_rules_group.dart';
import 'package:brisk/widget/setting/page/extension/webextension_settings_download_group.dart';
import 'package:brisk/widget/setting/page/extension/webextension_settings_group.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WebExtensionSettingsPage extends StatelessWidget {
  const WebExtensionSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context)
        .activeTheme
        .settingTheme
        .pageTheme;
    final loc = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      child: SizedBox(
        height: 500,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PortSettingsGroup(),
            Center(
              child: Text(
                '* ${loc.changesRequireRestart}',
                style: TextStyle(color: theme.titleTextColor),
              ),
            ),
            const SizedBox(height: 10),
            BrowserExtensionRulesGroup(),
            WebExtensionSettingsDownloadGroup(),
          ],
        ),
      ),
    );
  }
}
