import 'dart:io';

import 'package:brisk/provider/theme_provider.dart';
import 'package:brisk/setting/rule/file_condition.dart';
import 'package:brisk/setting/rule/rule_value_type.dart';
import 'package:brisk/util/settings_cache.dart';
import 'package:brisk/widget/base/closable_window.dart';
import 'package:brisk/widget/base/error_dialog.dart';
import 'package:brisk/widget/base/outlined_text_field.dart';
import 'package:brisk/widget/base/rounded_outlined_button.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class FileSaveRuleItemEditor extends StatefulWidget {
  final FileCondition condition;
  final String value;
  final RuleValueType ruleValueType;
  final String savePath;
  final Function(FileCondition condition, String value, String savePath)
      onSaveClicked;

  const FileSaveRuleItemEditor({
    super.key,
    required this.condition,
    required this.value,
    required this.ruleValueType,
    required this.onSaveClicked,
    required this.savePath,
  });

  @override
  State<FileSaveRuleItemEditor> createState() => _FileSaveRuleItemEditorState();
}

class _FileSaveRuleItemEditorState extends State<FileSaveRuleItemEditor> {
  late TextEditingController valueController;
  late TextEditingController savePathController;
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
    valueController = TextEditingController(text: widget.value);
    savePathController = TextEditingController(text: widget.savePath);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).activeTheme;
    final size = MediaQuery.of(context).size;
    return ClosableWindow(
      backgroundColor: theme.alertDialogTheme.backgroundColor,
      height: 360,
      width: 600,
      content: Container(
        width: 600,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                    controller: valueController,
                    keyboardType: selectedType.isNumber()
                        ? TextInputType.number
                        : TextInputType.text,
                    inputFormatters: selectedType.isNumber()
                        ? [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d*$'),
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
            titleRow2(),
            const SizedBox(height: 10),
            Row(
              children: [
                SizedBox(
                  width: size.width > 686 ? 500 : size.width * 0.6,
                  child: OutLinedTextField(controller: savePathController),
                ),
                const SizedBox(width: 5),
                IconButton(
                    onPressed: pickSaveLocation,
                    icon: Icon(
                      size: 30,
                      Icons.open_in_new_rounded,
                      color: Colors.white70,
                    ))
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
            ),
          ],
        ),
      ),
      actions: [],
    );
  }

  void pickSaveLocation() async {
    final newLocation = await FilePicker.platform.getDirectoryPath(
      initialDirectory: SettingsCache.saveDir.path,
    );
    if (newLocation == null) return;
    savePathController.text = newLocation;
  }

  void onSave() {
    String? errorText = null;
    if (valueController.text.isEmpty) {
      errorText = "Empty value!";
    }
    if (valueController.text.contains(",") ||
        savePathController.text.contains(",")) {
      errorText = "Unsupported Character: \",\" ";
    }
    if (valueController.text.contains("@:/") ||
        savePathController.text.contains("@:/")) {
      errorText = "Unsupported Character: \"@:/\" ";
    }
    if (!Directory(savePathController.text).existsSync()) {
      errorText = "Invalid Save Path!";
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
        value = (double.parse(valueController.text) * 1024).toString();
        break;
      case RuleValueType.MB:
        value = (double.parse(valueController.text) * 1024 * 1024).toString();
        break;
      case RuleValueType.GB:
        value = (double.parse(valueController.text) * 1024 * 1024 * 1024)
            .toString();
        break;
      case RuleValueType.Text:
        value = valueController.text;
        break;
    }
    widget.onSaveClicked(selectedCondition, value, savePathController.text);
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
      valueController.clear();
    });
  }
}

Widget titleRow2() {
  return Row(
    children: [
      Text("Save Path", style: TextStyle(color: Colors.grey)),
      const Spacer(),
    ],
  );
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
