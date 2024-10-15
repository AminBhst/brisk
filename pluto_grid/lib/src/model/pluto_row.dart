import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

class PlutoRow {
  PlutoRow({
    required this.cells,
    PlutoRowType? type,
    this.sortIdx = 0,
    bool checked = false,
    Key? key,
  })  : type = type ?? PlutoRowTypeNormal.instance,
        _checked = checked,
        _state = PlutoRowState.none,
        _key = key ?? UniqueKey();

  final PlutoRowType type;

  final Key _key;

  Map<String, PlutoCell> cells;

  /// Value to maintain the default sort order when sorting columns.
  /// If there is no value, it is automatically set when loading the grid.
  int sortIdx;

  bool? _checked;

  PlutoRow? _parent;

  PlutoRowState _state;

  Key get key => _key;

  bool get initialized {
    if (cells.isEmpty) {
      return true;
    }

    return cells.values.first.initialized;
  }

  /// If [PlutoRow] is included as a child of a group row,
  /// [parent] is the parent's reference.
  PlutoRow? get parent => _parent;

  /// Returns the depth if [PlutoRow] is a child of a group row.
  int get depth {
    int depth = 0;
    var current = parent;
    while (current != null) {
      depth += 1;
      current = current.parent;
    }
    return depth;
  }

  /// Returns whether [PlutoRow] is the top position.
  bool get isMain => parent == null;

  /// The state value that the checkbox is checked.
  /// If the enableRowChecked value of the [PlutoColumn] property is set to true,
  /// a check box appears in the cell of the corresponding column.
  /// To manually change the values at runtime,
  /// use the PlutoStateManager.setRowChecked
  /// or PlutoStateManager.toggleAllRowChecked methods.
  bool? get checked {
    return type.isGroup ? _tristateCheckedRow : _checked;
  }

  bool? get _tristateCheckedRow {
    if (!type.isGroup) return false;

    final children = type.group.children;

    final length = children.length;

    if (length == 0) return _checked;

    int countTrue = 0;

    int countFalse = 0;

    int countTristate = 0;

    for (var i = 0; i < length; i += 1) {
      if (children[i].type.isGroup) {
        switch (children[i]._tristateCheckedRow) {
          case true:
            ++countTrue;
            break;
          case false:
            ++countFalse;
            break;
          case null:
            ++countTristate;
            break;
        }
      } else {
        children[i].checked == true ? ++countTrue : ++countFalse;
      }

      if ((countTrue > 0 && countFalse > 0) || countTristate > 0) return null;
    }

    return countTrue == length;
  }

  /// State when a new row is added or the cell value in the row is changed.
  ///
  /// Keeps the row from disappearing when changing the cell value
  /// to a value other than the filtering condition while column filtering is applied.
  /// When the value of a cell is changed,
  /// the [state] value of the changed row is changed to [PlutoRowState.updated],
  /// and in this case, even if the filtering condition is not
  /// Make sure it stays in the list unless you change the filtering again.
  PlutoRowState get state => _state;

  void setParent(PlutoRow? row) {
    _parent = row;
  }

  void setChecked(bool? flag) {
    _checked = flag;
    if (type.isGroup) {
      for (final child in type.group.children) {
        child.setChecked(flag);
      }
    }
  }

  void setState(PlutoRowState state) {
    _state = state;
  }

