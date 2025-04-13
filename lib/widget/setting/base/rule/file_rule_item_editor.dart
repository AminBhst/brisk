import 'package:brisk/provider/theme_provider.dart';
import 'package:brisk/setting/rule/file_condition.dart';
import 'package:brisk/setting/rule/file_rule.dart';
import 'package:brisk/setting/rule/rule_value_type.dart';
import 'package:brisk/widget/base/closable_window.dart';
import 'package:brisk/widget/base/error_dialog.dart';
import 'package:brisk/widget/base/outlined_text_field.dart';
import 'package:brisk/widget/base/rounded_outlined_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class FileRuleItemEditor extends StatefulWidget {
  final FileCondition condition;
  final String value;
  final RuleValueType ruleValueType;
  final Function(FileCondition condition, String value) onSaveClicked;

  const FileRuleItemEditor({
    super.key,
    required this.condition,
    required this.value,
    required this.ruleValueType,
    required this.onSaveClicked,
  });

  @override
  State<FileRuleItemEditor> createState() => _FileRuleItemEditorState();
}

class _FileRuleItemEditorState extends State<FileRuleItemEditor> {
  late TextEditingController txtController;
  late FileCondition selectedCondition;
  late RuleValueType selectedType;
  late List<RuleValueType> validTypes;
  final conditions = [...FileCondition.values.map((a) => a.name)];

  @override
  void initState() {
    selectedCondition = widget.condition;
    selectedType = widget.ruleValueType;
    switch (FileCondition.values.byName(selectedCondition.name)) {
      case FileCondition.downloadUrlContains:
      case FileCondition.fileNameContains:
      case FileCondition.fileExtensionIs:
        validTypes = [RuleValueType.Text];
        break;
      case FileCondition.fileSizeLessThan:
      case FileCondition.fileSizeGreaterThan:
        validTypes = [RuleValueType.KB, RuleValueType.MB, RuleValueType.GB];
        break;
    }
    txtController = TextEditingController(text: widget.value);
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
                    keyboardType: selectedType.isNumber()
                        ? TextInputType.number
                        : TextInputType.text,
                    inputFormatters: selectedType.isNumber()
                        ? [
                            FilteringTextInputFormatter.allow(
                              RegExp(
                                  r'^\d*\.?\d*$'), // Matches numbers, optional decimal, and partial inputs like "0."
                            )
                          ]
                        : [],
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 65,
                  height: 50,
                  child: DropdownButton<String>(
                    value: selectedType.name,
                    dropdownColor: theme.settingTheme.pageTheme.widgetColor
                        .dropDownColor.dropDownBackgroundColor,
                    items: validTypes.map((RuleValueType value) {
                      return DropdownMenuItem<String>(
                        value: value.name,
                        child: SizedBox(
                          width: 40,
                          child: Text(
                            value.name,
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
                      setState(() =>
                          this.selectedType = RuleValueType.values.byName(a));
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
                RoundedOutlinedButton.fromButtonColor(
                  theme.alertDialogTheme.cancelButtonColor,
                  onPressed: () => Navigator.of(context).pop(),
                  width: 95,
                  text: "Cancel",
                ),
                const SizedBox(width: 30),
                RoundedOutlinedButton.fromButtonColor(
                  theme.alertDialogTheme.addButtonColor,
                  onPressed: onSave,
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

  void onSave() {
    String? errorText = null;
    if (txtController.text.isEmpty) {
      errorText = "Empty Value!";
    }
    if (txtController.text.contains(",")) {
      errorText = "Unsupported Character: \",\" ";
    }
    if (errorText != null) {
      showDialog(
        context: context,
        builder: (context) => ErrorDialog(text: errorText!, textHeight: 20),
      );
      return;
    }
    String value;
    switch (selectedType) {
      case RuleValueType.KB:
        value = (double.parse(txtController.text) * 1024).toString();
        break;
      case RuleValueType.MB:
        value = (double.parse(txtController.text) * 1024 * 1024).toString();
        break;
      case RuleValueType.GB:
        value =
            (double.parse(txtController.text) * 1024 * 1024 * 1024).toString();
        break;
      case RuleValueType.Text:
        value = txtController.text;
        break;
    }
    widget.onSaveClicked(selectedCondition, value);
    Navigator.of(context).pop();
  }

  void onConditionChanged(String? value) {
    if (value == null) return;
    List<RuleValueType> validTypes = [];
    RuleValueType selectedType;
    switch (FileCondition.values.byName(value)) {
      case FileCondition.downloadUrlContains:
      case FileCondition.fileNameContains:
      case FileCondition.fileExtensionIs:
        validTypes = [RuleValueType.Text];
        selectedType = RuleValueType.Text;
        break;
      case FileCondition.fileSizeLessThan:
      case FileCondition.fileSizeGreaterThan:
        selectedType = RuleValueType.MB;
        validTypes = [RuleValueType.KB, RuleValueType.MB, RuleValueType.GB];
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
