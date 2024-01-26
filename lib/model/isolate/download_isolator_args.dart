import 'dart:io';

import 'package:brisk/constants/download_command.dart';

import '../download_item_model.dart';

class DownloadIsolatorArgs {
  DownloadCommand command;
  DownloadItemModel downloadItem;
  Directory baseTempDir;

  DownloadIsolatorArgs({
    required this.command,
    required this.downloadItem,
    required this.baseTempDir,
  });
}

class SegmentedDownloadIsolateArgs extends DownloadIsolatorArgs {
  int totalConnections;
  int? segmentNumber;
  final int maxConnectionRetryCount;
  final int connectionRetryTimeout;
  final Directory baseSaveDir;

  SegmentedDownloadIsolateArgs({
    required super.command,
    required super.downloadItem,
    required super.baseTempDir,
    required this.totalConnections,
    required this.baseSaveDir,
    this.connectionRetryTimeout = 10,
    this.maxConnectionRetryCount = -1,
    this.segmentNumber,
  });
}
