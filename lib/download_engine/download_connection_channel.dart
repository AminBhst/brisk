import 'package:brisk/download_engine/isolate_channel_wrapper.dart';
import 'package:brisk/download_engine/segment.dart';
import 'package:brisk/model/download_item_model.dart';
import 'package:brisk/model/download_progress.dart';

class DownloadConnectionChannel extends IsolateChannelWrapper {
  final segmentNumber;
  Segment segment;
  bool segmentRefreshed = false;
  double progress = 0;
  int segmentLength = 0;
  DownloadItemModel? downloadItem;
  String? message;
  int totalReceivedBytes = 0;

  DownloadConnectionChannel({
    required super.channel,
    required this.segmentNumber,
    required this.segment,
  });

  @override
  void onEventReceived(event) {
    if (!(event is DownloadProgress)) {
      return;
    }
    this.progress = event.downloadProgress;
    this.segmentLength = event.segmentLength;
    this.downloadItem = event.downloadItem;
    this.message = event.message;
    this.totalReceivedBytes = event.totalReceivedBytes;
  }
}
