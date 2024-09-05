import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:brisk/download_engine/connection/base_http_download_connection.dart';
import 'package:brisk/download_engine/message/connection_handshake_message.dart';
import 'package:brisk/download_engine/message/connection_segment_message.dart';
import 'package:brisk/download_engine/download_command.dart';
import 'package:brisk/download_engine/download_status.dart';
import 'package:brisk/download_engine/channel/download_connection_channel.dart';
import 'package:brisk/download_engine/segment/download_segment_tree.dart';
import 'package:brisk/download_engine/download_settings.dart';
import 'package:brisk/download_engine/message/internal_messages.dart';
import 'package:brisk/download_engine/channel/main_download_channel.dart';
import 'package:brisk/download_engine/segment/segment.dart';
import 'package:brisk/download_engine/segment/segment_status.dart';
import 'package:brisk/download_engine/connection/download_connection_invoker.dart';
import 'package:brisk/download_engine/model/download_item_model.dart';
import 'package:brisk/download_engine/message/download_progress_message.dart';
import 'package:brisk/download_engine/message/download_isolate_message.dart';
import 'package:brisk/download_engine/util/temp_file_util.dart';
import 'package:brisk/model/isolate/isolate_args_pair.dart';
import 'package:dartx/dartx.dart';
import 'package:stream_channel/isolate_channel.dart';
import 'package:path/path.dart';

import '../util/file_util.dart';
import '../util/readability_util.dart';

