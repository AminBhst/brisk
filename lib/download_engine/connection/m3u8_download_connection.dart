import 'dart:io';

import 'package:brisk/constants/http_constants.dart';
import 'package:brisk/constants/types.dart';
import 'package:brisk/download_engine/connection/base_http_download_connection.dart';
import 'package:brisk/download_engine/download_status.dart';
import 'package:brisk/download_engine/model/m3u8.dart';
import 'package:brisk/download_engine/segment/segment.dart';
import 'package:brisk/download_engine/util/m3u8_util.dart';
import 'package:brisk/download_engine/util/temp_file_util.dart';
import 'package:encrypt/encrypt.dart';
import 'package:http/src/client.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;

class M3U8DownloadConnection extends BaseHttpDownloadConnection {
  String? encryptionKey;

  M3U8Segment m3u8segment;

  /// TODO try with lower value as well
  static const int _maximumFileSizeForInMemoryDecryption = 50000000;

  M3U8DownloadConnection({
    required super.downloadItem,
    required super.segment,
    required super.connectionNumber,
    required super.settings,
    required this.m3u8segment,
    required this.encryptionKey,
  });

  @override
  void doStart(
    DownloadProgressCallback progressCallback, {
    bool connectionReset = false,
    bool reuseConnection = false,
  }) {
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
      "Final_Segment_Complete.ts",
    );
    return File(finalSegmentPath).existsSync();
  }

  @override
  void init(connectionReset, progressCallback, reuseConnection) {
    super.init(connectionReset, progressCallback, reuseConnection);
    previousBufferEndByte = 0;
  }

  @override
  http.Request buildDownloadRequest(bool _) {
    return http.Request('GET', Uri.parse(m3u8segment.url))
      ..headers.addAll(userAgentHeader);
  }

  @override
  void doProcessChunk(List<int> chunk) {
    if (chunk.isEmpty) return;
    updateStatus(DownloadStatus.downloading);
    lastResponseTimeMillis = _nowMillis;
    pauseButtonEnabled = downloadItem.supportsPause;
    connectionStatus = transferRate;
    calculateTransferRate(chunk);
    calculateDynamicFlushThreshold();
    buffer.add(chunk);
    // updateReceivedBytes(chunk);
    updateDownloadProgress();
    if (tempReceivedBytes > dynamicFlushThreshold) {
      flushBuffer();
    }
    notifyProgress();
  }

  @override
  void onDownloadComplete() {
    if (paused || reset) return;
    bytesTransferRate = 0;

    /// TODO progress
    flushBuffer();
    connectionStatus = DownloadStatus.connectionComplete;
    logger?.info("Download complete with completion signal");
    assembleM3U8Segment();
  }

  /// Merges all temporary files of an m3u8 segment into one file and decrypts it if required.
  /// The successful completion of this method's execution marks the segment as fully downloaded.
  /// It does so by renaming the file at the end of the operation which can be used by the engine
  /// to mark this segment as fully downloaded in order to ignore it for a resume operation.
  void assembleM3U8Segment() {
    final tempFiles = tempDirectory.listSync().map((e) => e as File).toList()
      ..sort(sortByByteRanges);
    final segmentFile = File(join(tempDirectory.path, "Final_Segment.ts"));
    for (final file in tempFiles) {
      final bytes = file.readAsBytesSync();
      segmentFile.writeAsBytesSync(bytes, mode: FileMode.writeOnlyAppend);
    }
    if (m3u8segment.encryptionMethod == M3U8EncryptionMethod.AES_128) {
      if (segmentFile.lengthSync() > _maximumFileSizeForInMemoryDecryption) {
        decryptAes128File(
          segmentFile,
          encryptionKey!,
          decryptionIV!,
          chunked: true,
        );
      } else {
        decryptAes128File(segmentFile, encryptionKey!, decryptionIV!);
      }
    }
    final newPath = join(tempDirectory.path, "Final_Segment_Complete.ts");
    segmentFile.renameSync(newPath);
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
    return http.Client();
  }

  @override
  void pause(DownloadProgressCallback? progressCallback) {
    super.pause(progressCallback);
    // TODO: implement pause
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
