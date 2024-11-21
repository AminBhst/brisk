import 'package:brisk/provider/theme_provider.dart';
import 'package:brisk/util/settings_cache.dart';
import 'package:brisk/widget/base/closable_window.dart';
import 'package:brisk/widget/setting/base/rule/rule_item_editor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RuleEditorWindow extends StatelessWidget {
  final String ruleType;

  const RuleEditorWindow({super.key, required this.ruleType});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).activeTheme;
    return ClosableWindow(
      width: 500,
      height: 650,
      backgroundColor: theme.alertDialogTheme.backgroundColor,
      content: SizedBox(
        child: Column(
          children: [
            Text(
              ruleType,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 450,
              width: 400,
              decoration: BoxDecoration(
                color: theme.settingTheme.sideMenuTheme.backgroundColor,
                borderRadius: BorderRadius.circular(25),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ruleRow(context),
                    ruleRow(context),
                    ruleRow(context),
                    ruleRow(context),
                    ruleRow(context),
                    ruleRow(context),
                    ruleRow(context),
                    ruleRow(context),
                    ruleRow(context),
                    ruleRow(context),
                    ruleRow(context),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget ruleRow(context) {
    return Padding(
      padding: EdgeInsets.only(top: 10, left: 10, right: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Row(
            children: [
              Text("File size greater than "),
              Text("1 MB"),
              const Spacer(),
              IconButton(
                onPressed: () => showDialog(
                  builder: (context) => RuleItemEditor(),
                  context: context,
                ),
                icon: Icon(Icons.edit_rounded),
                iconSize: 18,
                color: Colors.green,
              ),
              IconButton(
                onPressed: () {},
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
}
