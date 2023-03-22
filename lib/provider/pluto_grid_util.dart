import 'package:brisk/constants/download_status.dart';
import 'package:brisk/model/download_progress.dart';
import 'package:brisk/util/readability_util.dart';
import 'package:pluto_grid/pluto_grid.dart';

class PlutoGridUtil {
  static PlutoGridStateManager? _stateManager;

  static final List<PlutoRow> cachedRows = [];

  static void updateRowCells(DownloadProgress progress) {
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
    _stateManager?.setFilter((row) {
      final cellValue = row.cells[cellName]?.value;
      return negate ? cellValue != filterValue : cellValue == filterValue;
    });
    _stateManager?.notifyListeners();
  }

  static void removeFilters() {
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

  static void doOperationOnCheckedRows(Function(int id, PlutoRow row) operation) {
    final selectedRows = _stateManager?.checkedRows;
    if (selectedRows == null) return;
    for (var row in selectedRows) {
      final id = row.cells["id"]!.value;
      operation(id, row);
    }
  }

  static PlutoGridStateManager? get plutoStateManager => _stateManager;
}
