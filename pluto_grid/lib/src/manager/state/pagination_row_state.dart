import 'package:pluto_grid/pluto_grid.dart';

abstract class IPaginationRowState {
  int get page;

  int get pageSize;

  int get pageRangeFrom;

  int get pageRangeTo;

  int get totalPage;

  bool get isPaginated;

  void setPageSize(int pageSize, {bool notify = true});

  void setPage(
    int page, {
    bool resetCurrentState = true,
    bool notify = true,
  });

  void resetPage({
    bool resetCurrentState = true,
    bool notify = true,
  });
}

class _State {
  int _pageSize = PaginationRowState.defaultPageSize;

  int _page = 1;
}

mixin PaginationRowState implements IPlutoGridState {
  final _State _state = _State();

  static int defaultPageSize = 40;

  final FilteredListRange _range = FilteredListRange(0, defaultPageSize);

  Iterable<PlutoRow> get _rowsToPaginate {
    return enabledRowGroups
        ? refRows.filterOrOriginalList.where(isMainRow)
        : refRows.filterOrOriginalList;
  }

  int get _length => _rowsToPaginate.length;

  int get _adjustPage {
    if (page > totalPage) {
      return totalPage;
    }

    if (page < 1 && totalPage > 0) {
      return 1;
    }

    return page;
  }

  @override
  int get page => _state._page;

  @override
  int get pageSize => _state._pageSize;

  @override
  int get pageRangeFrom => _range.from;

  @override
  int get pageRangeTo => _range.to;

  @override
  int get totalPage => (_length / pageSize).ceil();

  @override
  bool get isPaginated => refRows.hasRange;

  @override
  void setPageSize(int pageSize, {bool notify = true}) {
    _state._pageSize = pageSize;

    notifyListeners(notify, setPageSize.hashCode);
  }

  @override
  void setPage(
    int page, {
    bool resetCurrentState = true,
    bool notify = true,
  }) {
    _state._page = page;

    int from = (page - 1) * pageSize;

    if (from < 0) {
      from = 0;
    }

    int to = page * pageSize;

    if (to > _length) {
      to = _length;
    }

    if (enabledRowGroups) {
      PlutoRow lastRow(PlutoRow row) {
        return isExpandedGroupedRow(row) &&
                row.type.group.children.filterOrOriginalList.isNotEmpty
            ? lastRow(row.type.group.children.filterOrOriginalList.last)
            : row;
      }

      if (_rowsToPaginate.isEmpty) {
        from = 0;
        to = 0;
      } else {
        var fromRow = _rowsToPaginate.elementAt(from);

        var toRow = lastRow(_rowsToPaginate.elementAt(to - 1));

        from = refRows.filterOrOriginalList.indexOf(fromRow);

        to = refRows.filterOrOriginalList.indexOf(toRow) + 1;
      }
    }

    _range.setRange(from, to);

    refRows.setFilterRange(_range);

    if (resetCurrentState) {
      clearCurrentCell(notify: false);

      clearCurrentSelecting(notify: false);
    }

    notifyListeners(notify, setPage.hashCode);
  }

  @override
  void resetPage({
    bool resetCurrentState = true,
    bool notify = true,
  }) {
    setPage(
      _adjustPage,
      resetCurrentState: resetCurrentState,
      notify: notify,
    );
  }
}
