import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

typedef PlutoDualOnSelectedEventCallback = void Function(
    PlutoDualOnSelectedEvent event);

/// In [PlutoDualGrid], set the separation widget between the two grids.
class PlutoDualGridDivider {
  /// If [show] is set to true, a separator widget appears between the grids,
  /// and you can change the width of two grids by dragging them.
  final bool show;

  /// Set the background color.
  final Color backgroundColor;

  /// Set the icon color in the center of the separator widget.
  final Color indicatorColor;

  /// Set the background color when dragging the separator widget.
  final Color draggingColor;

  const PlutoDualGridDivider({
    this.show = true,
    this.backgroundColor = Colors.white,
    this.indicatorColor = const Color(0xFFA1A5AE),
    this.draggingColor = const Color(0xFFDCF5FF),
  });

  const PlutoDualGridDivider.dark({
    this.show = true,
    this.backgroundColor = const Color(0xFF111111),
    this.indicatorColor = const Color(0xFF000000),
    this.draggingColor = const Color(0xFF313131),
  });
}

/// [PlutoDualGrid] can connect the keyboard movement between the two grids
/// by arranging two [PlutoGrid] left and right.
class PlutoDualGrid extends StatefulWidget {
  final PlutoDualGridProps gridPropsA;

  final PlutoDualGridProps gridPropsB;

  final PlutoGridMode mode;

  final PlutoDualOnSelectedEventCallback? onSelected;

  /// [PlutoDualGridDisplayRatio]
  /// Set the width of the two grids by specifying the ratio of the left grid.
  /// 0.5 is 5(left grid):5(right grid).
  /// 0.8 is 8(left grid):2(right grid).
  ///
  /// [PlutoDualGridDisplayFixedAndExpanded]
  /// Fix the width of the left grid.
  ///
  /// [PlutoDualGridDisplayExpandedAndFixed]
  /// Fix the width of the right grid.
  final PlutoDualGridDisplay? display;

  final PlutoDualGridDivider divider;

  const PlutoDualGrid({
    required this.gridPropsA,
    required this.gridPropsB,
    this.mode = PlutoGridMode.normal,
    this.onSelected,
    this.display,
    this.divider = const PlutoDualGridDivider(),
    Key? key,
  }) : super(key: key);

  static const double dividerWidth = 10;

  @override
  PlutoDualGridState createState() => PlutoDualGridState();
}

class PlutoDualGridResizeNotifier extends ChangeNotifier {
  resize() {
    notifyListeners();
  }
}

class PlutoDualGridState extends State<PlutoDualGrid> {
  final PlutoDualGridResizeNotifier resizeNotifier =
      PlutoDualGridResizeNotifier();

  late final PlutoDualGridDisplay display;

  late final PlutoGridStateManager _stateManagerA;

  late final PlutoGridStateManager _stateManagerB;

  late final StreamSubscription<PlutoGridEvent> _streamA;

  late final StreamSubscription<PlutoGridEvent> _streamB;

  @override
  void initState() {
    super.initState();

    display = widget.display ?? PlutoDualGridDisplayRatio();
  }

  @override
  void dispose() {
    _streamA.cancel();

    _streamB.cancel();

    super.dispose();
  }

