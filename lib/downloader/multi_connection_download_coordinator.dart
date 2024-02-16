import 'dart:io';
import 'dart:isolate';

import 'package:brisk/constants/download_command.dart';
import 'package:brisk/constants/download_status.dart';
import 'package:brisk/downloader/single_connection_manager.dart';
import 'package:brisk/model/download_item_model.dart';
import 'package:brisk/model/download_progress.dart';
import 'package:brisk/model/isolate/download_isolator_args.dart';
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

  static final Map<int, String> completionEstimations = {};

  /// The last time in millis since the last check for dynamic segmentation per downloads
  static final Map<int, int> last_ds_checks = {};

  /// Settings
  static late Directory baseSaveDir;
  static late Directory baseTempDir;
  static late int totalConnections;
  static late int connectionRetryTimeout;
  static late int maxConnectionRetryCount;

  // static final Map<int, int> totalConnections = {};

  static int get _nowMillis => DateTime.now().millisecondsSinceEpoch;

  static void startDownloadRequest(SendPort sendPort) async {
    final handlerChannel = IsolateChannel.connectSend(sendPort);
    handlerChannel.stream.cast<DownloadIsolateArgs>().listen((data) async {
      final downloadItem = data.downloadItem;
      final id = downloadItem.id;
      final isListened = _connectionChannels[id] != null;
      _setSettings(data);
      if (isAssembledFileInvalid(downloadItem)) {
        final progress = reassembleFile(downloadItem, data.baseTempDir);
        handlerChannel.sink.add(progress);
        return;
      }
      await spawnOrSendToExistingDownloadIsolates(data);
      if (isListened) return;
      _connectionChannels[id]![0]
          ?.stream
          .cast<DownloadProgress>()
          .listen((progress) {
        handleDownloadProgressUpdates(progress, data, handlerChannel);
      });
      // for (final channel in _connectionChannels[id]!.values) {
      //   channel.stream.cast<DownloadProgress>().listen((progress) {
      //     handleDownloadProgressUpdates(progress, data, handlerChannel);
      //   });
      // }
    });
  }

  /// TODO Remove
  static bool skip = false;

  static _dynamicSegmentation(
      DownloadProgress progress, IsolateChannel handlerChannel) async {
    final downloadId = progress.downloadItem.id;
    last_ds_checks[downloadId] ??= _nowMillis;
    if (!_shouldCreateNewConnections(progress) || skip) {
      return;
    }

    skip = true;
    last_ds_checks[downloadId] = _nowMillis;
    final segments = _splitSegment(progress.downloadItem);
    print("SEGMENTS : ${segments}");
    _sendRefreshSegmentCommand(
      progress,
      segments.keys.elementAt(0),
      segments.values.elementAt(0),
    );

    final data = DownloadIsolateArgs(
      command: DownloadCommand.start,
      downloadItem: progress.downloadItem,
      baseTempDir: baseTempDir,
      totalConnections: totalConnections,
      baseSaveDir: baseSaveDir,
      startByte: segments.keys.elementAt(1),
      endByte: segments.values.elementAt(1),
    );
    await _spawnSingleDownloadIsolate(data, 1);
    _connectionChannels[downloadId]![1]
        ?.stream
        .cast<DownloadProgress>()
        .listen((prog) {
      handleDownloadProgressUpdates(prog, data, handlerChannel, false);
    });
  }

  /// Instead of sending a pause command and restarting the download with new segments,
  /// we can just use the length setter in uint8list to cut the temp file to the length that we need (MUCH MORE OPTIMIZED)
  static void _sendRefreshSegmentCommand(
    DownloadProgress progress,
    int startByte,
    int endByte,
  ) {
    final channels = _connectionChannels[progress.downloadItem.id];
    if (channels == null || channels.isEmpty) {
      return;
    }

    final data = DownloadIsolateArgs(
      command: DownloadCommand.refreshSegment,
      baseSaveDir: baseSaveDir,
      totalConnections: totalConnections,
      downloadItem: progress.downloadItem,
      baseTempDir: baseSaveDir,
      startByte: startByte,
      endByte: endByte,
      segmentNumber: 0,
    );
    channels[0]!.sink.add(data);
  }

  static Map<int, int> _splitSegment(DownloadItemModel downloadItem) {
    final isolates = _connectionIsolates[downloadItem.id];
    final endOne = (downloadItem.contentLength / 2).floor();
    return {0: endOne, endOne + 1: downloadItem.contentLength};
  }

  static bool _shouldCreateNewConnections(DownloadProgress progress) {
    final downloadId = progress.downloadItem.id;
    final lastCheck = last_ds_checks[downloadId];
    return lastCheck != null &&
        lastCheck + 2000 < _nowMillis &&
        progress.totalDownloadProgress != 1;
  }

  static void handleDownloadProgressUpdates(DownloadProgress progress,
      DownloadIsolateArgs data, IsolateChannel<dynamic> handlerChannel,
      [bool ds = true]) async {
    final int id = data.downloadItem.id;
    _connectionProgresses[id] ??= {};
    _connectionProgresses[id]![progress.segmentNumber] = progress;
    double totalByteTransferRate = _calculateTotalConnectionsTransferRate(id);
    final isTempWriteComplete = checkTempWriteCompletion(data);
    final totalProgress = _calculateTotalDownloadProgress(id);
    _calculateEstimatedRemaining(id, totalByteTransferRate);
    final downloadProgress = DownloadProgress(
      downloadItem: progress.downloadItem,
      downloadProgress: totalProgress,
      transferRate: convertByteTransferRateToReadableStr(totalByteTransferRate),
    );
    _setEstimation(id, downloadProgress, totalProgress);
    _setButtonAvailability(
      id,
      downloadProgress,
      data.totalConnections,
      totalProgress,
    );
    _setStatus(id, downloadProgress);
    if (ds) {
      await _dynamicSegmentation(downloadProgress, handlerChannel);
    }
    if (isTempWriteComplete && isAssembleEligible(data.downloadItem)) {
      downloadProgress.status = DownloadStatus.assembling;
      handlerChannel.sink.add(downloadProgress);
      final success = assembleFile(
        data.downloadItem,
        progress.baseTempDir,
        data.baseSaveDir,
      );
      _setCompletionStatuses(success, downloadProgress);
    }
    _setConnectionProgresses(downloadProgress);
    handlerChannel.sink.add(downloadProgress);
  }

  static spawnOrSendToExistingDownloadIsolates(DownloadIsolateArgs data) async {
    // final totalConnections = data.totalConnections;
    final int id = data.downloadItem.id;
    _connectionChannels[id] ??= {};
    if (_connectionChannels[id]!.isEmpty) {
      final missingByteRanges = _getMissingByteRanges(data);
      await _spawnDownloadIsolates(data, missingByteRanges);
      print(missingByteRanges);
    } else {
      _connectionChannels[id]!.values.forEach((channel) {
        channel.sink.add(data);
      });
    }
    // if (missingByteRanges.length > totalConnections) {
    /// TODO This shouldn't really happen but just in case we should do sth about it
    // }
  }

  static _spawnDownloadIsolates(
      DownloadIsolateArgs data, Map<int, int> missingByteRanges) async {
    for (int i = 0; i < missingByteRanges.length; i++) {
      data.startByte = missingByteRanges.keys.elementAt(i);
      print("==================== START BYTE =================");
      print(data.startByte);
      data.endByte = missingByteRanges.values.elementAt(i);
      print("==================== END BYTE =================");
      print(data.endByte);
      await _spawnSingleDownloadIsolate(data, i);
    }
  }

  /// Analyzes the temp files and returns the missing temp byte ranges
  /// TODO handle if no missing bytes were found
  static Map<int, int> _getMissingByteRanges(DownloadIsolateArgs data) {
    var tempFiles;
    final tempDirPath = join(data.baseTempDir.path, data.downloadItem.uid);
    final tempDir = Directory(tempDirPath);
    if (tempDir.existsSync()) {
      tempFiles = tempDir.listSync().map((o) => o as File).toList();
    }

    if (tempFiles == null || tempFiles.isEmpty) {
      return {0: data.downloadItem.contentLength};
    }

    tempFiles.sort(FileUtil.sortByFileName);
    String prevFileName = "";
    Map<int, int> missingBytes = {};
    for (final tempFile in tempFiles) {
      final tempFileName = basename(tempFile.path);
      if (prevFileName == "") {
        prevFileName = tempFileName;
        continue;
      }

      final startByte = FileUtil.getStartByteFromTempFileName(tempFileName);
      final prevEndByte = FileUtil.getEndByteFromTempFileName(prevFileName);

      if (prevEndByte + 1 != startByte) {
        final missingStartByte = prevEndByte + 1;
        final missingEndByte = startByte - 1;
        missingBytes[missingStartByte] = missingEndByte;
      }
      prevFileName = tempFileName;
    }
    return missingBytes;
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
    final tempFies = tempDir.listSync().map((o) => o as File).toList();
    tempFies.sort(FileUtil.sortByFileName);
    File fileToWrite = File(downloadItem.filePath);
    if (fileToWrite.existsSync()) {
      final newFilePath = FileUtil.getFilePath(
        downloadItem.fileName,
        baseSaveDir: baseSaveDir,
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
    if (_connectionProgresses[id] == null) return;
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
    _connectionProgresses[id]!.values.forEach((progress) {
      totalProgress += progress.totalDownloadProgress;
    });
    return totalProgress;
  }

  /// TODO fix
  static bool checkTempWriteCompletion(DownloadIsolateArgs data) {
    final progresses = _connectionProgresses[data.downloadItem.id]!.values;
    final tempComplete =
        progresses.every((progress) => progress.writeProgress == 1);
    if (!tempComplete) {
      return false;
    }

    return _getMissingByteRanges(data).length == 0;
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
  static _spawnSingleDownloadIsolate(
      DownloadIsolateArgs data, int segmentNumber) async {
    final rPort = ReceivePort();
    final channel = IsolateChannel.connectReceive(rPort);
    final downloadId = data.downloadItem.id;
    data.segmentNumber = segmentNumber;
    channel.sink.add(data);
    final isolate = await Isolate.spawn(
      SingleConnectionManager.handleSingleConnection,
      rPort.sendPort,
      errorsAreFatal: false,
    );
    _connectionIsolates[downloadId] ??= {};
    _connectionIsolates[downloadId]![segmentNumber] = isolate;
    _connectionChannels[downloadId] ??= {};
    _connectionChannels[downloadId]![segmentNumber] = channel;
  }

  static void _setSettings(DownloadIsolateArgs data) {
    baseSaveDir = data.baseSaveDir;
    baseTempDir = data.baseTempDir;
    connectionRetryTimeout = data.connectionRetryTimeout;
    maxConnectionRetryCount = data.maxConnectionRetryCount;
    totalConnections = data.totalConnections;
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
