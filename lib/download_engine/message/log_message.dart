import 'package:brisk/download_engine/model/download_item_model.dart';

class LogMessage {
  final DownloadItemModel downloadItem;
  final String log;

  LogMessage(this.log, this.downloadItem);
}
