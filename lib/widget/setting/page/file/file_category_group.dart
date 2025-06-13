import 'package:brisk/l10n/app_localizations.dart';
import 'package:brisk/util/parse_util.dart';
import 'package:brisk/widget/setting/base/settings_group.dart';
import 'package:brisk/widget/setting/base/switch_setting.dart';
import 'package:brisk/widget/setting/base/text_field_setting.dart';
import 'package:flutter/material.dart';

import '../../../../util/settings_cache.dart';

class FileCategoryGroup extends StatefulWidget {
  const FileCategoryGroup({super.key});

  @override
  State<FileCategoryGroup> createState() => _FileCategoryGroupState();
}

class _FileCategoryGroupState extends State<FileCategoryGroup> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final loc = AppLocalizations.of(context)!;
    return SettingsGroup(
      title: loc.settings_fileCategory,
      children: [
        SwitchSetting(
          text: loc.settings_automaticFileSavePathCategorization,
          switchValue: SettingsCache.automaticFileSavePathCategorization,
          onChanged: (value) => setState(
            () => SettingsCache.automaticFileSavePathCategorization = value,
          ),
        ),
        marginSizedBox,
        TextFieldSetting(
          text: loc.settings_fileCategory_video,
          width: resolveTextFieldWidth(size),
          textWidth: resolveTextWidth(size),
          txtController: TextEditingController(
              text: parseListToCsv(SettingsCache.videoFormats)),
          onChanged: (val) => setCachedFormats(
            val,
            (formats) => SettingsCache.videoFormats = formats,
          ),
        ),
        marginSizedBox,
        TextFieldSetting(
          text: loc.settings_fileCategory_music,
          width: resolveTextFieldWidth(size),
          textWidth: resolveTextWidth(size),
          txtController: TextEditingController(
              text: parseListToCsv(SettingsCache.musicFormats)),
          onChanged: (val) => setCachedFormats(
            val,
            (formats) => SettingsCache.musicFormats = formats,
          ),
        ),
        marginSizedBox,
        TextFieldSetting(
          text: loc.settings_fileCategory_archive,
          width: resolveTextFieldWidth(size),
          textWidth: resolveTextWidth(size),
          txtController: TextEditingController(
              text: parseListToCsv(SettingsCache.compressedFormats)),
          onChanged: (val) => setCachedFormats(
            val,
            (formats) => SettingsCache.compressedFormats = formats,
          ),
        ),
        marginSizedBox,
        TextFieldSetting(
          text: loc.settings_fileCategory_program,
          width: resolveTextFieldWidth(size),
          textWidth: resolveTextWidth(size),
          txtController: TextEditingController(
              text: parseListToCsv(SettingsCache.programFormats)),
          onChanged: (val) => setCachedFormats(
            val,
            (formats) => SettingsCache.programFormats = formats,
          ),
        ),
        marginSizedBox,
        TextFieldSetting(
          text: loc.settings_fileCategory_document,
          width: resolveTextFieldWidth(size),
          textWidth: resolveTextWidth(size),
          txtController: TextEditingController(
              text: parseListToCsv(SettingsCache.documentFormats)),
          onChanged: (val) => setCachedFormats(
            val,
            (formats) => SettingsCache.documentFormats = formats,
          ),
        ),
      ],
    );
  }

  double resolveTextFieldWidth(Size size) {
    double width = 400;
    if (size.width < 950) {
      width = size.width * 0.4;
    }
    if (size.width < 860) {
      width = size.width * 0.38;
    }
    if (size.width < 762) {
      width = size.width * 0.3;
    }
    if (size.width < 640) {
      width = size.width * 0.25;
    }
    return width;
  }

  double resolveTextWidth(Size size) {
    double width = 150;
    if (size.width < 950) {
      width = 90;
    }
    return width;
  }

  void setCachedFormats(
      String value, Function(List<String> formats) setCache) async {
    if (value.isEmpty) return;
    setCache(parseCsvToList(value));
  }

  Widget get marginSizedBox => const SizedBox(height: 10);
}
