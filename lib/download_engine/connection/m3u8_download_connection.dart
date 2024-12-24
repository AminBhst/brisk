import 'dart:io';

import 'package:brisk/constants/http_constants.dart';
import 'package:brisk/constants/types.dart';
import 'package:brisk/download_engine/connection/base_http_download_connection.dart';
import 'package:brisk/download_engine/download_status.dart';
import 'package:brisk/download_engine/message/download_progress_message.dart';
import 'package:brisk/download_engine/model/m3u8.dart';
import 'package:brisk/download_engine/segment/segment.dart';
import 'package:brisk/download_engine/util/m3u8_util.dart';
import 'package:brisk/download_engine/util/temp_file_util.dart';
import 'package:dartx/dartx_io.dart';
import 'package:encrypt/encrypt.dart';
import 'package:http/io_client.dart';
import 'package:http/src/client.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;

class M3U8DownloadConnection extends BaseHttpDownloadConnection {
  M3U8Segment m3u8segment;
  bool clientInitialized = false;
  int flushBufferCounter = 1;

  /// TODO try with lower value as well
  static const int _maximumFileSizeForInMemoryDecryption = 50000000;

  M3U8DownloadConnection({
    required super.downloadItem,
    required super.segment,
    required super.connectionNumber,
    required super.settings,
    required this.m3u8segment,
  });

  @override
  void doStart(
    DownloadProgressCallback progressCallback, {
    bool connectionReset = false,
    bool reuseConnection = false,
  }) {
    print("#$connectionNumber Got start............");
    tempDirectory.createSync(recursive: true);
    startLogFlushTimer();
    logger?.info(
      "Starting download for m3u8 segment ${m3u8segment.sequenceNumber} with "
      "reuseConnection: $reuseConnection "
      "connectionReset: $connectionReset "
      "url: ${m3u8segment.url}",
    );
    if (isDownloadCompleted) {
      logger?.info(
        "Download segment ${m3u8segment.sequenceNumber} is already completed!",
      );
      connectionStatus = DownloadStatus.connectionComplete;
      notifyProgress(completionSignal: true);
      return;
    }
    tempDirectory.listSync().forEach((file) => file.deleteSync);
    init(connectionReset, progressCallback, reuseConnection);
    if (connectionReset) {
      resetStatus();
    }
    notifyProgress();
    final request = buildDownloadRequest(false);
    sendDownloadRequest(request);
  }

  @override
  bool get isDownloadCompleted {
    final finalSegmentPath = join(
      tempDirectory.path,
      "final-segment.ts",
    );
    return File(finalSegmentPath).existsSync();
  }

  @override
  void resetConnection() {
    logger?.info("Resetting connection....");
    closeClient_withCatch();
    clearBuffer();
    dynamicFlushThreshold = double.infinity;
    reset = true;
    this.clientInitialized = false;
    start(progressCallback!, connectionReset: true);
  }

  @override
  void init(connectionReset, progressCallback, reuseConnection) {
    connectionStatus =
        connectionReset ? DownloadStatus.resetting : DownloadStatus.connecting;
    overallStatus = connectionStatus;
    this.progressCallback = progressCallback;
    if (!clientInitialized) {
      client = buildClient();
      clientInitialized = true;
    }
    paused = false;
    reset = false;
    terminatedOnCompletion = false;
  }

  @override
  http.Request buildDownloadRequest(bool _) {
    return http.Request('GET', Uri.parse(m3u8segment.url))
      ..headers.addAll({
        "User-Agent":
            "Mozilla/5.0 (Windows NT 6.1; Trident/7.0; rv:11.0) like Gecko;",
        "Connection": "keep-alive",
        "Keep-Alive": "timeout=4",
      });
  }

  @override
  void doProcessChunk(List<int> chunk) {
    if (chunk.isEmpty || paused) return;
    updateStatus(DownloadStatus.downloading);
    lastResponseTimeMillis = _nowMillis;
    pauseButtonEnabled = downloadItem.supportsPause;
    connectionStatus = transferRate;
    calculateTransferRate(chunk);
    calculateDynamicFlushThreshold();
    buffer.add(chunk);
    updateDownloadProgress();
    if (tempReceivedBytes > dynamicFlushThreshold) {
      flushBuffer();
    }
    notifyProgress();
  }

