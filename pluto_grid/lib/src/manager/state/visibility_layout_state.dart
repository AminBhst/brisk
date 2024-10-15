import 'package:pluto_grid/pluto_grid.dart';

abstract class IVisibilityLayoutState {
  /// Set [PlutoColumn.startPosition] to [PlutoColumn.width].
  ///
  /// Set the horizontal position of the columns in the left area, center area, and right area
  /// according to the [PlutoColumn.frozen] value in [PlutoColumn.startPosition].
  ///
  /// This method should be called in an operation that dynamically changes the position of a column.
  /// Example) resizeColumn, frozenColumn, hideColumn...
  ///
  /// [notify] is called false in the normal case.
  /// When [notify] is called true,
  /// the notifyListeners of scrollController is forcibly called when build is not triggered.
  void updateVisibilityLayout({bool notify = false});
}

mixin VisibilityLayoutState implements IPlutoGridState {
  @override
  void updateVisibilityLayout({bool notify = false}) {
    if (refColumns.isEmpty) return;

    _updateColumnSize();

    _updateColumnPosition();

    updateScrollViewport();

    if (notify) scroll.horizontal?.notifyListeners();
  }

  void _updateColumnSize() {
    if (!activatedColumnsAutoSize) return;

    double offset = 0;

    if (showFrozenColumn) {
      if (hasLeftFrozenColumns) {
        offset += PlutoGridSettings.gridBorderWidth;
      }

      if (hasRightFrozenColumns) {
        offset += PlutoGridSettings.gridBorderWidth;
      }
    }

    getColumnsAutoSizeHelper(
      columns: refColumns,
      maxWidth: maxWidth! - offset,
    ).update();
  }

  void _updateColumnPosition() {
    double leftX = 0;
    double bodyX = 0;
    double rightX = 0;

    for (final column in refColumns) {
      if (showFrozenColumn) {
        switch (column.frozen) {
          case PlutoColumnFrozen.none:
            column.startPosition = bodyX;
            bodyX += column.width;
            break;
          case PlutoColumnFrozen.start:
            column.startPosition = leftX;
            leftX += column.width;
            break;
          case PlutoColumnFrozen.end:
            column.startPosition = rightX;
            rightX += column.width;
            break;
        }
      } else {
        column.startPosition = bodyX;
        column.frozen = PlutoColumnFrozen.none;
        bodyX += column.width;
      }
    }
  }
}
