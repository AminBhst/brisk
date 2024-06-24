import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:brisk/downloader/download_command.dart';
import 'package:brisk/constants/download_status.dart';
import 'package:brisk/downloader/download_connection_channel.dart';
import 'package:brisk/downloader/internal_messages.dart';
import 'package:brisk/downloader/main_download_channel.dart';
import 'package:brisk/downloader/segment.dart';
import 'package:brisk/downloader/download_segments.dart';
import 'package:brisk/downloader/single_connection_manager.dart';
import 'package:brisk/model/download_item_model.dart';
import 'package:brisk/model/download_progress.dart';
import 'package:brisk/model/isolate/download_isolator_data.dart';
import 'package:brisk/model/isolate/isolate_args_pair.dart';
import 'package:brisk/model/isolate/settings.dart';
import 'package:stream_channel/isolate_channel.dart';
import 'package:path/path.dart';

import '../util/file_util.dart';
import '../util/readability_util.dart';

/// Coordinates and manages download connections.
/// By default, each download request consists of 8 download connections that are tasked to receive their designated bytes and save them as temporary files.
/// For each download item, [startDownloadRequest] will be called in a designated isolate spawned by the [DownloadRequestProvider].
/// The coordinator will track the state of the download connections, retrieve and aggregate data such as the overall download speed and progress,
/// manage the availability of pause/resume buttons and assemble the file when the all connections have finished receiving and writing their data.
class MultiConnectionDownloadHandler {
  /// TODO : send pause command to isolates which are pending connection

  /// A map of all stream channels related to the running download requests
  static final Map<int, MainDownloadChannel> _downloadChannels = {};

  /// TODO Remove and use download channels
  static final Map<int, Map<int, DownloadProgress>> _connectionProgresses = {};

  static final Map<int, DownloadProgress> _downloadProgresses = {};

  static final Map<int, Map<int, Isolate>> _connectionIsolates = {};

  // TODO redundant
  static final Map<int, String> completionEstimations = {};

  static Timer? _dynamicConnectionManagerTimer = null;

  /// Settings
  static late Settings settings; // TODO use settings object instead

  static late Directory baseSaveDir;
  static late Directory baseTempDir;
  static late int totalConnections;
  static late int connectionRetryTimeout;
  static late int maxConnectionRetryCount;

  // static final Map<int, int> totalConnections = {};

  static int get _nowMillis => DateTime.now().millisecondsSinceEpoch;

  static void _runDynamicConnectionManagerTimer() {
    if (_dynamicConnectionManagerTimer != null) {
      return;
    }
    _dynamicConnectionManagerTimer = Timer.periodic(
      Duration(seconds: 1),
      (_) => runDynamicConnectionManager(),
    );
  }

  static void runDynamicConnectionManager() {
    _downloadChannels.forEach((downloadId, handlerChannel) {
      final downloadProgress = _downloadProgresses[downloadId];
      if (downloadProgress == null) {
        return;
      }
      if (_shouldCreateNewConnections(downloadProgress)) {
        _createNewConnection(downloadId);
      }
    });
  }

  static void startDownloadRequest(IsolateArgsPair<int> args) async {
    final handlerChannel = IsolateChannel.connectSend(args.sendPort);
    final mainChannel = MainDownloadChannel(channel: handlerChannel);
    _downloadChannels[args.obj] = mainChannel;
    _runDynamicConnectionManagerTimer();
    mainChannel.listenToStream<DownloadIsolateData>((data) async {
      final downloadItem = data.downloadItem;
      final id = downloadItem.id;
      _setSettings(data);
      if (isAssembledFileInvalid(downloadItem)) {
        final progress = reassembleFile(downloadItem, data.baseTempDir);
        handlerChannel.sink.add(progress);
        return;
      }
      await sendToDownloadIsolates(data, handlerChannel);
      for (final channel in _downloadChannels[id]!.connectionChannels.values) {
        channel.listenToStream<DownloadProgress>(_handleProgressUpdates);
      }
    });
  }

