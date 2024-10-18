import 'package:flutter/cupertino.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../ui/ui.dart';

class PlutoChangeNotifierFilter<T> {
  PlutoChangeNotifierFilter(this._filter, [this._debugNotifierNames])
      : _type = T;

  static bool enabled = true;

  static bool debug = false;

  static bool get printDebug => enabled && debug;

  static List<String> debugWidgets = [];

  final Set<int> _filter;

  final Map<int, String>? _debugNotifierNames;

  final Type _type;

  bool any(PlutoNotifierEvent event) {
    printNotifierOnFilter(event);
    return _filter.isEmpty ? true : event.any(_filter);
  }

  void printNotifierOnFilter(PlutoNotifierEvent event) {
    if (_ignoreDebugPrint()) return;

    final length = event.notifier.length;

    debugPrint('[$_type] called on $length notifier.');
    for (int i = 0; i < length; i += 1) {
      final bool isLast = length - 1 == i;
      final prefix = isLast ? '\u2514' : '\u251c';
      final notifier = event.notifier.elementAt(i);
      debugPrint('  $prefix ${_debugNotifierNames?[notifier]}');
    }
  }

  void printNotifierOnChange(PlutoNotifierEvent event, bool rebuild) {
    if (_ignoreDebugPrint()) return;

    debugPrint('    ON_CHANGE - REBUILD : ${rebuild.toString().toUpperCase()}');
  }

  bool _ignoreDebugPrint() {
    return !enabled ||
        !debug ||
        (debugWidgets.isNotEmpty && !debugWidgets.contains(_type.toString()));
  }
}

abstract class PlutoChangeNotifierFilterResolver {
  const PlutoChangeNotifierFilterResolver();

  Set<int> resolve(PlutoGridStateManager stateManager, Type type);

  static Map<int, String> notifierNames(PlutoGridStateManager stateManager) {
    return {
      /// pluto_change_notifier
      stateManager.notifyListeners.hashCode: 'notifyListeners',
      stateManager.notifyListenersOnPostFrame.hashCode:
          'notifyListenersOnPostFrame',

      /// cell_state
      stateManager.setCurrentCellPosition.hashCode: 'setCurrentCellPosition',
      stateManager.updateCurrentCellPosition.hashCode:
          'updateCurrentCellPosition',
      stateManager.clearCurrentCell.hashCode: 'clearCurrentCell',
      stateManager.setCurrentCell.hashCode: 'setCurrentCell',

      /// column_group_state
      stateManager.setShowColumnGroups.hashCode: 'setShowColumnGroups',
      stateManager.removeColumnsInColumnGroup.hashCode:
          'removeColumnsInColumnGroup',

      /// column_state
      stateManager.toggleFrozenColumn.hashCode: 'toggleFrozenColumn',
      stateManager.toggleSortColumn.hashCode: 'toggleSortColumn',
      stateManager.insertColumns.hashCode: 'insertColumns',
      stateManager.removeColumns.hashCode: 'removeColumns',
      stateManager.moveColumn.hashCode: 'moveColumn',
      stateManager.sortAscending.hashCode: 'sortAscending',
      stateManager.sortDescending.hashCode: 'sortDescending',
      stateManager.sortBySortIdx.hashCode: 'sortBySortIdx',
      stateManager.hideColumn.hashCode: 'hideColumn',

      /// dragging_row_state
      stateManager.setIsDraggingRow.hashCode: 'setIsDraggingRow',
      stateManager.setDragRows.hashCode: 'setDragRows',
      stateManager.setDragTargetRowIdx.hashCode: 'setDragTargetRowIdx',

      /// editing_state
      stateManager.setEditing.hashCode: 'setEditing',
      stateManager.setAutoEditing.hashCode: 'setAutoEditing',
      stateManager.pasteCellValue.hashCode: 'pasteCellValue',
      stateManager.changeCellValue.hashCode: 'changeCellValue',

      /// filtering_row_state
      stateManager.setFilter.hashCode: 'setFilter',

      /// focus_state
      stateManager.setKeepFocus.hashCode: 'setKeepFocus',

      /// grid_state
      stateManager.resetCurrentState.hashCode: 'resetCurrentState',

      /// layout_state
      stateManager.setShowColumnTitle.hashCode: 'setShowColumnTitle',
      stateManager.setShowColumnFooter.hashCode: 'setShowColumnFooter',
      stateManager.setShowColumnFilter.hashCode: 'setShowColumnFilter',
      stateManager.setShowLoading.hashCode: 'setShowLoading',
      stateManager.notifyChangedShowFrozenColumn.hashCode:
          'notifyChangedShowFrozenColumn',

      /// pagination_state
      stateManager.setPageSize.hashCode: 'setPageSize',
      stateManager.setPage.hashCode: 'setPage',

      /// row_group_state
      stateManager.setRowGroup.hashCode: 'setRowGroup',
      stateManager.toggleExpandedRowGroup.hashCode: 'toggleExpandedRowGroup',

      /// row_state
      stateManager.setRowChecked.hashCode: 'setRowChecked',
      stateManager.insertRows.hashCode: 'insertRows',
      stateManager.prependRows.hashCode: 'prependRows',
      stateManager.appendRows.hashCode: 'appendRows',
      stateManager.removeCurrentRow.hashCode: 'removeCurrentRow',
      stateManager.removeRows.hashCode: 'removeRows',
      stateManager.removeAllRows.hashCode: 'removeAllRows',
      stateManager.moveRowsByIndex.hashCode: 'moveRowsByIndex',
      stateManager.toggleAllRowChecked.hashCode: 'toggleAllRowChecked',

      /// selecting_state
      stateManager.setSelecting.hashCode: 'setSelecting',
      stateManager.setSelectingMode.hashCode: 'setSelectingMode',
      stateManager.setCurrentSelectingPosition.hashCode:
          'setCurrentSelectingPosition',
      stateManager.setCurrentSelectingRowsByRange.hashCode:
          'setCurrentSelectingRowsByRange',
      stateManager.clearCurrentSelecting.hashCode: 'clearCurrentSelecting',
      stateManager.toggleSelectingRow.hashCode: 'toggleSelectingRow',
      stateManager.handleAfterSelectingRow.hashCode: 'handleAfterSelectingRow',
    };
  }
}

