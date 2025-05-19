import 'package:brisk/l10n/app_localizations.dart';
import 'package:brisk/util/parse_util.dart';
import 'package:brisk/util/settings_cache.dart';
import 'package:brisk/widget/setting/base/drop_down_setting.dart';
import 'package:brisk/widget/setting/base/settings_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

class DownloadHotkeySettingsGroup extends StatefulWidget {
  const DownloadHotkeySettingsGroup({super.key});

  @override
  State<DownloadHotkeySettingsGroup> createState() =>
      _DownloadHotkeySettingsGroupState();
}

class _DownloadHotkeySettingsGroupState
    extends State<DownloadHotkeySettingsGroup> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final loc = AppLocalizations.of(context)!;
    return SettingsGroup(
      height: 310,
      title: loc.addUrlFromClipboardHotkey,
      children: [
        DropDownSetting(
          dropDownItemTextWidth: size.width * 0.17,
          value:
              SettingsCache.downloadAdditionHotkeyModifierOne?.name ?? "None",
          text: "Modifier 1",
          onChanged: (val) {
            setState(() {
              if (val == "None") {
                SettingsCache.downloadAdditionHotkeyModifierOne = null;
                return;
              }
              SettingsCache.downloadAdditionHotkeyModifierOne =
                  strToHotkeyModifier(val!);
            });
          },
          items: [...HotKeyModifier.values.map((m) => m.name).toList(), "None"],
        ),
        const SizedBox(height: 5),
        DropDownSetting(
          dropDownItemTextWidth: size.width * 0.17,
          value:
              SettingsCache.downloadAdditionHotkeyModifierTwo?.name ?? "None",
          text: "Modifier 2",
          onChanged: (val) {
            setState(() {
              if (val == "None") {
                SettingsCache.downloadAdditionHotkeyModifierTwo = null;
                return;
              }
              SettingsCache.downloadAdditionHotkeyModifierTwo =
                  strToHotkeyModifier(val!);
            });
          },
          items: [...HotKeyModifier.values.map((m) => m.name).toList(), "None"],
        ),
        const SizedBox(height: 5),
        DropDownSetting(
          dropDownItemTextWidth: size.width * 0.17,
          value:
              logicalKeyToStr(SettingsCache.downloadAdditionHotkeyLogicalKey),
          text: "Logical Key",
          onChanged: (val) {
            setState(() {
              SettingsCache.downloadAdditionHotkeyLogicalKey =
                  strToLogicalKey(val!);
            });
          },
          items: getLetterKeyLabels(),
        ),
        const SizedBox(height: 5),
        DropDownSetting(
          dropDownItemTextWidth: size.width * 0.17,
          value: SettingsCache.downloadAdditionHotkeyScope.name,
          text: "Scope",
          onChanged: (val) {
            setState(() {
              SettingsCache.downloadAdditionHotkeyScope =
                  strToHotkeyScope(val!);
            });
          },
          items: [...HotKeyScope.values.map((s) => s.name).toList()],
        ),
        const SizedBox(height: 10),
        Center(
          child: Text(
            '* ${loc.changesRequireRestart}',
            style: TextStyle(color: Colors.white),
          ),
        )
      ],
    );
  }

  List<String> getLetterKeyLabels() {
    return List.generate(26, (index) {
      final codeUnit = 0x41 + index; // 0x41 is 'A'
      final key = LogicalKeyboardKey(codeUnit);
      return key.keyLabel;
    });
  }
}
