import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:brisk/model/download_item_model.dart';
import 'package:brisk/model/download_progress.dart';
import '../constants/types.dart';
import '../util/file_util.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
import '../constants/download_status.dart';

class MultiConnectionHttpDownloadRequest {
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

  final int segmentNumber;

  /// Threshold which determines the buffer flush frequency (in bytes)
  /// Threshold is currently only dynamically decided (4 times the byte transfer rate per second -
  /// and less than 100MB)
  // static const _staticFlushThreshold = 524288;
  double _dynamicFlushThreshold = 52428800;

  int _chunkCount = 0;
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

  final int startByte;

  final int endByte;

  final int totalSegments;

  /// Connection retry
  int lastResponseTimeMillis = DateTime.now().millisecondsSinceEpoch;

  Timer? connectionResetTimer;

  int _retryCount = 0;

  int maxConnectionRetryCount;
  
  int connectionRetryTimeoutMillis;

  MultiConnectionHttpDownloadRequest({
    required this.downloadItem,
    required this.baseTempDir,
    required this.segmentNumber,
    required this.startByte,
    required this.endByte,
    required this.totalSegments,
    this.connectionRetryTimeoutMillis = 10000,
    this.maxConnectionRetryCount = -1,
  });

  /// Starts the download request.
  /// [notifyChange] is used to let the provider know that the values are
  /// changed so that it calls notify listeners
  /// which can be used to display its live progress.
  void start(DownloadProgressCallback progressCallback,
      {bool connectionReset = false}) {
    if (!connectionReset && startNotAllowed) return;
    _runTimerBasedConnectionReset();

    detailsStatus =
        connectionReset ? DownloadStatus.resetting : DownloadStatus.connecting;
    status = detailsStatus;
    this.progressCallback = progressCallback;
    client = http.Client();
    paused = false;
    _notifyChange();

    final request = http.Request('GET', Uri.parse(downloadItem.downloadUrl));
    request.headers.addAll({'content-type': 'multipart/byteranges;'});
    final isFinished = _setByteRangeHeader(request);
    if (isFinished) {
      pauseButtonEnabled = true;
      downloadProgress = 1;
      writeProgress = 1;
      detailsStatus = DownloadStatus.complete;
      _notifyChange();
      return;
    }
    _setChunkCount();

    try {
      var response = client.send(request);
      response.timeout(const Duration(seconds: 5));
      response.asStream().listen((http.StreamedResponse streamedResponse) {
        streamedResponse.stream
            .listen(_processChunk, onDone: _onDownloadComplete, onError: (e) {
          client.close();
          _notifyChange();
        });
      });
    } catch (e) {
      _notifyChange();
    }
  }

