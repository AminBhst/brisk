import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:brisk/constants/download_status.dart';
import 'package:brisk/downloader/single_connection_manager.dart';
import 'package:brisk/model/download_item_model.dart';
import 'package:brisk/model/download_progress.dart';
import 'package:brisk/model/isolate/download_isolator_args.dart';
import 'package:brisk/model/isolate/isolate_method_args.dart';
import 'package:stream_channel/isolate_channel.dart';
import 'package:stream_channel/stream_channel.dart';
import 'package:path/path.dart';

import '../util/file_util.dart';
import '../util/readability_util.dart';

/// Coordinates and manages download connections.
/// By default, each download request consists of 8 download connections that are tasked to receive their designated bytes and save them as temporary files.
/// For each download item, [startDownloadRequest] will be called in a designated isolate spawned by the [DownloadRequestProvider].
/// The coordinator will track the state of the download connections, retrieve and aggregate data such as the overall download speed and progress,
/// manage the availability of pause/resume buttons and assemble the file when the all connections have finished receiving and writing their data.
class MultiConnectionDownloadCoordinator {

  /// TODO : send pause command to isolates which are pending connection

  /// A map of all stream channels related to the running download requests
  static final Map<int, Map<int, StreamChannel>> _connectionChannels = {};

  static final Map<int, Map<int, DownloadProgress>> _connectionProgresses = {};

  static final Map<int, Map<int, Isolate>> _connectionIsolates = {};

  static Map<int, String> completionEstimations = {};

  /// Settings
  static late Directory baseSaveDir;

  static void startDownloadRequest(SendPort sendPort) async {
    final handlerChannel = IsolateChannel.connectSend(sendPort);
    handlerChannel.stream.listen((data) async {
      if (data is SegmentedDownloadIsolateArgs) {
        final downloadItem = data.downloadItem;
        final id = downloadItem.id;
        final isListened = _connectionChannels[id] != null;
        _setSettings(data);
        if (isAssembledFileInvalid(downloadItem)) {
          final progress = reassembleFile(downloadItem, data.baseTempDir);
          handlerChannel.sink.add(progress);
          return;
        }
        _connectionChannels[id] ??= {};
        for (int i = 1; i <= data.totalConnections; i++) {
          if (_connectionChannels[id]![i] == null) {
            await _spawnDownloadRequestIsolate(data, i, data.totalConnections);
          } else {
            _connectionChannels[id]![i]!.sink.add(data);
          }
        }
        if (isListened) return;
        _connectionChannels[id]!.forEach((_, channel) {
          channel.stream.listen((progress) {
            if (progress is DownloadProgress) {
              final segmentNumber = progress.segmentNumber;
              _connectionProgresses[id] ??= {};
              _connectionProgresses[id]![segmentNumber] = progress;
              double totalByteTransferRate =
                  _calculateTotalConnectionsTransferRate(id);
              final isTempWriteComplete = checkTempWriteCompletion(id);
              final totalProgress = _calculateTotalDownloadProgress(id);
              _calculateEstimatedRemaining(id, totalByteTransferRate);
              final downloadProgress = DownloadProgress(
                downloadItem: progress.downloadItem,
                downloadProgress: totalProgress,
                transferRate:
                    convertByteTransferRateToReadableStr(totalByteTransferRate),
              );
              _setEstimation(id, downloadProgress, totalProgress);
              _setButtonAvailability(
                id,
                downloadProgress,
                data.totalConnections,
                totalProgress,
              );
              _setStatus(id, downloadProgress);
              if (isTempWriteComplete && isAssembleEligible(downloadItem)) {
                downloadProgress.status = DownloadStatus.assembling;
                handlerChannel.sink.add(downloadProgress);
                final success = assembleFile(
                  downloadItem,
                  progress.baseTempDir,
                  data.baseSaveDir,
                );
                _setCompletionStatuses(success, downloadProgress);
              }
              _setConnectionProgresses(downloadProgress);
              handlerChannel.sink.add(downloadProgress);
            }
          });
        });
      }
    });
  }

  static bool isAssembleEligible(DownloadItemModel downloadItem) {
    return downloadItem.status != DownloadStatus.assembleComplete &&
        downloadItem.status != DownloadStatus.assembleFailed;
  }