class PlutoNotifierFilterResolverDefault
    implements PlutoChangeNotifierFilterResolver {
  const PlutoNotifierFilterResolverDefault();

  @override
  Set<int> resolve(PlutoGridStateManager stateManager, Type type) {
    switch (type) {
      case PlutoGrid:
        return defaultGridFilter(stateManager);
      case PlutoBodyColumns:
      case PlutoBodyColumnsFooter:
      case PlutoLeftFrozenColumns:
      case PlutoLeftFrozenColumnsFooter:
      case PlutoRightFrozenColumns:
      case PlutoRightFrozenColumnsFooter:
        return defaultColumnsFilter(stateManager);
      case PlutoBodyRows:
      case PlutoLeftFrozenRows:
      case PlutoRightFrozenRows:
        return defaultRowsFilter(stateManager);
      case PlutoNoRowsWidget:
        return {
          ...defaultRowsFilter(stateManager),
          stateManager.setShowLoading.hashCode,
        };
      case PlutoAggregateColumnFooter:
        return defaultAggregateColumnFooterFilter(stateManager);
      case CheckboxSelectionWidget:
        return defaultCheckboxFilter(stateManager);
      case CheckboxAllSelectionWidget:
        return defaultCheckboxAllFilter(stateManager);
    }

    return <int>{};
  }

  static Set<int> defaultGridFilter(PlutoGridStateManager stateManager) {
    return {
      stateManager.setShowColumnTitle.hashCode,
      stateManager.setShowColumnFilter.hashCode,
      stateManager.setShowColumnFooter.hashCode,
      stateManager.setShowColumnGroups.hashCode,
      stateManager.setShowLoading.hashCode,
      stateManager.toggleFrozenColumn.hashCode,
      stateManager.insertColumns.hashCode,
      stateManager.removeColumns.hashCode,
      stateManager.moveColumn.hashCode,
      stateManager.hideColumn.hashCode,
      stateManager.notifyChangedShowFrozenColumn.hashCode,
    };
  }

  static Set<int> defaultColumnsFilter(PlutoGridStateManager stateManager) {
    return {
      stateManager.toggleFrozenColumn.hashCode,
      stateManager.insertColumns.hashCode,
      stateManager.removeColumns.hashCode,
      stateManager.moveColumn.hashCode,
      stateManager.hideColumn.hashCode,
      stateManager.setShowColumnGroups.hashCode,
      stateManager.removeColumnsInColumnGroup.hashCode,
      stateManager.notifyChangedShowFrozenColumn.hashCode,
    };
  }

  static Set<int> defaultRowsFilter(PlutoGridStateManager stateManager) {
    return {
      stateManager.toggleFrozenColumn.hashCode,
      stateManager.insertColumns.hashCode,
      stateManager.removeColumns.hashCode,
      stateManager.moveColumn.hashCode,
      stateManager.hideColumn.hashCode,
      stateManager.toggleSortColumn.hashCode,
      stateManager.sortAscending.hashCode,
      stateManager.sortDescending.hashCode,
      stateManager.sortBySortIdx.hashCode,
      stateManager.setShowColumnGroups.hashCode,
      stateManager.setFilter.hashCode,
      stateManager.removeColumnsInColumnGroup.hashCode,
      stateManager.insertRows.hashCode,
      stateManager.prependRows.hashCode,
      stateManager.appendRows.hashCode,
      stateManager.removeCurrentRow.hashCode,
      stateManager.removeRows.hashCode,
      stateManager.removeAllRows.hashCode,
      stateManager.moveRowsByIndex.hashCode,
      stateManager.setRowGroup.hashCode,
      stateManager.toggleExpandedRowGroup.hashCode,
      stateManager.notifyChangedShowFrozenColumn.hashCode,
      stateManager.setPage.hashCode,
      stateManager.setPageSize.hashCode,
    };
  }

  static Set<int> defaultAggregateColumnFooterFilter(
      PlutoGridStateManager stateManager) {
    return {
      stateManager.toggleAllRowChecked.hashCode,
      stateManager.setRowChecked.hashCode,
      stateManager.setPage.hashCode,
      stateManager.setPageSize.hashCode,
      stateManager.setFilter.hashCode,
      stateManager.toggleSortColumn.hashCode,
      stateManager.sortAscending.hashCode,
      stateManager.sortDescending.hashCode,
      stateManager.sortBySortIdx.hashCode,
      stateManager.insertRows.hashCode,
      stateManager.prependRows.hashCode,
      stateManager.appendRows.hashCode,
      stateManager.removeCurrentRow.hashCode,
      stateManager.removeRows.hashCode,
      stateManager.removeAllRows.hashCode,
      stateManager.setRowGroup.hashCode,
      stateManager.toggleExpandedRowGroup.hashCode,
      stateManager.changeCellValue.hashCode,
      stateManager.pasteCellValue.hashCode,
    };
  }

  static Set<int> defaultCheckboxFilter(PlutoGridStateManager stateManager) {
    if (stateManager.enabledRowGroups) {
      return PlutoNotifierFilterResolverDefault.defaultCheckboxAllFilter(
        stateManager,
      );
    }

    return {
      stateManager.toggleAllRowChecked.hashCode,
      stateManager.setRowChecked.hashCode,
    };
  }

  static Set<int> defaultCheckboxAllFilter(PlutoGridStateManager stateManager) {
    return {
      stateManager.toggleAllRowChecked.hashCode,
      stateManager.setRowChecked.hashCode,
      stateManager.setPage.hashCode,
      stateManager.setPageSize.hashCode,
      stateManager.setFilter.hashCode,
      stateManager.toggleSortColumn.hashCode,
      stateManager.sortAscending.hashCode,
      stateManager.sortDescending.hashCode,
      stateManager.sortBySortIdx.hashCode,
      stateManager.insertRows.hashCode,
      stateManager.prependRows.hashCode,
      stateManager.appendRows.hashCode,
      stateManager.removeCurrentRow.hashCode,
      stateManager.removeRows.hashCode,
      stateManager.removeAllRows.hashCode,
      stateManager.setRowGroup.hashCode,
      stateManager.toggleExpandedRowGroup.hashCode,
    };
  }
}
