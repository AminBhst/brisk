import 'package:pluto_grid/pluto_grid.dart';

/// Event called when the value of the TextField
/// that handles the filter under the column changes.
class PlutoGridChangeColumnFilterEvent extends PlutoGridEvent {
  final PlutoColumn column;
  final PlutoFilterType filterType;
  final String filterValue;
  final int? debounceMilliseconds;

  PlutoGridChangeColumnFilterEvent({
    required this.column,
    required this.filterType,
    required this.filterValue,
    this.debounceMilliseconds,
  }) : super(
          type: PlutoGridEventType.debounce,
          duration: Duration(
            milliseconds: debounceMilliseconds == null
                ? PlutoGridSettings.debounceMillisecondsForColumnFilter
                : debounceMilliseconds < 0
                    ? 0
                    : debounceMilliseconds,
          ),
        );

  List<PlutoRow> _getFilterRows(PlutoGridStateManager? stateManager) {
    List<PlutoRow> foundFilterRows =
        stateManager!.filterRowsByField(column.field);

    if (foundFilterRows.isEmpty) {
      return [
        ...stateManager.filterRows,
        FilterHelper.createFilterRow(
          columnField: column.field,
          filterType: filterType,
          filterValue: filterValue,
        ),
      ];
    }

    foundFilterRows.first.cells[FilterHelper.filterFieldValue]!.value =
        filterValue;

    return stateManager.filterRows;
  }

  @override
  void handler(PlutoGridStateManager stateManager) {
    stateManager.setFilterWithFilterRows(_getFilterRows(stateManager));
  }
}
