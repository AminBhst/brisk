import 'package:brisk/widget/setting/base/external_link_setting.dart';
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
          titleWidth: resolveTitleWidth(size),
          linkText: "Open Rule Editor",
          onLinkPressed: () => showDialog(
            builder: (context) => RuleEditorWindow(
              ruleType: "Extension Skip Capture Rules",
            ),
            context: context,
          ),
          tooltipMessage:
              "Defines conditions which determine when a file should not be captures via browser extension",
        ),
      ],
    );
  }

  double resolveTitleWidth(Size size) {
    var width = size.width * 0.3 * 0.5;
    print(width);
    if (width > 190) {
      print("returning 1250");
      return 190;
    }
    return width;
  }
}
