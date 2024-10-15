import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

abstract class ILayoutState {
  ChangeNotifier get resizingChangeNotifier;

  /// Screen width
  double? get maxWidth;

  /// Screen height
  double? get maxHeight;

  /// grid header height
  double get headerHeight;

  /// grid footer height
  double get footerHeight;

  double get columnRowContainerHeight;

  double get rowContainerHeight;

  /// Global offset of Grid.
  Offset? get gridGlobalOffset;

  /// Whether to apply a frozen column according to the screen size.
  /// true : If there is a frozen column, the frozen column is exposed.
  /// false : If there is a frozen column but the screen is narrow, it is exposed as a normal column.
  bool get showFrozenColumn;

  bool get showColumnTitle;

  bool get showColumnFooter;

  bool get showColumnFilter;

  bool get showHeader;

  bool get showFooter;

  bool get showLoading;

  PlutoGridLoadingLevel get loadingLevel;

  bool get hasLeftFrozenColumns;

  bool get hasRightFrozenColumns;

  double get headerBottomOffset;

  double get footerTopOffset;

  double get columnHeight;

  double get columnFooterHeight;

  double get columnGroupHeight;

  double get columnFilterHeight;

  double get columnBottomOffset;

  double get rowsTopOffset;

  double get rowHeight;

  double get rowTotalHeight;

  double get bodyTopOffset;

  double get bodyLeftOffset;

  double get bodyRightOffset;

  double get bodyLeftScrollOffset;

  double get bodyRightScrollOffset;

  double get bodyUpScrollOffset;

  double get bodyDownScrollOffset;

  double get leftFrozenRightOffset;

  double get rightFrozenLeftOffset;

  double get rightBlankOffset;

  double get scrollOffsetByFrozenColumn;

  TextDirection get textDirection;

  bool get isLTR;

  bool get isRTL;

  /// Update screen size information when LayoutBuilder builds.
  void setLayout(BoxConstraints size);

  void setShowColumnTitle(bool flag, {bool notify = true});

  void setShowColumnFooter(bool flag, {bool notify = true});

  void setShowColumnFilter(bool flag, {bool notify = true});

  void setShowLoading(
    bool flag, {
    PlutoGridLoadingLevel level = PlutoGridLoadingLevel.grid,
    bool notify = true,
  });

  void resetShowFrozenColumn();

  bool shouldShowFrozenColumns(double width);

  bool enoughFrozenColumnsWidth(double width);

  void notifyResizingListeners();

  void notifyChangedShowFrozenColumn();

  void setTextDirection(TextDirection textDirection);

  @visibleForTesting
  void setGridGlobalOffset(Offset offset);
}

class _State {
  double? _maxWidth;

  double? _maxHeight;

  double? _headerHeight;

  double? _footerHeight;

  double? _columnFooterHeight;

  Offset? _gridGlobalOffset;

  bool? _showFrozenColumn;

  bool? _showColumnTitle = true;

  bool? _showColumnFooter = false;

  bool? _showColumnFilter;

  bool? _showLoading;

  PlutoGridLoadingLevel _loadingLevel = PlutoGridLoadingLevel.grid;

  TextDirection _textDirection = TextDirection.ltr;
}

