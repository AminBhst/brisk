import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../ui/ui.dart';

/// A widget for client-side pagination.
///
/// Server-side pagination can be implemented
/// using the [PlutoLazyPagination] or [PlutoInfinityScrollRows] widgets.
class PlutoPagination extends PlutoStatefulWidget {
  const PlutoPagination(
    this.stateManager, {
    this.pageSizeToMove,
    super.key,
  }) : assert(pageSizeToMove == null || pageSizeToMove > 0);

  final PlutoGridStateManager stateManager;

  /// Set the number of moves to the previous or next page button.
  ///
  /// Default is null.
  /// Moves the page as many as the number of page buttons currently displayed.
  ///
  /// If this value is set to 1, the next previous page is moved by one page.
  final int? pageSizeToMove;

  @override
  PlutoPaginationState createState() => PlutoPaginationState();
}

abstract class _PlutoPaginationStateWithChange
    extends PlutoStateWithChange<PlutoPagination> {
  late int page;

  late int totalPage;

  @override
  PlutoGridStateManager get stateManager => widget.stateManager;

  @override
  void initState() {
    super.initState();

    page = stateManager.page;

    totalPage = stateManager.totalPage;

    stateManager.setPage(page, notify: false);

    updateState(PlutoNotifierEventForceUpdate.instance);
  }

  @override
  void updateState(PlutoNotifierEvent event) {
    page = update<int>(
      page,
      stateManager.page,
    );

    totalPage = update<int>(
      totalPage,
      stateManager.totalPage,
    );
  }
}

class PlutoPaginationState extends _PlutoPaginationStateWithChange {
  late double _maxWidth;

  final _iconSplashRadius = PlutoGridSettings.rowHeight / 2;

  bool get _isFirstPage => page < 2;

  bool get _isLastPage => page > totalPage - 1;

  /// maxWidth < 450 : 1
  /// maxWidth >= 450 : 3
  /// maxWidth >= 550 : 5
  /// maxWidth >= 650 : 7
  int get _itemSize {
    final countItemSize = ((_maxWidth - 350) / 100).floor();

    return countItemSize < 0 ? 0 : min(countItemSize, 3);
  }

  int get _startPage {
    final itemSizeGap = _itemSize + 1;

    var start = page - itemSizeGap;

    if (page + _itemSize > totalPage) {
      start -= _itemSize + page - totalPage;
    }

    return start < 0 ? 0 : start;
  }

  int get _endPage {
    final itemSizeGap = _itemSize + 1;

    var end = page + _itemSize;

    if (page - itemSizeGap < 0) {
      end += itemSizeGap - page;
    }

    return end > totalPage ? totalPage : end;
  }

  List<int> get _pageNumbers {
    return List.generate(
      _endPage - _startPage,
      (index) => _startPage + index,
      growable: false,
    );
  }

  int get _pageSizeToMove {
    if (widget.pageSizeToMove == null) {
      return 1 + (_itemSize * 2);
    }

    return widget.pageSizeToMove!;
  }

  void _firstPage() {
    _movePage(1);
  }

  void _beforePage() {
    setState(() {
      page -= _pageSizeToMove;

      if (page < 1) {
        page = 1;
      }

      _movePage(page);
    });
  }

  void _nextPage() {
    setState(() {
      page += _pageSizeToMove;

      if (page > totalPage) {
        page = totalPage;
      }

      _movePage(page);
    });
  }

  void _lastPage() {
    _movePage(totalPage);
  }

  void _movePage(int page) {
    stateManager.setPage(page);
  }

  ButtonStyle _getNumberButtonStyle(bool isCurrentIndex) {
    return TextButton.styleFrom(
      disabledForegroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      padding: const EdgeInsets.fromLTRB(5, 0, 0, 10),
      backgroundColor: Colors.transparent,
    );
  }

  TextStyle _getNumberTextStyle(bool isCurrentIndex) {
    return TextStyle(
      fontSize:
          isCurrentIndex ? stateManager.configuration.style.iconSize : null,
      color: isCurrentIndex
          ? stateManager.configuration.style.activatedBorderColor
          : stateManager.configuration.style.iconColor,
    );
  }

  Widget _makeNumberButton(int index) {
    var pageFromIndex = index + 1;

    var isCurrentIndex = page == pageFromIndex;

    return TextButton(
      onPressed: () {
        stateManager.setPage(pageFromIndex);
      },
      style: _getNumberButtonStyle(isCurrentIndex),
      child: Text(
        pageFromIndex.toString(),
        style: _getNumberTextStyle(isCurrentIndex),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, size) {
        _maxWidth = size.maxWidth;

        final Color iconColor = stateManager.configuration.style.iconColor;

        final Color disabledIconColor =
            stateManager.configuration.style.disabledIconColor;

        return SizedBox(
          width: _maxWidth,
          height: stateManager.footerHeight,
          child: Align(
            alignment: Alignment.center,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  IconButton(
                    onPressed: _isFirstPage ? null : _firstPage,
                    icon: const Icon(Icons.first_page),
                    color: iconColor,
                    disabledColor: disabledIconColor,
                    splashRadius: _iconSplashRadius,
                    mouseCursor: _isFirstPage
                        ? SystemMouseCursors.basic
                        : SystemMouseCursors.click,
                  ),
                  IconButton(
                    onPressed: _isFirstPage ? null : _beforePage,
                    icon: const Icon(Icons.navigate_before),
                    color: iconColor,
                    disabledColor: disabledIconColor,
                    splashRadius: _iconSplashRadius,
                    mouseCursor: _isFirstPage
                        ? SystemMouseCursors.basic
                        : SystemMouseCursors.click,
                  ),
                  ..._pageNumbers
                      .map(_makeNumberButton)
                      .toList(growable: false),
                  IconButton(
                    onPressed: _isLastPage ? null : _nextPage,
                    icon: const Icon(Icons.navigate_next),
                    color: iconColor,
                    disabledColor: disabledIconColor,
                    splashRadius: _iconSplashRadius,
                    mouseCursor: _isLastPage
                        ? SystemMouseCursors.basic
                        : SystemMouseCursors.click,
                  ),
                  IconButton(
                    onPressed: _isLastPage ? null : _lastPage,
                    icon: const Icon(Icons.last_page),
                    color: iconColor,
                    disabledColor: disabledIconColor,
                    splashRadius: _iconSplashRadius,
                    mouseCursor: _isLastPage
                        ? SystemMouseCursors.basic
                        : SystemMouseCursors.click,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
