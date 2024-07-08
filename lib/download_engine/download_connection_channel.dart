import 'package:brisk/download_engine/isolate_channel_wrapper.dart';
import 'package:brisk/model/download_item_model.dart';
import 'package:brisk/model/download_progress.dart';

class DownloadConnectionChannel extends IsolateChannelWrapper {
  final segmentNumber;
  int startByte;
  int endByte;
  bool segmentRefreshed = false;
  double progress = 0;
  int segmentLength = 0;
  DownloadItemModel? downloadItem;
  String? message;

  DownloadConnectionChannel({
    required super.channel,
    required this.segmentNumber,
    required this.startByte,
    required this.endByte,
  });

  @override
  void onEventReceived(event) {
    if (!(event is DownloadProgress)) {
      return;
    }
    event = event as DownloadProgress;
    this.progress = event.downloadProgress;
    this.segmentLength = event.segmentLength;
    this.downloadItem = event.downloadItem;
    this.message = event.message;
  }
}
