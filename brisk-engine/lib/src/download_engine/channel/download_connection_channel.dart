import 'package:brisk_engine/src/download_engine/message/download_progress_message.dart';
import 'package:brisk_engine/src/download_engine/model/download_item_model.dart';
import 'package:brisk_engine/src/download_engine/segment/segment.dart';
import 'package:brisk_engine/src/download_engine/util/isolate_channel_wrapper.dart';

class DownloadConnectionChannel extends IsolateChannelWrapper {
  final int connectionNumber;
  Segment? segment;
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
    required this.segment,
  });

  @override
  void onEventReceived(event) {
    if (event is! DownloadProgressMessage) {
      return;
    }
    progress = event.downloadProgress;
    segmentLength = event.segmentLength;
    downloadItem = event.downloadItem;
    message = event.message;
    totalReceivedBytes = event.totalReceivedBytes;
    status = event.status;
    detailsStatus = event.detailsStatus;
    bytesTransferRate = event.bytesTransferRate;
    segment = event.segment;
    lastResponseTime = DateTime.now().millisecondsSinceEpoch;
  }
}
