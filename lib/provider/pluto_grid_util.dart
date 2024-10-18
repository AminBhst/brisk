import 'dart:async';

import 'package:brisk/download_engine/download_status.dart';
import 'package:brisk/download_engine/message/download_progress_message.dart';
import 'package:brisk/util/readability_util.dart';
import 'package:pluto_grid/pluto_grid.dart';

class PlutoGridUtil {
  static PlutoGridStateManager? _stateManager;

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
    cells["time_left"]?.value = progress.estimatedRemaining;
    cells["progress"]?.value =
        convertPercentageNumberToReadableStr(progress.downloadProgress * 100);
    cells["transfer_rate"]?.value = progress.transferRate;
    cells["status"]?.value = downloadItem.status;
    cells["finish_date"]?.value = downloadItem.finishDate ?? "";
    _stateManager?.notifyListeners();
    _runPeriodicCachedRowClear();
  }

  static void _runPeriodicCachedRowClear() {
    if (cacheClearTimer != null) return;
    cacheClearTimer = Timer.periodic(
      const Duration(seconds: 3),
      (timer) => cachedRows.clear(),
    );
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
}
