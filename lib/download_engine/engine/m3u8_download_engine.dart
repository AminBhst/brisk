import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:brisk/constants/download_type.dart';
import 'package:brisk/download_engine/channel/download_connection_channel.dart';
import 'package:brisk/download_engine/channel/engine_channel.dart';
import 'package:brisk/download_engine/channel/m3u8_download_connection_channel.dart';
import 'package:brisk/download_engine/connection/download_connection_invoker.dart';
import 'package:brisk/download_engine/download_command.dart';
import 'package:brisk/download_engine/download_settings.dart';
import 'package:brisk/download_engine/download_status.dart';
import 'package:brisk/download_engine/message/connection_handshake_message.dart';
import 'package:brisk/download_engine/message/download_isolate_message.dart';
import 'package:brisk/download_engine/message/download_progress_message.dart';
import 'package:brisk/download_engine/message/log_message.dart';
import 'package:brisk/download_engine/message/m3u8_download_isolate_message.dart';
import 'package:brisk/download_engine/model/download_item_model.dart';
import 'package:brisk/download_engine/model/m3u8.dart';
import 'package:brisk/download_engine/segment/segment_status.dart';
import 'package:brisk/util/readability_util.dart';
import 'package:stream_channel/isolate_channel.dart';

import 'package:brisk/model/isolate/isolate_args_pair.dart';

/// The Download Engine responsible for downloading video streams based on the m3u8
/// file format.
class M3U8DownloadEngine {
  static final Map<int, Map<int, Isolate>> _connectionIsolates = {};
  static final Map<int, EngineChannel<M3u8DownloadConnectionChannel>>
      _engineChannels = {};

  static final Map<int, M3U8> _m3u8Map = {};

  static final Map<int, Map<int, DownloadProgressMessage>>
      _connectionProgresses = {};

  static final Map<int, DownloadProgressMessage> _downloadProgresses = {};

  static Timer? _connectionReuseTimer = null;
  static Timer? _connectionResetTimer = null;

  static late DownloadSettings downloadSettings;

  /// TODO remove the proxy settings
  static void start(IsolateArgsPair<int> args) async {
    final providerChannel = IsolateChannel.connectSend(args.sendPort);
    final engineChannel = EngineChannel<M3u8DownloadConnectionChannel>(
      channel: providerChannel,
    );
    _engineChannels[args.obj] = engineChannel;
    _startEngineTimers();
    engineChannel.listenToStream<M3u8DownloadIsolateMessage>((data) async {
      downloadSettings = data.settings;
      final downloadItem = data.downloadItem;
      final id = downloadItem.id;
      final engineChannel = _engineChannels[id]!;
      M3U8? m3u8 = _m3u8Map[id];

      /// TODO show error for unsupported encryption
      /// TODO set the proper segment statuses prior to start of the download
      if (m3u8 == null) {
        print("Creating the m3u8 file...");
        m3u8 = await M3U8.fromString(File(downloadItem.m3u8FilePath!).readAsStringSync(), "");
        print("Created the m3u8 file...");
        _m3u8Map[id] = m3u8!;
      }
      // if (isAssembledFileInvalid(downloadItem)) {
      //   final progress = reassembleFile(downloadItem);
      //   engineChannel.sendMessage(progress);
      //   return;
      // }
      await sendToDownloadIsolates(data, providerChannel, m3u8);
      for (final channel in _engineChannels[id]!.connectionChannels.values) {
        channel.listenToStream(_handleConnectionMessages);
      }
    });
  }

  static void _runConnectionReset() {}

  static void _runConnectionReuse() {
    print("Running reuse.... paused ?}");
    _engineChannels.forEach((downloadId, engineChannel) {
      print("Running reuse.... paused ? ${engineChannel.paused}");
      if (engineChannel.paused) return;
      final m3u8 = _m3u8Map[downloadId];
      if (m3u8 == null) return;
      final segmentToAssign = m3u8.segments
          .where((segment) => segment.segmentStatus == SegmentStatus.INITIAL)
          .first;
      if (engineChannel.connectionReuseQueue.isEmpty) return;
      final conn = engineChannel.connectionReuseQueue.removeFirst();
      segmentToAssign.segmentStatus = SegmentStatus.IN_USE;
      segmentToAssign.connectionNumber = conn.connectionNumber;
      if (_shouldSetSegmentEncryptionDetails(segmentToAssign, m3u8)) {
        segmentToAssign.encryptionDetails = m3u8.encryptionDetails;
      }
      final message = M3u8DownloadIsolateMessage(
        downloadItem: engineChannel.downloadItem!,
        command: DownloadCommand.start_Initial,
        settings: downloadSettings,
        connectionNumber: conn.connectionNumber,
        segment: segmentToAssign,
      );
      conn.sendMessage(message);
    });
  }

