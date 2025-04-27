import 'package:brisk_download_engine/brisk_download_engine.dart';
import 'package:brisk_download_engine/src/download_engine/model/m3u8.dart';

class M3u8DownloadIsolateMessage extends DownloadIsolateMessage {
  M3U8Segment? segment;
  String? refererHeader;

  M3u8DownloadIsolateMessage({
    required super.command,
    required super.downloadItem,
    required super.settings,
    super.connectionNumber,
    this.refererHeader,
    this.segment,
  });

  @override
  M3u8DownloadIsolateMessage clone() {
    return M3u8DownloadIsolateMessage(
      command: this.command,
      downloadItem: this.downloadItem,
      connectionNumber: this.connectionNumber,
      settings: this.settings,
      segment: this.segment,
      refererHeader: this.refererHeader,
    );
  }
}
