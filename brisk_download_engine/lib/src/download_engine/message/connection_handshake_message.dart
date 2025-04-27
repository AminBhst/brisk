import 'package:brisk_download_engine/src/download_engine/model/download_item_model.dart';

import 'download_isolate_message.dart';

class EngineConnectionHandshake {
  int newConnectionNumber;

  EngineConnectionHandshake({
    required this.newConnectionNumber,
  });
}

class ConnectionHandshake {
  DownloadItemModel downloadItem;
  bool reuseConnection;
  int newConnectionNumber;

  ConnectionHandshake({
    required this.downloadItem,
    required this.newConnectionNumber,
    this.reuseConnection = false,
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
