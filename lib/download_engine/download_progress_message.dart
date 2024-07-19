import 'dart:io';

import 'package:brisk/download_engine/connection_details.dart';
import 'package:brisk/download_engine/download_item_model.dart';

import 'http_download_connection.dart';

class DownloadProgressMessage {
  List<DownloadProgressMessage> connectionProgresses = [];
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
  int connectionNumber;
  int segmentLength;
  String detailsStatus;
  String message;

  DownloadProgressMessage({
    required this.downloadItem,
    this.connectionNumber = 0,
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
    this.totalDownloadProgress = 0,
    this.segmentLength = 0,
    this.detailsStatus = "",
    this.totalSegments = 0,
    this.message = "",
  });

  factory DownloadProgressMessage.loadFromHttpDownloadRequest(
    HttpDownloadConnection request,
  ) {
    final downloadProgress = DownloadProgressMessage(
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
      totalDownloadProgress: request.totalDownloadProgress,
      totalReceivedBytes: request.totalReceivedBytes,
      segmentLength: request.segmentLength,
      detailsStatus: request.detailsStatus,
      connectionNumber: request.connectionNumber,
    );
    return downloadProgress;
  }
}
