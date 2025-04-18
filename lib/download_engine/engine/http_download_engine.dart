import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:brisk/download_engine/channel/http_download_connection_channel.dart';
import 'package:brisk/download_engine/message/button_availability_message.dart';
import 'package:brisk/download_engine/message/connection_handshake_message.dart';
import 'package:brisk/download_engine/message/connection_segment_message.dart';
import 'package:brisk/download_engine/download_command.dart';
import 'package:brisk/download_engine/download_status.dart';
import 'package:brisk/download_engine/message/connections_cleared_message.dart';
import 'package:brisk/download_engine/message/http_download_isolate_message.dart';
import 'package:brisk/download_engine/message/log_message.dart';
import 'package:brisk/download_engine/segment/download_segment_tree.dart';
import 'package:brisk/download_engine/download_settings.dart';
import 'package:brisk/download_engine/message/internal_messages.dart';
import 'package:brisk/download_engine/channel/engine_channel.dart';
import 'package:brisk/download_engine/segment/segment.dart';
import 'package:brisk/download_engine/segment/segment_status.dart';
import 'package:brisk/download_engine/connection/download_connection_invoker.dart';
import 'package:brisk/download_engine/model/download_item_model.dart';
import 'package:brisk/download_engine/message/download_progress_message.dart';
import 'package:brisk/download_engine/message/download_isolate_message.dart';
import 'package:brisk/download_engine/util/temp_file_util.dart';
import 'package:brisk/model/isolate/isolate_args.dart';
import 'package:dartx/dartx.dart';
import 'package:dartx/dartx_io.dart';
import 'package:stream_channel/isolate_channel.dart';
import 'package:path/path.dart';

import '../../util/file_util.dart';
import '../../util/readability_util.dart';

/// Coordinates and manages download connections.
/// By default, each download request consists of 8 download connections that are tasked to receive their designated bytes and save them as temporary files.
/// For each download item, [start] will be called in a designated isolate spawned by the [DownloadRequestProvider].
/// The engine will track the state of the download connections, retrieve and aggregate data such as the overall download speed and progress,
/// manage the availability of pause/resume buttons and assemble the file when the all connections have finished receiving and writing their data.
///
/// TODO add ascii visual doc
///
/// TODO Write engine unit tests
/// TODO send pause command to isolates which are pending connection
/// TODO what if when we're still awaiting a segment refresh response from a connection, a refresh command is sent again! We should have a flag for each segment node
/// TODO add automatic bug report for fatal errors in the engine
/// TODO handle the case when a download is initially started using, for example, 8 connections, it is paused, then on the next start, it starts with only one connection
class HttpDownloadEngine {
  static const MINIMUM_DOWNLOAD_SEGMENT_LENGTH = 500000;

  static const _CONNECTION_REUSE_TIMER_DURATION_SEC = 2;

  static const _CONNECTION_SPAWNER_TIMER_DURATION_SEC = 2;

  static const _BUTTON_AVAILABILITY_NOTIFIER_TIMER_DURATION_SEC = 1;

  static const _CONNECTION_RESET_TIMER_DURATION_SEC = 4;

  static const BUTTON_AVAILABILITY_WAIT_SEC = 2;

  /// A map of all stream channels related to the running download requests
  /// key: downloadId
  static final Map<int, EngineChannel<HttpDownloadConnectionChannel>>
      _engineChannels = {};

  /// TODO Remove and use download channels
  static final Map<int, Map<int, DownloadProgressMessage>>
      _connectionProgresses = {};

  static final Map<int, DownloadProgressMessage> _downloadProgresses = {};

  /// TODO move to download channels
  static final Map<int, Map<int, Isolate>> _connectionIsolates = {};

  // TODO redundant
  static final Map<int, String> completionEstimations = {};

  /// The list of download IDs that should be ignored for dynamic connection spawn.
  /// This is used to prevent adding new connections when the user has stopped
  /// the download before all download connections have been spawned. In the
  /// mentioned situation, if dynamic connection spawn is not prevented,
  /// new connections will be added on the fly despite the download being in a
  /// paused state.
  static final List<int> _connectionSpawnerIgnoreList = [];

  static Timer? _dynamicConnectionReuseTimer = null;
  static Timer? _dynamicConnectionSpawnerTimer = null;
  static Timer? _buttonAvailabilityTimer = null;
  static Timer? _connectionResetTimer = null;

  static late DownloadSettings downloadSettings;

  /// Adds download connections on the fly
  static void _runDynamicConnectionSpawner() {
    _engineChannels.forEach((downloadId, _) {
      final downloadProgress = _downloadProgresses[downloadId];
      if (downloadProgress == null) {
        return;
      }
      if (_shouldCreateNewConnections(downloadId)) {
        _refreshConnectionSegments(downloadId);
      }
    });
  }

  /// Notifies the UI when the start button is available. Since there will not
  /// be any new messages coming from connections after pausing the download, [_setButtonAvailability]
  /// will not be able to notify the UI when the start button is available. Therefore, this timer
  /// is executed periodically to solve this problem.
  static void _startButtonAvailabilityNotifierTimer() {
    if (_buttonAvailabilityTimer != null) {
      return;
    }
    _buttonAvailabilityTimer = Timer.periodic(
      Duration(seconds: _BUTTON_AVAILABILITY_NOTIFIER_TIMER_DURATION_SEC),
      (_) => _runButtonAvailabilityNotifier(),
    );
  }

  static void _runButtonAvailabilityNotifier() {
    _engineChannels.forEach((downloadId, engineChannel) {
      if (engineChannel.downloadItem == null || !engineChannel.paused) {
        return;
      }
      final message = ButtonAvailabilityMessage(
        downloadItem: engineChannel.downloadItem!,
        pauseButtonEnabled: false,
        startButtonEnabled: engineChannel.isStartButtonWaitComplete,
      );
      engineChannel.sendMessage(message);
    });
  }

  static void _startConnectionResetTimer() {
    if (_connectionResetTimer != null) {
      return;
    }
    _connectionResetTimer = Timer.periodic(
      Duration(seconds: _CONNECTION_RESET_TIMER_DURATION_SEC),
      (_) => _runConnectionResetTimer(),
    );
  }