  static _createNewConnection(int downloadId) async {
    final progress = _downloadProgresses[downloadId];
    if (progress == null) {
      return;
    }
    final mainChannel = _downloadChannels[downloadId]!;
    _downloadChannels[downloadId]!.segments?.split();
    List<Segment> segments = List.from(mainChannel.segments!.segments);
    if (segments.isEmpty) {
      return;
    }
    segments.forEach((element) {
      print(
          "************************* NEW SEGMENTS ******************************");
      print("**** START : ${element.startByte}");
      print("**** END : ${element.endByte}");
      print("************************************************************");
    });

    mainChannel.connectionChannels.forEach((segNum, connectionChannel) {
      final connSegment = mainChannel.segments!.segments
          .where((seg) => connectionChannel.startByte == seg.startByte)
          .firstOrNull;
      if (connSegment == null) {
        return;
      }
      _sendRefreshSegmentCommand(downloadId, segNum, connSegment);
      mainChannel.segments!.segments.remove(connSegment);
    });

    print("Segments after deletion  ${segments}");

    // for (final seg in segments) {
    //   final maxSegNum = getNewSegmentNumber(downloadId);
    //   print("Max segnum : $maxSegNum");
    //   final data = DownloadIsolateData(
    //     command: DownloadCommand.start,
    //     downloadItem: progress.downloadItem,
    //     baseTempDir: baseTempDir,
    //     totalConnections: totalConnections,
    //     baseSaveDir: baseSaveDir,
    //     startByte: seg.startByte,
    //     endByte: seg.endByte,
    //   );
    //   await _spawnSingleDownloadIsolate(data, maxSegNum);
    // }
  }

  static int getNewSegmentNumber(int id) =>
      _downloadChannels[id]!.connectionChannels.keys.toList().reduce(max) + 1;

  /// Instead of sending a pause command and restarting the download with new segments,
  /// we can just use the length setter in uint8list to cut the temp file to the length that we need (MUCH MORE OPTIMIZED)
  static void _sendRefreshSegmentCommand(
      int downloadId, int segmentNumber, Segment segment) {
    final mainChannel = _downloadChannels[downloadId];
    if (mainChannel == null || mainChannel.connectionChannels.isEmpty) {
      return;
    }

    final data = DownloadIsolateData(
      command: DownloadCommand.refreshSegment,
      baseSaveDir: baseSaveDir,
      totalConnections: totalConnections,
      downloadItem: _downloadProgresses[downloadId]!.downloadItem,
      baseTempDir: baseSaveDir,
      startByte: segment.startByte,
      endByte: segment.endByte,
      segmentNumber: segmentNumber,
    );

    mainChannel.connectionChannels[segmentNumber]!.channel.sink.add(data);
  }

  static void removeCompletedSegments(int id, Map<int, int> segmentmap) {
    final mainChannel = _downloadChannels[id]!;
    mainChannel.connectionChannels.forEach((segmentNumber, connectionChannel) {
      final endByte = segmentmap[connectionChannel.startByte];
      if (endByte != null &&
          endByte == connectionChannel.endByte &&
          connectionChannel.progress >= 100) {
        segmentmap.remove(connectionChannel.startByte);
      }
    });
  }

  // TODO take estimation into account
  static bool _shouldCreateNewConnections(DownloadProgress progress) {
    final downloadId = progress.downloadItem.id;
    print(" ^^^^^^^^^^^^^^^ TOTAL PROG : ${progress.totalDownloadProgress}");
    // final lastCheck = last_ds_checks[downloadId];
    final connectionChannels =
        _downloadChannels[downloadId]?.connectionChannels;
    return
        // lastCheck != null &&
        //   lastCheck + 4000 < _nowMillis &&
        progress.totalDownloadProgress < 1 &&
            connectionChannels != null &&
            connectionChannels.length < totalConnections;
  }

  // TODO implement
  static void validateTempFilesIntegrity() {}

