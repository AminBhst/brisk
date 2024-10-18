import 'package:flutter/services.dart';
import 'package:pluto_grid/pluto_grid.dart';

/// Define the action by implementing the [execute] method
/// as an action that can be mapped to a shortcut key.
///
/// User-defined behavior other than the default implemented class
/// can be implemented by extending this class.
///
/// [PlutoGridActionMoveCellFocus]
/// {@macro pluto_grid_action_move_cell_focus}
///
/// [PlutoGridActionMoveSelectedCellFocus]
/// {@macro pluto_grid_action_move_selected_cell_focus}
///
/// [PlutoGridActionMoveCellFocusByPage]
/// {@macro pluto_grid_action_move_cell_focus_by_page}
///
/// [PlutoGridActionMoveSelectedCellFocusByPage]
/// {@macro pluto_grid_action_move_selected_cell_focus_by_page}
///
/// [PlutoGridActionDefaultTab]
/// {@macro pluto_grid_action_default_tab}
///
/// [PlutoGridActionDefaultEnterKey]
/// {@macro pluto_grid_action_default_enter_key}
///
/// [PlutoGridActionDefaultEscapeKey]
/// {@macro pluto_grid_action_default_escape_key}
///
/// [PlutoGridActionMoveCellFocusToEdge]
/// {@macro pluto_grid_action_move_cell_focus_to_edge}
///
/// [PlutoGridActionMoveSelectedCellFocusToEdge]
/// {@macro pluto_grid_action_move_selected_cell_focus_to_edge}
///
/// [PlutoGridActionSetEditing]
/// {@macro pluto_grid_action_set_editing}
///
/// [PlutoGridActionFocusToColumnFilter]
/// {@macro pluto_grid_action_focus_to_column_filter}
///
/// [PlutoGridActionToggleColumnSort]
/// {@macro pluto_grid_action_toggle_column_sort}
///
/// [PlutoGridActionCopyValues]
/// {@macro pluto_grid_action_copy_values}
///
/// [PlutoGridActionPasteValues]
/// {@macro pluto_grid_action_paste_values}
///
/// [PlutoGridActionSelectAll]
/// {@macro pluto_grid_action_select_all}
abstract class PlutoGridShortcutAction {
  const PlutoGridShortcutAction();

  /// Implement actions to be mapped to shortcut keys.
  void execute({
    required PlutoKeyManagerEvent keyEvent,
    required PlutoGridStateManager stateManager,
  });
}

/// {@template pluto_grid_action_move_cell_focus}
/// Move the current cell focus in the [direction] direction.
///
/// If the current cell is not selected, focus the first cell.
///
/// If [PlutoGridConfiguration.enableMoveHorizontalInEditing] is true,
/// Moves to the previous or next cell when the text cursor reaches the left or right edge
/// while the cell is in edit state.
/// {@endtemplate}
class PlutoGridActionMoveCellFocus extends PlutoGridShortcutAction {
  const PlutoGridActionMoveCellFocus(this.direction);

  final PlutoMoveDirection direction;

  @override
  void execute({
    required PlutoKeyManagerEvent keyEvent,
    required PlutoGridStateManager stateManager,
  }) {
    bool force = keyEvent.isHorizontal &&
        stateManager.configuration.enableMoveHorizontalInEditing == true;

    if (stateManager.currentCell == null) {
      stateManager.setCurrentCell(stateManager.firstCell, 0);
      return;
    }

    stateManager.moveCurrentCell(direction, force: force);
  }
}

/// {@template pluto_grid_action_move_selected_cell_focus}
/// Moves the selected focus in the [direction] direction in the cell or row selection state.
/// {@endtemplate}
class PlutoGridActionMoveSelectedCellFocus extends PlutoGridShortcutAction {
  const PlutoGridActionMoveSelectedCellFocus(this.direction);

  final PlutoMoveDirection direction;

  @override
  void execute({
    required PlutoKeyManagerEvent keyEvent,
    required PlutoGridStateManager stateManager,
  }) {
    if (stateManager.isEditing == true) return;

    stateManager.moveSelectingCell(direction);
  }
}

