import 'package:pluto_grid/pluto_grid.dart';

/// Automatically adjust column width or manage width adjustment mode.
abstract class IColumnSizingState {
  /// Refers to the value set in [PlutoGridConfiguration].
  PlutoGridColumnSizeConfig get columnSizeConfig;

  /// Automatically adjust the column width at the start of the grid
  /// or when the grid width is changed.
  PlutoAutoSizeMode get columnsAutoSizeMode;

  /// Condition for changing column width.
  PlutoResizeMode get columnsResizeMode;

  /// Whether [columnsAutoSizeMode] is enabled.
  bool get enableColumnsAutoSize;

  /// Whether [columnsAutoSizeMode] should be applied while [columnsAutoSizeMode] is enabled.
  ///
  /// After changing the state of the column,
  /// set whether to apply [columnsAutoSizeMode] again according to the value below.
  /// [PlutoGridColumnSizeConfig.restoreAutoSizeAfterHideColumn]
  /// [PlutoGridColumnSizeConfig.restoreAutoSizeAfterFrozenColumn]
  /// [PlutoGridColumnSizeConfig.restoreAutoSizeAfterMoveColumn]
  /// [PlutoGridColumnSizeConfig.restoreAutoSizeAfterInsertColumn]
  /// [PlutoGridColumnSizeConfig.restoreAutoSizeAfterRemoveColumn]
  ///
  /// If the above values are set to false,
  /// [columnsAutoSizeMode] is not applied after changing the column state.
  ///
  /// In this case, if the width of the grid is changed again or there is a layout change,
  /// it will be activated again.
  bool get activatedColumnsAutoSize;

  void activateColumnsAutoSize();

  void deactivateColumnsAutoSize();

  PlutoAutoSize getColumnsAutoSizeHelper({
    required Iterable<PlutoColumn> columns,
    required double maxWidth,
  });

  PlutoResize getColumnsResizeHelper({
    required List<PlutoColumn> columns,
    required PlutoColumn column,
    required double offset,
  });

  void setColumnSizeConfig(PlutoGridColumnSizeConfig config);
}

class _State {
  bool? _activatedColumnsAutoSize;
}

mixin ColumnSizingState implements IPlutoGridState {
  final _State _state = _State();

  @override
  PlutoGridColumnSizeConfig get columnSizeConfig => configuration.columnSize;

  @override
  PlutoAutoSizeMode get columnsAutoSizeMode => columnSizeConfig.autoSizeMode;

  @override
  PlutoResizeMode get columnsResizeMode => columnSizeConfig.resizeMode;

  @override
  bool get enableColumnsAutoSize => !columnsAutoSizeMode.isNone;

  @override
  bool get activatedColumnsAutoSize =>
      enableColumnsAutoSize && _state._activatedColumnsAutoSize != false;

  @override
  void activateColumnsAutoSize() {
    _state._activatedColumnsAutoSize = true;
  }

  @override
  void deactivateColumnsAutoSize() {
    _state._activatedColumnsAutoSize = false;
  }

  @override
  PlutoAutoSize getColumnsAutoSizeHelper({
    required Iterable<PlutoColumn> columns,
    required double maxWidth,
  }) {
    assert(columnsAutoSizeMode.isNone == false);
    assert(columns.isNotEmpty);

    return PlutoAutoSizeHelper.items<PlutoColumn>(
      maxSize: maxWidth,
      items: columns,
      isSuppressed: (e) => e.suppressedAutoSize,
      getItemSize: (e) => e.width,
      getItemMinSize: (e) => e.minWidth,
      setItemSize: (e, size) => e.width = size,
      mode: columnsAutoSizeMode,
    );
  }

  @override
  PlutoResize getColumnsResizeHelper({
    required List<PlutoColumn> columns,
    required PlutoColumn column,
    required double offset,
  }) {
    assert(!columnsResizeMode.isNone && !columnsResizeMode.isNormal);
    assert(columns.isNotEmpty);

    return PlutoResizeHelper.items<PlutoColumn>(
      offset: offset,
      items: columns,
      isMainItem: (e) => e.key == column.key,
      getItemSize: (e) => e.width,
      getItemMinSize: (e) => e.minWidth,
      setItemSize: (e, size) => e.width = size,
      mode: columnsResizeMode,
    );
  }

  @override
  void setColumnSizeConfig(PlutoGridColumnSizeConfig config) {
    setConfiguration(
      configuration.copyWith(columnSize: config),
      updateLocale: false,
      applyColumnFilter: false,
    );

    if (enableColumnsAutoSize) {
      activateColumnsAutoSize();

      notifyResizingListeners();
    }
  }
}
