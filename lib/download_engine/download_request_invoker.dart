import 'dart:async';
import 'dart:isolate';

import 'package:brisk/download_engine/download_command.dart';
import 'package:brisk/download_engine/http_download_request.dart';
import 'package:brisk/model/isolate/download_isolator_data.dart';
import 'package:dartx/dartx.dart';
import 'package:stream_channel/isolate_channel.dart';
import 'package:stream_channel/stream_channel.dart';

class DownloadRequestInvoker {
  static final Map<int, Map<int, HttpDownloadRequest>> _connections = {};

  static final Map<int, Map<int, TrackedDownloadCommand>> _trackedCommands = {};

  static final Map<int, TrackedDownloadCommand> _latestDownloadCommands = {};

  static final Map<int, Pair<bool, StreamChannel>> stopCommandTrackerMap = {};

  static Timer? _commandTrackerTimer;

  /// TODO : Check if it's a new connection (doesn't exist in the map) ignore it as a reference for commands
  static void _runCommandTrackerTimer() {
    _commandTrackerTimer = Timer.periodic(Duration(milliseconds: 500), (_) {
      _connections.forEach((downloadId, connections) {
        final shouldSignalStop =
            stopCommandTrackerMap[downloadId]?.first ?? true;
        final channel = stopCommandTrackerMap[downloadId]?.second;
        if (!shouldSignalStop) {
          return;
        }
        _connections[downloadId]?.forEach((_, request) {
          if (!request.paused) {
            request.pause(channel?.sink.add);
          }
        });
      });
    });
  }

  static void invokeRequest(SendPort sendPort) async {
    final channel = IsolateChannel.connectSend(sendPort);
    channel.stream.cast<DownloadIsolateData>().listen((data) {
      final id = data.downloadItem.id;
      _connections[id] ??= {};
      final connectionNumber = data.connectionNumber;
      HttpDownloadRequest? request = _connections[id]![connectionNumber!];
      _setStopCommandTracker(data, channel);
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
      _executeCommand(data, channel);
    });
  }

  static void _setStopCommandTracker(
    DownloadIsolateData data,
    StreamChannel channel,
  ) {
    final id = data.downloadItem.id;
    if (data.command == DownloadCommand.pause) {
      stopCommandTrackerMap[id] = Pair(true, channel);
      _runCommandTrackerTimer();
    } else if (data.command == DownloadCommand.start) {
      stopCommandTrackerMap[id] = Pair(false, channel);
      _commandTrackerTimer?.cancel();
      _commandTrackerTimer = null;
    }
  }

  static void _executeCommand(
    DownloadIsolateData data,
    IsolateChannel channel,
  ) {
    final id = data.downloadItem.id;
    final segmentNumber = data.connectionNumber;
    final request = _connections[id]![segmentNumber]!;
    switch (data.command) {
      case DownloadCommand.startInitial:
      case DownloadCommand.start:
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
    DownloadIsolateData data,
    IsolateChannel channel,
  ) {
    final id = data.downloadItem.id;
    final segmentNumber = data.connectionNumber!;
    if (_connections[id]!.isNotEmpty &&
        data.command == DownloadCommand.startInitial) {
      return;
    }
    final trackedCommand = TrackedDownloadCommand.create(data.command, channel);
    _trackedCommands[data.downloadItem.id] ??= {};
    _trackedCommands[id]![segmentNumber] = trackedCommand;
    if (_connections[id]![segmentNumber] != null) {
      _latestDownloadCommands[id] = trackedCommand;
    }
  }
}