/// {@template pluto_grid_action_move_cell_focus_by_page}
/// Move the focus of the current cell page by page.
///
/// If [direction] is up or down, it moves in the vertical direction on the current page.
///
/// If [direction] is left or right, the page moves when pagination is enabled.
/// If pagination is not enabled, no action is taken.
/// {@endtemplate}
class PlutoGridActionMoveCellFocusByPage extends PlutoGridShortcutAction {
  const PlutoGridActionMoveCellFocusByPage(this.direction);

  final PlutoMoveDirection direction;

  @override
  void execute({
    required PlutoKeyManagerEvent keyEvent,
    required PlutoGridStateManager stateManager,
  }) {
    switch (direction) {
      case PlutoMoveDirection.left:
      case PlutoMoveDirection.right:
        if (!stateManager.isPaginated) return;

        final currentColumn = stateManager.currentColumn;

        final previousPosition = stateManager.currentCellPosition;

        int toPage =
            direction.isLeft ? stateManager.page - 1 : stateManager.page + 1;

        if (toPage < 1) {
          toPage = 1;
        } else if (toPage > stateManager.totalPage) {
          toPage = stateManager.totalPage;
        }

        stateManager.setPage(toPage);

        _restoreCurrentCellPosition(
          stateManager: stateManager,
          currentColumn: currentColumn,
          previousPosition: previousPosition,
        );

        break;
      case PlutoMoveDirection.up:
      case PlutoMoveDirection.down:
        final int moveCount =
            (stateManager.rowContainerHeight / stateManager.rowTotalHeight)
                .floor();

        int rowIdx = stateManager.currentRowIdx!;

        rowIdx += direction.isUp ? -moveCount : moveCount;

        stateManager.moveCurrentCellByRowIdx(rowIdx, direction);

        break;
    }
  }

  void _restoreCurrentCellPosition({
    required PlutoGridStateManager stateManager,
    PlutoColumn? currentColumn,
    PlutoGridCellPosition? previousPosition,
  }) {
    if (currentColumn == null || previousPosition?.hasPosition != true) {
      return;
    }

    int rowIdx = previousPosition!.rowIdx!;

    if (rowIdx > stateManager.refRows.length - 1) {
      rowIdx = stateManager.refRows.length - 1;
    }

    stateManager.setCurrentCell(
      stateManager.refRows.elementAt(rowIdx).cells[currentColumn.field],
      rowIdx,
    );
  }
}

/// {@template pluto_grid_action_move_selected_cell_focus_by_page}
/// Moves the selection position page by page in cell or row selection mode.
///
/// When [direction] is left or right, no action is taken.
/// {@endtemplate}
class PlutoGridActionMoveSelectedCellFocusByPage
    extends PlutoGridShortcutAction {
  const PlutoGridActionMoveSelectedCellFocusByPage(this.direction);

  final PlutoMoveDirection direction;

  @override
  void execute({
    required PlutoKeyManagerEvent keyEvent,
    required PlutoGridStateManager stateManager,
  }) {
    if (direction.horizontal) return;

    final int moveCount =
        (stateManager.rowContainerHeight / stateManager.rowTotalHeight).floor();

    int rowIdx = stateManager.currentSelectingPosition?.rowIdx ??
        stateManager.currentCellPosition?.rowIdx ??
        0;

    rowIdx += direction.isUp ? -moveCount : moveCount;

    stateManager.moveSelectingCellByRowIdx(rowIdx, direction);
  }
}

/// {@template pluto_grid_action_default_tab}
/// This is the action in which the default action of the tab key is set.
///
/// If there is no currently focused cell, focus the first cell.
///
/// Move the focus to the previous or next cell with the shift key combination.
///
/// If [PlutoGridConfiguration.tabKeyAction] is moveToNextOnEdge ,
/// continue moving focus to the next or previous row when focus reaches the end.
/// {@endtemplate}
class PlutoGridActionDefaultTab extends PlutoGridShortcutAction {
  const PlutoGridActionDefaultTab();

  @override
  void execute({
    required PlutoKeyManagerEvent keyEvent,
    required PlutoGridStateManager stateManager,
  }) {
    if (stateManager.currentCell == null) {
      stateManager.setCurrentCell(stateManager.firstCell, 0);
      return;
    }

    final saveIsEditing = stateManager.isEditing;

    keyEvent.event.isShiftPressed
        ? _moveCellPrevious(stateManager)
        : _moveCellNext(stateManager);

    stateManager.setEditing(stateManager.autoEditing || saveIsEditing);
  }

