import 'dart:isolate';

import 'package:brisk/constants/download_command.dart';
import 'package:brisk/downloader/http_download_request.dart';
import 'package:brisk/model/isolate/download_isolator_args.dart';
import 'package:stream_channel/isolate_channel.dart';

class SingleConnectionManager {
  static final Map<int, Map<int, HttpDownloadRequest>> _connections = {};

  static void handleSingleConnection(SendPort sendPort) async {
    final channel = IsolateChannel.connectSend(sendPort);
    channel.stream.cast<DownloadIsolateArgs>().listen((data) {
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

      print("================= SINGLE ${segmentNumber} =================");
      print("START BYTE : ${data.startByte}");
      print("END BYTE : ${data.endByte}");
      print("TOTAL LEN : ${request.downloadItem.contentLength}");
      print("COMMAND : ${data.command}");
      print("================= SINGLE ${segmentNumber} =================");

      switch (data.command) {
        case DownloadCommand.start:
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
          request.refreshSegment(data.startByte!, data.endByte!);
          break;
      }
    });
  }
}
