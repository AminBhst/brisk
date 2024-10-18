import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:pluto_grid/pluto_grid.dart';

/// {@template pluto_row_group_delegate_type}
/// Determines the grouping type of the row.
///
/// [tree] groups rows into an unformatted tree.
///
/// [byColumn] groups rows by a specified column.
/// {@endtemplate}
enum PlutoRowGroupDelegateType {
  tree,
  byColumn;

  bool get isTree => this == PlutoRowGroupDelegateType.tree;

  bool get isByColumn => this == PlutoRowGroupDelegateType.byColumn;
}

/// {@template pluto_row_group_on_toggled}
/// A callback that is called when a group row is expanded or collapsed.
///
/// For [row], [row.type] is a group.
/// You can access the parent row with [row.parent].
/// You can access child rows with [row.group.children].
///
/// If [expanded] is true, the group row is expanded, if false, it is collapsed.
/// {@endtemplate}
typedef PlutoRowGroupOnToggled = void Function({
  required PlutoRow row,
  required bool expanded,
});

/// Abstract class that defines a base interface for grouping rows.
///
/// [PlutoRowGroupTreeDelegate] or [PlutoRowGroupByColumnDelegate]
/// class implements this abstract class.
abstract class PlutoRowGroupDelegate {
  PlutoRowGroupDelegate({
    this.onToggled,
  });

  final countFormat = NumberFormat.compact();

  /// {@macro pluto_row_group_on_toggled}
  final PlutoRowGroupOnToggled? onToggled;

  /// {@macro pluto_row_group_delegate_type}
  PlutoRowGroupDelegateType get type;

  /// {@template pluto_row_group_delegate_enabled}
  /// Returns whether the grouping function is activated.
  ///
  /// It is enabled by default,
  /// In the case of [PlutoRowGroupDelegateType.byColumn],
  /// the column is hidden and temporarily deactivated when there is no column to group.
  /// {@endtemplate}
  bool get enabled;

  /// {@template pluto_row_group_delegate_showCount}
  /// Decide whether to display the number of child rows in the cell
  /// where the expand icon is displayed in the grouped state.
  /// {@endtemplate}
  bool get showCount;

  /// {@template pluto_row_group_delegate_enableCompactCount}
  /// Decide whether to simply display the number of child rows when [showCount] is true.
  ///
  /// ex) 1,234,567 > 1.2M
  /// {@endtemplate}
  bool get enableCompactCount;

  /// {@template pluto_row_group_delegate_showFirstExpandableIon}
  /// Decide whether to force the expand button to be displayed in the first cell.
  /// {@endtemplate}
  bool get showFirstExpandableIcon;

  /// {@template pluto_row_group_delegate_isEditableCell}
  /// Determines whether the cell is editable.
  /// {@endtemplate}
  bool isEditableCell(PlutoCell cell);

  /// {@template pluto_row_group_delegate_isExpandableCell}
  /// Decide whether to show the extended button.
  /// {@endtemplate}
  bool isExpandableCell(PlutoCell cell);

  /// {@template pluto_row_group_delegate_toGroup}
  /// Handling for grouping rows.
  /// {@endtemplate}
  List<PlutoRow> toGroup({required Iterable<PlutoRow> rows});

  /// {@template pluto_row_group_delegate_sort}
  /// Handle sorting of grouped rows.
  /// {@endtemplate}
  void sort({
    required PlutoColumn column,
    required FilteredList<PlutoRow> rows,
    required int Function(PlutoRow, PlutoRow) compare,
  });

  /// {@template pluto_row_group_delegate_filter}
  /// Handle filtering of grouped rows.
  /// {@endtemplate}
  void filter({
    required FilteredList<PlutoRow> rows,
    required FilteredListFilter<PlutoRow>? filter,
  });

  /// {@template pluto_row_group_delegate_compactNumber}
  /// Brief summary of numbers.
  /// {@endtemplate}
  String compactNumber(num count) {
    return countFormat.format(count);
  }
}

class PlutoRowGroupTreeDelegate extends PlutoRowGroupDelegate {
  /// Determine the depth based on the cell column.
  ///
  /// ```dart
  /// // Determine the depth according to the column order.
  /// resolveColumnDepth: (column) => stateManager.columnIndex(column),
  /// ```
  final int? Function(PlutoColumn column) resolveColumnDepth;

  /// Decide whether to display the text in the cell.
  ///
  /// ```dart
  /// // Display the text in all cells.
  /// showText: (cell) => true,
  /// ```
  final bool Function(PlutoCell cell) showText;

  /// {@macro pluto_row_group_delegate_showFirstExpandableIon}
  @override
  final bool showFirstExpandableIcon;

  /// {@macro pluto_row_group_delegate_showCount}
  @override
  final bool showCount;

