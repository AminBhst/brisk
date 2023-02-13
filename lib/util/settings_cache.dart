import 'dart:io';

import 'package:brisk/constants/file_duplication_behaviour.dart';
import 'package:brisk/constants/setting_options.dart';
import 'package:brisk/constants/setting_type.dart';
import 'package:brisk/dao/setting_dao.dart';
import 'package:brisk/db/db_provider.dart';
import 'package:brisk/util/file_extensions.dart';
import 'package:brisk/util/file_util.dart';
import 'package:brisk/util/parse_util.dart';

class SettingsCache {
  /// General
  static late bool notificationOnDownloadCompletion;
  static late bool notificationOnDownloadFailure;
  static late bool launchOnStartUp;
  static late bool minimizeToTrayOnClose;
  static late bool openDownloadProgressWindow;

  /// File
  static late Directory temporaryDir;
  static late Directory saveDir;
  static late List<String> videoFormats;
  static late List<String> musicFormats;
  static late List<String> documentFormats;
  static late List<String> compressedFormats;
  static late List<String> programFormats;
  static late FileDuplicationBehaviour fileDuplicationBehaviour;

  // Connection
  static late int connectionsNumber;
  static late int connectionRetryCount;
  static late int connectionRetryTimeout;

  static final Map<String, List<String>> defaultSettings = {
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
    SettingOptions.minimizeToTrayOnClose.name: [
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
    ]
  };

  static Future<void> setCachedSettings() async {
    final settings = await SettingDao.instance.getAll();
    for (var setting in settings) {
      final value = setting.value;
      switch (parseSettingOptions(setting.name)) {
        case SettingOptions.notificationOnDownloadCompletion:
          notificationOnDownloadCompletion = parseBool(value);
          break;
        case SettingOptions.notificationOnDownloadFailure:
          notificationOnDownloadFailure = parseBool(value);
          break;
        case SettingOptions.launchOnStartUp:
          launchOnStartUp = parseBool(value);
          break;
        case SettingOptions.minimizeToTrayOnClose:
          minimizeToTrayOnClose = parseBool(value);
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
        case SettingOptions.connectionsNumber:
          connectionsNumber = int.parse(value);
          break;
        case SettingOptions.connectionRetryCount:
          connectionRetryCount = int.parse(value);
          break;
        case SettingOptions.connectionRetryTimeout:
          connectionRetryTimeout = int.parse(value);
          break;
        default:
      }
    }
  }

  static void saveCachedSettingsToDB() async {
    final allSettings = await SettingDao.instance.getAll();
    for (var setting in allSettings) {
      switch (parseSettingOptions(setting.name)) {
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
        case SettingOptions.minimizeToTrayOnClose:
          setting.value = parseBoolStr(SettingsCache.minimizeToTrayOnClose);
          break;
        case SettingOptions.openDownloadProgressWindow:
          setting.value = parseBoolStr(SettingsCache.openDownloadProgressWindow);
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
        case SettingOptions.connectionsNumber:
          setting.value = SettingsCache.connectionsNumber.toString();
          break;
        case SettingOptions.connectionRetryCount:
          setting.value = SettingsCache.connectionRetryCount.toString();
          break;
        case SettingOptions.connectionRetryTimeout:
          setting.value = SettingsCache.connectionRetryTimeout.toString();
          break;
        default:
      }
      await SettingDao.instance.update(setting);
    }
  }

  static Future<void> resetDefault() async {
    await SettingDao.instance.deleteAllRows();
    await DBProvider.instance.getDB(init: true);
    await setCachedSettings();
  }
}
