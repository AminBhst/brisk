import 'package:brisk/constants/download_type.dart';
import 'package:brisk/db/hive_util.dart';
import 'package:brisk/download_engine/model/download_item_model.dart';
import 'package:brisk/download_engine/message/download_progress_message.dart';
import 'package:brisk/download_engine/model/m3u8.dart';
import 'package:brisk/provider/download_request_provider.dart';
import 'package:brisk/provider/theme_provider.dart';
import 'package:brisk/util/file_util.dart';
import 'package:brisk/util/readability_util.dart';
import 'package:brisk/util/settings_cache.dart';
import 'package:brisk/widget/base/default_tooltip.dart';
import 'package:brisk/widget/base/outlined_text_field.dart';
import 'package:brisk/widget/base/rounded_outlined_button.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../download_engine/download_command.dart';
import '../../model/download_item.dart';
import 'download_progress_window.dart';

class DownloadInfoDialog extends StatefulWidget {
  final DownloadItem downloadItem;
  final bool showActionButtons;
  final bool showFileActionButtons;
  final bool showSupportsPause;

  const DownloadInfoDialog(
    this.downloadItem, {
    super.key,
    this.showActionButtons = true,
    this.showFileActionButtons = false,
    this.showSupportsPause = false,
  });

  @override
  State<DownloadInfoDialog> createState() => _DownloadInfoDialogState();
}

