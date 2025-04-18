import 'dart:async';
import 'dart:collection';
import 'dart:isolate';

import 'package:brisk/download_engine/connection/m3u8_download_connection.dart';
import 'package:brisk/download_engine/download_command.dart';
import 'package:brisk/download_engine/connection/http_download_connection.dart';
import 'package:brisk/download_engine/download_status.dart';
import 'package:brisk/download_engine/message/connection_segment_message.dart';
import 'package:brisk/download_engine/message/connections_cleared_message.dart';
import 'package:brisk/download_engine/message/download_isolate_message.dart';
import 'package:brisk/download_engine/message/http_download_isolate_message.dart';
import 'package:brisk/download_engine/message/m3u8_download_isolate_message.dart';
import 'package:brisk/download_engine/segment/segment.dart';
import 'package:dartx/dartx.dart';
import 'package:stream_channel/isolate_channel.dart';
import 'package:stream_channel/stream_channel.dart';

import 'package:brisk/download_engine/message/connection_handshake_message.dart';

class DownloadConnectionInvoker {
  static final Map<int, Map<int, HttpDownloadConnection>> _connections = {};

  static final Map<int, Map<int, TrackedDownloadCommand>> _trackedCommands = {};

  static final Map<int, Pair<bool, StreamChannel>> stopCommandTrackerMap = {};

  static final Map<int, Set<int>> forceApplyReuseConnections = {};

  static Timer? _commandTrackerTimer;

  /// TODO : Check if it's a new connection (doesn't exist in the map) ignore it as a reference for commands
  static void _runCommandTrackerTimer() {
    if (_commandTrackerTimer != null) return;
    _commandTrackerTimer = Timer.periodic(Duration(milliseconds: 300), (_) {
      _connections.forEach((downloadId, connections) {
        final shouldSignalStop =
            stopCommandTrackerMap[downloadId]?.first ?? false;
        final channel = stopCommandTrackerMap[downloadId]?.second;
        if (!shouldSignalStop) {
          return;
        }
        _connections[downloadId]?.forEach((_, conn) {
          if (conn.connectionStatus != DownloadStatus.paused) {
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
      final id = data.downloadItem.id;
      print("Received command for conn ${data.connectionNumber}");
      _connections[id] ??= {};
      final connectionNumber = data.connectionNumber;
      HttpDownloadConnection? conn = _connections[id]![connectionNumber!];
      _setStopCommandTracker(data, channel);
      setTrackedCommand(data, channel);
      if (conn == null) {
        conn = _buildDownloadConnection(data);
        if (data.settings.loggerEnabled) {
          conn?.initLogger();
        }
        _connections[id]![connectionNumber] = conn!;
      }
      _executeCommand(data, channel);
    });
  }

  static HttpDownloadConnection? _buildDownloadConnection(
    DownloadIsolateMessage data,
  ) {
    if (data is HttpDownloadIsolateMessage) {
      return HttpDownloadConnection(
        downloadItem: data.downloadItem,
        segment: data.segment!,
        connectionNumber: data.connectionNumber!,
        settings: data.settings,
      );
    }
    if (data is M3u8DownloadIsolateMessage) {
      return M3U8DownloadConnection(
        downloadItem: data.downloadItem,
        m3u8segment: data.segment!,
        connectionNumber: data.connectionNumber!,
        settings: data.settings,
        segment: Segment(0, 0),
        refererHeader: data.refererHeader,
      );
    }
    return null;
  }

  static void _setStopCommandTracker(
    DownloadIsolateMessage data,
    StreamChannel channel,
  ) {
    final id = data.downloadItem.id;
    if (data.command == DownloadCommand.pause ||
        data.command == DownloadCommand.clearConnections) {
      stopCommandTrackerMap[id] = Pair(true, channel);
      _runCommandTrackerTimer();
    } else if (data.command == DownloadCommand.start) {
      stopCommandTrackerMap[id] = Pair(false, channel);
    }
  }

  static void _executeCommand(
    DownloadIsolateMessage data,
    IsolateChannel channel,
  ) {
    if (data is HttpDownloadIsolateMessage) {
      _executeCommandHttp(data, channel);
    }
    if (data is M3u8DownloadIsolateMessage) {
      _executeCommandM3u8(data, channel);
    }
  }

  static void _executeCommandM3u8(
    M3u8DownloadIsolateMessage data,
    IsolateChannel channel,
  ) {
    final id = data.downloadItem.id;
    final connectionNumber = data.connectionNumber;
    final connection =
        _connections[id]![connectionNumber]! as M3U8DownloadConnection;
    print(
        "Executing ${data.command} conn ${connectionNumber} segment ${data.segment}");
    switch (data.command) {
      case DownloadCommand.start_Initial:
        // connection.previousBufferEndByte = data.previouslyWrittenByteLength;
        connection.m3u8segment = data.segment!;
        connection.start(channel.sink.add);
        channel.sink.add(ConnectionHandshake.fromIsolateMessage(data));
        break;
      case DownloadCommand.start:
        connection.start(channel.sink.add);
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
      case DownloadCommand.resetConnection:
        connection.resetConnection();
        break;
      default:
        break;
    }
  }

  static void _executeCommandHttp(
    HttpDownloadIsolateMessage data,
    IsolateChannel channel,
  ) {
    final id = data.downloadItem.id;
    final connectionNumber = data.connectionNumber;
    final connection = _connections[id]![connectionNumber]!;
    connection.logger?.info(
      "Invoker:: Received command ${data.command} with segment ${data.segment}",
    );
    bool forcedConnectionReuse = false;
    if (shouldForceApplyReuseConnection(data)) {
      data.command = DownloadCommand.start_ReuseConnection;
      forceApplyReuseConnections[id]?.remove(connectionNumber);
      forcedConnectionReuse = true;
      connection.logger?.info("Invoker:: Forcing reuseConnection...");
    }
    switch (data.command) {
      case DownloadCommand.start_Initial:
        connection.previousBufferEndByte = data.previouslyWrittenByteLength;
        connection.start(channel.sink.add);
        channel.sink.add(ConnectionHandshake.fromIsolateMessage(data));
        break;
      case DownloadCommand.start:
        connection.start(channel.sink.add);
        break;
      case DownloadCommand.start_ReuseConnection:
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
        _connections[id]?.forEach((_, conn) => conn.client.close());
        _connections[id]?.clear();
        channel.sink.add(
          ConnectionsClearedMessage(
            downloadItem: data.downloadItem,
          ),
        );
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
