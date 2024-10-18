import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

abstract class IDraggingRowState {
  bool get isDraggingRow;

  List<PlutoRow> get dragRows;

  int? get dragTargetRowIdx;

  bool get canRowDrag;

  void setIsDraggingRow(
    bool flag, {
    bool notify = true,
  });

  void setDragRows(
    List<PlutoRow> rows, {
    bool notify = true,
  });

  void setDragTargetRowIdx(
    int rowIdx, {
    bool notify = true,
  });

  bool isRowIdxDragTarget(int rowIdx);

  bool isRowIdxTopDragTarget(int rowIdx);

  bool isRowIdxBottomDragTarget(int rowIdx);

  bool isRowBeingDragged(Key rowKey);
}

class _State {
  bool _isDraggingRow = false;

  List<PlutoRow> _dragRows = [];

  int? _dragTargetRowIdx;
}

mixin DraggingRowState implements IPlutoGridState {
  final _State _state = _State();

  @override
  bool get isDraggingRow => _state._isDraggingRow;

  @override
  List<PlutoRow> get dragRows => _state._dragRows;

  @override
  int? get dragTargetRowIdx => _state._dragTargetRowIdx;

  @override
  bool get canRowDrag => !hasFilter && !hasSortedColumn && !enabledRowGroups;

  @override
  void setIsDraggingRow(
    bool flag, {
    bool notify = true,
  }) {
    if (isDraggingRow == flag) {
      return;
    }

    _state._isDraggingRow = flag;

    _clearDraggingState();

    notifyListeners(notify, setIsDraggingRow.hashCode);
  }

  @override
  void setDragRows(
    List<PlutoRow> rows, {
    bool notify = true,
  }) {
    _state._dragRows = rows;

    notifyListeners(notify, setDragRows.hashCode);
  }

  @override
  void setDragTargetRowIdx(
    int? rowIdx, {
    bool notify = true,
  }) {
    if (dragTargetRowIdx == rowIdx) {
      return;
    }

    _state._dragTargetRowIdx = rowIdx;

    notifyListeners(notify, setDragTargetRowIdx.hashCode);
  }

  @override
  bool isRowIdxDragTarget(int? rowIdx) {
    return rowIdx != null &&
        dragTargetRowIdx != null &&
        dragTargetRowIdx! <= rowIdx &&
        rowIdx < dragTargetRowIdx! + dragRows.length;
  }

  @override
  bool isRowIdxTopDragTarget(int? rowIdx) {
    return rowIdx != null &&
        dragTargetRowIdx != null &&
        dragTargetRowIdx == rowIdx &&
        rowIdx + dragRows.length <= refRows.length;
  }

  @override
  bool isRowIdxBottomDragTarget(int? rowIdx) {
    return rowIdx != null &&
        dragTargetRowIdx != null &&
        rowIdx == dragTargetRowIdx! + dragRows.length - 1;
  }

  @override
  bool isRowBeingDragged(Key? rowKey) {
    return rowKey != null &&
        isDraggingRow == true &&
        dragRows.firstWhereOrNull((element) => element.key == rowKey) != null;
  }

  void _clearDraggingState() {
    _state._dragRows = [];

    _state._dragTargetRowIdx = null;
  }
}
