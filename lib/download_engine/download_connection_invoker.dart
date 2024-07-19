import 'dart:async';
import 'dart:isolate';

import 'package:brisk/download_engine/download_command.dart';
import 'package:brisk/download_engine/http_download_connection.dart';
import 'package:brisk/download_engine/download_isolate_message.dart';
import 'package:dartx/dartx.dart';
import 'package:stream_channel/isolate_channel.dart';
import 'package:stream_channel/stream_channel.dart';

class DownloadConnectionInvoker {
  static final Map<int, Map<int, HttpDownloadConnection>> _connections = {};

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

  static void invokeConnection(SendPort sendPort) async {
    final channel = IsolateChannel.connectSend(sendPort);
    channel.stream.cast<DownloadIsolateMessage>().listen((data) {
      final id = data.downloadItem.id;
      _connections[id] ??= {};
      final connectionNumber = data.connectionNumber;
      HttpDownloadConnection? request = _connections[id]![connectionNumber!];
      _setStopCommandTracker(data, channel);
      setTrackedCommand(data, channel);
      if (request == null) {
        request = HttpDownloadConnection(
          downloadItem: data.downloadItem,
          startByte: data.segment!.startByte,
          endByte: data.segment!.endByte,
          connectionNumber: connectionNumber,
          settings: data.settings,
        );
        _connections[id]![connectionNumber] = request;
      }
      _executeCommand(data, channel);
    });
  }

  static void _setStopCommandTracker(
    DownloadIsolateMessage data,
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
    DownloadIsolateMessage data,
    IsolateChannel channel,
  ) {
    final id = data.downloadItem.id;
    final segmentNumber = data.connectionNumber;
    final request = _connections[id]![segmentNumber]!;
    switch (data.command) {
      case DownloadCommand.start_Initial:
      case DownloadCommand.start:
        request.start(channel.sink.add);
        break;
      case DownloadCommand.start_ReuseConnection:
        request.start(channel.sink.add, reinitializeClient: false);
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
        request.refreshSegment(data.segment!);
        break;
      case DownloadCommand.refreshSegment_reuseConnection:
        request.refreshSegment(data.segment!, reuseConnection: true);
        break;
    }
  }

  static void setTrackedCommand(
    DownloadIsolateMessage data,
    IsolateChannel channel,
  ) {
    final id = data.downloadItem.id;
    final segmentNumber = data.connectionNumber!;
    if (_connections[id]!.isNotEmpty &&
        data.command == DownloadCommand.start_Initial) {
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
