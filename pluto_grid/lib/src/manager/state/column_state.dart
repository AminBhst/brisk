import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

abstract class IColumnState {
  /// Columns provided at grid start.
  List<PlutoColumn> get columns;

  FilteredList<PlutoColumn> get refColumns;

  /// Column index list.
  List<int> get columnIndexes;

  /// List of column indexes in which the sequence is maintained
  /// while the frozen column is visible.
  List<int> get columnIndexesForShowFrozen;

  /// Width of the entire column.
  double get columnsWidth;

  /// Left frozen columns.
  List<PlutoColumn> get leftFrozenColumns;

  /// Left frozen column Index List.
  List<int> get leftFrozenColumnIndexes;

  /// Width of the left frozen column.
  double get leftFrozenColumnsWidth;

  /// Right frozen columns.
  List<PlutoColumn> get rightFrozenColumns;

  /// Right frozen column Index List.
  List<int> get rightFrozenColumnIndexes;

  /// Width of the right frozen column.
  double get rightFrozenColumnsWidth;

  /// Body columns.
  List<PlutoColumn> get bodyColumns;

  /// Body column Index List.
  List<int> get bodyColumnIndexes;

  /// Width of the body column.
  double get bodyColumnsWidth;

  /// Column of currently selected cell.
  PlutoColumn? get currentColumn;

  /// Column field name of currently selected cell.
  String? get currentColumnField;

  bool get hasSortedColumn;

  PlutoColumn? get getSortedColumn;

  /// Column Index List by frozen Column
  List<int> get columnIndexesByShowFrozen;

  /// Toggle whether the column is frozen or not.
  ///
  /// When [column] is changed to a frozen column,
  /// the [PlutoColumn.frozen] is not changed if the frozen column width constraint is insufficient.
  /// Unfreeze the existing frozen or widen the entire grid width
  /// to set it wider than the frozen column width constraint.
  void toggleFrozenColumn(PlutoColumn column, PlutoColumnFrozen frozen);

  /// Toggle column sorting.
  ///
  /// It works when you tap the title area of a column.
  /// When called, [PlutoGrid.onSorted] callback is called. (If registered)
  ///
  /// [sortAscending], [sortDescending], [sortBySortIdx] also sort the column,
  /// but do not call the [PlutoGrid.onSorted] callback.
  void toggleSortColumn(PlutoColumn column);

  /// Index of [column] in [columns]
  ///
  /// Depending on the state of the frozen column, the column order index
  /// must be referenced with the columnIndexesByShowFrozen function.
  int? columnIndex(PlutoColumn column);

  /// Insert [columns] at [columnIdx] position.
  ///
  /// If there is a [PlutoColumn.frozen.isFrozen] column in [columns],
  /// If the width constraint of the frozen column is greater than the range,
  /// the columns are unfreeze in order.
  void insertColumns(int columnIdx, List<PlutoColumn> columns);

  void removeColumns(List<PlutoColumn> columns);

  /// Move [column] position to [targetColumn].
  ///
  /// In case of [column.frozen.isNone] and [targetColumn.frozen.isFroze],
  /// If the width constraint of a frozen column is narrow, it cannot be moved.
  void moveColumn({
    required PlutoColumn column,
    required PlutoColumn targetColumn,
  });

  /// Resize column size
  ///
  /// In case of [column.frozen.isFrozen],
  /// it is not changed if the width constraint of the frozen column is narrow.
  void resizeColumn(PlutoColumn column, double offset);

  void autoFitColumn(BuildContext context, PlutoColumn column);

  /// Hide or show the [column] with [hide] value.
  ///
  /// When [column.frozen.isFrozen] and [hide] is false,
  /// [column.frozen] is changed to [PlutoColumnFrozen.none]
  /// if the frozen column width constraint is narrow.
  void hideColumn(
    PlutoColumn column,
    bool hide, {
    bool notify = true,
  });

  /// Hide or show the [columns] with [hide] value.
  ///
  /// When [column.frozen.isFrozen] in [columns] and [hide] is false,
  /// [column.frozen] is changed to [PlutoColumnFrozen.none]
  /// if the frozen column width constraint is narrow.
  void hideColumns(
    List<PlutoColumn> columns,
    bool hide, {
    bool notify = true,
  });

  void sortAscending(PlutoColumn column, {bool notify = true});

  void sortDescending(PlutoColumn column, {bool notify = true});

  void sortBySortIdx(PlutoColumn column, {bool notify = true});

