import 'dart:io';

import 'package:brisk/util/parse_util.dart';
import 'package:brisk/util/platform.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:xdg_desktop_portal/xdg_desktop_portal.dart';

import '../constants/setting_options.dart';
import '../db/hive_util.dart';

bool launchedAtStartup = false;
const fromStartupArg = '--from-startup';

Future<void> updateLaunchAtStartupSetting() async {
  final launchOnStartupEnabled = HiveUtil.instance.settingBox.values
      .where((val) =>
  parseSettingOptions(val.name) == SettingOptions.launchOnStartUp)
      .first;

  if (Platform.isMacOS) return;
  if (parseBool(launchOnStartupEnabled.value)) {
    if (isFlatpak) {
      flatpakAutostart();
      return;
    }
    launchAtStartup.setup(
      appName: "brisk",
      appPath: launchCommand,
      args: launchArgs,
      /// TODO add package name when msix is supported
    );
    await launchAtStartup.enable();
  } else {
    await launchAtStartup.disable();
  }
}

void flatpakAutostart() async {
  var client = XdgDesktopPortalClient();
  final reason = 'Allow your application to autostart.';
  var result = await client.background.requestBackground(
    reason: reason,
    autostart: true,
    commandLine: ["brisk", fromStartupArg],
  ).first;
  await client.close();
}

String get launchCommand {
  if (isFlatpak) {
    return 'flatpak';
  }
  if (isSnap) {
    return "snap";
  }
  return Platform.resolvedExecutable;
}

List<String> get launchArgs {
  if (isFlatpak) {
    return ['run', 'io.github.BrisklyDev.Brisk', fromStartupArg];
  }
  if (isSnap) {
    return ['run', 'brisk', fromStartupArg];
  }
  return [fromStartupArg];
}

Future<void> setupLaunchAtStartup() async {
  if (Platform.isMacOS) return;
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  launchAtStartup.setup(
    appName: packageInfo.appName,
    appPath: Platform.resolvedExecutable,
  );
}
