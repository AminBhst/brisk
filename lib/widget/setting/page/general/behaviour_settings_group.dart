import 'package:brisk/widget/setting/base/settings_group.dart';
import 'package:brisk/widget/setting/base/switch_setting.dart';
import 'package:flutter/material.dart';

import '../../../../constants/file_duplication_behaviour.dart';
import '../../../../util/settings_cache.dart';
import '../../base/drop_down_setting.dart';

class BehaviourSettingsGroup extends StatefulWidget {
  const BehaviourSettingsGroup({super.key});

  @override
  State<BehaviourSettingsGroup> createState() => _BehaviourSettingsGroupState();
}

class _BehaviourSettingsGroupState extends State<BehaviourSettingsGroup> {
  static const dropDownAskStr = "Always ask";
  static const dropDownSkipStr = "Skip download";
  static const dropDownAddStr = "Add new";
  static const dropDownUpdateUrlSTr = "Update URL";

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SettingsGroup(
      title: "Behaviour",
      children: [
        // SwitchSetting(
        //   text: "Launch on startup",
        //   switchValue: SettingsCache.launchOnStartUp,
        //   // onChanged: (val) =>
        //   //     setState(() => SettingsCache.launchOnStartUp = val),
        // ),
        // SwitchSetting(
        //   text: "Minimize to tray on close",
        //   switchValue: SettingsCache.minimizeToTrayOnClose,
        //   // onChanged: (val) =>
        //   //     setState(() => SettingsCache.minimizeToTrayOnClose = val),
        // ),
        SwitchSetting(
          text: "Open download progress window when a new download has started",
          switchValue: SettingsCache.openDownloadProgressWindow,
          onChanged: (val) =>
              setState(() => SettingsCache.openDownloadProgressWindow = val),
        ),
        const SizedBox(height: 5),
        DropDownSetting(
          dropDownWidth: size.width * 0.2,
          textWidth: size.width * 0.15,
          dropDownItemTextWidth: size.width * 0.17,
          value: _actionToDropDownTxt(SettingsCache.fileDuplicationBehaviour),
          text: "Duplicate download action",
          onChanged: _onDropDownChanged,
          items: const [
            dropDownAddStr,
            dropDownUpdateUrlSTr,
            dropDownSkipStr,
            dropDownAskStr,
          ],
        )
      ],
    );
  }

  String _actionToDropDownTxt(FileDuplicationBehaviour behaviour) {
    switch (behaviour) {
      case FileDuplicationBehaviour.ask:
        return dropDownAskStr;
      case FileDuplicationBehaviour.skip:
        return dropDownSkipStr;
      case FileDuplicationBehaviour.updateUrl:
        return dropDownUpdateUrlSTr;
      case FileDuplicationBehaviour.add:
        return dropDownAddStr;
    }
  }

  void _onDropDownChanged(String? value) {
    if (value == null || value.isEmpty) return;
    final behaviour = _dropDownTxtToBehaviour(value);
    setState(() => SettingsCache.fileDuplicationBehaviour = behaviour);
  }

  FileDuplicationBehaviour _dropDownTxtToBehaviour(String txt) {
    switch (txt) {
      case dropDownAskStr:
        return FileDuplicationBehaviour.ask;
      case dropDownSkipStr:
        return FileDuplicationBehaviour.skip;
      case dropDownAddStr:
        return FileDuplicationBehaviour.add;
      case dropDownUpdateUrlSTr:
        return FileDuplicationBehaviour.updateUrl;
      default:
        return FileDuplicationBehaviour.ask;
    }
  }
}
