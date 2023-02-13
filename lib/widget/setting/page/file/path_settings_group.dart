import 'package:brisk/provider/settings_provider.dart';
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
    return SettingsGroup(
      title: "Paths",
      children: [
        TextFieldSetting(
          text: "Temporary Path",
          textWidth: size.width * 0.6 * 0.2,
          width: size.width * 0.6 * 0.3,
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
            icon: openIcon,
          ),
        ),
        const SizedBox(height: 5),
        TextFieldSetting(
          text: "Save Path",
          width: size.width * 0.6 * 0.3,
          textWidth: size.width * 0.6 * 0.2,
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
            icon: openIcon,
          ),
        ),
      ],
    );
  }

  Future<String?> pickNewLocation(String initialDir) async {
    return await FilePicker.platform
        .getDirectoryPath(initialDirectory: initialDir);
  }

  Widget get openIcon => const Icon(
        Icons.open_in_new_rounded,
        color: Colors.white,
      );
}
