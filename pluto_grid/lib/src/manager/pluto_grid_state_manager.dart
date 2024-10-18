import 'dart:async';
import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'state/cell_state.dart';
import 'state/column_group_state.dart';
import 'state/column_sizing_state.dart';
import 'state/column_state.dart';
import 'state/dragging_row_state.dart';
import 'state/editing_state.dart';
import 'state/filtering_row_state.dart';
import 'state/focus_state.dart';
import 'state/grid_state.dart';
import 'state/keyboard_state.dart';
import 'state/layout_state.dart';
import 'state/pagination_row_state.dart';
import 'state/row_group_state.dart';
import 'state/row_state.dart';
import 'state/scroll_state.dart';
import 'state/selecting_state.dart';
import 'state/visibility_layout_state.dart';

abstract class IPlutoGridState
    implements
        PlutoChangeNotifier,
        ICellState,
        IColumnGroupState,
        IColumnSizingState,
        IColumnState,
        IDraggingRowState,
        IEditingState,
        IFilteringRowState,
        IFocusState,
        IGridState,
        IKeyboardState,
        ILayoutState,
        IPaginationRowState,
        IRowGroupState,
        IRowState,
        IScrollState,
        ISelectingState,
        IVisibilityLayoutState {}

class PlutoGridStateChangeNotifier extends PlutoChangeNotifier
    with
        CellState,
        ColumnGroupState,
        ColumnSizingState,
        ColumnState,
        DraggingRowState,
        EditingState,
        FilteringRowState,
        FocusState,
        GridState,
        KeyboardState,
        LayoutState,
        PaginationRowState,
        RowGroupState,
        RowState,
        ScrollState,
        SelectingState,
        VisibilityLayoutState {
  PlutoGridStateChangeNotifier({
    required List<PlutoColumn> columns,
    required List<PlutoRow> rows,
    required this.gridFocusNode,
    required this.scroll,
    List<PlutoColumnGroup>? columnGroups,
    this.onChanged,
    this.onSelected,
    this.onSorted,
    this.onRowChecked,
    this.onRowDoubleTap,
    this.onRowSecondaryTap,
    this.onRowsMoved,
    this.onColumnsMoved,
    this.rowColorCallback,
    this.createHeader,
    this.createFooter,
    PlutoColumnMenuDelegate? columnMenuDelegate,
    PlutoChangeNotifierFilterResolver? notifierFilterResolver,
    PlutoGridConfiguration configuration = const PlutoGridConfiguration(),
    PlutoGridMode? mode,
  })  : refColumns = FilteredList(initialList: columns),
        refRows = FilteredList(initialList: rows),
        refColumnGroups = FilteredList<PlutoColumnGroup>(
          initialList: columnGroups,
        ),
        columnMenuDelegate =
            columnMenuDelegate ?? const PlutoColumnMenuDelegateDefault(),
        notifierFilterResolver = notifierFilterResolver ??
            const PlutoNotifierFilterResolverDefault(),
        gridKey = GlobalKey() {
    setConfiguration(configuration);
    setGridMode(mode ?? PlutoGridMode.normal);
    _initialize();
  }

  @override
  final FilteredList<PlutoColumn> refColumns;

  @override
  final FilteredList<PlutoColumnGroup> refColumnGroups;

  @override
  final FilteredList<PlutoRow> refRows;

  @override
  final FocusNode gridFocusNode;

  @override
  final PlutoGridScrollController scroll;

  @override
  final PlutoOnChangedEventCallback? onChanged;

  @override
  final PlutoOnSelectedEventCallback? onSelected;

  @override
  final PlutoOnSortedEventCallback? onSorted;

  @override
  final PlutoOnRowCheckedEventCallback? onRowChecked;

  @override
  final PlutoOnRowDoubleTapEventCallback? onRowDoubleTap;

  @override
  final PlutoOnRowSecondaryTapEventCallback? onRowSecondaryTap;

  @override
  final PlutoOnRowsMovedEventCallback? onRowsMoved;

  @override
  final PlutoOnColumnsMovedEventCallback? onColumnsMoved;

  @override
  final PlutoRowColorCallback? rowColorCallback;

  @override
  final CreateHeaderCallBack? createHeader;

  @override
  final CreateFooterCallBack? createFooter;

  @override
  final PlutoColumnMenuDelegate columnMenuDelegate;

  final PlutoChangeNotifierFilterResolver notifierFilterResolver;

  @override
  final GlobalKey gridKey;

  void _initialize() {
    PlutoGridStateManager.initializeRows(
      refColumns.originalList,
      refRows.originalList,
    );

    refColumns.setFilter((element) => element.hide == false);

    setShowColumnGroups(columnGroups.isNotEmpty, notify: false);

    setShowColumnFooter(
      refColumns.originalList.any((e) => e.footerRenderer != null),
      notify: false,
    );

    setGroupToColumn();
  }
}

