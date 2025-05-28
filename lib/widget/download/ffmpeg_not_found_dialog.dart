import 'package:brisk/db/hive_util.dart';
import 'package:brisk/provider/theme_provider.dart';
import 'package:brisk/util/ffmpeg.dart';
import 'package:brisk/widget/base/rounded_outlined_button.dart';
import 'package:brisk/widget/base/scrollable_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FFmpegNotFoundDialog extends StatelessWidget {
  const FFmpegNotFoundDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider
        .of<ThemeProvider>(context)
        .activeTheme;
    return ScrollableDialog(
      width: 550,
      height: 240,
      scrollviewHeight: 300,
      scrollButtonVisible: false,
      backgroundColor: theme.alertDialogTheme.backgroundColor,
      title: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: Color.fromRGBO(245, 158, 11, 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Align(
                  alignment: const Alignment(0, -0.16),
                  child: const Icon(
                    Icons.warning_rounded,
                    color: Color.fromRGBO(245, 158, 11, 1),
                    size: 35,
                  ),
                ),
              ),
            ),
            SizedBox(width: 10),
            Text(
              "FFmpeg Not Found!",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
                "Subtitles were found for this video stream, however, FFmpeg was not found on your system."
                    "\nFFmpeg is required to add the detected subtitles to the video file.\n"),
            Text(
              "You can:\n\t• Let Brisk handle the installation for you\n\t• Install FFmpeg via a package manager (choco, brew, pacman, etc.)\n\t• Download the binaries and add FFmpeg to your system’s PATH.\n\nYou can always set the FFmpeg's path in Settings -> General -> FFmpeg",
              style: TextStyle(color: Colors.white60),
            ),
          ],
        ),
      ),
      buttons: [
        RoundedOutlinedButton.fromButtonColor(
          theme.alertDialogTheme.cancelButtonColor,
          onPressed: () {
            final warningIgnore = HiveUtil.instance.generalDataBox.values
                .where(
                  (element) => element.fieldName == 'ffmpegWarningIgnore',
            )
                .first;
            warningIgnore.value = true;
            warningIgnore.save();
            Navigator.of(context).pop();
          },
          text: "I'll Install Later",
        ),
        const SizedBox(width: 10),
        RoundedOutlinedButton.fromButtonColor(
          theme.alertDialogTheme.addButtonColor,
          onPressed: () {
            Navigator.of(context).pop();
            FFmpeg.install(context);
          },
          text: "Install Automatically",
        ),
      ],
    );
  }
}
