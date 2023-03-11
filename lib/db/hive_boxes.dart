import 'package:brisk/model/download_queue.dart';
import 'package:hive/hive.dart';

import '../model/download_item.dart';

class HiveBoxes {
  HiveBoxes._();

  static final HiveBoxes instance = HiveBoxes._();

  late final Box<DownloadItem> downloadItemsBox;

  late final Box<DownloadQueue> downloadQueueBox;

  Future<void> openBoxes() async {
    downloadItemsBox = await Hive.openBox<DownloadItem>("download_items");
    downloadQueueBox = await Hive.openBox<DownloadQueue>("download_queues");
  }

  void putInitialBoxValues() {
    if (downloadQueueBox.get(0) != null) return;
    downloadQueueBox.put(0, DownloadQueue(name: "Main"));
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
