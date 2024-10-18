import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

typedef SetFilterPopupHandler = void Function(
    PlutoGridStateManager? stateManager);

class FilterHelper {
  /// A value to identify all column searches when searching filters.
  static const filterFieldAllColumns = 'plutoFilterAllColumns';

  /// The field name of the column that includes the field values of the column
  /// when searching for a filter.
  static const filterFieldColumn = 'column';

  /// The field name of the column including the filter type
  /// when searching for a filter.
  static const filterFieldType = 'type';

  /// The field name of the column containing the value to be searched
  /// when searching for a filter.
  static const filterFieldValue = 'value';

  static const List<PlutoFilterType> defaultFilters = [
    PlutoFilterTypeContains(),
    PlutoFilterTypeEquals(),
    PlutoFilterTypeStartsWith(),
    PlutoFilterTypeEndsWith(),
    PlutoFilterTypeGreaterThan(),
    PlutoFilterTypeGreaterThanOrEqualTo(),
    PlutoFilterTypeLessThan(),
    PlutoFilterTypeLessThanOrEqualTo(),
  ];

  /// Create a row to contain filter information.
  static PlutoRow createFilterRow({
    String? columnField,
    PlutoFilterType? filterType,
    String? filterValue,
  }) {
    return PlutoRow(
      cells: {
        filterFieldColumn:
            PlutoCell(value: columnField ?? filterFieldAllColumns),
        filterFieldType:
            PlutoCell(value: filterType ?? const PlutoFilterTypeContains()),
        filterFieldValue: PlutoCell(value: filterValue ?? ''),
      },
    );
  }

  /// Converts rows containing filter information into comparison functions.
  static FilteredListFilter<PlutoRow?>? convertRowsToFilter(
    List<PlutoRow?> rows,
    List<PlutoColumn>? enabledFilterColumns,
  ) {
    if (rows.isEmpty) {
      return null;
    }

    return (PlutoRow? row) {
      bool? flag;

      for (var e in rows) {
        final filterType = e!.cells[filterFieldType]!.value as PlutoFilterType?;

        if (e.cells[filterFieldColumn]!.value == filterFieldAllColumns) {
          bool? flagAllColumns;

          row!.cells.forEach((key, value) {
            var foundColumn = enabledFilterColumns!.firstWhereOrNull(
              (element) => element.field == key,
            );

            if (foundColumn != null) {
              flagAllColumns = compareOr(
                flagAllColumns,
                compareByFilterType(
                  filterType: filterType!,
                  base: value.value.toString(),
                  search: e.cells[filterFieldValue]!.value.toString(),
                  column: foundColumn,
                ),
              );
            }
          });

          flag = compareAnd(flag, flagAllColumns);
        } else {
          var foundColumn = enabledFilterColumns!.firstWhereOrNull(
            (element) => element.field == e.cells[filterFieldColumn]!.value,
          );

          if (foundColumn != null) {
            flag = compareAnd(
              flag,
              compareByFilterType(
                filterType: filterType!,
                base: row!.cells[e.cells[filterFieldColumn]!.value]!.value
                    .toString(),
                search: e.cells[filterFieldValue]!.value.toString(),
                column: foundColumn,
              ),
            );
          }
        }
      }

      return flag == true;
    };
  }

  /// Converts List<PlutoRow> type with filtering information to Map type.
  ///
  /// [allField] determines the key value of the filter applied to the entire scope.
  /// Default is all.
  ///
  /// ```dart
  /// // The return value below is an example of the condition
  /// in which two filtering is applied with the Contains type condition to all ranges.
  /// {all: [{Contains: abc}, {Contains: 123}]}
  ///
  /// // If filtering is applied to a column, the key is the field name of the column.
  /// {column1: [{Contains: abc}]}
  /// ```
  static Map<String, List<Map<String, String>>> convertRowsToMap(
    List<PlutoRow> filterRows, {
    String allField = 'all',
  }) {
    final map = <String, List<Map<String, String>>>{};

    if (filterRows.isEmpty) return map;

    for (final row in filterRows) {
      String columnField = row.cells[FilterHelper.filterFieldColumn]!.value;

      if (columnField == FilterHelper.filterFieldAllColumns) {
        columnField = allField;
      }

      final String filterType =
          (row.cells[FilterHelper.filterFieldType]!.value as PlutoFilterType)
              .title;

      final filterValue = row.cells[FilterHelper.filterFieldValue]!.value;

      if (map.containsKey(columnField)) {
        map[columnField]!.add({filterType: filterValue});
      } else {
        map[columnField] = [
          {filterType: filterValue},
        ];
      }
    }

    return map;
  }