  void _runTimerBasedConnectionReset() {
    if (connectionResetTimer != null) return;
    connectionResetTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (connectionRetryAllowed) {
        resetConnection();
        _retryCount++;
      }
    });
  }

  void _setChunkCount() {
    final files =
        tempDirectory.listSync(recursive: true).map((file) => file as File);
    _chunkCount = files.isEmpty ? 0 : files.length + 1;
  }

  void resetConnection() {
    client.close();
    _clearBuffer();
    _dynamicFlushThreshold = double.infinity;
    start(progressCallback!, connectionReset: true);
  }

  void cancel({bool failure = false}) {
    client.close();
    _clearBuffer();
    final status = failure ? DownloadStatus.failed : DownloadStatus.canceled;
    _updateStatus(status);
    detailsStatus = status;
    _notifyChange();
  }

  void _notifyChange() {
    final data = DownloadProgress.loadFromMultiConnectionDownloadRequest(this);
    progressCallback!(data);
  }

  /// Sets the request byte range header to achieve resume functionality if the
  /// parts of the file has already been written.
  /// The length of the existing file is set to the start value and the TODO FIX DOC (SEGMENTED)
  /// content-length retrieved from the HEAD Request is set to the end value.
  /// returns whether the segment download has already been finished or not.
  bool _setByteRangeHeader(http.Request request) {
    tempDirectory.createSync(recursive: true);
    final existingLength = FileUtil.calculateReceivedBytesSync(tempDirectory);
    final newStartByte =
        existingLength == 0 ? startByte : startByte + existingLength;
    request.headers.addAll(
      {"Range": "bytes=$newStartByte-$endByte"},
    );
    downloadProgress = existingLength / segmentLength;
    writeProgress = downloadProgress;
    totalReceivedBytes = existingLength;
    totalWrittenBytes = existingLength;
    totalDownloadProgress = totalReceivedBytes / downloadItem.contentLength;
    _notifyChange();
    return newStartByte >= endByte;
  }

  /// Processes each data [chunk] in [streamedResponse].
  /// Once the [tempReceivedBytes] hits the [_dynamicFlushThreshold], the buffer is
  /// flushed to the disk. This process continues until the download has been
  /// finished. The buffer will be emptied after each flush to be
  void _processChunk(List<int> chunk) {
    _updateStatus(DownloadStatus.downloading);
    lastResponseTimeMillis = _nowMillis;
    pauseButtonEnabled = downloadItem.supportsPause;
    detailsStatus = transferRate;
    _notifyChange();
    if (downloadProgress == 1 && !isWritePartCaughtUp) {
      _updateStatus("Download Complete");
    }
    _calculateTransferRate(chunk);
    _calculateDynamicFlushThreshold();
    downloadItem.progress = downloadProgress;
    buffer.add(chunk);
    _updateReceivedBytes(chunk);
    downloadProgress = totalReceivedBytes / segmentLength;
    totalDownloadProgress = totalReceivedBytes / downloadItem.contentLength;
    _notifyChange();
    if (tempReceivedBytes > _dynamicFlushThreshold) {
      _flushBuffer();
    }
  }


  /// Flushes the buffer containing the received bytes
  /// to the disk.
  ///
  /// all flush operations write temp files which their name corresponds to the order
  /// in which they were received.
  /// The path for the temp files is determined as followed :
  /// [FileUtil.defaultTempFileDir]/[downloadItem.uid]/[segmentNumber]
  void _flushBuffer() {
    final filePath = join(tempDirectory.path, _chunkCount.toString());
    final bytes = _writeToUin8List(tempReceivedBytes, buffer);
    _chunkCount++;
    _flushQueueCount++;
    File(filePath).writeAsBytes(mode: FileMode.writeOnly, bytes).then((file) {
      if (isWritePartCaughtUp && paused) {
        _updateStatus("Download Paused");
      }
      totalWrittenBytes += file.lengthSync();
      writeProgress = totalWrittenBytes / segmentLength;
      if (writeProgress == 1) {
        detailsStatus = DownloadStatus.complete;
      }
      _flushQueueComplete++;
      _notifyChange();
    });
    _clearBuffer();
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

  void _calculateDynamicFlushThreshold() {
    const double hundredMegaBytes = 104857600;
    _dynamicFlushThreshold = bytesTransferRate * 2.5 < hundredMegaBytes
        ? bytesTransferRate * 2.5
        : hundredMegaBytes;
  }

  void pause(DownloadProgressCallback progressCallback) {
    paused = true;
    this.progressCallback = progressCallback;
    _flushBuffer();
    _updateStatus(DownloadStatus.paused);
    detailsStatus = DownloadStatus.paused;
    client.close();
    pauseButtonEnabled = false;
    _notifyChange();
  }

  void _clearBuffer() {
    buffer = [];
    tempReceivedBytes = 0;
  }

  /// Flushes the remaining bytes in the buffer and completes the download.
  void _onDownloadComplete() {
    if (paused) return;
    bytesTransferRate = 0;
    downloadProgress = totalReceivedBytes / segmentLength;
    _flushBuffer();
    if (downloadProgress == 1 && isWritePartCaughtUp) {
      _updateStatus(DownloadStatus.complete);
      detailsStatus = DownloadStatus.complete;
    }
    _notifyChange();
    client.close();
  }

  Uint8List _writeToUin8List(int length, List<List<int>> chunks) {
    int start = 0;
    final bytes = Uint8List(length);
    for (var chunk in chunks) {
      bytes.setRange(start, start + chunk.length, chunk);
      start += chunk.length;
    }
    chunks = [];
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

  Directory get tempDirectory => Directory(join(
        baseTempDir.path,
        downloadItem.uid.toString(),
        segmentNumber.toString(),
      ));


  /// Determines if the user is permitted to hit the start (Resume) button or not
  /// for further information refer to docs for [isWritePartCaughtUp]
  // bool startButtonEnabled = false;
  bool get isStartButtonEnabled =>
      (isWritePartCaughtUp && paused) || downloadProgress == 0;

  int get segmentLength => endByte == downloadItem.contentLength
      ? endByte - startByte
      : endByte - startByte + 1;

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
