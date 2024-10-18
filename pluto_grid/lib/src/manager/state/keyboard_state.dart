import 'package:pluto_grid/pluto_grid.dart';

abstract class IKeyboardState {
  /// Currently pressed key
  PlutoGridKeyPressed get keyPressed;

  /// The index position of the cell to move in that direction in the current cell.
  PlutoGridCellPosition cellPositionToMove(
    PlutoGridCellPosition cellPosition,
    PlutoMoveDirection direction,
  );

  /// Change the current cell to the cell in the [direction] and move the scroll
  /// [force] true : Allow left and right movement with tab key in editing state.
  void moveCurrentCell(
    PlutoMoveDirection direction, {
    bool force = false,
    bool notify = true,
  });

  void moveCurrentCellToEdgeOfColumns(
    PlutoMoveDirection direction, {
    bool force = false,
    bool notify = true,
  });

  void moveCurrentCellToEdgeOfRows(
    PlutoMoveDirection direction, {
    bool force = false,
    bool notify = true,
  });

  void moveCurrentCellByRowIdx(
    int rowIdx,
    PlutoMoveDirection direction, {
    bool notify = true,
  });

  void moveSelectingCell(PlutoMoveDirection direction);

  void moveSelectingCellToEdgeOfColumns(
    PlutoMoveDirection direction, {
    bool force = false,
    bool notify = true,
  });

  void moveSelectingCellToEdgeOfRows(
    PlutoMoveDirection direction, {
    bool force = false,
    bool notify = true,
  });

  void moveSelectingCellByRowIdx(
    int rowIdx,
    PlutoMoveDirection direction, {
    bool notify = true,
  });
}

