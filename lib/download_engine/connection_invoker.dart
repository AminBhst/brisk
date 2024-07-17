import 'dart:async';
import 'dart:isolate';

import 'package:brisk/download_engine/download_command.dart';
import 'package:brisk/download_engine/http_download_request.dart';
import 'package:brisk/model/isolate/download_isolator_data.dart';
import 'package:stream_channel/isolate_channel.dart';

class ConnectionInvoker {
  static final Map<int, Map<int, HttpDownloadRequest>> _connections = {};

  static final Map<int, Map<int, TrackedDownloadCommand>> _trackedCommands = {};

  static final Map<int, TrackedDownloadCommand> _latestDownloadCommands = {};

  static Timer? _commandTrackerTimer;

  /// TODO : Check if it's a new connection (doesn't exist in the map) ignore it as a reference for commands
  static void runCommandTrackerTimer() {
    _commandTrackerTimer = Timer.periodic(Duration(milliseconds: 500), (_) {
      _connections.forEach((downloadId, connections) {
        final firstConn = connections[0];
        if (firstConn == null) return;
        final command = _trackedCommands[downloadId];
        if (command == null) return;
        // command
      });
    });
  }

  static void handleSingleConnection(SendPort sendPort) async {
    final channel = IsolateChannel.connectSend(sendPort);
    channel.stream.cast<DownloadIsolateData>().listen((data) {
      final id = data.downloadItem.id;
      _connections[id] ??= {};
      final connectionNumber = data.connectionNumber;
      HttpDownloadRequest? request = _connections[id]![connectionNumber!];
      setTrackedCommand(data, channel);
      if (request == null) {
        request = HttpDownloadRequest(
          downloadItem: data.downloadItem,
          baseTempDir: data.baseTempDir,
          startByte: data.segment!.startByte,
          endByte: data.segment!.endByte,
          connectionNumber: connectionNumber,
          connectionRetryTimeoutMillis: data.connectionRetryTimeout,
          maxConnectionRetryCount: data.maxConnectionRetryCount,
        );
        _connections[id]![connectionNumber] = request;
      }

      print("SINGLE::$connectionNumber   Segment : ${data.segment}");
      print(
          "SINGLE::$connectionNumber TOTAL LEN : ${request.downloadItem.contentLength}");
      print("SINGLE::$connectionNumber COMMAND : ${data.command}");

      executeCommand(data, channel);
    });
  }

  static void executeCommand(DownloadIsolateData data, IsolateChannel channel) {
    final id = data.downloadItem.id;
    final segmentNumber = data.connectionNumber;
    final request = _connections[id]![segmentNumber]!;
    switch (data.command) {
      case DownloadCommand.start:
        print("Starting download....");
        request.start(channel.sink.add);
        break;
      case DownloadCommand.pause:
        request.pause(channel.sink.add);
        break;
      case DownloadCommand.clearConnections: // TODO add sink.close()
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
        request.requestRefreshSegment(data.segment!);
        break;
    }
  }

  static void setTrackedCommand(
      DownloadIsolateData data, IsolateChannel channel) {
    final id = data.downloadItem.id;
    final segmentNumber = data.connectionNumber!;
    final trackedCommand = TrackedDownloadCommand.create(data.command, channel);
    _trackedCommands[data.downloadItem.id] ??= {};
    _trackedCommands[id]![segmentNumber] = trackedCommand;
    if (_connections[id]![segmentNumber] != null) {
      _latestDownloadCommands[id] = trackedCommand;
    }
  }
}
