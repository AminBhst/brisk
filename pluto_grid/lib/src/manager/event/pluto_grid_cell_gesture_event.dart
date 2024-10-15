import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

/// [PlutoCell] This event handles the gesture of the widget.
class PlutoGridCellGestureEvent extends PlutoGridEvent {
  final PlutoGridGestureType gestureType;
  final Offset offset;
  final PlutoCell cell;
  final PlutoColumn column;
  final int rowIdx;

  PlutoGridCellGestureEvent({
    required this.gestureType,
    required this.offset,
    required this.cell,
    required this.column,
    required this.rowIdx,
  });

  @override
  void handler(PlutoGridStateManager stateManager) {
    switch (gestureType) {
      case PlutoGridGestureType.onTapUp:
        _onTapUp(stateManager);
        break;
      case PlutoGridGestureType.onLongPressStart:
        _onLongPressStart(stateManager);
        break;
      case PlutoGridGestureType.onLongPressMoveUpdate:
        _onLongPressMoveUpdate(stateManager);
        break;
      case PlutoGridGestureType.onLongPressEnd:
        _onLongPressEnd(stateManager);
        break;
      case PlutoGridGestureType.onDoubleTap:
        _onDoubleTap(stateManager);
        break;
      case PlutoGridGestureType.onSecondaryTap:
        _onSecondaryTap(stateManager);
        break;
      default:
    }
  }

  void _onTapUp(PlutoGridStateManager stateManager) {
    if (_setKeepFocusAndCurrentCell(stateManager)) {
      return;
    } else if (stateManager.isSelectingInteraction()) {
      _selecting(stateManager);
      return;
    } else if (stateManager.mode.isSelectMode) {
      _selectMode(stateManager);
      return;
    }

    if (stateManager.isCurrentCell(cell) && stateManager.isEditing != true) {
      stateManager.setEditing(true);
    } else {
      stateManager.setCurrentCell(cell, rowIdx);
    }
  }

  void _onLongPressStart(PlutoGridStateManager stateManager) {
    _setCurrentCell(stateManager, cell, rowIdx);

    stateManager.setSelecting(true);

    if (stateManager.selectingMode.isRow) {
      stateManager.toggleSelectingRow(rowIdx);
    }
  }

  void _onLongPressMoveUpdate(PlutoGridStateManager stateManager) {
    _setCurrentCell(stateManager, cell, rowIdx);

    stateManager.setCurrentSelectingPositionWithOffset(offset);

    stateManager.eventManager!.addEvent(
      PlutoGridScrollUpdateEvent(offset: offset),
    );
  }

  void _onLongPressEnd(PlutoGridStateManager stateManager) {
    _setCurrentCell(stateManager, cell, rowIdx);

    stateManager.setSelecting(false);

    PlutoGridScrollUpdateEvent.stopScroll(
      stateManager,
      PlutoGridScrollUpdateDirection.all,
    );

    if (stateManager.mode.isMultiSelectMode) {
      stateManager.handleOnSelected();
    }
  }

  void _onDoubleTap(PlutoGridStateManager stateManager) {
    stateManager.onRowDoubleTap!(
      PlutoGridOnRowDoubleTapEvent(
        row: stateManager.getRowByIdx(rowIdx)!,
        rowIdx: rowIdx,
        cell: cell,
      ),
    );
  }

  void _onSecondaryTap(PlutoGridStateManager stateManager) {
    stateManager.onRowSecondaryTap!(
      PlutoGridOnRowSecondaryTapEvent(
        row: stateManager.getRowByIdx(rowIdx)!,
        rowIdx: rowIdx,
        cell: cell,
        offset: offset,
      ),
    );
  }

  bool _setKeepFocusAndCurrentCell(PlutoGridStateManager stateManager) {
    if (stateManager.hasFocus) {
      return false;
    }

    stateManager.setKeepFocus(true);

    return stateManager.isCurrentCell(cell);
  }

  void _selecting(PlutoGridStateManager stateManager) {
    bool callOnSelected = stateManager.mode.isMultiSelectMode;

    if (stateManager.keyPressed.shift) {
      final int? columnIdx = stateManager.columnIndex(column);

      stateManager.setCurrentSelectingPosition(
        cellPosition: PlutoGridCellPosition(
          columnIdx: columnIdx,
          rowIdx: rowIdx,
        ),
      );
    } else if (stateManager.keyPressed.ctrl) {
      stateManager.toggleSelectingRow(rowIdx);
    } else {
      callOnSelected = false;
    }

    if (callOnSelected) {
      stateManager.handleOnSelected();
    }
  }

  void _selectMode(PlutoGridStateManager stateManager) {
    switch (stateManager.mode) {
      case PlutoGridMode.normal:
      case PlutoGridMode.readOnly:
      case PlutoGridMode.popup:
        return;
      case PlutoGridMode.select:
      case PlutoGridMode.selectWithOneTap:
        if (stateManager.isCurrentCell(cell) == false) {
          stateManager.setCurrentCell(cell, rowIdx);

          if (!stateManager.mode.isSelectWithOneTap) {
            return;
          }
        }
        break;
      case PlutoGridMode.multiSelect:
        stateManager.toggleSelectingRow(rowIdx);
        break;
    }

    stateManager.handleOnSelected();
  }

  void _setCurrentCell(
    PlutoGridStateManager stateManager,
    PlutoCell? cell,
    int? rowIdx,
  ) {
    if (stateManager.isCurrentCell(cell) != true) {
      stateManager.setCurrentCell(cell, rowIdx, notify: false);
    }
  }
}

enum PlutoGridGestureType {
  onTapUp,
  onLongPressStart,
  onLongPressMoveUpdate,
  onLongPressEnd,
  onDoubleTap,
  onSecondaryTap;

  bool get isOnTapUp => this == PlutoGridGestureType.onTapUp;

  bool get isOnLongPressStart => this == PlutoGridGestureType.onLongPressStart;

  bool get isOnLongPressMoveUpdate =>
      this == PlutoGridGestureType.onLongPressMoveUpdate;

  bool get isOnLongPressEnd => this == PlutoGridGestureType.onLongPressEnd;

  bool get isOnDoubleTap => this == PlutoGridGestureType.onDoubleTap;

  bool get isOnSecondaryTap => this == PlutoGridGestureType.onSecondaryTap;
}
