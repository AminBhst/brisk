import 'dart:io';

import 'package:brisk/l10n/app_localizations.dart';
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
  late List<String> conditions;
  late AppLocalizations loc;
  late Map<FileCondition, String> fileConditionMap;

  @override
  void initState() {
    valueController = TextEditingController(text: widget.value);
    savePathController = TextEditingController(text: widget.savePath);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    loc = AppLocalizations.of(context)!;
    fileConditionMap = buildDropMenuLocaleMap();
    conditions = fileConditionMap.values.toList();
    selectedCondition = widget.condition;
    selectedType = widget.ruleValueType;
    conditions = fileConditionMap.values.toList();
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
    super.didChangeDependencies();
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
                    value: fileConditionMap[selectedCondition],
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
            OutLinedTextField(
              controller: savePathController,
              suffixIcon: IconButton(
                icon: Icon(Icons.folder, color: Colors.white60),
                onPressed: pickSaveLocation,
              ),
            ),
            // Row(
            //   children: [
            //     SizedBox(
            //       width: size.width > 686 ? 500 : size.width * 0.6,
            //       child: OutLinedTextField(controller: savePathController),
            //     ),
            //     const SizedBox(width: 5),
            //   ],
            // ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                RoundedOutlinedButton.fromButtonColor(
                  theme.alertDialogTheme.cancelButtonColor,
                  onPressed: () => Navigator.of(context).pop(),
                  text: loc.btn_cancel,
                ),
                const SizedBox(width: 30),
                RoundedOutlinedButton.fromButtonColor(
                  theme.alertDialogTheme.addButtonColor,
                  onPressed: onSave,
                  text: loc.btn_save,
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
      errorText = loc.err_emptyValue;
    }
    if (valueController.text.contains(",") ||
        savePathController.text.contains(",")) {
      errorText = "${loc.err_unsupportedCharacter}: \",\" ";
    }
    if (valueController.text.contains("@:/") ||
        savePathController.text.contains("@:/")) {
      errorText = "${loc.err_unsupportedCharacter}: \"@:/\" ";
    }
    if (!Directory(savePathController.text).existsSync()) {
      errorText = loc.err_invalidSavePath;
    }
    if (errorText != null) {
      showDialog(
        context: context,
        builder: (context) => ErrorDialog(
          title: loc.error,
          description: errorText!,
          height: 100,
        ),
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

  void onConditionChanged(String? valueStr) {
    if (valueStr == null) {
      return;
    }
    final value = fileConditionMap.entries
        .firstWhere((entry) => entry.value == valueStr)
        .key;
    List<RuleValueType> validTypes = [];
    RuleValueType selectedType;
    switch (value) {
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
      selectedCondition = value;
      valueController.clear();
    });
  }

  Widget titleRow() {
    return Row(
      children: [
        Text(loc.condition, style: TextStyle(color: Colors.grey)),
        const Spacer(),
        Text(loc.value, style: TextStyle(color: Colors.grey)),
        const SizedBox(width: 68),
        Padding(
          padding: const EdgeInsets.only(right: 35.0),
          child: Text(loc.type, style: TextStyle(color: Colors.grey)),
        ),
      ],
    );
  }

  Widget titleRow2() {
    return Row(
      children: [
        Text(loc.savePath, style: TextStyle(color: Colors.grey)),
        const Spacer(),
      ],
    );
  }

  Map<FileCondition, String> buildDropMenuLocaleMap() {
    return {
      FileCondition.downloadUrlContains: loc.ruleEditor_downloadUrlContains,
      FileCondition.fileNameContains: loc.ruleEditor_fileNameContains,
      FileCondition.fileExtensionIs: loc.ruleEditor_fileExtensionIs,
      FileCondition.fileSizeLessThan: loc.ruleEditor_fileSizeLessThan,
      FileCondition.fileSizeGreaterThan: loc.ruleEditor_fileSizeGreaterThan,
    };
  }
}