  /// {@macro pluto_row_group_delegate_enableCompactCount}
  @override
  final bool enableCompactCount;

  PlutoRowGroupTreeDelegate({
    required this.resolveColumnDepth,
    required this.showText,
    this.showFirstExpandableIcon = false,
    this.showCount = true,
    this.enableCompactCount = true,
    super.onToggled,
  });

  /// {@macro pluto_row_group_delegate_type}
  @override
  PlutoRowGroupDelegateType get type => PlutoRowGroupDelegateType.tree;

  /// {@macro pluto_row_group_delegate_enabled}
  @override
  bool get enabled => true;

  /// {@macro pluto_row_group_delegate_isEditableCell}
  @override
  bool isEditableCell(PlutoCell cell) => showText(cell);

  /// {@macro pluto_row_group_delegate_isExpandableCell}
  @override
  bool isExpandableCell(PlutoCell cell) {
    if (!cell.row.type.isGroup) return false;
    final int checkDepth = showFirstExpandableIcon ? 0 : cell.row.depth;
    return cell.row.type.isGroup &&
        resolveColumnDepth(cell.column) == checkDepth;
  }

  /// {@macro pluto_row_group_delegate_toGroup}
  @override
  List<PlutoRow> toGroup({
    required Iterable<PlutoRow> rows,
  }) {
    if (rows.isEmpty) return rows.toList();

    final children = PlutoRowGroupHelper.iterateWithFilter(
      rows,
      filter: (r) => r.type.isGroup,
    );

    for (final child in children) {
      setParent(PlutoRow r) => r.setParent(child);
      child.type.group.children.originalList.forEach(setParent);
    }

    return rows.toList();
  }

  /// {@macro pluto_row_group_delegate_sort}
  @override
  void sort({
    required PlutoColumn column,
    required FilteredList<PlutoRow> rows,
    required int Function(PlutoRow, PlutoRow) compare,
  }) {
    if (rows.originalList.isEmpty) return;

    rows.sort(compare);

    final children = PlutoRowGroupHelper.iterateWithFilter(
      rows.originalList,
      filter: (r) => r.type.isGroup,
    );

    for (final child in children) {
      child.type.group.children.sort(compare);
    }
  }

  /// {@macro pluto_row_group_delegate_filter}
  @override
  void filter({
    required FilteredList<PlutoRow> rows,
    required FilteredListFilter<PlutoRow>? filter,
  }) {
    if (rows.originalList.isEmpty) return;

    PlutoRowGroupHelper.applyFilter(rows: rows, filter: filter);
  }
}

class PlutoRowGroupByColumnDelegate extends PlutoRowGroupDelegate {
  /// Column to group by.
  final List<PlutoColumn> columns;

  /// {@macro pluto_row_group_delegate_showFirstExpandableIon}
  @override
  final bool showFirstExpandableIcon;

  /// {@macro pluto_row_group_delegate_showCount}
  @override
  final bool showCount;

  /// {@macro pluto_row_group_delegate_enableCompactCount}
  @override
  final bool enableCompactCount;

  PlutoRowGroupByColumnDelegate({
    required this.columns,
    this.showFirstExpandableIcon = false,
    this.showCount = true,
    this.enableCompactCount = true,
    super.onToggled,
  });

  /// {@macro pluto_row_group_delegate_type}
  @override
  PlutoRowGroupDelegateType get type => PlutoRowGroupDelegateType.byColumn;

  /// {@macro pluto_row_group_delegate_enabled}
  @override
  bool get enabled => visibleColumns.isNotEmpty;

  /// Returns a non-hidden column from the column to be grouped.
  List<PlutoColumn> get visibleColumns =>
      columns.where((e) => !e.hide).toList();

  /// {@macro pluto_row_group_delegate_isEditableCell}
  @override
  bool isEditableCell(PlutoCell cell) =>
      cell.row.type.isNormal && !isRowGroupColumn(cell.column);

  /// {@macro pluto_row_group_delegate_isExpandableCell}
  @override
  bool isExpandableCell(PlutoCell cell) {
    if (cell.row.type.isNormal) return false;
    final int checkDepth = showFirstExpandableIcon ? 0 : cell.row.depth;
    return _columnDepth(cell.column) == checkDepth;
  }

  /// Returns whether the column is a grouping column.
  bool isRowGroupColumn(PlutoColumn column) {
    return visibleColumns.firstWhereOrNull((e) => e.field == column.field) !=
        null;
  }

