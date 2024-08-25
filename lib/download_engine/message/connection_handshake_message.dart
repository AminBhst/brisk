import 'download_isolate_message.dart';

class EngineConnectionHandshake {
  int newConnectionNumber;
  HandShakeStatus handShakeStatus;

  EngineConnectionHandshake({
    required this.handShakeStatus,
    required this.newConnectionNumber,
  });
}

class ConnectionHandshake {
  int downloadId;
  int newConnectionNumber;

  ConnectionHandshake({
    required this.downloadId,
    required this.newConnectionNumber,
  });

  factory ConnectionHandshake.fromIsolateMessage(
    DownloadIsolateMessage message,
  ) {
    return ConnectionHandshake(
      downloadId: message.downloadItem.id,
      newConnectionNumber: message.connectionNumber!,
    );
  }
}

enum HandShakeStatus { PENDING_REFRESH, PENDING_CONNECTION_SPAWN }
