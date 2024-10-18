import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../ui.dart';

typedef DragUpdatedCallback = Function(Offset offset);

class PlutoDefaultCell extends PlutoStatefulWidget {
  final PlutoCell cell;

  final PlutoColumn column;

  final int rowIdx;

  final PlutoRow row;

  final PlutoGridStateManager stateManager;

  const PlutoDefaultCell({
    required this.cell,
    required this.column,
    required this.rowIdx,
    required this.row,
    required this.stateManager,
    Key? key,
  }) : super(key: key);

  @override
  State<PlutoDefaultCell> createState() => _PlutoDefaultCellState();
}

class _PlutoDefaultCellState extends PlutoStateWithChange<PlutoDefaultCell> {
  bool _hasFocus = false;

  bool _canRowDrag = false;

  bool _isCurrentCell = false;

  String _text = '';

  @override
  PlutoGridStateManager get stateManager => widget.stateManager;

  bool get _canExpand {
    if (!widget.row.type.isGroup || !stateManager.enabledRowGroups) {
      return false;
    }

    return _isExpandableCell;
  }

  bool get _isExpandableCell =>
      stateManager.rowGroupDelegate!.isExpandableCell(widget.cell);

  bool get _showSpacing {
    if (!stateManager.enabledRowGroups ||
        !stateManager.rowGroupDelegate!.showFirstExpandableIcon) {
      return false;
    }

    if (_canExpand) return true;

    final parentCell = widget.row.parent?.cells[widget.column.field];

    return parentCell != null &&
        stateManager.rowGroupDelegate!.isExpandableCell(parentCell);
  }

  bool get _isEmptyGroup => widget.row.type.group.children.isEmpty;

  bool get _showGroupCount =>
      stateManager.enabledRowGroups &&
      _isExpandableCell &&
      widget.row.type.isGroup &&
      stateManager.rowGroupDelegate!.showCount;

  String get _groupCount => _compactCount
      ? stateManager.rowGroupDelegate!
          .compactNumber(widget.row.type.group.children.length)
      : widget.row.type.group.children.length.toString();

  bool get _compactCount => stateManager.rowGroupDelegate!.enableCompactCount;

  @override
  void initState() {
    super.initState();

    updateState(PlutoNotifierEventForceUpdate.instance);
  }

  @override
  void updateState(PlutoNotifierEvent event) {
    _hasFocus = update<bool>(
      _hasFocus,
      stateManager.hasFocus,
    );

    _canRowDrag = update<bool>(
      _canRowDrag,
      widget.column.enableRowDrag && stateManager.canRowDrag,
    );

    _isCurrentCell = update<bool>(
      _isCurrentCell,
      stateManager.isCurrentCell(widget.cell),
    );

    _text = update<String>(
      _text,
      widget.column.formattedValueForDisplay(widget.cell.value),
    );
  }

