import 'package:collection/collection.dart';
import 'package:pluto_grid/pluto_grid.dart';

/// Helper class for grouping rows.
class PlutoRowGroupHelper {
  /// Traversing the group rows of [rows] according to the [filter] condition.
  ///
  /// If [childrenFilter] is passed, the traversal condition of child rows is applied.
  ///
  /// If [iterateAll] is true,
  /// the filtering condition applied to the child row of each group is ignored and
  /// Iterate through the entire row.
  static Iterable<PlutoRow> iterateWithFilter(
    Iterable<PlutoRow> rows, {
    bool Function(PlutoRow)? filter,
    Iterator<PlutoRow>? Function(PlutoRow)? childrenFilter,
    bool iterateAll = true,
  }) sync* {
    if (rows.isEmpty) return;

    final List<Iterator<PlutoRow>> stack = [];

    Iterator<PlutoRow>? currentIter = rows.iterator;

    Iterator<PlutoRow>? defaultChildrenFilter(PlutoRow row) {
      return row.type.isGroup
          ? iterateAll
              ? row.type.group.children.originalList.iterator
              : row.type.group.children.iterator
          : null;
    }

    final filterChildren = childrenFilter ?? defaultChildrenFilter;

    while (currentIter != null || stack.isNotEmpty) {
      bool hasChildren = false;

      if (currentIter != null) {
        while (currentIter!.moveNext()) {
          if (filter == null || filter(currentIter.current)) {
            yield currentIter.current;
          }

          final Iterator<PlutoRow>? children = filterChildren(
            currentIter.current,
          );

          if (children != null) {
            stack.add(currentIter);
            currentIter = children;
            hasChildren = true;
            break;
          }
        }
      }

      if (!hasChildren) {
        currentIter = stack.lastOrNull;
        if (currentIter != null) stack.removeLast();
      }
    }
  }

  /// Apply [filter] condition to all groups in [rows].
  static void applyFilter({
    required FilteredList<PlutoRow> rows,
    required FilteredListFilter<PlutoRow>? filter,
  }) {
    if (rows.originalList.isEmpty) return;

    isGroup(PlutoRow row) => row.type.isGroup;

    if (filter == null) {
      rows.setFilter(null);

      final children = PlutoRowGroupHelper.iterateWithFilter(
        rows.originalList,
        filter: isGroup,
      );

      for (final child in children) {
        child.type.group.children.setFilter(null);
      }
    } else {
      isNotEmptyGroup(PlutoRow row) =>
          row.type.isGroup &&
          row.type.group.children.filterOrOriginalList.isNotEmpty;

      filterOrHasChildren(PlutoRow row) => filter(row) || isNotEmptyGroup(row);

      final children = PlutoRowGroupHelper.iterateWithFilter(
        rows.originalList,
        filter: isGroup,
      );

      for (final child in children.toList().reversed) {
        child.type.group.children.setFilter(filterOrHasChildren);
      }

      rows.setFilter(filterOrHasChildren);
    }
  }
}