  static void _runConnectionResetTimer() {
    _engineChannels.forEach((downloadId, engineChannel) {
      if (engineChannel.downloadItem == null || engineChannel.paused) {
        return;
      }
      final connectionsToReset = engineChannel.connectionChannels.values
          .where((conn) =>
              conn.detailsStatus != DownloadStatus.paused &&
              conn.detailsStatus != DownloadStatus.canceled &&
              conn.detailsStatus != DownloadStatus.connectionComplete)
          .toList()
          .where((conn) =>
              (conn.resetCount < downloadSettings.maxConnectionRetryCount ||
                  downloadSettings.maxConnectionRetryCount == -1) &&
              conn.lastResponseTime + downloadSettings.connectionRetryTimeout <
                  _nowMillis)
          .toList();

      for (final connection in connectionsToReset) {
        final message = HttpDownloadIsolateMessage(
          command: DownloadCommand.resetConnection,
          downloadItem: engineChannel.downloadItem!,
          settings: downloadSettings,
          connectionNumber: connection.connectionNumber,
        );
        engineChannel.connectionChannels[connection.connectionNumber]
            ?.awaitingResetResponse = true;
        connection.sendMessage(message);
        connection.resetCount++;
      }
    });
  }

  /// Manages connection reuse which allows for completed connections to receive
  /// the remaining bytes of other connections, thus keeping the maximum number
  /// of connections active throughout the entirety of the download.
  static void _startDynamicConnectionReuseTimer() {
    if (_dynamicConnectionReuseTimer != null) {
      return;
    }
    _dynamicConnectionSpawnerTimer = Timer.periodic(
      Duration(seconds: _CONNECTION_REUSE_TIMER_DURATION_SEC),
      (_) => _runDynamicConnectionReuse(),
    );
  }

  static void _startDynamicConnectionSpawnerTimer() {
    if (_dynamicConnectionSpawnerTimer != null) {
      return;
    }
    _dynamicConnectionSpawnerTimer = Timer.periodic(
      Duration(seconds: _CONNECTION_SPAWNER_TIMER_DURATION_SEC),
      (_) => _runDynamicConnectionSpawner(),
    );
  }

  static void _runDynamicConnectionReuse() {
    _engineChannels.forEach((downloadId, engineChannel) {
      final queue = engineChannel.connectionReuseQueue;
      final prog = _downloadProgresses[downloadId]?.totalDownloadProgress ?? 0;
      if (queue.isEmpty ||
          _shouldCreateNewConnections(downloadId) ||
          engineChannel.awaitingConnectionResetResponse ||
          prog >= 1) {
        return;
      }
      final connectionChannel = queue.removeFirst();
      engineChannel.logger?.info(
        "Sending refresh segment for conn ${connectionChannel.connectionNumber}",
      );
      _sendRefreshSegmentCommand_ReuseConnection(connectionChannel);
    });
  }

  static void start(IsolateSingleArg<int> args) async {
    final providerChannel = IsolateChannel.connectSend(args.sendPort);
    final engineChannel = EngineChannel<HttpDownloadConnectionChannel>(
      channel: providerChannel,
    );
    _engineChannels[args.obj] = engineChannel;
    _startEngineTimers();
    engineChannel.listenToStream<HttpDownloadIsolateMessage>((data) async {
      downloadSettings = data.settings;
      _setConnectionSpawnIgnoreList(data);
      final downloadItem = data.downloadItem;
      final id = downloadItem.id;
      if (isAssembledFileInvalid(downloadItem)) {
        File(downloadItem.filePath).deleteSync();
      }
      _setFutureCommandExecution(data);
      await sendToDownloadIsolates(data, providerChannel);
      for (final channel in _engineChannels[id]!.connectionChannels.values) {
        channel.listenToStream(_handleConnectionMessages);
      }
    });
  }

  static void _setFutureCommandExecution(DownloadIsolateMessage message) {
    if (message.command != DownloadCommand.pause) {
      return;
    }
    final downloadChannel = _engineChannels[message.downloadItem.id]!;
    if (downloadChannel.pendingHandshakes.length > 0) {
      downloadChannel.pauseOnFinalHandshake = true;
    }
  }

  static void _startEngineTimers() {
    _startDynamicConnectionSpawnerTimer();
    _startDynamicConnectionReuseTimer();
    _startButtonAvailabilityNotifierTimer();
    _startConnectionResetTimer();
  }

  static void _setConnectionSpawnIgnoreList(DownloadIsolateMessage data) {
    if (data.command == DownloadCommand.pause) {
      _connectionSpawnerIgnoreList.add(data.downloadItem.id);
    }
    if (data.command == DownloadCommand.start) {
      _connectionSpawnerIgnoreList.remove(data.downloadItem.id);
    }
  }

  static void _refreshConnectionSegments(int downloadId) {
    final progress = _downloadProgresses[downloadId];
    if (progress == null) {
      return;
    }
    final engineChannel = _engineChannels[downloadId]!;
    final logger = engineChannel.logger;
    if (engineChannel.segmentTree == null) return;
    try {
      engineChannel.segmentTree!.split();
    } catch (e) {
      logger?.error("_refreshConnectionSegments:: Fatal! ${e}");
      return;
    }
    final nodes = engineChannel.segmentTree!.lowestLevelNodes;
    logger?.info("refreshing connection segments...");
    logger?.info("Current segment tree lowest level nodes:");
    nodes.forEach(
      (element) => engineChannel.logger?.info(element.segment.toString()),
    );
    final segmentNodes = engineChannel.segmentTree!.lowestLevelNodes;
    engineChannel.connectionChannels.forEach((connNum, connectionChannel) {
      final relatedSegmentNode =
          segmentNodes.where((s) => s.connectionNumber == connNum).firstOrNull;
      if (relatedSegmentNode == null) {
        logger?.error(
          "Fatal error occurred! relatedSegmentNode is null!",
        );
        return;
      }
      final data = HttpDownloadIsolateMessage(
        command: DownloadCommand.refreshSegment,
        downloadItem: _downloadProgresses[downloadId]!.downloadItem,
        connectionNumber: connNum,
        segment: relatedSegmentNode.segment,
        settings: downloadSettings,
      );
      relatedSegmentNode.segmentStatus = SegmentStatus.REFRESH_REQUESTED;
      relatedSegmentNode.setLastUpdateMillis();
      engineChannel.createdConnections++;
      connectionChannel.sendMessage(data);
      logger?.info(
        "Command ${data.command} with segment ${relatedSegmentNode.segment} sent to connection $connNum",
      );
    });
  }