  /// Create PlutoRow in json type.
  /// The key of the json you want to generate must match the key of [PlutoColumn].
  ///
  /// ```dart
  /// final json = {
  ///   'column1': 'value1',
  ///   'column2': 'value2',
  ///   'column3': 'value3',
  /// };
  ///
  /// final row = PlutoRow.fromJson(json);
  /// ```
  ///
  /// If you want to create a group row with children, you need to pass [childrenField] .
  ///
  /// ```dart
  /// // Example when the child row field is children
  /// final json = {
  ///   'column1': 'group value1',
  ///   'column2': 'group value2',
  ///   'column3': 'group value3',
  ///   'children': [
  ///     {
  ///       'column1': 'child1 value1',
  ///       'column2': 'child1 value2',
  ///       'column3': 'child1 value3',
  ///     },
  ///     {
  ///       'column1': 'child2 value1',
  ///       'column2': 'child2 value2',
  ///       'column3': 'child2 value3',
  ///     },
  ///   ],
  /// };
  ///
  /// final rowGroup = PlutoRow.fromJson(json, childrenField: 'children');
  /// ```
  factory PlutoRow.fromJson(
    Map<String, dynamic> json, {
    String? childrenField,
  }) {
    final Map<String, PlutoCell> cells = {};

    final bool hasChildren =
        childrenField != null && json.containsKey(childrenField);

    final entries = hasChildren
        ? json.entries.where((e) => e.key != childrenField)
        : json.entries;

    assert(!hasChildren || json.length - 1 == entries.length);

    for (final item in entries) {
      cells[item.key] = PlutoCell(value: item.value);
    }

    PlutoRowType? type;

    if (hasChildren) {
      assert(json[childrenField] is List<Map<String, dynamic>>);

      final children = <PlutoRow>[];

      for (final child in json[childrenField]) {
        children.add(PlutoRow.fromJson(child, childrenField: childrenField));
      }

      type = PlutoRowType.group(children: FilteredList(initialList: children));
    }

    return PlutoRow(cells: cells, type: type);
  }

  /// Convert the row to json type.
  ///
  /// ```dart
  /// // Assuming you have a line like below.
  /// final PlutoRow row = PlutoRow(cells: {
  ///   'column1': PlutoCell(value: 'value1'),
  ///   'column2': PlutoCell(value: 'value2'),
  ///   'column3': PlutoCell(value: 'value3'),
  /// });
  ///
  /// final json = row.toJson();
  /// // toJson is returned as below.
  /// // {
  /// //   'column1': 'value1',
  /// //   'column2': 'value2',
  /// //   'column3': 'value3',
  /// // }
  /// ```
  ///
  /// In case of group row, [includeChildren] is true (default)
  /// If [childrenField] is set to 'children' (default), the following is returned.
  ///
  /// ```dart
  /// // Assuming you have rows grouped by 1 depth.
  /// final PlutoRow row = PlutoRow(
  ///   cells: {
  ///     'column1': PlutoCell(value: 'group value1'),
  ///     'column2': PlutoCell(value: 'group value2'),
  ///     'column3': PlutoCell(value: 'group value3'),
  ///   },
  ///   type: PlutoRowType.group(
  ///     children: FilteredList(initialList: [
  ///       PlutoRow(
  ///         cells: {
  ///           'column1': PlutoCell(value: 'child1 value1'),
  ///           'column2': PlutoCell(value: 'child1 value2'),
  ///           'column3': PlutoCell(value: 'child1 value3'),
  ///         },
  ///       ),
  ///       PlutoRow(
  ///         cells: {
  ///           'column1': PlutoCell(value: 'child2 value1'),
  ///           'column2': PlutoCell(value: 'child2 value2'),
  ///           'column3': PlutoCell(value: 'child2 value3'),
  ///         },
  ///       ),
  ///     ]),
  ///   ),
  /// );
  ///
  /// final json = row.toJson();
  /// // It is returned in the following format.
  /// // {
  /// //   'column1': 'group value1',
  /// //   'column2': 'group value2',
  /// //   'column3': 'group value3',
  /// //   'children': [
  /// //     {
  /// //       'column1': 'child1 value1',
  /// //       'column2': 'child1 value2',
  /// //       'column3': 'child1 value3',
  /// //     },
  /// //     {
  /// //       'column1': 'child2 value1',
  /// //       'column2': 'child2 value2',
  /// //       'column3': 'child2 value3',
  /// //     },
  /// //   ],
  /// // }
  /// ```
  Map<String, dynamic> toJson({
    bool includeChildren = true,
    String childrenField = 'children',
  }) {
    final json = cells.map((key, value) => MapEntry(key, value.value));

    if (!includeChildren || !type.isGroup) return json;

    final List<Map<String, dynamic>> children = type.group.children
        .map(
          (e) => e.toJson(childrenField: childrenField),
        )
        .toList();

    json[childrenField] = children;

    return json;
  }
}

enum PlutoRowState {
  none,
  added,
  updated;

  bool get isNone => this == PlutoRowState.none;

  bool get isAdded => this == PlutoRowState.added;

  bool get isUpdated => this == PlutoRowState.updated;
}
