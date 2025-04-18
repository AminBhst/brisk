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
import 'package:brisk/widget/download/update_available_dialog.dart';
import 'package:brisk/widget/other/brisk_change_log_dialog.dart';
import 'package:dartx/dartx.dart';
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
  bool ignoreLastUpdateCheck = false,
}) async {
  Pair<bool, String> versionCheckResult;
  try {
    versionCheckResult = await isNewBriskVersionAvailable(
      ignoreLastUpdateCheck: ignoreLastUpdateCheck,
    );
  } catch (e) {
    showDialog(
      context: context,
      builder: (context) => ErrorDialog(
        title: "Check for Update Failed",
        description: e.toString(),
        height: 100,
        width: 400,
      ),
    );
    return;
  }
  if (versionCheckResult.first) {
    final changeLog = await getLatestVersionChangeLog(
      removeChangeLogHeader: true,
    );
    showDialog(
      context: context,
      builder: (context) => UpdateAvailableDialog(
        newVersion: versionCheckResult.second,
        changeLog: changeLog,
        onUpdatePressed: launchAutoUpdater,
      ),
    );
  } else {
    if (showUpdateNotAvailableDialog) {
      showDialog(
        context: context,
        builder: (context) => InfoDialog(
          titleIcon: Icon(
            Icons.info,
            color: Colors.blueAccent,
          ),
          titleIconBackgroundColor: Colors.black12,
          titleText: "No new update is available yet",
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
  if (preUpdateVersion.value != currentVersion) {
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
      barrierDismissible: false,
      builder: (context) => ConfirmationDialog(
        title: "Update Failed",
        width: 500,
        description:
            "Failed to automatically update brisk to the latest version!\nWould you like to manually download the latest version?",
        confirmButtonText: "Yes, Take me there",
        confirmButtonWidth: 150,
        onConfirmPressed: () => launchUrlString(
            "https://github.com/AminBhst/brisk/releases/latest"),
      ),
    );
  }
  await updateRequested
    ..value = "false"
    ..save();
}

Future<String> getLatestVersionChangeLog({
  bool removeChangeLogHeader = false,
  bool browserExtension = false,
}) async {
  String url =
      "https://raw.githubusercontent.com/AminBhst/brisk/refs/heads/main/.github/${browserExtension ? "extension_release.md" : "release.md"}";
  final response = await Client().get(Uri.parse(url));
  final changeLog = utf8.decode(response.bodyBytes);
  if (removeChangeLogHeader) {
    final lines = changeLog.split('\n');
    if (lines.isNotEmpty && lines.first.contains("Change Log")) {
      lines.removeAt(0);
    }
    return lines.join('\n');
  }
  return changeLog;
}

void launchAutoUpdater() async {
  String executablePath = Platform.resolvedExecutable;
  if (Platform.isWindows) {
    await setUpdateRequested();
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
    await setUpdateRequested();
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

Future<void> setUpdateRequested() async {
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
