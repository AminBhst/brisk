import 'package:brisk/constants/download_type.dart';
import 'package:brisk/download_engine/channel/download_connection_channel.dart';
import 'package:brisk/download_engine/message/download_progress_message.dart';
import 'package:brisk/download_engine/segment/segment.dart';

class HttpDownloadConnectionChannel extends DownloadConnectionChannel {
  Segment? segment;

  HttpDownloadConnectionChannel({
    required super.channel,
    required super.connectionNumber,
    required this.segment,
  });

  @override
  void onEventReceived(event) {
    super.onEventReceived(event);
    if (!(event is DownloadProgressMessage) ||
        event.downloadItem.downloadType != DownloadType.HTTP) {
      return;
    }
    this.segment = event.segment;
  }
}
