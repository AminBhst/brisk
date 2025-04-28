import 'package:brisk_download_engine/src/download_engine/channel/download_connection_channel.dart';
import 'package:brisk_download_engine/src/download_engine/download_type.dart';
import 'package:brisk_download_engine/src/download_engine/message/download_progress_message.dart';
import 'package:brisk_download_engine/src/download_engine/model/m3u8.dart';

class M3u8DownloadConnectionChannel extends DownloadConnectionChannel {
  M3U8Segment? segment;

  M3u8DownloadConnectionChannel({
    required super.channel,
    required super.connectionNumber,
    required this.segment,
  });

  @override
  void onEventReceived(event) {
    super.onEventReceived(event);
    if (event is! DownloadProgressMessage ||
        event.downloadItem.downloadType != DownloadType.m3u8) {
      return;
    }
    this.segment = event.m3u8segment;
  }
}