  @override
  void flushBuffer() {
    if (buffer.isEmpty) return;
    isWritingTempFile = true;
    final bytes = writeToUin8List(buffer);
    final filePath = join(tempDirectory.path, flushBufferCounter.toString());
    previousBufferEndByte += bytes.lengthInBytes;
    File(filePath).writeAsBytesSync(mode: FileMode.writeOnly, bytes);
    logger?.info(
      newLine: false,
      "FlushBuffer for segment $startByte-$endByte ::${basename(filePath)}",
    );
    clearBuffer();
    sendLogBuffer();
    flushBufferCounter++;
    isWritingTempFile = false;
  }

  @override
  void onDownloadComplete() async {
    if (paused || reset) return;
    flushBuffer();
    connectionStatus = DownloadStatus.connectionComplete;
    logger?.info("Download complete with completion signal");
    await assembleM3U8Segment();
    notifyProgress(completionSignal: true);
  }

  /// Merges all temporary files of an m3u8 segment into one file and decrypts it if required.
  /// The successful completion of this method's execution marks the segment as fully downloaded.
  /// It does so by renaming the file at the end of the operation which can be used by the engine
  /// to mark this segment as fully downloaded in order to ignore it for a resume operation.
  Future<void> assembleM3U8Segment() async {
    final tempFiles = tempDirectory.listSync().map((e) => e as File).toList()
      ..sort(
        (a, b) => basename(a.path).toInt().compareTo(basename(b.path).toInt()),
      );
    final segmentFile = File(join(tempDirectory.path, "Final_Segment.ts"));
    for (final file in tempFiles) {
      final bytes = file.readAsBytesSync();
      segmentFile.writeAsBytesSync(bytes, mode: FileMode.writeOnlyAppend);
    }
    if (m3u8segment.encryptionMethod == M3U8EncryptionMethod.AES_128) {
      await decryptAes128File(
        segmentFile,
        m3u8segment.encryptionDetails!.keyBytes!,
        decryptionIV!,
        chunked:
            segmentFile.lengthSync() > _maximumFileSizeForInMemoryDecryption,
      );
    }
    final newPath = join(tempDirectory.path, "final-segment.ts");
    segmentFile.renameSync(newPath);
    tempDirectory
        .listSync()
        .map((e) => e as File)
        .where((f) => f.name != "final-segment.ts")
        .forEach((f) => f.deleteSync());
  }

  @override
  Directory get tempDirectory => Directory(
        join(
          settings.baseTempDir.path,
          downloadItem.uid.toString(),
          m3u8segment.sequenceNumber.toString(),
        ),
      );

  @override
  Client buildClient() {
    final client = HttpClient()
      ..findProxy = (url) {
        return "PROXY localhost:10808;";
      };
    return IOClient(client);
  }

  @override
  void pause(DownloadProgressCallback? progressCallback) {
    clientInitialized = false;
    paused = true;
    logger?.info("Paused connection $connectionNumber");
    cancelLogFlushTimer();
    if (progressCallback != null) {
      this.progressCallback = progressCallback;
    }
    clearBuffer();
    print("Setting pause for connection ${connectionNumber}");
    updateStatus(DownloadStatus.paused);
    connectionStatus = DownloadStatus.paused;
    client.close();
    pauseButtonEnabled = false;
    notifyProgress();
  }

  /// Initialization vector used for decrypting AES-128 based m3u8 encryption
  IV? get decryptionIV {
    final encryptionDetails = m3u8segment.encryptionDetails!;
    if (encryptionDetails.encryptionMethod == M3U8EncryptionMethod.AES_128) {
      return encryptionDetails.iv == null
          ? deriveImplicitIV(m3u8segment.sequenceNumber)
          : deriveExplicitIV(m3u8segment.encryptionDetails!.iv!);
    }
    return null;
  }

  /// Refresh segment is not supported for m3u8 download connections
  @override
  void refreshSegment(Segment segment, {bool reuseConnection = false}) {
    logger?.warn(
      "Invalid Operation! Refresh segment requested on an m3u8 download connection",
    );
  }

  int get _nowMillis => DateTime.now().millisecondsSinceEpoch;
}