  /// Whether [column] is included in [filteredRows].
  ///
  /// That is, check if it is a filtered column.
  /// If there is a search condition for all columns in [filteredRows],
  /// it is regarded as a filtering column.
  static bool isFilteredColumn(
    PlutoColumn column,
    List<PlutoRow?>? filteredRows,
  ) {
    if (filteredRows == null || filteredRows.isEmpty) {
      return false;
    }

    for (var row in filteredRows) {
      if (row!.cells[filterFieldColumn]!.value == filterFieldAllColumns ||
          row.cells[filterFieldColumn]!.value == column.field) {
        return true;
      }
    }

    return false;
  }

  /// Opens a pop-up for filtering.
  static void filterPopup(FilterPopupState popupState) {
    PlutoGridPopup(
      width: popupState.width,
      height: popupState.height,
      context: popupState.context,
      createHeader: popupState.createHeader,
      columns: popupState.makeColumns(),
      rows: popupState.filterRows,
      configuration: popupState.configuration,
      onLoaded: popupState.onLoaded,
      onChanged: popupState.onChanged,
      onSelected: popupState.onSelected,
      mode: PlutoGridMode.popup,
    );
  }

  /// 'or' comparison with null values
  static bool compareOr(bool? a, bool b) {
    return a != true ? a == true || b : true;
  }

  /// 'and' comparison with null values
  static bool? compareAnd(bool? a, bool? b) {
    return a != false ? b : false;
  }

  /// Compare [base] and [search] with [PlutoFilterType.compare].
  static bool compareByFilterType({
    required PlutoFilterType filterType,
    required String base,
    required String search,
    required PlutoColumn column,
  }) {
    bool compare = false;

    if (column.type is PlutoColumnTypeWithNumberFormat) {
      final numberColumn = column.type as PlutoColumnTypeWithNumberFormat;

      compare = compare ||
          filterType.compare(
            base: numberColumn.applyFormat(base),
            search: search,
            column: column,
          );

      search = search.replaceFirst(
        numberColumn.numberFormat.symbols.DECIMAL_SEP,
        '.',
      );
    }

    return compare ||
        filterType.compare(
          base: base,
          search: search,
          column: column,
        );
  }

  /// Whether [search] is contains in [base].
  static bool compareContains({
    required String? base,
    required String? search,
    required PlutoColumn column,
  }) {
    return _compareWithRegExp(
      RegExp.escape(search!),
      base!,
    );
  }

  /// Whether [search] is equals to [base].
  static bool compareEquals({
    required String? base,
    required String? search,
    required PlutoColumn column,
  }) {
    return _compareWithRegExp(
      // ignore: prefer_interpolation_to_compose_strings
      r'^' + RegExp.escape(search!) + r'$',
      base!,
    );
  }

  /// Whether [base] starts with [search].
  static bool compareStartsWith({
    required String? base,
    required String? search,
    required PlutoColumn column,
  }) {
    return _compareWithRegExp(
      // ignore: prefer_interpolation_to_compose_strings
      r'^' + RegExp.escape(search!),
      base!,
    );
  }

  /// Whether [base] ends with [search].
  static bool compareEndsWith({
    required String? base,
    required String? search,
    required PlutoColumn column,
  }) {
    return _compareWithRegExp(
      // ignore: prefer_interpolation_to_compose_strings
      RegExp.escape(search!) + r'$',
      base!,
    );
  }

  static bool compareGreaterThan({
    required String? base,
    required String? search,
    required PlutoColumn column,
  }) {
    return column.type.compare(base, search) == 1;
  }

  static bool compareGreaterThanOrEqualTo({
    required String? base,
    required String? search,
    required PlutoColumn column,
  }) {
    return column.type.compare(base, search) > -1;
  }

  static bool compareLessThan({
    required String? base,
    required String? search,
    required PlutoColumn column,
  }) {
    return column.type.compare(base, search) == -1;
  }

  static bool compareLessThanOrEqualTo({
    required String? base,
    required String? search,
    required PlutoColumn column,
  }) {
    return column.type.compare(base, search) < 1;
  }

  static bool _compareWithRegExp(
    String pattern,
    String value, {
    bool caseSensitive = false,
  }) {
    return RegExp(
      pattern,
      caseSensitive: caseSensitive,
    ).hasMatch(value);
  }
}

/// State for calling filter pop
class FilterPopupState {
  /// [BuildContext] for calling [showDialog]
  final BuildContext context;

