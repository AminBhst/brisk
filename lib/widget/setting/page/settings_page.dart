import 'package:brisk/provider/settings_provider.dart';
import 'package:brisk/widget/setting/page/about/about_page.dart';
import 'package:brisk/widget/setting/page/bug_report/bug_report_page.dart';
import 'package:brisk/widget/setting/page/connection/connection_settings_page.dart';
import 'package:brisk/widget/setting/page/file/file_settings_page.dart';
import 'package:brisk/widget/setting/page/general/general_settings_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SettingsProvider>(context);
    final size = MediaQuery.of(context).size;
    return Container(
      height: resolveHeight(size.height),
      width: size.width * 0.6 * 0.75,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15), color: Colors.black26),
      child: PageView(
        controller: provider.settingsPageController,
        children: const [
          GeneralSettingsPage(),
          FileSettingsPage(),
          ConnectionSettingsPage(),
          AboutPage(),
          BugReportPage(),
        ],
      ),
    );
  }

  double resolveHeight(double sizeHeight) {
    double height = sizeHeight * 0.8 * 0.65;
    if (height < 500) {
      height = height * 0.9;
    }
    if (height < 400) {
      // height = height * 0.7;
    }
    if (height < 200) {
      height = height * 0.6;
    }

    return height;
  }
}
