import 'package:brisk/l10n/app_localizations.dart';
import 'package:brisk/provider/theme_provider.dart';
import 'package:brisk/widget/base/rounded_outlined_button.dart';
import 'package:brisk/widget/base/scrollable_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

class BrowserExtensionInstallationGuideDialog extends StatefulWidget {
  final String browserName;
  final String? downloadUrl;

  BrowserExtensionInstallationGuideDialog({
    super.key,
    required this.browserName,
    this.downloadUrl,
  });

  @override
  State<BrowserExtensionInstallationGuideDialog> createState() =>
      _BrowserExtensionInstallationGuideDialogState();
}

class _BrowserExtensionInstallationGuideDialogState
    extends State<BrowserExtensionInstallationGuideDialog> {
  bool videoGuide = false;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).activeTheme;
    final loc = AppLocalizations.of(context)!;
    return ScrollableDialog(
      width: 600,
      height: 380,
      buttons: [],
      scrollviewHeight: 300,
      backgroundColor: theme.alertDialogTheme.backgroundColor,
      scrollButtonVisible: false,
      title: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Text(
              loc.installBrowserExtensionGuide_title,
              style: TextStyle(
                color: theme.alertDialogTheme.textColor,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              splashRadius: 20,
              icon: Icon(
                Icons.close_rounded,
                color: Colors.white60,
              ),
            )
          ],
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            installationStep(
              step: 1,
              title: loc.downloadExtension,
              subtitles: [
                Text(
                  step1Subtitle(loc),
                  style: TextStyle(color: Colors.white60, fontSize: 15),
                ),
                const SizedBox(height: 5),
                RoundedOutlinedButton(
                  height: 30,
                  onPressed: () => launchUrlString(
                    widget.downloadUrl ??
                        "https://github.com/BrisklyDev/brisk-browser-extension/releases/tag/v1.2.2",
                  ),
                  text: loc.downloadExtension,
                  hoverBackgroundColor: Colors.blueAccent,
                  backgroundColor: Color.fromRGBO(53, 89, 143, 1),
                  icon: Icon(Icons.download, color: Colors.white70),
                ),
              ],
            ),
            installationStep(
              step: 2,
              title: loc.installBrowserExtension_step2_title,
              subtitles: [
                Text(
                  loc.installBrowserExtension_step2_subtitle,
                  style: TextStyle(color: Colors.white60, fontSize: 15),
                ),
              ],
            ),
            installationStep(
              step: 3,
              title: step3Title(loc),
              subtitles: [
                Text(
                  step3Subtitle(loc),
                  style: TextStyle(color: Colors.white60, fontSize: 15),
                ),
              ],
            ),
            installationStep(
              step: 4,
              title: step4Title(loc),
              subtitles: [
                Text(
                  step4Subtitle(loc),
                  style: TextStyle(color: Colors.white60, fontSize: 15),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  String step4Title(AppLocalizations loc) {
      return loc.installBrowserExtension_step4_title;
  }

  String step4Subtitle(AppLocalizations loc) {
    return loc.installBrowserExtension_step4_subtitle;
  }

  String step3Title(AppLocalizations loc) {
    return loc.installBrowserExtension_step3_title;
  }

  String step3Subtitle(AppLocalizations loc) {
    if (widget.browserName.toLowerCase() == "chrome") {
      return loc.installBrowserExtension_chrome_step3_subtitle;
    } else if (widget.browserName.toLowerCase() == "edge") {
      return loc.installBrowserExtension_edge_step3_subtitle;
    } else if (widget.browserName.toLowerCase() == "opera") {
      return loc.installBrowserExtension_opera_step3_subtitle;
    }
    return "";
  }

  String step1Subtitle(AppLocalizations loc) {
    if (widget.browserName.toLowerCase() == "chrome") {
      return loc.installBrowserExtension_chrome_step1_subtitle;
    } else if (widget.browserName.toLowerCase() == "edge") {
      return loc.installBrowserExtension_edge_step1_subtitle;
    } else if (widget.browserName.toLowerCase() == "opera") {
      return loc.installBrowserExtension_opera_step1_subtitle;
    }
    return "";
  }

  Widget installationStep({
    required int step,
    required String title,
    required List<Widget> subtitles,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 30,
          child: Center(child: stepCircle(step)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 5),
              ...subtitles,
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget stepCircle(int number) {
    return SizedBox(
      width: 25,
      height: 25,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: Color.fromRGBO(53, 89, 143, 1),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            number.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              height: 1, // helps center vertically
            ),
          ),
        ),
      ),
    );
  }
}
