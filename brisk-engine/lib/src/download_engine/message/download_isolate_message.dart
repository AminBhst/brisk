import 'package:brisk_engine/src/download_engine/download_command.dart';
import 'package:brisk_engine/src/download_engine/download_settings.dart';
import 'package:brisk_engine/src/download_engine/model/download_item_model.dart';
import 'package:brisk_engine/src/download_engine/segment/segment.dart';

class DownloadIsolateMessage {
  int? connectionNumber;
  DownloadCommand command;
  DownloadItemModel downloadItem;
  Segment? segment;
  DownloadSettings settings;
  int previouslyWrittenByteLength;

  DownloadIsolateMessage({
    required this.command,
    required this.downloadItem,
    required this.settings,
    this.connectionNumber,
    this.segment,
    this.previouslyWrittenByteLength = 0,
  });

  DownloadIsolateMessage clone() {
    return DownloadIsolateMessage(
      command: this.command,
      downloadItem: this.downloadItem,
      segment: this.segment,
      connectionNumber: this.connectionNumber,
      settings: this.settings,
    );
  }
}