  static bool isDownloadNearCompletion(int downloadId) {
    final estimate = _downloadProgresses[downloadId]?.estimatedRemaining ?? "";
    return estimate.contains("Seconds") &&
        !estimate.contains(",") &&
        ((int.tryParse(estimate.replaceAll(" Seconds", "")) ?? 100) < 5);
  }

  static bool _shouldCreateNewConnections(int downloadId) {
    final progress = _downloadProgresses[downloadId]!;
    final engineChannel = _engineChannels[downloadId];
    final pendingSegmentExists = _engineChannels[downloadId]!
            .segmentTree
            ?.lowestLevelNodes
            .any((s) => s.segmentStatus == SegmentStatus.REFRESH_REQUESTED) ??
        true;

    return !pendingSegmentExists &&
        progress.connectionProgresses.length <
            downloadSettings.totalConnections &&
        engineChannel!.createdConnections < downloadSettings.totalConnections &&
        !_connectionSpawnerIgnoreList.contains(downloadId) &&
        !isDownloadNearCompletion(downloadId);
  }

  /// Handles the messages coming from [BaseHttpDownloadConnection]
  static void _handleConnectionMessages(message) async {
    switch (message.runtimeType) {
      case DownloadProgressMessage:
        _handleProgressUpdates(message);
        break;
      case ConnectionsClearedMessage:
        _handleConnectionsClearedMessage(message);
        break;
      case ConnectionSegmentMessage:
        _handleSegmentMessage(message);
        break;
      case ConnectionHandshake:
        _handleConnectionHandshakeMessage(message);
        break;
      case LogMessage:
        _handleLogMessage(message);
        break;
      default:
        break;
    }
  }

  static void _handleConnectionsClearedMessage(
    ConnectionsClearedMessage message,
  ) {
    final id = message.downloadItem.id;
    _connectionIsolates[id]?.forEach((_, isolate) => isolate.kill(priority: 0));
    _connectionIsolates[id]?.clear();
    _engineChannels[id]?.sendMessage(message);
    _engineChannels.remove(id);
    _connectionProgresses.remove(id);
    _downloadProgresses.remove(id);
  }

  static void _handleConnectionHandshakeMessage(ConnectionHandshake message) {
    final engineChannel = _engineChannels[message.downloadItem.id]!;
    engineChannel.logger?.info(
      "Received handshake ${message.newConnectionNumber}",
    );
    engineChannel.pendingHandshakes.removeWhere(
      (h) => h.newConnectionNumber == message.newConnectionNumber,
    );
    if (message.reuseConnection) {
      engineChannel.segmentTree?.lowestLevelNodes
          .where(
            (node) =>
                node.segmentStatus == SegmentStatus.REUSE_REQUESTED &&
                node.connectionNumber == message.newConnectionNumber,
          )
          .firstOrNull
          ?.segmentStatus = SegmentStatus.IN_USE;
    }
    if (engineChannel.pendingHandshakes.length == 0 &&
        engineChannel.pauseOnFinalHandshake) {
      engineChannel.connectionChannels.forEach((connNum, conn) {
        // final pauseCommand = DownloadIsolateMessage(
        //   command: DownloadCommand.pause,
        //   downloadItem: message.downloadItem,
        //   settings: downloadSettings,
        //   connectionNumber: connNum,
        // );
        // conn.sendMessage(pauseCommand);
      });
    }
  }

  static void _handleLogMessage(LogMessage message) {
    final engineChannel = _engineChannels[message.downloadItem.id];
    engineChannel?.logger
      ?..logBuffer.writeln(message.log)
      ..writeLogBuffer();
  }

  static void _handleSegmentMessage(ConnectionSegmentMessage message) {
    _engineChannels[message.downloadItem.id]?.logger?.info(
          "Handling refresh segment response : ${message.internalMessage}",
        );
    switch (message.internalMessage) {
      case InternalMessage.REFRESH_SEGMENT_SUCCESS:
        _handleRefreshSegmentSuccess(message);
        break;
      case InternalMessage.OVERLAPPING_REFRESH_SEGMENT:
        _handleOverlappingSegment(message);
        break;
      case InternalMessage.REUSE_CONNECTION__REFRESH_SEGMENT_REFUSED:
      case InternalMessage.REFRESH_SEGMENT_REFUSED:
        _handleRefreshSegmentRefused(message);
        break;
      default:
        break;
    }
  }

  static void _addHandshake(int downloadId, int connectionNumber) {
    final handshake = EngineConnectionHandshake(
      newConnectionNumber: connectionNumber,
    );
    final downloadChannel = _engineChannels[downloadId];
    downloadChannel?.pendingHandshakes.add(handshake);
  }

  static void _handleRefreshSegmentRefused(ConnectionSegmentMessage message) {
    final node = findSegmentNode(message);
    final tree = _engineChannels[message.downloadItem.id]!.segmentTree!;
    final engineChannel = _engineChannels[message.downloadItem.id]!;
    final logger = engineChannel.logger;
    if (node == null) {
      logger?.error(
        "Fatal error occurred! Failed to find requested segment node!",
      );
      return;
    }
    final parent = node.parent!;
    if (message.reuseConnection) {
      final connNum = parent.rightChild!.connectionNumber;
      final connection = engineChannel.connectionChannels[connNum]!;
      engineChannel.connectionReuseQueue.add(connection);
      logger?.info("Added connection $connNum to connection queue");
    } else {
      // TODO We should probably handle this better
      // _engineChannels[message.downloadItem.id]!.createdConnections--;
    }
    final l_index = tree.lowestLevelNodes
        .indexWhere((node) => node.segment == parent.leftChild!.segment);
    if (l_index != -1) {
      // parent.segmentStatus = SegmentStatus.IN_USE;
      tree.lowestLevelNodes
        ..insert(l_index, parent)
        ..removeWhere((node) => node.segment == parent.rightChild!.segment)
        ..removeWhere((node) => node.segment == parent.leftChild!.segment);
    } else {
      logger?.info(
        "RefreshSegmentRefused:: Fatal error occurred! Failed to find segment node to insert",
      );
    }
    parent
      ..removeChildren()
      ..setLastUpdateMillis();
  }

