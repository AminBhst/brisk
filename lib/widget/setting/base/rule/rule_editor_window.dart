import 'package:brisk/provider/theme_provider.dart';
import 'package:brisk/setting/rule/file_condition.dart';
import 'package:brisk/setting/rule/file_rule.dart';
import 'package:brisk/setting/rule/rule_value_type.dart';
import 'package:brisk/theme/application_theme.dart';
import 'package:brisk/widget/base/closable_window.dart';
import 'package:brisk/widget/base/rounded_outlined_button.dart';
import 'package:brisk/widget/setting/base/rule/file_rule_item_editor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RuleEditorWindow<T extends FileRule> extends StatefulWidget {
  final String ruleType;
  final List<T> rules;
  final Widget Function(T rule) buildItemTitle;
  final void Function(void Function(T newRule) addRule) onAddPressed;
  final void Function(List<T> rules) onSavePressed;
  final void Function(
    T rule,
    void Function(T oldRule, T newRule) update,
  ) onEditPressed;

  const RuleEditorWindow({
    super.key,
    required this.ruleType,
    required this.rules,
    required this.onSavePressed,
    required this.buildItemTitle,
    required this.onEditPressed,
    required this.onAddPressed,
  });

  @override
  _RuleEditorWindowState<T> createState() => _RuleEditorWindowState<T>();
}

class _RuleEditorWindowState<T extends FileRule>
    extends State<RuleEditorWindow<T>> {
  late ApplicationTheme theme;

  void updateRule(T oldRule, T newRule) {
    setState(() {
      final idx = widget.rules.indexWhere((r) => r == oldRule);
      widget.rules.removeAt(idx);
      widget.rules.insert(idx, newRule);
    });
  }

  void addRule(T newRule) {
    setState(() => widget.rules.add(newRule));
  }

  @override
  Widget build(BuildContext context) {
    theme = Provider.of<ThemeProvider>(context).activeTheme;
    final size = MediaQuery.of(context).size;
    return ClosableWindow(
      width: 500,
      height: size.height > 750 ? 600 : size.height * 0.75,
      backgroundColor: theme.alertDialogTheme.backgroundColor,
      content: SizedBox(
        child: Column(
          children: [
            Text(
              widget.ruleType,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: resolveScrollviewHeight(size),
              width: 400,
              decoration: BoxDecoration(
                color: theme.settingTheme.sideMenuTheme.backgroundColor,
                borderRadius: BorderRadius.circular(25),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ...widget.rules.map((e) => ruleItem(context, e))
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 1),
            IconButton(
                onPressed: () => widget.onAddPressed(addRule),
                icon: Icon(
                  size: 40,
                  Icons.add_circle_rounded,
                  color: Colors.green,
                )),
            const SizedBox(height: 20),
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
                  onPressed: () {
                    widget.onSavePressed(widget.rules);
                    Navigator.of(context).pop();
                  },
                  width: 95,
                  text: "Save",
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  /// TODO terrible code: will fix later
  double resolveScrollviewHeight(Size size) {
    if (size.height > 750) return 390;
    if (size.height > 600) {
      return size.height * (0.45 - ((750 - size.height) / 700 * 0.33));
    }
    if (size.height > 550) {
      return size.height * (0.44 - ((750 - size.height) / 700 * 0.33));
    }
    if (size.height > 500) {
      return size.height * (0.41 - ((750 - size.height) / 700 * 0.33));
    }
    if (size.height > 460) {
      return size.height * (0.36 - ((750 - size.height) / 700 * 0.33));
    }
    if (size.height > 340 && size.height > 411) {
      return size.height * (0.30 - ((750 - size.height) / 700 * 0.33));
    }
    return size.height * 0.1;
  }

  Widget ruleItem(context, T rule) {
    return Padding(
      padding: EdgeInsets.only(top: 10, left: 10, right: 10),
      child: Container(
        decoration: BoxDecoration(
          color: theme.settingTheme.pageTheme.itemAccentColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Row(
            children: [
              widget.buildItemTitle(rule),
              const Spacer(),
              IconButton(
                onPressed: () => widget.onEditPressed(rule, updateRule),
                icon: Icon(Icons.edit_rounded),
                iconSize: 18,
                color: Colors.green,
              ),
              IconButton(
                onPressed: () {
                  setState(() => widget.rules.removeWhere((r) => r == rule));
                },
                icon: Icon(Icons.delete),
                iconSize: 18,
                color: Colors.red,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onAddPressed() {}
}
