import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:brisk/download_engine/connection_segment_message.dart';
import 'package:brisk/model/download_item_model.dart';
import 'package:brisk/download_engine/internal_messages.dart';
import 'package:brisk/model/download_progress.dart';
import '../constants/types.dart';
import '../util/file_util.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
import '../constants/download_status.dart';

class HttpDownloadRequest {
  /// Buffer containing the received bytes
  List<List<int>> buffer = [];

  /// The download progress percentage for this segment
  double downloadProgress = 0;

  // The download progress in relation to the total progress
  double totalDownloadProgress = 0;

  /// The total of received bytes for this request
  int totalReceivedBytes = 0;

  /// The total byte length of un-flushed buffer.
  /// This value reset to 0 after each flush.
  int tempReceivedBytes = 0;

  bool supportsPause = false;

  String transferRate = '';

  String status = 'Stopped';

  /// Time used to calculate the elapsed milliseconds between data chunk transfers
  int _tmpTime = DateTime.now().millisecondsSinceEpoch;

  /// Buffer used to calculate transfer rate
  List<List<int>> _transferRateChunkBuffer = [];

  double bytesTransferRate = 0;

  String estimatedRemaining = '';

  bool paused = false;

  String detailsStatus = "";

  int totalWrittenBytes = 0;

  /// calculate and update transfer rate every 0.7 seconds
  static const int _transferRateCalculationWindowMillis = 700;

  http.Client client = http.Client();

  /// Threshold is currently only dynamically decided (4 times the byte transfer rate per second -
  /// and less than 100MB)
  // static const _staticFlushThreshold = 524288;
  double _dynamicFlushThreshold = 52428800;

  int _flushQueueCount = 0;
  int _flushQueueComplete = 0;

  double writeProgress = 0;
  bool isWritingFilePart = false;

  /// Determines if the user is permitted to hit the pause button or not.
  /// In order to prevent issues (mostly regarding [startButtonEnabled] property),
  /// the user is only permitted to hit the pause button only once before hitting
  /// the resume button.
  bool pauseButtonEnabled = false;

  DownloadItemModel downloadItem;

  final Directory baseTempDir;

  /// Callback method used to update the handler isolate on the current progress of the download
  DownloadProgressCallback? progressCallback;

  int startByte;

  int endByte;

  bool segmentRefreshed = false;

  /// TODO rename to connectionNumber
  int segmentNumber;

  int previousBufferEndByte = 0;

  /// Connection retry
  int lastResponseTimeMillis = DateTime.now().millisecondsSinceEpoch;

  Timer? connectionResetTimer;

  int _retryCount = 0;

  int maxConnectionRetryCount;

  int connectionRetryTimeoutMillis;

  HttpDownloadRequest({
    required this.downloadItem,
    required this.baseTempDir,
    required this.startByte,
    required this.endByte,
    required this.segmentNumber,
    this.connectionRetryTimeoutMillis = 10000,
    this.maxConnectionRetryCount = -1,
  });

  /// Starts the download request.
  /// [progressCallback] is used to let the provider know that the values are
  /// changed so that it calls notify listeners which can be used to display its live progress.
  void start(DownloadProgressCallback progressCallback,
      {bool connectionReset = false}) {
    if (!connectionReset && startNotAllowed) return;
    // _runConnectionResetTimer(); // TODO uncomment

    _init(connectionReset, progressCallback);
    _notifyProgress();

    if (_isDownloadCompleted()) {
      _setDownloadComplete();
      _notifyProgress();
      return;
    }

    final request = buildDownloadRequest();
    sendDownloadRequest(request);
  }

  void _init(bool connectionReset, DownloadProgressCallback progressCallback) {
    detailsStatus =
        connectionReset ? DownloadStatus.resetting : DownloadStatus.connecting;
    status = detailsStatus;
    this.progressCallback = progressCallback;
    client = http.Client();
    paused = false;
  }

  http.Request buildDownloadRequest() {
    final request = http.Request('GET', Uri.parse(downloadItem.downloadUrl));
    request.headers.addAll({
      "User-Agent":
          "Mozilla/5.0 (Windows NT 6.1; Trident/7.0; rv:11.0) like Gecko;"
    });
    _setByteRangeHeader(request);
    return request;
  }

