import 'dart:io';

import 'package:brisk/downloader/download_command.dart';

import '../download_item_model.dart';

class DownloadIsolateData {
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

  DownloadIsolateData({
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

  DownloadIsolateData clone() {
    return DownloadIsolateData(
      command: this.command,
      downloadItem: this.downloadItem,
      baseTempDir: this.baseTempDir,
      totalConnections: totalConnections,
      baseSaveDir: this.baseSaveDir,
      connectionRetryTimeout: this.connectionRetryTimeout,
      maxConnectionRetryCount: this.maxConnectionRetryCount,
      startByte: this.startByte,
      endByte: this.startByte,
      segmentNumber: this.segmentNumber,
    );
  }
}
