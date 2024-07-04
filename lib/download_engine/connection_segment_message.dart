import 'package:brisk/download_engine/internal_messages.dart';
import 'package:brisk/model/download_item_model.dart';

class ConnectionSegmentMessage {
  DownloadItemModel downloadItem;
  InternalMessage internalMessage;
  int? validStartByte;
  int? validEndByte;

  ConnectionSegmentMessage({
    required this.downloadItem,
    required this.internalMessage,
    this.validStartByte,
    this.validEndByte,
  });
}
