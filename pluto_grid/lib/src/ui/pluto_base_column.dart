import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'ui.dart';

class PlutoBaseColumn extends PlutoStatefulWidget
    implements PlutoVisibilityLayoutChild {
  final PlutoGridStateManager stateManager;

  final PlutoColumn column;

  final double? columnTitleHeight;

  PlutoBaseColumn({
    required this.stateManager,
    required this.column,
    this.columnTitleHeight,
  }) : super(key: column.key);

  @override
  PlutoBaseColumnState createState() => PlutoBaseColumnState();

  @override
  double get width => column.width;

  @override
  double get startPosition => column.startPosition;

  @override
  bool get keepAlive => false;
}

class PlutoBaseColumnState extends PlutoStateWithChange<PlutoBaseColumn> {
  bool _showColumnFilter = false;

  @override
  PlutoGridStateManager get stateManager => widget.stateManager;

  @override
  void initState() {
    super.initState();

    updateState(PlutoNotifierEventForceUpdate.instance);
  }

  @override
  void updateState(PlutoNotifierEvent event) {
    _showColumnFilter = update<bool>(
      _showColumnFilter,
      stateManager.showColumnFilter,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: _showColumnFilter ? stateManager.columnFilterHeight : 0,
          child: PlutoColumnTitle(
            stateManager: stateManager,
            column: widget.column,
            height: widget.columnTitleHeight ?? stateManager.columnHeight,
          ),
        ),
        if (_showColumnFilter)
          Positioned(
            bottom: 0,
            right: 0,
            left: 0,
            child: PlutoColumnFilter(
              stateManager: stateManager,
              column: widget.column,
            ),
          ),
      ],
    );
  }
}