  /// [PlutoGridConfiguration] to call [PlutoGridPopup]
  final PlutoGridConfiguration configuration;

  /// A callback function called when adding a new filter.
  final SetFilterPopupHandler handleAddNewFilter;

  /// A callback function called when filter information changes.
  final SetFilterPopupHandler handleApplyFilter;

  /// List of columns to be filtered.
  final List<PlutoColumn> columns;

  /// List with filtering condition information
  final List<PlutoRow> filterRows;

  /// The filter popup opens and focuses on the filter value in the first row.
  final bool focusFirstFilterValue;

  /// Width of filter popup
  final double width;

  /// Height of filter popup
  final double height;

  final void Function()? onClosed;

  FilterPopupState({
    required this.context,
    required this.configuration,
    required this.handleAddNewFilter,
    required this.handleApplyFilter,
    required this.columns,
    required this.filterRows,
    required this.focusFirstFilterValue,
    this.width = 600,
    this.height = 450,
    this.onClosed,
  })  : assert(columns.isNotEmpty),
        _previousFilterRows = [...filterRows];

  PlutoGridStateManager? _stateManager;
  List<PlutoRow?> _previousFilterRows;

  void onLoaded(PlutoGridOnLoadedEvent e) {
    _stateManager = e.stateManager;

    _stateManager!.setSelectingMode(PlutoGridSelectingMode.row, notify: false);

    if (_stateManager!.rows.isNotEmpty) {
      _stateManager!.setKeepFocus(true, notify: false);

      _stateManager!.setCurrentCell(
        _stateManager!.rows.first.cells[FilterHelper.filterFieldValue],
        0,
        notify: false,
      );

      if (focusFirstFilterValue) {
        _stateManager!.setEditing(true, notify: false);
      }
    }

    _stateManager!.notifyListeners();

    _stateManager!.addListener(stateListener);
  }

  void onChanged(PlutoGridOnChangedEvent e) {
    applyFilter();
  }

  void onSelected(PlutoGridOnSelectedEvent e) {
    _stateManager!.removeListener(stateListener);

    if (onClosed != null) {
      onClosed!();
    }
  }

  void stateListener() {
    if (listEquals(_previousFilterRows, _stateManager!.rows) == false) {
      _previousFilterRows = [..._stateManager!.rows];
      applyFilter();
    }
  }

  void applyFilter() {
    handleApplyFilter(_stateManager);
  }

  PlutoGridFilterPopupHeader createHeader(PlutoGridStateManager stateManager) {
    return PlutoGridFilterPopupHeader(
      stateManager: stateManager,
      configuration: configuration,
      handleAddNewFilter: handleAddNewFilter,
    );
  }

  List<PlutoColumn> makeColumns() {
    return _makeFilterColumns(configuration: configuration, columns: columns);
  }

  Map<String, String> _makeFilterColumnMap({
    required PlutoGridConfiguration configuration,
    required List<PlutoColumn> columns,
  }) {
    Map<String, String> columnMap = {
      FilterHelper.filterFieldAllColumns:
          configuration.localeText.filterAllColumns,
    };

    columns.where((element) => element.enableFilterMenuItem).forEach((element) {
      columnMap[element.field] = element.titleWithGroup;
    });

    return columnMap;
  }

  List<PlutoColumn> _makeFilterColumns({
    required PlutoGridConfiguration configuration,
    required List<PlutoColumn> columns,
  }) {
    Map<String, String> columnMap = _makeFilterColumnMap(
      configuration: configuration,
      columns: columns,
    );

    return [
      PlutoColumn(
        title: configuration.localeText.filterColumn,
        field: FilterHelper.filterFieldColumn,
        type: PlutoColumnType.select(columnMap.keys.toList(growable: false)),
        enableFilterMenuItem: false,
        applyFormatterInEditing: true,
        formatter: (dynamic value) {
          return columnMap[value] ?? '';
        },
      ),
      PlutoColumn(
        title: configuration.localeText.filterType,
        field: FilterHelper.filterFieldType,
        type: PlutoColumnType.select(configuration.columnFilter.filters),
        enableFilterMenuItem: false,
        applyFormatterInEditing: true,
        formatter: (dynamic value) {
          return (value?.title ?? '').toString();
        },
      ),
      PlutoColumn(
        title: configuration.localeText.filterValue,
        field: FilterHelper.filterFieldValue,
        type: PlutoColumnType.text(),
        enableFilterMenuItem: false,
      ),
    ];
  }
}

