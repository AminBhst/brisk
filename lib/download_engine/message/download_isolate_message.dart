import 'package:brisk/download_engine/download_command.dart';
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

  DownloadIsolateMessage clone();
}
