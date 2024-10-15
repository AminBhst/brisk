import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'ui.dart';

class PlutoBodyColumnsFooter extends PlutoStatefulWidget {
  final PlutoGridStateManager stateManager;

  const PlutoBodyColumnsFooter(
    this.stateManager, {
    super.key,
  });

  @override
  PlutoBodyColumnsFooterState createState() => PlutoBodyColumnsFooterState();
}

class PlutoBodyColumnsFooterState
    extends PlutoStateWithChange<PlutoBodyColumnsFooter> {
  List<PlutoColumn> _columns = [];

  int _itemCount = 0;

  late final ScrollController _scroll;

  @override
  PlutoGridStateManager get stateManager => widget.stateManager;

  @override
  void initState() {
    super.initState();

    _scroll = stateManager.scroll.horizontal!.addAndGet();

    updateState(PlutoNotifierEventForceUpdate.instance);
  }

  @override
  void dispose() {
    _scroll.dispose();

    super.dispose();
  }

  @override
  void updateState(PlutoNotifierEvent event) {
    _columns = update<List<PlutoColumn>>(
      _columns,
      _getColumns(),
      compare: listEquals,
    );

    _itemCount = update<int>(_itemCount, _columns.length);
  }

  List<PlutoColumn> _getColumns() {
    return stateManager.showFrozenColumn
        ? stateManager.bodyColumns
        : stateManager.columns;
  }

  PlutoVisibilityLayoutId _makeFooter(PlutoColumn e) {
    return PlutoVisibilityLayoutId(
      id: e.field,
      child: PlutoBaseColumnFooter(
        stateManager: stateManager,
        column: e,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scroll,
      scrollDirection: Axis.horizontal,
      physics: const ClampingScrollPhysics(),
      child: PlutoVisibilityLayout(
        delegate: ColumnFooterLayoutDelegate(
          stateManager: stateManager,
          columns: _columns,
          textDirection: stateManager.textDirection,
        ),
        scrollController: _scroll,
        initialViewportDimension: MediaQuery.of(context).size.width,
        children: _columns.map(_makeFooter).toList(growable: false),
      ),
    );
  }
}

class ColumnFooterLayoutDelegate extends MultiChildLayoutDelegate {
  final PlutoGridStateManager stateManager;

  final List<PlutoColumn> columns;

  final TextDirection textDirection;

  ColumnFooterLayoutDelegate({
    required this.stateManager,
    required this.columns,
    required this.textDirection,
  }) : super(relayout: stateManager.resizingChangeNotifier);

  @override
  Size getSize(BoxConstraints constraints) {
    return Size(
      columns.fold(
        0,
        (previousValue, element) => previousValue += element.width,
      ),
      stateManager.columnFooterHeight,
    );
  }

  @override
  void performLayout(Size size) {
    final isLTR = textDirection == TextDirection.ltr;
    final items = isLTR ? columns : columns.reversed;
    double dx = 0;

    for (PlutoColumn col in items) {
      var width = col.width;

      if (hasChild(col.field)) {
        var boxConstraints = BoxConstraints.tight(
          Size(width, stateManager.columnFooterHeight),
        );

        layoutChild(col.field, boxConstraints);

        positionChild(col.field, Offset(dx, 0));
      }
      dx += width;
    }
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) {
    return true;
  }
}
