import 'package:brisk/download_engine/internal_messages.dart';
import 'package:brisk/download_engine/segment.dart';
import 'package:brisk/model/download_item_model.dart';

class ConnectionSegmentMessage {
  DownloadItemModel downloadItem;
  InternalMessage? internalMessage;
  Segment requestedSegment;
  int? validStartByte;
  int? validEndByte;

  ConnectionSegmentMessage({
    required this.downloadItem,
    required this.requestedSegment,
    this.internalMessage,
    this.validStartByte,
    this.validEndByte,
  });
}
