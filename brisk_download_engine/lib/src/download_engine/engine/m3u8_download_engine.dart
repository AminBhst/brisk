import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:brisk_download_engine/brisk_download_engine.dart';
import 'package:brisk_download_engine/src/download_engine/channel/engine_channel.dart';
import 'package:brisk_download_engine/src/download_engine/channel/m3u8_download_connection_channel.dart';
import 'package:brisk_download_engine/src/download_engine/connection/download_connection_invoker.dart';
import 'package:brisk_download_engine/src/download_engine/download_command.dart';
import 'package:brisk_download_engine/src/download_engine/download_status.dart';
import 'package:brisk_download_engine/src/download_engine/message/log_message.dart';
import 'package:brisk_download_engine/src/download_engine/message/m3u8_download_isolate_message.dart';
import 'package:brisk_download_engine/src/download_engine/model/m3u8.dart';
import 'package:brisk_download_engine/src/download_engine/segment/segment_status.dart';
import 'package:brisk_download_engine/src/download_engine/util/file_util.dart';
import 'package:brisk_download_engine/src/download_engine/util/isolate_args.dart';
import 'package:brisk_download_engine/src/download_engine/util/readability_util.dart';
import 'package:dartx/dartx.dart';
import 'package:path/path.dart';
import 'package:stream_channel/isolate_channel.dart';

/// The Download Engine responsible for downloading video streams based on the m3u8
/// file format.
class M3U8DownloadEngine {
  static const buttonAvailabilityWaitSec = 4;
  static final Map<String, Map<int, Isolate>> _connectionIsolates = {};
  static final Map<String, EngineChannel<M3u8DownloadConnectionChannel>>
      _engineChannels = {};

  static final Map<String, M3U8> _m3u8Map = {};

  static final Map<String, Map<int, DownloadProgressMessage>>
      _connectionProgresses = {};

  static final Map<String, DownloadProgressMessage> _downloadProgresses = {};

  static Timer? _connectionResetTimer;
  static Timer? _buttonAvailabilityTimer;

  static late DownloadSettings downloadSettings;

  /// TODO remove the proxy settings
  static void start(IsolateSingleArg<String> args) async {
    final providerChannel = IsolateChannel.connectSend(args.sendPort);
    final engineChannel = EngineChannel<M3u8DownloadConnectionChannel>(
      channel: providerChannel,
    );
    _engineChannels[args.obj] = engineChannel;
    _startEngineTimers();
    engineChannel.listenToStream<M3u8DownloadIsolateMessage>((data) async {
      downloadSettings = data.settings;
      final downloadItem = data.downloadItem;
      final uid = downloadItem.uid;
      M3U8? m3u8 = _m3u8Map[uid];

      /// TODO show error for unsupported encryption
      if (m3u8 == null) {
        engineChannel.logger?.info("Creating the m3u8 file...");
        m3u8 = await M3U8.fromString(
          downloadItem.m3u8Content!,
          downloadItem.downloadUrl,
          proxySetting: downloadSettings.proxySetting,
        )
          ?..refererHeader = downloadItem.refererHeader;
        _m3u8Map[uid] = m3u8!;
        engineChannel.logger?.info("Successfully created the m3u8 file.");
      }
      if (isAssembledFileInvalid(downloadItem)) {
        final progress = reassembleFile(downloadItem);
        engineChannel.sendMessage(progress);
        return;
      }
      await sendToDownloadIsolates(data, providerChannel, m3u8);
      for (final channel in _engineChannels[uid]!.connectionChannels.values) {
        channel.listenToStream(_handleConnectionMessages);
      }
    });
  }

