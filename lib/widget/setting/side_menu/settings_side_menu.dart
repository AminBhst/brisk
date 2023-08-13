import 'package:brisk/provider/settings_provider.dart';
import 'package:brisk/widget/setting/side_menu/settings_side_menu_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsSideMenu extends StatelessWidget {
  const SettingsSideMenu({super.key});
  static const double itemMargin = 10;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(25),
      ),
      width: minimizedSideMenu(size) ? size.width *0.6 * 0.08 : size.width * 0.6 * 0.14,
      height: size.height < 700 ? size.height * 0.3 : 400,
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              SettingsSideMenuItem(
                tabId: 0,
                title: "General",
                icon: Icons.layers_rounded,
              ),
              SizedBox(height: itemMargin),
              SettingsSideMenuItem(
                tabId: 1,
                title: "File",
                icon: Icons.folder_open_rounded,
              ),
              SizedBox(height: itemMargin),
              SettingsSideMenuItem(
                tabId: 2,
                title: "Connection",
                icon: Icons.wifi,
              ),
              SizedBox(height: itemMargin),
              SettingsSideMenuItem(
                tabId: 3,
                title: "Extension",
                icon: Icons.extension,
              ),
              SizedBox(height: itemMargin),
              SettingsSideMenuItem(
                tabId: 4,
                title: "About",
                icon: Icons.info,
              ),
              SizedBox(height: itemMargin),
              SettingsSideMenuItem(
                tabId: 5,
                title: "Bug Report",
                icon: Icons.bug_report_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool minimizedSideMenu(Size size) => size.width < 1400;
}
