import 'package:brisk/setting/rule/file_condition.dart';
import 'package:brisk/setting/rule/file_rule.dart';
import 'package:brisk/setting/rule/rule_value_type.dart';
import 'package:brisk/util/settings_cache.dart';
import 'package:brisk/widget/setting/base/external_link_setting.dart';
import 'package:brisk/widget/setting/base/rule/file_rule_item_editor.dart';
import 'package:brisk/widget/setting/base/rule/rule_editor_window.dart';
import 'package:brisk/widget/setting/base/settings_group.dart';
import 'package:flutter/material.dart';

class BrowserExtensionRulesGroup extends StatelessWidget {
  const BrowserExtensionRulesGroup({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SettingsGroup(
      height: 130,
      title: "Rules",
      children: [
        ExternalLinkSetting(
          title: "Extension Skip Capture Rules",
          width: resolveLinkWidth(size),
          titleWidth: resolveTitleWidth(size),
          linkText: "Open Rule Editor",
          onLinkPressed: () => showDialog(
            builder: (context) => RuleEditorWindow<FileRule>(
              ruleType: "Extension Skip Capture Rules",
              rules: [...SettingsCache.extensionSkipCaptureRules],
              onSavePressed: (List<FileRule> rules) {
                SettingsCache.extensionSkipCaptureRules = rules;
              },
              buildItemTitle: buildRuleRow,
              onEditPressed: (
                FileRule rule,
                Function(FileRule oldRule, FileRule newRule) update,
              ) {
                showDialog(
                  builder: (_) => FileRuleItemEditor(
                    condition: rule.condition,
                    value: rule.valueWithTypeConsidered,
                    ruleValueType: RuleValueType.fromRule(rule),
                    onSaveClicked: (FileCondition condition, String value) {
                      final newRule = FileRule(
                        condition: condition,
                        value: value,
                      );
                      update(rule, newRule);
                    },
                  ),
                  context: context,
                );
              },
              onAddPressed: (Function(FileRule) addRule) {
                showDialog(
                  context: context,
                  builder: (context) => FileRuleItemEditor(
                    condition: FileCondition.fileNameContains,
                    value: "",
                    ruleValueType: RuleValueType.Text,
                    onSaveClicked: (condition, value) {
                      final rule = FileRule(condition: condition, value: value);
                      addRule(rule);
                    },
                  ),
                );
              },
            ),
            context: context,
          ),
          tooltipMessage:
              "Defines conditions which determine when a file should not be captures via browser extension",
        ),
      ],
    );
  }

  Widget buildRuleRow(FileRule rule) {
    return Row(
      children: [
        Text(rule.condition.toReadable()),
        const SizedBox(width: 5),
        SizedBox(
          width: 90,
          child: rule.readableValue.length > 10
              ? Tooltip(
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(33, 33, 33, 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: TextStyle(color: Colors.white),
                  child:
                      Text(rule.readableValue, overflow: TextOverflow.ellipsis),
                  message: rule.readableValue,
                )
              : Text(rule.readableValue, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  double resolveLinkWidth(Size size) {
    double width = 300;
    if (size.width < 754) {
      width = 230;
    }
    if (size.width < 666) {
      width = 200;
    }
    if (size.width < 630) {
      width = 180;
    }
    return width;
  }

  double resolveTitleWidth(Size size) {
    double width = 220;
    if (size.width < 754) {
      width = 170;
    }
    if (size.width < 666) {
      width = 120;
    }
    return width;
  }
}
