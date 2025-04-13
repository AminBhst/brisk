import 'dart:io';

import 'package:brisk/provider/settings_provider.dart';
import 'package:brisk/provider/theme_provider.dart';
import 'package:brisk/theme/application_theme_holder.dart';
import 'package:brisk/widget/base/rounded_outlined_button.dart';
import 'package:brisk/widget/setting/page/settings_page.dart';
import 'package:brisk/widget/setting/side_menu/settings_side_menu_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../util/settings_cache.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  SettingsProvider? settingsProvider;
  ThemeProvider? themeProvider;

  @override
  Widget build(BuildContext context) {
    settingsProvider = Provider.of<SettingsProvider>(context);
    themeProvider = Provider.of<ThemeProvider>(context);
    final settingTheme = themeProvider!.activeTheme.settingTheme;
    final size = MediaQuery.of(context).size;
    return AlertDialog(
      content: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: settingTheme.windowBackgroundColor,
          ),
          height: resolveDialogHeight(size),
          width: resolveDialogWidth(size),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Text(
                  "Settings",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
              ),
              SizedBox(height: 30),
              Container(
                width: resolveDialogWidth(size),
                height: 1,
                color: Color.fromRGBO(65, 65, 65, 1.0),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    // color: const Color.fromRGBO(26, 26, 26, 1.0),
                    color: settingTheme.sideMenuTheme.backgroundColor,
                    height: resolveDialogHeight(size) - 144,
                    child: SingleChildScrollView(
                      child: SizedBox(
                        width: 150,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SettingsSideMenuItem(
                                tabId: 0,
                                title: "General",
                                icon: Icons.layers_rounded,
                              ),
                              SettingsSideMenuItem(
                                tabId: 1,
                                title: "File",
                                icon: Icons.folder_open_rounded,
                              ),
                              SettingsSideMenuItem(
                                tabId: 2,
                                title: "Connection",
                                icon: Icons.wifi,
                              ),
                              SettingsSideMenuItem(
                                tabId: 3,
                                title: "Extension",
                                icon: Icons.extension,
                              ),
                              SettingsSideMenuItem(
                                tabId: 4,
                                title: "About",
                                icon: Icons.info,
                              ),
                              SettingsSideMenuItem(
                                tabId: 5,
                                title: "Bug Report",
                                icon: Icons.bug_report_rounded,
                              ),
                            ]),
                      ),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: resolveDialogHeight(size) - 144,
                    color: Color.fromRGBO(65, 65, 65, 1.0),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: SettingsPage(
                        height: resolveDialogHeight(size) - 175,
                        width: resolveDialogWidth(size) - 200),
                  ),
                ],
              ),
              Container(
                height: 1,
                width: 800,
                color: Color.fromRGBO(65, 65, 65, 1.0),
              ),
              Container(
                color: settingTheme.sideMenuTheme.backgroundColor,
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    Transform.translate(
                      offset: Offset(-10, -15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(width: size.width < 880 ? 10 : 20),
                          RoundedOutlinedButton.fromButtonColor(
                            settingTheme.resetDefaultsButtonColor,
                            text: "Reset to Defaults",
                            width: 140,
                            onPressed: _onResetDefaultPressed,
                          ),
                          Spacer(),
                          RoundedOutlinedButton.fromButtonColor(
                            settingTheme.cancelButtonColor,
                            text: "Cancel",
                            width: 80,
                            onPressed: _onCancelPressed,
                          ),
                          SizedBox(width: size.width < 880 ? 10 : 20),
                          RoundedOutlinedButton.fromButtonColor(
                            settingTheme.saveButtonColor,
                            text: "Save Changes",
                            width: 130,
                            onPressed: _onApplyPressed,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _onResetDefaultPressed() {
    SettingsCache.resetDefault();
    SettingsCache.setCachedSettings();
    Navigator.of(context).pop();
  }

  void _onCancelPressed() {
    SettingsCache.setCachedSettings();
    Navigator.of(context).pop();
  }

  void _onApplyPressed() {
    final tempPath = settingsProvider?.tempPath;
    final savePath = settingsProvider?.savePath;
    if (validatePathSettings(tempPath)) {
      SettingsCache.temporaryDir = Directory(tempPath!);
    } else {
      settingsProvider?.tempPath = SettingsCache.temporaryDir.path;
    }
    if (validatePathSettings(savePath)) {
      SettingsCache.saveDir = Directory(savePath!);
    } else {
      settingsProvider?.savePath = SettingsCache.saveDir.path;
    }
    SettingsCache.saveCachedSettingsToDB();
    ApplicationThemeHolder.setActiveTheme();
    themeProvider?.updateActiveTheme();
    Navigator.of(context).pop();
  }

  bool validatePathSettings(String? path) {
    if (path == null) return false;
    final dir = Directory(path);
    return dir.existsSync();
  }

  double resolveDialogWidth(Size size) {
    double width = 800;
    if (size.width < 950) {
      width = size.width * 0.8;
    }
    return width;
  }

  double resolveDialogHeight(Size size) {
    double height = 515;
    if (size.height < 627) {
      height = 465;
    }
    if (size.height < 576) {
      height = 400;
    }
    if (size.height < 511) {
      height = 340;
    }
    if (size.height < 451) {
      height = 290;
    }
    if (size.height < 401) {
      height = 200;
    }
    return height;
  }
}