  /// TODO add doc
  static void _handleOverlappingSegment(ConnectionSegmentMessage message) {
    final node = findSegmentNode(message);
    final logger = _engineChannels[message.downloadItem.id]?.logger;
    if (node == null) {
      logger?.error("Fatal! Failed to find requested segment node!");
      return;
    }
    final parent = node.parent!;
    parent.leftChild!.segment = Segment(
      message.refreshedStartByte!,
      message.refreshedEndByte!,
    );

    parent
      ..setLastUpdateMillis()
      ..leftChild?.setLastUpdateMillis()
      ..segmentStatus = SegmentStatus.OUT_DATED
      ..leftChild?.segmentStatus = SegmentStatus.IN_USE
      ..rightChild?.segmentStatus = SegmentStatus.REUSE_REQUESTED;

    final newConnectionNode = parent.rightChild!;
    newConnectionNode.segment = Segment(
      message.validNewStartByte!,
      message.validNewEndByte!,
    );
    newConnectionNode.setLastUpdateMillis();
    if (message.reuseConnection) {
      _sendStartCommand_ReuseConnection(
        message.downloadItem,
        newConnectionNode.connectionNumber,
        newConnectionNode.segment,
      );
      newConnectionNode.segmentStatus = SegmentStatus.IN_USE;
    } else {
      _createDownloadConnection(
        message.downloadItem,
        newConnectionNode,
        newConnectionNode.connectionNumber,
      );
      _addHandshake(
        message.downloadItem.id,
        newConnectionNode.connectionNumber,
      );
    }
  }

  static void _handleRefreshSegmentSuccess(ConnectionSegmentMessage message) {
    final node = findSegmentNode(message);
    final logger = _engineChannels[message.downloadItem.id]?.logger;
    if (node == null) {
      logger?.info(
        "_handleRefreshSegmentSuccess:: Failed to find segment node. Fatal!",
      );
      return;
    }
    final parent = node.parent!;
    parent.segmentStatus = SegmentStatus.OUT_DATED;
    parent.setLastUpdateMillis();
    final connectionNode = parent.rightChild!;
    if (message.reuseConnection) {
      _sendStartCommand_ReuseConnection(
        message.downloadItem,
        connectionNode.connectionNumber,
        connectionNode.segment,
      );
    } else {
      _createDownloadConnection(
        message.downloadItem,
        connectionNode,
        connectionNode.connectionNumber,
      );
      _addHandshake(
        message.downloadItem.id,
        connectionNode.connectionNumber,
      );
    }
    parent.leftChild!.segmentStatus = SegmentStatus.IN_USE;
    connectionNode.segmentStatus = SegmentStatus.IN_USE;
    connectionNode.setLastUpdateMillis();
    parent.leftChild?.setLastUpdateMillis();
  }

  static void _sendStartCommand_ReuseConnection(
    DownloadItemModel downloadItem,
    int connectionNumber,
    Segment segment,
  ) {
    final data = HttpDownloadIsolateMessage(
      command: DownloadCommand.start_ReuseConnection,
      downloadItem: downloadItem,
      settings: downloadSettings,
      segment: segment,
      connectionNumber: connectionNumber,
    );
    final engineChannel = _engineChannels[downloadItem.id]!;
    final connection = engineChannel.connectionChannels[connectionNumber]!;
    connection.sendMessage(data);
    engineChannel.logger?.info(
      "Sent command ${data.command} with segment ${data.segment} to connection ${data.connectionNumber}",
    );
  }

  static SegmentNode? findSegmentNode(ConnectionSegmentMessage message) {
    final id = message.downloadItem.id;
    final logger = _engineChannels[id]!.logger;
    final tree = _engineChannels[id]!.segmentTree!;
    final node = tree.searchNode(message.requestedSegment);
    if (node == null) {
      logger?.error("Failed to find segment node");
    }
    return node;
  }

  static void _handleProgressUpdates(DownloadProgressMessage progress) {
    final downloadItem = progress.downloadItem;
    final downloadId = downloadItem.id;
    final engineChannel = _engineChannels[downloadItem.id]!;
    final logger = engineChannel.logger;
    if (engineChannel.assembleRequested) {
      return;
    }
    _connectionProgresses[downloadId] ??= {};
    _connectionProgresses[downloadId]![progress.connectionNumber] = progress;
    final totalByteTransferRate = _calculateTotalTransferRate(downloadId);
    final isTempWriteComplete = checkTempWriteCompletion(downloadItem);
    final totalProgress = _calculateTotalDownloadProgress(downloadId);
    _calculateEstimatedRemaining(downloadId, totalByteTransferRate);
    final downloadProgress = DownloadProgressMessage(
      downloadItem: downloadItem,
      downloadProgress: totalProgress,
      totalDownloadProgress: totalProgress,
      transferRate: convertByteTransferRateToReadableStr(totalByteTransferRate),
    );
    _setEstimation(downloadProgress, totalProgress);
    if (progress.status == DownloadStatus.downloading) {
      engineChannel.connectionChannels[progress.connectionNumber]
          ?.awaitingResetResponse = false;
    }
    _setButtonAvailability(downloadProgress, totalProgress);
    _setStatus(downloadId, downloadProgress); // TODO broken
    if (progress.completionSignal) {
      logger?.info(
        "Received completion signal from connection ${progress.connectionNumber}",
      );
      _addToReuseQueue(progress);
      _setSegmentComplete(progress);
    }
    if (isTempWriteComplete && isAssembleEligible(downloadItem)) {
      engineChannel.sendMessage(downloadProgress);
      final success = assembleFile(
        progress.downloadItem,
        progressChannel: engineChannel.channel,
      );

      /// TODO add proper progress indication. currently it only notifies when the assemble is complete
      _setCompletionStatuses(success, downloadProgress);
      logger
        ?..writeLogBuffer()
        ..flushTimer?.cancel();
    }
    _setConnectionProgresses(downloadProgress);
    _downloadProgresses[downloadId] = downloadProgress;
    engineChannel.sendMessage(downloadProgress);
  }

  static void _addToReuseQueue(DownloadProgressMessage progress) {
    final downloadId = progress.downloadItem.id;
    final engineChannel = _engineChannels[downloadId];
    final conn = engineChannel!.connectionChannels[progress.connectionNumber]!;
    final reuseQueue = _engineChannels[downloadId]!.connectionReuseQueue;
    if (!reuseQueue.contains(conn)) {
      reuseQueue.add(conn);
    }
  }

  static void _setSegmentComplete(DownloadProgressMessage progress) {
    final downloadId = progress.downloadItem.id;
    final tree = _engineChannels[downloadId]!.segmentTree!;
    final logger = _engineChannels[downloadId]!.logger;
    final node = tree.searchNode(progress.segment!);
    if (node == null) {
      logger?.error("setSegmentComplete:: Failed to find node!");
    }
    node?.segmentStatus = SegmentStatus.COMPLETE;
  }

