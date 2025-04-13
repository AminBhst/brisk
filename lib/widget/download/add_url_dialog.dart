import 'package:brisk/provider/theme_provider.dart';
import 'package:brisk/util/download_addition_ui_util.dart';
import 'package:brisk/widget/base/rounded_outlined_button.dart';
import 'package:brisk/widget/loader/file_info_loader.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';

class AddUrlDialog extends StatefulWidget {
  final bool updateDialog;
  final int? downloadId;

  const AddUrlDialog({super.key, this.updateDialog = false, this.downloadId});

  @override
  State<AddUrlDialog> createState() => _AddUrlDialogState();
}

class _AddUrlDialogState extends State<AddUrlDialog> {
  TextEditingController txtController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme =
        Provider.of<ThemeProvider>(context).activeTheme.alertDialogTheme;
    return LoaderOverlay(
      overlayWidgetBuilder: (progress) => FileInfoLoader(
        onCancelPressed: () => DownloadAdditionUiUtil.cancelRequest(context),
      ),
      child: AlertDialog(
        surfaceTintColor: theme.backgroundColor,
        backgroundColor: theme.backgroundColor,
        insetPadding: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        title: Text(
          widget.updateDialog ? "Update Download URL" : "Add a Download URL",
          style: TextStyle(color: theme.textColor),
        ),
        content: SizedBox(
          width: 400,
          height: 100,
          child: Row(
            children: [
              SizedBox(
                width: 340,
                child: TextField(
                  maxLines: 1,
                  cursorColor: theme.urlFieldColor.cursorColor,
                  controller: txtController,
                  decoration: InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: theme.urlFieldColor.borderColor,
                    ),
                  )),
                  style: TextStyle(color: theme.urlFieldColor.textColor),
                ),
              ),
              const SizedBox(width: 20),
              IconButton(
                icon: const Icon(Icons.paste_rounded, color: Colors.white),
                onPressed: () async {
                  String url = await FlutterClipboard.paste();
                  setState(() => txtController.text = url);
                },
              ),
            ],
          ),
        ),
        actions: <Widget>[
          RoundedOutlinedButton.fromButtonColor(
            theme.cancelButtonColor,
            text: "Cancel",
            width: 80,
            onPressed: () => _onCancelPressed(context),
          ),
          RoundedOutlinedButton.fromButtonColor(
            theme.addButtonColor,
            text: widget.updateDialog ? "Update URL" : "Add URL",
            width: 120,
            onPressed: () => _onAddPressed(context),
          ),
        ],
      ),
    );
  }

  void _onCancelPressed(BuildContext context) {
    txtController.text = '';
    Navigator.of(context).pop();
  }

  void _onAddPressed(BuildContext context) {
    final url = txtController.text;
    DownloadAdditionUiUtil.handleDownloadAddition(context, url,
        updateDialog: widget.updateDialog,
        downloadId: widget.downloadId,
        additionalPop: true);
  }
}
