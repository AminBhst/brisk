import 'package:brisk/provider/theme_provider.dart';
import 'package:brisk/setting/rule/file_condition.dart';
import 'package:brisk/widget/base/closable_window.dart';
import 'package:brisk/widget/base/outlined_text_field.dart';
import 'package:brisk/widget/base/rounded_outlined_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class RuleItemEditor extends StatefulWidget {
  const RuleItemEditor({super.key});

  @override
  State<RuleItemEditor> createState() => _RuleItemEditorState();
}

class _RuleItemEditorState extends State<RuleItemEditor> {
  late TextEditingController txtController;
  var selectedCondition = FileCondition.fileExtensionIs;
  var selectedType = "MB"; // TODO fix these
  var validTypes = ["KB", "MB", "GB"];
  final conditions = [...FileCondition.values.map((a) => a.name)];

  @override
  void initState() {
    txtController = TextEditingController(text: "100");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).activeTheme;
    return ClosableWindow(
      backgroundColor: theme.alertDialogTheme.backgroundColor,
      height: 250,
      width: 600,
      content: Container(
        width: 600,
        child: Column(
          children: [
            titleRow(),
            const SizedBox(height: 10),
            Row(
              children: [
                SizedBox(
                  width: 205,
                  child: DropdownButton<String>(
                    value: selectedCondition.name,
                    dropdownColor: theme.settingTheme.pageTheme.widgetColor
                        .dropDownColor.dropDownBackgroundColor,
                    items: conditions.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: SizedBox(
                          width: 180,
                          child: Text(
                            value,
                            style: TextStyle(
                              color: theme.settingTheme.pageTheme.widgetColor
                                  .dropDownColor.ItemTextColor,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: onConditionChanged,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 100,
                  height: 50,
                  child: OutLinedTextField(
                    controller: txtController,
                    keyboardType: validTypes.contains("MB")
                        ? TextInputType.number
                        : TextInputType.text,
                    inputFormatters: validTypes.contains("MB")
                        ? [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^[0-9]*$'))
                          ]
                        : [],
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 65,
                  height: 50,
                  child: DropdownButton<String>(
                    value: selectedType,
                    dropdownColor: theme.settingTheme.pageTheme.widgetColor
                        .dropDownColor.dropDownBackgroundColor,
                    items: validTypes.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: SizedBox(
                          width: 40,
                          child: Text(
                            value,
                            style: TextStyle(
                              color: theme.settingTheme.pageTheme.widgetColor
                                  .dropDownColor.ItemTextColor,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (a) {
                      if (a == null) return;
                      setState(() => this.selectedType = a);
                    },
                  ),
                )
              ],
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                RoundedOutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  borderColor:
                      theme.alertDialogTheme.cancelButtonColor.borderColor,
                  hoverTextColor:
                      theme.alertDialogTheme.cancelButtonColor.hoverTextColor,
                  hoverBackgroundColor: theme
                      .alertDialogTheme.cancelButtonColor.hoverBackgroundColor,
                  textColor: theme.alertDialogTheme.cancelButtonColor.textColor,
                  width: 95,
                  text: "Cancel",
                ),
                const SizedBox(width: 30),
                RoundedOutlinedButton(
                  onPressed: () {},
                  borderColor:
                      theme.alertDialogTheme.addButtonColor.borderColor,
                  hoverTextColor:
                      theme.alertDialogTheme.addButtonColor.hoverTextColor,
                  hoverBackgroundColor: theme
                      .alertDialogTheme.addButtonColor.hoverBackgroundColor,
                  textColor: theme.alertDialogTheme.addButtonColor.textColor,
                  width: 95,
                  text: "Save",
                )
              ],
            )
          ],
        ),
      ),
      actions: [],
    );
  }

  void onConditionChanged(String? value) {
    if (value == null) return;
    List<String> validTypes = [];
    String selectedType;
    switch (FileCondition.values.byName(value)) {
      case FileCondition.downloadUrlContains:
      case FileCondition.fileNameContains:
      case FileCondition.fileExtensionIs:
        validTypes = ["Text"];
        selectedType = "Text";
        break;
      case FileCondition.fileSizeLessThan:
      case FileCondition.fileSizeGreaterThan:
        selectedType = "MB";
        validTypes = ["KB", "MB", "GB"];
        break;
    }
    setState(() {
      this.validTypes = validTypes;
      this.selectedType = selectedType;
      selectedCondition = FileCondition.values.byName(value);
      txtController.clear();
    });
  }
}

Widget titleRow() {
  return Row(
    children: [
      Text("Condition", style: TextStyle(color: Colors.grey)),
      const Spacer(),
      Text("Value", style: TextStyle(color: Colors.grey)),
      const SizedBox(width: 68),
      Padding(
        padding: const EdgeInsets.only(right: 35.0),
        child: Text("Type", style: TextStyle(color: Colors.grey)),
      ),
    ],
  );
}
