import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'ui.dart';

class PlutoBaseColumnFooter extends StatelessWidget
    implements PlutoVisibilityLayoutChild {
  final PlutoGridStateManager stateManager;

  final PlutoColumn column;

  PlutoBaseColumnFooter({
    required this.stateManager,
    required this.column,
  }) : super(key: column.key);

  @override
  double get width => column.width;

  @override
  double get startPosition => column.startPosition;

  @override
  bool get keepAlive => true;

  @override
  Widget build(BuildContext context) {
    final renderer = column.footerRenderer;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: column.backgroundColor,
        border: BorderDirectional(
          end: stateManager.style.enableColumnBorderVertical
              ? BorderSide(color: stateManager.style.borderColor, width: 1.0)
              : BorderSide.none,
        ),
      ),
      child: renderer == null
          ? const SizedBox()
          : renderer(
              PlutoColumnFooterRendererContext(
                column: column,
                stateManager: stateManager,
              ),
            ),
    );
  }
}