  /// Reassigns a connection that has finished receiving its bytes to a new segment
  static void _sendRefreshSegmentCommand_ReuseConnection(
    HttpDownloadConnectionChannel connectionChannel,
  ) {
    final downloadId = connectionChannel.downloadItem!.id;
    final engineChannel = _engineChannels[downloadId]!;
    final logger = engineChannel.logger;
    final segmentTree = engineChannel.segmentTree;
    final nodes = segmentTree!.inQueueNodes!.isNotEmpty
        ? segmentTree.inQueueNodes
        : segmentTree.inUseNodes;
    if (nodes!.isEmpty) {
      logger?.error(
        "_sendRefreshSegmentCommand_ReuseConnection:: Fatal! Failed to find segment node!",
      );
      return;
    }
    nodes.sort((a, b) => a.segment.length.compareTo(b.segment.length));
    final targetNode = nodes
        .where((node) => node.segment != connectionChannel.segment)
        .toList()
        .firstOrNull;
    if (targetNode == null) {
      logger?.error(
        "_sendRefreshSegmentCommand_ReuseConnection:: Fatal! Target node is null!",
      );
      return;
    }
    logger?.info("Splitting segment node ${targetNode.segment}...");
    bool success = false;
    try {
      success = segmentTree.splitSegmentNode(
        targetNode,
        setConnectionNumber: false,
      );
    } catch (e) {
      logger?.error("Fatal! ${e.toString()}");
    }

    /// TODO retry with a different node (has to stop at some point tho)
    if (!success) {
      logger?.warn(
        "Failed to split segment node ${targetNode.segment}. skipping...",
      );
      return;
    }
    logger?.info(
      "Split segment node : Parent ${targetNode.segment} ==> "
      "leftNode:: ${targetNode.leftChild!.segment} "
      "rightNode :: ${targetNode.rightChild!.segment}",
    );
    targetNode.rightChild?.connectionNumber =
        connectionChannel.connectionNumber;
    targetNode
      ..segmentStatus = SegmentStatus.REFRESH_REQUESTED
      ..leftChild?.segmentStatus = SegmentStatus.REFRESH_REQUESTED
      ..rightChild?.segmentStatus = SegmentStatus.INITIAL;
    final oldestSegmentConnection = engineChannel.connectionChannels.values
        .where((conn) => conn.segment == targetNode.segment)
        .firstOrNull;
    logger?.info("Segment tree in reuseConnection :");
    segmentTree.lowestLevelNodes.forEach((element) {
      logger?.info(
        "${element.segment} ==> ${element.connectionNumber} ==> ${element.segmentStatus}",
      );
    });
    if (oldestSegmentConnection == null) {
      logger?.error("Fatal! Failed to find oldest connection! List is :");
      engineChannel.connectionChannels.forEach((_, conn) {
        logger?.info("Conn:${conn.connectionNumber} => ${conn.segment}");
      });
      return;
    }
    logger?.info(
      "Sending refresh segment request to connection ${oldestSegmentConnection.connectionNumber}",
    );
    final data = HttpDownloadIsolateMessage(
      command: DownloadCommand.refreshSegment_reuseConnection,
      downloadItem: connectionChannel.downloadItem!,
      connectionNumber: oldestSegmentConnection.connectionNumber,
      segment: targetNode.leftChild!.segment,
      settings: downloadSettings,
    );
    oldestSegmentConnection.sendMessage(data);
  }

  static void _createDownloadConnection(
    DownloadItemModel downloadItem,
    SegmentNode segmentNode,
    int connectionNumber,
  ) async {
    final logger = _engineChannels[downloadItem.id]!.logger;
    final data = HttpDownloadIsolateMessage(
      command: DownloadCommand.start_Initial,
      downloadItem: downloadItem,
      settings: downloadSettings,
      segment: segmentNode.segment,
    );
    logger?.info(
      "Creating connection ${connectionNumber} :: ${segmentNode.segment}",
    );
    await _spawnSingleDownloadIsolate(data, connectionNumber);
    segmentNode.segmentStatus = SegmentStatus.IN_USE;
  }

  static Future<void> sendToDownloadIsolates(
    HttpDownloadIsolateMessage data,
    IsolateChannel handlerChannel,
  ) async {
    final int id = data.downloadItem.id;
    Completer<void> completer = Completer();
    final engineChannel = _engineChannels[id];
    final logger = engineChannel?.logger;
    if (engineChannel!.connectionChannels.isEmpty) {
      validateTempFilesIntegrity(
        data.downloadItem,
        checkForMissingTempFile: false,
        progressUpdateChannel: handlerChannel,
      );
      final missingByteRanges = _findMissingByteRanges(data.downloadItem);
      if (missingByteRanges.isEmpty && isAssembleEligible(data.downloadItem)) {
        assembleFile(
          data.downloadItem,
          progressChannel: engineChannel.channel,
          notifyProgress: true,
        );
        return;
      }
      missingByteRanges.forEach((element) {
        logger?.info("MissingByteRange:::: $element");
      });
      logger?.info("Building tree...");
      engineChannel.segmentTree = DownloadSegmentTree.buildFromMissingBytes(
        data.downloadItem.contentLength,
        downloadSettings.totalConnections,
        missingByteRanges,
      );
      // If the tree was built on top of existing temp files, the dynamic connection spawner
      // should not be executed because multiple segments are already assigned to connections.
      // therefore we set the created connections to the max allowed value.
      logger?.info(
        "Tree lowest level nodes : ${engineChannel.segmentTree!.lowestLevelNodes.map((e) => e.segment).toList()}",
      );
      if (engineChannel.segmentTree!.lowestLevelNodes.length != 1) {
        engineChannel.createdConnections = downloadSettings.totalConnections;
      }
      logger?.info("Built the download segment tree from temp files");
      engineChannel.segmentTree!.lowestLevelNodes.forEach((element) {
        logger?.info("${element.segment} ==> ${element.segmentStatus}");
      });
      data.command = DownloadCommand.start_Initial;
      await _spawnDownloadIsolates(data);
    } else {
      _engineChannels[id]?.connectionChannels.forEach((connNum, connection) {
        final newData = data.clone()..connectionNumber = connNum;
        logger?.info(
          "Sent Command ${data.command} with segment ${data.segment} to connection $connNum",
        );
        connection.sendMessage(newData);
      });
    }
    return completer.complete();
  }

