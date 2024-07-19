import 'dart:io';

import 'package:brisk/download_engine/download_command.dart';
import 'package:brisk/download_engine/segment.dart';

import '../download_item_model.dart';

class DownloadIsolateData {
  int totalConnections;
  int? connectionNumber;
  final int maxConnectionRetryCount;
  final int connectionRetryTimeout;
  final Directory baseSaveDir;
  DownloadCommand command;
  DownloadItemModel downloadItem;
  Directory baseTempDir;
  Segment? segment;

  DownloadIsolateData({
    required this.command,
    required this.downloadItem,
    required this.baseTempDir,
    required this.totalConnections,
    required this.baseSaveDir,
    this.connectionRetryTimeout = 10000,
    this.maxConnectionRetryCount = -1,
    this.connectionNumber,
    this.segment,
  });

  DownloadIsolateData clone() {
    return DownloadIsolateData(
      command: this.command,
      downloadItem: this.downloadItem,
      baseTempDir: this.baseTempDir,
      totalConnections: totalConnections,
      baseSaveDir: this.baseSaveDir,
      connectionRetryTimeout: this.connectionRetryTimeout,
      maxConnectionRetryCount: this.maxConnectionRetryCount,
      segment: this.segment,
      connectionNumber: this.connectionNumber,
    );
  }
}