  static void _runConnectionReset() {
    _engineChannels.forEach((downloadUid, engineChannel) {
      final progress = _calculateTotalDownloadProgress(downloadUid);
      if (engineChannel.downloadItem == null ||
          engineChannel.paused ||
          progress == 1) {
        return;
      }
      final connectionsToReset = engineChannel.connectionChannels.values
          .where((conn) =>
              conn.detailsStatus != DownloadStatus.paused &&
              conn.detailsStatus != DownloadStatus.canceled &&
              conn.detailsStatus != DownloadStatus.connectionComplete)
          .toList()
          .where(
            (conn) =>
                (conn.resetCount < downloadSettings.maxConnectionRetryCount ||
                    downloadSettings.maxConnectionRetryCount == -1) &&
                conn.lastResponseTime +
                        downloadSettings.connectionRetryTimeoutMillis +
                        2000 <
                    DateTime.now().millisecondsSinceEpoch,
          )
          .toList();

      for (final connection in connectionsToReset) {
        final message = M3u8DownloadIsolateMessage(
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

  static void _reuseConnection(DownloadProgressMessage progress) {
    final uid = progress.downloadItem.uid;
    final engineChannel = _engineChannels[uid]!;
    print("Running reuse.... paused ? ${engineChannel.paused}");
    if (engineChannel.paused) return;
    final m3u8 = _m3u8Map[uid];
    if (m3u8 == null) return;
    final segmentToAssign = m3u8.segments
        .where((segment) => segment.segmentStatus == SegmentStatus.initial)
        .first;
    segmentToAssign.segmentStatus = SegmentStatus.inUse;
    final conn = engineChannel.connectionChannels[progress.connectionNumber]!;
    segmentToAssign.connectionNumber = conn.connectionNumber;
    if (_shouldSetSegmentEncryptionDetails(segmentToAssign, m3u8)) {
      segmentToAssign.encryptionDetails = m3u8.encryptionDetails;
    }
    final commandMessage = M3u8DownloadIsolateMessage(
      downloadItem: engineChannel.downloadItem!,
      command: DownloadCommand.startInitial,
      settings: downloadSettings,
      connectionNumber: conn.connectionNumber,
      segment: segmentToAssign,
    );
    conn.sendMessage(commandMessage);
  }

  static void _startEngineTimers() {
    _startConnectionResetTimer();
    _startButtonAvailabilityNotifierTimer();
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
      Duration(seconds: 1),
      (_) => _runButtonAvailabilityNotifier(),
    );
  }

  static void _startConnectionResetTimer() {
    if (_connectionResetTimer != null) return;
    _connectionResetTimer = Timer.periodic(Duration(seconds: 5), (_) {
      try {
        _runConnectionReset();
      } catch (e) {
        print(e);
      }
    });
  }

  static void _runButtonAvailabilityNotifier() {
    _engineChannels.forEach((downloadId, engineChannel) {
      final progress = _calculateTotalDownloadProgress(downloadId);
      final allConnectionsPaused =
          engineChannel.connectionChannels.values.every(
        (conn) => conn.detailsStatus == DownloadStatus.paused,
      );
      if (engineChannel.downloadItem == null ||
          !engineChannel.paused ||
          progress == 1) {
        return;
      }
      final connectionsPauseWaitComplete =
          engineChannel.connectionChannels.values.every(
        (conn) =>
            conn.lastResponseTime + 3000 <
            DateTime.now().millisecondsSinceEpoch,
      );
      final message = ButtonAvailabilityMessage(
        downloadItem: engineChannel.downloadItem!,
        pauseButtonEnabled: false,
        startButtonEnabled: connectionsPauseWaitComplete &&
            engineChannel.isStartButtonWaitComplete &&
            allConnectionsPaused,
      );
      engineChannel.sendMessage(message);
    });
  }

  static void _handleProgressUpdates(DownloadProgressMessage progress) {
    final downloadItem = progress.downloadItem;
    final uid = downloadItem.uid;
    final engineChannel = _engineChannels[uid]!;
    final logger = engineChannel.logger;
    if (engineChannel.assembleRequested) {
      return;
    }
    _connectionProgresses[uid] ??= {};
    _connectionProgresses[uid]![progress.connectionNumber] = progress;
    if (progress.completionSignal) {
      logger?.info(
        "Received completion signal from connection ${progress.connectionNumber}",
      );
      _setSegmentComplete(progress);
    }
    final totalByteTransferRate = _calculateTotalTransferRate(uid);
    final totalProgress = _calculateTotalDownloadProgress(uid);
    final downloadProgress = DownloadProgressMessage(
      downloadItem: downloadItem,
      downloadProgress: totalProgress,
      totalDownloadProgress: totalProgress,
      transferRate: convertByteTransferRateToReadableStr(totalByteTransferRate),
    );
    if (progress.status == DownloadStatus.downloading) {
      engineChannel.connectionChannels[progress.connectionNumber]
          ?.awaitingResetResponse = false;
    }
    _setButtonAvailability(downloadProgress, totalProgress);
    _setStatus(uid, downloadProgress); // TODO broken
    if (progress.completionSignal && totalProgress < 1) {
      _reuseConnection(progress);
    }
    if (totalProgress == 1 && isAssembleEligible(downloadItem)) {
      engineChannel.sendMessage(downloadProgress);
      final fileSize = assembleFile(progress.downloadItem);
      if (fileSize == -1) return;

      /// TODO add proper progress indication. currently it only notifies when the assemble is complete
      _setCompletionStatuses(downloadProgress, fileSize);
      logger
        ?..writeLogBuffer()
        ..flushTimer?.cancel();
    }
    _setConnectionProgresses(downloadProgress);
    _downloadProgresses[uid] = downloadProgress;
    if (engineChannel.paused) {
      downloadProgress.buttonAvailability = ButtonAvailability(false, false);
    }
    engineChannel.sendMessage(downloadProgress);
  }

  static double _calculateTotalDownloadProgress(String uid) {
    final completeCount = _m3u8Map[uid]!
        .segments
        .where((s) => s.segmentStatus == SegmentStatus.complete)
        .toList()
        .length;
    return completeCount / _m3u8Map[uid]!.segments.length;
  }

  static bool checkTempFilesIntegrity(String uid) {
    final engineChannel = _engineChannels[uid]!;
    final downloadItem = engineChannel.downloadItem!;
    final m3u8 = _m3u8Map[uid]!;
    for (final segment in m3u8.segments) {
      final segmentFilePath = join(
        downloadSettings.baseTempDir.path,
        downloadItem.uid,
        segment.sequenceNumber.toString(),
        "final-segment.ts",
      );
      if (!File(segmentFilePath).existsSync()) {
        final progress = _downloadProgresses[uid]!;
        progress.status = DownloadStatus.assembleFailed;
        progress.downloadItem.status = DownloadStatus.assembleFailed;
        engineChannel.sendMessage(progress);
        return false;
      }
    }
    return true;
  }

  static int assembleFile(
    DownloadItemModel downloadItem, {
    bool notifyProgress = false,
  }) {
    if (!checkTempFilesIntegrity(downloadItem.uid)) {
      File(downloadItem.filePath).writeAsBytesSync([0]);
      return -1;
    }
    final engineChannel = _engineChannels[downloadItem.uid]!;
    final progress = _downloadProgresses[downloadItem.uid] ??
        DownloadProgressMessage(
          downloadItem: downloadItem,
        );
    progress
      ..downloadItem.status = DownloadStatus.assembling
      ..totalDownloadProgress = 1
      ..downloadProgress = 1
      ..status = DownloadStatus.downloading;
    engineChannel.sendMessage(progress);
    engineChannel.assembleRequested = true;
    final logger = engineChannel.logger;
    final tempPath = join(downloadSettings.baseTempDir.path, downloadItem.uid);
    final tempDir = Directory(tempPath);
    final tempFies = getM3u8TempFilesSorted(tempDir);
    File fileToWrite = File(downloadItem.filePath);
    if (fileToWrite.existsSync()) {
      var newFilePath = FileUtil.getFilePath(
        downloadItem.fileName,
        downloadSettings.baseSaveDir,
        checkFileDuplicationOnly: true,
      );
      fileToWrite = File(newFilePath);
    }
    try {
      fileToWrite.createSync(recursive: true);
    } catch (e) {
      var newFilePath = FileUtil.getFilePath(
        downloadItem.uid + extension(downloadItem.fileName),
        downloadSettings.baseSaveDir,
        checkFileDuplicationOnly: true,
      );
      fileToWrite = File(newFilePath);
      fileToWrite.createSync(recursive: true);
    }
    try {
      logger?.info("Creating file...");
      for (var file in tempFies) {
        final bytes = file.readAsBytesSync();
        fileToWrite.writeAsBytesSync(bytes, mode: FileMode.writeOnlyAppend);
      }
    } catch (e) {
      print(e);
    }
    _connectionIsolates[downloadItem.uid]?.values.forEach((isolate) {
      isolate.kill();
    });
    tempDir.deleteSync(recursive: true);
    if (notifyProgress) {
      _setCompletionStatuses(progress, fileToWrite.lengthSync());
      engineChannel.sendMessage(progress);
    }
    logger
      ?..writeLogBuffer()
      ..logBuffer.clear()
      ..flushTimer?.cancel();
    _engineChannels.remove(downloadItem.uid);
    return fileToWrite.lengthSync();
  }

  static List<File> getM3u8TempFilesSorted(Directory tempDir) {
    final directories = tempDir.listSync().whereType<Directory>().toList();
    directories.sort(
      (a, b) => basename(a.path).toInt().compareTo(basename(b.path).toInt()),
    );
    return directories
        .map((d) => File(join(d.path, "final-segment.ts")))
        .toList();
  }

  static void _setCompletionStatuses(
      DownloadProgressMessage downloadProgress, int fileSize) {
    downloadProgress.assembleProgress = 1;
    downloadProgress.status = DownloadStatus.assembleComplete;
    downloadProgress.downloadItem.status = DownloadStatus.assembleComplete;
    downloadProgress.downloadItem.finishDate = DateTime.now();
    downloadProgress.buttonAvailability = ButtonAvailability(false, false);
    downloadProgress.transferRate = "";
    downloadProgress.assembledFileSize = fileSize;
  }

  static void _setConnectionProgresses(DownloadProgressMessage progress) {
    final uid = progress.downloadItem.uid;
    _connectionProgresses[uid] ??= {};
    progress.connectionProgresses = _connectionProgresses[uid]!.values.toList();
  }

  static bool isAssembleEligible(DownloadItemModel downloadItem) {
    return downloadItem.status != DownloadStatus.assembleComplete &&
        downloadItem.status != DownloadStatus.assembleFailed &&
        !_engineChannels[downloadItem.uid]!.assembleRequested;
  }

  static void _setSegmentComplete(DownloadProgressMessage progress) {
    _m3u8Map[progress.downloadItem.uid]!
        .segments
        .where((s) => s == progress.m3u8segment)
        .first
        .segmentStatus = SegmentStatus.complete;
  }

  static void _setStatus(String uid, DownloadProgressMessage downloadProgress) {
    if (_connectionProgresses[uid] == null) return;
    final firstProgress = _connectionProgresses[uid]!.values.first;
    String status = firstProgress.status;
    final totalProgress = _calculateTotalDownloadProgress(uid);
    final allConnecting = _engineChannels[uid]!
        .connectionChannels
        .values
        .every((p) => p.detailsStatus == DownloadStatus.connecting);
    final anyDownloading = _engineChannels[uid]!
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

  static void _setButtonAvailability(
    DownloadProgressMessage progress,
    double totalProgress,
  ) {
    final uid = progress.downloadItem.uid;
    final engineChannel = _engineChannels[uid];
    if (_connectionProgresses[uid] == null) return;
    final progresses = _connectionProgresses[uid]!.values;
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

  // TODO fix bug
  static double _calculateTotalTransferRate(String uid) {
    double sum = 0;
    _connectionProgresses[uid]!.forEach((key, value) {
      sum += _connectionProgresses[uid]![key]!.bytesTransferRate;
    });
    return sum;
  }

  static Future<void> sendToDownloadIsolates(
    M3u8DownloadIsolateMessage data,
    IsolateChannel handlerChannel,
    M3U8 m3u8,
  ) async {
    final uid = data.downloadItem.uid;
    Completer<void> completer = Completer();
    final engineChannel = _engineChannels[uid];
    final logger = engineChannel?.logger;
    if (engineChannel!.connectionChannels.isEmpty) {
      _setSegmentStatuses(data);
      await _spawnDownloadIsolates(data);
    } else {
      _engineChannels[uid]?.connectionChannels.forEach((connNum, connection) {
        final newData = data.clone()..connectionNumber = connNum;
        logger?.info("Sent Command ${data.command} with "
            "segment ${data.segment} to connection $connNum");
        connection.sendMessage(newData);
      });
    }
    return completer.complete();
  }

  static void _setSegmentStatuses(M3u8DownloadIsolateMessage data) {
    final m3u8 = _m3u8Map[data.downloadItem.uid]!;
    final segmentsPath = join(
      downloadSettings.baseTempDir.path,
      data.downloadItem.uid,
    );
    final tempDir = Directory(segmentsPath);
    if (!tempDir.existsSync()) return;
    final tempDirectoriesSorter = tempDir
        .listSync()
        .whereType<Directory>()
        .toList()
      ..sort((a, b) =>
          basename(a.path).toInt().compareTo(basename(b.path).toInt()));
    for (final dir in tempDirectoriesSorter) {
      final finalSegmentPath = join(dir.path, "final-segment.ts");
      if (File(finalSegmentPath).existsSync()) {
        m3u8.segments
            .where((s) => s.sequenceNumber == basename(dir.path).toInt())
            .first
            .segmentStatus = SegmentStatus.complete;
      }
    }
  }

  static _spawnDownloadIsolates(M3u8DownloadIsolateMessage data) async {
    final m3u8 = _m3u8Map[data.downloadItem.uid]!;
    final incompleteSegments = m3u8.segments
        .where((s) => s.segmentStatus != SegmentStatus.complete)
        .toList();
    final segments = incompleteSegments.length >
            downloadSettings.totalM3u8Connections
        ? incompleteSegments.sublist(0, downloadSettings.totalM3u8Connections)
        : incompleteSegments.sublist(0);
    for (int i = 0; i < segments.length; i++) {
      final segment = segments[i];
      segment.connectionNumber = i;
      m3u8.segments.where((s) => s == segment).first
        ..connectionNumber = 1
        ..segmentStatus = SegmentStatus.inUse;
      await _spawnSingleDownloadIsolate(data.clone(), i, segment);
    }
  }

  static _spawnSingleDownloadIsolate(
    M3u8DownloadIsolateMessage data,
    int connNum,
    M3U8Segment segment,
  ) async {
    final rPort = ReceivePort();
    final channel = IsolateChannel.connectReceive(rPort);
    final uid = data.downloadItem.uid;
    final logger = _engineChannels[uid]?.logger;
    final m3u8 = _m3u8Map[uid]!;
    if (_shouldSetSegmentEncryptionDetails(segment, m3u8)) {
      segment.encryptionDetails = m3u8.encryptionDetails;
    }
    data.connectionNumber = connNum;
    data.segment = segment;
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
    _connectionIsolates[uid] ??= {};
    _connectionIsolates[uid]![connNum] = isolate;
    final connectionChannel = M3u8DownloadConnectionChannel(
      channel: channel,
      connectionNumber: connNum,
      segment: data.segment!,
    );
    _engineChannels[uid]!.connectionChannels[connNum] = connectionChannel;
    connectionChannel.listenToStream(_handleConnectionMessages);
  }

  static bool _shouldSetSegmentEncryptionDetails(
    M3U8Segment segment,
    M3U8 m3u8,
  ) {
    return (segment.encryptionDetails == null ||
            segment.encryptionDetails!.keyBytes == null) &&
        m3u8.encryptionDetails.keyBytes != null;
  }

  static void _handleConnectionMessages(message) async {
    switch (message.runtimeType) {
      case const (DownloadProgressMessage):
        _handleProgressUpdates(message);
        break;
      case const (LogMessage):
        _handleLogMessage(message);
        break;
      default:
        break;
    }
  }

  static void _handleLogMessage(LogMessage message) {
    final engineChannel = _engineChannels[message.downloadItem.uid];
    engineChannel?.logger
      ?..logBuffer.writeln(message.log)
      ..writeLogBuffer();
  }

  static bool isAssembledFileInvalid(DownloadItemModel downloadItem) {
    final tempPath = join(downloadSettings.baseTempDir.path, downloadItem.uid);
    return _downloadProgresses[downloadItem.uid] == null &&
        Directory(tempPath).existsSync() &&
        File(downloadItem.filePath).existsSync();
  }

  static DownloadProgressMessage reassembleFile(
    DownloadItemModel downloadItem,
  ) {
    final assembledFile = File(downloadItem.filePath);
    if (assembledFile.existsSync()) {
      assembledFile.deleteSync();
    }
    final fileSize = assembleFile(downloadItem);
    downloadItem.status = DownloadStatus.assembleComplete;
    final progress = DownloadProgressMessage(
      downloadItem: downloadItem,
      status: DownloadStatus.assembleComplete,
      downloadProgress: 1,
      assembledFileSize: fileSize,
    );
    return progress;
  }
}
