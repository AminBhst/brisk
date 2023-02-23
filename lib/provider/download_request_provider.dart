import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:brisk/constants/download_command.dart';
import 'package:brisk/constants/download_status.dart';
import 'package:brisk/dao/download_item_dao.dart';
import 'package:brisk/downloader/multi_connection_isolation_handler.dart';
import 'package:brisk/model/download_progress.dart';
import 'package:brisk/model/download_item.dart';
import 'package:brisk/model/isolate/download_isolator_args.dart';
import 'package:brisk/provider/pluto_grid_state_manager_provider.dart';
import 'package:brisk/util/notification_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:stream_channel/isolate_channel.dart';
import 'package:stream_channel/stream_channel.dart';
import 'package:path/path.dart';

import '../util/readability_util.dart';
import '../util/settings_cache.dart';

class DownloadRequestProvider with ChangeNotifier {
  Map<int, DownloadProgress> downloads = {};
  Map<int, StreamChannel?> handlerChannels = {};
  Map<int, Isolate?> handlerIsolates = {};

  static int get _nowMillis => DateTime.now().millisecondsSinceEpoch;

  void addRequest(DownloadItem item) {
    final progress = DownloadProgress(downloadItem: item);
    downloads.addAll({item.id: progress});
    insertRows([DownloadProgress(downloadItem: item)]);
    PlutoGridStateManagerProvider.plutoStateManager?.notifyListeners();
    notifyListeners();
  }

  /// Temp variable used to compare the last time the download item was updated to
  /// now in milliseconds in order to update every n seconds.
  int _previousUpdateTime = _nowMillis;

  void executeDownloadCommand(int id, DownloadCommand command) async {
    DownloadProgress? downloadProgress = downloads[id];
    downloadProgress ??= await _addDownloadProgress(id);
    final downloadItem = downloadProgress.downloadItem;
    StreamChannel? channel = handlerChannels[id];
    final totalConnections = downloadProgress.downloadItem.supportsPause
        ? SettingsCache.connectionsNumber
        : 1;

    final connectionCount = getExistingConnectionCount(downloadItem) ?? totalConnections;
    final isolatorArgs = SegmentedDownloadIsolateArgs(
      command: command,
      downloadItem: downloadProgress.downloadItem,
      baseTempDir: SettingsCache.temporaryDir,
      baseSaveDir: SettingsCache.saveDir,
      totalConnections: connectionCount,
      connectionRetryTimeout: SettingsCache.connectionRetryTimeout * 1000,
      maxConnectionRetryCount: SettingsCache.connectionRetryCount,
    );
    if (channel == null) {
      channel = await _spawnHandlerIsolate(id);
      if (command == DownloadCommand.cancel) return;
      channel.stream.listen((progress) => _listenToHandlerChannel(progress, id));
    }
    channel.sink.add(isolatorArgs);
  }

  int? getExistingConnectionCount(DownloadItem downloadItem) {
    final tempPath = join(SettingsCache.temporaryDir.path, downloadItem.uid);
    final tempDir = Directory(tempPath);
    return tempDir.existsSync() ? tempDir.listSync().length : null;
  }

  Future<StreamChannel> _spawnHandlerIsolate(int id) async {
    final rPort = ReceivePort();
    final channel = IsolateChannel.connectReceive(rPort);
    final isolate = await Isolate.spawn(
      MultiConnectionIsolationHandler.handleMultiConnectionRequest,
      rPort.sendPort,
    );
    handlerIsolates[id] = isolate;
    handlerChannels[id] = channel;
    return channel;
  }


  void _listenToHandlerChannel(dynamic progress, int id) {
    if (progress is DownloadProgress) {
      downloads[id] = progress;
      _handleNotification(progress);
      final downloadItem = progress.downloadItem;
      notifyAllListeners(progress);
      _updateDownloadRequest(progress, downloadItem);
      if (progress.status == DownloadStatus.failed) {
        _killIsolateConnection(id);
      }
    }
  }

  void _handleNotification(DownloadProgress progress) {
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

  Future<DownloadProgress> _addDownloadProgress(int id) async {
    final downloadRequest = await DownloadItemDao.instance.getById(id);
    downloads.addAll({id: DownloadProgress(downloadItem: downloadRequest)});
    return DownloadProgress(downloadItem: downloadRequest);
  }

  void _killIsolateConnection(int id) {
    handlerChannels[id] = null;
    handlerIsolates[id]?.kill();
    handlerIsolates[id] = null;
  }

  /// Updates the download request based on the incoming progress from handler isolate every 6 seconds
  void _updateDownloadRequest(DownloadProgress progress, DownloadItem item) {
    final status = progress.status;
    if (_previousUpdateTime + 6000 < _nowMillis ||
        status == DownloadStatus.assembleComplete ||
        status == DownloadStatus.paused) {
      item.progress = progress.downloadProgress;
      item.status = status;
      if (status == DownloadStatus.assembleComplete) {
        item.finishDate = DateTime.now();
      }
      DownloadItemDao.instance.update(item);
      _previousUpdateTime = _nowMillis;
    }
  }

  void insertRows(List<DownloadProgress> progressData) {
    final stateManager = PlutoGridStateManagerProvider.plutoStateManager;
    final rows = stateManager?.rows;
    final lastIndex = rows!.isNotEmpty ? rows.last.sortIdx : -1;
    stateManager?.insertRows(lastIndex + 1, buildRows(progressData));
  }

  List<PlutoRow> buildRows(List<DownloadProgress> progressData) {
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
          "file_type": PlutoCell(value: e.downloadItem.fileType.name),
          "id": PlutoCell(value: e.downloadItem.id),
        },
      );
    }).toList();
  }

  void notifyAllListeners(DownloadProgress progress) {
    if (handlerChannels[progress.downloadItem.id] == null) return;
    notifyListeners();
    PlutoGridStateManagerProvider.updateRowCells(progress);
  }

  Future<void> fetchRows() async {
    final requests = (await DownloadItemDao.instance.getAll())
        .map((e) =>
            DownloadProgress(downloadItem: e, downloadProgress: e.progress))
        .toList();
    final stateManager = PlutoGridStateManagerProvider.plutoStateManager;
    stateManager?.removeAllRows();
    stateManager?.insertRows(0, buildRows(requests));
    stateManager?.setShowLoading(false);
    stateManager?.notifyListeners();
  }
}
