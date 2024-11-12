import 'dart:convert';
import 'dart:io';
import 'package:brisk/constants/setting_options.dart';
import 'package:brisk/constants/setting_type.dart';
import 'package:brisk/db/hive_util.dart';
import 'package:brisk/model/setting.dart';
import 'package:brisk/util/parse_util.dart';
import 'package:brisk/widget/base/confirmation_dialog.dart';
import 'package:brisk/widget/base/error_dialog.dart';
import 'package:brisk/widget/base/info_dialog.dart';
import 'package:brisk/widget/other/brisk_change_log_dialog.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:window_manager/window_manager.dart';
import 'package:http/http.dart';

import 'http_util.dart';

void handleBriskUpdateCheck(
  BuildContext context, {
  bool showUpdateNotAvailableDialog = false,
}) async {
  final isNewVersionAvailable = await isNewBriskVersionAvailable();
  if (isNewVersionAvailable) {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title:
            "New version of Brisk is available! Do you want Brisk to automatically download and install the latest version?",
        onConfirmPressed: launchAutoUpdater,
      ),
    );
  } else {
    if (showUpdateNotAvailableDialog) {
      showDialog(
        context: context,
        builder: (context) => InfoDialog(
          title: "No new update is available yet",
          onConfirmPressed: launchAutoUpdater,
        ),
      );
      return;
    }
  }

  final updateRequested = HiveUtil.getSetting(SettingOptions.updateRequested);
  final preUpdateVersion = HiveUtil.getSetting(SettingOptions.preUpdateVersion);
  if (updateRequested == null ||
      preUpdateVersion == null ||
      !parseBool(updateRequested.value)) return;

  final currentVersion = (await PackageInfo.fromPlatform()).version;
  if (preUpdateVersion != currentVersion) {
    String changeLog = await getLatestVersionChangeLog();
    showDialog(
      context: context,
      builder: (context) => BriskChangeLogDialog(
        updatedVersion: currentVersion,
        changeLog: changeLog,
      ),
      barrierDismissible: false,
    );
  } else {
    showDialog(
        context: context,
        builder: (context) => ErrorDialog(
              width: 500,
              height: 70,
              textHeight: 30,
              textSpaceBetween: 10,
              text:
                  "Update Failed! Please manually download and install the latest version.",
            ));
  }
  await updateRequested
    ..value = "false"
    ..save();
}

Future<String> getLatestVersionChangeLog() async {
  final response = await Client().get(
    Uri.parse(
        "https://raw.githubusercontent.com/AminBhst/brisk/refs/heads/main/.github/release.md"),
  );
  return utf8.decode(response.bodyBytes);
}

void launchAutoUpdater() {
  String executablePath = Platform.resolvedExecutable;
  if (Platform.isWindows) {
    setUpdateRequested();
    final updaterPath = join(
      Directory(executablePath).parent.path,
      "updater",
      "brisk_auto_updater.exe",
    );
    String command = 'Start-Process -FilePath "$updaterPath" -Verb RunAs';
    Process.run('powershell', ['-command', command], runInShell: true).then(
      (_) {
        windowManager.destroy().then((value) => exit(0));
      },
    );
  } else if (Platform.isLinux) {
    setUpdateRequested();
    final updaterPath = join(
      Directory(executablePath).parent.path,
      "updater",
      "brisk_auto_updater",
    );
    Process.start(
      updaterPath,
      [],
      mode: ProcessStartMode.detached,
    ).then((_) {
      windowManager.destroy().then((value) => exit(0));
    });
  } else {
    launchUrlString(
      "https://github.com/AminBhst/brisk/releases/latest",
    );
  }
}

void setUpdateRequested() async {
  var updateRequested = HiveUtil.getSetting(SettingOptions.updateRequested);
  var preUpdateVersion = HiveUtil.getSetting(SettingOptions.preUpdateVersion);
  final currentVersion = (await PackageInfo.fromPlatform()).version;
  if (updateRequested == null) {
    updateRequested = Setting(
      name: "updateRequested",
      value: "true",
      settingType: SettingType.system.name,
    );
    preUpdateVersion = Setting(
      name: "preUpdateVersion",
      value: currentVersion,
      settingType: SettingType.system.name,
    );
    await HiveUtil.instance.settingBox.add(updateRequested);
    await HiveUtil.instance.settingBox.add(preUpdateVersion);
    return;
  }
  updateRequested.value = "true";
  preUpdateVersion!.value = currentVersion;
  await updateRequested.save();
  await preUpdateVersion.save();
}
