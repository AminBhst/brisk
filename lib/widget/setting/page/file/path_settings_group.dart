import 'package:brisk/provider/settings_provider.dart';
import 'package:brisk/provider/theme_provider.dart';
import 'package:brisk/widget/setting/base/settings_group.dart';
import 'package:brisk/widget/setting/base/text_field_setting.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../util/settings_cache.dart';

class PathSettingsGroup extends StatefulWidget {
  const PathSettingsGroup({super.key});

  @override
  State<PathSettingsGroup> createState() => _PathSettingsGroupState();
}

class _PathSettingsGroupState extends State<PathSettingsGroup> {
  String tempPath = SettingsCache.temporaryDir.path;
  String savePath = SettingsCache.saveDir.path;
  TextEditingController tempPathController =
      TextEditingController(text: SettingsCache.temporaryDir.path);
  TextEditingController savePathController =
      TextEditingController(text: SettingsCache.saveDir.path);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final provider = Provider.of<SettingsProvider>(context);
    final theme = Provider.of<ThemeProvider>(context)
        .activeTheme
        .settingTheme
        .pageTheme
        .widgetColor;
    return SettingsGroup(
      title: "Paths",
      children: [
        TextFieldSetting(
          text: "Temp Files Path",
          textWidth: resolveTextWidth(size),
          width: resolveTextFieldWidth(size),
          txtController: tempPathController,
          onChanged: (value) {
            provider.tempPath = value;
          },
          icon: IconButton(
            onPressed: () async {
              final newPath = await pickNewLocation(savePath);
              if (newPath == null) return;
              tempPathController.text = newPath;
              provider.tempPath = newPath;
            },
            icon: Icon(
              Icons.open_in_new_rounded,
              color: theme.launchIconColor,
            ),
          ),
        ),
        const SizedBox(height: 5),
        TextFieldSetting(
          text: "Save Path",
          textWidth: resolveTextWidth(size),
          width: resolveTextFieldWidth(size),
          txtController: savePathController,
          onChanged: (value) {
            provider.savePath = value;
          },
          icon: IconButton(
            onPressed: () async {
              final newPath = await pickNewLocation(savePath);
              if (newPath == null) return;
              savePathController.text = newPath;
              provider.savePath = newPath;
            },
            icon: Icon(
              Icons.open_in_new_rounded,
              color: theme.launchIconColor,
            ),
          ),
        ),
      ],
    );
  }

  double resolveTextFieldWidth(Size size) {
    double width = 300;
    if (size.width < 913) {
      width = size.width * 0.3;
    }
    if (size.width < 860) {
      width = size.width * 0.28;
    }
    if (size.width < 827) {
      width = size.width * 0.25;
    }
    if (size.width < 782) {
      width = size.width * 0.21;
    }
    if (size.width < 645) {
      width = size.width * 0.16;
    }
    return width;
  }

  double resolveTextWidth(Size size) {
    double width = 150;
    if (size.width < 730) {
      width = 100;
    }
    return width;
  }

  Future<String?> pickNewLocation(String initialDir) async {
    return await FilePicker.platform
        .getDirectoryPath(initialDirectory: initialDir);
  }

}
