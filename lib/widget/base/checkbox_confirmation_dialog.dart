import 'package:brisk/l10n/app_localizations.dart';
import 'package:brisk/provider/theme_provider.dart';
import 'package:brisk/widget/base/rounded_outlined_button.dart';
import 'package:brisk/widget/base/scrollable_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CheckboxConfirmationDialog extends StatefulWidget {
  final Function(bool value) onConfirmPressed;
  final String title;
  final String checkBoxTitle;

  const CheckboxConfirmationDialog({
    Key? key,
    required this.onConfirmPressed,
    required this.title,
    required this.checkBoxTitle,
  }) : super(key: key);

  @override
  State<CheckboxConfirmationDialog> createState() =>
      _CheckedBoxedConfirmationDialogState();
}

class _CheckedBoxedConfirmationDialogState
    extends State<CheckboxConfirmationDialog> {
  bool? checkBoxValue = false;

  @override
  Widget build(BuildContext context) {
    final theme =
        Provider.of<ThemeProvider>(context).activeTheme.alertDialogTheme;
    return ScrollableDialog(
      scrollviewHeight: 110,
      scrollButtonVisible: false,
      width: 450,
      height: 130,
      backgroundColor: theme.backgroundColor,
      title: Padding(
        padding: const EdgeInsets.all(10),
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
              AppLocalizations.of(context)!.confirmAction,
              style: TextStyle(
                  color: theme.textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
          ],
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text(
                widget.title,
                style: const TextStyle(fontSize: 17),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Checkbox(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                  side: WidgetStateBorderSide.resolveWith(
                    (states) => BorderSide(
                      width: 1.0,
                      color: theme.checkBoxColor.borderColor,
                    ),
                  ),
                  activeColor: theme.checkBoxColor.activeColor,
                  value: checkBoxValue,
                  onChanged: (value) => setState(() => checkBoxValue = value),
                ),
                Text(
                  widget.checkBoxTitle,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            )
          ],
        ),
      ),
      buttons: [
        RoundedOutlinedButton.fromButtonColor(
          theme.deleteCancelColor,
          text: AppLocalizations.of(context)!.btn_cancel,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        const SizedBox(width: 5),
        RoundedOutlinedButton.fromButtonColor(
          theme.deleteConfirmColor,
          text: AppLocalizations.of(context)!.btn_deleteConfirm,
          onPressed: () {
            Navigator.of(context).pop();
            widget.onConfirmPressed(checkBoxValue!);
          },
        ),
      ],
    );
  }
}
