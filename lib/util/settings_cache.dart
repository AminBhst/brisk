import 'dart:io';

import 'package:brisk/constants/app_closure_behaviour.dart';
import 'package:brisk/constants/file_duplication_behaviour.dart';
import 'package:brisk/constants/setting_options.dart';
import 'package:brisk/constants/setting_type.dart';
import 'package:brisk/db/hive_util.dart';
import 'package:brisk/model/setting.dart';
import 'package:brisk/theme/application_theme_holder.dart';
import 'package:brisk/util/file_extensions.dart';
import 'package:brisk/util/launch_at_startup_util.dart';
import 'package:brisk/util/parse_util.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'file_util.dart';

class SettingsCache {
  static late String currentVersion;

  /// General
  static late String applicationThemeId;
  static late bool notificationOnDownloadCompletion;
  static late bool notificationOnDownloadFailure;
  static late bool launchOnStartUp;
  static late bool openDownloadProgressWindow;
  static late bool enableWindowToFront;
  static late int extensionPort;
  static late bool loggerEnabled;

  /// File
  static late Directory temporaryDir;
  static late Directory saveDir;
  static late List<String> videoFormats;
  static late List<String> musicFormats;
  static late List<String> documentFormats;
  static late List<String> compressedFormats;
  static late List<String> programFormats;
  static late FileDuplicationBehaviour fileDuplicationBehaviour;
  static late AppClosureBehaviour appClosureBehaviour;

  // Connection
  static late int connectionsNumber;
  static late int connectionRetryCount;
  static late int connectionRetryTimeout;

  static final Map<String, List<String>> defaultSettings = {
    SettingOptions.applicationThemeId.name: [
      SettingType.general.name,
      ApplicationThemeHolder.themes.first.themeId,
    ],
    SettingOptions.notificationOnDownloadCompletion.name: [
      SettingType.general.name,
      "false",
    ],
    SettingOptions.notificationOnDownloadFailure.name: [
      SettingType.general.name,
      "true",
    ],
    SettingOptions.launchOnStartUp.name: [
      SettingType.general.name,
      "false",
    ],
    SettingOptions.openDownloadProgressWindow.name: [
      SettingType.general.name,
      "true",
    ],
    SettingOptions.temporaryPath.name: [
      SettingType.file.name,
      FileUtil.defaultTempFileDir.path,
    ],
    SettingOptions.savePath.name: [
      SettingType.file.name,
      FileUtil.defaultSaveDir.path,
    ],
    SettingOptions.videoFormats.name: [
      SettingType.file.name,
      parseListToCsv(FileExtensions.video),
    ],
    SettingOptions.musicFormats.name: [
      SettingType.file.name,
      parseListToCsv(FileExtensions.music),
    ],
    SettingOptions.compressedFormats.name: [
      SettingType.file.name,
      parseListToCsv(FileExtensions.compressed),
    ],
    SettingOptions.documentFormats.name: [
      SettingType.file.name,
      parseListToCsv(FileExtensions.document),
    ],
    SettingOptions.programFormats.name: [
      SettingType.file.name,
      parseListToCsv(FileExtensions.program),
    ],
    SettingOptions.fileDuplicationBehaviour.name: [
      SettingType.file.name,
      FileDuplicationBehaviour.ask.name,
    ],
    SettingOptions.appClosureBehaviour.name: [
      SettingType.general.name,
      AppClosureBehaviour.ask.name,
    ],
    SettingOptions.loggerEnabled.name: [SettingType.general.name, "false"],
    SettingOptions.connectionsNumber.name: [
      SettingType.connection.name,
      "8",
    ],
    SettingOptions.connectionRetryCount.name: [
      SettingType.connection.name,
      "-1",
    ],
    SettingOptions.connectionRetryTimeout.name: [
      SettingType.connection.name,
      "10",
    ],
    SettingOptions.enableWindowToFront.name: [
      SettingType.extension.name,
      "true",
    ],
    SettingOptions.extensionPort.name: [
      SettingType.extension.name,
      "3020",
    ],
    SettingOptions.lastUpdateCheck.name: [
      SettingType.system.name,
      "0",
    ]
  };

