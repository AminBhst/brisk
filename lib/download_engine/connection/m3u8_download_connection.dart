import 'dart:io';

import 'package:brisk/constants/http_constants.dart';
import 'package:brisk/constants/types.dart';
import 'package:brisk/download_engine/connection/base_http_download_connection.dart';
import 'package:brisk/download_engine/download_status.dart';
import 'package:brisk/download_engine/model/m3u8.dart';
import 'package:brisk/download_engine/util/m3u8_util.dart';
import 'package:encrypt/encrypt.dart';
import 'package:http/src/client.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;

class M3U8DownloadConnection extends BaseHttpDownloadConnection {
  String? encryptionKey;

  M3U8Segment m3u8segment;

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
    init(connectionReset, progressCallback, reuseConnection);
    if (connectionReset) {
      resetStatus();
    }
    notifyProgress();
    final request = buildDownloadRequest(false);
    sendDownloadRequest(request);
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

  int get _nowMillis => DateTime.now().millisecondsSinceEpoch;
}
