import 'package:brisk_engine/src/download_engine/model/download_item_model.dart';

class LogMessage {
  final DownloadItemModel downloadItem;
  final String log;

  LogMessage(this.log, this.downloadItem);
}
