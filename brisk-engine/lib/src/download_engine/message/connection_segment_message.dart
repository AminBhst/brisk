import 'package:brisk_engine/src/download_engine/message/internal_messages.dart';
import 'package:brisk_engine/src/download_engine/model/download_item_model.dart';
import 'package:brisk_engine/src/download_engine/segment/segment.dart';

class ConnectionSegmentMessage {
  DownloadItemModel downloadItem;
  InternalMessage? internalMessage;
  bool reuseConnection;
  Segment requestedSegment;
  int? validNewStartByte;
  int? validNewEndByte;
  int? refreshedStartByte;
  int? refreshedEndByte;

  ConnectionSegmentMessage({
    required this.downloadItem,
    required this.requestedSegment,
    required this.reuseConnection,
    this.internalMessage,
    this.validNewStartByte,
    this.validNewEndByte,
    this.refreshedStartByte,
    this.refreshedEndByte,
  });
}
