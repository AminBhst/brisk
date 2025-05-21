import 'package:brisk/l10n/app_localizations.dart';
import 'package:brisk/provider/theme_provider.dart';
import 'package:brisk/widget/base/rounded_outlined_button.dart';
import 'package:brisk/widget/base/scrollable_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class UpdateAvailableDialog extends StatefulWidget {
  final String changeLog;
  final newVersion;
  final VoidCallback onUpdatePressed;
  bool isBrowserExtension;
  final VoidCallback? onLaterPressed;

  UpdateAvailableDialog({
    super.key,
    required this.changeLog,
    required this.newVersion,
    required this.onUpdatePressed,
    this.isBrowserExtension = false,
    this.onLaterPressed,
  });

  @override
  State<UpdateAvailableDialog> createState() => _UpdateAvailableDialogState();
}

class _UpdateAvailableDialogState extends State<UpdateAvailableDialog> {
  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final theme =
        Provider.of<ThemeProvider>(context, listen: false).activeTheme;
    final size = MediaQuery.of(context).size;
    final loc = AppLocalizations.of(context)!;
    return ScrollableDialog(
      height: 280,
      width: 400,
      scrollviewHeight: 200,
      scrollViewWidth: 400,
      scrollButtonVisible: size.height < 420,
      backgroundColor: theme.alertDialogTheme.backgroundColor,
      title: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: theme.alertDialogTheme.itemContainerBackgroundColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SvgPicture.asset(
                  width: 30,
                  height: 30,
                  "assets/icons/refresh.svg",
                  colorFilter: ColorFilter.mode(
                    Colors.white70,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.isBrowserExtension
                      ? loc.extensionUpdateAvailable
                      : loc.updateAvailable,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  widget.newVersion,
                  style: TextStyle(fontSize: 14, color: Colors.white60),
                ),
              ],
            ),
          ],
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.only(left: 15, right: 15),
        child: Container(
          height: 280,
          width: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.updateAvailable_description(
                  widget.isBrowserExtension
                      ? loc.settings_browserExtension
                      : loc.application,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: 400,
                height: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: theme.alertDialogTheme.itemContainerBackgroundColor,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      SizedBox(
                        child: Row(
                          children: [
                            Icon(Icons.info_rounded, color: Colors.white60),
                            const SizedBox(width: 5),
                            Text(
                              loc.whatsNew,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.white60),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 180,
                        width: 400,
                        child: Markdown(
                          data: EmojiParser().emojify(widget.changeLog),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      buttons: [
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              RoundedOutlinedButton.fromButtonColor(
                theme.downloadInfoDialogTheme.cancelColor,
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.onLaterPressed?.call();
                },
                text: loc.btn_later,
              ),
              const SizedBox(width: 10),
              RoundedOutlinedButton.fromButtonColor(
                theme.downloadInfoDialogTheme.downloadColor,
                onPressed: () => widget.onUpdatePressed(),
                text: loc.btn_update,
              ),
            ],
          ),
        )
      ],
    );
  }
}
