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

  const DownloadInfoDialog(
    this.downloadItem, {
    super.key,
    this.showActionButtons = true,
    this.showFileActionButtons = false,
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
    final theme =
        Provider.of<ThemeProvider>(context).activeTheme.alertDialogTheme;
    return ScaleTransition(
      scale: scaleAnimation,
      child: AlertDialog(
        insetPadding: const EdgeInsets.all(10),
        backgroundColor: theme.backgroundColor,
        surfaceTintColor: theme.backgroundColor,
        content: SizedBox(
          width: 500,
          height: 350,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                  width: 500,
                  height: 400,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              SizedBox(
                                child: SvgPicture.asset(
                                  FileUtil.resolveFileTypeIconPath(
                                    widget.downloadItem.fileType,
                                  ),
                                  width: 70,
                                  height: 70,
                                  colorFilter: ColorFilter.mode(
                                    FileUtil.resolveFileTypeIconColor(
                                      widget.downloadItem.fileType,
                                    ),
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                              Text(
                                fileSubtitle,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 30),
                        ],
                      ),
                      const SizedBox(height: 40),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'File Name : ',
                            style: TextStyle(color: Colors.white),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 300,
                            height: 50,
                            child: OutLinedTextField(
                              controller: TextEditingController(
                                text: widget.downloadItem.fileName,
                              ),
                              readOnly: true,
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: EdgeInsets.only(
                            left: widget.showActionButtons ? 55 : 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Save As : ',
                              style: TextStyle(color: Colors.white),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 300,
                              height: 50,
                              child: OutLinedTextField(
                                  readOnly: !widget.showActionButtons,
                                  controller: txtController),
                            ),
                            const SizedBox(width: 10),
                            Visibility(
                              visible: widget.showActionButtons,
                              child: IconButton(
                                onPressed: pickNewSaveLocation,
                                icon: const Icon(
                                  Icons.open_in_new_rounded,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 31),
                            child: Text('URL : ',
                                style: TextStyle(color: Colors.white)),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                              width: 300,
                              height: 50,
                              child: OutLinedTextField(
                                controller: TextEditingController(
                                  text: widget.downloadItem.downloadUrl,
                                ),
                                readOnly: true,
                              ))
                        ],
                      ),
                      const SizedBox(height: 15),
                      Stack(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 42),
                              child: Text(
                                  'Resumable :    ${widget.downloadItem.supportsPause == true ? 'Yes' : 'No'}',
                                  style: const TextStyle(color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )),
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
                    onPressed: () => _onDownloadPressed(context),
                    borderColor: Colors.green,
                    textColor: Colors.green,
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
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  RoundedOutlinedButton(
                    text: "Open File",
                    onPressed: () {
                      launchUrlString("file:${widget.downloadItem.filePath}");
                      Navigator.of(context).pop();
                    },
                    borderColor: Color.fromRGBO(53, 89, 143, 1),
                    textColor: Colors.white,
                    backgroundColor: Color.fromRGBO(53, 89, 143, 1),
                  ),
                  const SizedBox(width: 40),
                  RoundedOutlinedButton(
                    text: "Open File Location",
                    onPressed: () {
                      openFileLocation(widget.downloadItem);
                      Navigator.of(context).pop();
                    },
                    borderColor: Color.fromRGBO(53, 89, 143, 1),
                    textColor: Color.fromRGBO(53, 89, 143, 1),
                  ),
                ],
              ),
            )
          else
            Container()
        ],
      ),
    );
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
      HiveUtil.instance.downloadItemsBox
          .put(widget.downloadItem.key, widget.downloadItem);
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
