import 'package:brisk/constants/file_type.dart';
import 'package:brisk/download_engine/model/m3u8.dart';
import 'package:brisk/provider/theme_provider.dart';
import 'package:brisk/util/download_addition_ui_util.dart';
import 'package:brisk/util/file_util.dart';
import 'package:brisk/util/readability_util.dart';
import 'package:brisk/widget/base/closable_window.dart';
import 'package:brisk/widget/base/default_tooltip.dart';
import 'package:brisk/widget/base/rounded_outlined_button.dart';
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
    final theme =
        Provider.of<ThemeProvider>(context).activeTheme.alertDialogTheme;
    final size = MediaQuery.of(context).size;
    return ClosableWindow(
        backgroundColor: theme.backgroundColor,
        padding: EdgeInsets.all(10),
        width: 500,
        height: 380,
        content: Container(
          width: 500,
          // height: 400,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              Container(
                height: resolveHeight(size),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.white38),
                    borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ...m3u8.streamInfos
                            .map((e) => masterPlaylistItem(e, context))
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ));
  }

  double resolveHeight(Size size) {
    final height = size.height;
    double result = 250;
    if (height < 455) {
      result = 200;
    }
    if (height < 403) {
      result = 150;
    }
    if (height < 356) {
      result = 100;
    }
    return result;
  }

  Widget masterPlaylistItem(StreamInf streamInf, BuildContext context) {
    final duration = streamInf.m3u8!.totalDuration;
    return Padding(
      padding: EdgeInsets.only(top: 10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white12),
        ),
        height: 80,
        width: 500,
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Column(
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
                          Text(
                            durationSecondsToReadableStr(
                              duration,
                              compactView: true,
                            ),
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 20),
                        child: SizedBox(
                          width: 250,
                          child: DefaultTooltip(
                            message: ""
                                "Title: ${streamInf.fileName}"
                                "\nResolution: ${streamInf.resolution}"
                                "\nFramerate: ${streamInf.frameRate}"
                                "\nDuration: ${durationSecondsToReadableStr(duration)}",
                            child: Text(
                              streamInf.fileName,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
              Spacer(),
              RoundedOutlinedButton(
                text: "Download",
                onPressed: () => _onDownloadPressed(streamInf, context),
                borderColor: Colors.green,
                textColor: Colors.green,
                borderRadius: 15,
              )
            ],
          ),
        ),
      ),
    );
  }

  void _onDownloadPressed(StreamInf streamInf, BuildContext context) {
    Navigator.of(context).pop();
    DownloadAdditionUiUtil.handleM3u8Addition(streamInf.m3u8!, context);
  }
}