  void _handleToggleExpandedRowGroup() {
    stateManager.toggleExpandedRowGroup(
      rowGroup: widget.row,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cellWidget = _DefaultCellWidget(
      stateManager: stateManager,
      rowIdx: widget.rowIdx,
      row: widget.row,
      column: widget.column,
      cell: widget.cell,
    );

    final style = stateManager.configuration.style;

    Widget? spacingWidget;
    if (_showSpacing) {
      if (widget.row.depth > 0) {
        double gap = style.iconSize * 1.5;
        double spacing = widget.row.depth * gap;
        if (!widget.row.type.isGroup) spacing += gap;
        spacingWidget = SizedBox(width: spacing);
      }
    }

    Widget? expandIcon;
    if (_canExpand) {
      expandIcon = IconButton(
        onPressed: _isEmptyGroup ? null : _handleToggleExpandedRowGroup,
        icon: _isEmptyGroup
            ? Icon(
                style.rowGroupEmptyIcon,
                size: style.iconSize / 2,
                color: style.iconColor,
              )
            : widget.row.type.group.expanded
                ? Icon(
                    style.rowGroupExpandedIcon,
                    size: style.iconSize,
                    color: style.iconColor,
                  )
                : Icon(
                    style.rowGroupCollapsedIcon,
                    size: style.iconSize,
                    color: style.iconColor,
                  ),
      );
    }

    return Row(children: [
      if (_canRowDrag)
        _RowDragIconWidget(
          column: widget.column,
          row: widget.row,
          rowIdx: widget.rowIdx,
          stateManager: stateManager,
          feedbackWidget: cellWidget,
          dragIcon: Icon(
            Icons.drag_indicator,
            size: style.iconSize,
            color: style.iconColor,
          ),
        ),
      if (widget.column.enableRowChecked)
        CheckboxSelectionWidget(
          column: widget.column,
          row: widget.row,
          rowIdx: widget.rowIdx,
          stateManager: stateManager,
        ),
      if (spacingWidget != null) spacingWidget,
      if (expandIcon != null) expandIcon,
      Expanded(child: cellWidget),
      if (_showGroupCount)
        Text(
          '($_groupCount)',
          style: stateManager.configuration.style.cellTextStyle.copyWith(
            decoration: TextDecoration.none,
            fontWeight: FontWeight.normal,
          ),
        ),
    ]);
  }
}

class _RowDragIconWidget extends StatelessWidget {
  final PlutoColumn column;

  final PlutoRow row;

  final int rowIdx;

  final PlutoGridStateManager stateManager;

  final Widget dragIcon;

  final Widget feedbackWidget;

  const _RowDragIconWidget({
    required this.column,
    required this.row,
    required this.rowIdx,
    required this.stateManager,
    required this.dragIcon,
    required this.feedbackWidget,
    Key? key,
  }) : super(key: key);

  List<PlutoRow> get _draggingRows {
    if (stateManager.currentSelectingRows.isEmpty) {
      return [row];
    }

    if (stateManager.isSelectedRow(row.key)) {
      return stateManager.currentSelectingRows;
    }

    // In case there are selected rows,
    // if the dragging row is not included in it,
    // the selection of rows is invalidated.
    stateManager.clearCurrentSelecting(notify: false);

    return [row];
  }

  void _handleOnPointerDown(PointerDownEvent event) {
    stateManager.setIsDraggingRow(true, notify: false);

    stateManager.setDragRows(_draggingRows);
  }

  void _handleOnPointerMove(PointerMoveEvent event) {
    // Do not drag while rows are selected.
    if (stateManager.isSelecting) {
      stateManager.setIsDraggingRow(false);

      return;
    }

    stateManager.eventManager!.addEvent(PlutoGridScrollUpdateEvent(
      offset: event.position,
    ));

    int? targetRowIdx = stateManager.getRowIdxByOffset(
      event.position.dy,
    );

    stateManager.setDragTargetRowIdx(targetRowIdx);
  }

  void _handleOnPointerUp(PointerUpEvent event) {
    stateManager.setIsDraggingRow(false);

    PlutoGridScrollUpdateEvent.stopScroll(
      stateManager,
      PlutoGridScrollUpdateDirection.all,
    );
  }

  @override
  Widget build(BuildContext context) {
    final translationX = stateManager.isRTL ? -0.92 : -0.08;

    return Listener(
      onPointerDown: _handleOnPointerDown,
      onPointerMove: _handleOnPointerMove,
      onPointerUp: _handleOnPointerUp,
      child: Draggable<PlutoRow>(
        data: row,
        dragAnchorStrategy: pointerDragAnchorStrategy,
        feedback: FractionalTranslation(
          translation: Offset(translationX, -0.5),
          child: Material(
            child: PlutoShadowContainer(
              width: column.width,
              height: stateManager.rowHeight,
              backgroundColor:
                  stateManager.configuration.style.gridBackgroundColor,
              borderColor:
                  stateManager.configuration.style.activatedBorderColor,
              child: Row(
                children: [
                  dragIcon,
                  Expanded(
                    child: feedbackWidget,
                  ),
                ],
              ),
            ),
          ),
        ),
        child: dragIcon,
      ),
    );
  }
}

class CheckboxSelectionWidget extends PlutoStatefulWidget {
  final PlutoGridStateManager stateManager;

