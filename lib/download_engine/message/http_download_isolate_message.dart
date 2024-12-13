import 'package:brisk/download_engine/message/download_isolate_message.dart';
import 'package:brisk/download_engine/segment/segment.dart';

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
      command: this.command,
      downloadItem: this.downloadItem,
      connectionNumber: this.connectionNumber,
      settings: this.settings,
      segment: this.segment,
      previouslyWrittenByteLength: previouslyWrittenByteLength,
    );
  }
}
