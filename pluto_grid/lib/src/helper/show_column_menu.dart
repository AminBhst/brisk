import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

abstract class PlutoColumnMenuDelegate<T> {
  List<PopupMenuEntry<T>> buildMenuItems({
    required PlutoGridStateManager stateManager,
    required PlutoColumn column,
  });

  void onSelected({
    required BuildContext context,
    required PlutoGridStateManager stateManager,
    required PlutoColumn column,
    required bool mounted,
    required T? selected,
  });
}

class PlutoColumnMenuDelegateDefault
    implements PlutoColumnMenuDelegate<PlutoGridColumnMenuItem> {
  const PlutoColumnMenuDelegateDefault();

  @override
  List<PopupMenuEntry<PlutoGridColumnMenuItem>> buildMenuItems({
    required PlutoGridStateManager stateManager,
    required PlutoColumn column,
  }) {
    return _getDefaultColumnMenuItems(
      stateManager: stateManager,
      column: column,
    );
  }

  @override
  void onSelected({
    required BuildContext context,
    required PlutoGridStateManager stateManager,
    required PlutoColumn column,
    required bool mounted,
    required PlutoGridColumnMenuItem? selected,
  }) {
    switch (selected) {
      case PlutoGridColumnMenuItem.unfreeze:
        stateManager.toggleFrozenColumn(column, PlutoColumnFrozen.none);
        break;
      case PlutoGridColumnMenuItem.freezeToStart:
        stateManager.toggleFrozenColumn(column, PlutoColumnFrozen.start);
        break;
      case PlutoGridColumnMenuItem.freezeToEnd:
        stateManager.toggleFrozenColumn(column, PlutoColumnFrozen.end);
        break;
      case PlutoGridColumnMenuItem.autoFit:
        if (!mounted) return;
        stateManager.autoFitColumn(context, column);
        stateManager.notifyResizingListeners();
        break;
      case PlutoGridColumnMenuItem.hideColumn:
        stateManager.hideColumn(column, true);
        break;
      case PlutoGridColumnMenuItem.setColumns:
        if (!mounted) return;
        stateManager.showSetColumnsPopup(context);
        break;
      case PlutoGridColumnMenuItem.setFilter:
        if (!mounted) return;
        stateManager.showFilterPopup(context, calledColumn: column);
        break;
      case PlutoGridColumnMenuItem.resetFilter:
        stateManager.setFilter(null);
        break;
      default:
        break;
    }
  }
}

/// Open the context menu on the right side of the column.
Future<T?>? showColumnMenu<T>({
  required BuildContext context,
  required Offset position,
  required List<PopupMenuEntry<T>> items,
  Color backgroundColor = Colors.white,
}) {
  final RenderBox overlay =
      Overlay.of(context).context.findRenderObject() as RenderBox;

  return showMenu<T>(
    context: context,
    color: backgroundColor,
    position: RelativeRect.fromLTRB(
      position.dx,
      position.dy,
      position.dx + overlay.size.width,
      position.dy + overlay.size.height,
    ),
    items: items,
    useRootNavigator: true,
  );
}

List<PopupMenuEntry<PlutoGridColumnMenuItem>> _getDefaultColumnMenuItems({
  required PlutoGridStateManager stateManager,
  required PlutoColumn column,
}) {
  final Color textColor = stateManager.style.cellTextStyle.color!;

  final Color disableTextColor = textColor.withOpacity(0.5);

  final bool enoughFrozenColumnsWidth = stateManager.enoughFrozenColumnsWidth(
    stateManager.maxWidth! - column.width,
  );

  final localeText = stateManager.localeText;

  return [
    if (column.frozen.isFrozen == true)
      _buildMenuItem(
        value: PlutoGridColumnMenuItem.unfreeze,
        text: localeText.unfreezeColumn,
        textColor: textColor,
      ),
    if (column.frozen.isFrozen != true) ...[
      _buildMenuItem(
        value: PlutoGridColumnMenuItem.freezeToStart,
        enabled: enoughFrozenColumnsWidth,
        text: localeText.freezeColumnToStart,
        textColor: enoughFrozenColumnsWidth ? textColor : disableTextColor,
      ),
      _buildMenuItem(
        value: PlutoGridColumnMenuItem.freezeToEnd,
        enabled: enoughFrozenColumnsWidth,
        text: localeText.freezeColumnToEnd,
        textColor: enoughFrozenColumnsWidth ? textColor : disableTextColor,
      ),
    ],
    const PopupMenuDivider(),
    _buildMenuItem(
      value: PlutoGridColumnMenuItem.autoFit,
      text: localeText.autoFitColumn,
      textColor: textColor,
    ),
    if (column.enableHideColumnMenuItem == true)
      _buildMenuItem(
        value: PlutoGridColumnMenuItem.hideColumn,
        text: localeText.hideColumn,
        textColor: textColor,
        enabled: stateManager.refColumns.length > 1,
      ),
    if (column.enableSetColumnsMenuItem == true)
      _buildMenuItem(
        value: PlutoGridColumnMenuItem.setColumns,
        text: localeText.setColumns,
        textColor: textColor,
      ),
    if (column.enableFilterMenuItem == true) ...[
      const PopupMenuDivider(),
      _buildMenuItem(
        value: PlutoGridColumnMenuItem.setFilter,
        text: localeText.setFilter,
        textColor: textColor,
      ),
      _buildMenuItem(
        value: PlutoGridColumnMenuItem.resetFilter,
        text: localeText.resetFilter,
        textColor: textColor,
        enabled: stateManager.hasFilter,
      ),
    ],
  ];
}

PopupMenuItem<PlutoGridColumnMenuItem> _buildMenuItem<PlutoGridColumnMenuItem>({
  required String text,
  required Color? textColor,
  bool enabled = true,
  PlutoGridColumnMenuItem? value,
}) {
  return PopupMenuItem<PlutoGridColumnMenuItem>(
    value: value,
    height: 36,
    enabled: enabled,
    child: Text(
      text,
      style: TextStyle(
        color: enabled ? textColor : textColor!.withOpacity(0.5),
        fontSize: 13,
      ),
    ),
  );
}

/// Items in the context menu on the right side of the column
enum PlutoGridColumnMenuItem {
  unfreeze,
  freezeToStart,
  freezeToEnd,
  hideColumn,
  setColumns,
  autoFit,
  setFilter,
  resetFilter,
}
