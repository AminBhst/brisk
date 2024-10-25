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
import 'package:stream_channel/isolate_channel.dart';
import 'package:stream_channel/stream_channel.dart';
import 'package:path/path.dart';
import 'package:brisk_engine/brisk_engine.dart';

import '../util/readability_util.dart';
import '../util/settings_cache.dart';

class DownloadRequestProvider with ChangeNotifier {
  Map<String, DownloadProgressMessage> downloads = {};
  Map<String, StreamChannel?> engineChannels = {};
  Map<String, Isolate?> engineIsolates = {};

  PlutoGridCheckRowProvider plutoProvider;

  DownloadRequestProvider(this.plutoProvider);

  static int get _nowMillis =>
      DateTime
          .now()
          .millisecondsSinceEpoch;

  void addRequest(DownloadItem item) {
    final progress = DownloadProgressMessage(
      downloadItem: DownloadItemModel(
        fileName: item.fileName,
        downloadUrl: item.downloadUrl,
        startDate: item.startDate,
        progress: item.progress,
        id: item.key,
      ),
    );
    downloads.addAll({item.key!: progress});
    insertRows([
      DownloadProgressMessage(
          downloadItem: DownloadItemModel(
            id: item.key,
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
    if (checkDownloadCompletion(downloadItem)) return;
    StreamChannel? channel = engineChannels[id];
    if (channel == null && command == DownloadCommand.clearConnections) {
      return;
    }
    final totalConnections = downloadProgress.downloadItem.supportsPause
        ? SettingsCache.connectionsNumber
        : 1;

    final data = DownloadIsolateMessage(
      command: command,
      downloadItem: downloadProgress.downloadItem,
      settings: DownloadSettings(
        baseSaveDir: SettingsCache.saveDir,
        totalConnections: SettingsCache.connectionsNumber,
        loggerEnabled: SettingsCache.loggerEnabled,
        baseTempDir: SettingsCache.temporaryDir,
        connectionRetryTimeout: SettingsCache.connectionRetryTimeout,
        maxConnectionRetryCount: SettingsCache.connectionRetryCount,
      ),
    );
    data.settings.totalConnections = totalConnections;
    if (channel == null) {
      channel = await _spawnDownloadEngineIsolate(downloadItem);
      if (command == DownloadCommand.cancel) return;
      channel.stream.listen(_handleDownloadEngineMessage);
    }
    channel.sink.add(data);
  }

  bool checkDownloadCompletion(DownloadItemModel downloadItem) {
    final file = File(downloadItem.filePath);
    return downloadItem.status == DownloadStatus.assembleComplete ||
        (file.existsSync() && file.lengthSync() == downloadItem.contentLength);
  }

  int? getExistingConnectionCount(DownloadItemModel downloadItem) {
    final tempPath = join(SettingsCache.temporaryDir.path, downloadItem.uid);
    final tempDir = Directory(tempPath);
    return tempDir.existsSync() ? tempDir
        .listSync()
        .length : null;
  }

  Future<StreamChannel> _spawnDownloadEngineIsolate(
      DownloadItemModel downloadItem) async {
    final rPort = ReceivePort();
    final channel = IsolateChannel.connectReceive(rPort);
    final isolate = await Isolate.spawn(
      HttpDownloadEngine.start,
      IsolateArgsPair(rPort.sendPort, downloadItem.uid),
      errorsAreFatal: false,
    );
    engineIsolates[downloadItem.uid] = isolate;
    engineChannels[downloadItem.uid] = channel;
    return
    channel;
  }

  void _handleDownloadEngineMessage(message) {
    if (message is DownloadProgressMessage) {
      _handleDownloadProgressMessage(message);
    }
    if (message is ButtonAvailabilityMessage) {
      _handleButtonAvailabilityMessage(message);
    }
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
    final uid = progress.downloadItem.uid;
    downloads[uid] = progress;
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
    final downloadItem = HiveUtil.instance.downloadItemsBox.get(id)!;
    downloads.addAll({
      downloadItem.uid: DownloadProgressMessage(
          downloadItem: DownloadItemModel.fromDownloadItem(downloadItem))
    });
    return DownloadProgressMessage(
        downloadItem: DownloadItemModel.fromDownloadItem(downloadItem));
  }

  void _killIsolateConnection(int id) {
    engineChannels[id] = null;
    engineIsolates[id]?.kill();
    engineIsolates[id] = null;
  }

  /// Updates the download request based on the incoming progress from handler isolate every 6 seconds
  void _updateDownloadRequest(DownloadProgressMessage progress,
      DownloadItem item) {
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
    if (engineChannels[progress.downloadItem.id] == null) return;
    plutoProvider.notifyListeners();
    notifyListeners();
    PlutoGridUtil.updateRowCells(progress);
  }

  Future<void> fetchRows(List<DownloadItem> items) async {
    PlutoGridUtil.cachedRows.clear();
    final requests = items
        .map((e) =>
        DownloadProgressMessage(
            downloadItem: DownloadItemModel.fromDownloadItem(e),
            downloadProgress: e.progress))
        .toList();
    final stateManager = PlutoGridUtil.plutoStateManager;
    stateManager?.removeAllRows();
    stateManager?.insertRows(0, buildRows(requests));
    stateManager?.setShowLoading(false);
    stateManager?.notifyListeners();
  }
}
