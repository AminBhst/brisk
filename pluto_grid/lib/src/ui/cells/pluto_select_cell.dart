import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'popup_cell.dart';

class PlutoSelectCell extends StatefulWidget implements PopupCell {
  @override
  final PlutoGridStateManager stateManager;

  @override
  final PlutoCell cell;

  @override
  final PlutoColumn column;

  @override
  final PlutoRow row;

  const PlutoSelectCell({
    required this.stateManager,
    required this.cell,
    required this.column,
    required this.row,
    Key? key,
  }) : super(key: key);

  @override
  PlutoSelectCellState createState() => PlutoSelectCellState();
}

class PlutoSelectCellState extends State<PlutoSelectCell>
    with PopupCellState<PlutoSelectCell> {
  @override
  List<PlutoColumn> popupColumns = [];

  @override
  List<PlutoRow> popupRows = [];

  @override
  IconData? get icon => widget.column.type.select.popupIcon;

  late bool enableColumnFilter;

  @override
  void initState() {
    super.initState();

    enableColumnFilter = widget.column.type.select.enableColumnFilter;

    final columnFilterHeight = enableColumnFilter
        ? widget.stateManager.configuration.style.columnFilterHeight
        : 0;

    final rowsHeight = widget.column.type.select.items.length *
        widget.stateManager.rowTotalHeight;

    popupHeight = widget.stateManager.configuration.style.columnHeight +
        columnFilterHeight +
        rowsHeight +
        PlutoGridSettings.gridInnerSpacing +
        PlutoGridSettings.gridBorderWidth;

    fieldOnSelected = widget.column.title;

    popupColumns = [
      PlutoColumn(
        title: widget.column.title,
        field: widget.column.title,
        readOnly: true,
        type: PlutoColumnType.text(),
        formatter: widget.column.formatter,
        enableFilterMenuItem: enableColumnFilter,
        enableHideColumnMenuItem: false,
        enableSetColumnsMenuItem: false,
      )
    ];

    popupRows = widget.column.type.select.items.map((dynamic item) {
      return PlutoRow(
        cells: {
          widget.column.title: PlutoCell(value: item),
        },
      );
    }).toList();
  }

  @override
  void onLoaded(PlutoGridOnLoadedEvent event) {
    super.onLoaded(event);

    if (enableColumnFilter) {
      event.stateManager.setShowColumnFilter(true, notify: false);
    }

    event.stateManager.setSelectingMode(PlutoGridSelectingMode.none);
  }
}
