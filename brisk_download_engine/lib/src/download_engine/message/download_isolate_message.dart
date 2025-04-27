import 'package:brisk_download_engine/brisk_download_engine.dart';
import 'package:brisk_download_engine/src/download_engine/download_type.dart';
import 'package:brisk_download_engine/src/download_engine/message/http_download_isolate_message.dart';
import 'package:brisk_download_engine/src/download_engine/message/m3u8_download_isolate_message.dart';

abstract class DownloadIsolateMessage {
  int? connectionNumber;
  DownloadCommand command;
  DownloadItemModel downloadItem;
  DownloadSettings settings;

  DownloadIsolateMessage({
    required this.command,
    required this.downloadItem,
    required this.settings,
    this.connectionNumber,
  });

  factory DownloadIsolateMessage.createFromDownloadType({
    required DownloadType downloadType,
    required DownloadCommand command,
    required DownloadItemModel downloadItem,
    required DownloadSettings settings,
  }) {
    if (downloadType == DownloadType.m3u8) {
      return M3u8DownloadIsolateMessage(
        command: command,
        downloadItem: downloadItem,
        settings: settings,
        refererHeader: downloadItem.refererHeader,
      );
    } else {
      return HttpDownloadIsolateMessage(
        command: command,
        downloadItem: downloadItem,
        settings: settings,
      );
    }
  }

  DownloadIsolateMessage clone();
}