  final PlutoColumn column;

  final PlutoRow row;

  final int rowIdx;

  const CheckboxSelectionWidget({
    required this.stateManager,
    required this.column,
    required this.row,
    required this.rowIdx,
    super.key,
  });

  @override
  CheckboxSelectionWidgetState createState() => CheckboxSelectionWidgetState();
}

class CheckboxSelectionWidgetState
    extends PlutoStateWithChange<CheckboxSelectionWidget> {
  bool _tristate = false;

  bool? _checked;

  @override
  PlutoGridStateManager get stateManager => widget.stateManager;

  @override
  void initState() {
    super.initState();

    updateState(PlutoNotifierEventForceUpdate.instance);
  }

  @override
  void updateState(PlutoNotifierEvent event) {
    _tristate = update<bool>(
      _tristate,
      stateManager.enabledRowGroups && widget.row.type.isGroup,
    );

    _checked = update<bool?>(
      _checked,
      _tristate ? widget.row.checked : widget.row.checked == true,
    );
  }

  void _handleOnChanged(bool? changed) {
    if (changed == _checked) {
      return;
    }

    if (_tristate) {
      changed ??= false;

      if (_checked == null) changed = true;
    } else {
      changed = changed == true;
    }

    stateManager.setRowChecked(widget.row, changed);

    if (stateManager.onRowChecked != null) {
      stateManager.onRowChecked!(
        PlutoGridOnRowCheckedOneEvent(
          row: widget.row,
          rowIdx: widget.rowIdx,
          isChecked: changed,
        ),
      );
    }

    setState(() {
      _checked = changed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PlutoScaledCheckbox(
      value: _checked,
      handleOnChanged: _handleOnChanged,
      tristate: _tristate,
      scale: 0.86,
      unselectedColor: stateManager.configuration.style.iconColor,
      activeColor: stateManager.configuration.style.activatedBorderColor,
      checkColor: stateManager.configuration.style.activatedColor,
    );
  }
}

class _DefaultCellWidget extends StatelessWidget {
  final PlutoGridStateManager stateManager;

  final int rowIdx;

  final PlutoRow row;

  final PlutoColumn column;

  final PlutoCell cell;

  const _DefaultCellWidget({
    required this.stateManager,
    required this.rowIdx,
    required this.row,
    required this.column,
    required this.cell,
    Key? key,
  }) : super(key: key);

  bool get _showText {
    if (!stateManager.enabledRowGroups) {
      return true;
    }

    return stateManager.rowGroupDelegate!.isExpandableCell(cell) ||
        stateManager.rowGroupDelegate!.isEditableCell(cell);
  }

  String get _text {
    if (!_showText) return '';

    dynamic cellValue = cell.value;

    if (stateManager.enabledRowGroups &&
        stateManager.rowGroupDelegate!.showFirstExpandableIcon &&
        stateManager.rowGroupDelegate!.type.isByColumn) {
      final delegate =
          stateManager.rowGroupDelegate as PlutoRowGroupByColumnDelegate;

      if (row.depth < delegate.columns.length) {
        cellValue = row.cells[delegate.columns[row.depth].field]!.value;
      }
    }

    return column.formattedValueForDisplay(cellValue);
  }

  @override
  Widget build(BuildContext context) {
    if (column.hasRenderer) {
      return column.renderer!(PlutoColumnRendererContext(
        column: column,
        rowIdx: rowIdx,
        row: row,
        cell: cell,
        stateManager: stateManager,
      ));
    }

    return Text(
      _text,
      style: stateManager.configuration.style.cellTextStyle.copyWith(
        decoration: TextDecoration.none,
        fontWeight: FontWeight.normal,
      ),
      overflow: TextOverflow.ellipsis,
      textAlign: column.textAlign.value,
    );
  }
}