  static Future<void> setCachedSettings() async {
    final settings = HiveUtil.instance.settingBox.values;
    for (var setting in settings) {
      final value = setting.value;
      switch (parseSettingOptions(setting.name)) {
        case SettingOptions.applicationThemeId:
          applicationThemeId = value.toString();
          break;
        case SettingOptions.notificationOnDownloadCompletion:
          notificationOnDownloadCompletion = parseBool(value);
          break;
        case SettingOptions.notificationOnDownloadFailure:
          notificationOnDownloadFailure = parseBool(value);
          break;
        case SettingOptions.launchOnStartUp:
          launchOnStartUp = parseBool(value);
          break;
        case SettingOptions.openDownloadProgressWindow:
          openDownloadProgressWindow = parseBool(value);
          break;
        case SettingOptions.temporaryPath:
          temporaryDir = Directory(value);
          break;
        case SettingOptions.savePath:
          saveDir = Directory(value);
          break;
        case SettingOptions.videoFormats:
          videoFormats = parseCsvToList(value);
          break;
        case SettingOptions.musicFormats:
          musicFormats = parseCsvToList(value);
          break;
        case SettingOptions.compressedFormats:
          compressedFormats = parseCsvToList(value);
          break;
        case SettingOptions.documentFormats:
          documentFormats = parseCsvToList(value);
          break;
        case SettingOptions.programFormats:
          programFormats = parseCsvToList(value);
          break;
        case SettingOptions.fileDuplicationBehaviour:
          fileDuplicationBehaviour = parseFileDuplicationBehaviour(value);
          break;
        case SettingOptions.appClosureBehaviour:
          appClosureBehaviour = parseAppCloseBehaviour(value);
          break;
        case SettingOptions.loggerEnabled:
          loggerEnabled = parseBool(value);
          break;
        case SettingOptions.connectionsNumber:
          connectionsNumber = int.parse(value);
          break;
        case SettingOptions.connectionRetryCount:
          connectionRetryCount = int.parse(value);
          break;
        case SettingOptions.connectionRetryTimeout:
          connectionRetryTimeout = int.parse(value);
          break;
        case SettingOptions.enableWindowToFront:
          enableWindowToFront = parseBool(value);
          break;
        case SettingOptions.extensionPort:
          extensionPort = int.parse(value);
          break;
        default:
      }
    }
    currentVersion = (await PackageInfo.fromPlatform()).version;
  }

  static Future<void> saveCachedSettingsToDB() async {
    final allSettings = HiveUtil.instance.settingBox.values;
    for (var setting in allSettings) {
      switch (parseSettingOptions(setting.name)) {
        case SettingOptions.applicationThemeId:
          setting.value = SettingsCache.applicationThemeId.toString();
        case SettingOptions.notificationOnDownloadCompletion:
          setting.value =
              parseBoolStr(SettingsCache.notificationOnDownloadCompletion);
          break;
        case SettingOptions.notificationOnDownloadFailure:
          setting.value =
              parseBoolStr(SettingsCache.notificationOnDownloadFailure);
          break;
        case SettingOptions.launchOnStartUp:
          setting.value = parseBoolStr(SettingsCache.launchOnStartUp);
          break;
        case SettingOptions.openDownloadProgressWindow:
          setting.value =
              parseBoolStr(SettingsCache.openDownloadProgressWindow);
          break;
        case SettingOptions.loggerEnabled:
          setting.value = parseBoolStr(SettingsCache.loggerEnabled);
          break;
        case SettingOptions.temporaryPath:
          setting.value = SettingsCache.temporaryDir.path;
          break;
        case SettingOptions.savePath:
          setting.value = SettingsCache.saveDir.path;
          break;
        case SettingOptions.videoFormats:
          setting.value = parseListToCsv(SettingsCache.videoFormats);
          break;
        case SettingOptions.musicFormats:
          setting.value = parseListToCsv(musicFormats);
          break;
        case SettingOptions.compressedFormats:
          setting.value = parseListToCsv(compressedFormats);
          break;
        case SettingOptions.documentFormats:
          setting.value = parseListToCsv(documentFormats);
          break;
        case SettingOptions.programFormats:
          setting.value = parseListToCsv(programFormats);
          break;
        case SettingOptions.fileDuplicationBehaviour:
          setting.value = SettingsCache.fileDuplicationBehaviour.name;
          break;
        case SettingOptions.appClosureBehaviour:
          setting.value = SettingsCache.appClosureBehaviour.name;
          break;
        case SettingOptions.connectionsNumber:
          setting.value = SettingsCache.connectionsNumber.toString();
          break;
        case SettingOptions.connectionRetryCount:
          setting.value = SettingsCache.connectionRetryCount.toString();
          break;
        case SettingOptions.connectionRetryTimeout:
          setting.value = SettingsCache.connectionRetryTimeout.toString();
          break;
        case SettingOptions.enableWindowToFront:
          setting.value = parseBoolStr(SettingsCache.enableWindowToFront);
          break;
        case SettingOptions.extensionPort:
          setting.value = SettingsCache.extensionPort.toString();
          break;
        default:
      }
      await setting.save();
      await performRequiredUpdates();
    }
  }

  static Future<void> performRequiredUpdates() async {
    await updateLaunchAtStartupSetting();
  }

  static Future<void> resetDefault() async {
    HiveUtil.instance.settingBox.values
        .forEach((setting) async => await setting.delete());
    await setDefaultSettings();
    await setCachedSettings();
  }

  static Future<void> setDefaultSettings() async {
    defaultSettings["savePath"]![1] = FileUtil.defaultSaveDir.path;
    defaultSettings["temporaryPath"]![1] = FileUtil.defaultTempFileDir.path;
    for (int i = 0; i < defaultSettings.length; i++) {
      final key = defaultSettings.keys.elementAt(i);
      final value = defaultSettings[key]!;
      final setting = Setting(
        name: key,
        value: value[1],
        settingType: value[0],
      );
      await HiveUtil.instance.settingBox.put(i, setting);
    }
  }
}
