import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

/// A callback function to implement when the scroll reaches the end.
typedef PlutoInfinityScrollRowsFetch = Future<PlutoInfinityScrollRowsResponse>
    Function(PlutoInfinityScrollRowsRequest);

/// Request data to get data when scrolling has reached the end.
class PlutoInfinityScrollRowsRequest {
  PlutoInfinityScrollRowsRequest({
    this.lastRow,
    this.sortColumn,
    this.filterRows = const <PlutoRow>[],
  });

  /// If [lastRow] is null , it points to the beginning of the data.
  /// If not null, the next data is loaded with reference to this value.
  final PlutoRow? lastRow;

  /// If the sort condition is set, the column for which the sort is set.
  /// The value of [PlutoColumn.sort] is the sort status of the column.
  final PlutoColumn? sortColumn;

  /// Filtering status when filtering conditions are set.
  ///
  /// If this list is empty, filtering is not set.
  /// Filtering column, type, and filtering value are set in [PlutoRow.cells].
  ///
  /// [filterRows] can be converted to Map type as shown below.
  /// ```dart
  /// FilterHelper.convertRowsToMap(filterRows);
  ///
  /// // Assuming that filtering is set in column2, the following values are returned.
  /// // {column2: [{Contains: 123}]}
  /// ```
  ///
  /// The filter type in FilterHelper.defaultFilters is the default,
  /// If there is user-defined filtering,
  /// the title set by the user is returned as the filtering type.
  /// All filtering can change the value returned as a filtering type by changing the name property.
  /// In case of PlutoFilterTypeContains filter, if you change the static type name to include
  /// PlutoFilterTypeContains.name = 'include';
  /// {column2: [{include: abc}, {include: 123}]} will be returned.
  final List<PlutoRow> filterRows;
}

/// The return value of the fetch callback function of [PlutoInfinityScrollRow]
/// when the scroll reaches the end.
class PlutoInfinityScrollRowsResponse {
  PlutoInfinityScrollRowsResponse({
    required this.isLast,
    required this.rows,
  });

  /// Set this value to true if all items are returned.
  final bool isLast;

  /// Rows to be added.
  final List<PlutoRow> rows;
}

/// When the end of the list is reached
/// by scrolling, arrow keys, or PageDown key manipulation
/// Add the response result to the grid by calling the [fetch] callback function.
///
/// ```dart
/// createFooter: (s) => PlutoInfinityScrollRows(
///   fetch: fetch,
///   stateManager: s,
/// ),
/// ```
class PlutoInfinityScrollRows extends StatefulWidget {
  const PlutoInfinityScrollRows({
    this.initialFetch = true,
    this.fetchWithSorting = true,
    this.fetchWithFiltering = true,
    required this.fetch,
    required this.stateManager,
    super.key,
  });

  /// Decide whether to call the fetch function first.
  final bool initialFetch;

  /// Decide whether to handle sorting in the fetch function.
  /// Default is true.
  /// If this value is false, the list is sorted with the current grid loaded.
  final bool fetchWithSorting;

  /// Decide whether to handle filtering in the fetch function.
  /// Default is true.
  /// If this value is false,
  /// the list is filtered while it is currently loaded in the grid.
  final bool fetchWithFiltering;

  /// A callback function that returns the data to be added.
  final PlutoInfinityScrollRowsFetch fetch;

  final PlutoGridStateManager stateManager;

  @override
  State<PlutoInfinityScrollRows> createState() =>
      _PlutoInfinityScrollRowsState();
}

class _PlutoInfinityScrollRowsState extends State<PlutoInfinityScrollRows> {
  late final StreamSubscription<PlutoGridEvent> _events;

  bool _isFetching = false;

  bool _isLast = false;

  PlutoGridStateManager get stateManager => widget.stateManager;

  ScrollController get scroll => stateManager.scroll.bodyRowsVertical!;

  @override
  void initState() {
    super.initState();

    if (widget.fetchWithSorting) {
      stateManager.setSortOnlyEvent(true);
    }

    if (widget.fetchWithFiltering) {
      stateManager.setFilterOnlyEvent(true);
    }

    _events = stateManager.eventManager!.listener(_eventListener);

    scroll.addListener(_scrollListener);

    if (widget.initialFetch) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _update(null);
      });
    }
  }

  @override
  void dispose() {
    scroll.removeListener(_scrollListener);

    _events.cancel();

    super.dispose();
  }

  void _eventListener(PlutoGridEvent event) {
    if (event is PlutoGridCannotMoveCurrentCellEvent &&
        event.direction.isDown &&
        !_isFetching) {
      _update(stateManager.refRows.last);
    } else if (event is PlutoGridChangeColumnSortEvent) {
      _update(null);
    } else if (event is PlutoGridSetColumnFilterEvent) {
      _update(null);
    }
  }

  void _scrollListener() {
    if (scroll.offset == scroll.position.maxScrollExtent && !_isFetching) {
      _update(stateManager.refRows.last);
    }
  }

  void _update(PlutoRow? lastRow) {
    if (lastRow == null) _isLast = false;

    if (_isLast) return;

    _isFetching = true;

    stateManager.setShowLoading(
      true,
      level: lastRow == null
          ? PlutoGridLoadingLevel.rows
          : PlutoGridLoadingLevel.rowsBottomCircular,
    );

    final request = PlutoInfinityScrollRowsRequest(
      lastRow: lastRow,
      sortColumn: stateManager.getSortedColumn,
      filterRows: stateManager.filterRows,
    );

    widget.fetch(request).then((response) {
      if (lastRow == null) {
        scroll.jumpTo(0);
        stateManager.removeAllRows(notify: false);
      }

      stateManager.appendRows(response.rows);

      stateManager.setShowLoading(false);

      _isFetching = false;

      _isLast = response.isLast;
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
