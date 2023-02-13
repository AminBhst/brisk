import 'package:brisk/util/parse_util.dart';
import 'package:brisk/widget/setting/base/settings_group.dart';
import 'package:brisk/widget/setting/base/text_field_setting.dart';
import 'package:flutter/material.dart';

import '../../../../util/settings_cache.dart';

class FileCategoryGroup extends StatelessWidget {
  const FileCategoryGroup({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SettingsGroup(
      height: 380,
      title: "File Category",
      children: [
        TextFieldSetting(
          text: "Video",
          width: size.width * 0.6 * 0.4,
          txtController: TextEditingController(text: parseListToCsv(SettingsCache.videoFormats)),
          onChanged: (val) => setCachedFormats(
            val,
            (formats) => SettingsCache.videoFormats = formats,
          ),
        ),
        marginSizedBox,
        TextFieldSetting(
          text: "Music",
          width: size.width * 0.6 * 0.4,
          txtController: TextEditingController(text: parseListToCsv(SettingsCache.musicFormats)),
          onChanged: (val) => setCachedFormats(
            val,
            (formats) => SettingsCache.musicFormats = formats,
          ),
        ),
        marginSizedBox,
        TextFieldSetting(
          text: "Archive",
          width: size.width * 0.6 * 0.4,
          txtController: TextEditingController(text: parseListToCsv(SettingsCache.compressedFormats)),
          onChanged: (val) => setCachedFormats(
            val,
            (formats) => SettingsCache.compressedFormats = formats,
          ),
        ),
        marginSizedBox,
        TextFieldSetting(
          text: "Program",
          width: size.width * 0.6 * 0.4,
          txtController: TextEditingController(text: parseListToCsv(SettingsCache.programFormats)),
          onChanged: (val) => setCachedFormats(
            val,
            (formats) => SettingsCache.programFormats = formats,
          ),
        ),
        marginSizedBox,
        TextFieldSetting(
          text: "Document",
          width: size.width * 0.6 * 0.4,
          txtController: TextEditingController(text: parseListToCsv(SettingsCache.documentFormats)),
          onChanged: (val) => setCachedFormats(
            val,
            (formats) => SettingsCache.documentFormats = formats,
          ),
        ),
      ],
    );
  }

  void setCachedFormats(
      String value, Function(List<String> formats) setCache) async {
    if (value.isEmpty) return;
    setCache(parseCsvToList(value));
  }

  Widget get marginSizedBox => const SizedBox(height: 10);
}