  /// {@macro pluto_row_group_delegate_toGroup}
  @override
  List<PlutoRow> toGroup({
    required Iterable<PlutoRow> rows,
  }) {
    if (rows.isEmpty) return rows.toList();
    assert(visibleColumns.isNotEmpty);

    final List<PlutoRow> groups = [];
    final List<List<PlutoRow>> groupStack = [];
    final List<PlutoRow> parentStack = [];
    final List<String> groupFields =
        visibleColumns.map((e) => e.field).toList();
    final List<String> groupKeyStack = [];
    final maxDepth = groupFields.length;

    List<PlutoRow>? currentGroups = groups;
    PlutoRow? currentParent;
    int depth = 0;
    int sortIdx = 0;
    List<Iterator<MapEntry<String, List<PlutoRow>>>> stack = [];
    Iterator<MapEntry<String, List<PlutoRow>>>? currentIter;
    currentIter = groupBy<PlutoRow, String>(
      rows,
      (r) => r.cells[groupFields[depth]]!.value.toString(),
    ).entries.iterator;

    while (currentIter != null || stack.isNotEmpty) {
      if (currentIter != null && depth < maxDepth && currentIter.moveNext()) {
        groupKeyStack.add(currentIter.current.key);
        final groupKeys = [
          visibleColumns[depth].field,
          groupKeyStack.join('_'),
          'rowGroup',
        ];

        final row = _createRowGroup(
          groupKeys: groupKeys,
          sortIdx: ++sortIdx,
          sampleRow: currentIter.current.value.first,
        );

        currentParent = parentStack.lastOrNull;
        if (currentParent != null) row.setParent(currentParent);

        parentStack.add(row);
        currentGroups!.add(row);
        stack.add(currentIter);
        groupStack.add(currentGroups);
        currentGroups = row.type.group.children;

        if (depth + 1 < maxDepth) {
          currentIter = groupBy<PlutoRow, String>(
            currentIter.current.value,
            (r) => r.cells[groupFields[depth + 1]]!.value.toString(),
          ).entries.iterator;
        }

        ++depth;
      } else {
        --depth;
        if (depth < 0) break;

        groupKeyStack.removeLast();
        currentParent = parentStack.lastOrNull;
        if (currentParent != null) parentStack.removeLast();
        currentIter = stack.lastOrNull;
        if (currentIter != null) stack.removeLast();

        if (depth + 1 == maxDepth) {
          int sortIdx = 0;
          for (final child in currentIter!.current.value) {
            currentGroups!.add(child);
            child.setParent(currentParent);
            child.sortIdx = ++sortIdx;
          }
        }

        currentGroups = groupStack.lastOrNull;
        if (currentGroups != null) groupStack.removeLast();
      }

      if (depth == 0) groupKeyStack.clear();
    }

    return groups;
  }

  /// {@macro pluto_row_group_delegate_sort}
  @override
  void sort({
    required PlutoColumn column,
    required FilteredList<PlutoRow> rows,
    required int Function(PlutoRow, PlutoRow) compare,
  }) {
    if (rows.originalList.isEmpty) return;

    final depth = _columnDepth(column);

    if (depth == 0) {
      rows.sort(compare);
      return;
    }

    final children = PlutoRowGroupHelper.iterateWithFilter(
      rows.originalList,
      filter: (r) => r.type.isGroup,
      childrenFilter: (r) => _isFirstChildGroup(r)
          ? r.type.group.children.originalList.iterator
          : null,
    );

    for (final child in children) {
      if (_firstChildDepth(child) == depth) {
        child.type.group.children.sort(compare);
      }
    }
  }

  /// {@macro pluto_row_group_delegate_filter}
  @override
  void filter({
    required FilteredList<PlutoRow> rows,
    required FilteredListFilter<PlutoRow>? filter,
  }) {
    if (rows.originalList.isEmpty) return;

    PlutoRowGroupHelper.applyFilter(rows: rows, filter: filter);
  }

  int _columnDepth(PlutoColumn column) => visibleColumns.indexOf(column);

  int _firstChildDepth(PlutoRow row) {
    if (!row.type.group.children.originalList.first.type.isGroup) {
      return -1;
    }

    return row.type.group.children.originalList.first.depth;
  }

  bool _isFirstChildGroup(PlutoRow row) {
    return row.type.group.children.originalList.first.type.isGroup;
  }

  PlutoRow _createRowGroup({
    required List<String> groupKeys,
    required int sortIdx,
    required PlutoRow sampleRow,
  }) {
    final cells = <String, PlutoCell>{};

    final groupKey = groupKeys.join('_');

    final row = PlutoRow(
      key: ValueKey(groupKey),
      cells: cells,
      sortIdx: sortIdx,
      type: PlutoRowType.group(
        children: FilteredList(initialList: []),
      ),
    );

    for (var e in sampleRow.cells.entries) {
      cells[e.key] = PlutoCell(
        value: visibleColumns.firstWhereOrNull((c) => c.field == e.key) != null
            ? e.value.value
            : null,
        key: ValueKey('${groupKey}_${e.key}_cell'),
      )
        ..setColumn(e.value.column)
        ..setRow(row);
    }

    return row;
  }
}
