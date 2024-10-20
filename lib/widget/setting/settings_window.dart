import 'dart:io';

import 'package:brisk/provider/settings_provider.dart';
import 'package:brisk/provider/theme_provider.dart';
import 'package:brisk/theme/application_theme_holder.dart';
import 'package:brisk/widget/base/closable_window.dart';
import 'package:brisk/widget/base/rounded_outlined_button.dart';
import 'package:brisk/widget/setting/page/settings_page.dart';
import 'package:brisk/widget/setting/side_menu/settings_side_menu.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../util/settings_cache.dart';

class SettingsWindow extends StatefulWidget {
  const SettingsWindow({super.key});

  @override
  State<SettingsWindow> createState() => _SettingsWindowState();
}

class _SettingsWindowState extends State<SettingsWindow> {
  SettingsProvider? settingsProvider;
  ThemeProvider? themeProvider;

  @override
  Widget build(BuildContext context) {
    settingsProvider = Provider.of<SettingsProvider>(context);
    themeProvider = Provider.of<ThemeProvider>(context);
    final settingTheme = themeProvider!.activeTheme.settingTheme;
    final size = MediaQuery.of(context).size;
    return ClosableWindow(
      backgroundColor: settingTheme.windowBackgroundColor,
      width: size.width * 0.6,
      height: resolveWindowHeight(size),
      padding: const EdgeInsets.all(0),
      onWindowClosed: SettingsCache.setCachedSettings,
      content: SizedBox(
        height: resolveHeight(size.height),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  SizedBox(width: 20),
                  SettingsSideMenu(),
                  SizedBox(width: 20),
                  SettingsPage(),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                RoundedOutlinedButton(
                  text: "Cancel",
                  width: 140,
                  onPressed: _onCancelPressed,
                  borderColor: settingTheme.cancelButtonColor.borderColor,
                  textColor: settingTheme.cancelButtonColor.textColor,
                  hoverBackgroundColor:
                      settingTheme.cancelButtonColor.hoverBackgroundColor,
                  hoverTextColor: settingTheme.cancelButtonColor.hoverTextColor,
                ),
                const SizedBox(width: 20),
                RoundedOutlinedButton(
                  text: "Save Changes",
                  width: 140,
                  onPressed: _onApplyPressed,
                  borderColor: settingTheme.saveButtonColor.borderColor,
                  textColor: settingTheme.saveButtonColor.textColor,
                  hoverBackgroundColor:
                      settingTheme.saveButtonColor.hoverBackgroundColor,
                  hoverTextColor: settingTheme.saveButtonColor.hoverTextColor,
                ),
                const SizedBox(width: 20),
                RoundedOutlinedButton(
                  text: "Reset Default",
                  width: 140,
                  onPressed: _onResetDefaultPressed,
                  borderColor:
                      settingTheme.resetDefaultsButtonColor.borderColor,
                  textColor: settingTheme.resetDefaultsButtonColor.textColor,
                  hoverBackgroundColor: settingTheme
                      .resetDefaultsButtonColor.hoverBackgroundColor,
                  hoverTextColor:
                      settingTheme.resetDefaultsButtonColor.hoverTextColor,
                ),
              ],
            ),
          ],
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

  double resolveWindowHeight(Size size) {
    double height = size.height * 0.75;
    if (size.height < 645) {
      height -= 60;
    }
    if (size.height < 690) {
      height = size.height * 0.77;
    }
    return height;
  }

  double resolveHeight(double sizeHeight) {
    double height = sizeHeight * 0.79 * 0.8;
    if (height < 500) {
      height * 0.9;
    }
    if (height < 700) {
      height * 0.5;
    }
    if (sizeHeight < 645) {
      height = height * 0.93;
    }
    return height;
  }
}
