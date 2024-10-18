import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'ui.dart';

class PlutoBaseRow extends StatelessWidget {
  final int rowIdx;

  final PlutoRow row;

  final List<PlutoColumn> columns;

  final PlutoGridStateManager stateManager;

  final bool visibilityLayout;

  const PlutoBaseRow({
    required this.rowIdx,
    required this.row,
    required this.columns,
    required this.stateManager,
    this.visibilityLayout = false,
    super.key,
  });

  bool _checkSameDragRows(PlutoRow draggingRow) {
    final List<PlutoRow> selectedRows =
        stateManager.currentSelectingRows.isNotEmpty
            ? stateManager.currentSelectingRows
            : [draggingRow];

    final end = rowIdx + selectedRows.length;

    for (int i = rowIdx; i < end; i += 1) {
      if (stateManager.refRows[i].key != selectedRows[i - rowIdx].key) {
        return false;
      }
    }

    return true;
  }

  bool _handleOnWillAccept(PlutoRow? draggingRow) {
    if (draggingRow == null) {
      return false;
    }

    return !_checkSameDragRows(draggingRow);
  }

  void _handleOnAccept(PlutoRow draggingRow) async {
    final draggingRows = stateManager.currentSelectingRows.isNotEmpty
        ? stateManager.currentSelectingRows
        : [draggingRow];

    stateManager.eventManager!.addEvent(
      PlutoGridDragRowsEvent(
        rows: draggingRows,
        targetIdx: rowIdx,
      ),
    );
  }

  PlutoVisibilityLayoutId _makeCell(PlutoColumn column) {
    return PlutoVisibilityLayoutId(
      id: column.field,
      child: PlutoBaseCell(
        key: row.cells[column.field]!.key,
        cell: row.cells[column.field]!,
        column: column,
        rowIdx: rowIdx,
        row: row,
        stateManager: stateManager,
      ),
    );
  }

