import 'dart:io';

import 'package:brisk/util/parse_util.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../constants/setting_options.dart';
import '../db/hive_util.dart';

Future<void> updateLaunchAtStartupSetting() async {
  final launchOnStartupEnabled = HiveUtil.instance.settingBox.values
      .where((val) =>
          parseSettingOptions(val.name) == SettingOptions.launchOnStartUp)
      .first;

  if (Platform.isMacOS) return;
  if (parseBool(launchOnStartupEnabled.value)) {
    await launchAtStartup.enable();
  } else {
    await launchAtStartup.disable();
  }
}

Future<void> setupLaunchAtStartup() async {
  if (Platform.isMacOS) return;
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  launchAtStartup.setup(
    appName: packageInfo.appName,
    appPath: Platform.resolvedExecutable,
  );
}