  Widget _buildGrid({
    required PlutoDualGridProps props,
    required bool isGridA,
    required PlutoGridMode mode,
  }) {
    return LayoutId(
      id: isGridA == true ? _PlutoDualGridId.gridA : _PlutoDualGridId.gridB,
      child: PlutoGrid(
        columns: props.columns,
        rows: props.rows,
        columnGroups: props.columnGroups,
        onLoaded: (PlutoGridOnLoadedEvent onLoadedEvent) {
          if (isGridA) {
            _stateManagerA = onLoadedEvent.stateManager;
          } else {
            _stateManagerB = onLoadedEvent.stateManager;
          }

          handleEvent(PlutoGridEvent plutoEvent) {
            if (plutoEvent is PlutoGridCannotMoveCurrentCellEvent) {
              if (isGridA == true && plutoEvent.direction.isRight) {
                _stateManagerA.setKeepFocus(false);
                _stateManagerB.setKeepFocus(true);
              } else if (isGridA != true && plutoEvent.direction.isLeft) {
                _stateManagerA.setKeepFocus(true);
                _stateManagerB.setKeepFocus(false);
              }
            }
          }

          if (isGridA) {
            _streamA =
                onLoadedEvent.stateManager.eventManager!.listener(handleEvent);
          } else {
            _streamB =
                onLoadedEvent.stateManager.eventManager!.listener(handleEvent);
          }

          if (props.onLoaded != null) {
            props.onLoaded!(onLoadedEvent);
          }
        },
        onChanged: props.onChanged,
        onSelected: (PlutoGridOnSelectedEvent onSelectedEvent) {
          if (onSelectedEvent.row == null || onSelectedEvent.cell == null) {
            widget.onSelected!(
              PlutoDualOnSelectedEvent(
                gridA: null,
                gridB: null,
              ),
            );
          } else {
            widget.onSelected!(
              PlutoDualOnSelectedEvent(
                gridA: PlutoGridOnSelectedEvent(
                  row: _stateManagerA.currentRow,
                  rowIdx: _stateManagerA.currentRowIdx,
                  cell: _stateManagerA.currentCell,
                ),
                gridB: PlutoGridOnSelectedEvent(
                  row: _stateManagerB.currentRow,
                  rowIdx: _stateManagerB.currentRowIdx,
                  cell: _stateManagerB.currentCell,
                ),
              ),
            );
          }
        },
        onSorted: props.onSorted,
        onRowChecked: props.onRowChecked,
        onRowDoubleTap: props.onRowDoubleTap,
        onRowSecondaryTap: props.onRowSecondaryTap,
        onRowsMoved: props.onRowsMoved,
        onColumnsMoved: props.onColumnsMoved,
        createHeader: props.createHeader,
        createFooter: props.createFooter,
        noRowsWidget: props.noRowsWidget,
        rowColorCallback: props.rowColorCallback,
        columnMenuDelegate: props.columnMenuDelegate,
        configuration: props.configuration,
        mode: mode,
        key: props.key,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isLTR = Directionality.of(context) == TextDirection.ltr;

    return CustomMultiChildLayout(
      delegate: PlutoDualGridLayoutDelegate(
        notifier: resizeNotifier,
        display: display,
        showDraggableDivider: widget.divider.show,
        isLTR: isLTR,
      ),
      children: [
        _buildGrid(
          props: widget.gridPropsA,
          isGridA: true,
          mode: widget.mode,
        ),
        if (widget.divider.show == true)
          LayoutId(
            id: _PlutoDualGridId.divider,
            child: PlutoDualGridDividerWidget(
              backgroundColor: widget.divider.backgroundColor,
              indicatorColor: widget.divider.indicatorColor,
              draggingColor: widget.divider.draggingColor,
              dragCallback: (details) {
                final RenderBox object =
                    context.findRenderObject() as RenderBox;

                display.offset = object
                    .globalToLocal(Offset(
                      details.globalPosition.dx,
                      details.globalPosition.dy,
                    ))
                    .dx;

                resizeNotifier.resize();
              },
            ),
          ),
        _buildGrid(
          props: widget.gridPropsB,
          isGridA: false,
          mode: widget.mode,
        ),
      ],
    );
  }
}

class PlutoDualGridDividerWidget extends StatefulWidget {
  final Color backgroundColor;

  final Color indicatorColor;

  final Color draggingColor;

  final void Function(DragUpdateDetails) dragCallback;

  const PlutoDualGridDividerWidget({
    required this.backgroundColor,
    required this.indicatorColor,
    required this.draggingColor,
    required this.dragCallback,
    Key? key,
  }) : super(key: key);

  @override
  State<PlutoDualGridDividerWidget> createState() =>
      PlutoDualGridDividerWidgetState();
}

class PlutoDualGridDividerWidgetState
    extends State<PlutoDualGridDividerWidget> {
  bool isDragging = false;

  void onHorizontalDragStart(DragStartDetails details) {
    if (isDragging == false) {
      setState(() {
        isDragging = true;
      });
    }
  }

  void onHorizontalDragUpdate(DragUpdateDetails details) {
    widget.dragCallback(details);

    if (isDragging == false) {
      setState(() {
        isDragging = true;
      });
    }
  }

  void onHorizontalDragEnd(DragEndDetails details) {
    setState(() {
      isDragging = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (layoutContext, size) {
        return GestureDetector(
          onHorizontalDragStart: onHorizontalDragStart,
          onHorizontalDragUpdate: onHorizontalDragUpdate,
          onHorizontalDragEnd: onHorizontalDragEnd,
          child: ColoredBox(
            color: isDragging ? widget.draggingColor : widget.backgroundColor,
            child: Stack(
              children: [
                Positioned(
                  top: (size.maxHeight / 2) - 18,
                  left: -4,
                  child: Icon(
                    Icons.drag_indicator,
                    color: widget.indicatorColor,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

enum _PlutoDualGridId {
  gridA,
  gridB,
  divider,
}

class PlutoDualGridLayoutDelegate extends MultiChildLayoutDelegate {
  PlutoDualGridLayoutDelegate({
    required ChangeNotifier notifier,
    required this.display,
    required this.showDraggableDivider,
    required this.isLTR,
  }) : super(relayout: notifier);

  final PlutoDualGridDisplay display;

  final bool showDraggableDivider;

  final bool isLTR;

  @override
  void performLayout(Size size) {
    final BoxConstraints constrains = BoxConstraints(
      maxWidth: size.width,
      maxHeight: size.height,
    );

    final dividerHalf =
        showDraggableDivider ? PlutoDualGrid.dividerWidth / 2 : 0;

    final dividerWidth = dividerHalf * 2;

    double gridAWidth = showDraggableDivider
        ? display.offset == null
            ? display.gridAWidth(constrains) - dividerHalf
            : display.offset! - dividerHalf
        : display.gridAWidth(constrains) - dividerHalf;
    double gridBWidth = size.width - gridAWidth - dividerWidth;

    if (!isLTR) {
      final savedGridBWidth = gridBWidth;
      gridBWidth = gridAWidth;
      gridAWidth = savedGridBWidth;
    }

    if (gridAWidth < 0) {
      gridAWidth = 0;
    } else if (gridAWidth > size.width - dividerWidth) {
      gridAWidth = size.width - dividerWidth;
    }

    if (gridBWidth < 0) {
      gridBWidth = 0;
    } else if (gridBWidth > size.width - dividerWidth) {
      gridBWidth = size.width - dividerWidth;
    }

    if (hasChild(_PlutoDualGridId.gridA)) {
      layoutChild(
        _PlutoDualGridId.gridA,
        BoxConstraints.tight(
          Size(gridAWidth, size.height),
        ),
      );

      final double posX = isLTR ? 0 : gridBWidth + dividerWidth;

      positionChild(_PlutoDualGridId.gridA, Offset(posX, 0));
    }

    if (hasChild(_PlutoDualGridId.divider)) {
      layoutChild(
        _PlutoDualGridId.divider,
        BoxConstraints.tight(
          Size(PlutoDualGrid.dividerWidth, size.height),
        ),
      );

      final double posX = isLTR ? gridAWidth : gridBWidth;

      positionChild(_PlutoDualGridId.divider, Offset(posX, 0));
    }

    if (hasChild(_PlutoDualGridId.gridB)) {
      layoutChild(
        _PlutoDualGridId.gridB,
        BoxConstraints.tight(
          Size(gridBWidth, size.height),
        ),
      );

      final double posX = isLTR ? gridAWidth + dividerWidth : 0;

      positionChild(_PlutoDualGridId.gridB, Offset(posX, 0));
    }
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) {
    return true;
  }
}

class PlutoDualOnSelectedEvent {
  PlutoGridOnSelectedEvent? gridA;

  PlutoGridOnSelectedEvent? gridB;

  PlutoDualOnSelectedEvent({
    this.gridA,
    this.gridB,
  });
}

abstract class PlutoDualGridDisplay {
  double gridAWidth(BoxConstraints size);

  double gridBWidth(BoxConstraints size);

  double? offset;
}

class PlutoDualGridDisplayRatio implements PlutoDualGridDisplay {
  final double ratio;

  PlutoDualGridDisplayRatio({
    this.ratio = 0.5,
  }) : assert(0 < ratio && ratio < 1);

  @override
  double? offset;

  @override
  double gridAWidth(BoxConstraints size) => size.maxWidth * ratio;

  @override
  double gridBWidth(BoxConstraints size) => size.maxWidth * (1 - ratio);
}

class PlutoDualGridDisplayFixedAndExpanded implements PlutoDualGridDisplay {
  final double width;

  PlutoDualGridDisplayFixedAndExpanded({
    this.width = 206.0,
  });

  @override
  double? offset;

  @override
  double gridAWidth(BoxConstraints size) => width;

  @override
  double gridBWidth(BoxConstraints size) => size.maxWidth - width;
}

class PlutoDualGridDisplayExpandedAndFixed implements PlutoDualGridDisplay {
  final double width;

  PlutoDualGridDisplayExpandedAndFixed({
    this.width = 206.0,
  });

  @override
  double? offset;

  @override
  double gridAWidth(BoxConstraints size) => size.maxWidth - width;

  @override
  double gridBWidth(BoxConstraints size) => width;
}

class PlutoDualGridProps {
  /// {@macro pluto_grid_property_columns}
  final List<PlutoColumn> columns;

  /// {@macro pluto_grid_property_rows}
  final List<PlutoRow> rows;

  /// {@macro pluto_grid_property_columnGroups}
  final List<PlutoColumnGroup>? columnGroups;

  /// {@macro pluto_grid_property_onLoaded}
  final PlutoOnLoadedEventCallback? onLoaded;

  /// {@macro pluto_grid_property_onChanged}
  final PlutoOnChangedEventCallback? onChanged;

  /// {@macro pluto_grid_property_onSorted}
  final PlutoOnSortedEventCallback? onSorted;

  /// {@macro pluto_grid_property_onRowChecked}
  final PlutoOnRowCheckedEventCallback? onRowChecked;

  /// {@macro pluto_grid_property_onRowDoubleTap}
  final PlutoOnRowDoubleTapEventCallback? onRowDoubleTap;

  /// {@macro pluto_grid_property_onRowSecondaryTap}
  final PlutoOnRowSecondaryTapEventCallback? onRowSecondaryTap;

  /// {@macro pluto_grid_property_onRowsMoved}
  final PlutoOnRowsMovedEventCallback? onRowsMoved;

  /// {@macro pluto_grid_property_onColumnsMoved}
  final PlutoOnColumnsMovedEventCallback? onColumnsMoved;

  /// {@macro pluto_grid_property_createHeader}
  final CreateHeaderCallBack? createHeader;

  /// {@macro pluto_grid_property_createFooter}
  final CreateFooterCallBack? createFooter;

  /// {@macro pluto_grid_property_noRowsWidget}
  final Widget? noRowsWidget;

  /// {@macro pluto_grid_property_rowColorCallback}
  final PlutoRowColorCallback? rowColorCallback;

  /// {@macro pluto_grid_property_columnMenuDelegate}
  final PlutoColumnMenuDelegate? columnMenuDelegate;

  /// {@macro pluto_grid_property_configuration}
  final PlutoGridConfiguration configuration;

  /// Execution mode of [PlutoGrid].
  ///
  /// [PlutoGridMode.normal]
  /// {@macro pluto_grid_mode_normal}
  ///
  /// [PlutoGridMode.select], [PlutoGridMode.selectWithOneTap]
  /// {@macro pluto_grid_mode_select}
  ///
  /// [PlutoGridMode.popup]
  /// {@macro pluto_grid_mode_popup}
  final PlutoGridMode? mode;

  final Key? key;

  const PlutoDualGridProps({
    required this.columns,
    required this.rows,
    this.columnGroups,
    this.onLoaded,
    this.onChanged,
    this.onSorted,
    this.onRowChecked,
    this.onRowDoubleTap,
    this.onRowSecondaryTap,
    this.onRowsMoved,
    this.onColumnsMoved,
    this.createHeader,
    this.createFooter,
    this.noRowsWidget,
    this.rowColorCallback,
    this.columnMenuDelegate,
    this.configuration = const PlutoGridConfiguration(),
    this.mode,
    this.key,
  });

  PlutoDualGridProps copyWith({
    List<PlutoColumn>? columns,
    List<PlutoRow>? rows,
    PlutoOptional<List<PlutoColumnGroup>?>? columnGroups,
    PlutoOptional<PlutoOnLoadedEventCallback?>? onLoaded,
    PlutoOptional<PlutoOnChangedEventCallback?>? onChanged,
    PlutoOptional<PlutoOnSortedEventCallback?>? onSorted,
    PlutoOptional<PlutoOnRowCheckedEventCallback?>? onRowChecked,
    PlutoOptional<PlutoOnRowDoubleTapEventCallback?>? onRowDoubleTap,
    PlutoOptional<PlutoOnRowSecondaryTapEventCallback?>? onRowSecondaryTap,
    PlutoOptional<PlutoOnRowsMovedEventCallback?>? onRowsMoved,
    PlutoOptional<PlutoOnColumnsMovedEventCallback?>? onColumnsMoved,
    PlutoOptional<CreateHeaderCallBack?>? createHeader,
    PlutoOptional<CreateFooterCallBack?>? createFooter,
    PlutoOptional<Widget?>? noRowsWidget,
    PlutoOptional<PlutoRowColorCallback?>? rowColorCallback,
    PlutoOptional<PlutoColumnMenuDelegate?>? columnMenuDelegate,
    PlutoGridConfiguration? configuration,
    PlutoOptional<PlutoGridMode?>? mode,
    Key? key,
  }) {
    return PlutoDualGridProps(
      columns: columns ?? this.columns,
      rows: rows ?? this.rows,
      columnGroups:
          columnGroups == null ? this.columnGroups : columnGroups.value,
      onLoaded: onLoaded == null ? this.onLoaded : onLoaded.value,
      onChanged: onChanged == null ? this.onChanged : onChanged.value,
      onSorted: onSorted == null ? this.onSorted : onSorted.value,
      onRowChecked:
          onRowChecked == null ? this.onRowChecked : onRowChecked.value,
      onRowDoubleTap:
          onRowDoubleTap == null ? this.onRowDoubleTap : onRowDoubleTap.value,
      onRowSecondaryTap: onRowSecondaryTap == null
          ? this.onRowSecondaryTap
          : onRowSecondaryTap.value,
      onRowsMoved: onRowsMoved == null ? this.onRowsMoved : onRowsMoved.value,
      onColumnsMoved:
          onColumnsMoved == null ? this.onColumnsMoved : onColumnsMoved.value,
      createHeader:
          createHeader == null ? this.createHeader : createHeader.value,
      createFooter:
          createFooter == null ? this.createFooter : createFooter.value,
      noRowsWidget:
          noRowsWidget == null ? this.noRowsWidget : noRowsWidget.value,
      rowColorCallback: rowColorCallback == null
          ? this.rowColorCallback
          : rowColorCallback.value,
      columnMenuDelegate: columnMenuDelegate == null
          ? this.columnMenuDelegate
          : columnMenuDelegate.value,
      configuration: configuration ?? this.configuration,
      mode: mode == null ? this.mode : mode.value,
      key: key ?? this.key,
    );
  }
}
