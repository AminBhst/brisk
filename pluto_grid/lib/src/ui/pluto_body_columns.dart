import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'ui.dart';

class PlutoBodyColumns extends PlutoStatefulWidget {
  final PlutoGridStateManager stateManager;

  const PlutoBodyColumns(
    this.stateManager, {
    super.key,
  });

  @override
  PlutoBodyColumnsState createState() => PlutoBodyColumnsState();
}

class PlutoBodyColumnsState extends PlutoStateWithChange<PlutoBodyColumns> {
  List<PlutoColumn> _columns = [];

  List<PlutoColumnGroupPair> _columnGroups = [];

  bool _showColumnGroups = false;

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
    _showColumnGroups = update<bool>(
      _showColumnGroups,
      stateManager.showColumnGroups,
    );

    _columns = update<List<PlutoColumn>>(
      _columns,
      _getColumns(),
      compare: listEquals,
    );

    _columnGroups = update<List<PlutoColumnGroupPair>>(
      _columnGroups,
      stateManager.separateLinkedGroup(
        columnGroupList: stateManager.refColumnGroups,
        columns: _columns,
      ),
    );

    _itemCount = update<int>(_itemCount, _getItemCount());
  }

  List<PlutoColumn> _getColumns() {
    return stateManager.showFrozenColumn
        ? stateManager.bodyColumns
        : stateManager.columns;
  }

  int _getItemCount() {
    return _showColumnGroups == true ? _columnGroups.length : _columns.length;
  }

  PlutoVisibilityLayoutId _makeColumnGroup(PlutoColumnGroupPair e) {
    return PlutoVisibilityLayoutId(
      id: e.key,
      child: PlutoBaseColumnGroup(
        stateManager: stateManager,
        columnGroup: e,
        depth: stateManager.columnGroupDepth(
          stateManager.refColumnGroups,
        ),
      ),
    );
  }

  PlutoVisibilityLayoutId _makeColumn(PlutoColumn e) {
    return PlutoVisibilityLayoutId(
      id: e.field,
      child: PlutoBaseColumn(
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
        delegate: MainColumnLayoutDelegate(
          stateManager: stateManager,
          columns: _columns,
          columnGroups: _columnGroups,
          frozen: PlutoColumnFrozen.none,
          textDirection: stateManager.textDirection,
        ),
        scrollController: _scroll,
        initialViewportDimension: MediaQuery.of(context).size.width,
        children: _showColumnGroups == true
            ? _columnGroups.map(_makeColumnGroup).toList(growable: false)
            : _columns.map(_makeColumn).toList(growable: false),
      ),
    );
  }
}

class MainColumnLayoutDelegate extends MultiChildLayoutDelegate {
  final PlutoGridStateManager stateManager;

  final List<PlutoColumn> columns;

  final List<PlutoColumnGroupPair> columnGroups;

  final PlutoColumnFrozen frozen;

  final TextDirection textDirection;

  MainColumnLayoutDelegate({
    required this.stateManager,
    required this.columns,
    required this.columnGroups,
    required this.frozen,
    required this.textDirection,
  }) : super(relayout: stateManager.resizingChangeNotifier);

  double totalColumnsHeight = 0;

  @override
  Size getSize(BoxConstraints constraints) {
    totalColumnsHeight = 0;

    if (stateManager.showColumnGroups) {
      totalColumnsHeight =
          stateManager.columnGroupHeight + stateManager.columnHeight;
    } else {
      totalColumnsHeight = stateManager.columnHeight;
    }

    totalColumnsHeight += stateManager.columnFilterHeight;

    return Size(
      columns.fold(
        0,
        (previousValue, element) => previousValue += element.width,
      ),
      totalColumnsHeight,
    );
  }

  @override
  void performLayout(Size size) {
    final isLTR = textDirection == TextDirection.ltr;

    if (stateManager.showColumnGroups) {
      final items = isLTR ? columnGroups : columnGroups.reversed;
      double dx = 0;

      for (PlutoColumnGroupPair pair in items) {
        final double width = pair.columns.fold<double>(
          0,
          (previousValue, element) => previousValue + element.width,
        );

        if (hasChild(pair.key)) {
          var boxConstraints = BoxConstraints.tight(
            Size(width, totalColumnsHeight),
          );

          layoutChild(pair.key, boxConstraints);

          positionChild(pair.key, Offset(dx, 0));
        }

        dx += width;
      }
    } else {
      final items = isLTR ? columns : columns.reversed;
      double dx = 0;

      for (PlutoColumn col in items) {
        var width = col.width;

        if (hasChild(col.field)) {
          var boxConstraints = BoxConstraints.tight(
            Size(width, totalColumnsHeight),
          );

          layoutChild(col.field, boxConstraints);

          positionChild(col.field, Offset(dx, 0));
        }

        dx += width;
      }
    }
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) {
    return true;
  }
}
