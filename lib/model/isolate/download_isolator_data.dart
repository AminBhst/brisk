import 'package:brisk/download_engine/download_command.dart';
import 'package:brisk/download_engine/segment.dart';
import 'package:brisk/model/download_item_model.dart';
import 'package:brisk/download_engine/download_settings.dart';

class DownloadIsolateData {
  int? connectionNumber;
  DownloadCommand command;
  DownloadItemModel downloadItem;
  Segment? segment;
  DownloadSettings settings;

  DownloadIsolateData({
    required this.command,
    required this.downloadItem,
    required this.settings,
    this.connectionNumber,
    this.segment,
  });

  DownloadIsolateData clone() {
    return DownloadIsolateData(
      command: this.command,
      downloadItem: this.downloadItem,
      segment: this.segment,
      connectionNumber: this.connectionNumber,
      settings: this.settings,
    );
  }
}
