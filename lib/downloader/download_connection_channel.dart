import 'package:brisk/downloader/isolate_channel_proxy.dart';
import 'package:brisk/model/download_item_model.dart';
import 'package:brisk/model/download_progress.dart';

class DownloadConnectionChannel extends IsolateChannelProxy {
  final segmentNumber;
  int startByte;
  int endByte;
  double progress = 0;
  int segmentLength = 0;
  DownloadItemModel? downloadItem;
  DownloadConnectionChannel({
    required super.channel,
    required this.segmentNumber,
    required this.startByte,
    required this.endByte,
  });

  @override
  void onEventReceived(event) {
    if (!event is DownloadProgress) {
      return;
    }
    event = event as DownloadProgress;
    this.progress = event.downloadProgress;
    this.segmentLength = event.segmentLength;
    this.downloadItem = event.downloadItem;
  }
}
