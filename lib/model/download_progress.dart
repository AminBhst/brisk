import 'dart:io';

import 'package:brisk/model/download_item.dart';
import 'package:brisk/model/download_item_model.dart';

import '../downloader/multi_connection_http_download_request.dart';

class DownloadProgress {
  List<DownloadProgress> connectionProgresses = [];
  DownloadItemModel downloadItem;
  int totalSegments;
  double downloadProgress;
  int totalReceivedBytes;
  double totalDownloadProgress;
  String transferRate;
  double bytesTransferRate;
  String status;
  String estimatedRemaining;
  bool paused;
  double writeProgress;
  double assembleProgress;
  bool startButtonEnabled;
  bool pauseButtonEnabled;
  int segmentNumber;
  int segmentLength;
  late Directory baseTempDir;
  String detailsStatus;

  DownloadProgress({
    required this.downloadItem,
    this.downloadProgress = 0,
    this.transferRate = "",
    this.status = "",
    this.estimatedRemaining = "",
    this.paused = false,
    this.writeProgress = 0,
    this.assembleProgress = 0,
    this.startButtonEnabled = false,
    this.pauseButtonEnabled = false,
    this.bytesTransferRate = 0,
    this.totalReceivedBytes = 0,
    this.segmentNumber = 0,
    this.totalDownloadProgress = 0,
    this.segmentLength = 0,
    this.detailsStatus = "",
    this.totalSegments = 0,
  });

  factory DownloadProgress.loadFromMultiConnectionDownloadRequest(
      MultiConnectionHttpDownloadRequest request) {
    final downloadProgress = DownloadProgress(
      downloadProgress: request.downloadProgress,
      transferRate: request.transferRate,
      status: request.status,
      estimatedRemaining: request.estimatedRemaining,
      paused: request.paused,
      writeProgress: request.writeProgress,
      startButtonEnabled: request.isStartButtonEnabled,
      pauseButtonEnabled: request.pauseButtonEnabled,
      downloadItem: request.downloadItem,
      bytesTransferRate: request.bytesTransferRate,
      segmentNumber: request.segmentNumber,
      totalDownloadProgress: request.totalDownloadProgress,
      totalReceivedBytes: request.totalReceivedBytes,
      segmentLength: request.segmentLength,
      detailsStatus: request.detailsStatus,
      totalSegments: request.totalSegments,
    );
    downloadProgress.baseTempDir = request.baseTempDir;
    return downloadProgress;
  }
}