mixin KeyboardState implements IPlutoGridState {
  final PlutoGridKeyPressed _keyPressed = PlutoGridKeyPressed();

  @override
  PlutoGridKeyPressed get keyPressed => _keyPressed;

  @override
  PlutoGridCellPosition cellPositionToMove(
    PlutoGridCellPosition? cellPosition,
    PlutoMoveDirection direction,
  ) {
    final columnIndexes = columnIndexesByShowFrozen;

    switch (direction) {
      case PlutoMoveDirection.left:
        return PlutoGridCellPosition(
          columnIdx: columnIndexes[cellPosition!.columnIdx! - 1],
          rowIdx: cellPosition.rowIdx,
        );
      case PlutoMoveDirection.right:
        return PlutoGridCellPosition(
          columnIdx: columnIndexes[cellPosition!.columnIdx! + 1],
          rowIdx: cellPosition.rowIdx,
        );
      case PlutoMoveDirection.up:
        return PlutoGridCellPosition(
          columnIdx: columnIndexes[cellPosition!.columnIdx!],
          rowIdx: cellPosition.rowIdx! - 1,
        );
      case PlutoMoveDirection.down:
        return PlutoGridCellPosition(
          columnIdx: columnIndexes[cellPosition!.columnIdx!],
          rowIdx: cellPosition.rowIdx! + 1,
        );
    }
  }

  @override
  void moveCurrentCell(
    PlutoMoveDirection direction, {
    bool force = false,
    bool notify = true,
  }) {
    if (currentCell == null) return;

    // @formatter:off
    if (!force && isEditing && direction.horizontal) {
      // Select type column can be moved left or right even in edit state
      if (currentColumn?.type.isSelect == true) {
      }
      // Date type column can be moved left or right even in edit state
      else if (currentColumn?.type.isDate == true) {
      }
      // Time type column can be moved left or right even in edit state
      else if (currentColumn?.type.isTime == true) {
      }
      // Currency type column can be moved left or right even in edit state
      else if (currentColumn?.type.isCurrency == true) {
      }
      // Read only type column can be moved left or right even in edit state
      else if (currentColumn?.readOnly == true) {
      }
      // Unable to move left and right in other modified states
      else {
        return;
      }
    }
    // @formatter:on

    final cellPosition = currentCellPosition;

    if (cellPosition != null && canNotMoveCell(cellPosition, direction)) {
      eventManager!.addEvent(
        PlutoGridCannotMoveCurrentCellEvent(
          cellPosition: cellPosition,
          direction: direction,
        ),
      );

      return;
    }

    final toMove = cellPositionToMove(
      cellPosition,
      direction,
    );

    setCurrentCell(
      refRows[toMove.rowIdx!].cells[refColumns[toMove.columnIdx!].field],
      toMove.rowIdx,
      notify: notify,
    );

    if (direction.horizontal) {
      moveScrollByColumn(direction, cellPosition!.columnIdx);
    } else if (direction.vertical) {
      moveScrollByRow(direction, cellPosition!.rowIdx);
    }
    return;
  }

  @override
  void moveCurrentCellToEdgeOfColumns(
    PlutoMoveDirection direction, {
    bool force = false,
    bool notify = true,
  }) {
    if (!direction.horizontal) {
      return;
    }

    if (!force && isEditing == true) {
      return;
    }

    if (currentCell == null) {
      return;
    }

    final columnIndexes = columnIndexesByShowFrozen;

    final int columnIdx =
        direction.isLeft ? columnIndexes.first : columnIndexes.last;

    final column = refColumns[columnIdx];

    final cellToMove = currentRow!.cells[column.field];

    setCurrentCell(cellToMove, currentRowIdx, notify: notify);

    if (!showFrozenColumn || column.frozen.isFrozen != true) {
      direction.isLeft
          ? scroll.horizontal!.jumpTo(0)
          : scroll.horizontal!.jumpTo(scroll.maxScrollHorizontal);
    }
  }

  @override
  void moveCurrentCellToEdgeOfRows(
    PlutoMoveDirection direction, {
    bool force = false,
    bool notify = true,
  }) {
    if (!direction.vertical) {
      return;
    }

    if (!force && isEditing == true) {
      return;
    }

    final field = currentColumnField ?? columns.first.field;

    final int rowIdx = direction.isUp ? 0 : refRows.length - 1;

    final cellToMove = refRows[rowIdx].cells[field];

    setCurrentCell(cellToMove, rowIdx, notify: notify);

    direction.isUp
        ? scroll.vertical!.jumpTo(0)
        : scroll.vertical!.jumpTo(scroll.maxScrollVertical);
  }

  @override
  void moveCurrentCellByRowIdx(
    int rowIdx,
    PlutoMoveDirection direction, {
    bool notify = true,
  }) {
    if (!direction.vertical) {
      return;
    }

    if (rowIdx < 0) {
      rowIdx = 0;
    }

    if (rowIdx > refRows.length - 1) {
      rowIdx = refRows.length - 1;
    }

    final field = currentColumnField ?? refColumns.first.field;

    final cellToMove = refRows[rowIdx].cells[field];

    setCurrentCell(cellToMove, rowIdx, notify: notify);

    moveScrollByRow(direction, rowIdx - direction.offset);
  }

  @override
  void moveSelectingCell(PlutoMoveDirection direction) {
    final PlutoGridCellPosition? cellPosition =
        currentSelectingPosition ?? currentCellPosition;

    if (canNotMoveCell(cellPosition, direction)) {
      return;
    }

    setCurrentSelectingPosition(
      cellPosition: PlutoGridCellPosition(
        columnIdx: cellPosition!.columnIdx! +
            (direction.horizontal ? direction.offset : 0),
        rowIdx:
            cellPosition.rowIdx! + (direction.vertical ? direction.offset : 0),
      ),
    );

    if (direction.horizontal) {
      moveScrollByColumn(direction, cellPosition.columnIdx);
    } else {
      moveScrollByRow(direction, cellPosition.rowIdx);
    }
  }

  @override
  void moveSelectingCellToEdgeOfColumns(
    PlutoMoveDirection direction, {
    bool force = false,
    bool notify = true,
  }) {
    if (!direction.horizontal) {
      return;
    }

    if (!force && isEditing == true) {
      return;
    }

    if (currentCell == null) {
      return;
    }

    final int columnIdx = direction.isLeft ? 0 : refColumns.length - 1;

    final int? rowIdx = hasCurrentSelectingPosition
        ? currentSelectingPosition!.rowIdx
        : currentCellPosition!.rowIdx;

    setCurrentSelectingPosition(
      cellPosition: PlutoGridCellPosition(
        columnIdx: columnIdx,
        rowIdx: rowIdx,
      ),
      notify: notify,
    );

    direction.isLeft
        ? scroll.horizontal!.jumpTo(0)
        : scroll.horizontal!.jumpTo(scroll.maxScrollHorizontal);
  }

  @override
  void moveSelectingCellToEdgeOfRows(
    PlutoMoveDirection direction, {
    bool force = false,
    bool notify = true,
  }) {
    if (!direction.vertical) {
      return;
    }

    if (!force && isEditing == true) {
      return;
    }

    if (currentCell == null) {
      return;
    }

    final columnIdx = hasCurrentSelectingPosition
        ? currentSelectingPosition!.columnIdx
        : currentCellPosition!.columnIdx;

    final int rowIdx = direction.isUp ? 0 : refRows.length - 1;

    setCurrentSelectingPosition(
      cellPosition: PlutoGridCellPosition(
        columnIdx: columnIdx,
        rowIdx: rowIdx,
      ),
      notify: notify,
    );

    direction.isUp
        ? scroll.vertical!.jumpTo(0)
        : scroll.vertical!.jumpTo(scroll.maxScrollVertical);
  }

  @override
  void moveSelectingCellByRowIdx(
    int rowIdx,
    PlutoMoveDirection direction, {
    bool notify = true,
  }) {
    if (rowIdx < 0) {
      rowIdx = 0;
    }

    if (rowIdx > refRows.length - 1) {
      rowIdx = refRows.length - 1;
    }

    if (currentCell == null) {
      return;
    }

    int? columnIdx = hasCurrentSelectingPosition
        ? currentSelectingPosition!.columnIdx
        : currentCellPosition!.columnIdx;

    setCurrentSelectingPosition(
      cellPosition: PlutoGridCellPosition(
        columnIdx: columnIdx,
        rowIdx: rowIdx,
      ),
    );

    moveScrollByRow(direction, rowIdx - direction.offset);
  }
}
