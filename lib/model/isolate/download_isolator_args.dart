import 'dart:io';

import 'package:brisk/constants/download_command.dart';

import '../download_item_model.dart';

class DownloadIsolateArgs {
  int totalConnections;
  int? segmentNumber;
  final int maxConnectionRetryCount;
  final int connectionRetryTimeout;
  final Directory baseSaveDir;
  DownloadCommand command;
  DownloadItemModel downloadItem;
  Directory baseTempDir;
  int? startByte;
  int? endByte;

  DownloadIsolateArgs({
    required this.command,
    required this.downloadItem,
    required this.baseTempDir,
    required this.totalConnections,
    required this.baseSaveDir,
    this.connectionRetryTimeout = 10,
    this.maxConnectionRetryCount = -1,
    this.segmentNumber,
    this.startByte,
    this.endByte,
  });
}