  void sendDownloadRequest(http.Request request) {
    try {
      final response = client.send(request);
      response.asStream().cast<http.StreamedResponse>().listen((response) {
        response.stream.listen(
          _processChunk,
          onDone: _onDownloadComplete,
          onError: _onError,
        );
      });
    } catch (e) {
      _onError(e);
      _notifyProgress();
    }
  }

  void _setDownloadComplete() {
    pauseButtonEnabled = true;
    downloadProgress = 1;
    writeProgress = 1;
    detailsStatus = DownloadStatus.complete;
    totalDownloadProgress = segmentLength / downloadItem.contentLength;
  }

  void _updateDownloadProgress() {
    downloadProgress = totalReceivedBytes / segmentLength;
    totalDownloadProgress = totalReceivedBytes / downloadItem.contentLength;
    _notifyProgress();
  }

  // TODO USE THIS
  void _runConnectionResetTimer() {
    if (connectionResetTimer != null) return;
    connectionResetTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (connectionRetryAllowed) {
        resetConnection();
        _retryCount++;
      }
    });
  }

  void resetConnection() {
    client.close();
    _clearBuffer();
    _dynamicFlushThreshold = double.infinity;
    start(progressCallback!, connectionReset: true);
  }

  void cancel({bool failure = false}) {
    client.close();
    _cancelConnectionResetTimer();
    _clearBuffer();
    final status = failure ? DownloadStatus.failed : DownloadStatus.canceled;
    _updateStatus(status);
    detailsStatus = status;
    _notifyProgress();
  }

  void _cancelConnectionResetTimer() {
    connectionResetTimer?.cancel();
    connectionResetTimer = null;
  }

  /// TODO don't create a new obj every time
  void _notifyProgress() {
    final data = DownloadProgress.loadFromHttpDownloadRequest(this);
    progressCallback!(data);
  }

  /// Sets the request byte range header to achieve resume functionality if the
  /// parts of the file has already been written.
  /// The length of the existing file is set to the start value and the TODO FIX DOC (SEGMENTED)
  /// content-length retrieved from the HEAD Request is set to the end value.
  /// returns whether the segment download has already been finished or not.
  void _setByteRangeHeader(http.Request request) {
    tempDirectory.createSync(recursive: true);

    final newStartByte = getNewStartByte();
    request.headers.addAll(
      {
        "Range": "bytes=$newStartByte-$endByte",
        // "Keep-Alive": "timeout=5, max=1"
      },
    );
    final existingLength = newStartByte - this.startByte;
    downloadProgress = existingLength / segmentLength;
    writeProgress = downloadProgress;
    totalReceivedBytes = existingLength;
    totalWrittenBytes = existingLength;
    totalDownloadProgress = totalReceivedBytes / downloadItem.contentLength;
    _notifyProgress();
  }

  int getNewStartByte() {
    final tempFiles = _getTempFilesSorted(thisConnectionOnly: true);
    if (tempFiles.isEmpty) {
      return startByte;
    }
    final lastFileName = basename(tempFiles.last.path);
    return FileUtil.getEndByteFromTempFileName(lastFileName) + 1;
  }

  void _processChunk(List<int> chunk) {
    try {
      _doProcessChunk(chunk);
    } catch (e) {
      print(e); // TODO Add to log files
      client.close();
      _clearBuffer();
    }
  }

  /// Processes each data [chunk] in [streamedResponse].
  /// Once the [tempReceivedBytes] hits the [_dynamicFlushThreshold], the buffer is
  /// flushed to the disk. This process continues until the download has been
  /// finished. The buffer will be emptied after each flush
  void _doProcessChunk(List<int> chunk) {
    _updateStatus(DownloadStatus.downloading);
    lastResponseTimeMillis = _nowMillis;
    pauseButtonEnabled = downloadItem.supportsPause;
    detailsStatus = transferRate;
    _notifyProgress();
    if (downloadProgress == 1 && !isWritePartCaughtUp) {
      _updateStatus("Download Complete");
    }
    _calculateTransferRate(chunk);
    _calculateDynamicFlushThreshold();
    buffer.add(chunk);
    _updateReceivedBytes(chunk);
    _updateDownloadProgress();
    if (receivedBytesExceededEndByte) {
      _onByteExceeded();
      return;
    }

    if (tempReceivedBytes > _dynamicFlushThreshold) {
      _flushBuffer();
    }
    _notifyProgress();
  }

  void _onByteExceeded() {
    client.close();
    _flushBuffer();
    _correctTempBytes();
    _setDownloadComplete();
    _notifyProgress();
    // segmentRefreshed = false;
  }

  /// Flushes the buffer containing the received bytes to the disk.
  /// all flush operations write temp files with connection number and
  /// their corresponding byte ranges
  /// e.g. 0#100-2500 => connectionNumber#startByte-endByte
  void _flushBuffer() {
    if (buffer.isEmpty) return;
    final bytes = _writeToUin8List(tempReceivedBytes, buffer);
    _flushQueueCount++;
    final filePath = join(
      tempDirectory.path,
      "${segmentNumber}#${tempFileStartByte}-${tempFileEndByte}",
    );
    previousBufferEndByte += bytes.lengthInBytes;
    final file = File(filePath);
    file.writeAsBytesSync(mode: FileMode.writeOnly, bytes);
    _onTempFileWriteComplete(file);
    _clearBuffer();
  }

  void _onTempFileWriteComplete(File file) {
    if (isWritePartCaughtUp && paused) {
      _updateStatus("Download Paused");
    }
    totalWrittenBytes += file.lengthSync();
    writeProgress = totalWrittenBytes / segmentLength;
    if (writeProgress == 1) {
      detailsStatus = DownloadStatus.complete;
    }
    _flushQueueComplete++;
    _notifyProgress();
  }

  void _correctTempBytes() {
    final tempFiles = _getTempFilesSorted();
    List<File> tempFilesToDelete = [];
    Uint8List? newBufferToWrite;
    File? tempFileToCut;
    int? newBufferStartByte;
    for (var file in tempFiles) {
      final fileName = basename(file.path);
      final tempStartByte = FileUtil.getStartByteFromTempFileName(fileName);
      final tempEndByte = FileUtil.getEndByteFromTempFileName(fileName);
      if (this.endByte < tempStartByte) {
        print("THROAWAY FILE : ${tempEndByte - tempStartByte}");
        tempFilesToDelete.add(file);
        continue;
      }
      if (this.endByte < tempEndByte) {
        tempFileToCut = file;
        newBufferStartByte = tempStartByte;
        final bufferCutLength = this.endByte - tempStartByte + 1;
        newBufferToWrite = FileUtil.readSync(file, bufferCutLength);
        tempFilesToDelete.add(file);
      }
    }

    for (final file in tempFilesToDelete) {
      totalReceivedBytes -= file.lengthSync();
      file.deleteSync();
    }

    if (newBufferToWrite != null) {
      final newBufferEndByte =
          newBufferStartByte! + newBufferToWrite.lengthInBytes - 1;
      final newTempFilePath = join(
        tempDirectory.path,
        "${segmentNumber}#${newBufferStartByte}-${newBufferEndByte}",
      );
      File(newTempFilePath).writeAsBytesSync(newBufferToWrite);
      totalReceivedBytes += newBufferToWrite.lengthInBytes;
      totalWrittenBytes = segmentLength;
    }
    totalDownloadProgress = totalReceivedBytes / downloadItem.contentLength;
  }

  bool _isDownloadCompleted() {
    final tempFiles = _getTempFilesSorted(thisConnectionOnly: false)
        .where(
          (file) =>
              FileUtil.getStartByteFromTempFile(file) >= this.startByte &&
              FileUtil.getEndByteFromTempFile(file) <= this.endByte,
        )
        .toList();

    if (tempFiles.isEmpty) {
      return false;
    }

    for (var i = 0; i < tempFiles.length; i++) {
      if (i == 0) continue;
      final file = tempFiles[i];
      final prevFile = tempFiles[i - 1];
      final fileStartByte = FileUtil.getStartByteFromTempFile(file);
      final fileEndByte = FileUtil.getEndByteFromTempFile(file);
      final prevFileEndByte = FileUtil.getEndByteFromTempFile(prevFile);
      final isLastFile = i == tempFiles.length - 1;
      if ((fileStartByte != prevFileEndByte) ||
          (isLastFile && fileEndByte != this.endByte)) {
        return false;
      }
    }
    return true;
  }

  List<File> _getTempFilesSorted({bool thisConnectionOnly = true}) {
    if (!tempDirectory.existsSync()) {
      return List.empty();
    }

    var tempFiles = tempDirectory.listSync().map((e) => e as File).toList();
    if (thisConnectionOnly) {
      tempFiles = tempFiles
          .where((file) => basename(file.path).startsWith("${segmentNumber}#"))
          .toList();
    }

    tempFiles.sort(FileUtil.sortByByteRanges);
    return tempFiles;
  }

  void _calculateTransferRate(List<int> chunk) {
    _transferRateChunkBuffer.add(chunk);
    final nowMillis = _nowMillis;
    if (_tmpTime + _transferRateCalculationWindowMillis > nowMillis) return;
    var timeBefore = _tmpTime;
    _tmpTime = nowMillis;
    int len = 0;
    for (var element in _transferRateChunkBuffer) {
      len += element.length;
    }
    transferRate = _getTransferRateStr(timeBefore, len);
    _transferRateChunkBuffer = [];
  }

  String _getTransferRateStr(int timeBefore, int len) {
    final elapsedSec = (_tmpTime - timeBefore) / 1000;
    if (elapsedSec <= 0) return "";
    final speedInMegaBytes = (len / 1048576) / elapsedSec;
    final speedInKiloBytes = (len / 1024) / elapsedSec;
    bytesTransferRate = len / elapsedSec;

    if (speedInMegaBytes > 1) {
      return '${speedInMegaBytes.toStringAsFixed(2)} MB/s';
    } else if (speedInKiloBytes > 1) {
      return '${speedInKiloBytes.toStringAsFixed(2)} KB/s';
    } else {
      return '${bytesTransferRate.toStringAsFixed(2)} B/s';
    }
  }

  /// TODO fix threshold = 2 && reduce default val
  void _calculateDynamicFlushThreshold() {
    const double hundredMegaBytes = 104857600;
    _dynamicFlushThreshold = bytesTransferRate * 2.5 < hundredMegaBytes
        ? bytesTransferRate * 2.5
        : hundredMegaBytes;
  }

  void pause(DownloadProgressCallback progressCallback) {
    paused = true;
    _cancelConnectionResetTimer();
    this.progressCallback = progressCallback;
    _flushBuffer();
    _updateStatus(DownloadStatus.paused);
    detailsStatus = DownloadStatus.paused;
    client.close();
    pauseButtonEnabled = false;
    _notifyProgress();
  }

  void requestRefreshSegment() {
    print("()()()()()() REFRESH ()()(()()()()())");
    print("()()()()()() Start : $startByte ()()(()()()()())");
    print("()()()()()() End : $endByte ()()(()()()()())");
    print("()()()()()() TotalReceive : $totalReceivedBytes ()()(()()()()())");
    print("()()()()()() REFRESH ()()(()()()()())");
    final prevEndByte = this.endByte;
    print("S$segmentNumber this.endByte = ${this.endByte}");
    print("S$segmentNumber prevEndByte = ${prevEndByte}");
    final newEndByte = _newValidRefreshSegmentEndByte;
    if (newEndByte < 0) {
      return;
    }
    this.endByte = newEndByte;
    final message = ConnectionSegmentMessage(
      downloadItem: downloadItem,
      internalMessage: InternalMessage.VALID_REFRESH_SEGMENT,
      validStartByte: this.endByte + 1,
      validEndByte: prevEndByte,
    );
    print("S$segmentNumber this.endByte = ${this.endByte}");
    print("S$segmentNumber prevEndByte = ${prevEndByte}");
    print(
        "VALID_REFRESH_SEGMENT:::: ${message.validStartByte} - ${message.validEndByte}");
    segmentRefreshed = true;
    progressCallback!(message);
    return;
  }

  int get _newValidRefreshSegmentEndByte =>
      ((this.endByte - (this.startByte + totalReceivedBytes)) / 2).floor() +
      this.startByte +
      totalReceivedBytes;

  void _clearBuffer() {
    buffer = [];
    tempReceivedBytes = 0;
  }

  /// Flushes the remaining bytes in the buffer and completes the download.
  void _onDownloadComplete() {
    if (paused) return;
    bytesTransferRate = 0;
    downloadProgress = totalReceivedBytes / segmentLength;
    print("**************************** I-$segmentNumber ******************");
    print("my download prog : $downloadProgress");
    print("total rec : $totalReceivedBytes");
    print("Seg len : $segmentLength");
    print("Con len : ${downloadItem.contentLength}");
    print("******************************************************************");

    totalDownloadProgress = totalReceivedBytes / downloadItem.contentLength;
    _flushBuffer();
    print(
        "&&&&&&&&&& Download Progress $downloadProgress   CAUGHT UP ? $isWritePartCaughtUp");
    // if (downloadProgress == 1 && isWritePartCaughtUp) {
    _updateStatus(DownloadStatus.complete);
    detailsStatus = DownloadStatus.complete;
    // }
    _notifyProgress();
    // segmentRefreshed = false;
    client.close();
  }

  void _onError(dynamic error, [dynamic s]) {
    try {
      client.close();
    } catch (e) {}
    _clearBuffer();
    _notifyProgress();
    print(error);
    throw error;
  }

  Uint8List _writeToUin8List(int length, List<List<int>> chunks) {
    int start = 0;
    final bytes = Uint8List(length);
    for (var chunk in chunks) {
      bytes.setRange(start, start + chunk.length, chunk);
      start += chunk.length;
    }
    return bytes;
  }

  void _updateReceivedBytes(List<int> chunk) {
    totalReceivedBytes += chunk.length;
    tempReceivedBytes += chunk.length;
  }

  void _updateStatus(String status) {
    this.status = status;
    downloadItem.status = this.status;
  }

  bool get startNotAllowed =>
      (paused && !isWritePartCaughtUp) ||
      (!paused && downloadProgress > 0) ||
      downloadItem.status == DownloadStatus.complete ||
      status == DownloadStatus.complete ||
      detailsStatus == DownloadStatus.complete;

  int get _nowMillis => DateTime.now().millisecondsSinceEpoch;

  /// e.g. 0#0-50, 0#51-150, 1#151-400 and so on...
  String get tempFileName =>
      "${segmentNumber}#${tempFileStartByte}-${tempFileEndByte}";

  /// The end byte of the buffer with respect to the target file (The file which will be built after download completes).
  int get tempFileEndByte =>
      startByte + previousBufferEndByte + tempReceivedBytes - 1;

  /// The start byte of the buffer with respect to the target file
  int get tempFileStartByte => previousBufferEndByte == 0
      ? startByte
      : startByte + previousBufferEndByte;

  Directory get tempDirectory => Directory(join(
        baseTempDir.path,
        downloadItem.uid.toString(),
      ));

  /// Determines if the user is permitted to hit the start (Resume) button or not
  /// for further information refer to docs for [isWritePartCaughtUp]
  // bool startButtonEnabled = false;
  bool get isStartButtonEnabled =>
      (isWritePartCaughtUp && paused) || downloadProgress == 0;

  bool get receivedBytesExceededEndByte =>
      segmentRefreshed && startByte + totalReceivedBytes > this.endByte;

  /// TODO FIX
  /// TODO
  ///TODO
  int get segmentLength => this.endByte == downloadItem.contentLength
      ? this.endByte - this.startByte
      : this.endByte - this.startByte;

  bool get connectionRetryAllowed =>
      lastResponseTimeMillis + connectionRetryTimeoutMillis < _nowMillis &&
      status != DownloadStatus.paused &&
      status != DownloadStatus.complete &&
      detailsStatus != DownloadStatus.canceled &&
      detailsStatus != DownloadStatus.complete &&
      isWritePartCaughtUp &&
      (_retryCount < maxConnectionRetryCount || maxConnectionRetryCount == -1);

  /// In order for download's play/pause functionality to work, the total received
  /// bytes must be calculated and be used for the resume request header. Therefore,
  /// before the resume request is send, the user has to wait for all part write operations
  /// to complete so that the value calculated for the total received bytes is valid.
  /// This method determines if the part write operation is caught up to the current download progress.
  bool get isWritePartCaughtUp => _flushQueueComplete == _flushQueueCount;
}
