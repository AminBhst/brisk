import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

abstract class IScrollState {
  /// Controller to control the scrolling of the grid.
  PlutoGridScrollController get scroll;

  bool get isHorizontalOverScrolled;

  double get correctHorizontalOffset;

  Offset get directionalScrollEdgeOffset;

  Offset toDirectionalOffset(Offset offset);

  /// [direction] Scroll direction
  /// [offset] Scroll position
  void scrollByDirection(PlutoMoveDirection direction, double offset);

  /// Whether the cell can be scrolled when moving.
  bool canHorizontalCellScrollByDirection(
    PlutoMoveDirection direction,
    PlutoColumn columnToMove,
  );

  /// Scroll to [rowIdx] position.
  void moveScrollByRow(PlutoMoveDirection direction, int? rowIdx);

  /// Scroll to [columnIdx] position.
  void moveScrollByColumn(PlutoMoveDirection direction, int? columnIdx);

  bool needMovingScroll(Offset offset, PlutoMoveDirection move);

  void updateCorrectScrollOffset();

  void updateScrollViewport();

  void resetScrollToZero();
}

mixin ScrollState implements IPlutoGridState {
  @override
  bool get isHorizontalOverScrolled =>
      scroll.bodyRowsHorizontal!.offset > scroll.maxScrollHorizontal ||
      scroll.bodyRowsHorizontal!.offset < 0;

  @override
  double get correctHorizontalOffset {
    if (isHorizontalOverScrolled) {
      return scroll.horizontalOffset < 0 ? 0 : scroll.maxScrollHorizontal;
    }

    return scroll.horizontalOffset;
  }

  @override
  Offset get directionalScrollEdgeOffset =>
      isLTR ? Offset.zero : Offset(gridGlobalOffset!.dx, 0);

  @override
  Offset toDirectionalOffset(Offset offset) {
    if (isLTR) {
      return offset;
    }

    return Offset(
      (maxWidth! + gridGlobalOffset!.dx) - offset.dx,
      offset.dy,
    );
  }

  @override
  void scrollByDirection(PlutoMoveDirection direction, double offset) {
    if (direction.vertical) {
      scroll.vertical!.jumpTo(offset);
    } else {
      scroll.horizontal!.jumpTo(offset);
    }
  }

  @override
  bool canHorizontalCellScrollByDirection(
    PlutoMoveDirection direction,
    PlutoColumn columnToMove,
  ) {
    // 고정 컬럼이 보여지는 상태에서 이동 할 컬럼이 고정 컬럼인 경우 스크롤 불필요
    return !(showFrozenColumn == true && columnToMove.frozen.isFrozen);
  }

  @override
  void moveScrollByRow(PlutoMoveDirection direction, int? rowIdx) {
    if (!direction.vertical) {
      return;
    }

    final double rowSize = rowTotalHeight;

    final double screenOffset = scroll.verticalOffset +
        columnRowContainerHeight -
        columnGroupHeight -
        columnHeight -
        columnFilterHeight -
        columnFooterHeight -
        PlutoGridSettings.rowBorderWidth;

    double offsetToMove =
        direction.isUp ? (rowIdx! - 1) * rowSize : (rowIdx! + 1) * rowSize;

    final bool inScrollStart = scroll.verticalOffset <= offsetToMove;

    final bool inScrollEnd = offsetToMove + rowSize <= screenOffset;

    if (inScrollStart && inScrollEnd) {
      return;
    } else if (inScrollEnd == false) {
      offsetToMove =
          scroll.verticalOffset + offsetToMove + rowSize - screenOffset;
    }

    scrollByDirection(direction, offsetToMove);
  }

  @override
  void moveScrollByColumn(PlutoMoveDirection direction, int? columnIdx) {
    if (!direction.horizontal) {
      return;
    }

    final columnIndexes = columnIndexesByShowFrozen;

    final PlutoColumn columnToMove =
        refColumns[columnIndexes[columnIdx! + direction.offset]];

    if (!canHorizontalCellScrollByDirection(
      direction,
      columnToMove,
    )) {
      return;
    }

    double offsetToMove = columnToMove.startPosition;

    final double? screenOffset = showFrozenColumn == true
        ? maxWidth! - leftFrozenColumnsWidth - rightFrozenColumnsWidth
        : maxWidth;

    if (direction.isRight) {
      if (offsetToMove > scroll.horizontal!.offset) {
        offsetToMove -= screenOffset!;
        offsetToMove += columnToMove.width;
        offsetToMove += scrollOffsetByFrozenColumn;

        if (offsetToMove < scroll.horizontal!.offset) {
          return;
        }
      }
    } else {
      final offsetToNeed = offsetToMove + columnToMove.width;

      final currentOffset = screenOffset! + scroll.horizontal!.offset;

      if (offsetToNeed > currentOffset) {
        offsetToMove = scroll.horizontal!.offset + offsetToNeed - currentOffset;
        offsetToMove += scrollOffsetByFrozenColumn;
      } else if (offsetToMove > scroll.horizontal!.offset) {
        return;
      }
    }

    scrollByDirection(direction, offsetToMove);
  }

  @override
  bool needMovingScroll(Offset? offset, PlutoMoveDirection move) {
    if (selectingMode.isNone) {
      return false;
    }

    switch (move) {
      case PlutoMoveDirection.left:
        return offset!.dx < bodyLeftScrollOffset;
      case PlutoMoveDirection.right:
        return offset!.dx > bodyRightScrollOffset;
      case PlutoMoveDirection.up:
        return offset!.dy < bodyUpScrollOffset;
      case PlutoMoveDirection.down:
        return offset!.dy > bodyDownScrollOffset;
    }
  }

  @override
  void updateCorrectScrollOffset() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (scroll.bodyRowsHorizontal?.hasClients != true) {
        return;
      }

      if (isHorizontalOverScrolled) {
        scroll.horizontal!.animateTo(
          correctHorizontalOffset,
          curve: Curves.ease,
          duration: const Duration(milliseconds: 300),
        );
      }
    });
  }

  @override
  void updateScrollViewport() {
    if (maxWidth == null ||
        scroll.bodyRowsHorizontal?.position.hasViewportDimension != true) {
      return;
    }

    final double bodyWidth = maxWidth! - bodyLeftOffset - bodyRightOffset;

    scroll.horizontal!.applyViewportDimension(bodyWidth);

    updateCorrectScrollOffset();
  }

  /// Called to fix an error
  /// that the screen cannot be touched due to an incorrect scroll range
  /// when resizing the screen.
  @override
  void resetScrollToZero() {
    if ((scroll.bodyRowsVertical?.offset ?? 0) <= 0) {
      scroll.bodyRowsVertical?.jumpTo(0);
    }

    if ((scroll.bodyRowsHorizontal?.offset ?? 0) <= 0) {
      scroll.bodyRowsHorizontal?.jumpTo(0);
    }
  }
}