/// It manages the state of the [PlutoGrid] and contains methods used by the grid.
///
/// An instance of [PlutoGridStateManager] can be returned
/// through the [onLoaded] callback of the [PlutoGrid] constructor.
/// ```dart
/// PlutoGridStateManager stateManager;
///
/// PlutoGrid(
///   onLoaded: (PlutoGridOnLoadedEvent event) => stateManager = event.stateManager,
/// )
/// ```
/// {@template initialize_rows_sync_or_async}
/// It is created when [PlutoGrid] is first created,
/// and the state required for the grid is set for `List<PlutoRow> rows`.
/// [PlutoGridStateManager.initializeRows], which operates at this time, works synchronously,
/// and if there are many rows, the UI may freeze when starting the grid.
///
/// To prevent UI from freezing when passing many rows to [PlutoGrid],
/// you can set rows asynchronously as follows.
/// After passing an empty list when creating [PlutoGrid],
/// add rows initialized with [initializeRowsAsync] as shown below.
///
/// ```dart
/// PlutoGridStateManager.initializeRowsAsync(
///   columns,
///   fetchedRows,
/// ).then((value) {
///   stateManager.refRows.addAll(FilteredList(initialList: value));
///   stateManager.notifyListeners();
/// });
/// {@endtemplate}
/// ```
class PlutoGridStateManager extends PlutoGridStateChangeNotifier {
  PlutoGridStateManager({
    required super.columns,
    required super.rows,
    required super.gridFocusNode,
    required super.scroll,
    super.columnGroups,
    super.onChanged,
    super.onSelected,
    super.onSorted,
    super.onRowChecked,
    super.onRowDoubleTap,
    super.onRowSecondaryTap,
    super.onRowsMoved,
    super.onColumnsMoved,
    super.rowColorCallback,
    super.createHeader,
    super.createFooter,
    super.columnMenuDelegate,
    super.notifierFilterResolver,
    super.configuration,
    super.mode,
  });

  PlutoChangeNotifierFilter<T> resolveNotifierFilter<T>() {
    return PlutoChangeNotifierFilter<T>(
      notifierFilterResolver.resolve(this, T),
      PlutoChangeNotifierFilter.debug
          ? PlutoChangeNotifierFilterResolver.notifierNames(this)
          : null,
    );
  }

  /// It handles the necessary settings when [rows] are first set or added to the [PlutoGrid].
  ///
  /// {@template initialize_rows_params}
  /// [forceApplySortIdx] determines whether to force PlutoRow.sortIdx to be set.
  ///
  /// [increase] and [start] are valid only when [forceApplySortIdx] is true.
  ///
  /// [increase] determines whether to increment or decrement when initializing [sortIdx].
  /// For example, if a row is added before an existing row,
  /// the [sortIdx] value should be set to a negative number than the row being added.
  ///
  /// [start] sets the starting value when initializing [sortIdx].
  /// For example, if sortIdx is set from 0 to 9 in the previous 10 rows,
  /// [start] is set to 10, which sets the sortIdx of the row added at the end.
  /// {@endtemplate}
  ///
  /// {@macro initialize_rows_sync_or_async}
  static List<PlutoRow> initializeRows(
    List<PlutoColumn> refColumns,
    List<PlutoRow> refRows, {
    bool forceApplySortIdx = true,
    bool increase = true,
    int start = 0,
  }) {
    if (refColumns.isEmpty || refRows.isEmpty) {
      return refRows;
    }

    _ApplyList applyList = _ApplyList([
      _ApplyCellForSetColumnRow(refColumns),
      _ApplyRowForSortIdx(
        forceApply: forceApplySortIdx,
        increase: increase,
        start: start,
        firstRow: refRows.first,
      ),
      _ApplyRowGroup(refColumns),
    ]);

    if (!applyList.apply) {
      return refRows;
    }

    var rowLength = refRows.length;

    for (var rowIdx = 0; rowIdx < rowLength; rowIdx += 1) {
      applyList.execute(refRows[rowIdx]);
    }

    return refRows;
  }