  void _moveCellPrevious(PlutoGridStateManager stateManager) {
    if (_willMoveToPreviousRow(
        stateManager.currentCellPosition, stateManager)) {
      _moveCellToPreviousRow(stateManager);
    } else {
      stateManager.moveCurrentCell(PlutoMoveDirection.left, force: true);
    }
  }

  void _moveCellNext(PlutoGridStateManager stateManager) {
    if (_willMoveToNextRow(stateManager.currentCellPosition, stateManager)) {
      _moveCellToNextRow(stateManager);
    } else {
      stateManager.moveCurrentCell(PlutoMoveDirection.right, force: true);
    }
  }

  bool _willMoveToPreviousRow(
    PlutoGridCellPosition? position,
    PlutoGridStateManager stateManager,
  ) {
    if (!stateManager.configuration.tabKeyAction.isMoveToNextOnEdge ||
        position == null ||
        !position.hasPosition) {
      return false;
    }

    return position.rowIdx! > 0 && position.columnIdx == 0;
  }

  bool _willMoveToNextRow(
    PlutoGridCellPosition? position,
    PlutoGridStateManager stateManager,
  ) {
    if (!stateManager.configuration.tabKeyAction.isMoveToNextOnEdge ||
        position == null ||
        !position.hasPosition) {
      return false;
    }

    return position.rowIdx! < stateManager.refRows.length - 1 &&
        position.columnIdx == stateManager.refColumns.length - 1;
  }

  void _moveCellToPreviousRow(PlutoGridStateManager stateManager) {
    stateManager.moveCurrentCell(
      PlutoMoveDirection.up,
      force: true,
      notify: false,
    );

    stateManager.moveCurrentCellToEdgeOfColumns(
      PlutoMoveDirection.right,
      force: true,
    );
  }

  void _moveCellToNextRow(PlutoGridStateManager stateManager) {
    stateManager.moveCurrentCell(
      PlutoMoveDirection.down,
      force: true,
      notify: false,
    );

    stateManager.moveCurrentCellToEdgeOfColumns(
      PlutoMoveDirection.left,
      force: true,
    );
  }
}

/// {@template pluto_grid_action_default_enter_key}
/// This action is the default action of the Enter key.
///
/// If [PlutoGrid.mode] is in selection mode,
/// the [PlutoGrid.onSelected] callback that returns information
/// of the currently selected row is called.
///
/// Otherwise, it behaves according to [PlutoGridConfiguration.enterKeyAction].
/// {@endtemplate}
class PlutoGridActionDefaultEnterKey extends PlutoGridShortcutAction {
  const PlutoGridActionDefaultEnterKey();

  @override
  void execute({
    required PlutoKeyManagerEvent keyEvent,
    required PlutoGridStateManager stateManager,
  }) {
    // In SelectRow mode, the current Row is passed to the onSelected callback.
    if (stateManager.mode.isSelectMode && stateManager.onSelected != null) {
      stateManager.onSelected!(PlutoGridOnSelectedEvent(
        row: stateManager.currentRow,
        rowIdx: stateManager.currentRowIdx,
        cell: stateManager.currentCell,
        selectedRows: stateManager.mode.isMultiSelectMode
            ? stateManager.currentSelectingRows
            : null,
      ));
      return;
    }

    if (stateManager.configuration.enterKeyAction.isNone) {
      return;
    }

    if (!stateManager.isEditing && _isExpandableCell(stateManager)) {
      stateManager.toggleExpandedRowGroup(rowGroup: stateManager.currentRow!);
      return;
    }

    if (stateManager.configuration.enterKeyAction.isToggleEditing) {
      stateManager.toggleEditing(notify: false);
    } else {
      if (stateManager.isEditing == true ||
          stateManager.currentColumn?.enableEditingMode == false) {
        final saveIsEditing = stateManager.isEditing;

        _moveCell(keyEvent, stateManager);

        stateManager.setEditing(saveIsEditing, notify: false);
      } else {
        stateManager.toggleEditing(notify: false);
      }
    }

    if (stateManager.autoEditing) {
      stateManager.setEditing(true, notify: false);
    }

    stateManager.notifyListeners();
  }

