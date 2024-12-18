import 'package:brisk/constants/download_type.dart';
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
  String detailsStatus;
  String message;
  Segment? segment;
  M3U8Segment? m3u8segment;
  bool completionSignal;
  DownloadType downloadType;

  DownloadProgressMessage({
    required this.downloadItem,
    required this.downloadType,
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
    this.detailsStatus = "",
    this.totalSegments = 0,
    this.message = "",
    this.completionSignal = false,
  });

  factory DownloadProgressMessage.loadFromHttpDownloadRequest(
    BaseHttpDownloadConnection request,
  ) {
    final downloadProgress = DownloadProgressMessage(
      downloadProgress: request.downloadProgress,
      transferRate: request.transferRate,
      status: request.overallStatus,
      estimatedRemaining: request.estimatedRemaining,
      paused: request.paused,
      totalConnectionWriteProgress: request.totalConnectionWriteProgress,
      totalRequestWriteProgress: request.totalRequestWriteProgress,
      buttonAvailability: ButtonAvailability(
        request.pauseButtonEnabled,
        request.isStartButtonEnabled,
      ),
      downloadItem: request.downloadItem,
      bytesTransferRate: request.bytesTransferRate,
      totalDownloadProgress: request.totalDownloadProgress,
      totalReceivedBytes: request.totalConnectionReceivedBytes,
      detailsStatus: request.connectionStatus,
      connectionNumber: request.connectionNumber,
      segment: request.segment,
      downloadType: DownloadType.HTTP,
    );
    return downloadProgress;
  }
}

class ButtonAvailability {
  final bool pauseButtonEnabled;
  final bool startButtonEnabled;

  const ButtonAvailability(this.pauseButtonEnabled, this.startButtonEnabled);
}
