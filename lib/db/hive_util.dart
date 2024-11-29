import 'package:brisk/constants/setting_options.dart';
import 'package:brisk/model/download_queue.dart';
import 'package:brisk/model/general_data.dart';
import 'package:brisk/model/setting.dart';
import 'package:brisk/util/settings_cache.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../model/download_item.dart';

class HiveUtil {
  HiveUtil._();

  static final HiveUtil instance = HiveUtil._();

  late final Box<DownloadItem> downloadItemsBox;

  late final Box<DownloadQueue> downloadQueueBox;

  late final Box<Setting> settingBox;

  late final Box<GeneralData> generalDataBox;

  Future<void> initHive() async {
    await Hive.initFlutter("Brisk_v2");
    Hive.registerAdapter(DownloadItemAdapter());
    Hive.registerAdapter(DownloadQueueAdapter());
    Hive.registerAdapter(SettingAdapter());
    Hive.registerAdapter(GeneralDataAdapter());
    await HiveUtil.instance.openBoxes();
  }

  Future<void> openBoxes() async {
    downloadItemsBox = await Hive.openBox<DownloadItem>("download_items");
    downloadQueueBox = await Hive.openBox<DownloadQueue>("download_queues");
    settingBox = await Hive.openBox<Setting>("settings");
    generalDataBox = await Hive.openBox<GeneralData>("general_data");
  }

  static Setting? getSetting(SettingOptions option) {
    return HiveUtil.instance.settingBox.values
        .where((setting) => setting.name == option.name)
        .firstOrNull;
  }

  Future<void> putInitialBoxValues() async {
    if (downloadQueueBox.get(0) == null) {
      downloadQueueBox.put(0, DownloadQueue(name: "Main"));
    }
    if (settingBox.values.length != SettingsCache.defaultSettings.length) {
      await SettingsCache.setDefaultSettings();
    }

    final appVersion = generalDataBox.values
        .where((val) => val.fieldName == "appVersion")
        .firstOrNull;
    if (appVersion == null) {
      final packageInfo = await PackageInfo.fromPlatform();
      final appVersion = await GeneralData(
        fieldName: "appVersion",
        value: packageInfo.version,
      );
      await generalDataBox.add(appVersion);
      await SettingsCache.resetDefault();
    } else {
      await performRequiredAppVersionUpdates();
    }
  }

  /// To be used for specific cases where some db values need to be updated
  /// based on specific version bumps
  Future<void> performRequiredAppVersionUpdates() async {
    if (getAppVersionData().value == "2.0.0") {
      await migrateV2_0_2();
    }
  }

  GeneralData getAppVersionData() {
    return generalDataBox.values
        .where((element) => element.fieldName == "appVersion")
        .first;
  }

  Future<void> migrateV2_0_2() async {
    final loggerEnabled =
        SettingsCache.defaultSettings[SettingOptions.loggerEnabled.name]!;
    final fileSavePathRules =
        SettingsCache.defaultSettings[SettingOptions.fileSavePathRules.name]!;
    final extensionSkipCaptureRule = SettingsCache
        .defaultSettings[SettingOptions.extensionSkipCaptureRules.name]!;
    final newSettings = [
      Setting(
        name: SettingOptions.loggerEnabled.name,
        value: loggerEnabled[0],
        settingType: loggerEnabled[1],
      ),
      Setting(
        name: SettingOptions.fileSavePathRules.name,
        value: fileSavePathRules[0],
        settingType: fileSavePathRules[1],
      ),
      Setting(
        name: SettingOptions.extensionSkipCaptureRules.name,
        value: extensionSkipCaptureRule[0],
        settingType: extensionSkipCaptureRule[1],
      )
    ];
    await settingBox.addAll(newSettings);
    final appVersion = getAppVersionData();
    appVersion.value = "2.0.2";
    await appVersion.save();
  }

  Future<void> addDownloadItem(DownloadItem downloadItem) async {
    await downloadItemsBox.add(downloadItem);
    final mainQueue = downloadQueueBox.get(0)!;
    mainQueue.downloadItemsIds ??= [];
    mainQueue.downloadItemsIds!.add(downloadItem.key);
    await mainQueue.save();
  }

  Future<void> removeDownloadFromQueues(int key) async {
    final queues = downloadQueueBox.values
        .where((queue) =>
            queue.downloadItemsIds != null &&
            queue.downloadItemsIds!.contains(key))
        .toList();
    for (final queue in queues) {
      queue.downloadItemsIds?.removeWhere((id) => id == key);
      await queue.save();
    }
  }
}