mixin LayoutState implements IPlutoGridState {
  final _State _state = _State();

  @override
  ChangeNotifier get resizingChangeNotifier => _resizingChangeNotifier;

  final ChangeNotifier _resizingChangeNotifier = ChangeNotifier();

  @override
  double? get maxWidth => _state._maxWidth;

  @override
  double? get maxHeight => _state._maxHeight;

  @override
  double get headerHeight {
    if (createHeader == null) {
      return 0;
    }

    return _state._headerHeight == null
        ? PlutoGridSettings.rowTotalHeight
        : _state._headerHeight!;
  }

  set headerHeight(double value) {
    _state._headerHeight = value;
  }

  @override
  double get footerHeight {
    if (createFooter == null) {
      return 0;
    }

    return _state._footerHeight == null
        ? PlutoGridSettings.rowTotalHeight
        : _state._footerHeight!;
  }

  set footerHeight(double value) {
    _state._footerHeight = value;
  }

  @override
  double get columnFooterHeight {
    if (!showColumnFooter) {
      return 0;
    }

    return _state._columnFooterHeight == null
        ? PlutoGridSettings.rowTotalHeight
        : _state._columnFooterHeight!;
  }

  set columnFooterHeight(double value) {
    _state._columnFooterHeight = value;
  }

  @override
  double get columnRowContainerHeight =>
      maxHeight! - headerHeight - footerHeight;

  @override
  double get rowContainerHeight => maxHeight! - rowsTopOffset - footerHeight;

  @override
  Offset? get gridGlobalOffset {
    final RenderBox? gridRenderBox =
        gridKey.currentContext?.findRenderObject() as RenderBox?;

    if (gridRenderBox == null) {
      return _state._gridGlobalOffset;
    }

    _state._gridGlobalOffset = gridRenderBox.localToGlobal(Offset.zero);

    return _state._gridGlobalOffset;
  }

  @override
  bool get showFrozenColumn => _state._showFrozenColumn == true;

  @override
  bool get showColumnTitle => _state._showColumnTitle == true;

  @override
  bool get showColumnFooter => _state._showColumnFooter == true;

  @override
  bool get showColumnFilter => _state._showColumnFilter == true;

  @override
  bool get showHeader => createHeader != null;

  @override
  bool get showFooter => createFooter != null;

  @override
  bool get showLoading => _state._showLoading == true;

  @override
  PlutoGridLoadingLevel get loadingLevel => _state._loadingLevel;

  @override
  bool get hasLeftFrozenColumns =>
      refColumns.firstWhereOrNull((e) => e.frozen.isStart) != null;

  @override
  bool get hasRightFrozenColumns =>
      refColumns.firstWhereOrNull((e) => e.frozen.isEnd) != null;

  @override
  double get headerBottomOffset => maxHeight! - headerHeight;

  @override
  double get footerTopOffset =>
      maxHeight! - footerHeight - PlutoGridSettings.totalShadowLineWidth;

  @override
  double get columnHeight =>
      showColumnTitle ? configuration.style.columnHeight : 0;

  @override
  double get columnGroupHeight =>
      showColumnGroups ? columnGroupDepth(columnGroups) * columnHeight : 0;

  @override
  double get columnFilterHeight =>
      showColumnFilter ? configuration.style.columnFilterHeight : 0;

  @override
  double get columnBottomOffset =>
      maxHeight! - rowsTopOffset - PlutoGridSettings.totalShadowLineWidth;

  @override
  double get rowsTopOffset =>
      headerHeight + columnGroupHeight + columnHeight + columnFilterHeight;

  @override
  double get rowHeight => configuration.style.rowHeight;

  @override
  double get rowTotalHeight => rowHeight + PlutoGridSettings.rowBorderWidth;

  @override
  double get bodyTopOffset =>
      gridGlobalOffset!.dy +
      PlutoGridSettings.gridPadding +
      headerHeight +
      PlutoGridSettings.gridBorderWidth +
      columnGroupHeight +
      columnHeight +
      columnFilterHeight;

  @override
  double get bodyLeftOffset {
    return (showFrozenColumn && leftFrozenColumnsWidth > 0)
        ? leftFrozenColumnsWidth + PlutoGridSettings.gridBorderWidth
        : 0;
  }

  @override
  double get bodyRightOffset {
    return (showFrozenColumn && rightFrozenColumnsWidth > 0)
        ? rightFrozenColumnsWidth + PlutoGridSettings.gridBorderWidth
        : 0;
  }

  @override
  double get bodyLeftScrollOffset {
    return gridGlobalOffset!.dx +
        PlutoGridSettings.gridPadding +
        PlutoGridSettings.gridBorderWidth +
        PlutoGridSettings.offsetScrollingFromEdge;
  }

  @override
  double get bodyRightScrollOffset {
    return (gridGlobalOffset!.dx + maxWidth!) -
        PlutoGridSettings.offsetScrollingFromEdge;
  }

  @override
  double get bodyUpScrollOffset {
    return bodyTopOffset + PlutoGridSettings.offsetScrollingFromEdge;
  }

  @override
  double get bodyDownScrollOffset {
    return gridGlobalOffset!.dy +
        maxHeight! -
        footerHeight -
        columnFooterHeight -
        PlutoGridSettings.offsetScrollingFromEdge;
  }

  @override
  double get leftFrozenRightOffset =>
      maxWidth! -
      leftFrozenColumnsWidth -
      PlutoGridSettings.totalShadowLineWidth;

  @override
  double get rightFrozenLeftOffset =>
      maxWidth! -
      rightFrozenColumnsWidth -
      PlutoGridSettings.totalShadowLineWidth;

  @override
  double get rightBlankOffset =>
      rightFrozenLeftOffset -
      leftFrozenColumnsWidth -
      bodyColumnsWidth +
      PlutoGridSettings.totalShadowLineWidth +
      scroll.horizontal!.offset;

  @override
  double get scrollOffsetByFrozenColumn {
    double offset = 0;

    if (showFrozenColumn) {
      offset +=
          leftFrozenColumnsWidth > 0 ? PlutoGridSettings.gridBorderWidth : 0;
      offset +=
          rightFrozenColumnsWidth > 0 ? PlutoGridSettings.gridBorderWidth : 0;
    }

    return offset;
  }

  @override
  TextDirection get textDirection => _state._textDirection;

  @override
  bool get isLTR => textDirection == TextDirection.ltr;

  @override
  bool get isRTL => textDirection == TextDirection.rtl;

  @override
  void setLayout(BoxConstraints size) {
    final firstLayout = maxWidth == null;
    final changedSize = _updateSize(size, firstLayout);
    final changedShowFrozen = _updateShowFrozenColumn(
      size: size,
      firstLayout: firstLayout,
      changedSize: changedSize,
    );
    final bool updateVisibility =
        changedShowFrozen || firstLayout || changedSize;
    final bool notifyResizing = !firstLayout && changedSize;

    if (updateVisibility) updateVisibilityLayout();

    if (notifyResizing) notifyResizingListeners();

    if (changedShowFrozen) notifyChangedShowFrozenColumn();

    if (enableColumnsAutoSize && !activatedColumnsAutoSize) {
      activateColumnsAutoSize();
    }
  }

  @override
  void setShowColumnTitle(bool flag, {bool notify = true}) {
    if (showColumnTitle == flag) {
      return;
    }

    _state._showColumnTitle = flag;

    notifyListeners(notify, setShowColumnTitle.hashCode);
  }

  @override
  void setShowColumnFooter(bool flag, {bool notify = true}) {
    if (showColumnFooter == flag) {
      return;
    }

    _state._showColumnFooter = flag;

    notifyListeners(notify, setShowColumnFooter.hashCode);
  }

  @override
  void setShowColumnFilter(bool flag, {bool notify = true}) {
    if (showColumnFilter == flag) {
      return;
    }

    _state._showColumnFilter = flag;

    notifyListeners(notify, setShowColumnFilter.hashCode);
  }

  @override
  void setShowLoading(
    bool flag, {
    PlutoGridLoadingLevel level = PlutoGridLoadingLevel.grid,
    bool notify = true,
  }) {
    if (showLoading == flag) {
      return;
    }

    _state._showLoading = flag;

    _state._loadingLevel = level;

    notifyListeners(notify, setShowLoading.hashCode);
  }

  @override
  void resetShowFrozenColumn() {
    _state._showFrozenColumn = shouldShowFrozenColumns(maxWidth!);
  }

  @override
  bool shouldShowFrozenColumns(double width) {
    final bool hasFrozenColumn =
        leftFrozenColumns.isNotEmpty || rightFrozenColumns.isNotEmpty;

    return hasFrozenColumn && enoughFrozenColumnsWidth(width);
  }

  @override
  bool enoughFrozenColumnsWidth(double width) {
    return width >
        (leftFrozenColumnsWidth +
            rightFrozenColumnsWidth +
            PlutoGridSettings.bodyMinWidth +
            PlutoGridSettings.totalShadowLineWidth);
  }

  @override
  void notifyResizingListeners() {
    updateVisibilityLayout(notify: true);

    _resizingChangeNotifier.notifyListeners();
  }

  @override
  void notifyChangedShowFrozenColumn() {
    notifyListeners(true, notifyChangedShowFrozenColumn.hashCode);
  }

  @override
  void setTextDirection(TextDirection textDirection) {
    _state._textDirection = textDirection;
  }

  @override
  @visibleForTesting
  void setGridGlobalOffset(Offset offset) {
    _state._gridGlobalOffset = offset;
  }

  bool _updateSize(BoxConstraints size, bool firstLayout) {
    final changedMaxWidth = !firstLayout && maxWidth != size.maxWidth;

    _state._maxWidth = size.maxWidth;
    _state._maxHeight = size.maxHeight;

    return changedMaxWidth;
  }

  bool _updateShowFrozenColumn({
    required BoxConstraints size,
    required bool firstLayout,
    required bool changedSize,
  }) {
    final updateShowFrozen = firstLayout || changedSize;

    final showFrozen = updateShowFrozen
        ? shouldShowFrozenColumns(size.maxWidth)
        : _state._showFrozenColumn!;

    final changedShowFrozen =
        !firstLayout && _state._showFrozenColumn != showFrozen;

    _state._showFrozenColumn = showFrozen;

    return changedShowFrozen;
  }
}