/// Coordinates and manages download connections.
/// By default, each download request consists of 8 download connections that are tasked to receive their designated bytes and save them as temporary files.
/// For each download item, [startDownloadRequest] will be called in a designated isolate spawned by the [DownloadRequestProvider].
/// The coordinator will track the state of the download connections, retrieve and aggregate data such as the overall download speed and progress,
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
  static const _CONNECTION_REUSE_TIMER_DURATION_SEC = 2;

  static const _CONNECTION_SPAWNER_TIMER_DURATION_SEC = 3;

  /// A map of all stream channels related to the running download requests
  /// key: downloadId
  static final Map<int, MainDownloadChannel> _downloadChannels = {};

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
  static final List<int> _dynamicConnectionSpawnerIgnoreList = [];

  static Timer? _dynamicConnectionReuseTimer = null;

  static Timer? _dynamicConnectionSpawnerTimer = null;

  static Map<int, bool> forcePause = {};

  static late DownloadSettings downloadSettings;

  static int get _nowMillis => DateTime.now().millisecondsSinceEpoch;

  /// Adds download connections on the fly
  static void _runDynamicConnectionSpawner() {
    _downloadChannels.forEach((downloadId, handlerChannel) {
      final downloadProgress = _downloadProgresses[downloadId];
      if (downloadProgress == null) {
        return;
      }
      if (_shouldCreateNewConnections(downloadId)) {
        _refreshConnectionSegments(downloadId);
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

  /// TODO similar to this, we should have a queue of connections that should be assigned every N seconds
  /// TODO by doing this, we can assign all of them together. Also, this queue should be run after all connections
  /// TODO have been spawned. This way, we git rid of the possible overlapping of requests
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
    _downloadChannels.forEach((downloadId, handlerChannel) {
      final queue = handlerChannel.connectionReuseQueue;
      final prog = _downloadProgresses[downloadId]?.totalDownloadProgress ?? 0;
      if (queue.isEmpty ||
          _shouldCreateNewConnections(downloadId) ||
          prog >= 1) {
        return;
      }
      final connectionChannel = queue.removeFirst();
      print(
          "Sending refresh segment for conn ${connectionChannel.connectionNumber}");
      _sendRefreshSegmentCommand_ReuseConnection(connectionChannel);
    });
  }

  static void startDownloadRequest(IsolateArgsPair<int> args) async {
    final providerChannel = IsolateChannel.connectSend(args.sendPort);
    final mainChannel = MainDownloadChannel(channel: providerChannel);
    _downloadChannels[args.obj] = mainChannel;
    _startEngineTimers();
    mainChannel.listenToStream<DownloadIsolateMessage>((data) async {
      downloadSettings = data.settings;
      _setConnectionSpawnIgnoreList(data);
      final downloadItem = data.downloadItem;
      final id = downloadItem.id;
      if (isAssembledFileInvalid(downloadItem)) {
        final progress = reassembleFile(downloadItem);
        mainChannel.sendMessage(progress);
        return;
      }
      await sendToDownloadIsolates(data, providerChannel);
      for (final channel in _downloadChannels[id]!.connectionChannels.values) {
        channel.listenToStream(_handleConnectionMessages);
      }
    });
  }

  static void _startEngineTimers() {
    _startDynamicConnectionSpawnerTimer();
    _startDynamicConnectionReuseTimer();
  }

  static void _setConnectionSpawnIgnoreList(DownloadIsolateMessage data) {
    if (data.command == DownloadCommand.pause) {
      _dynamicConnectionSpawnerIgnoreList.add(data.downloadItem.id);
    }
    if (data.command == DownloadCommand.start) {
      _dynamicConnectionSpawnerIgnoreList.remove(data.downloadItem.id);
    }
  }

  static void _refreshConnectionSegments(int downloadId) {
    final progress = _downloadProgresses[downloadId];
    if (progress == null) {
      return;
    }
    final mainChannel = _downloadChannels[downloadId]!;
    if (mainChannel.segmentTree == null) return;
    mainChannel.segmentTree!.split();
    final nodes = mainChannel.segmentTree!.lowestLevelNodes;
    print("======================== SEGMENT TREE =========================");
    nodes.forEach((node) {
      print(node.segment);
    });
    print("======================== SEGMENT TREE =========================");
    final segmentNodes = mainChannel.segmentTree!.lowestLevelNodes;
    mainChannel.connectionChannels.forEach((connectionNum, connectionChannel) {
      final relatedSegmentNode = segmentNodes
          .where((s) => s.connectionNumber == connectionNum)
          .firstOrNull;
      if (relatedSegmentNode == null) {
        // TODO log condition
        print("FATAL!!!!!!!");
        return;
      }
      final data = DownloadIsolateMessage(
        command: DownloadCommand.refreshSegment,
        downloadItem: _downloadProgresses[downloadId]!.downloadItem,
        connectionNumber: connectionNum,
        segment: relatedSegmentNode.segment,
        settings: downloadSettings,
      );
      relatedSegmentNode.segmentStatus = SegmentStatus.REFRESH_REQUESTED;
      relatedSegmentNode.setLastUpdateMillis();
      _downloadChannels[downloadId]?.createdConnections++;
      print("CREATED:::: ${_downloadChannels[downloadId]?.createdConnections}");
      connectionChannel.sendMessage(data);
    });
  }

  // TODO take estimation into account
  static bool _shouldCreateNewConnections(int downloadId) {
    final progress = _downloadProgresses[downloadId]!;
    print("^^^^^^^^^^^^^^^ TOTAL PROG : ${progress.totalDownloadProgress}");
    final mainChannel = _downloadChannels[downloadId];
    final pendingSegmentExists = _downloadChannels[downloadId]!
            .segmentTree
            ?.lowestLevelNodes
            .any((s) => s.segmentStatus == SegmentStatus.REFRESH_REQUESTED) ??
        true;

    final shouldCreate = !pendingSegmentExists &&
        progress.totalDownloadProgress < 1 &&
        mainChannel!.createdConnections < downloadSettings.totalConnections &&
        !_dynamicConnectionSpawnerIgnoreList.contains(downloadId);
    print("WELL SHOULD I CREATE NEW CONN ? $shouldCreate");
    return shouldCreate;
  }

  /// Handles the messages coming from [BaseHttpDownloadConnection]
  static void _handleConnectionMessages(message) async {
    if (message is DownloadProgressMessage) {
      _handleProgressUpdates(message);
    }
    if (message is ConnectionSegmentMessage) {
      _handleSegmentMessage(message);
    }
    if (message is ConnectionHandshake) {
      _handleConnectionHandshakeMessage(message);
    }
  }

  static void _handleConnectionHandshakeMessage(ConnectionHandshake message) {
    print("Got handshake ${message.newConnectionNumber}");
    final downloadChannel = _downloadChannels[message.downloadId];
    downloadChannel?.pendingHandshakes.removeWhere(
      (h) => h.newConnectionNumber == message.newConnectionNumber,
    );
  }

  static void _handleSegmentMessage(ConnectionSegmentMessage message) {
    print("Handling refresh segment response : ${message.internalMessage}");
    switch (message.internalMessage) {
      case InternalMessage.REFRESH_SEGMENT_SUCCESS:
        print("INSIDE REFRESH SEGMENT SUCCESS");
        _handleRefreshSegmentSuccess(message);
        break;
      case InternalMessage.OVERLAPPING_REFRESH_SEGMENT:
        print("INSIDE OVERLAPPING");
        _handleOverlappingSegment(message);
        break;
      case InternalMessage.REUSE_CONNECTION__REFRESH_SEGMENT_REFUSED:
      case InternalMessage.REFRESH_SEGMENT_REFUSED:
        print("INSIDE REFUSED");
        _handleRefreshSegmentRefused(message);
        break;
      default:
        break;
    }
  }

  static void _addHandshake(int downloadId, int connectionNumber) {
    final handshake = EngineConnectionHandshake(
      newConnectionNumber: connectionNumber,
      handShakeStatus: HandShakeStatus.PENDING_CONNECTION_SPAWN,
    );
    final downloadChannel = _downloadChannels[downloadId];
    downloadChannel?.pendingHandshakes.add(handshake);
  }

  static void _handleRefreshSegmentRefused(ConnectionSegmentMessage message) {
    final node = findSegmentNode(message);
    final tree = _downloadChannels[message.downloadItem.id]!.segmentTree!;
    if (node == null) {
      print("Failed to find requested segment node! Fatal!");
      return;
    }
    final parent = node.parent!;
    if (message.reuseConnection) {
      final downloadChannel = _downloadChannels[message.downloadItem.id]!;
      final connNum = parent.rightChild!.connectionNumber;
      final connection = downloadChannel.connectionChannels[connNum]!;
      downloadChannel.connectionReuseQueue.add(connection);
      print("Added connection $connNum to connection queue");
    } else {
      _downloadChannels[message.downloadItem.id]!.createdConnections--;
    }
    final l_index = tree.lowestLevelNodes
        .indexWhere((node) => node.segment == parent.leftChild!.segment);
    print("Trying to fix segment tree lowest nodes");
    if (l_index != -1) {
      // parent.segmentStatus = SegmentStatus.IN_USE;
      tree.lowestLevelNodes
        ..insert(l_index, parent)
        ..removeWhere((node) => node.segment == parent.rightChild!.segment)
        ..removeWhere((node) => node.segment == parent.leftChild!.segment);
    }
    parent
      ..removeChildren()
      ..setLastUpdateMillis();
  }

  /// TODO add doc
  static void _handleOverlappingSegment(ConnectionSegmentMessage message) {
    final node = findSegmentNode(message);
    if (node == null) {
      print("Failed to find requested segment node! Fatal!");
      return;
    }
    final parent = node.parent!;
    parent.leftChild!.segment = Segment(
      message.refreshedStartByte,
      message.refreshedEndByte,
    );
    parent
      ..setLastUpdateMillis()
      ..leftChild?.setLastUpdateMillis()
      ..segmentStatus = SegmentStatus.OUT_DATED
      ..leftChild?.segmentStatus = SegmentStatus.IN_USE
      ..rightChild?.segmentStatus = SegmentStatus.IN_USE;
    final newConnectionNode = parent.rightChild!;
    newConnectionNode.segment = Segment(
      message.validNewStartByte,
      message.validNewEndByte,
    );
    newConnectionNode.setLastUpdateMillis();
    _createDownloadConnection(
      message.downloadItem,
      newConnectionNode,
      newConnectionNode.connectionNumber,
    );
    _addHandshake(message.downloadItem.id, newConnectionNode.connectionNumber);
  }

  static void _handleRefreshSegmentSuccess(ConnectionSegmentMessage message) {
    final node = findSegmentNode(message);
    if (node == null) {
      print("Failed to find segment node. FATAL!");
      return;
    }
    final parent = node.parent!;
    parent.segmentStatus = SegmentStatus.OUT_DATED;
    parent.setLastUpdateMillis();
    final connectionNode = parent.rightChild!;
    print("Creating connection................");
    if (message.reuseConnection) {
      _sendStartCommand_ReuseConnection(
        message.downloadItem,
        connectionNode.connectionNumber,
        connectionNode.segment,
      );
      connectionNode.segmentStatus = SegmentStatus.IN_USE;
    } else {
      _createDownloadConnection(
        message.downloadItem,
        connectionNode,
        connectionNode.connectionNumber,
      );
    }
    _addHandshake(message.downloadItem.id, connectionNode.connectionNumber);
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
    final data = DownloadIsolateMessage(
      command: DownloadCommand.start_ReuseConnection,
      downloadItem: downloadItem,
      settings: downloadSettings,
      segment: segment,
      connectionNumber: connectionNumber,
    );
    final connection = _downloadChannels[downloadItem.id]!
        .connectionChannels[connectionNumber]!;
    connection.sendMessage(data);
  }

  static SegmentNode? findSegmentNode(ConnectionSegmentMessage message) {
    final id = message.downloadItem.id;
    final tree = _downloadChannels[id]!.segmentTree!;
    final node = tree.searchNode(message.requestedSegment);
    print("DID I FIND THE NODE???? ${node != null}");
    return node;
  }

  static void _handleProgressUpdates(DownloadProgressMessage progress) {
    final downloadItem = progress.downloadItem;
    final downloadId = downloadItem.id;
    final downloadChannel = _downloadChannels[downloadItem.id]!;
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
    _setButtonAvailability(downloadProgress, totalProgress);
    _setStatus(downloadId, downloadProgress); // TODO broken
    if (isTempWriteComplete && isAssembleEligible(downloadItem)) {
      downloadProgress.status = DownloadStatus.assembling;
      downloadChannel.sendMessage(downloadProgress);
      // TODO uncomment
      // final success = assembleFile(progress.downloadItem); /// TODO add proper progress indication. currently it only notifies when the assemble is complete
      // _setCompletionStatuses(success, downloadProgress);
    }
    _setConnectionProgresses(downloadProgress);
    _downloadProgresses[downloadId] = downloadProgress;
    downloadChannel.sendMessage(downloadProgress);
    if (progress.completionSignal) {
      print(
          "----> Got completion signal for conn num ${progress.connectionNumber}");
      _addToReuseQueue(progress);
      _setSegmentComplete(progress);
    }
  }

  static void _addToReuseQueue(DownloadProgressMessage progress) {
    final downloadId = progress.downloadItem.id;
    final mainChannel = _downloadChannels[downloadId];
    final conn = mainChannel!.connectionChannels[progress.connectionNumber]!;
    _downloadChannels[downloadId]!.connectionReuseQueue.add(conn);
  }

  static void _setSegmentComplete(DownloadProgressMessage progress) {
    final downloadId = progress.downloadItem.id;
    final tree = _downloadChannels[downloadId]!.segmentTree!;
    final node = tree.searchNode(progress.segment!);
    print("did I find the node??? ${node != null}");
    node!.segmentStatus = SegmentStatus.COMPLETE;
  }

  /// Reassigns a connection that has finished receiving its bytes to a new segment
  static void _sendRefreshSegmentCommand_ReuseConnection(
    DownloadConnectionChannel connectionChannel,
  ) {
    final downloadId = connectionChannel.downloadItem!.id;
    final mainChannel = _downloadChannels[downloadId]!;
    final segmentTree = mainChannel.segmentTree;
    final inUseNodes = segmentTree!.inUseNodes;
    if (inUseNodes!.isEmpty) {
      print("Failed to find segment node! FATAL!");
      return;
    }
    inUseNodes.sort((a, b) => a.lastUpdateMillis.compareTo(b.lastUpdateMillis));
    final targetNode = inUseNodes
        .where((node) => node.segment != connectionChannel.segment)
        .where((node) => node.segmentStatus == SegmentStatus.IN_USE)
        .lastOrNull;
    if (targetNode == null) {
      print("Target node is null! FATAL!");
      return;
    }
    final success = segmentTree.splitSegmentNode(
      targetNode,
      setConnectionNumber: false,
    );

    /// TODO retry with a different node (has to stop at some point tho)
    if (!success) {
      print("Failed to segment new node");
      return;
    }
    print(
        "Split SegNode : Parent ${targetNode.segment} ::  l:: ${targetNode.leftChild!.segment} r :: ${targetNode.rightChild!.segment}");
    print("Segment tree reuse ===========================");
    segmentTree.lowestLevelNodes.forEach((element) {
      print(element.segment);
    });
    targetNode.rightChild?.connectionNumber =
        connectionChannel.connectionNumber;
    final oldestSegmentConnection = mainChannel.connectionChannels.values
        .where((conn) => conn.segment == targetNode.segment)
        .firstOrNull;
    if (oldestSegmentConnection == null) {
      print("Failed to find oldest conn! FATAL!");
      return;
    }
    final data = DownloadIsolateMessage(
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
    final data = DownloadIsolateMessage(
      command: DownloadCommand.start_Initial,
      downloadItem: downloadItem,
      settings: downloadSettings,
      segment: segmentNode.segment,
    );
    print("Creating connection ${connectionNumber} :: ${segmentNode.segment}");
    await _spawnSingleDownloadIsolate(data, connectionNumber);
    segmentNode.segmentStatus = SegmentStatus.IN_USE;
  }

  static Future<void> sendToDownloadIsolates(
    DownloadIsolateMessage data,
    IsolateChannel handlerChannel,
  ) async {
    final int id = data.downloadItem.id;
    Completer<void> completer = Completer();
    if (_downloadChannels[id]!.connectionChannels.isEmpty) {
      final byteRangeMap = _findMissingByteRanges(
        data.downloadItem,
      ); // TODO Fix segment tree impl
      final ranges = byteRangeMap.values.toList();

      /// TODO handle
      if (ranges.isEmpty) {
        return;
      }
      _downloadChannels[id]!.segmentTree =
          DownloadSegmentTree.fromByteRanges(ranges);
      print("=========== MISSING BYTE RANGES =========");
      print(byteRangeMap);
      data.command = DownloadCommand.start_Initial;
      await _spawnDownloadIsolates(data);
    } else {
      _downloadChannels[id]?.connectionChannels.forEach((connNum, connection) {
        final newData = data.clone()..connectionNumber = connNum;
        print("Command ${data.command} send to connection $connNum");
        connection.sendMessage(newData);
      });
    }
    return completer.complete();
    // if (missingByteRanges.length > totalConnections) {
    /// TODO This shouldn't really happen but just in case we should do sth about it
    // }
  }

  static _spawnDownloadIsolates(DownloadIsolateMessage data) async {
    final id = data.downloadItem.id;
    final segmentTree = _downloadChannels[id]!.segmentTree!;
    segmentTree.lowestLevelNodes.forEach((segmentNode) {
      var newData = data.clone()..segment = segmentNode.segment;
      segmentNode.segmentStatus = SegmentStatus.IN_USE;
      _spawnSingleDownloadIsolate(newData, segmentNode.connectionNumber);
    });
  }

  /// Analyzes the temp files and returns the missing temp byte ranges
  /// TODO handle if no missing bytes were found
  /// TODO probably needs fixing
  static Map<int, Segment> _findMissingByteRanges(
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
      return {0: Segment(0, downloadItem.contentLength)};
    }

    tempFiles.sort(sortByByteRanges);
    String prevFileName = "";
    Map<int, Segment> missingBytes = {};
    for (var i = 0; i < tempFiles.length; i++) {
      final tempFile = tempFiles[i];
      final tempFileName = basename(tempFile.path);
      if (prevFileName == "") {
        prevFileName = tempFileName;
        continue;
      }

      final startByte = getStartByteFromTempFileName(tempFileName);
      final endByte = getEndByteFromTempFileName(tempFileName);
      final prevEndByte = getEndByteFromTempFileName(prevFileName);
      final segmentNumber = getConnectionNumberFromTempFileName(tempFileName);

      if (prevEndByte + 1 != startByte) {
        final missingStartByte = prevEndByte + 1;
        final missingEndByte = startByte - 1;
        missingBytes[segmentNumber] = Segment(missingStartByte, missingEndByte);
      }
      prevFileName = tempFileName;

      if (i == tempFiles.length - 1 && endByte != contentLength) {
        missingBytes[segmentNumber] = Segment(endByte, contentLength);
      }
    }
    return missingBytes;
  }

  static bool isAssembleEligible(DownloadItemModel downloadItem) {
    return downloadItem.status != DownloadStatus.assembleComplete &&
        downloadItem.status != DownloadStatus.assembleFailed;
  }

  static void validateTempFilesIntegrity(DownloadItemModel downloadItem) {
    print("Validating temp files integrity...");
    final tempPath = join(downloadSettings.baseTempDir.path, downloadItem.uid);
    final tempDir = Directory(tempPath);
    final tempFies = getTempFilesSorted(tempDir);
    for (int i = 0; i < tempFies.length; i++) {
      if (i == tempFies.length) {
        return;
      }
      final file = tempFies[i];
      final nextFile = tempFies[i + 1];
      final startNext = getStartByteFromTempFile(nextFile);
      final end = getEndByteFromTempFile(file);
      final start = getStartByteFromTempFile(file);
      if (startNext + 1 != end) {
        print(
            "Found inconsistent temp file :: ${basename(file.path)} == ${basename(nextFile.path)}");
      }
      if (end - start + 1 != file.lengthSync()) {
        print("Found bad length ::: ${basename(file.path)}");
      }
    }
  }

  /// Writes all the file parts inside the temp folder into one file therefore
  /// creating the final downloaded file.
  static bool assembleFile(DownloadItemModel downloadItem) {
    validateTempFilesIntegrity(downloadItem);
    final tempPath = join(downloadSettings.baseTempDir.path, downloadItem.uid);
    final tempDir = Directory(tempPath);
    final tempFies = getTempFilesSorted(tempDir);
    File fileToWrite = File(downloadItem.filePath);
    if (fileToWrite.existsSync()) {
      final newFilePath = FileUtil.getFilePath(
        downloadItem.fileName,
        baseSaveDir: downloadSettings.baseSaveDir,
        checkFileDuplicationOnly: true,
      );
      fileToWrite = File(newFilePath);
    }
    fileToWrite.createSync(recursive: true);
    print("Creating file...");
    for (var file in tempFies) {
      final bytes = file.readAsBytesSync();
      fileToWrite.writeAsBytesSync(bytes, mode: FileMode.writeOnlyAppend);
    }
    final assembleSuccessful =
        fileToWrite.lengthSync() == downloadItem.contentLength;
    if (assembleSuccessful) {
      _connectionIsolates[downloadItem.id]?.values.forEach((isolate) {
        isolate.kill();
      });
      tempDir.delete(recursive: true);
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
    if (days >= 1) {
      estimatedRemaining =
          '$days Days, $hours Hours, $minutes Minutes, $seconds Seconds';
    } else if (hours >= 1) {
      estimatedRemaining = '$hours Hours, $minutes Minutes, $seconds Seconds';
    } else if (minutes >= 1) {
      estimatedRemaining = '$minutes Minutes, $seconds Seconds';
    } else if (remainingSec == 0) {
      estimatedRemaining = "";
    } else {
      estimatedRemaining = '${remainingSec.toStringAsFixed(0)} Seconds';
    }
    _tempTime = _nowMillis;
    completionEstimations.addAll({id: estimatedRemaining});
  }

  static void _setStatus(int id, DownloadProgressMessage downloadProgress) {
    if (_connectionProgresses[id] == null) return;
    final firstProgress = _connectionProgresses[id]!.values.first;
    String status = firstProgress.status;
    final totalProgress = _calculateTotalDownloadProgress(id);
    final allConnecting = _connectionProgresses[id]!
        .values
        .every((p) => p.detailsStatus == DownloadStatus.connecting);
    if (allConnecting) {
      status = DownloadStatus.connecting;
    }
    if (totalProgress >= 1) {
      status = DownloadStatus.complete;
      if (downloadProgress.assembleProgress < 1) {
        status = DownloadStatus.assembling;
      }
    }
    downloadProgress.status = status;
    downloadProgress.downloadItem.status = status;
  }

  /// Sets the availability for start and pause buttons based on all the
  /// statuses of active connections
  static void _setButtonAvailability(
    DownloadProgressMessage progress,
    double totalProgress,
  ) {
    final downloadId = progress.downloadItem.id;
    if (_connectionProgresses[downloadId] == null) return;
    final progresses = _connectionProgresses[downloadId]!.values;
    if (totalProgress >= 1) {
      progress.pauseButtonEnabled = false;
      progress.startButtonEnabled = false;
      return;
    }
    final downloadChannel = _downloadChannels[downloadId];
    final pendingHandshakeExists =
        downloadChannel?.pendingHandshakes.isNotEmpty ?? false;
    final unfinishedConnections = progresses.where(
      (p) => p.detailsStatus != DownloadStatus.complete,
    );
    if (pendingHandshakeExists) {
      progress.pauseButtonEnabled = false;
    } else {
      progress.pauseButtonEnabled = unfinishedConnections.every(
        (c) => c.pauseButtonEnabled,
      );
    }
    progress.startButtonEnabled = unfinishedConnections.every(
      (c) => c.startButtonEnabled,
    );
  }

  static double _calculateTotalDownloadProgress(int id) {
    double totalProgress = 0;
    _connectionProgresses[id]!.values.forEach((progress) {
      totalProgress += progress.totalDownloadProgress;
    });
    return totalProgress;
  }

  /// TODO fix
  static bool checkTempWriteCompletion(DownloadItemModel downloadItem) {
    final progresses = _connectionProgresses[downloadItem.id]!.values;
    final tempComplete = progresses
        .every((progress) => progress.totalConnectionWriteProgress == 1);

    progresses.forEach((prog) {
      // print("WRITE PROG ${prog.segmentNumber} ::::::::: ${prog.writeProgress}");
    });
    if (!tempComplete) {
      return false;
    }

    final msng = _findMissingByteRanges(downloadItem);
    print("MISSING BYTERANGE CHECK : ${msng}");
    return _findMissingByteRanges(downloadItem).length == 0;
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
    DownloadIsolateMessage data,
    int connectionNumber,
  ) async {
    final rPort = ReceivePort();
    final channel = IsolateChannel.connectReceive(rPort);
    final downloadId = data.downloadItem.id;
    data.connectionNumber = connectionNumber;
    print("Data.segmentNumber = ${data.connectionNumber}");
    final isolate = await Isolate.spawn(
      DownloadConnectionInvoker.invokeConnection,
      rPort.sendPort,
      errorsAreFatal: false,
    );
    print("SPAWNED $connectionNumber for id $downloadId");
    channel.sink.add(data);
    _connectionIsolates[downloadId] ??= {};
    _connectionIsolates[downloadId]![connectionNumber] = isolate;
    final connectionChannel = DownloadConnectionChannel(
      channel: channel,
      connectionNumber: connectionNumber,
      segment: data.segment!,
    );

    _downloadChannels[downloadId]!
        .setConnectionChannel(connectionNumber, connectionChannel);

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
  ) {
    File(downloadItem.filePath).deleteSync();
    final success = assembleFile(downloadItem);
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
}