class PlutoGridFilterPopupHeader extends StatelessWidget {
  final PlutoGridStateManager? stateManager;
  final PlutoGridConfiguration? configuration;
  final SetFilterPopupHandler? handleAddNewFilter;

  const PlutoGridFilterPopupHeader({
    Key? key,
    this.stateManager,
    this.configuration,
    this.handleAddNewFilter,
  }) : super(key: key);

  void handleAddButton() {
    handleAddNewFilter!(stateManager);
  }

  void handleRemoveButton() {
    if (stateManager!.currentSelectingRows.isEmpty) {
      stateManager!.removeCurrentRow();
    } else {
      stateManager!.removeRows(stateManager!.currentSelectingRows);
    }
  }

  void handleClearButton() {
    if (stateManager!.rows.isEmpty) {
      Navigator.of(stateManager!.gridFocusNode.context!).pop();
    } else {
      stateManager!.removeRows(stateManager!.rows);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add),
            color: configuration!.style.iconColor,
            iconSize: configuration!.style.iconSize,
            onPressed: handleAddButton,
          ),
          IconButton(
            icon: const Icon(Icons.remove),
            color: configuration!.style.iconColor,
            iconSize: configuration!.style.iconSize,
            onPressed: handleRemoveButton,
          ),
          IconButton(
            icon: const Icon(Icons.clear_sharp),
            color: Colors.red,
            iconSize: configuration!.style.iconSize,
            onPressed: handleClearButton,
          ),
        ],
      ),
    );
  }
}

/// [base] is the cell values of the column on which the search is based.
/// [search] is the value entered by the user to search.
typedef PlutoCompareFunction = bool Function({
  required String? base,
  required String? search,
  required PlutoColumn column,
});

abstract class PlutoFilterType {
  String get title => throw UnimplementedError();

  PlutoCompareFunction get compare => throw UnimplementedError();
}

class PlutoFilterTypeContains implements PlutoFilterType {
  static String name = 'Contains';

  @override
  String get title => PlutoFilterTypeContains.name;

  @override
  PlutoCompareFunction get compare => FilterHelper.compareContains;

  const PlutoFilterTypeContains();
}

class PlutoFilterTypeEquals implements PlutoFilterType {
  static String name = 'Equals';

  @override
  String get title => PlutoFilterTypeEquals.name;

  @override
  PlutoCompareFunction get compare => FilterHelper.compareEquals;

  const PlutoFilterTypeEquals();
}

class PlutoFilterTypeStartsWith implements PlutoFilterType {
  static String name = 'Starts with';

  @override
  String get title => PlutoFilterTypeStartsWith.name;

  @override
  PlutoCompareFunction get compare => FilterHelper.compareStartsWith;

  const PlutoFilterTypeStartsWith();
}

class PlutoFilterTypeEndsWith implements PlutoFilterType {
  static String name = 'Ends with';

  @override
  String get title => PlutoFilterTypeEndsWith.name;

  @override
  PlutoCompareFunction get compare => FilterHelper.compareEndsWith;

  const PlutoFilterTypeEndsWith();
}

class PlutoFilterTypeGreaterThan implements PlutoFilterType {
  static String name = 'Greater than';

  @override
  String get title => PlutoFilterTypeGreaterThan.name;

  @override
  PlutoCompareFunction get compare => FilterHelper.compareGreaterThan;

  const PlutoFilterTypeGreaterThan();
}

class PlutoFilterTypeGreaterThanOrEqualTo implements PlutoFilterType {
  static String name = 'Greater than or equal to';

  @override
  String get title => PlutoFilterTypeGreaterThanOrEqualTo.name;

  @override
  PlutoCompareFunction get compare => FilterHelper.compareGreaterThanOrEqualTo;

  const PlutoFilterTypeGreaterThanOrEqualTo();
}

class PlutoFilterTypeLessThan implements PlutoFilterType {
  static String name = 'Less than';

  @override
  String get title => PlutoFilterTypeLessThan.name;

  @override
  PlutoCompareFunction get compare => FilterHelper.compareLessThan;

  const PlutoFilterTypeLessThan();
}

class PlutoFilterTypeLessThanOrEqualTo implements PlutoFilterType {
  static String name = 'Less than or equal to';

  @override
  String get title => PlutoFilterTypeLessThanOrEqualTo.name;

  @override
  PlutoCompareFunction get compare => FilterHelper.compareLessThanOrEqualTo;

  const PlutoFilterTypeLessThanOrEqualTo();
}
