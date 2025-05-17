import 'package:brisk/l10n/app_localizations.dart';
import 'package:brisk/provider/theme_provider.dart';
import 'package:brisk/widget/base/outlined_text_field.dart';
import 'package:brisk/widget/base/scrollable_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class FlatpakUpdateDialog extends StatelessWidget {
  FlatpakUpdateDialog({super.key});

  final txtController =
      TextEditingController(text: "flatpak update io.github.BrisklyDev.Brisk");

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).activeTheme;
    final loc = AppLocalizations.of(context)!;
    return ScrollableDialog(
      width: 450,
      height: 200,
      scrollviewHeight: 300,
      backgroundColor: theme.alertDialogTheme.backgroundColor,
      scrollButtonVisible: false,
      title: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            SvgPicture.asset(
              width: 30,
              height: 30,
              "assets/icons/flathub.svg",
              colorFilter: ColorFilter.mode(
                Colors.white70,
                BlendMode.srcIn,
              ),
            ),
            SizedBox(width: 10),
            Text(
              loc.flatpakUpdate,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
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
            Text(loc.flatpakUpdate_description),
            const SizedBox(height: 5),
            Text(
              loc.flatpakUpdate_hint,
              style: TextStyle(color: Colors.white60),
            ),
            const SizedBox(height: 10),
            OutLinedTextField(
              controller: txtController,
              readOnly: true,
              suffixIcon: IconButton(
                onPressed: () async {
                  Clipboard.setData(
                    ClipboardData(text: txtController.text),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Color.fromRGBO(38, 38, 38, 1.0),
                      content: Text(
                        loc.copiedToClipboard,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      ),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                icon: Icon(
                  Icons.copy_rounded,
                  color: Colors.white60,
                ),
              ),
            ),
          ],
        ),
      ),
      buttons: [],
    );
  }
}
