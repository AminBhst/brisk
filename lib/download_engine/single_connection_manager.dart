import 'dart:isolate';

import 'package:brisk/download_engine/download_command.dart';
import 'package:brisk/download_engine/http_download_request.dart';
import 'package:brisk/model/isolate/download_isolator_data.dart';
import 'package:stream_channel/isolate_channel.dart';

class SingleConnectionManager {
  static final Map<int, Map<int, HttpDownloadRequest>> _connections = {};

  static void handleSingleConnection(SendPort sendPort) async {
    final channel = IsolateChannel.connectSend(sendPort);
    channel.stream.cast<DownloadIsolateData>().listen((data) {
      final id = data.downloadItem.id;
      _connections[id] ??= {};
      final segmentNumber = data.segmentNumber;
      HttpDownloadRequest? request = _connections[id]![segmentNumber!];
      if (request == null) {
        request = HttpDownloadRequest(
          downloadItem: data.downloadItem,
          baseTempDir: data.baseTempDir,
          startByte: data.startByte!,
          endByte: data.endByte!,
          segmentNumber: segmentNumber,
          connectionRetryTimeoutMillis: data.connectionRetryTimeout,
          maxConnectionRetryCount: data.maxConnectionRetryCount,
        );
        _connections[id]![segmentNumber] = request;
      }

      print("SINGLE::$segmentNumber  START BYTE : ${data.startByte}");
      print("SINGLE::$segmentNumber END BYTE : ${data.endByte}");
      print("SINGLE::$segmentNumber TOTAL LEN : ${request.downloadItem.contentLength}");
      print("SINGLE::$segmentNumber COMMAND : ${data.command}");

      switch (data.command) {
        case DownloadCommand.start:
          print("Starting download....");
          request.start(channel.sink.add);
          break;
        case DownloadCommand.pause:
          request.pause(channel.sink.add);
          break;
        case DownloadCommand.clearConnections:
          _connections[id]?.clear();
          break;
        case DownloadCommand.cancel:
          request.cancel();
          _connections[id]?.clear();
          break;
        case DownloadCommand.forceCancel:
          request.cancel(failure: true);
          _connections[id]?.clear();
          break;
        case DownloadCommand.refreshSegment:
          request.requestRefreshSegment();
          break;
      }
    });
  }
}
