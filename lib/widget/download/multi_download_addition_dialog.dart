import 'package:brisk/download_engine/download_status.dart';
import 'package:brisk/db/hive_util.dart';
import 'package:brisk/model/download_item.dart';
import 'package:brisk/download_engine/model/download_item_model.dart';
import 'package:brisk/download_engine/message/download_progress_message.dart';
import 'package:brisk/model/file_metadata.dart';
import 'package:brisk/provider/theme_provider.dart';
import 'package:brisk/util/download_addition_ui_util.dart';
import 'package:brisk/util/readability_util.dart';
import 'package:brisk/widget/base/closable_window.dart';
import 'package:brisk/widget/base/rounded_outlined_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../provider/download_request_provider.dart';
import '../../util/file_util.dart';

class MultiDownloadAdditionDialog extends StatefulWidget {
  List<FileInfo> fileInfos = [];
  late DownloadRequestProvider provider;

  MultiDownloadAdditionDialog(this.fileInfos);

  @override
  State<MultiDownloadAdditionDialog> createState() =>
      _MultiDownloadAdditionDialogState();
}

class _MultiDownloadAdditionDialogState
    extends State<MultiDownloadAdditionDialog> {
  Widget build(BuildContext context) {
    widget.provider =
        Provider.of<DownloadRequestProvider>(context, listen: false);
    final theme =
        Provider.of<ThemeProvider>(context).activeTheme.alertDialogTheme;
    final size = MediaQuery.of(context).size;
    return ClosableWindow(
        disableCloseButton: true,
        height: 600,
        width: 700,
        backgroundColor: theme.backgroundColor,
        content: Container(
          height: resolveMainContainerHeight(size),
          width: 600,
          child: Column(
            children: [
              Container(
                width: 600,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Color.fromRGBO(220, 220, 220, 0.2)),
                ),
                height: resolveScrollViewHeight(size),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ...widget.fileInfos.map((e) => getListTileItem(e, size))
                    ],
                  ),
                ),
              ),
              Spacer(),
              Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RoundedOutlinedButton(
                      width: 100,
                      onPressed: () => Navigator.of(context).pop(),
                      borderColor: Colors.red,
                      text: "Cancel",
                      textColor: Colors.red,
                    ),
                    const SizedBox(width: 10),
                    RoundedOutlinedButton(
                      width: 100,
                      onPressed: onAddPressed,
                      borderColor: Colors.green,
                      text: "Add",
                      textColor: Colors.green,
                    ),
                  ])
            ],
          ),
        ));
  }

  void onAddPressed() async {
    final downloadItems =
        widget.fileInfos.map((e) => DownloadItem.fromFileInfo(e)).toList();

    await updateDuplicateUrls(downloadItems);
    for (final item in downloadItems.toSet()) {
      await HiveUtil.instance.addDownloadItem(item);
      widget.provider.insertRows([
        DownloadProgressMessage(
            downloadItem: DownloadItemModel.fromDownloadItem(item))
      ]);
    }
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> updateDuplicateUrls(List<DownloadItem> downloadItems) async {
    final duplicates = downloadItems.where(checkDownloadDuplication).toList();
    final uncompletedDownloads = HiveUtil.instance.downloadItemsBox.values
        .where((element) => element.status != DownloadStatus.assembleComplete);
    for (final download in uncompletedDownloads) {
      final fileNames = duplicates.map((e) => e.fileName).toList();
      if (fileNames.contains(download.fileName)) {
        download.downloadUrl = duplicates
            .where((dl) => dl.fileName == download.fileName)
            .first
            .downloadUrl;
        await download.save();
      }
    }
    downloadItems.removeWhere(checkDownloadDuplication);
  }

  bool checkDownloadDuplication(DownloadItem item) {
    return DownloadAdditionUiUtil.checkDownloadDuplication(item.fileName);
  }

  double resolveScrollViewHeight(Size size) {
    if (size.height < 390) {
      return 70;
    }
    if (size.height < 450) {
      return 160;
    }
    if (size.height < 500) {
      return 220;
    }
    if (size.height < 550) {
      return 250;
    }
    if (size.height < 600) {
      return 290;
    }
    if (size.height < 648) {
      return 340;
    }
    return 420;
  }

  double resolveMainContainerHeight(Size size) {
    if (size.height < 348) {
      return 110;
    }
    if (size.height < 390) {
      return 140;
    }
    if (size.height < 440) {
      return 220;
    }
    if (size.height < 470) {
      return 270;
    }
    if (size.height < 520) {
      return 300;
    }
    if (size.height < 570) {
      return 350;
    }
    if (size.height < 598) {
      return 400;
    }
    if (size.height < 648) {
      return 430;
    }
    if (size.height < 668) {
      return 480;
    }
    return 500;
  }

  double resolveListContainerWidth(Size size) {
    if (size.width > 700) {
      return 450;
    }
    return size.width * 0.5;
  }

  Widget getListTileItem(FileInfo fileInfo, Size size) {
    final fileType = FileUtil.detectFileType(fileInfo.fileName);
    return Container(
      width: 600,
      height: 70,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              child: SvgPicture.asset(
                FileUtil.resolveFileTypeIconPath(fileType.name),
                width: 35,
                height: 35,
                colorFilter: ColorFilter.mode(
                  FileUtil.resolveFileTypeIconColor(fileType.name),
                  BlendMode.srcIn,
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            SizedBox(
              width: resolveListContainerWidth(size),
              height: 45,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SizedBox(
                        width: resolveListContainerWidth(size),
                        child: Text(
                          fileInfo.fileName,
                          style: TextStyle(
                              color: Colors.white,
                              overflow: TextOverflow.ellipsis),
                        )),
                  ),
                  Text(convertByteToReadableStr(fileInfo.contentLength),
                      style: TextStyle(color: Colors.white, fontSize: 14)),
                ],
              ),
            ),
            const Spacer(),
            IconButton(
              icon: Icon(Icons.delete),
              color: Colors.red,
              onPressed: () {
                setState(() => widget.fileInfos.remove(fileInfo));
              },
            )
          ],
        ),
      ),
    );
  }
}