  static void _handleProgressUpdates(DownloadProgress progress) async {
    final downloadChannel = _downloadChannels[progress.downloadItem.id]!;
    final int id = progress.downloadItem.id;
    _connectionProgresses[id] ??= {};
    _connectionProgresses[id]![progress.segmentNumber] = progress;
    if (progress.message == VALID_REFRESH_SEGMENT) {
      createConnection(progress);
    }
    double totalByteTransferRate = _calculateTotalTransferRate(id);
    final isTempWriteComplete = checkTempWriteCompletion(progress.downloadItem);
    final totalProgress = _calculateTotalDownloadProgress(id);
    _calculateEstimatedRemaining(id, totalByteTransferRate);
    final downloadProgress = DownloadProgress(
      downloadItem: progress.downloadItem,
      downloadProgress: totalProgress,
      totalDownloadProgress: totalProgress,
      transferRate: convertByteTransferRateToReadableStr(totalByteTransferRate),
    );
    _setEstimation(downloadProgress, totalProgress);
    _setButtonAvailability(downloadProgress, totalProgress);
    _setStatus(id, downloadProgress);
    if (isTempWriteComplete && isAssembleEligible(progress.downloadItem)) {
      downloadProgress.status = DownloadStatus.assembling;
      downloadChannel.channel.sink.add(downloadProgress);
      // TODO uncomment
      // final success = assembleFile(
      //   data.downloadItem,
      //   progress.baseTempDir,
      //   data.baseSaveDir,
      // );
      // _setCompletionStatuses(success, downloadProgress);
    }
    _setConnectionProgresses(downloadProgress);
    _downloadProgresses[id] = downloadProgress;
    downloadChannel.channel.sink.add(downloadProgress);
  }

  static void createConnection(DownloadProgress progress) async {
    final id = progress.downloadItem.id;
    final mainChannel = _downloadChannels[id]!;
    List<Segment> segments = List.from(mainChannel.segments!.segments);
    for (final seg in segments) {
      final maxSegNum = getNewSegmentNumber(id);
      print("Max segnum : $maxSegNum");
      final data = DownloadIsolateData(
        command: DownloadCommand.start,
        downloadItem: progress.downloadItem,
        baseTempDir: baseTempDir,
        totalConnections: totalConnections,
        baseSaveDir: baseSaveDir,
        startByte: seg.startByte,
        endByte: seg.endByte,
      );
      await _spawnSingleDownloadIsolate(data, maxSegNum);
    }
  }

  static Future<void> sendToDownloadIsolates(
      DownloadIsolateData data, IsolateChannel handlerChannel) async {
    final int id = data.downloadItem.id;
    Completer<void> com = Completer();
    if (_downloadChannels[id]!.connectionChannels.isEmpty) {
      final byteRangeMap = _findMissingByteRanges(data.downloadItem);
      final ranges = byteRangeMap.values.toList();
      _downloadChannels[id]!.segments = DownloadSegments.fromByteRanges(ranges);
      print("=========== MISSING BYTE RANGES =========");
      print(byteRangeMap);
      await _spawnDownloadIsolates(data, byteRangeMap);
    } else {
      print("INSIDE ELSE ================");
      // print(_downloadChannels[id]!.values.length);
      _downloadChannels[id]?.connectionChannels.forEach((seg, conn) {
        data.segmentNumber = seg;
        conn.channel.sink.add(data);
      });
    }
    return com.complete();
    // if (missingByteRanges.length > totalConnections) {
    /// TODO This shouldn't really happen but just in case we should do sth about it
    // }
  }

  static _spawnDownloadIsolates(
      DownloadIsolateData data, Map<int, Segment> missingByteRanges) async {
    missingByteRanges.forEach((segmentNumber, missingBytes) async {
      print("SPAWNING CONNECTION ISOLATE I-$segmentNumber");
      var newData = data.clone();
      newData.startByte = missingBytes.startByte;
      newData.endByte = missingBytes.endByte;
      await _spawnSingleDownloadIsolate(newData, segmentNumber);
    });
  }

