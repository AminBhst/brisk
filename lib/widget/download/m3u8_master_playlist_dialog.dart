import 'package:brisk/constants/file_type.dart';
import 'package:brisk/provider/theme_provider.dart';
import 'package:brisk/theme/application_theme.dart';
import 'package:brisk/util/download_addition_ui_util.dart';
import 'package:brisk/util/file_util.dart';
import 'package:brisk/util/readability_util.dart';
import 'package:brisk/widget/base/default_tooltip.dart';
import 'package:brisk/widget/base/error_dialog.dart';
import 'package:brisk/widget/base/rounded_outlined_button.dart';
import 'package:brisk/widget/base/scrollable_dialog.dart';
import 'package:brisk_download_engine/brisk_download_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class M3u8MasterPlaylistDialog extends StatelessWidget {
  final M3U8 m3u8;

  const M3u8MasterPlaylistDialog({
    super.key,
    required this.m3u8,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).activeTheme;
    final size = MediaQuery.of(context).size;
    return ScrollableDialog(
      backgroundColor: theme.alertDialogTheme.backgroundColor,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              "Available Downloads",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          Container(
            width: 500,
            height: 1,
            color: Color.fromRGBO(65, 65, 65, 1.0),
          )
        ],
      ),
      content: Container(
        width: 500,
        height: 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            SizedBox(
              height: 260,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ...m3u8.streamInfos
                          .map((e) => masterPlaylistItem(e, context, theme))
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      scrollviewHeight: 300,
      scrollViewWidth: 500,
      width: 500,
      height: 300,
      scrollButtonVisible: false,
      buttons: [
        RoundedOutlinedButton(
          text: "Cancel",
          width: 80,
          onPressed: () => Navigator.of(context).pop(),
          backgroundColor: Color.fromRGBO(63, 19, 19, 0.5),
          hoverBackgroundColor: Color.fromRGBO(244, 67, 54, 0.6),
          borderColor: Colors.transparent,
          hoverTextColor: Colors.white,
          textColor: theme.downloadInfoDialogTheme.cancelColor.textColor,
        )
      ],
    );
  }

  Widget masterPlaylistItem(
    StreamInf streamInf,
    BuildContext context,
    ApplicationTheme theme,
  ) {
    final duration = streamInf.m3u8!.totalDuration;
    return Padding(
      padding: EdgeInsets.only(top: 10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: theme.alertDialogTheme.itemContainerBackgroundColor,
        ),
        height: 70,
        width: 500,
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Row(
            children: [
              // Left section: icon + text info
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    height: 40,
                    FileUtil.resolveFileTypeIconPath(
                      DLFileType.video.name,
                    ),
                    colorFilter: ColorFilter.mode(
                      FileUtil.resolveFileTypeIconColor(
                        DLFileType.video.name,
                      ),
                      BlendMode.srcIn,
                    ),
                  ),
                  SizedBox(width: 10), // spacing between icon and text
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 250,
                        child: Text(
                          streamInf.fileName,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      SizedBox(height: 5),
                      DefaultTooltip(
                        message: ""
                            "Title: ${streamInf.fileName}"
                            "\nResolution: ${streamInf.resolution}"
                            "\nFramerate: ${streamInf.frameRate}"
                            "\nDuration: ${durationSecondsToReadableStr(duration)}",
                        child: Row(
                          children: [
                            itemSubtitle(
                              value: durationSecondsToReadableStr(duration),
                              iconData: Icons.access_time,
                            ),
                            SizedBox(width: 10),
                            itemSubtitle(
                              value: streamInf.resolution ?? "Unknown",
                              iconData: Icons.monitor,
                            ),
                            SizedBox(width: 10),
                            itemSubtitle(
                              value: fpsToReadableStr(streamInf.frameRate) ??
                                  "Unknown",
                              iconData: Icons.monitor,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Spacer(),
              RoundedOutlinedButton(
                icon: Icon(
                  Icons.download,
                  color: Colors.white,
                  size: 18,
                ),
                text: "Download",
                width: 120,
                onPressed: () => _onDownloadPressed(streamInf, context),
                backgroundColor:
                    theme.downloadInfoDialogTheme.downloadColor.backgroundColor,
                borderColor:
                    theme.downloadInfoDialogTheme.downloadColor.borderColor,
                hoverBackgroundColor: theme
                    .downloadInfoDialogTheme.downloadColor.hoverBackgroundColor,
                hoverTextColor:
                    theme.downloadInfoDialogTheme.downloadColor.hoverTextColor,
                textColor:
                    theme.downloadInfoDialogTheme.downloadColor.textColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget itemSubtitle({required String value, required IconData iconData}) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            iconData,
            color: Colors.white70,
            size: 15,
          ),
          const SizedBox(width: 5),
          Text(
            value,
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _onDownloadPressed(StreamInf streamInf, BuildContext context) {
    if (streamInf.m3u8!.encryptionDetails.encryptionMethod ==
        M3U8EncryptionMethod.sampleAes) {
      showDialog(
        context: context,
        builder: (context) => ErrorDialog(
          textHeight: 20,
          text: "SAMPLE-AES encryption is not supported!",
        ),
      );
      return;
    }
    Navigator.of(context).pop();
    DownloadAdditionUiUtil.handleM3u8Addition(streamInf.m3u8!, context);
  }
}