  /// An asynchronous version of [PlutoGridStateManager.initializeRows].
  ///
  /// [PlutoGridStateManager.initializeRowsAsync] repeats [Timer] every [duration],
  /// Process the setting of [refRows] by the size of [chunkSize].
  /// [Isolate] is a good way to handle CPU heavy work, but
  /// The condition that List<PlutoRow> cannot be passed to Isolate
  /// solves the problem of UI freezing by dividing the work with Timer.
  ///
  /// {@macro initialize_rows_params}
  ///
  /// [chunkSize] determines the number of lists processed at one time when setting rows.
  ///
  /// [duration] determines the processing interval when setting rows.
  ///
  /// If pagination is set, [PlutoGridStateManager.setPage] must be called
  /// after Future is completed before Rows appear on the screen.
  ///
  /// ```dart
  /// PlutoGridStateManager.initializeRowsAsync(columns, fetchedRows).then((initializedRows) {
  ///   stateManager.refRows.addAll(initializedRows);
  ///   stateManager.setPage(1, notify: false);
  ///   stateManager.notifyListeners();
  /// });
  /// ```
  ///
  /// {@macro initialize_rows_sync_or_async}
  static Future<List<PlutoRow>> initializeRowsAsync(
    List<PlutoColumn> refColumns,
    List<PlutoRow> refRows, {
    bool forceApplySortIdx = true,
    bool increase = true,
    int start = 0,
    int chunkSize = 100,
    Duration duration = const Duration(milliseconds: 1),
  }) {
    if (refColumns.isEmpty || refRows.isEmpty) {
      return Future.value(refRows);
    }

    assert(chunkSize > 0);

    final Completer<List<PlutoRow>> completer = Completer();

    SplayTreeMap<int, List<PlutoRow>> splayMapRows = SplayTreeMap();

    final Iterable<List<PlutoRow>> chunks = refRows.slices(chunkSize);

    final chunksLength = chunks.length;

    final List<int> chunksIndexes = List.generate(
      chunksLength,
      (index) => index,
    );

    Timer.periodic(duration, (timer) {
      if (chunksIndexes.isEmpty) {
        return;
      }

      final chunkIndex = chunksIndexes.removeLast();

      final chunk = chunks.elementAt(chunkIndex);

      Future(() {
        return PlutoGridStateManager.initializeRows(
          refColumns,
          chunk,
          forceApplySortIdx: forceApplySortIdx,
          increase: increase,
          start: start + (chunkIndex * chunkSize),
        );
      }).then((value) {
        splayMapRows[chunkIndex] = value;

        if (splayMapRows.length == chunksLength) {
          completer.complete(
            splayMapRows.values.expand((element) => element).toList(),
          );

          timer.cancel();
        }
      });
    });

    return completer.future;
  }
}

/// This is a class for handling horizontal and vertical scrolling of columns and rows of [PlutoGrid].
class PlutoGridScrollController {
  LinkedScrollControllerGroup? vertical;

  LinkedScrollControllerGroup? horizontal;

  PlutoGridScrollController({
    this.vertical,
    this.horizontal,
  });

  ScrollController? get bodyRowsHorizontal => _bodyRowsHorizontal;

  ScrollController? _bodyRowsHorizontal;

  ScrollController? get bodyRowsVertical => _bodyRowsVertical;

  ScrollController? _bodyRowsVertical;

  double get maxScrollHorizontal {
    assert(_bodyRowsHorizontal != null);

    return _bodyRowsHorizontal!.position.maxScrollExtent;
  }

  double get maxScrollVertical {
    assert(_bodyRowsVertical != null);

    return _bodyRowsVertical!.position.maxScrollExtent;
  }

  double get verticalOffset => vertical!.offset;

  double get horizontalOffset => horizontal!.offset;

  void setBodyRowsHorizontal(ScrollController? scrollController) {
    _bodyRowsHorizontal = scrollController;
  }

  void setBodyRowsVertical(ScrollController? scrollController) {
    _bodyRowsVertical = scrollController;
  }
}

class PlutoGridCellPosition {
  final int? columnIdx;
  final int? rowIdx;

  const PlutoGridCellPosition({
    this.columnIdx,
    this.rowIdx,
  });

  bool get hasPosition => columnIdx != null && rowIdx != null;

