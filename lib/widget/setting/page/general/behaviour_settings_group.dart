import 'package:brisk/constants/app_closure_behaviour.dart';
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
  static const dropDownAskStr = "Always Ask";
  static const dropDownSkipStr = "Skip Download";
  static const dropDownAddStr = "Add New";
  static const dropDownUpdateUrlSTr = "Update URL";

  static const dropDownExitStr = "Exit";
  static const dropDownMinimizeToTrayStr = "Minimize to Tray";

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SettingsGroup(
      height: 300,
      title: "Behavior",
      children: [
        SwitchSetting(
          text: "Launch at startup",
          switchValue: SettingsCache.launchOnStartUp,
          onChanged: (val) =>
              setState(() => SettingsCache.launchOnStartUp = val),
        ),
        const SizedBox(height: 5),
        const SizedBox(height: 5),
        SwitchSetting(
          text: "Open download progress window when a new download starts",
          switchValue: SettingsCache.openDownloadProgressWindow,
          onChanged: (val) =>
              setState(() => SettingsCache.openDownloadProgressWindow = val),
        ),
        const SizedBox(height: 5),
        DropDownSetting(
          dropDownItemTextWidth: size.width * 0.17,
          value: _appClosureActionToDropDownTxt(
            SettingsCache.appClosureBehaviour,
          ),
          text: "App closure behavior",
          onChanged: _onAppClosureDropDownChanged,
          items: const [
            dropDownMinimizeToTrayStr,
            dropDownExitStr,
            dropDownAskStr,
          ],
        ),
        const SizedBox(height: 5),
        DropDownSetting(
          dropDownItemTextWidth: size.width * 0.17,
          value: _fileDuplicationActionToDropDownTxt(
            SettingsCache.fileDuplicationBehaviour,
          ),
          text: "Duplicate download action",
          onChanged: _onFileDuplicationDropDownChanged,
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

  String _fileDuplicationActionToDropDownTxt(
      FileDuplicationBehaviour behaviour) {
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

  String _appClosureActionToDropDownTxt(AppClosureBehaviour behaviour) {
    switch (behaviour) {
      case AppClosureBehaviour.ask:
        return dropDownAskStr;
      case AppClosureBehaviour.exit:
        return dropDownExitStr;
      case AppClosureBehaviour.minimizeToTray:
        return dropDownMinimizeToTrayStr;
    }
  }

  void _onFileDuplicationDropDownChanged(String? value) {
    if (value == null || value.isEmpty) return;
    final behaviour = _fileDuplicationDropDownTxtToBehaviour(value);
    setState(() => SettingsCache.fileDuplicationBehaviour = behaviour);
  }

  void _onAppClosureDropDownChanged(String? value) {
    if (value == null || value.isEmpty) return;
    final behaviour = _appClosureDropDownTxtToBehaviour(value);
    setState(() => SettingsCache.appClosureBehaviour = behaviour);
  }

  AppClosureBehaviour _appClosureDropDownTxtToBehaviour(String txt) {
    switch (txt) {
      case dropDownAskStr:
        return AppClosureBehaviour.ask;
      case dropDownExitStr:
        return AppClosureBehaviour.exit;
      case dropDownMinimizeToTrayStr:
        return AppClosureBehaviour.minimizeToTray;
      default:
        return AppClosureBehaviour.ask;
    }
  }

  FileDuplicationBehaviour _fileDuplicationDropDownTxtToBehaviour(String txt) {
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
