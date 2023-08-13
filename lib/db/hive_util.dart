import 'package:brisk/model/download_queue.dart';
import 'package:brisk/model/setting.dart';
import 'package:brisk/util/settings_cache.dart';
import 'package:hive_flutter/adapters.dart';

import '../model/download_item.dart';

class HiveUtil {
  HiveUtil._();

  static final HiveUtil instance = HiveUtil._();

  late final Box<DownloadItem> downloadItemsBox;

  late final Box<DownloadQueue> downloadQueueBox;

  late final Box<Setting> settingBox;


  Future<void> initHive() async {
    await Hive.initFlutter("Brisk");
    Hive.registerAdapter(DownloadItemAdapter());
    Hive.registerAdapter(DownloadQueueAdapter());
    Hive.registerAdapter(SettingAdapter());
    await HiveUtil.instance.openBoxes();
  }

  Future<void> openBoxes() async {
    downloadItemsBox = await Hive.openBox<DownloadItem>("download_items");
    downloadQueueBox = await Hive.openBox<DownloadQueue>("download_queues");
    settingBox = await Hive.openBox<Setting>("settings");
  }

  Future<void> putInitialBoxValues() async {
    if (downloadQueueBox.get(0) == null) {
      downloadQueueBox.put(0, DownloadQueue(name: "Main"));
    }
    if (settingBox.values.length != SettingsCache.defaultSettings.length) {
      await SettingsCache.setDefaultSettings();
    }
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
