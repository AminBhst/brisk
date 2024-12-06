import 'package:brisk/constants/types.dart';
import 'package:brisk/download_engine/connection/base_http_download_connection.dart';
import 'package:http/http.dart' as http;

import '../download_status.dart';

class HttpDownloadConnection extends BaseHttpDownloadConnection {
  HttpDownloadConnection({
    required super.downloadItem,
    required super.segment,
    required super.connectionNumber,
    required super.settings,
  });

  @override
  http.Client buildClient() {
    return http.Client();
  }

  @override
  void pause(DownloadProgressCallback? progressCallback) {
    if (isWritingTempFile) {
      logger?.info("Tried to pause while writing temp files!");
    }
    paused = true;
    logger?.info("Paused connection $connectionNumber");
    cancelLogFlushTimer();
    if (progressCallback != null) {
      this.progressCallback = progressCallback;
    }
    flushBuffer();
    updateStatus(DownloadStatus.paused);
    connectionStatus = DownloadStatus.paused;
    client.close();
    pauseButtonEnabled = false;
    notifyProgress();
  }
}
