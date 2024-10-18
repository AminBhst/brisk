import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../ui.dart';

class PlutoColumnFilter extends PlutoStatefulWidget {
  final PlutoGridStateManager stateManager;

  final PlutoColumn column;

  PlutoColumnFilter({
    required this.stateManager,
    required this.column,
    Key? key,
  }) : super(key: ValueKey('column_filter_${column.key}'));

  @override
  PlutoColumnFilterState createState() => PlutoColumnFilterState();
}

class PlutoColumnFilterState extends PlutoStateWithChange<PlutoColumnFilter> {
  List<PlutoRow> _filterRows = [];

  String _text = '';

  bool _enabled = false;

  late final StreamSubscription _event;

  late final FocusNode _focusNode;

  late final TextEditingController _controller;

  String get _filterValue {
    return _filterRows.isEmpty
        ? ''
        : _filterRows.first.cells[FilterHelper.filterFieldValue]!.value
            .toString();
  }

  bool get _hasCompositeFilter {
    return _filterRows.length > 1 ||
        stateManager
            .filterRowsByField(FilterHelper.filterFieldAllColumns)
            .isNotEmpty;
  }

  InputBorder get _border => OutlineInputBorder(
        borderSide: BorderSide(
            color: stateManager.configuration.style.borderColor, width: 0.0),
        borderRadius: BorderRadius.zero,
      );

  InputBorder get _enabledBorder => OutlineInputBorder(
        borderSide: BorderSide(
            color: stateManager.configuration.style.activatedBorderColor,
            width: 0.0),
        borderRadius: BorderRadius.zero,
      );

  InputBorder get _disabledBorder => OutlineInputBorder(
        borderSide: BorderSide(
            color: stateManager.configuration.style.inactivatedBorderColor,
            width: 0.0),
        borderRadius: BorderRadius.zero,
      );

  Color get _textFieldColor => _enabled
      ? stateManager.configuration.style.cellColorInEditState
      : stateManager.configuration.style.cellColorInReadOnlyState;

  EdgeInsets get _padding =>
      widget.column.filterPadding ??
      stateManager.configuration.style.defaultColumnFilterPadding;

  @override
  PlutoGridStateManager get stateManager => widget.stateManager;

  @override
  initState() {
    super.initState();

    _focusNode = FocusNode(onKey: _handleOnKey);

    widget.column.setFilterFocusNode(_focusNode);

    _controller = TextEditingController(text: _filterValue);

    _event = stateManager.eventManager!.listener(_handleFocusFromRows);

    updateState(PlutoNotifierEventForceUpdate.instance);
  }

  @override
  dispose() {
    _event.cancel();

    _controller.dispose();

    _focusNode.dispose();

    super.dispose();
  }

  @override
  void updateState(PlutoNotifierEvent event) {
    _filterRows = update<List<PlutoRow>>(
      _filterRows,
      stateManager.filterRowsByField(widget.column.field),
      compare: listEquals,
    );

    if (_focusNode.hasPrimaryFocus != true) {
      _text = update<String>(_text, _filterValue);

      if (changed) {
        _controller.text = _text;
      }
    }

    _enabled = update<bool>(
      _enabled,
      widget.column.enableFilterMenuItem && !_hasCompositeFilter,
    );
  }

  void _moveDown({required bool focusToPreviousCell}) {
    if (!focusToPreviousCell || stateManager.currentCell == null) {
      stateManager.setCurrentCell(
        stateManager.refRows.first.cells[widget.column.field],
        0,
        notify: false,
      );

      stateManager.scrollByDirection(PlutoMoveDirection.down, 0);
    }

    stateManager.setKeepFocus(true, notify: false);

    stateManager.gridFocusNode.requestFocus();

    stateManager.notifyListeners();
  }

  KeyEventResult _handleOnKey(FocusNode node, RawKeyEvent event) {
    var keyManager = PlutoKeyManagerEvent(
      focusNode: node,
      event: event,
    );

    if (keyManager.isKeyUpEvent) {
      return KeyEventResult.handled;
    }

    final handleMoveDown =
        (keyManager.isDown || keyManager.isEnter || keyManager.isEsc) &&
            stateManager.refRows.isNotEmpty;

    final handleMoveHorizontal = keyManager.isTab ||
        (_controller.text.isEmpty && keyManager.isHorizontal);

    final skip = !(handleMoveDown || handleMoveHorizontal || keyManager.isF3);

    if (skip) {
      if (keyManager.isUp) {
        return KeyEventResult.handled;
      }

      return stateManager.keyManager!.eventResult.skip(
        KeyEventResult.ignored,
      );
    }

    if (handleMoveDown) {
      _moveDown(focusToPreviousCell: keyManager.isEsc);
    } else if (handleMoveHorizontal) {
      stateManager.nextFocusOfColumnFilter(
        widget.column,
        reversed: keyManager.isLeft || keyManager.isShiftPressed,
      );
    } else if (keyManager.isF3) {
      stateManager.showFilterPopup(
        _focusNode.context!,
        calledColumn: widget.column,
        onClosed: () {
          stateManager.setKeepFocus(true, notify: false);
          _focusNode.requestFocus();
        },
      );
    }

    return KeyEventResult.handled;
  }

  void _handleFocusFromRows(PlutoGridEvent plutoEvent) {
    if (!_enabled) {
      return;
    }

    if (plutoEvent is PlutoGridCannotMoveCurrentCellEvent &&
        plutoEvent.direction.isUp) {
      var isCurrentColumn = widget
              .stateManager
              .refColumns[stateManager.columnIndexesByShowFrozen[
                  plutoEvent.cellPosition.columnIdx!]]
              .key ==
          widget.column.key;

      if (isCurrentColumn) {
        stateManager.clearCurrentCell(notify: false);
        stateManager.setKeepFocus(false);
        _focusNode.requestFocus();
      }
    }
  }

  void _handleOnTap() {
    stateManager.setKeepFocus(false);
  }

  void _handleOnChanged(String changed) {
    stateManager.eventManager!.addEvent(
      PlutoGridChangeColumnFilterEvent(
        column: widget.column,
        filterType: widget.column.defaultFilter,
        filterValue: changed,
        debounceMilliseconds:
            stateManager.configuration.columnFilter.debounceMilliseconds,
      ),
    );
  }

  void _handleOnEditingComplete() {
    // empty for ignore event of OnEditingComplete.
  }

  @override
  Widget build(BuildContext context) {
    final style = stateManager.style;

    return SizedBox(
      height: stateManager.columnFilterHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: BorderDirectional(
            top: BorderSide(color: style.borderColor),
            end: style.enableColumnBorderVertical
                ? BorderSide(color: style.borderColor)
                : BorderSide.none,
          ),
        ),
        child: Padding(
          padding: _padding,
          child: Center(
            child: TextField(
              focusNode: _focusNode,
              controller: _controller,
              enabled: _enabled,
              style: style.cellTextStyle,
              onTap: _handleOnTap,
              onChanged: _handleOnChanged,
              onEditingComplete: _handleOnEditingComplete,
              decoration: InputDecoration(
                hintText: _enabled ? widget.column.defaultFilter.title : '',
                filled: true,
                fillColor: _textFieldColor,
                border: _border,
                enabledBorder: _border,
                disabledBorder: _disabledBorder,
                focusedBorder: _enabledBorder,
                contentPadding: const EdgeInsets.all(5),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