  static _spawnDownloadIsolates(HttpDownloadIsolateMessage data) async {
    final id = data.downloadItem.id;
    final segmentTree = _engineChannels[id]!.segmentTree!;
    segmentTree.lowestLevelNodes
        .where((node) => node.segmentStatus == SegmentStatus.INITIAL)
        .toList()
        .forEach((segmentNode) {
      var newData = data.clone()..segment = segmentNode.segment;
      segmentNode.segmentStatus = SegmentStatus.IN_USE;
      final completedSegments = segmentTree.lowestLevelNodes
          .where((node) =>
              node.segmentStatus == SegmentStatus.COMPLETE &&
              node.connectionNumber == segmentNode.connectionNumber)
          .map((e) => e.segment.length)
          .toList();
      int completedLength = completedSegments.isEmpty
          ? 0
          : completedSegments.reduce((first, second) => first + second);
      data.previouslyWrittenByteLength = completedLength;
      _spawnSingleDownloadIsolate(newData, segmentNode.connectionNumber);
    });
  }

  /// Analyzes the temp files and returns the missing temp byte ranges
  static List<Segment> _findMissingByteRanges(
    DownloadItemModel downloadItem,
  ) {
    final contentLength = downloadItem.contentLength;
    List<File>? tempFiles;
    final tempDirPath = join(
      downloadSettings.baseTempDir.path,
      downloadItem.uid,
    );
    final tempDir = Directory(tempDirPath);
    if (tempDir.existsSync()) {
      tempFiles = tempDir.listSync().map((o) => o as File).toList();
    }

    if (tempFiles == null || tempFiles.isEmpty) {
      return [Segment(0, downloadItem.contentLength)];
    }

    tempFiles.sort(sortByByteRanges);
    String prevFileName = "";
    List<Segment> missingBytes = [];
    for (var i = 0; i < tempFiles.length; i++) {
      final tempFile = tempFiles[i];
      final tempFileName = basename(tempFile.path);
      if (prevFileName == "") {
        prevFileName = tempFileName;
        final startByte = getStartByteFromTempFileName(tempFileName);
        if (startByte != 0) {
          missingBytes.add(Segment(0, startByte - 1));
        }
        continue;
      }

      final startByte = getStartByteFromTempFileName(tempFileName);
      final endByte = getEndByteFromTempFileName(tempFileName);
      final prevEndByte = getEndByteFromTempFileName(prevFileName);

      if (prevEndByte + 1 != startByte) {
        final missingStartByte = prevEndByte + 1;
        final missingEndByte = startByte - 1;
        missingBytes.add(Segment(missingStartByte, missingEndByte));
      }
      prevFileName = tempFileName;

      /// endByte is always contentLength - 1, but just to be sure we also add
      /// the endByte != contentLength
      if (i == tempFiles.length - 1 &&
          (endByte != contentLength - 1 && endByte != contentLength)) {
        missingBytes.add(Segment(endByte + 1, contentLength));
      }
    }
    return missingBytes..sort((a, b) => a.startByte.compareTo(b.startByte));
  }

  static bool isAssembleEligible(DownloadItemModel downloadItem) {
    return downloadItem.status != DownloadStatus.assembleComplete &&
        downloadItem.status != DownloadStatus.assembleFailed &&
        !_engineChannels[downloadItem.id]!.assembleRequested;
  }

  /// Checks all temp files and optionally removes all files that are considered to be corrupted.
  /// e.g. If a file does not correspond to the byte range it is named as,
  /// or if the byte range of multiple temp files clash with each other.
  static void validateTempFilesIntegrity(
    DownloadItemModel downloadItem, {
    bool deleteCorruptedTempFiles = true,
    bool checkForMissingTempFile = true,
    IsolateChannel? progressUpdateChannel,
  }) {
    final logger = _engineChannels[downloadItem.id]!.logger;
    var progress = _downloadProgresses[downloadItem.id] ??
        DownloadProgressMessage(downloadItem: downloadItem);
    progress
      ..downloadItem = downloadItem
      ..status = DownloadStatus.validatingFiles
      ..downloadItem.status = DownloadStatus.validatingFiles;
    _engineChannels[downloadItem.id]!.sendMessage(progress);
    logger?.info("Validating temp files integrity...");
    List<File> tempFilesToDelete = [];
    final tempPath = join(downloadSettings.baseTempDir.path, downloadItem.uid);
    final tempDir = Directory(tempPath);
    final tempFiles = getTempFilesSorted(tempDir);
    if (tempFiles.isEmpty) {
      return;
    }
    for (int i = 0; i < tempFiles.length; i++) {
      progress.integrityValidationProgress = i / tempFiles.length;
      progressUpdateChannel?.sink.add(progress);
      final file = tempFiles[i];
      final end = getEndByteFromTempFile(file);
      final start = getStartByteFromTempFile(file);
      if (end - start + 1 != file.lengthSync()) {
        logger?.info("Found bad length :: ${basename(file.path)}");
        tempFilesToDelete.add(file);
      }
      if (start > downloadItem.contentLength ||
          end > downloadItem.contentLength) {
        logger?.info(
          "Found byte range exceeding contentLength :: ${basename(file.path)}",
        );
        tempFilesToDelete.add(file);
      }
      if (i == tempFiles.length - 1) {
        continue;
      }
      final nextFile = tempFiles[i + 1];
      final startNext = getStartByteFromTempFile(nextFile);
      // Cases where there is a single missing byte
      if (startNext - end == 2) {
        tempFilesToDelete.add(file);
        if (i - 1 < 0) {
          tempFilesToDelete.add(tempFiles[i + 1]);
        } else {
          tempFilesToDelete.add(tempFiles[i - 1]);
        }
      }
      if (checkForMissingTempFile && startNext - 1 != end) {
        logger?.info(
          "Found inconsistent temp file :: ${basename(file.path)} == ${basename(nextFile.path)}",
        );
      }
      final badTempFiles = tempFiles.where((f) => f != file).where((f) {
        final fileSegment = Segment(
          getStartByteFromTempFile(f),
          getEndByteFromTempFile(f),
        );
        final currentFileSegment = Segment(start, end);

        final fileOverlapsWithCurrent =
            fileSegment.overlapsWithOther(currentFileSegment);

        final currentOverlapsWithFile =
            currentFileSegment.overlapsWithOther(fileSegment);

        if (fileOverlapsWithCurrent || currentOverlapsWithFile) {
          logger?.info(
            "Found overlapping temp files : ${basename(file.path)} === ${basename(f.path)}",
          );
          return true;
        }
        return false;
      }).toList();
      tempFilesToDelete.addAll(badTempFiles);
      for (final badFile in badTempFiles) {
        logger?.info("Bad file :: ${basename(badFile.path)}");
      }
    }
    if (deleteCorruptedTempFiles) {
      tempFilesToDelete.toSet().forEach((file) {
        logger?.info("Deleting bad temp file ${basename(file.path)}...");
        try {
          file.deleteSync();
        } catch (e) {
          logger?.error("Failed to delete file ${basename(file.path)}! $e");
          rethrow;
        }
      });
    }
  }