  /// Writes all the file parts inside the temp folder into one file therefore
  /// creating the final downloaded file.
  static bool assembleFile(DownloadItemModel downloadItem,
      Directory baseTempDir, Directory baseSaveDir) {
    final tempPath = join(baseTempDir.path, downloadItem.uid);
    final tempDir = Directory(tempPath);
    final segmentDirs = tempDir.listSync().map((o) => o as Directory).toList();
    segmentDirs.sort(FileUtil.sortByFileName);
    File fileToWrite = File(downloadItem.filePath);
    if (fileToWrite.existsSync()) {
      final newFilePath = FileUtil.getFilePath(
        downloadItem.fileName,
        baseSaveDir: baseSaveDir,
        checkFileDuplicationOnly: true
      );
      fileToWrite = File(newFilePath);
    }
    fileToWrite.createSync(recursive: true);
    for (var dir in segmentDirs) {
      final segmentFiles = dir.listSync().map((o) => o as File).toList();
      segmentFiles.sort(FileUtil.sortByFileName);
      for (var file in segmentFiles) {
        final bytes = file.readAsBytesSync();
        fileToWrite.writeAsBytesSync(bytes, mode: FileMode.writeOnlyAppend);
      }
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

  static void _setConnectionProgresses(DownloadProgress progress) {
    final id = progress.downloadItem.id;
    _connectionProgresses[id] ??= {};
    progress.connectionProgresses = _connectionProgresses[id]!.values.toList();
  }

  static void _setCompletionStatuses(
      bool success, DownloadProgress downloadProgress) {
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
      int id, DownloadProgress downloadProgress, double totalProgress) {
    if (completionEstimations[id] == null) return;
    downloadProgress.estimatedRemaining =
        totalProgress >= 1 ? "" : completionEstimations[id]!;
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

  static void _setStatus(int id, DownloadProgress downloadProgress) {
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
  static void _setButtonAvailability(int id, DownloadProgress progress,
      int totalSegments, double totalProgress) {
    if (_connectionProgresses[id] == null ||
        _connectionProgresses[id]!.length != totalSegments) return;
    final progresses = _connectionProgresses[id]!.values;
    if (totalProgress >= 1) {
      progress.pauseButtonEnabled = false;
      progress.startButtonEnabled = false;
    } else {
      final unfinishedConnections = progresses
          .where((element) => element.detailsStatus != DownloadStatus.complete);
      progress.pauseButtonEnabled =
          unfinishedConnections.every((c) => c.pauseButtonEnabled);
      progress.startButtonEnabled =
          unfinishedConnections.every((c) => c.startButtonEnabled);
    }
  }

  static double _calculateTotalDownloadProgress(int id) {
    double totalProgress = 0;
    _connectionProgresses[id]!.forEach((_, value) {
      totalProgress += value.totalDownloadProgress;
    });
    return totalProgress;
  }

  static bool checkTempWriteCompletion(int id) {
    final progresses = _connectionProgresses[id]!.values;
    final totalSegments = progresses.first.totalSegments;
    return progresses.every((progress) => progress.writeProgress == 1) &&
        progresses.length == totalSegments;
  }

  static double _calculateTotalConnectionsTransferRate(int id) {
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
  static Future<void> _spawnDownloadRequestIsolate(
      SegmentedDownloadIsolateArgs args,
      int segmentNumber,
      int totalSegments) async {
    final rPort = ReceivePort();
    final channel = IsolateChannel.connectReceive(rPort);
    channel.sink.add(args);
    final downloadId = args.downloadItem.id;
    final isolateArgs = HandleSingleConnectionArgs(
      totalSegments: totalSegments,
      segmentNumber: segmentNumber,
      maxConnectionRetryCount: args.maxConnectionRetryCount,
      connectionRetryTimeout: args.connectionRetryTimeout,
      sendPort: rPort.sendPort,
    );
    final isolate = await Isolate.spawn<HandleSingleConnectionArgs>(
        SingleConnectionManager.handleSingleConnection, isolateArgs,
        errorsAreFatal: false);
    _connectionIsolates[downloadId] ??= {};
    _connectionIsolates[downloadId]![segmentNumber] = isolate;
    _connectionChannels[downloadId] ??= {};
    _connectionChannels[downloadId]![segmentNumber] = channel;
  }

  static int get _nowMillis => DateTime.now().millisecondsSinceEpoch;

  static void _setSettings(SegmentedDownloadIsolateArgs data) {
    baseSaveDir = data.baseSaveDir;
  }

  static bool isAssembledFileInvalid(DownloadItemModel downloadItem) {
    final assembledFile = File(downloadItem.filePath);
    return assembledFile.existsSync() &&
        assembledFile.lengthSync() != downloadItem.contentLength;
  }

  static DownloadProgress reassembleFile(
      DownloadItemModel downloadItem, Directory baseTempDir) {
    File(downloadItem.filePath).deleteSync();

    final success = assembleFile(downloadItem, baseTempDir, baseSaveDir);
    final status = success
        ? DownloadStatus.assembleComplete
        : DownloadStatus.assembleFailed;
    downloadItem.status = status;
    final progress = DownloadProgress(
      downloadItem: downloadItem,
      status: status,
      downloadProgress: 1,
    );
    return progress;
  }
}
