import 'package:brisk/download_engine/isolate_channel_wrapper.dart';
import 'package:brisk/download_engine/segment.dart';
import 'package:brisk/download_engine/download_item_model.dart';
import 'package:brisk/download_engine/download_progress_message.dart';

class DownloadConnectionChannel extends IsolateChannelWrapper {
  final connectionNumber;
  Segment segment;
  bool segmentRefreshed = false;
  double progress = 0;
  int segmentLength = 0;
  DownloadItemModel? downloadItem;
  String? message;
  int totalReceivedBytes = 0;
  String status = "";
  String detailsStatus = "";
  double bytesTransferRate = 0;

  DownloadConnectionChannel({
    required super.channel,
    required this.connectionNumber,
    required this.segment,
  });

  @override
  void onEventReceived(event) {
    if (!(event is DownloadProgressMessage)) {
      return;
    }
    this.progress = event.downloadProgress;
    this.segmentLength = event.segmentLength;
    this.downloadItem = event.downloadItem;
    this.message = event.message;
    this.totalReceivedBytes = event.totalReceivedBytes;
    this.status = event.status;
    this.detailsStatus = event.detailsStatus;
    this.bytesTransferRate = event.bytesTransferRate;
  }
}