  static void _startEngineTimers() {
    _startConnectionReuseTimer();
    _startConnectionResetTimer();
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

  static void _startConnectionReuseTimer() {
    if (_connectionReuseTimer != null) return;
    _connectionReuseTimer = Timer.periodic(Duration(milliseconds: 500), (_) {
      try {
        _runConnectionReuse();
      } catch (e) {
        print(e);
      }
    });
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
    // final isTempWriteComplete = checkTempWriteCompletion(downloadItem);
    final totalProgress = _calculateTotalDownloadProgress(downloadId);
    // _calculateEstimatedRemaining(downloadId, totalByteTransferRate);
    final downloadProgress = DownloadProgressMessage(
      downloadItem: downloadItem,
      downloadProgress: totalProgress,
      totalDownloadProgress: totalProgress,
      transferRate: convertByteTransferRateToReadableStr(totalByteTransferRate),
      downloadType: DownloadType.M3U8,
    );
    // _setEstimation(downloadProgress, totalProgress);
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
    // if (isTempWriteComplete && isAssembleEligible(downloadItem)) {
    //   engineChannel.sendMessage(downloadProgress);
    //   final success = assembleFile(progress.downloadItem);
    //
    //   /// TODO add proper progress indication. currently it only notifies when the assemble is complete
    //   _setCompletionStatuses(success, downloadProgress);
    //   logger
    //     ?..writeLogBuffer()
    //     ..flushTimer?.cancel();
    // }
    // _setConnectionProgresses(downloadProgress);
    _downloadProgresses[downloadId] = downloadProgress;
    engineChannel.sendMessage(downloadProgress);
  }

  static void _setSegmentComplete(DownloadProgressMessage progress) {
    _m3u8Map[progress.downloadItem.id]!
        .segments
        .where((s) => s == progress.m3u8segment)
        .first
        .segmentStatus = SegmentStatus.COMPLETE;
  }

  static void _addToReuseQueue(DownloadProgressMessage progress) {
    final downloadId = progress.downloadItem.id;
    final engineChannel = _engineChannels[downloadId]!;
    final connection =
        engineChannel.connectionChannels[progress.connectionNumber];
    if (!engineChannel.connectionReuseQueue.contains(connection!)) {
      engineChannel.connectionReuseQueue.add(connection);
    }
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
        .where((p) => p.detailsStatus != DownloadStatus.connectionComplete)
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
    double totalProgress = 0;
    _connectionProgresses[id]!.values.forEach((progress) {
      totalProgress += progress.totalDownloadProgress;
    });
    return totalProgress;
  }

  // static bool checkTempWriteCompletion(DownloadItemModel downloadItem) {
  //   final progresses = _connectionProgresses[downloadItem.id]!.values;
  //   final logger = _engineChannels[downloadItem.id]!.logger;
  //   final tempComplete = progresses.every(
  //     (progress) =>
  //         progress.totalConnectionWriteProgress >= 1 &&
  //         progress.detailsStatus == DownloadStatus.connectionComplete,
  //   );
  //   if (!tempComplete) {
  //     return false;
  //   }
  //   validateTempFilesIntegrity(downloadItem);
  //   final missingBytes = _findMissingByteRanges(downloadItem);
  //   logger?.info("Missing byte range check : ${missingBytes}");
  //   final nodes =
  //       _engineChannels[downloadItem.id]!.segmentTree!.lowestLevelNodes;
  //   nodes.forEach((element) {
  //     logger?.info(
  //         "LowestLevelNode:: ${element.segment} :: ${element.segmentStatus}");
  //   });
  //   return missingBytes.length == 0;
  // }

  // TODO fix bug
  static double _calculateTotalTransferRate(int id) {
    double sum = 0;
    _connectionProgresses[id]!.forEach((key, value) {
      sum += _connectionProgresses[id]![key]!.bytesTransferRate;
    });
    return sum;
  }

  static Future<void> sendToDownloadIsolates(
    M3u8DownloadIsolateMessage data,
    IsolateChannel handlerChannel,
    M3U8 m3u8,
  ) async {
    final int id = data.downloadItem.id;
    Completer<void> completer = Completer();
    final engineChannel = _engineChannels[id];
    final logger = engineChannel?.logger;
    if (engineChannel!.connectionChannels.isEmpty) {
      await _spawnDownloadIsolates(data);
    } else {
      _engineChannels[id]?.connectionChannels.forEach((connNum, connection) {
        final newData = data.clone()..connectionNumber = connNum;
        logger?.info("Sent Command ${data.command} with "
            "segment ${data.segment} to connection $connNum");
        connection.sendMessage(newData);
      });
    }
    return completer.complete();
  }

  static _spawnDownloadIsolates(M3u8DownloadIsolateMessage data) async {
    final m3u8 = _m3u8Map[data.downloadItem.id]!;
    final segments =
        m3u8.segments.sublist(0, downloadSettings.totalConnections);
    for (int i = 0; i < segments.length; i++) {
      final segment = segments[i];
      segment.connectionNumber = i;
      m3u8.segments.where((s) => s == segment).first
        ..connectionNumber = 1
        ..segmentStatus = SegmentStatus.IN_USE;
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
    final id = data.downloadItem.id;
    final logger = _engineChannels[id]?.logger;
    final m3u8 = _m3u8Map[id]!;
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
    _connectionIsolates[id] ??= {};
    _connectionIsolates[id]![connNum] = isolate;
    final connectionChannel = M3u8DownloadConnectionChannel(
      channel: channel,
      connectionNumber: connNum,
      segment: data.segment!,
    );
    _engineChannels[id]!.connectionChannels[connNum] = connectionChannel;
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
      case DownloadProgressMessage:
        _handleProgressUpdates(message);
        break;
      case LogMessage:
        _handleLogMessage(message);
        break;
      default:
        break;
    }
  }

  /// TODO implement
  static void _handleLogMessage(message) {}
}