  bool _isExpandableCell(PlutoGridStateManager stateManager) {
    return stateManager.currentCell != null &&
        stateManager.enabledRowGroups &&
        stateManager.rowGroupDelegate
                ?.isExpandableCell(stateManager.currentCell!) ==
            true;
  }

  void _moveCell(
    PlutoKeyManagerEvent keyEvent,
    PlutoGridStateManager stateManager,
  ) {
    final enterKeyAction = stateManager.configuration.enterKeyAction;

    if (enterKeyAction.isNone) {
      return;
    }

    if (enterKeyAction.isEditingAndMoveDown) {
      if (keyEvent.event.isShiftPressed) {
        stateManager.moveCurrentCell(
          PlutoMoveDirection.up,
          notify: false,
        );
      } else {
        stateManager.moveCurrentCell(
          PlutoMoveDirection.down,
          notify: false,
        );
      }
    } else if (enterKeyAction.isEditingAndMoveRight) {
      if (keyEvent.event.isShiftPressed) {
        stateManager.moveCurrentCell(
          PlutoMoveDirection.left,
          force: true,
          notify: false,
        );
      } else {
        stateManager.moveCurrentCell(
          PlutoMoveDirection.right,
          force: true,
          notify: false,
        );
      }
    }
  }
}

/// {@template pluto_grid_action_default_escape_key}
/// This is the action in which the default behavior of the Escape key is set.
///
/// If [PlutoGridMode] is in selection or popup mode,
/// call the [PlutoGrid.onSelected] callback,
/// which returns a [PlutoGridOnSelectedEvent] with a null value meaning unselected.
///
/// In other cases, it cancels the currently edited cell.
/// {@endtemplate}
class PlutoGridActionDefaultEscapeKey extends PlutoGridShortcutAction {
  const PlutoGridActionDefaultEscapeKey();

  @override
  void execute({
    required PlutoKeyManagerEvent keyEvent,
    required PlutoGridStateManager stateManager,
  }) {
    if (stateManager.mode.isSelectMode ||
        (stateManager.mode.isPopup && !stateManager.isEditing)) {
      if (stateManager.onSelected != null) {
        stateManager.clearCurrentSelecting();
        stateManager.onSelected!(const PlutoGridOnSelectedEvent());
      }
      return;
    }

    if (stateManager.isEditing) {
      stateManager.setEditing(false);
    }
  }
}

/// {@template pluto_grid_action_move_cell_focus_to_edge}
/// Move the focus of the current cell to the end of the [direction] direction.
/// {@endtemplate}
class PlutoGridActionMoveCellFocusToEdge extends PlutoGridShortcutAction {
  const PlutoGridActionMoveCellFocusToEdge(this.direction);

  final PlutoMoveDirection direction;

  @override
  void execute({
    required PlutoKeyManagerEvent keyEvent,
    required PlutoGridStateManager stateManager,
  }) {
    switch (direction) {
      case PlutoMoveDirection.left:
      case PlutoMoveDirection.right:
        stateManager.moveCurrentCellToEdgeOfColumns(direction);
        break;
      case PlutoMoveDirection.up:
      case PlutoMoveDirection.down:
        stateManager.moveCurrentCellToEdgeOfRows(direction);
        break;
    }
  }
}

/// {@template pluto_grid_action_move_selected_cell_focus_to_edge}
/// Moves the selected focus to the end of the [direction] direction
/// in the cell or row selection state.
/// {@endtemplate}
class PlutoGridActionMoveSelectedCellFocusToEdge
    extends PlutoGridShortcutAction {
  const PlutoGridActionMoveSelectedCellFocusToEdge(this.direction);

  final PlutoMoveDirection direction;

  @override
  void execute({
    required PlutoKeyManagerEvent keyEvent,
    required PlutoGridStateManager stateManager,
  }) {
    switch (direction) {
      case PlutoMoveDirection.left:
      case PlutoMoveDirection.right:
        stateManager.moveSelectingCellToEdgeOfColumns(direction);
        break;
      case PlutoMoveDirection.up:
      case PlutoMoveDirection.down:
        stateManager.moveSelectingCellToEdgeOfRows(direction);
        break;
    }
  }
}

/// {@template pluto_grid_action_set_editing}
/// Set the current cell to edit state.
/// {@endtemplate}
class PlutoGridActionSetEditing extends PlutoGridShortcutAction {
  const PlutoGridActionSetEditing();

