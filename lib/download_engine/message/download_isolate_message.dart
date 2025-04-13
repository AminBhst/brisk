import 'package:brisk/constants/download_type.dart';
import 'package:brisk/download_engine/download_command.dart';
import 'package:brisk/download_engine/message/http_download_isolate_message.dart';
import 'package:brisk/download_engine/message/m3u8_download_isolate_message.dart';
import 'package:brisk/download_engine/segment/segment.dart';
import 'package:brisk/download_engine/model/download_item_model.dart';
import 'package:brisk/download_engine/download_settings.dart';

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
    if (downloadType == DownloadType.M3U8) {
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
