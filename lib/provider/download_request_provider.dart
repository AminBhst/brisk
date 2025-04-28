import 'dart:async';
import 'dart:io';

import 'package:brisk/db/hive_util.dart';
import 'package:brisk/model/download_item.dart';
import 'package:brisk/provider/pluto_grid_check_row_provider.dart';
import 'package:brisk/provider/pluto_grid_util.dart';
import 'package:brisk/util/notification_manager.dart';
import 'package:brisk_download_engine/brisk_download_engine.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:pluto_grid/pluto_grid.dart';
import '../util/download_engine_util.dart';
import 'package:stream_channel/stream_channel.dart';
import 'package:path/path.dart';

import '../util/readability_util.dart';
import '../util/settings_cache.dart';

class DownloadRequestProvider with ChangeNotifier {
  Map<int, DownloadProgressMessage> downloads = {};

  PlutoGridCheckRowProvider plutoProvider;

  DownloadRequestProvider(this.plutoProvider);

  static int get _nowMillis => DateTime.now().millisecondsSinceEpoch;

  void addRequest(DownloadItem item) {
    final progress = DownloadProgressMessage(
      downloadItem: buildFromDownloadItem(item),
    );
    downloads.addAll({item.key!: progress});
    insertRows([progress]);
    PlutoGridUtil.plutoStateManager?.notifyListeners();
    notifyListeners();
  }

  /// now in milliseconds in order to update every n seconds.
  /// Temp variable used to compare the last time the download item was updated to
  // TODO remove: Implement a custom update Queue
  int _previousUpdateTime = _nowMillis;

  Future<void> pauseDownload(int id) async {
    final uid = await HiveUtil.instance.getDownloadItemUid(id);
    DownloadEngine.pause(uid);
  }

  void startDownload(int id) async {
    DownloadProgressMessage? downloadProgress = downloads[id];
    downloadProgress ??= await _addDownloadProgress(id);
    final downloadItem = downloadProgress.downloadItem;
    StreamChannel? channel = DownloadEngine.engineChannels[id];
    final totalConnections = downloadProgress.downloadItem.supportsPause
        ? SettingsCache.connectionsNumber
        : 1;
    final settings = downloadSettingsFromCache()
      ..totalM3u8Connections = totalConnections;
    if (channel == null) {
      DownloadEngine.start(
        downloadItem,
        settings,
        downloadItem.downloadType,
        onButtonAvailability: _handleButtonAvailabilityMessage,
        onDownloadProgress: _handleDownloadProgressMessage,
      );
    }
  }

  int? getExistingConnectionCount(DownloadItemModel downloadItem) {
    final tempPath = join(SettingsCache.temporaryDir.path, downloadItem.uid);
    final tempDir = Directory(tempPath);
    return tempDir.existsSync() ? tempDir.listSync().length : null;
  }

  // Future<StreamChannel> _spawnDownloadEngineIsolate(
  //   int id,
  //   DownloadType downloadType,
  // ) async {
  //   final rPort = ReceivePort();
  //   final channel = IsolateChannel.connectReceive(rPort);
  //   final isolate = await Isolate.spawn(
  //     getEngineStartMethod(downloadType),
  //     IsolateSingleArg(rPort.sendPort, id),
  //     errorsAreFatal: false,
  //   );
  //   engineIsolates[id] = isolate;
  //   engineChannels[id] = channel;
  //   return channel;
  // }

  // getEngineStartMethod(DownloadType downloadType) {
  //   if (downloadType == DownloadType.M3U8) {
  //     return M3U8DownloadEngine.start;
  //   }
  //   return HttpDownloadEngine.start;
  // }

  // void _handleDownloadEngineMessage(message) {
  //   if (message is DownloadProgressMessage) {
  //     _handleDownloadProgressMessage(message);
  //   }
  //   if (message is ButtonAvailabilityMessage) {
  //     _handleButtonAvailabilityMessage(message);
  //   }
  //   // if (message is ConnectionsClearedMessage) {
  //   //   _handleConnectionsClearedMessage(message);
  //   // }
  // }

  // void _handleConnectionsClearedMessage(ConnectionsClearedMessage message) {
  //   final id = message.downloadItem.id;
  //   downloads[id]!.downloadItem.status = DownloadStatus.paused;
  //   downloads[id]!.status = DownloadStatus.paused;
  //   engineIsolates[id]?.kill(priority: 0);
  //   engineChannels.remove(id);
  //   downloads[id]!.buttonAvailability = ButtonAvailability(false, true);
  //   notifyAllListeners(downloads[id]!);
  // }

  void _handleButtonAvailabilityMessage(ButtonAvailabilityMessage message) {
    final download = downloads[message.downloadItem.id];
    download?.buttonAvailability = ButtonAvailability(
      message.pauseButtonEnabled,
      message.startButtonEnabled,
    );
    notifyListeners();
    plutoProvider.notifyListeners();
  }

