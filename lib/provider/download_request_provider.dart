import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:brisk/db/hive_util.dart';
import 'package:brisk/model/download_item.dart';
import 'package:brisk/provider/pluto_grid_check_row_provider.dart';
import 'package:brisk/provider/pluto_grid_util.dart';
import 'package:brisk/util/notification_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:path/path.dart';
import 'package:brisk_engine/brisk_engine.dart';

import '../constants/download_command.dart';
import '../util/readability_util.dart';
import '../util/settings_cache.dart';

class DownloadRequestProvider with ChangeNotifier {
  Map<int, DownloadProgressMessage> downloads = {};

  PlutoGridCheckRowProvider plutoProvider;

  DownloadRequestProvider(this.plutoProvider);

  static int get _nowMillis => DateTime.now().millisecondsSinceEpoch;

  void addRequest(DownloadItem item) {
    final progress = DownloadProgressMessage(
      downloadItem: DownloadItemModel(
        fileName: item.fileName,
        downloadUrl: item.downloadUrl,
        startDate: item.startDate,
        progress: item.progress,
        id: item.key,
        uid: item.uid,
      ),
    );
    downloads.addAll({item.key!: progress});
    insertRows([
      DownloadProgressMessage(
          downloadItem: DownloadItemModel(
        id: item.key,
        uid: item.uid,
        fileName: item.fileName,
        downloadUrl: item.downloadUrl,
        progress: item.progress,
      )),
    ]);
    PlutoGridUtil.plutoStateManager?.notifyListeners();
    notifyListeners();
  }

  /// now in milliseconds in order to update every n seconds.
  /// Temp variable used to compare the last time the download item was updated to
  // TODO remove: Implement a custom update Queue
  int _previousUpdateTime = _nowMillis;

  void executeDownloadCommand(int id, DownloadCommand command) async {
    DownloadProgressMessage? downloadProgress = downloads[id];
    downloadProgress ??= await _addDownloadProgress(id);
    final downloadItem = downloadProgress.downloadItem;
    final totalConnections = downloadProgress.downloadItem.supportsPause
        ? SettingsCache.connectionsNumber
        : 1;
    final settings = DownloadSettings(
      baseSaveDir: SettingsCache.saveDir,
      totalConnections: SettingsCache.connectionsNumber,
      loggerEnabled: SettingsCache.loggerEnabled,
      baseTempDir: SettingsCache.temporaryDir,
      connectionRetryTimeout: SettingsCache.connectionRetryTimeout * 1000,
      maxConnectionRetryCount: SettingsCache.connectionRetryCount,
    );
    settings.totalConnections = totalConnections;
    if (command == DownloadCommand.start) {
      DownloadEngine.start(
        downloadItem,
        settings,
        onButtonAvailability: _handleButtonAvailabilityMessage,
        onDownloadProgress: _handleDownloadProgressMessage,
      );
    } else {
      DownloadEngine.pause(downloadItem.uid);
    }
  }

  bool checkDownloadCompletion(DownloadItemModel downloadItem) {
    final file = File(downloadItem.filePath);
    return downloadItem.status == DownloadStatus.assembleComplete ||
        (file.existsSync() && file.lengthSync() == downloadItem.contentLength);
  }

  int? getExistingConnectionCount(DownloadItemModel downloadItem) {
    final tempPath = join(SettingsCache.temporaryDir.path, downloadItem.uid);
    final tempDir = Directory(tempPath);
    return tempDir.existsSync() ? tempDir.listSync().length : null;
  }

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
    downloads[progress.downloadItem.id!] = progress;
    _handleNotification(progress);
    final downloadItem = progress.downloadItem;
    notifyAllListeners(progress);
    final dl = HiveUtil.instance.downloadItemsBox.get(downloadItem.id);
    if (dl == null) return;
    if (progress.assembleProgress == 1) {
      HiveUtil.instance.removeDownloadFromQueues(dl.key);
      PlutoGridUtil.removeCachedRow(progress.downloadItem.id!);
    }
    _updateDownloadRequest(progress, dl);
    if (progress.status == DownloadStatus.failed) {
      // _killIsolateConnection(uid);
    }
  }

  void _handleNotification(DownloadProgressMessage progress) {
    if (progress.assembleProgress == 1 &&
        SettingsCache.notificationOnDownloadCompletion) {
      NotificationUtil.showNotification(
        NotificationUtil.downloadCompletionHeader,
        progress.downloadItem.fileName,
      );
    }
    if (progress.status == DownloadStatus.failed &&
        SettingsCache.notificationOnDownloadFailure) {
      NotificationUtil.showNotification(
        NotificationUtil.downloadFailureHeader,
        progress.downloadItem.fileName,
      );
    }
  }

  Future<DownloadProgressMessage> _addDownloadProgress(int id) async {
    final downloadItem = await HiveUtil.instance.downloadItemsBox.get(id)!;
    downloads.addAll({
      downloadItem.key: DownloadProgressMessage(
        downloadItem:
            DownloadItemModel(fileName: '', downloadUrl: '', progress: 0)
                .fromDownloadItem(downloadItem),
      )
    });
    return DownloadProgressMessage(
        downloadItem:
            DownloadItemModel(fileName: '', downloadUrl: '', progress: 0)
                .fromDownloadItem(downloadItem));
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
      HiveUtil.instance.downloadItemsBox.put(item.key, item);
      _previousUpdateTime = _nowMillis;
    }
  }

  bool isUpdateEligible(String status) {
    return _previousUpdateTime + 6000 < _nowMillis ||
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
            value: convertByteToReadableStr(e.downloadItem.contentLength),
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
    if (DownloadEngine.engineChannels[progress.downloadItem.uid] == null)
      return;
    plutoProvider.notifyListeners();
    notifyListeners();
    PlutoGridUtil.updateRowCells(progress);
  }

  Future<void> fetchRows(List<DownloadItem> items) async {
    PlutoGridUtil.cachedRows.clear();
    final requests = items
        .map(
          (e) => DownloadProgressMessage(
              downloadItem:
                  DownloadItemModel(fileName: '', downloadUrl: '', progress: 0)
                      .fromDownloadItem(e),
              downloadProgress: e.progress),
        )
        .toList();
    final stateManager = PlutoGridUtil.plutoStateManager;
    stateManager?.removeAllRows();
    stateManager?.insertRows(0, buildRows(requests));
    stateManager?.setShowLoading(false);
    stateManager?.notifyListeners();
  }
}

extension Factory on DownloadItemModel {
  DownloadItemModel fromDownloadItem(DownloadItem e) {
    return DownloadItemModel(
      id: e.key,
      uid: e.uid,
      downloadUrl: e.downloadUrl,
      fileName: e.fileName,
      supportsPause: e.supportsPause,
      progress: e.progress,
      contentLength: e.contentLength,
      filePath: e.filePath,
      fileType: e.fileType,
      finishDate: e.finishDate,
      startDate: e.startDate,
      status: e.status,
    );
  }
}