class _DownloadInfoDialogState extends State<DownloadInfoDialog>
    with SingleTickerProviderStateMixin {
  late TextEditingController txtController;
  late DownloadRequestProvider provider;
  late AnimationController controller;
  late Animation<double> scaleAnimation;

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 150),
    );
    scaleAnimation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    );
    txtController = TextEditingController(text: widget.downloadItem.filePath);
    controller.addListener(() => setState(() {}));
    controller.forward();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<DownloadRequestProvider>(context, listen: false);
    final theme = Provider.of<ThemeProvider>(context).activeTheme;
    final size = MediaQuery.of(context).size;
    final alertDialogTheme = theme.alertDialogTheme;
    return ScaleTransition(
      scale: scaleAnimation,
      child: AlertDialog(
        insetPadding: const EdgeInsets.all(10),
        backgroundColor: alertDialogTheme.backgroundColor,
        surfaceTintColor: alertDialogTheme.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        actionsPadding: EdgeInsets.all(0),
        contentPadding: EdgeInsets.all(0),
        titlePadding: EdgeInsets.all(0),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                "Add New Download",
                style: TextStyle(
                  color: alertDialogTheme.textColor,
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
        content: SizedBox(
          width: 500,
          height: resolveDialogHeight(size),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: 500,
                height: 350,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(25),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            child: SvgPicture.asset(
                              FileUtil.resolveFileTypeIconPath(
                                widget.downloadItem.fileType,
                              ),
                              width: 35,
                              height: 35,
                              colorFilter: ColorFilter.mode(
                                FileUtil.resolveFileTypeIconColor(
                                  widget.downloadItem.fileType,
                                ),
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                          SizedBox(width: 5),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 400,
                                child: widget.downloadItem.fileName.characters
                                            .length <
                                        50
                                    ? Text(
                                        widget.downloadItem.fileName,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          color: Colors.white,
                                        ),
                                      )
                                    : DefaultTooltip(
                                        message: widget.downloadItem.fileName,
                                        child: Text(
                                          widget.downloadItem.fileName,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                              ),
                              Text(
                                "Size: $fileSubtitle",
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.white60,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFieldWidget(
                      title: "URL",
                      controller: TextEditingController(
                        text: widget.downloadItem.downloadUrl,
                      ),
                      readonly: true,
                    ),
                    const SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.only(left: 25, right: 25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Save As",
                            style:
                                TextStyle(color: Colors.white60, fontSize: 14),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  width: widget.showActionButtons ? 335 : 500,
                                  height: 40,
                                  child: OutLinedTextField(
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 12,
                                    ),
                                    controller: txtController,
                                    readOnly: !widget.showActionButtons,
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: widget.showActionButtons,
                                child: Row(
                                  children: [
                                    const SizedBox(width: 5),
                                    RoundedOutlinedButton(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      text: "Browse",
                                      height: 40,
                                      width: 110,
                                      icon: SvgPicture.asset(
                                        'assets/icons/folder-open.svg',
                                        colorFilter: ColorFilter.mode(
                                            Colors.white54, BlendMode.srcIn),
                                      ),
                                      textColor: Colors.white,
                                      borderColor: Colors.transparent,
                                      backgroundColor:
                                          alertDialogTheme.itemColor,
                                      onPressed: pickNewSaveLocation,
                                    ),
                                  ],
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Visibility(
                      visible: widget.showSupportsPause,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 25, bottom: 25),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              Icon(
                                size: 18,
                                widget.downloadItem.supportsPause
                                    ? Icons.check_box
                                    : Icons.check_box_outline_blank_rounded,
                                color: Colors.white60,
                              ),
                              const SizedBox(width: 5),
                              Text("Download can be pause/resumed",
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 14)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          if (widget.showActionButtons)
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  RoundedOutlinedButton(
                    text: "Cancel",
                    onPressed: () => Navigator.of(context).pop(),
                    borderColor: Colors.red,
                    textColor: Colors.red,
                  ),
                  const SizedBox(width: 40),
                  RoundedOutlinedButton(
                    text: "Download",
                    width: 151,
                    onPressed: () => _onDownloadPressed(context),
                    backgroundColor: theme
                        .downloadInfoDialogTheme.downloadColor.backgroundColor,
                    borderColor:
                    theme.downloadInfoDialogTheme.downloadColor.borderColor,
                    hoverBackgroundColor: theme.downloadInfoDialogTheme
                        .downloadColor.hoverBackgroundColor,
                    hoverTextColor: theme
                        .downloadInfoDialogTheme.downloadColor.hoverTextColor,
                    textColor:
                    theme.downloadInfoDialogTheme.downloadColor.textColor,
                  ),
                  const SizedBox(width: 40),
                  RoundedOutlinedButton(
                    text: "Add to list",
                    onPressed: addToList,
                    borderColor: Color.fromRGBO(53, 89, 143, 1),
                    textColor: Color.fromRGBO(53, 89, 143, 1),
                  ),
                ],
              ),
            )
          else if (widget.showFileActionButtons)
            Container(
              color: Colors.black12,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    RoundedOutlinedButton(
                      text: "Open File Location",
                      width: 151,
                      onPressed: () {
                        openFileLocation(widget.downloadItem);
                        Navigator.of(context).pop();
                      },
                      backgroundColor: theme
                          .downloadInfoDialogTheme.openFileLocationColor.backgroundColor,
                      borderColor:
                          theme.downloadInfoDialogTheme.openFileLocationColor.borderColor,
                      hoverBackgroundColor: theme.downloadInfoDialogTheme
                          .openFileLocationColor.hoverBackgroundColor,
                      hoverTextColor: theme
                          .downloadInfoDialogTheme.openFileLocationColor.hoverTextColor,
                      textColor:
                          theme.downloadInfoDialogTheme.openFileLocationColor.textColor,
                    ),
                    const SizedBox(width: 10),
                    RoundedOutlinedButton(
                      width: 110,
                      text: "Open File",
                      onPressed: () {
                        launchUrlString("file:${widget.downloadItem.filePath}");
                        Navigator.of(context).pop();
                      },
                      borderColor: Color.fromRGBO(53, 89, 143, 1),
                      textColor: Colors.white,
                      backgroundColor: Color.fromRGBO(53, 89, 143, 1),
                    )
                  ],
                ),
              ),
            )
          else
            Container()
        ],
      ),
    );
  }

  Padding TextFieldWidget(
      {required String title,
      required TextEditingController controller,
      required bool readonly}) {
    return Padding(
      padding: const EdgeInsets.only(left: 25, right: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(color: Colors.white60, fontSize: 14),
          ),
          const SizedBox(height: 5),
          SizedBox(
              width: 500,
              height: 40,
              child: OutLinedTextField(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 12,
                ),
                controller: controller,
                readOnly: readonly,
              ))
        ],
      ),
    );
  }

  double resolveDialogHeight(Size size) {
    double height = 290;
    return widget.showSupportsPause ? height + 30 : height;
  }

  String get fileSubtitle {
    return widget.downloadItem.downloadType == DownloadType.M3U8.name
        ? durationSecondsToReadableStr(
            widget.downloadItem.extraInfo["duration"],
          )
        : convertByteToReadableStr(
            widget.downloadItem.contentLength,
          );
  }

  /// TODO fix download id bug
  void addToList() async {
    final request = widget.downloadItem;
    await HiveUtil.instance.addDownloadItem(request);
    final downloadItemModel = DownloadItemModel.fromDownloadItem(request);
    provider.insertRows([
      DownloadProgressMessage(
        downloadItem: downloadItemModel,
      )
    ]);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  void pickNewSaveLocation() async {
    final filePath = widget.downloadItem.filePath;
    final initialDir = filePath.substring(0, filePath.lastIndexOf('\\'));
    final location = await FilePicker.platform.saveFile(
      fileName: widget.downloadItem.fileName,
      initialDirectory: initialDir,
    );
    if (location != null) {
      setState(() {
        widget.downloadItem.filePath = location;
        txtController.text = location;
      });
    }
  }

  void _onDownloadPressed(BuildContext context) async {
    await HiveUtil.instance.addDownloadItem(widget.downloadItem);
    if (!mounted) return;
    final provider =
        Provider.of<DownloadRequestProvider>(context, listen: false);
    provider.addRequest(widget.downloadItem);
    Navigator.of(context).pop();
    if (SettingsCache.openDownloadProgressWindow) {
      showDialog(
        context: context,
        builder: (_) => DownloadProgressWindow(widget.downloadItem.key),
        barrierDismissible: false,
      );
    }
    provider.executeDownloadCommand(
      widget.downloadItem.key,
      DownloadCommand.start,
    );
  }
}