  @override
  bool operator ==(covariant Object other) {
    return identical(this, other) ||
        other is PlutoGridCellPosition &&
            runtimeType == other.runtimeType &&
            columnIdx == other.columnIdx &&
            rowIdx == other.rowIdx;
  }

  @override
  int get hashCode => Object.hash(columnIdx, rowIdx);
}

class PlutoGridSelectingCellPosition {
  final String? field;
  final int? rowIdx;

  const PlutoGridSelectingCellPosition({
    this.field,
    this.rowIdx,
  });

  @override
  bool operator ==(covariant Object other) {
    return identical(this, other) ||
        other is PlutoGridSelectingCellPosition &&
            runtimeType == other.runtimeType &&
            field == other.field &&
            rowIdx == other.rowIdx;
  }

  @override
  int get hashCode => Object.hash(field, rowIdx);
}

class PlutoGridKeyPressed {
  bool get shift {
    final keysPressed = HardwareKeyboard.instance.logicalKeysPressed;

    return !(!keysPressed.contains(LogicalKeyboardKey.shiftLeft) &&
        !keysPressed.contains(LogicalKeyboardKey.shiftRight));
  }

  bool get ctrl {
    final keysPressed = HardwareKeyboard.instance.logicalKeysPressed;

    return !(!keysPressed.contains(LogicalKeyboardKey.controlLeft) &&
        !keysPressed.contains(LogicalKeyboardKey.controlRight));
  }
}

/// A type of selection mode when you select a row or cell in a grid
/// by tapping and holding, then moving the pointer
/// or selecting a row or cell in the grid with controls or shift and tap.
///
/// [PlutoGridSelectingMode.cell] selects each cell.
///
/// [PlutoGridSelectingMode.row] selects row by row.
///
/// [PlutoGridSelectingMode.none] does nothing.
enum PlutoGridSelectingMode {
  cell,
  row,
  none,

  /// using only internal
  horizontal;

  bool get isCell => this == PlutoGridSelectingMode.cell;

  bool get isRow => this == PlutoGridSelectingMode.row;

  bool get isNone => this == PlutoGridSelectingMode.none;

  /// using only internal
  bool get isHorizontal => this == PlutoGridSelectingMode.horizontal;
}

abstract class _Apply {
  bool get apply;

  void execute(PlutoRow row);
}

class _ApplyList implements _Apply {
  final List<_Apply> list;

  _ApplyList(this.list) {
    list.removeWhere((element) => !element.apply);
  }

  @override
  bool get apply => list.isNotEmpty;

  @override
  void execute(PlutoRow row) {
    var len = list.length;

    for (var i = 0; i < len; i += 1) {
      list[i].execute(row);
    }
  }
}

class _ApplyCellForSetColumnRow implements _Apply {
  final List<PlutoColumn> refColumns;

  _ApplyCellForSetColumnRow(this.refColumns);

  @override
  bool get apply => true;

  @override
  void execute(PlutoRow row) {
    if (row.initialized) {
      return;
    }

    for (var element in refColumns) {
      row.cells[element.field]!
        ..setColumn(element)
        ..setRow(row);
    }
  }
}

class _ApplyRowForSortIdx implements _Apply {
  final bool forceApply;

  final bool increase;

  final int start;

  final PlutoRow? firstRow;

  _ApplyRowForSortIdx({
    required this.forceApply,
    required this.increase,
    required this.start,
    required this.firstRow,
  }) {
    assert(firstRow != null);

    _sortIdx = start;
  }

  late int _sortIdx;

  @override
  bool get apply => forceApply == true;

  @override
  void execute(PlutoRow row) {
    row.sortIdx = _sortIdx;

    _sortIdx = increase ? ++_sortIdx : --_sortIdx;
  }
}

class _ApplyRowGroup implements _Apply {
  final List<PlutoColumn> refColumns;

  _ApplyRowGroup(this.refColumns);

  @override
  bool get apply => true;

  @override
  void execute(PlutoRow row) {
    if (_hasChildren(row)) {
      _initializeChildren(
        columns: refColumns,
        rows: row.type.group.children.originalList,
        parent: row,
      );
    }
  }

  void _initializeChildren({
    required List<PlutoColumn> columns,
    required List<PlutoRow> rows,
    required PlutoRow parent,
  }) {
    for (final row in rows) {
      row.setParent(parent);
    }

    PlutoGridStateManager.initializeRows(columns, rows);
  }

  bool _hasChildren(PlutoRow row) {
    return row.type.isGroup && row.type.group.children.originalList.isNotEmpty;
  }
}