  /// Writes all the file parts inside the temp folder into one file therefore
  /// creating the final downloaded file.
  static bool assembleFile(
    DownloadItemModel downloadItem, {
    bool notifyProgress = false,
    required IsolateChannel progressChannel,
  }) {
    final engineChannel = _engineChannels[downloadItem.id]!;
    final progress = _downloadProgresses[downloadItem.id] ??
        DownloadProgressMessage(
          downloadItem: downloadItem,
        );
    progress
      ..downloadItem.status = DownloadStatus.assembling
      ..totalDownloadProgress = 1
      ..downloadProgress = 1
      ..status = DownloadStatus.assembling;
    engineChannel.sendMessage(progress);
    engineChannel.assembleRequested = true;
    final logger = engineChannel.logger;
    final tempPath = join(downloadSettings.baseTempDir.path, downloadItem.uid);
    final tempDir = Directory(tempPath);
    final tempFiles = getTempFilesSorted(tempDir);
    File fileToWrite = File(downloadItem.filePath);
    if (fileToWrite.existsSync()) {
      var newFilePath = FileUtil.getFilePath(
        downloadItem.fileName,
        baseSaveDir: downloadSettings.baseSaveDir,
        checkFileDuplicationOnly: true,
      );
      fileToWrite = File(newFilePath);
    }
    try {
      fileToWrite.createSync(recursive: true);
    } catch (e) {
      var newFilePath = FileUtil.getFilePath(
        downloadItem.uid + extension(downloadItem.fileName),
        baseSaveDir: downloadSettings.baseSaveDir,
        checkFileDuplicationOnly: true,
      );
      fileToWrite = File(newFilePath);
      fileToWrite.createSync(recursive: true);
    }
    logger?.info("Creating file...");
    for (int i = 0; i < tempFiles.length; i++) {
      progress.assembleProgress = i / tempFiles.length;
      progressChannel.sink.add(progress);
      var file = tempFiles[i];
      final bytes = file.readAsBytesSync();
      fileToWrite.writeAsBytesSync(bytes, mode: FileMode.writeOnlyAppend);
    }
    final assembleSuccessful =
        fileToWrite.lengthSync() == downloadItem.contentLength;
    if (assembleSuccessful) {
      _connectionIsolates[downloadItem.id]?.values.forEach((isolate) {
        isolate.kill();
      });
      tempDir.deleteSync(recursive: true);
    } else {
      logger?.error(
        "Assemble failed! written file length = ${fileToWrite.lengthSync()} expected file length = ${downloadItem.contentLength}",
      );
    }
    if (notifyProgress) {
      _setCompletionStatuses(assembleSuccessful, progress);
      engineChannel.sendMessage(progress);
    }
    if (assembleSuccessful) {
      logger
        ?..writeLogBuffer()
        ..logBuffer.clear()
        ..flushTimer?.cancel();
      _engineChannels.remove(engineChannel);
    }
    return assembleSuccessful;
  }

  static void _setConnectionProgresses(DownloadProgressMessage progress) {
    final id = progress.downloadItem.id;
    _connectionProgresses[id] ??= {};
    progress.connectionProgresses = _connectionProgresses[id]!.values.toList();
  }

  static void _setCompletionStatuses(
    bool success,
    DownloadProgressMessage downloadProgress,
  ) {
    if (success) {
      downloadProgress.assembleProgress = 1;
      downloadProgress.status = DownloadStatus.assembleComplete;
      downloadProgress.downloadItem.status = DownloadStatus.assembleComplete;
      downloadProgress.downloadItem.finishDate = DateTime.now();
    } else {
      downloadProgress.status = DownloadStatus.assembleFailed;
      downloadProgress.downloadItem.status = DownloadStatus.assembleFailed;
    }
    downloadProgress.buttonAvailability = ButtonAvailability(false, false);
    downloadProgress.transferRate = "";
  }

  static void _setEstimation(
      DownloadProgressMessage downloadProgress, double totalProgress) {
    final downloadId = downloadProgress.downloadItem.id;
    if (completionEstimations[downloadId] == null) return;
    downloadProgress.estimatedRemaining =
        totalProgress >= 1 ? "" : completionEstimations[downloadId]!;
  }

  static int _tempTime = _nowMillis;

  static void _calculateEstimatedRemaining(int id, double bytesTransferRate) {
    final progresses = _connectionProgresses[id];
    final nowMillis = _nowMillis;
    if (progresses == null ||
        _tempTime + 1000 > nowMillis ||
        bytesTransferRate == 0) return;

    int totalBytes = 0;
    final contentLength = progresses.values.first.downloadItem.contentLength;
    for (var element in progresses.values) {
      totalBytes += element.totalReceivedBytes;
    }

    final remainingSec = (contentLength - totalBytes) / bytesTransferRate;
    String estimatedRemaining;

    final days = ((remainingSec % 31536000) / 86400).floor();
    final hours = (((remainingSec % 31536000) % 86400) / 3600).floor();
    final minutes = ((((remainingSec % 31536000) % 86400) % 3600) / 60).floor();
    final seconds = ((((remainingSec % 31536000) % 86400) % 3600) % 60).floor();

    String formatUnit(int value, String unit) {
      return '$value $unit${value == 1 ? '' : 's'}';
    }

    if (days >= 1) {
      estimatedRemaining = formatUnit(hours, 'Hour');
    } else if (hours >= 1) {
      estimatedRemaining =
          '${formatUnit(hours, 'Hour')}, ${formatUnit(minutes, 'Minute')}';
    } else if (minutes >= 1) {
      estimatedRemaining =
          '${formatUnit(minutes, 'Minute')}, ${formatUnit(seconds, 'Second')}';
    } else if (remainingSec == 0) {
      estimatedRemaining = "";
    } else {
      estimatedRemaining = formatUnit(remainingSec.toInt(), 'Second');
    }
    _tempTime = _nowMillis;
    completionEstimations[id] = estimatedRemaining;
  }

