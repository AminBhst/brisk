import 'package:brisk/setting/rule/file_condition.dart';
import 'package:brisk/setting/rule/file_save_path_rule.dart';
import 'package:brisk/setting/rule/rule_value_type.dart';
import 'package:brisk/util/settings_cache.dart';
import 'package:brisk/widget/base/default_tooltip.dart';

import 'package:brisk/widget/setting/base/external_link_setting.dart';
import 'package:brisk/widget/setting/base/rule/file_save_rule_item_editor.dart';
import 'package:brisk/widget/setting/base/rule/rule_editor_window.dart';
import 'package:brisk/widget/setting/base/settings_group.dart';
import 'package:flutter/material.dart';

class FileRulesGroup extends StatelessWidget {
  const FileRulesGroup({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SettingsGroup(
      height: 150,
      title: "Rules",
      children: [
        ExternalLinkSetting(
          title: "File Save Path Rules",
          titleWidth: resolveWidth(size),
          linkText: "Open Rule Editor",
          onLinkPressed: () => showDialog(
            builder: (context) => RuleEditorWindow<FileSavePathRule>(
              ruleType: "File Save Path Rules",
              rules: [...SettingsCache.fileSavePathRules],
              buildItemTitle: (FileSavePathRule rule) {
                return SizedBox(
                  height: 40,
                  width: 230,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            rule.condition.toReadable(),
                            style: TextStyle(color: Colors.white),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            rule.readableValue,
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 180,
                        child: rule.savePath.length > 22
                            ? DefaultTooltip(
                                message: rule.savePath,
                                child: Text(
                                  overflow: TextOverflow.ellipsis,
                                  rule.savePath,
                                  style: TextStyle(color: Colors.white),
                                ),
                              )
                            : Text(
                                rule.savePath,
                                style: TextStyle(color: Colors.white),
                              ),
                      )
                    ],
                  ),
                );
              },
              onSavePressed: (List<FileSavePathRule> rules) {
								SettingsCache.fileSavePathRules = rules;
							},
              onEditPressed: (
                FileSavePathRule rule,
                Function(FileSavePathRule oldRule, FileSavePathRule newRule) update,
              ) {
                showDialog(
                  builder: (_) => FileSaveRuleItemEditor(
                    condition: rule.condition,
                    value: rule.valueWithTypeConsidered,
                    ruleValueType: RuleValueType.fromRule(rule),
                    onSaveClicked: (
                      FileCondition condition,
                      String value,
                      String savePath
                    ) {
                      final newRule = FileSavePathRule(
                        condition: condition,
                        value: value,
                        savePath: savePath,
                      );
                      update(rule, newRule);
                    },
                    savePath: rule.savePath,
                  ),
                  context: context,
                );
              },
              onAddPressed: (Function(FileSavePathRule) addRule) {
                showDialog(
                  context: context,
                  builder: (context) => FileSaveRuleItemEditor(
                    condition: FileCondition.fileNameContains,
                    value: "",
                    ruleValueType: RuleValueType.Text,
                    onSaveClicked: (condition, value, savePath) {
                      final rule = FileSavePathRule(
                        condition: condition,
                        value: value,
                        savePath: savePath,
                      );
                      addRule(rule);
                      // addRule(rule);
                    },
                    savePath: '',
                  ),
                );
              },
            ),
            context: context,
          ),
          tooltipMessage:
              "Defines conditions which determine when a file should be saved in the specified location",
        )
      ],
    );
  }

  double resolveWidth(Size size) {
    double width = 140;
    if (size.width < 688) {
      width = 120;
    }
    if (size.width < 608) {
      width = 90;
    }
    return width;
  }
}