  @override
  void execute({
    required PlutoKeyManagerEvent keyEvent,
    required PlutoGridStateManager stateManager,
  }) {
    if (stateManager.isEditing) return;

    stateManager.setEditing(true);
  }
}

/// {@template pluto_grid_action_focus_to_column_filter}
/// Move the focus from the current cell position
/// to the filtering TextField of the corresponding column.
/// {@endtemplate}
class PlutoGridActionFocusToColumnFilter extends PlutoGridShortcutAction {
  const PlutoGridActionFocusToColumnFilter();

  @override
  void execute({
    required PlutoKeyManagerEvent keyEvent,
    required PlutoGridStateManager stateManager,
  }) {
    final currentColumn = stateManager.currentColumn;

    if (currentColumn == null) return;

    if (!stateManager.showColumnFilter) return;

    if (currentColumn.filterFocusNode?.canRequestFocus == true) {
      currentColumn.filterFocusNode?.requestFocus();

      stateManager.setKeepFocus(false);
    }
  }
}

/// {@template pluto_grid_action_toggle_column_sort}
/// Toggles the sort state of the column.
/// {@endtemplate}
class PlutoGridActionToggleColumnSort extends PlutoGridShortcutAction {
  const PlutoGridActionToggleColumnSort();

  @override
  void execute({
    required PlutoKeyManagerEvent keyEvent,
    required PlutoGridStateManager stateManager,
  }) {
    final currentColumn = stateManager.currentColumn;

    if (currentColumn == null || !currentColumn.enableSorting) return;

    final previousPosition = stateManager.currentCellPosition;

    stateManager.toggleSortColumn(currentColumn);

    _restoreCurrentCellPosition(
      stateManager: stateManager,
      currentColumn: currentColumn,
      previousPosition: previousPosition,
      ignore: stateManager.sortOnlyEvent,
    );
  }

  void _restoreCurrentCellPosition({
    required PlutoGridStateManager stateManager,
    PlutoColumn? currentColumn,
    PlutoGridCellPosition? previousPosition,
    bool ignore = false,
  }) {
    if (ignore ||
        currentColumn == null ||
        previousPosition?.hasPosition != true) {
      return;
    }

    int rowIdx = previousPosition!.rowIdx!;

    if (rowIdx > stateManager.refRows.length - 1) {
      rowIdx = stateManager.refRows.length - 1;
    }

    stateManager.setCurrentCell(
      stateManager.refRows.elementAt(rowIdx).cells[currentColumn.field],
      rowIdx,
    );
  }
}

/// {@template pluto_grid_action_copy_values}
/// Copies the value of the current cell or the selected cell or row to the clipboard.
/// {@endtemplate}
class PlutoGridActionCopyValues extends PlutoGridShortcutAction {
  const PlutoGridActionCopyValues();

  @override
  void execute({
    required PlutoKeyManagerEvent keyEvent,
    required PlutoGridStateManager stateManager,
  }) {
    if (stateManager.isEditing == true) {
      return;
    }

    Clipboard.setData(ClipboardData(text: stateManager.currentSelectingText));
  }
}

/// {@template pluto_grid_action_paste_values}
/// Pastes the copied values to the clipboard
/// depending on the position of the current cell or row.
/// {@endtemplate}
class PlutoGridActionPasteValues extends PlutoGridShortcutAction {
  const PlutoGridActionPasteValues();

  @override
  void execute({
    required PlutoKeyManagerEvent keyEvent,
    required PlutoGridStateManager stateManager,
  }) {
    if (stateManager.currentCell == null) {
      return;
    }

    if (stateManager.isEditing == true) {
      return;
    }

    Clipboard.getData('text/plain').then((value) {
      List<List<String>> textList =
          PlutoClipboardTransformation.stringToList(value!.text!);

      stateManager.pasteCellValue(textList);
    });
  }
}

/// {@template pluto_grid_action_select_all}
/// Select all cells or rows.
/// {@endtemplate}
class PlutoGridActionSelectAll extends PlutoGridShortcutAction {
  const PlutoGridActionSelectAll();

  @override
  void execute({
    required PlutoKeyManagerEvent keyEvent,
    required PlutoGridStateManager stateManager,
  }) {
    if (stateManager.isEditing == true) {
      return;
    }

    stateManager.setAllCurrentSelecting();
  }
}
