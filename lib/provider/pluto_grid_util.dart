import 'dart:async';

import 'package:brisk/constants/file_type.dart';
import 'package:brisk/download_engine/download_status.dart';
import 'package:brisk/download_engine/message/download_progress_message.dart';
import 'package:brisk/download_engine/model/download_item_model.dart';
import 'package:brisk/util/file_util.dart';
import 'package:brisk/util/readability_util.dart';
import 'package:brisk/widget/download/queue_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pluto_grid/pluto_grid.dart';

class PlutoGridUtil {
  static PlutoGridStateManager? _stateManager;
  static PlutoGridStateManager? _multiDownloadAdditionStateManager;

  static Timer? cacheClearTimer;
  static final List<PlutoRow> cachedRows = [];

  static bool Function(PlutoRow)? filter = null;

  static void updateRowCells(DownloadProgressMessage progress) {
    final id = progress.downloadItem.id;
    final row = findCachedRow(id) ?? findRowById(id);
    if (row == null) return;
    final cells = row.cells;
    final downloadItem = progress.downloadItem;
    if (progress.status == DownloadStatus.canceled) {
      downloadItem.status = DownloadStatus.canceled;
    }
    updateCells(cells, progress, downloadItem);
    for (PlutoRow row in QueueTimer.queueRows) {
      if (id == row.cells['id']!.value) {
        updateCells(row.cells, progress, downloadItem);
      }
    }
    _stateManager?.notifyListeners();
    _runPeriodicCachedRowClear();
  }

  static void updateCells(
    Map<String, PlutoCell> cells,
    DownloadProgressMessage progress,
    DownloadItemModel downloadItem,
  ) {
    cells["time_left"]?.value = progress.estimatedRemaining;
    cells["progress"]?.value =
        convertPercentageNumberToReadableStr(progress.downloadProgress * 100);
    cells["transfer_rate"]?.value = progress.transferRate;
    cells["status"]?.value = downloadItem.status;
    cells["finish_date"]?.value = downloadItem.finishDate ?? "";
    if (progress.assembledFileSize != null) {
      cells["size"]?.value =
          convertByteToReadableStr(progress.assembledFileSize!);
    }
  }

  static void _runPeriodicCachedRowClear() {
    if (cacheClearTimer != null) return;
    cacheClearTimer = Timer.periodic(
      const Duration(seconds: 3),
      (timer) => cachedRows.clear(),
    );
  }

  static Row fileNameColumnRenderer(
      PlutoColumnRendererContext rendererContext) {
    final fileName = rendererContext.row.cells["file_name"]!.value;
    final fileType = FileUtil.detectFileType(fileName);
    return Row(
      children: [
        SizedBox(
          width: resolveIconSize(fileType),
          height: resolveIconSize(fileType),
          child: SvgPicture.asset(
            FileUtil.resolveFileTypeIconPath(fileType.name),
            colorFilter: ColorFilter.mode(
              FileUtil.resolveFileTypeIconColor(fileType.name),
              BlendMode.srcIn,
            ),
          ),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            rendererContext.row.cells[rendererContext.column.field]!.value
                .toString(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  static double resolveIconSize(DLFileType fileType) {
    if (fileType == DLFileType.documents || fileType == DLFileType.program)
      return 25;
    else if (fileType == DLFileType.music)
      return 28;
    else
      return 30;
  }

  static void removeCachedRow(int id) {
    cachedRows.removeWhere((row) => row.cells["id"]?.value == id);
  }

  static PlutoRow? findCachedRow(int id) {
    final results = cachedRows.where((row) => row.cells["id"]?.value == id);
    if (results.length != 1) return null;
    return results.first;
  }

  static PlutoRow? findRowById(int id) {
    final results =
        _stateManager?.rows.where((row) => row.cells["id"]?.value == id);
    if (results == null || results.length != 1) return null;
    cachedRows.add(results.first);
    return results.first;
  }

  static void setStateManager(PlutoGridStateManager plutoStateManager) {
    _stateManager = plutoStateManager;
  }

  static void setMultiAdditionStateManager(
    PlutoGridStateManager plutoStateManager,
  ) {
    _multiDownloadAdditionStateManager = plutoStateManager;
  }

  static void setFilter(String cellName, String filterValue,
      {bool negate = false}) {
    filter = (row) {
      final cellValue = row.cells[cellName]?.value;
      return negate ? cellValue != filterValue : cellValue == filterValue;
    };
    _stateManager?.setFilter(filter);
    _stateManager?.notifyListeners();
  }

  static void removeFilters() {
    filter = null;
    _stateManager?.setFilter(null);
    _stateManager?.notifyListeners();
  }

  static int getFilteredRowCount(String cell, String value,
      {bool negate = false}) {
    return _stateManager?.rows.where((row) {
          final cellValue = row.cells[cell]?.value;
          return negate ? cellValue != value : cellValue == value;
        }).length ??
        0;
  }

  static bool get selectedRowExists => !selectedRowIds.isEmpty;

  static List<int> get selectedRowIds => _stateManager?.checkedRows == null
      ? []
      : _stateManager!.checkedRows
          .map((row) => int.parse(row.cells["id"]!.value.toString()))
          .toList();

  static void doOperationOnCheckedRows(
      Function(int id, PlutoRow row) operation) {
    final selectedRows = _stateManager?.checkedRows;
    if (selectedRows == null) return;
    for (var row in selectedRows) {
      final id = row.cells["id"]!.value;
      _stateManager?.setRowChecked(row, false);
      operation(id, row);
    }
    _stateManager?.notifyListeners();
  }

  static PlutoGridStateManager? get plutoStateManager => _stateManager;

  static PlutoGridStateManager? get multiDownloadAdditionStateManager =>
      _multiDownloadAdditionStateManager;
}
