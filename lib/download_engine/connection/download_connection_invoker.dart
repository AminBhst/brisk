import 'dart:async';
import 'dart:collection';
import 'dart:isolate';

import 'package:brisk/download_engine/download_command.dart';
import 'package:brisk/download_engine/connection/http_download_connection.dart';
import 'package:brisk/download_engine/download_status.dart';
import 'package:brisk/download_engine/message/download_isolate_message.dart';
import 'package:brisk/download_engine/connection/mock_http_download_connection.dart';
import 'package:dartx/dartx.dart';
import 'package:stream_channel/isolate_channel.dart';
import 'package:stream_channel/stream_channel.dart';

import 'package:brisk/download_engine/connection/base_http_download_connection.dart';
import 'package:brisk/download_engine/client/mock_http_client_proxy.dart';
import 'package:brisk/download_engine/message/connection_handshake_message.dart';

class DownloadConnectionInvoker {
  static final Map<int, Map<int, BaseHttpDownloadConnection>> _connections = {};

  static final Map<int, Map<int, TrackedDownloadCommand>> _trackedCommands = {};

  static final Map<int, Pair<bool, StreamChannel>> stopCommandTrackerMap = {};

  static final Map<int, Set<int>> forceApplyReuseConnections = {};

  static Timer? _commandTrackerTimer;

  /// TODO : Check if it's a new connection (doesn't exist in the map) ignore it as a reference for commands
  static void _runCommandTrackerTimer() {
    if (_commandTrackerTimer != null) return;
    _commandTrackerTimer = Timer.periodic(Duration(milliseconds: 200), (_) {
      _connections.forEach((downloadId, connections) {
        final shouldSignalStop =
            stopCommandTrackerMap[downloadId]?.first ?? false;
        final channel = stopCommandTrackerMap[downloadId]?.second;
        if (!shouldSignalStop) {
          return;
        }
        _connections[downloadId]?.forEach((_, conn) {
          if (!conn.paused) {
            conn.pause(channel?.sink.add);
            print("======== paused connection ${conn.connectionNumber}");
          }
        });
      });
    });
  }

  static void invokeConnection(SendPort sendPort) async {
    final channel = IsolateChannel.connectSend(sendPort);
    _runCommandTrackerTimer();
    channel.stream.cast<DownloadIsolateMessage>().listen((data) {
      final id = data.downloadItem.id;
      _connections[id] ??= {};
      final connectionNumber = data.connectionNumber;
      BaseHttpDownloadConnection? conn = _connections[id]![connectionNumber!];
      _setStopCommandTracker(data, channel);
      setTrackedCommand(data, channel);
      if (conn == null) {
        conn = _buildDownloadConnection(data);
        _connections[id]![connectionNumber] = conn;
      }
      _executeCommand(data, channel);
    });
  }

  static BaseHttpDownloadConnection _buildDownloadConnection(
    DownloadIsolateMessage data,
  ) {
    return data.downloadItem.downloadUrl == mockDownloadUrl
        ? MockHttpDownloadConnection(
            downloadItem: data.downloadItem,
            segment: data.segment!,
            connectionNumber: data.connectionNumber!,
            settings: data.settings,
          )
        : HttpDownloadConnection(
            downloadItem: data.downloadItem,
            segment: data.segment!,
            connectionNumber: data.connectionNumber!,
            settings: data.settings,
          );
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
    final connectionNumber = data.connectionNumber;
    final connection = _connections[id]![connectionNumber]!;
    print(
        "Got command conn $connectionNumber ===> ${data.command} ==> ${data.segment}");
    bool forcedConnectionReuse = false;
    if (shouldForceApplyReuseConnection(data)) {
      data.command = DownloadCommand.start_ReuseConnection;
      forceApplyReuseConnections[id]?.remove(connectionNumber);
      forcedConnectionReuse = true;
      print("Forcing reuseConnection for conn $connectionNumber");
    }
    switch (data.command) {
      case DownloadCommand.start_Initial:
        connection.start(channel.sink.add);
        channel.sink.add(ConnectionHandshake.fromIsolateMessage(data));
        break;
      case DownloadCommand.start:
        connection.start(channel.sink.add);
        break;
      case DownloadCommand.start_ReuseConnection:
        if (!forcedConnectionReuse) {
          connection.segment = data.segment!;
          if (connection.detailsStatus == DownloadStatus.paused) {
            print(
              "Conn $connectionNumber received start_ConnectionReuse command in paused status",
            );
            forceApplyReuseConnections[id] ??= HashSet();
            forceApplyReuseConnections[id]!.add(connectionNumber!);
            break;
          }
        }
        connection.start(channel.sink.add, reuseConnection: true);
        channel.sink.add(
          ConnectionHandshake.fromIsolateMessage(data)..reuseConnection = true,
        );
        break;
      case DownloadCommand.pause:
        connection.pause(channel.sink.add);
        break;
      case DownloadCommand.clearConnections: // TODO add sink.close()
        _connections[id]?.clear();
        break;
      case DownloadCommand.cancel:
        connection.cancel();
        _connections[id]?.clear();
        break;
      case DownloadCommand.forceCancel:
        connection.cancel(failure: true);
        _connections[id]?.clear();
        break;
      case DownloadCommand.refreshSegment:
        connection.refreshSegment(data.segment!);
        break;
      case DownloadCommand.refreshSegment_reuseConnection:
        connection.refreshSegment(data.segment!, reuseConnection: true);
        break;
    }
  }

  static bool shouldForceApplyReuseConnection(DownloadIsolateMessage message) {
    final downloadId = message.downloadItem.id;
    return message.command == DownloadCommand.start &&
        forceApplyReuseConnections[downloadId] != null &&
        forceApplyReuseConnections[downloadId]!
            .contains(message.connectionNumber);
  }

  static void setTrackedCommand(
    DownloadIsolateMessage data,
    IsolateChannel channel,
  ) {
    final id = data.downloadItem.id;
    final segmentNumber = data.connectionNumber!;
    if (_connections[id]!.isNotEmpty && data.command != DownloadCommand.pause) {
      return;
    }
    final trackedCommand = TrackedDownloadCommand.create(data.command, channel);
    _trackedCommands[data.downloadItem.id] ??= {};
    _trackedCommands[id]![segmentNumber] = trackedCommand;
  }
}
