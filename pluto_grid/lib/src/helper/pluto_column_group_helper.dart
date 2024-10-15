import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

/// Helper class for handling [PlutoColumnGroup].
class PlutoColumnGroupHelper {
  /// Returns whether [field] exists in [columnGroup].
  static bool exists({
    required String field,
    required PlutoColumnGroup columnGroup,
  }) {
    if (columnGroup.hasFields) {
      return columnGroup.fields!.contains(field);
    }

    for (int i = 0; i < columnGroup.children!.length; i += 1) {
      if (exists(
        field: field,
        columnGroup: columnGroup.children![i],
      )) {
        return true;
      }
    }

    return false;
  }

  /// Returns whether [field] exists in [columnGroupList].
  static bool existsFromList({
    required String field,
    required List<PlutoColumnGroup> columnGroupList,
  }) {
    for (int i = 0; i < columnGroupList.length; i += 1) {
      if (exists(field: field, columnGroup: columnGroupList[i])) {
        return true;
      }
    }
    return false;
  }

  /// Find the parent class of [field] in [columnGroupList] and return it.
  /// Returns `null` if not found.
  static PlutoColumnGroup? getParentGroupIfExistsFromList({
    required String field,
    required List<PlutoColumnGroup> columnGroupList,
  }) {
    for (final columnGroup in columnGroupList) {
      if (columnGroup.hasFields && columnGroup.fields!.contains(field)) {
        return columnGroup;
      } else if (columnGroup.hasChildren) {
        for (int i = 0; i < columnGroup.children!.length; i += 1) {
          final found = getParentGroupIfExistsFromList(
            field: field,
            columnGroupList: columnGroup.children!,
          );

          if (found != null) {
            return found;
          }
        }
      }
    }

    return null;
  }

  /// Finds [PlutoColumnGroup] with [field] in [columnGroupList] and returns it.
  /// Returns `null` if not found.
  static PlutoColumnGroup? getGroupIfExistsFromList({
    required String field,
    required List<PlutoColumnGroup> columnGroupList,
  }) {
    for (int i = 0; i < columnGroupList.length; i += 1) {
      if (exists(field: field, columnGroup: columnGroupList[i])) {
        return columnGroupList[i];
      }
    }
    return null;
  }

  /// Separate groups according to the order of [columns].
  ///
  /// There are columns A, B, C, D, E
  /// If A and B are the same group, they are included as the same group.
  ///
  /// If C and E are in the same group,
  /// but there is D included in another group in the middle,
  /// C and E are in the same group but separated.
  static List<PlutoColumnGroupPair> separateLinkedGroup({
    required List<PlutoColumnGroup> columnGroupList,
    required List<PlutoColumn> columns,
  }) {
    if (columnGroupList.isEmpty || columns.isEmpty) {
      return [];
    }

    List<PlutoColumnGroupPair> separatedColumns = [];

    PlutoColumnGroup? previousGroup;

    List<PlutoColumn> linkedColumns = <PlutoColumn>[];

    for (int i = 0; i < columns.length; i += 1) {
      final column = columns[i];

      final field = column.field;

      final foundGroup = getGroupIfExistsFromList(
            field: field,
            columnGroupList: columnGroupList,
          ) ??
          PlutoColumnGroup(
            key: ValueKey(field),
            title: field,
            fields: [field],
            expandedColumn: true,
          );

      previousGroup ??= foundGroup;

      if (previousGroup.key != foundGroup.key) {
        separatedColumns.add(PlutoColumnGroupPair(
          group: previousGroup,
          columns: linkedColumns,
        ));

        linkedColumns = [];

        previousGroup = foundGroup;
      }

      linkedColumns.add(column);

      if (i == columns.length - 1) {
        separatedColumns.add(PlutoColumnGroupPair(
          group: foundGroup,
          columns: linkedColumns,
        ));
      }
    }

    return separatedColumns;
  }

  /// [columnGroupList] Returns the depth of how many levels the group has been set.
  static int maxDepth({
    required List<PlutoColumnGroup> columnGroupList,
    int level = 0,
  }) {
    int currentDepth = level + 1;

    for (int i = 0; i < columnGroupList.length; i += 1) {
      if (columnGroupList[i].hasChildren) {
        final int depth = maxDepth(
          columnGroupList: columnGroupList[i].children!,
          level: level + 1,
        );

        if (depth > currentDepth) {
          currentDepth = depth;
        }
      }
    }

    return currentDepth;
  }
}