  Widget _dragTargetBuilder(dragContext, candidate, rejected) {
    return _RowContainerWidget(
      stateManager: stateManager,
      rowIdx: rowIdx,
      row: row,
      enableRowColorAnimation:
          stateManager.configuration.style.enableRowColorAnimation,
      key: ValueKey('rowContainer_${row.key}'),
      child: visibilityLayout
          ? PlutoVisibilityLayout(
              key: ValueKey('rowContainer_${row.key}_row'),
              delegate: _RowCellsLayoutDelegate(
                stateManager: stateManager,
                columns: columns,
                textDirection: stateManager.textDirection,
              ),
              scrollController: stateManager.scroll.bodyRowsHorizontal!,
              initialViewportDimension: MediaQuery.of(dragContext).size.width,
              children: columns.map(_makeCell).toList(growable: false),
            )
          : CustomMultiChildLayout(
              key: ValueKey('rowContainer_${row.key}_row'),
              delegate: _RowCellsLayoutDelegate(
                stateManager: stateManager,
                columns: columns,
                textDirection: stateManager.textDirection,
              ),
              children: columns.map(_makeCell).toList(growable: false),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget<PlutoRow>(
      onWillAccept: _handleOnWillAccept,
      onAccept: _handleOnAccept,
      builder: _dragTargetBuilder,
    );
  }
}

class _RowCellsLayoutDelegate extends MultiChildLayoutDelegate {
  final PlutoGridStateManager stateManager;

  final List<PlutoColumn> columns;

  final TextDirection textDirection;

  _RowCellsLayoutDelegate({
    required this.stateManager,
    required this.columns,
    required this.textDirection,
  }) : super(relayout: stateManager.resizingChangeNotifier);

  @override
  Size getSize(BoxConstraints constraints) {
    final double width = columns.fold(
      0,
      (previousValue, element) => previousValue + element.width,
    );

    return Size(width, stateManager.rowHeight);
  }

  @override
  void performLayout(Size size) {
    final isLTR = textDirection == TextDirection.ltr;
    final items = isLTR ? columns : columns.reversed;
    double dx = 0;

    for (var element in items) {
      var width = element.width;

      if (hasChild(element.field)) {
        layoutChild(
          element.field,
          BoxConstraints.tightFor(
            width: width,
            height: stateManager.rowHeight,
          ),
        );

        positionChild(
          element.field,
          Offset(dx, 0),
        );
      }

      dx += width;
    }
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) {
    return true;
  }
}

class _RowContainerWidget extends PlutoStatefulWidget {
  final PlutoGridStateManager stateManager;

  final int rowIdx;

  final PlutoRow row;

  final bool enableRowColorAnimation;

  final Widget child;

  const _RowContainerWidget({
    required this.stateManager,
    required this.rowIdx,
    required this.row,
    required this.enableRowColorAnimation,
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  State<_RowContainerWidget> createState() => _RowContainerWidgetState();
}

class _RowContainerWidgetState extends PlutoStateWithChange<_RowContainerWidget>
    with
        AutomaticKeepAliveClientMixin,
        PlutoStateWithKeepAlive<_RowContainerWidget> {
  @override
  PlutoGridStateManager get stateManager => widget.stateManager;

  BoxDecoration _decoration = const BoxDecoration();

  Color get _oddRowColor => stateManager.configuration.style.oddRowColor == null
      ? stateManager.configuration.style.rowColor
      : stateManager.configuration.style.oddRowColor!;

  Color get _evenRowColor =>
      stateManager.configuration.style.evenRowColor == null
          ? stateManager.configuration.style.rowColor
          : stateManager.configuration.style.evenRowColor!;

  @override
  void initState() {
    super.initState();

    updateState(PlutoNotifierEventForceUpdate.instance);
  }

  @override
  void updateState(PlutoNotifierEvent event) {
    _decoration = update<BoxDecoration>(
      _decoration,
      _getBoxDecoration(),
    );

    setKeepAlive(stateManager.isSelecting &&
        stateManager.currentRowIdx == widget.rowIdx);
  }

  Color _getDefaultRowColor() {
    if (stateManager.rowColorCallback == null) {
      return widget.rowIdx % 2 == 0 ? _oddRowColor : _evenRowColor;
    }

    return stateManager.rowColorCallback!(
      PlutoRowColorContext(
        rowIdx: widget.rowIdx,
        row: widget.row,
        stateManager: stateManager,
      ),
    );
  }

  Color _getRowColor({
    required bool isDragTarget,
    required bool isFocusedCurrentRow,
    required bool isSelecting,
    required bool hasCurrentSelectingPosition,
    required bool isCheckedRow,
  }) {
    Color color = _getDefaultRowColor();

    if (isDragTarget) {
      color = stateManager.configuration.style.cellColorInReadOnlyState;
    } else {
      final bool checkCurrentRow = !stateManager.selectingMode.isRow &&
          isFocusedCurrentRow &&
          (!isSelecting && !hasCurrentSelectingPosition);

      final bool checkSelectedRow = stateManager.selectingMode.isRow &&
          stateManager.isSelectedRow(widget.row.key);

      if (checkCurrentRow || checkSelectedRow) {
        color = stateManager.configuration.style.activatedColor;
      }
    }

    return isCheckedRow
        ? Color.alphaBlend(stateManager.configuration.style.checkedColor, color)
        : color;
  }

  BoxDecoration _getBoxDecoration() {
    final bool isCurrentRow = stateManager.currentRowIdx == widget.rowIdx;

    final bool isSelecting = stateManager.isSelecting;

    final bool isCheckedRow = widget.row.checked == true;

    final alreadyTarget = stateManager.dragRows
            .firstWhereOrNull((element) => element.key == widget.row.key) !=
        null;

    final isDraggingRow = stateManager.isDraggingRow;

    final bool isDragTarget = isDraggingRow &&
        !alreadyTarget &&
        stateManager.isRowIdxDragTarget(widget.rowIdx);

    final bool isTopDragTarget =
        isDraggingRow && stateManager.isRowIdxTopDragTarget(widget.rowIdx);

    final bool isBottomDragTarget =
        isDraggingRow && stateManager.isRowIdxBottomDragTarget(widget.rowIdx);

    final bool hasCurrentSelectingPosition =
        stateManager.hasCurrentSelectingPosition;

    final bool isFocusedCurrentRow = isCurrentRow && stateManager.hasFocus;

    final Color rowColor = _getRowColor(
      isDragTarget: isDragTarget,
      isFocusedCurrentRow: isFocusedCurrentRow,
      isSelecting: isSelecting,
      hasCurrentSelectingPosition: hasCurrentSelectingPosition,
      isCheckedRow: isCheckedRow,
    );

    return BoxDecoration(
      color: rowColor,
      border: Border(
        top: isTopDragTarget
            ? BorderSide(
                width: PlutoGridSettings.rowBorderWidth,
                color: stateManager.configuration.style.activatedBorderColor,
              )
            : BorderSide.none,
        bottom: isBottomDragTarget
            ? BorderSide(
                width: PlutoGridSettings.rowBorderWidth,
                color: stateManager.configuration.style.activatedBorderColor,
              )
            : stateManager.configuration.style.enableCellBorderHorizontal
                ? BorderSide(
                    width: PlutoGridSettings.rowBorderWidth,
                    color: stateManager.configuration.style.borderColor,
                  )
                : BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return _AnimatedOrNormalContainer(
      enable: widget.enableRowColorAnimation,
      decoration: _decoration,
      child: widget.child,
    );
  }
}

class _AnimatedOrNormalContainer extends StatelessWidget {
  final bool enable;

  final Widget child;

  final BoxDecoration decoration;

  const _AnimatedOrNormalContainer({
    required this.enable,
    required this.child,
    required this.decoration,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return enable
        ? AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: decoration,
            child: child,
          )
        : DecoratedBox(decoration: decoration, child: child);
  }
}
