import 'package:brisk/constants/download_type.dart';
import 'package:brisk/download_engine/connection/m3u8_download_connection.dart';
import 'package:brisk/download_engine/model/download_item_model.dart';
import 'package:brisk/download_engine/model/m3u8.dart';
import 'package:brisk/download_engine/segment/segment.dart';

import '../connection/base_http_download_connection.dart';

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
  double totalConnectionWriteProgress;
  double totalRequestWriteProgress;
  double assembleProgress;
  ButtonAvailability buttonAvailability;
  int connectionNumber;
  int segmentLength;
  String connectioStatus;
  String message;
  Segment? segment;
  M3U8Segment? m3u8segment;
  bool completionSignal;
  int? assembledFileSize;

  DownloadProgressMessage({
    required this.downloadItem,
    this.segment,
    this.connectionNumber = 0,
    this.downloadProgress = 0,
    this.transferRate = "",
    this.status = "",
    this.estimatedRemaining = "",
    this.paused = false,
    this.totalConnectionWriteProgress = 0,
    this.totalRequestWriteProgress = 0,
    this.assembleProgress = 0,
    this.buttonAvailability = const ButtonAvailability(false, false),
    this.bytesTransferRate = 0,
    this.totalReceivedBytes = 0,
    this.totalDownloadProgress = 0,
    this.segmentLength = 0,
    this.connectioStatus = "",
    this.totalSegments = 0,
    this.message = "",
    this.completionSignal = false,
    this.assembledFileSize,
  });

  factory DownloadProgressMessage.loadFromHttpDownloadRequest(
    BaseHttpDownloadConnection connection,
  ) {
    final downloadProgress = DownloadProgressMessage(
      downloadProgress: connection.downloadProgress,
      transferRate: connection.transferRate,
      status: connection.overallStatus,
      estimatedRemaining: connection.estimatedRemaining,
      paused: connection.paused,
      totalConnectionWriteProgress: connection.totalConnectionWriteProgress,
      totalRequestWriteProgress: connection.totalRequestWriteProgress,
      buttonAvailability: ButtonAvailability(
        connection.pauseButtonEnabled,
        connection.isStartButtonEnabled,
      ),
      downloadItem: connection.downloadItem,
      bytesTransferRate: connection.bytesTransferRate,
      totalDownloadProgress: connection.totalDownloadProgress,
      totalReceivedBytes: connection.totalConnectionReceivedBytes,
      connectioStatus: connection.connectionStatus,
      connectionNumber: connection.connectionNumber,
      segment: connection.segment,
    );
    if (connection is M3U8DownloadConnection) {
      downloadProgress.m3u8segment = connection.m3u8segment;
    }
    return downloadProgress;
  }
}

class ButtonAvailability {
  final bool pauseButtonEnabled;
  final bool startButtonEnabled;

  const ButtonAvailability(this.pauseButtonEnabled, this.startButtonEnabled);
}
