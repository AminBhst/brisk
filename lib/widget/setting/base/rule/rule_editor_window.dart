import 'package:brisk/provider/theme_provider.dart';
import 'package:brisk/widget/base/closable_window.dart';
import 'package:brisk/widget/base/rounded_outlined_button.dart';
import 'package:brisk/widget/setting/base/rule/rule_item_editor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RuleEditorWindow extends StatelessWidget {
  final String ruleType;

  const RuleEditorWindow({super.key, required this.ruleType});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).activeTheme;
    final size = MediaQuery.of(context).size;
    return ClosableWindow(
      width: 500,
      height: size.height > 750 ? 650 : size.height * 0.8,
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
              height: resolveScrollviewHeight(size),
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
            ),
            SizedBox(height: 20),
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
    );
  }

  double resolveScrollviewHeight(Size size) {
    if (size.height > 750) return 450;
    if (size.height > 510) {
      return size.height * (0.53 - ((750 - size.height) / 700 * 0.33));
    }
    if (size.height > 460) {
      return size.height * (0.4 - ((510 - size.height) / 50 * 0.1));
    }
    if (size.height > 340 && size.height > 395) {
      return size.height * (0.3 - ((460 - size.height) / 120 * 0.1));
    }
    return size.height * 0.1;
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
