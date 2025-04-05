import 'dart:async';

import 'package:brisk/download_engine/download_status.dart';
import 'package:brisk/provider/download_request_provider.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:brisk/download_engine/download_command.dart';

class QueueTimer {
  static Timer? timer;
  static int simultaneousDownloads = 1;
  static List<int> runningRequests = [];
  static List<int> stoppedRequests = [];
  static List<PlutoRow> queueRows = [];

  static void runQueueTimer(int i, DownloadRequestProvider provider) {
    if (timer != null) return;
    simultaneousDownloads = i;
    stoppedRequests = [];
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      List<int> toRemove = [];
      runningRequests.forEach((request) {
        final download = provider.downloads[request];
        if (download != null &&
            (download.status == DownloadStatus.assembleComplete ||
                download.status == DownloadStatus.assembleFailed)) {
          toRemove.add(request);
        }
      });
      toRemove.forEach((id) => runningRequests.remove(id));
      final requestsToStart = simultaneousDownloads - runningRequests.length;
      for (int i = 0; i < requestsToStart; i++) {
        final row = fetchNextQueueRow();
        final id = row.cells['id']!.value;
        provider.executeDownloadCommand(id, DownloadCommand.start);
        runningRequests.add(id);
      }
    });
  }

  static PlutoRow fetchNextQueueRow() {
    return queueRows
        .where((row) =>
            row.cells['status']!.value != DownloadStatus.assembleComplete &&
            !runningRequests.contains(row.cells['id']!.value) &&
            !stoppedRequests.contains(row.cells['id']!.value))
        .toList()
        .first;
  }
}
