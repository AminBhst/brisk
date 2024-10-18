import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

/// Callback function to implement to add lazy pagination data.
typedef PlutoLazyPaginationFetch = Future<PlutoLazyPaginationResponse> Function(
    PlutoLazyPaginationRequest);

/// Request data for lazy pagination processing.
class PlutoLazyPaginationRequest {
  PlutoLazyPaginationRequest({
    required this.page,
    this.sortColumn,
    this.filterRows = const <PlutoRow>[],
  });

  /// Request page.
  final int page;

  /// If the sort condition is set, the column for which the sort is set.
  /// The value of [PlutoColumn.sort] is the sort status of the column.
  final PlutoColumn? sortColumn;

  /// Filtering status when filtering conditions are set.
  ///
  /// If this list is empty, filtering is not set.
  /// Filtering column, type, and filtering value are set in [PlutoRow.cells].
  ///
  /// [filterRows] can be converted to Map type as shown below.
  /// ```dart
  /// FilterHelper.convertRowsToMap(filterRows);
  ///
  /// // Assuming that filtering is set in column2, the following values are returned.
  /// // {column2: [{Contains: 123}]}
  /// ```
  ///
  /// The filter type in FilterHelper.defaultFilters is the default,
  /// If there is user-defined filtering,
  /// the title set by the user is returned as the filtering type.
  /// All filtering can change the value returned as a filtering type by changing the name property.
  /// In case of PlutoFilterTypeContains filter, if you change the static type name to include
  /// PlutoFilterTypeContains.name = 'include';
  /// {column2: [{include: abc}, {include: 123}]} will be returned.
  final List<PlutoRow> filterRows;
}

/// Response data for lazy pagination.
class PlutoLazyPaginationResponse {
  PlutoLazyPaginationResponse({
    required this.totalPage,
    required this.rows,
  });

  /// Total number of pages to create pagination buttons.
  final int totalPage;

  /// Rows to be added.
  final List<PlutoRow> rows;
}

/// Widget for processing lazy pagination.
///
/// ```dart
/// createFooter: (stateManager) {
///   return PlutoLazyPagination(
///     fetch: fetch,
///     stateManager: stateManager,
///   );
/// },
/// ```
class PlutoLazyPagination extends StatefulWidget {
  const PlutoLazyPagination({
    this.initialPage = 1,
    this.initialFetch = true,
    this.fetchWithSorting = true,
    this.fetchWithFiltering = true,
    this.pageSizeToMove,
    required this.fetch,
    required this.stateManager,
    super.key,
  });

  /// Set the first page.
  final int initialPage;

  /// Decide whether to call the fetch function first.
  final bool initialFetch;

  /// Decide whether to handle sorting in the fetch function.
  /// Default is true.
  /// If this value is false, the list is sorted with the current grid loaded.
  final bool fetchWithSorting;

  /// Decide whether to handle filtering in the fetch function.
  /// Default is true.
  /// If this value is false,
  /// the list is filtered while it is currently loaded in the grid.
  final bool fetchWithFiltering;

  /// Set the number of moves to the previous or next page button.
  ///
  /// Default is null.
  /// Moves the page as many as the number of page buttons currently displayed.
  ///
  /// If this value is set to 1, the next previous page is moved by one page.
  final int? pageSizeToMove;

  /// A callback function that returns the data to be added.
  final PlutoLazyPaginationFetch fetch;

  final PlutoGridStateManager stateManager;

  @override
  State<PlutoLazyPagination> createState() => _PlutoLazyPaginationState();
}

class _PlutoLazyPaginationState extends State<PlutoLazyPagination> {
  late final StreamSubscription<PlutoGridEvent> _events;

  int _page = 1;

  int _totalPage = 0;

  bool _isFetching = false;

  PlutoGridStateManager get stateManager => widget.stateManager;

