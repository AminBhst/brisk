import 'dart:io';

import 'package:brisk/provider/settings_provider.dart';
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
  SettingsProvider? provider;

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<SettingsProvider>(context);
    final size = MediaQuery.of(context).size;
    return ClosableWindow(
      width: size.width * 0.6,
      height: size.height * 0.79,
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
                  // width: 140,
                  onPressed: _onCancelPressed,
                  borderColor: Colors.red,
                  textColor: Colors.red,
                ),
                const SizedBox(width: 20),
                RoundedOutlinedButton(
                  text: "Save Changes",
                  width: 140,
                  onPressed: _onApplyPressed,
                  borderColor: Colors.green,
                  textColor: Colors.green,
                ),
                const SizedBox(width: 20),
                RoundedOutlinedButton(
                  text: "Reset Default",
                  width: 140,
                  onPressed: _onResetDefaultPressed,
                  borderColor: Colors.blueGrey,
                  textColor: Colors.blueGrey,
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
    final tempPath = provider?.tempPath;
    final savePath = provider?.savePath;
    if (validatePathSettings(tempPath)) {
      SettingsCache.temporaryDir = Directory(tempPath!);
    } else {
      provider?.tempPath = SettingsCache.temporaryDir.path;
    }
    if (validatePathSettings(savePath)) {
      SettingsCache.saveDir = Directory(savePath!);
    } else {
      provider?.savePath = SettingsCache.saveDir.path;
    }
    SettingsCache.saveCachedSettingsToDB();
    Navigator.of(context).pop();
  }

  bool validatePathSettings(String? path) {
    if (path == null) return false;
    final dir = Directory(path);
    return dir.existsSync();
  }

  double resolveHeight(double sizeHeight) {
    double height = sizeHeight * 0.79 * 0.8;
    if (height < 500) {
      height * 0.9;
    }
    if (height < 700) {
      height * 0.5;
    }
    return height;
  }
}
