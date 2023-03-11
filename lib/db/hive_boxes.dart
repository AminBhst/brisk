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
}