  static void _setStatus(int id, DownloadProgressMessage downloadProgress) {
    if (_connectionProgresses[id] == null) return;
    final firstProgress = _connectionProgresses[id]!.values.first;
    String status = firstProgress.status;
    final totalProgress = _calculateTotalDownloadProgress(id);
    final allConnecting = _engineChannels[id]!
        .connectionChannels
        .values
        .every((p) => p.detailsStatus == DownloadStatus.connecting);
    final anyDownloading = _engineChannels[id]!
        .connectionChannels
        .values
        .any((p) => p.status == DownloadStatus.downloading);
    if (allConnecting) {
      status = DownloadStatus.connecting;
    }
    if (totalProgress >= 1) {
      status = DownloadStatus.connectionComplete;
    }
    if (anyDownloading) {
      status = DownloadStatus.downloading;
    }
    downloadProgress.status = status;
    downloadProgress.downloadItem.status = status;
  }

  /// Sets the availability for start and pause buttons based on all the
  /// statuses of active connections. To prevent unexpected issues, both the
  /// start and pause button will have a wait time set by the value of [BUTTON_AVAILABILITY_WAIT_SEC].
  static void _setButtonAvailability(
    DownloadProgressMessage progress,
    double totalProgress,
  ) {
    final downloadId = progress.downloadItem.id;
    final engineChannel = _engineChannels[downloadId];
    if (_connectionProgresses[downloadId] == null) return;
    final progresses = _connectionProgresses[downloadId]!.values;
    if (totalProgress >= 1) {
      progress.buttonAvailability = ButtonAvailability(false, false);
      return;
    }
    final unfinishedConnections = progresses
        .where((p) => p.connectionStatus != DownloadStatus.connectionComplete)
        .toList();

    final pauseButtonEnabled = unfinishedConnections.every(
          (c) => c.buttonAvailability.pauseButtonEnabled,
        ) &&
        engineChannel!.isPauseButtonWaitComplete;

    final startButtonEnabled = unfinishedConnections.every(
          (c) => c.buttonAvailability.startButtonEnabled,
        ) &&
        engineChannel!.isStartButtonWaitComplete;

    progress.buttonAvailability =
        ButtonAvailability(pauseButtonEnabled, startButtonEnabled);
  }

  static double _calculateTotalDownloadProgress(int id) {
    return _connectionProgresses[id]!
        .values
        .map((e) => e.totalDownloadProgress)
        .reduce((first, second) => first + second);
  }

  /// TODO fix
  static bool checkTempWriteCompletion(DownloadItemModel downloadItem) {
    final progresses = _connectionProgresses[downloadItem.id]!.values;
    final logger = _engineChannels[downloadItem.id]!.logger;
    final tempComplete = progresses.every(
      (progress) =>
          progress.totalConnectionWriteProgress >= 1 &&
          progress.connectionStatus == DownloadStatus.connectionComplete,
    );
    if (!tempComplete) {
      return false;
    }
    validateTempFilesIntegrity(
      downloadItem,
      progressUpdateChannel: _engineChannels[downloadItem.id]!.channel,
    );
    final missingBytes = _findMissingByteRanges(downloadItem);
    logger?.info("Missing byte range check : ${missingBytes}");
    final nodes =
        _engineChannels[downloadItem.id]!.segmentTree!.lowestLevelNodes;
    nodes.forEach((element) {
      logger?.info(
          "LowestLevelNode:: ${element.segment} :: ${element.segmentStatus}");
    });
    return missingBytes.length == 0;
  }

  // TODO fix bug
  static double _calculateTotalTransferRate(int id) {
    double sum = 0;
    _connectionProgresses[id]!.forEach((key, value) {
      sum += _connectionProgresses[id]![key]!.bytesTransferRate;
    });
    return sum;
  }

  /// Spawns an isolate responsible for each download connection.
  /// [errorsAreFatal] is set to false to prevent isolate from closing when a
  /// connection exception occurs. Otherwise, we wouldn't be able to reset the
  /// connection because the isolate would already be dead.
  static _spawnSingleDownloadIsolate(
    HttpDownloadIsolateMessage data,
    int connNum,
  ) async {
    final rPort = ReceivePort();
    final channel = IsolateChannel.connectReceive(rPort);
    final id = data.downloadItem.id;
    final logger = _engineChannels[id]?.logger;
    data.connectionNumber = connNum;
    logger?.info(
      "Spawning download connection isolate with connection number ${data.connectionNumber}...",
    );
    final isolate = await Isolate.spawn(
      DownloadConnectionInvoker.invokeConnection,
      rPort.sendPort,
      errorsAreFatal: false,
    );
    logger?.info(
      "Spawned connection $connNum with segment ${data.segment}",
    );
    channel.sink.add(data);
    _connectionIsolates[id] ??= {};
    _connectionIsolates[id]![connNum] = isolate;
    final connectionChannel = HttpDownloadConnectionChannel(
      channel: channel,
      connectionNumber: connNum,
      segment: data.segment!,
    );
    _engineChannels[id]!.connectionChannels[connNum] = connectionChannel;
    connectionChannel.listenToStream(_handleConnectionMessages);
  }

  static bool isAssembledFileInvalid(DownloadItemModel downloadItem) {
    final assembledFile = File(downloadItem.filePath);
    return assembledFile.existsSync() &&
        assembledFile.lengthSync() != downloadItem.contentLength;
  }

  /// TODO should notify the progress while building the file instead of when the file has already been built
  static DownloadProgressMessage reassembleFile(
    DownloadItemModel downloadItem,
    IsolateChannel progressChannel,
  ) {
    File(downloadItem.filePath).deleteSync();
    final success = assembleFile(
      downloadItem,
      progressChannel: progressChannel,
    );
    final status = success
        ? DownloadStatus.assembleComplete
        : DownloadStatus.assembleFailed;
    downloadItem.status = status;
    final progress = DownloadProgressMessage(
      downloadItem: downloadItem,
      status: status,
      downloadProgress: 1,
    );
    return progress;
  }

  static int get _nowMillis => DateTime.now().millisecondsSinceEpoch;
}
