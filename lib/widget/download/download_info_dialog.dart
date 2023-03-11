import 'package:brisk/db/hive_boxes.dart';
import 'package:brisk/model/download_item_model.dart';
import 'package:brisk/model/download_progress.dart';
import 'package:brisk/provider/download_request_provider.dart';
import 'package:brisk/util/file_util.dart';
import 'package:brisk/util/readability_util.dart';
import 'package:brisk/util/settings_cache.dart';
import 'package:brisk/widget/base/rounded_outlined_button.dart';
import 'package:brisk/widget/base/outlined_text_field.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../constants/download_command.dart';
import '../../model/download_item.dart';
import 'download_progress_window.dart';

class DownloadInfoDialog extends StatefulWidget {
  final DownloadItem downloadItem;
  final bool showActionButtons;

  const DownloadInfoDialog(this.downloadItem,
      {super.key, this.showActionButtons = true});

  @override
  State<DownloadInfoDialog> createState() => _DownloadInfoDialogState();
}

class _DownloadInfoDialogState extends State<DownloadInfoDialog> {
  late TextEditingController txtController;
  late DownloadRequestProvider provider;

  @override
  void initState() {
    txtController = TextEditingController(text: widget.downloadItem.filePath);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<DownloadRequestProvider>(context, listen: false);
    return AlertDialog(
      insetPadding: const EdgeInsets.all(10),
      backgroundColor: const Color.fromRGBO(25, 25, 25, 1),
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
                                  widget.downloadItem.fileType),
                              width: 70,
                              height: 70,
                              color: FileUtil.resolveFileTypeIconColor(
                                  widget.downloadItem.fileType),
                            )),
                            Text(
                              convertByteToReadableStr(
                                  widget.downloadItem.contentLength),
                              style: const TextStyle(
                                fontSize: 10,
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
        widget.showActionButtons
            ? Padding(
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
                      borderColor: Colors.grey,
                      textColor: Colors.grey,
                    ),
                  ],
                ),
              )
            : Container()
      ],
    );
  }

  /// TODO fix download id bug
  void addToList() async {
    final request = widget.downloadItem;
    await HiveBoxes.instance.downloadItemsBox.add(request);
    provider.insertRows([
      DownloadProgress(
          downloadItem: DownloadItemModel.fromDownloadItem(request))
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
      HiveBoxes.instance.downloadItemsBox
          .put(widget.downloadItem.key, widget.downloadItem);
    }
  }

  void _onDownloadPressed(BuildContext context) async {
    await HiveBoxes.instance.downloadItemsBox.add(widget.downloadItem);
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