  void showSetColumnsPopup(BuildContext context);

  /// When expanding the width of the freeze column,
  /// check the width constraint of the freeze column.
  bool limitResizeColumn(PlutoColumn column, double offset);

  /// When moving from a non-frozen column to a frozen column area,
  /// check the frozen column width constraint.
  bool limitMoveColumn({
    required PlutoColumn column,
    required PlutoColumn targetColumn,
  });

  /// When changing the value of [PlutoColumn.frozen],
  /// check the frozen column width constraint.
  ///
  /// [frozen] is the value you want to change.
  bool limitToggleFrozenColumn(PlutoColumn column, PlutoColumnFrozen frozen);

  /// When changing a column from hidden state to unhidden state,
  /// Check the constraint on the frozen column.
  /// If the hidden column is a frozen column
  /// The width of the currently frozen column is limited.
  bool limitHideColumn(
    PlutoColumn column,
    bool hide, {
    double accumulateWidth = 0,
  });
}

mixin ColumnState implements IPlutoGridState {
  @override
  List<PlutoColumn> get columns => List.from(refColumns, growable: false);

  @override
  List<int> get columnIndexes => List.generate(
        refColumns.length,
        (index) => index,
        growable: false,
      );

  @override
  List<int> get columnIndexesForShowFrozen {
    final leftIndexes = <int>[];
    final bodyIndexes = <int>[];
    final rightIndexes = <int>[];
    final length = refColumns.length;

    for (int i = 0; i < length; i += 1) {
      refColumns[i].frozen.isNone
          ? bodyIndexes.add(i)
          : refColumns[i].frozen.isStart
              ? leftIndexes.add(i)
              : rightIndexes.add(i);
    }

    return leftIndexes + bodyIndexes + rightIndexes;
  }

  @override
  double get columnsWidth {
    double width = 0;

    for (final column in refColumns) {
      width += column.width;
    }

    return width;
  }

  @override
  List<PlutoColumn> get leftFrozenColumns {
    return refColumns.where((e) => e.frozen.isStart).toList(growable: false);
  }

  @override
  List<int> get leftFrozenColumnIndexes {
    final indexes = <int>[];
    final length = refColumns.length;

    for (int i = 0; i < length; i += 1) {
      if (refColumns[i].frozen.isStart) {
        indexes.add(i);
      }
    }

    return indexes;
  }

  @override
  double get leftFrozenColumnsWidth {
    double width = 0;

    for (final column in refColumns) {
      if (column.frozen.isStart) {
        width += column.width;
      }
    }

    return width;
  }

  @override
  List<PlutoColumn> get rightFrozenColumns {
    return refColumns.where((e) => e.frozen.isEnd).toList();
  }

  @override
  List<int> get rightFrozenColumnIndexes {
    final indexes = <int>[];
    final length = refColumns.length;

    for (int i = 0; i < length; i += 1) {
      if (refColumns[i].frozen.isEnd) {
        indexes.add(i);
      }
    }

    return indexes;
  }

  @override
  double get rightFrozenColumnsWidth {
    double width = 0;

    for (final column in refColumns) {
      if (column.frozen.isEnd) {
        width += column.width;
      }
    }

    return width;
  }

  @override
  List<PlutoColumn> get bodyColumns {
    return refColumns.where((e) => e.frozen.isNone).toList();
  }

  @override
  List<int> get bodyColumnIndexes {
    final indexes = <int>[];
    final length = refColumns.length;

    for (int i = 0; i < length; i += 1) {
      if (refColumns[i].frozen.isNone) {
        indexes.add(i);
      }
    }

    return indexes;
  }

  @override
  double get bodyColumnsWidth {
    double width = 0;

    for (final column in refColumns) {
      if (column.frozen.isNone) {
        width += column.width;
      }
    }

    return width;
  }

  @override
  PlutoColumn? get currentColumn {
    return currentCell?.column;
  }

  @override
  String? get currentColumnField {
    return currentCell?.column.field;
  }

  @override
  bool get hasSortedColumn {
    for (final column in refColumns) {
      if (column.sort.isNone == false) {
        return true;
      }
    }

    return false;
  }

  @override
  PlutoColumn? get getSortedColumn {
    for (final column in refColumns) {
      if (column.sort.isNone == false) {
        return column;
      }
    }

    return null;
  }

  @override
  List<int> get columnIndexesByShowFrozen {
    return showFrozenColumn ? columnIndexesForShowFrozen : columnIndexes;
  }

  @override
  void toggleFrozenColumn(PlutoColumn column, PlutoColumnFrozen frozen) {
    if (limitToggleFrozenColumn(column, frozen)) {
      return;
    }

    column.frozen = column.frozen.isFrozen ? PlutoColumnFrozen.none : frozen;

    resetCurrentState(notify: false);

    resetShowFrozenColumn();

    if (!columnSizeConfig.restoreAutoSizeAfterFrozenColumn) {
      deactivateColumnsAutoSize();
    }

    updateVisibilityLayout();

    if (onColumnsMoved != null) {
      onColumnsMoved!(PlutoGridOnColumnsMovedEvent(
        idx: refColumns.indexOf(column),
        visualIdx: columnIndex(column)!,
        columns: [column],
      ));
    }

    notifyListeners(true, toggleFrozenColumn.hashCode);
  }

  @override
  void toggleSortColumn(PlutoColumn column) {
    final oldSort = column.sort;

    if (column.sort.isNone) {
      sortAscending(column, notify: false);
    } else if (column.sort.isAscending) {
      sortDescending(column, notify: false);
    } else {
      sortBySortIdx(column, notify: false);
    }

    _callOnSorted(column, oldSort);

    notifyListeners(true, toggleSortColumn.hashCode);
  }

  @override
  int? columnIndex(PlutoColumn column) {
    final columnIndexes = columnIndexesByShowFrozen;
    final length = columnIndexes.length;

    for (int i = 0; i < length; i += 1) {
      if (refColumns[columnIndexes[i]].field == column.field) {
        return i;
      }
    }

    return null;
  }

  @override
  void insertColumns(int columnIdx, List<PlutoColumn> columns) {
    if (columns.isEmpty) {
      return;
    }

    if (columnIdx < 0 || refColumns.length < columnIdx) {
      return;
    }

    _updateLimitedFrozenColumns(columns);

    if (columnIdx >= refColumns.originalLength) {
      refColumns.addAll(columns);
    } else {
      refColumns.insertAll(columnIdx, columns);
    }

    _fillCellsInRows(columns);

    resetCurrentState(notify: false);

    resetShowFrozenColumn();

    if (!columnSizeConfig.restoreAutoSizeAfterInsertColumn) {
      deactivateColumnsAutoSize();
    }

    updateVisibilityLayout();

    notifyListeners(true, insertColumns.hashCode);
  }

  @override
  void removeColumns(List<PlutoColumn> columns) {
    if (columns.isEmpty) {
      return;
    }

    removeColumnsInColumnGroup(columns, notify: false);

    removeColumnsInFilterRows(columns, notify: false);

    removeColumnsInRowGroupByColumn(columns, notify: false);

    _removeCellsInRows(columns);

    final removeKeys = Set.from(columns.map((e) => e.key));

    refColumns.removeWhereFromOriginal(
      (column) => removeKeys.contains(column.key),
    );

    resetShowFrozenColumn();

    if (!columnSizeConfig.restoreAutoSizeAfterRemoveColumn) {
      deactivateColumnsAutoSize();
    }

    updateVisibilityLayout();

    resetCurrentState(notify: false);

    notifyListeners(true, removeColumns.hashCode);
  }

  @override
  void moveColumn({
    required PlutoColumn column,
    required PlutoColumn targetColumn,
  }) {
    if (limitMoveColumn(column: column, targetColumn: targetColumn)) {
      return;
    }

    final foundIndexes = _findIndexOfColumns([column, targetColumn]);

    if (foundIndexes.length != 2) {
      return;
    }

    int index = foundIndexes[0];

    int targetIndex = foundIndexes[1];

    final frozen = refColumns[index].frozen;

    final targetFrozen = refColumns[targetIndex].frozen;

    if (frozen != targetFrozen) {
      if (targetFrozen.isEnd && index > targetIndex) {
        targetIndex += 1;
      } else if (targetFrozen.isStart && index < targetIndex) {
        targetIndex -= 1;
      } else if (frozen.isStart && index > targetIndex) {
        targetIndex += 1;
      } else if (frozen.isEnd && index < targetIndex) {
        targetIndex -= 1;
      }
    }

    refColumns[index].frozen = targetFrozen;

    var columnToMove = refColumns[index];

    refColumns.removeAt(index);

    refColumns.insert(targetIndex, columnToMove);

    updateCurrentCellPosition(notify: false);

    resetShowFrozenColumn();

    if (!columnSizeConfig.restoreAutoSizeAfterMoveColumn) {
      deactivateColumnsAutoSize();
    }

    updateVisibilityLayout();

    if (onColumnsMoved != null) {
      onColumnsMoved!(PlutoGridOnColumnsMovedEvent(
        idx: targetIndex,
        visualIdx: columnIndex(columnToMove)!,
        columns: [columnToMove],
      ));
    }

    notifyListeners(true, moveColumn.hashCode);
  }

  @override
  void resizeColumn(PlutoColumn column, double offset) {
    if (columnsResizeMode.isNone || !column.enableDropToResize) {
      return;
    }

    if (limitResizeColumn(column, offset)) {
      return;
    }

    bool updated = false;

    if (columnsResizeMode.isNormal) {
      final setWidth = column.width + offset;

      column.width = setWidth > column.minWidth ? setWidth : column.minWidth;

      updated = setWidth == column.width;
    } else {
      updated = _updateResizeColumns(column: column, offset: offset);
    }

    if (updated == false) {
      return;
    }

    deactivateColumnsAutoSize();

    notifyResizingListeners();

    scrollByDirection(
      PlutoMoveDirection.right,
      correctHorizontalOffset,
    );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      activateColumnsAutoSize();
    });
  }

  @override
  void autoFitColumn(BuildContext context, PlutoColumn column) {
    final String maxValue = refRows.fold('', (previousValue, element) {
      final value = column.formattedValueForDisplay(
        element.cells.entries
            .firstWhere((element) => element.key == column.field)
            .value
            .value,
      );

      if (previousValue.length < value.length) {
        return value;
      }

      return previousValue;
    });

    // Get size after rendering virtually
    // https://stackoverflow.com/questions/54351655/flutter-textfield-width-should-match-width-of-contained-text
    TextSpan textSpan = TextSpan(
      style: DefaultTextStyle.of(context).style,
      text: maxValue,
    );

    TextPainter textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    // todo : Apply (popup type icon, checkbox, drag indicator, renderer)

    EdgeInsets cellPadding =
        column.cellPadding ?? configuration.style.defaultCellPadding;

    resizeColumn(
      column,
      textPainter.width -
          column.width +
          (cellPadding.left + cellPadding.right) +
          2,
    );
  }

  @override
  void hideColumn(
    PlutoColumn column,
    bool hide, {
    bool notify = true,
  }) {
    if (column.hide == hide) {
      return;
    }

    if (limitHideColumn(column, hide)) {
      column.frozen = PlutoColumnFrozen.none;
    }

    column.hide = hide;

    _updateAfterHideColumn(columns: [column], notify: notify);
  }

  @override
  void hideColumns(
    List<PlutoColumn> columns,
    bool hide, {
    bool notify = true,
  }) {
    if (columns.isEmpty) {
      return;
    }

    _updateLimitedHideColumns(columns, hide);

    _updateAfterHideColumn(columns: columns, notify: notify);
  }

  @override
  void sortAscending(PlutoColumn column, {bool notify = true}) {
    _updateBeforeColumnSort();

    column.sort = PlutoColumnSort.ascending;

    if (sortOnlyEvent) return;

    compare(a, b) => column.type.compare(
          a.cells[column.field]!.valueForSorting,
          b.cells[column.field]!.valueForSorting,
        );

    if (enabledRowGroups) {
      sortRowGroup(column: column, compare: compare);
    } else {
      refRows.sort(compare);
    }

    notifyListeners(notify, sortAscending.hashCode);
  }

  @override
  void sortDescending(PlutoColumn column, {bool notify = true}) {
    _updateBeforeColumnSort();

    column.sort = PlutoColumnSort.descending;

    if (sortOnlyEvent) return;

    compare(b, a) => column.type.compare(
          a.cells[column.field]!.valueForSorting,
          b.cells[column.field]!.valueForSorting,
        );

    if (enabledRowGroups) {
      sortRowGroup(column: column, compare: compare);
    } else {
      refRows.sort(compare);
    }

    notifyListeners(notify, sortDescending.hashCode);
  }

  @override
  void sortBySortIdx(PlutoColumn column, {bool notify = true}) {
    _updateBeforeColumnSort();

    if (sortOnlyEvent) return;

    int compare(a, b) {
      if (a.sortIdx == null || b.sortIdx == null) {
        if (a.sortIdx == null && b.sortIdx == null) {
          return 0;
        }

        return a.sortIdx == null ? -1 : 1;
      }

      return a.sortIdx!.compareTo(b.sortIdx!);
    }

    if (enabledRowGroups) {
      sortRowGroup(column: column, compare: compare);
    } else {
      refRows.sort(compare);
    }

    notifyListeners(notify, sortBySortIdx.hashCode);
  }

  @override
  void showSetColumnsPopup(BuildContext context) {
    const titleField = 'title';
    const columnField = 'field';

    final columns = [
      PlutoColumn(
        title: configuration.localeText.setColumnsTitle,
        field: titleField,
        type: PlutoColumnType.text(),
        enableRowChecked: true,
        enableEditingMode: false,
        enableDropToResize: true,
        enableContextMenu: false,
        enableColumnDrag: false,
      ),
      PlutoColumn(
        title: 'hidden column',
        field: columnField,
        type: PlutoColumnType.text(),
        hide: true,
      ),
    ];

    final toRow = _toRowByColumnField(
      titleField: titleField,
      columnField: columnField,
    );

    final rows = refColumns.originalList.map(toRow).toList(growable: false);

    void handleOnRowChecked(PlutoGridOnRowCheckedEvent event) {
      if (event.isAll) {
        hideColumns(refColumns.originalList, event.isChecked != true);
      } else {
        final checkedField = event.row!.cells[columnField]!.value.toString();
        final checkedColumn = refColumns.originalList.firstWhere(
          (column) => column.field == checkedField,
        );
        hideColumn(checkedColumn, event.isChecked != true);
      }
    }

    PlutoGridPopup(
      context: context,
      configuration: configuration.copyWith(
        style: configuration.style.copyWith(
          gridBorderRadius: configuration.style.gridPopupBorderRadius,
          enableRowColorAnimation: false,
          oddRowColor: const PlutoOptional(null),
          evenRowColor: const PlutoOptional(null),
        ),
      ),
      columns: columns,
      rows: rows,
      width: 200,
      height: 500,
      mode: PlutoGridMode.popup,
      onLoaded: (e) {
        e.stateManager.setSelectingMode(PlutoGridSelectingMode.none);
      },
      onRowChecked: handleOnRowChecked,
    );
  }

  @override
  bool limitResizeColumn(PlutoColumn column, double offset) {
    if (offset <= 0) {
      return false;
    }

    return _limitFrozenColumn(column.frozen, offset);
  }

  @override
  bool limitMoveColumn({
    required PlutoColumn column,
    required PlutoColumn targetColumn,
  }) {
    if (column.frozen.isFrozen) {
      return false;
    }

    return _limitFrozenColumn(targetColumn.frozen, column.width);
  }

  @override
  bool limitToggleFrozenColumn(PlutoColumn column, PlutoColumnFrozen frozen) {
    if (column.frozen.isFrozen) {
      return false;
    }

    return _limitFrozenColumn(frozen, column.width);
  }

  @override
  bool limitHideColumn(
    PlutoColumn column,
    bool hide, {
    double accumulateWidth = 0,
  }) {
    if (hide == true) {
      return false;
    }

    return _limitFrozenColumn(
      column.frozen,
      column.width + accumulateWidth,
    );
  }

  /// Check the width limit before changing the PlutoColumnFrozen value.
  ///
  /// In the following situations, need to check the frozen column width limit.
  /// 1. Change the width of the frozen column
  /// 2. Set a non-frozen column to a frozen column
  /// 3. If the column to be unhidden in the hidden state is a frozen column
  /// 4. Add a frozen column
  ///
  /// [frozen] The value to be changed.
  ///
  /// [offsetWidth] The size to be changed. Usually [PlutoColumn.width].
  /// Check the width limit of the frozen column
  /// by subtracting the offsetWidth value from the total width of the grid.
  /// Assume that a column has been added by subtracting the [offsetWidth] value
  /// from the total width while no column has been added yet.
  bool _limitFrozenColumn(
    PlutoColumnFrozen frozen,
    double offsetWidth,
  ) {
    if (frozen.isNone) {
      return false;
    }

    return !enoughFrozenColumnsWidth(maxWidth! - offsetWidth);
  }

  void _updateBeforeColumnSort() {
    clearCurrentCell(notify: false);

    clearCurrentSelecting(notify: false);

    // Reset column sort to none.
    for (var i = 0; i < refColumns.originalList.length; i += 1) {
      refColumns.originalList[i].sort = PlutoColumnSort.none;
    }
  }

  List<int> _findIndexOfColumns(List<PlutoColumn> findColumns) {
    SplayTreeMap<int, int> found = SplayTreeMap();

    for (int i = 0; i < refColumns.length; i += 1) {
      for (int j = 0; j < findColumns.length; j += 1) {
        if (findColumns[j].key == refColumns[i].key) {
          found[j] = i;
          continue;
        }
      }

      if (findColumns.length == found.length) {
        break;
      }
    }

    return found.values.toList();
  }

  PlutoRow Function(PlutoColumn column) _toRowByColumnField({
    required String titleField,
    required String columnField,
  }) {
    return (PlutoColumn column) {
      return PlutoRow(
        cells: {
          titleField: PlutoCell(value: column.titleWithGroup),
          columnField: PlutoCell(value: column.field),
        },
        checked: !column.hide,
      );
    };
  }

  /// [PlutoGrid.onSorted] Called when a callback is registered.
  void _callOnSorted(PlutoColumn column, PlutoColumnSort oldSort) {
    if (sortOnlyEvent) {
      eventManager!.addEvent(
        PlutoGridChangeColumnSortEvent(column: column, oldSort: oldSort),
      );
    }

    if (onSorted == null) {
      return;
    }

    onSorted!(PlutoGridOnSortedEvent(column: column, oldSort: oldSort));
  }

  /// Add [PlutoCell] to the whole [PlutoRow.cells].
  /// Called when a new column is added.
  void _fillCellsInRows(List<PlutoColumn> columns) {
    for (var row in iterateAllRowAndGroup) {
      final List<MapEntry<String, PlutoCell>> cells = [];

      for (var column in columns) {
        final cell = PlutoCell(value: column.type.defaultValue)
          ..setRow(row)
          ..setColumn(column);

        cells.add(MapEntry(column.field, cell));
      }

      row.cells.addEntries(cells);
    }
  }

  /// Delete [PlutoCell] with matching [columns.field] from [PlutoRow.cells].
  /// When a column is deleted, the corresponding [PlutoCell] is also called to be deleted.
  void _removeCellsInRows(List<PlutoColumn> columns) {
    for (var row in iterateAllRowAndGroup) {
      for (var column in columns) {
        row.cells.remove(column.field);
      }
    }
  }

  /// If there is a [PlutoColumn.frozen] column in [columns],
  /// check the width limit of the frozen column.
  /// If there are more frozen columns in [columns] than the width limit,
  /// they are updated in order to unfreeze them.
  void _updateLimitedFrozenColumns(List<PlutoColumn> columns) {
    double accumulateWidth = 0;

    for (final column in columns) {
      if (_limitFrozenColumn(
        column.frozen,
        column.width + accumulateWidth,
      )) {
        column.frozen = PlutoColumnFrozen.none;
      }

      if (column.frozen.isFrozen) {
        accumulateWidth += column.width;
      }
    }
  }

  /// Change the value of [PlutoColumn.hide] of [columns] to [hide].
  ///
  /// When there is a frozen column when it is unhidden in a hidden state,
  /// it is limited to the width of the frozen column area.
  /// Updated to unfreeze [PlutoColumn.frozen].
  void _updateLimitedHideColumns(List<PlutoColumn> columns, bool hide) {
    double accumulateWidth = 0;

    for (final column in columns) {
      if (hide == column.hide) {
        continue;
      }

      if (limitHideColumn(column, hide, accumulateWidth: accumulateWidth)) {
        column.frozen = PlutoColumnFrozen.none;
      }

      if (column.frozen.isFrozen) {
        accumulateWidth += column.width;
      }

      column.hide = hide;
    }
  }

  void _updateAfterHideColumn({
    required List<PlutoColumn> columns,
    required bool notify,
  }) {
    refColumns.update();

    resetCurrentState(notify: false);

    resetShowFrozenColumn();

    if (!columnSizeConfig.restoreAutoSizeAfterHideColumn) {
      deactivateColumnsAutoSize();
    }

    updateRowGroupByHideColumn(columns);

    updateVisibilityLayout();

    notifyListeners(notify, hideColumn.hashCode);
  }

  bool _updateResizeColumns({
    required PlutoColumn column,
    required double offset,
  }) {
    if (offset == 0 || columnsResizeMode.isNone || columnsResizeMode.isNormal) {
      return false;
    }

    final columns = showFrozenColumn
        ? leftFrozenColumns + bodyColumns + rightFrozenColumns
        : refColumns;

    final resizeHelper = getColumnsResizeHelper(
      columns: columns,
      column: column,
      offset: offset,
    );

    return resizeHelper.update();
  }
}
