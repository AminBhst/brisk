import 'package:brisk_download_engine/brisk_download_engine.dart';
import 'package:brisk_download_engine/src/download_engine/util/isolate_channel_wrapper.dart';

class DownloadConnectionChannel extends IsolateChannelWrapper {
  final int connectionNumber;
  bool segmentRefreshed = false;
  double progress = 0;
  int segmentLength = 0;
  DownloadItemModel? downloadItem;
  String? message;
  int totalReceivedBytes = 0;
  String status = "";
  String detailsStatus = "";
  double bytesTransferRate = 0;
  int lastResponseTime = DateTime.now().millisecondsSinceEpoch;
  int resetCount = 0;
  bool awaitingResetResponse = false;

  DownloadConnectionChannel({
    required super.channel,
    required this.connectionNumber,
  });

  @override
  void onEventReceived(event) {
    if (event is! DownloadProgressMessage) {
      return;
    }
    lastResponseTime = DateTime.now().millisecondsSinceEpoch;
    progress = event.downloadProgress;
    segmentLength = event.segmentLength;
    downloadItem = event.downloadItem;
    message = event.message;
    totalReceivedBytes = event.totalReceivedBytes;
    status = event.status;
    detailsStatus = event.connectionStatus;
    bytesTransferRate = event.bytesTransferRate;
  }
}
