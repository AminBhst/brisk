import 'package:brisk/db/hive_boxes.dart';
import 'package:brisk/model/download_queue.dart';
import 'package:flutter/cupertino.dart';

class QueueProvider with ChangeNotifier {
  bool queueTabSelected = false;
  bool downloadQueueTopMenu = false;
  bool queueTopMenu = false;
  int? selectedQueueId;

  void setQueueTopMenu(bool value) {
    queueTopMenu = value;
    notifyListeners();
  }

  void setQueueTabSelected(bool value) {
    queueTabSelected = value;
    notifyListeners();
  }

  void setSelectedQueue(int? queueId) {
    selectedQueueId = queueId;
    notifyListeners();
  }

  void setDownloadQueueTopMenu(bool value) {
    downloadQueueTopMenu = value;
    notifyListeners();
  }

  Future<void> deleteQueue(DownloadQueue queue) async {
    await queue.delete();
    notifyListeners();
  }

  Future<void> saveQueue(DownloadQueue queue) async {
    await HiveBoxes.instance.downloadQueueBox.add(queue);
    notifyListeners();
  }

  void notifyListeners() => super.notifyListeners();
}
