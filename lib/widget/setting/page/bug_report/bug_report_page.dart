import 'package:brisk/provider/theme_provider.dart';
import 'package:brisk/widget/setting/base/settings_group.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

class BugReportPage extends StatelessWidget {
  const BugReportPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme =
        Provider.of<ThemeProvider>(context).activeTheme.settingTheme.pageTheme;
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SettingsGroup(
            height: 180,
            title: "How to report a bug",
            children: [
              SizedBox(
                width: size.width * 0.6,
                height: 50,
                child: Text(
                  "In order to report a bug or request a feature, open a new issue in the project github repo and add the proper labels.\n\n",
                  style: TextStyle(color: theme.titleTextColor),
                ),
              ),
              InkWell(
                child: SizedBox(
                  width: size.width * 0.6,
                  child: const Text(
                    "Click to open an issue",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
                onTap: () => launchUrlString(
                    "https://github.com/AminBhst/brisk/issues/new"),
              )
            ],
          ),
        ],
      ),
    );
  }
}