  void _handleDownloadProgressMessage(DownloadProgressMessage progress) {
    final id = progress.downloadItem.id!;
    downloads[id] = progress;
    _handleNotification(progress);
    final downloadItem = progress.downloadItem;
    final dl = HiveUtil.instance.downloadItemsBox.get(downloadItem.id);
    if (dl == null) return;
    if (progress.status == DownloadStatus.assembling) {
      progress.totalDownloadProgress = 1;
    }
    if (progress.assembleProgress == 1) {
      HiveUtil.instance.removeDownloadFromQueues(dl.key);
      PlutoGridUtil.removeCachedRow(id);
    }
    _updateDownloadRequest(progress, dl);
    if (progress.status == DownloadStatus.failed) {
      _killIsolateConnection(id);
    }
    notifyAllListeners(progress);
  }

  void _handleNotification(DownloadProgressMessage progress) {
    if (progress.assembleProgress == 1 &&
        SettingsCache.notificationOnDownloadCompletion) {
      NotificationManager.showNotification(
        NotificationManager.downloadCompletionHeader,
        progress.downloadItem.fileName,
      );
    }
    if (progress.status == DownloadStatus.failed &&
        SettingsCache.notificationOnDownloadFailure) {
      NotificationManager.showNotification(
        NotificationManager.downloadFailureHeader,
        progress.downloadItem.fileName,
      );
    }
  }

  Future<DownloadProgressMessage> _addDownloadProgress(int id) async {
    final downloadItem = HiveUtil.instance.downloadItemsBox.get(id)!;
    downloads.addAll({
      id: DownloadProgressMessage(
        downloadItem: buildFromDownloadItem(downloadItem),
      )
    });
    // TODO handle download type properly
    return DownloadProgressMessage(
      downloadItem: buildFromDownloadItem(downloadItem),
    );
  }

  void _killIsolateConnection(int id) {
    // engineChannels[id] = null;
    // engineIsolates[id]?.kill();
    // engineIsolates[id] = null;
  }

  /// Updates the download request based on the incoming progress from handler isolate every 6 seconds
  void _updateDownloadRequest(
      DownloadProgressMessage progress, DownloadItem item) {
    final status = progress.status;
    if (isUpdateEligible(status)) {
      item.progress = progress.downloadProgress;
      item.status = status;
      if (status == DownloadStatus.assembleComplete) {
        item.finishDate = DateTime.now();
      }
      if (progress.assembledFileSize != null) {
        item.contentLength = progress.assembledFileSize!;
      }
      HiveUtil.instance.downloadItemsBox.put(item.key, item);
      _previousUpdateTime = _nowMillis;
    }
  }

  bool isUpdateEligible(String status) {
    return _previousUpdateTime + 2000 < _nowMillis ||
        status == DownloadStatus.assembleComplete ||
        status == DownloadStatus.paused;
  }

  void insertRows(List<DownloadProgressMessage> progressData) {
    final stateManager = PlutoGridUtil.plutoStateManager;
    final rows = stateManager?.rows;
    final lastIndex = rows!.isNotEmpty ? rows.last.sortIdx : -1;
    stateManager?.insertRows(lastIndex + 1, buildRows(progressData));
  }

  /// TODO this shouldn't be in the provider. Move to [PlutoGridUtil]
  List<PlutoRow> buildRows(List<DownloadProgressMessage> progressData) {
    return progressData.map((e) {
      if (downloads[e.downloadItem.id] != null) {
        e = downloads[e.downloadItem.id]!;
      }
      return PlutoRow(
        cells: {
          "file_name": PlutoCell(value: e.downloadItem.fileName),
          "size": PlutoCell(
            value: e.downloadItem.fileSize < 0
                ? "Unknown"
                : convertByteToReadableStr(e.downloadItem.fileSize),
          ),
          "progress": PlutoCell(
            value:
                convertPercentageNumberToReadableStr(e.downloadProgress * 100),
          ),
          "status": PlutoCell(
            value: e.status == ""
                ? (e.downloadItem.status == DownloadStatus.assembleComplete ||
                        e.downloadItem.status == DownloadStatus.paused)
                    ? e.downloadItem.status
                    : ""
                : e.status,
          ),
          "transfer_rate": PlutoCell(value: e.transferRate),
          "time_left": PlutoCell(value: e.estimatedRemaining),
          "start_date": PlutoCell(value: e.downloadItem.startDate),
          "finish_date": PlutoCell(value: e.downloadItem.finishDate ?? ""),
          "file_type": PlutoCell(value: e.downloadItem.fileType),
          "id": PlutoCell(value: e.downloadItem.id),
          "uid": PlutoCell(value: e.downloadItem.uid),
        },
      );
    }).toList();
  }

  // int _tmpTime = _nowMillis;
  void notifyAllListeners(DownloadProgressMessage progress) {
    // if (_tmpTime + 90 > _nowMillis) return;
    // _tmpTime = _nowMillis;
    plutoProvider.notifyListeners();
    notifyListeners();
    PlutoGridUtil.updateRowCells(progress);
  }

  Future<void> fetchRows(List<DownloadItem> items) async {
    PlutoGridUtil.cachedRows.clear();
    final requests = items
        .map((e) => DownloadProgressMessage(
              downloadItem: buildFromDownloadItem(e),
              downloadProgress: e.progress,
            ))
        .toList();
    final stateManager = PlutoGridUtil.plutoStateManager;
    stateManager?.removeAllRows();
    stateManager?.insertRows(0, buildRows(requests));
    stateManager?.setShowLoading(false);
    stateManager?.notifyListeners();
  }
}