  /// Analyzes the temp files and returns the missing temp byte ranges
  /// TODO handle if no missing bytes were found
  static Map<int, Segment> _findMissingByteRanges(
      DownloadItemModel downloadItem) {
    final contentLength = downloadItem.contentLength;
    List<File>? tempFiles;
    final tempDirPath = join(baseTempDir.path, downloadItem.uid);
    final tempDir = Directory(tempDirPath);
    if (tempDir.existsSync()) {
      tempFiles = tempDir.listSync().map((o) => o as File).toList();
    }

    if (tempFiles == null || tempFiles.isEmpty) {
      return {0: Segment(0, downloadItem.contentLength)};
    }

    tempFiles.sort(FileUtil.sortByFileName);
    String prevFileName = "";
    Map<int, Segment> missingBytes = {};
    for (var i = 0; i < tempFiles.length; i++) {
      final tempFile = tempFiles[i];
      final tempFileName = basename(tempFile.path);
      if (prevFileName == "") {
        prevFileName = tempFileName;
        continue;
      }

      final startByte = FileUtil.getStartByteFromTempFileName(tempFileName);
      final endByte = FileUtil.getEndByteFromTempFileName(tempFileName);
      final prevEndByte = FileUtil.getEndByteFromTempFileName(prevFileName);
      final segmentNumber =
          FileUtil.getSegmentNumberFromTempFileName(tempFileName);

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
      DownloadProgress downloadProgress, double totalProgress) {
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
  static void _setButtonAvailability(
      DownloadProgress progress, double totalProgress) {
    final downloadId = progress.downloadItem.id;
    if (_connectionProgresses[downloadId] == null) return;
    final progresses = _connectionProgresses[downloadId]!.values;
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
  static bool checkTempWriteCompletion(DownloadItemModel downloadItem) {
    final progresses = _connectionProgresses[downloadItem.id]!.values;
    final tempComplete =
        progresses.every((progress) => progress.writeProgress == 1);

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
      DownloadIsolateData data, int segmentNumber) async {
    final rPort = ReceivePort();
    final channel = IsolateChannel.connectReceive(rPort);
    final downloadId = data.downloadItem.id;
    data.segmentNumber = segmentNumber;
    print("Data.segmentNumber = ${data.segmentNumber}");
    final isolate = await Isolate.spawn(
      SingleConnectionManager.handleSingleConnection,
      rPort.sendPort,
      errorsAreFatal: false,
    );
    // final isolateCount = _activeDownloadIsolateCount[downloadId];
    // if (isolateCount == null) {
    //   _activeDownloadIsolateCount[downloadId] = 1;
    // } else {
    //   _activeDownloadIsolateCount[downloadId] = isolateCount + 1;
    // }
    print("SPAWNED $segmentNumber for id $downloadId");
    channel.sink.add(data);
    _connectionIsolates[downloadId] ??= {};
    _connectionIsolates[downloadId]![segmentNumber] = isolate;
    final connChannel = DownloadConnectionChannel(
      channel: channel,
      segmentNumber: segmentNumber,
      startByte: data.startByte!,
      endByte: data.endByte!,
    );

    _downloadChannels[downloadId]!
        .setConnectionChannel(segmentNumber, connChannel);

    connChannel.listenToStream<DownloadProgress>(_handleProgressUpdates);
  }

  static void _setSettings(DownloadIsolateData data) {
    baseSaveDir = data.baseSaveDir;
    baseTempDir = data.baseTempDir;
    connectionRetryTimeout = data.connectionRetryTimeout;
    maxConnectionRetryCount = data.maxConnectionRetryCount;
    totalConnections = data.totalConnections;

    settings = Settings(
      baseSaveDir: data.baseSaveDir,
      baseTempDir: data.baseTempDir,
      totalConnections: data.totalConnections,
      connectionRetryTimeout: data.connectionRetryTimeout,
      maxConnectionRetryCount: data.maxConnectionRetryCount,
    );
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
