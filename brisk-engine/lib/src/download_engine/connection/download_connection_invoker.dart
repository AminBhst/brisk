import 'dart:async';
import 'dart:collection';
import 'dart:isolate';

import 'package:brisk_engine/src/download_engine/connection/base_http_download_connection.dart';
import 'package:brisk_engine/src/download_engine/connection/http_download_connection.dart';
import 'package:brisk_engine/src/download_engine/constants/download_command.dart';
import 'package:brisk_engine/src/download_engine/constants/download_status.dart';
import 'package:brisk_engine/src/download_engine/message/connection_handshake_message.dart';
import 'package:brisk_engine/src/download_engine/message/download_isolate_message.dart';
import 'package:dartx/dartx.dart';
import 'package:stream_channel/isolate_channel.dart';
import 'package:stream_channel/stream_channel.dart';

class DownloadConnectionInvoker {
  static final Map<String, Map<int, BaseHttpDownloadConnection>> _connections = {};

  static final Map<String, Pair<bool, StreamChannel>> stopCommandTrackerMap = {};

  static final Map<String, Set<int>> forceApplyReuseConnections = {};

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
            conn.logger?.info("Invoker:: Force paused connection");
          }
        });
      });
    });
  }

  static void invokeConnection(SendPort sendPort) async {
    final channel = IsolateChannel.connectSend(sendPort);
    _runCommandTrackerTimer();
    channel.stream.cast<DownloadIsolateMessage>().listen((data) {
      final uid = data.downloadItem.uid;
      _connections[uid] ??= {};
      final connectionNumber = data.connectionNumber;
      BaseHttpDownloadConnection? conn = _connections[uid]![connectionNumber!];
      _setStopCommandTracker(data, channel);
      if (conn == null) {
        conn = _buildDownloadConnection(data) as BaseHttpDownloadConnection?;
        if (data.settings.loggerEnabled) {
          conn!.initLogger();
        }
        _connections[uid]![connectionNumber] = conn!;
      }
      _executeCommand(data, channel);
    });
  }

  static HttpDownloadConnection _buildDownloadConnection(
    DownloadIsolateMessage data,
  ) {
    return HttpDownloadConnection(
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
    final id = data.downloadItem.uid;
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
    final id = data.downloadItem.uid;
    final connectionNumber = data.connectionNumber;
    final connection = _connections[id]![connectionNumber]!;
    connection.logger?.info(
      "Invoker:: Received command ${data.command} with segment ${data.segment}",
    );
    bool forcedConnectionReuse = false;
    if (shouldForceApplyReuseConnection(data)) {
      data.command = DownloadCommand.startReuseConnection;
      forceApplyReuseConnections[id]?.remove(connectionNumber);
      forcedConnectionReuse = true;
      connection.logger?.info("Invoker:: Forcing reuseConnection...");
    }
    switch (data.command) {
      case DownloadCommand.startInitial:
        connection.previousBufferEndByte = data.previouslyWrittenByteLength;
        connection.start(channel.sink.add);
        channel.sink.add(ConnectionHandshake.fromIsolateMessage(data));
        break;
      case DownloadCommand.start:
        connection.start(channel.sink.add);
        break;
      case DownloadCommand.startReuseConnection:
        if (!forcedConnectionReuse) {
          connection.segment = data.segment!;
          if (connection.connectionStatus == DownloadStatus.paused ||
              connection.reset) {
            connection.logger?.info(
              "Invoker:: received start_ConnectionReuse command in paused status! reset? ${connection.reset}",
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
      case DownloadCommand.refreshSegmentReuseConnection:
        connection.refreshSegment(data.segment!, reuseConnection: true);
        break;
      case DownloadCommand.resetConnection:
        if (!connection.connectionRetryAllowed) {
          break;
        }
        connection.previousBufferEndByte = 0;
        connection.resetConnection();
        break;
    }
  }

  static bool shouldForceApplyReuseConnection(DownloadIsolateMessage message) {
    final downloadId = message.downloadItem.uid;
    return message.command == DownloadCommand.start &&
        forceApplyReuseConnections[downloadId] != null &&
        forceApplyReuseConnections[downloadId]!
            .contains(message.connectionNumber);
  }
}