  @override
  void initState() {
    super.initState();

    _page = widget.initialPage;

    if (widget.fetchWithSorting) {
      stateManager.setSortOnlyEvent(true);
    }

    if (widget.fetchWithFiltering) {
      stateManager.setFilterOnlyEvent(true);
    }

    _events = stateManager.eventManager!.listener(_eventListener);

    if (widget.initialFetch) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        setPage(widget.initialPage);
      });
    }
  }

  @override
  void dispose() {
    _events.cancel();

    super.dispose();
  }

  void _eventListener(PlutoGridEvent event) {
    if (event is PlutoGridChangeColumnSortEvent ||
        event is PlutoGridSetColumnFilterEvent) {
      setPage(1);
    }
  }

  void setPage(int page) async {
    if (_isFetching) return;

    _isFetching = true;

    stateManager.setShowLoading(true, level: PlutoGridLoadingLevel.rows);

    widget
        .fetch(
      PlutoLazyPaginationRequest(
        page: page,
        sortColumn: stateManager.getSortedColumn,
        filterRows: stateManager.filterRows,
      ),
    )
        .then((data) {
      stateManager.scroll.bodyRowsVertical!.jumpTo(0);

      stateManager.refRows.clearFromOriginal();
      stateManager.insertRows(0, data.rows);

      setState(() {
        _page = page;

        _totalPage = data.totalPage;

        _isFetching = false;
      });

      stateManager.setShowLoading(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return _PaginationWidget(
      iconColor: stateManager.style.iconColor,
      disabledIconColor: stateManager.style.disabledIconColor,
      activatedColor: stateManager.style.activatedBorderColor,
      iconSize: stateManager.style.iconSize,
      height: stateManager.footerHeight,
      page: _page,
      totalPage: _totalPage,
      pageSizeToMove: widget.pageSizeToMove,
      setPage: setPage,
    );
  }
}

class _PaginationWidget extends StatefulWidget {
  const _PaginationWidget({
    required this.iconColor,
    required this.disabledIconColor,
    required this.activatedColor,
    required this.iconSize,
    required this.height,
    this.page = 1,
    required this.totalPage,
    this.pageSizeToMove,
    required this.setPage,
  });

  final Color iconColor;

  final Color disabledIconColor;

  final Color activatedColor;

  final double iconSize;

  final double height;

  final int page;

  final int totalPage;

  /// Set the number of moves to the previous or next page button.
  ///
  /// Default is null.
  /// Moves the page as many as the number of page buttons currently displayed.
  ///
  /// If this value is set to 1, the next previous page is moved by one page.
  final int? pageSizeToMove;

  final void Function(int page) setPage;

  @override
  State<_PaginationWidget> createState() => _PaginationWidgetState();
}

class _PaginationWidgetState extends State<_PaginationWidget> {
  double _maxWidth = 0;

  final _iconSplashRadius = PlutoGridSettings.rowHeight / 2;

  bool get _isFirstPage => widget.page < 2;

  bool get _isLastPage => widget.page > widget.totalPage - 1;

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

    var start = widget.page - itemSizeGap;

    if (widget.page + _itemSize > widget.totalPage) {
      start -= _itemSize + widget.page - widget.totalPage;
    }

    return start < 0 ? 0 : start;
  }

  int get _endPage {
    final itemSizeGap = _itemSize + 1;

    var end = widget.page + _itemSize;

    if (widget.page - itemSizeGap < 0) {
      end += itemSizeGap - widget.page;
    }

    return end > widget.totalPage ? widget.totalPage : end;
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
    int beforePage = widget.page - _pageSizeToMove;

    if (beforePage < 1) {
      beforePage = 1;
    }

    _movePage(beforePage);
  }

  void _nextPage() {
    int nextPage = widget.page + _pageSizeToMove;

    if (nextPage > widget.totalPage) {
      nextPage = widget.totalPage;
    }

    _movePage(nextPage);
  }

  void _lastPage() {
    _movePage(widget.totalPage);
  }

  void _movePage(int page) {
    widget.setPage(page);
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
      fontSize: isCurrentIndex ? widget.iconSize : null,
      color: isCurrentIndex ? widget.activatedColor : widget.iconColor,
    );
  }

  Widget _makeNumberButton(int index) {
    var pageFromIndex = index + 1;

    var isCurrentIndex = widget.page == pageFromIndex;

    return TextButton(
      onPressed: () {
        _movePage(pageFromIndex);
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

        return SizedBox(
          width: size.maxWidth,
          height: widget.height,
          child: Align(
            alignment: Alignment.center,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  IconButton(
                    onPressed: _isFirstPage ? null : _firstPage,
                    icon: const Icon(Icons.first_page),
                    color: widget.iconColor,
                    disabledColor: widget.disabledIconColor,
                    splashRadius: _iconSplashRadius,
                    mouseCursor: _isFirstPage
                        ? SystemMouseCursors.basic
                        : SystemMouseCursors.click,
                  ),
                  IconButton(
                    onPressed: _isFirstPage ? null : _beforePage,
                    icon: const Icon(Icons.navigate_before),
                    color: widget.iconColor,
                    disabledColor: widget.disabledIconColor,
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
                    color: widget.iconColor,
                    disabledColor: widget.disabledIconColor,
                    splashRadius: _iconSplashRadius,
                    mouseCursor: _isLastPage
                        ? SystemMouseCursors.basic
                        : SystemMouseCursors.click,
                  ),
                  IconButton(
                    onPressed: _isLastPage ? null : _lastPage,
                    icon: const Icon(Icons.last_page),
                    color: widget.iconColor,
                    disabledColor: widget.disabledIconColor,
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
