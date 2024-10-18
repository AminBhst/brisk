import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

/// [PlutoDualGridPopup] can connect the keyboard movement between the two grids
/// by arranging two [PlutoGrid] left and right.
/// It works as a popup.
class PlutoDualGridPopup {
  final BuildContext context;

  final PlutoDualGridProps gridPropsA;

  final PlutoDualGridProps gridPropsB;

  final PlutoGridMode mode;

  final PlutoDualOnSelectedEventCallback? onSelected;

  final PlutoDualGridDisplay? display;

  final double? width;

  final double? height;

  final PlutoDualGridDivider? divider;

  PlutoDualGridPopup({
    required this.context,
    required this.gridPropsA,
    required this.gridPropsB,
    this.mode = PlutoGridMode.normal,
    this.onSelected,
    this.display,
    this.width,
    this.height,
    this.divider,
  }) {
    open();
  }

  Future<void> open() async {
    final textDirection = Directionality.of(context);

    final splitBorderRadius = _splitBorderRadius(textDirection);

    final shape = _getShape(splitBorderRadius);

    final propsA = _applyBorderRadiusToGridProps(
      splitBorderRadius.elementAt(0),
      gridPropsA,
    );

    final propsB = _applyBorderRadiusToGridProps(
      splitBorderRadius.elementAt(1),
      gridPropsB,
    );

    PlutoDualOnSelectedEvent? selected =
        await showDialog<PlutoDualOnSelectedEvent>(
            context: context,
            builder: (BuildContext ctx) {
              return Dialog(
                shape: shape,
                child: LayoutBuilder(
                  builder: (ctx, size) {
                    return SizedBox(
                      width: (width ?? size.maxWidth) +
                          PlutoGridSettings.gridInnerSpacing,
                      height: height ?? size.maxHeight,
                      child: Directionality(
                        textDirection: textDirection,
                        child: PlutoDualGrid(
                          gridPropsA: propsA,
                          gridPropsB: propsB,
                          mode: mode,
                          onSelected: (PlutoDualOnSelectedEvent event) {
                            Navigator.pop(ctx, event);
                          },
                          display: display ?? PlutoDualGridDisplayRatio(),
                          divider: divider ?? const PlutoDualGridDivider(),
                        ),
                      ),
                    );
                  },
                ),
              );
            });
    if (onSelected != null && selected != null) {
      onSelected!(selected);
    }
  }

  List<BorderRadius> _splitBorderRadius(TextDirection textDirection) {
    final left = gridPropsA.configuration.style.gridBorderRadius.resolve(
      TextDirection.ltr,
    );

    final right = gridPropsB.configuration.style.gridBorderRadius.resolve(
      TextDirection.ltr,
    );

    return [
      BorderRadiusDirectional.only(
        topStart: left.topLeft,
        bottomStart: left.bottomLeft,
        topEnd: Radius.zero,
        bottomEnd: Radius.zero,
      ).resolve(textDirection),
      BorderRadiusDirectional.only(
        topStart: Radius.zero,
        bottomStart: Radius.zero,
        topEnd: right.topRight,
        bottomEnd: right.bottomRight,
      ).resolve(textDirection),
    ];
  }

  ShapeBorder _getShape(List<BorderRadius> borderRadius) {
    return RoundedRectangleBorder(
      borderRadius: borderRadius.elementAt(0) + borderRadius.elementAt(1),
    );
  }

  PlutoDualGridProps _applyBorderRadiusToGridProps(
    BorderRadius borderRadius,
    PlutoDualGridProps gridProps,
  ) {
    return gridProps.copyWith(
      configuration: gridProps.configuration.copyWith(
        style: gridProps.configuration.style.copyWith(
          gridBorderRadius: borderRadius,
        ),
      ),
    );
  }
}
