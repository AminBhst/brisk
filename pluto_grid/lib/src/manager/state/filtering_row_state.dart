import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

abstract class IFilteringRowState {
  List<PlutoRow> get filterRows;

  bool get hasFilter;

  void setFilter(FilteredListFilter<PlutoRow>? filter, {bool notify = true});

  void setFilterWithFilterRows(List<PlutoRow> rows, {bool notify = true});

  void setFilterRows(List<PlutoRow> rows);

  List<PlutoRow> filterRowsByField(String columnField);

  /// Check if the column is in a state with filtering applied.
  bool isFilteredColumn(PlutoColumn column);

  void removeColumnsInFilterRows(
    List<PlutoColumn> columns, {
    bool notify = true,
  });

  void showFilterPopup(
    BuildContext context, {
    PlutoColumn? calledColumn,
  });
}

class _State {
  List<PlutoRow> _filterRows = [];
}

mixin FilteringRowState implements IPlutoGridState {
  final _State _state = _State();

  @override
  List<PlutoRow> get filterRows => _state._filterRows;

  @override
  bool get hasFilter =>
      refRows.hasFilter || (filterOnlyEvent && filterRows.isNotEmpty);

  @override
  void setFilter(FilteredListFilter<PlutoRow>? filter, {bool notify = true}) {
    if (filter == null) {
      setFilterRows([]);
    }

    if (filterOnlyEvent) {
      eventManager!.addEvent(
        PlutoGridSetColumnFilterEvent(filterRows: filterRows),
      );
      return;
    }

    for (final row in iterateAllRowAndGroup) {
      row.setState(PlutoRowState.none);
    }

    var savedFilter = filter;

    if (filter != null) {
      savedFilter = (PlutoRow row) {
        return !row.state.isNone || filter(row);
      };
    }

    if (enabledRowGroups) {
      setRowGroupFilter(savedFilter);
    } else {
      refRows.setFilter(savedFilter);
    }

    resetCurrentState(notify: false);

    notifyListeners(notify, setFilter.hashCode);
  }

  @override
  void setFilterWithFilterRows(List<PlutoRow> rows, {bool notify = true}) {
    setFilterRows(rows);

    var enabledFilterColumnFields =
        refColumns.where((element) => element.enableFilterMenuItem).toList();

    setFilter(
      FilterHelper.convertRowsToFilter(filterRows, enabledFilterColumnFields),
      notify: isPaginated ? false : notify,
    );

    if (isPaginated) {
      resetPage(notify: notify);
    }
  }

  @override
  void setFilterRows(List<PlutoRow> rows) {
    _state._filterRows = rows
        .where(
          (element) => element.cells[FilterHelper.filterFieldValue]!.value
              .toString()
              .isNotEmpty,
        )
        .toList();
  }

  @override
  List<PlutoRow> filterRowsByField(String columnField) {
    return filterRows
        .where(
          (element) =>
              element.cells[FilterHelper.filterFieldColumn]!.value ==
              columnField,
        )
        .toList();
  }

  @override
  bool isFilteredColumn(PlutoColumn column) {
    return hasFilter && FilterHelper.isFilteredColumn(column, filterRows);
  }

  @override
  void removeColumnsInFilterRows(
    List<PlutoColumn> columns, {
    bool notify = true,
  }) {
    if (filterRows.isEmpty) {
      return;
    }

    final Set<String> columnFields = Set.from(columns.map((e) => e.field));

    filterRows.removeWhere(
      (filterRow) {
        return columnFields.contains(
          filterRow.cells[FilterHelper.filterFieldColumn]!.value,
        );
      },
    );

    setFilterWithFilterRows(filterRows, notify: notify);
  }

  @override
  void showFilterPopup(
    BuildContext context, {
    PlutoColumn? calledColumn,
    void Function()? onClosed,
  }) {
    var shouldProvideDefaultFilterRow =
        filterRows.isEmpty && calledColumn != null;

    var rows = shouldProvideDefaultFilterRow
        ? [
            FilterHelper.createFilterRow(
              columnField: calledColumn.enableFilterMenuItem
                  ? calledColumn.field
                  : FilterHelper.filterFieldAllColumns,
              filterType: calledColumn.defaultFilter,
            ),
          ]
        : filterRows;

    FilterHelper.filterPopup(
      FilterPopupState(
        context: context,
        configuration: configuration.copyWith(
          style: configuration.style.copyWith(
            gridBorderRadius: configuration.style.gridPopupBorderRadius,
            enableRowColorAnimation: false,
            oddRowColor: const PlutoOptional(null),
            evenRowColor: const PlutoOptional(null),
          ),
        ),
        handleAddNewFilter: (filterState) {
          filterState!.appendRows([FilterHelper.createFilterRow()]);
        },
        handleApplyFilter: (filterState) {
          setFilterWithFilterRows(filterState!.rows);
        },
        columns: columns,
        filterRows: rows,
        focusFirstFilterValue: shouldProvideDefaultFilterRow,
        onClosed: onClosed,
      ),
    );
  }
}
