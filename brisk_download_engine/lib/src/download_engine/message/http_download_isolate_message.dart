import 'package:brisk_download_engine/brisk_download_engine.dart';
import 'package:brisk_download_engine/src/download_engine/segment/segment.dart';

class HttpDownloadIsolateMessage extends DownloadIsolateMessage {
  Segment? segment;
  int previouslyWrittenByteLength;

  HttpDownloadIsolateMessage({
    required super.command,
    required super.downloadItem,
    required super.settings,
    super.connectionNumber,
    this.segment,
    this.previouslyWrittenByteLength = 0,
  });

  @override
  HttpDownloadIsolateMessage clone() {
    return HttpDownloadIsolateMessage(
      command: command,
      downloadItem: downloadItem,
      connectionNumber: connectionNumber,
      settings: settings,
      segment: segment,
      previouslyWrittenByteLength: previouslyWrittenByteLength,
    );
  }
}
