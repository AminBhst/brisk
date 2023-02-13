import 'package:brisk/constants/file_duplication_behaviour.dart';
import 'package:brisk/widget/setting/base/drop_down_setting.dart';
import 'package:brisk/widget/setting/base/settings_group.dart';
import 'package:flutter/material.dart';

import '../../../../util/settings_cache.dart';

class FileBehaviourGroup extends StatefulWidget {
  const FileBehaviourGroup({super.key});

  static const dropDownAskStr = "Always ask";
  static const dropDownSkipStr = "Skip download";
  static const dropDownSuffixStr = "Suffix new file with [_version]";

  @override
  State<FileBehaviourGroup> createState() => _FileBehaviourGroupState();
}

class _FileBehaviourGroupState extends State<FileBehaviourGroup> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SettingsGroup(
      title: "Behaviour",
      children: [
        DropDownSetting(
          dropDownWidth: size.width * 0.2,
          textWidth: size.width * 0.15,
          dropDownItemTextWidth: size.width * 0.17,
          value: _actionToDropDownTxt(SettingsCache.fileDuplicationBehaviour),
          text: "Duplicate download action",
          onChanged: _onDropDownChanged,
          items: const [
            FileBehaviourGroup.dropDownSuffixStr,
            FileBehaviourGroup.dropDownSkipStr,
            FileBehaviourGroup.dropDownAskStr,
          ],
        )
      ],
    );
  }

  void _onDropDownChanged(String? value) {
    if (value == null || value.isEmpty) return;
    final behaviour = _dropDownTxtToBehaviour(value);
    setState(() => SettingsCache.fileDuplicationBehaviour = behaviour);
  }

  String _actionToDropDownTxt(FileDuplicationBehaviour behaviour) {
    switch (behaviour) {
      case FileDuplicationBehaviour.ask:
        return FileBehaviourGroup.dropDownAskStr;
      case FileDuplicationBehaviour.skip:
        return FileBehaviourGroup.dropDownSkipStr;
      case FileDuplicationBehaviour.suffix:
        return FileBehaviourGroup.dropDownSuffixStr;
    }
  }

  FileDuplicationBehaviour _dropDownTxtToBehaviour(String txt) {
    switch (txt) {
      case FileBehaviourGroup.dropDownAskStr:
        return FileDuplicationBehaviour.ask;
      case FileBehaviourGroup.dropDownSkipStr:
        return FileDuplicationBehaviour.skip;
      case FileBehaviourGroup.dropDownSuffixStr:
        return FileDuplicationBehaviour.suffix;
      default:
        return FileDuplicationBehaviour.ask;
    }
  }
}
