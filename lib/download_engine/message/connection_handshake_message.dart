import 'package:brisk/download_engine/model/download_item_model.dart';

import 'download_isolate_message.dart';

class EngineConnectionHandshake {
  int newConnectionNumber;

  EngineConnectionHandshake({
    required this.newConnectionNumber,
  });
}

class ConnectionHandshake {
  DownloadItemModel downloadItem;
  int newConnectionNumber;

  ConnectionHandshake({
    required this.downloadItem,
    required this.newConnectionNumber,
  });

  factory ConnectionHandshake.fromIsolateMessage(
    DownloadIsolateMessage message,
  ) {
    return ConnectionHandshake(
      downloadItem: message.downloadItem,
      newConnectionNumber: message.connectionNumber!,
    );
  }
}
