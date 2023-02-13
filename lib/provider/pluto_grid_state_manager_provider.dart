import 'package:brisk/constants/download_status.dart';
import 'package:brisk/model/download_progress.dart';
import 'package:brisk/util/readability_util.dart';
import 'package:pluto_grid/pluto_grid.dart';

class PlutoGridStateManagerProvider {
  static PlutoGridStateManager? _stateManager;

  static void updateRowCells(DownloadProgress progress) {
    final row = findPlutoRowById(progress.downloadItem.id);
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

  static PlutoRow? findPlutoRowById(int id) {
    final results =
        _stateManager?.rows.where((row) => row.cells["id"]?.value == id);
    if (results == null || results.length != 1) return null;
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

  static PlutoGridStateManager? get plutoStateManager => _stateManager;
}
