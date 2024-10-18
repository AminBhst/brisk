import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../helper/column_helper.dart';
import '../../helper/row_helper.dart';
import '../../matcher/pluto_object_matcher.dart';
import '../../mock/mock_build_context.dart';
import '../../mock/mock_methods.dart';
import '../../mock/shared_mocks.mocks.dart';

void main() {
  group('createFilterRow', () {
    test(
      'When called without arguments,'
      'Should be returned a row filled with default values.',
      () {
        var row = FilterHelper.createFilterRow();

        expect(row.cells.length, 3);

        expect(
          row.cells[FilterHelper.filterFieldColumn]!.value,
          FilterHelper.filterFieldAllColumns,
        );

        expect(
          row.cells[FilterHelper.filterFieldType]!.value,
          isA<PlutoFilterTypeContains>(),
        );

        expect(
          row.cells[FilterHelper.filterFieldValue]!.value,
          '',
        );
      },
    );

    test(
      'When called with arguments,'
      'Should be returned a row filled with arguments.',
      () {
        var filter = const PlutoFilterTypeEndsWith();

        var row = FilterHelper.createFilterRow(
          columnField: 'filterColumnField',
          filterType: filter,
          filterValue: 'abc',
        );

        expect(row.cells.length, 3);

        expect(
          row.cells[FilterHelper.filterFieldColumn]!.value,
          'filterColumnField',
        );

        expect(
          row.cells[FilterHelper.filterFieldType]!.value,
          filter,
        );

        expect(
          row.cells[FilterHelper.filterFieldValue]!.value,
          'abc',
        );
      },
    );
  });

  group('convertRowsToFilter', () {
    test(
      'When called with empty rows, '
      'Should be returned null.',
      () {
        expect(FilterHelper.convertRowsToFilter([], []), isNull);
      },
    );

    group('with rows.', () {
      List<PlutoColumn>? columns;

      PlutoRow? row;

      setUp(() {
        columns = ColumnHelper.textColumn('column', count: 3);

        row = PlutoRow(
          cells: {
            'column1': PlutoCell(value: 'column1 value'),
            'column2': PlutoCell(value: 'column2 value'),
            'column3': PlutoCell(value: 'column3 value'),
          },
        );
      });

      test(
        'filterFieldColumn : All, '
        'filterFieldType : Contains, '
        'filterFieldValue : column1, '
        'true',
        () {
          var filterRows = [
            FilterHelper.createFilterRow(
              filterValue: 'column1',
            )
          ];

          var enabledFilterColumns = columns;

          expect(
            FilterHelper.convertRowsToFilter(
              filterRows,
              enabledFilterColumns,
            )!(row),
            isTrue,
          );
        },
      );

      test(
        'filterFieldColumn : column2, '
        'filterFieldType : Contains, '
        'filterFieldValue : column1, '
        'false',
        () {
          var filterRows = [
            FilterHelper.createFilterRow(
              columnField: 'column2',
              filterValue: 'column1',
            )
          ];

          var enabledFilterColumns = columns;

          expect(
            FilterHelper.convertRowsToFilter(
              filterRows,
              enabledFilterColumns,
            )!(row),
            isFalse,
          );
        },
      );

      test(
        'filterFieldColumn : column1, '
        'filterFieldType : StartsWith, '
        'filterFieldValue : column1, '
        'true',
        () {
          var filterRows = [
            FilterHelper.createFilterRow(
              columnField: 'column1',
              filterType: const PlutoFilterTypeStartsWith(),
              filterValue: 'column1',
            )
          ];

          var enabledFilterColumns = columns;

          expect(
            FilterHelper.convertRowsToFilter(
              filterRows,
              enabledFilterColumns,
            )!(row),
            isTrue,
          );
        },
      );

      test(
        'column1 이 enabledFilterColumns 에 존재하지 않을 때, '
        'filterFieldColumn : column1, '
        'filterFieldType : Contains, '
        'filterFieldValue : column1, '
        'false',
        () {
          var filterRows = [
            FilterHelper.createFilterRow(
              columnField: 'column1',
              filterType: const PlutoFilterTypeContains(),
              filterValue: 'column1',
            )
          ];

          columns!.removeWhere((element) => element.field == 'column1');

          var enabledFilterColumns = columns;

          expect(
            FilterHelper.convertRowsToFilter(
              filterRows,
              enabledFilterColumns,
            )!(row),
            isFalse,
          );
        },
      );

      test(
        'filterFieldColumn : All, '
        'filterFieldType : StartsWith, '
        'filterFieldValue : column1, '
        'enabledFilterColumnFields : [column3]'
        'false',
        () {
          var filterRows = [
            FilterHelper.createFilterRow(
              filterType: const PlutoFilterTypeStartsWith(),
              filterValue: 'column1',
            )
          ];

          var enabledFilterColumns = columns!
              .where(
                (element) => element.field == 'column3',
              )
              .toList();

          expect(
            FilterHelper.convertRowsToFilter(
              filterRows,
              enabledFilterColumns,
            )!(row),
            isFalse,
          );
        },
      );
    });
  });

  group('convertRowsToMap', () {
    test('filterRows 가 비어있으면 빈 맵을 리턴해야 한다.', () {
      final List<PlutoRow> filterRows = [];

      final result = FilterHelper.convertRowsToMap(filterRows);

      expect(result.isEmpty, true);
      expect(result, isA<Map<String, List<Map<String, String>>>>());
    });

    test('filterRows 가 설정 되어 있으면 Map 에 값이 설정되어 리턴되어야 한다.', () {
      final List<PlutoRow> filterRows = [
        PlutoRow(cells: {
          FilterHelper.filterFieldColumn: PlutoCell(value: 'column'),
          FilterHelper.filterFieldType: PlutoCell(
            value: const PlutoFilterTypeContains(),
          ),
          FilterHelper.filterFieldValue: PlutoCell(value: '123'),
        }),
      ];

      final result = FilterHelper.convertRowsToMap(filterRows);

      expect(result.length, 1);
      expect(result, PlutoObjectMatcher<Map<String, List<Map<String, String>>>>(
        rule: (value) {
          return value.keys.first == 'column' &&
              value.values.first[0].keys.first ==
                  PlutoFilterTypeContains.name &&
              value.values.first[0].values.first == '123';
        },
      ));
    });

    test(
        'filterRows 에 동일한 컬럼의 조건이 2개 설정 되어 있으면, '
        'Map 에 값이 설정되어 리턴되어야 한다.', () {
      final List<PlutoRow> filterRows = [
        PlutoRow(cells: {
          FilterHelper.filterFieldColumn: PlutoCell(value: 'column'),
          FilterHelper.filterFieldType: PlutoCell(
            value: const PlutoFilterTypeContains(),
          ),
          FilterHelper.filterFieldValue: PlutoCell(value: '123'),
        }),
        PlutoRow(cells: {
          FilterHelper.filterFieldColumn: PlutoCell(value: 'column'),
          FilterHelper.filterFieldType: PlutoCell(
            value: const PlutoFilterTypeEndsWith(),
          ),
          FilterHelper.filterFieldValue: PlutoCell(value: '456'),
        }),
      ];

      final result = FilterHelper.convertRowsToMap(filterRows);

      expect(result.length, 1);
      expect(result, PlutoObjectMatcher<Map<String, List<Map<String, String>>>>(
        rule: (value) {
          return value.keys.contains('column') &&
              value['column']!.length == 2 &&
              value['column']![0].keys.contains(PlutoFilterTypeContains.name) &&
              value['column']![0].values.contains('123') &&
              value['column']![1].keys.contains(PlutoFilterTypeEndsWith.name) &&
              value['column']![1].values.contains('456');
        },
      ));
    });

    test(
        'filtering 조건에 모든 컬럼 조건이 포함 되어 있으면, '
        'Map 에 기본값 all 로 설정되어 리턴되어야 한다.', () {
      final List<PlutoRow> filterRows = [
        PlutoRow(cells: {
          FilterHelper.filterFieldColumn: PlutoCell(value: 'column'),
          FilterHelper.filterFieldType: PlutoCell(
            value: const PlutoFilterTypeContains(),
          ),
          FilterHelper.filterFieldValue: PlutoCell(value: '123'),
        }),
        PlutoRow(cells: {
          FilterHelper.filterFieldColumn: PlutoCell(
            value: FilterHelper.filterFieldAllColumns,
          ),
          FilterHelper.filterFieldType: PlutoCell(
            value: const PlutoFilterTypeContains(),
          ),
          FilterHelper.filterFieldValue: PlutoCell(value: '123'),
        }),
      ];

      final result = FilterHelper.convertRowsToMap(filterRows);

      expect(result.length, 2);
      expect(result, PlutoObjectMatcher<Map<String, List<Map<String, String>>>>(
        rule: (value) {
          return value.containsKey('all');
        },
      ));
    });

    test(
        'allField 을 allColumns 로 변경하면, '
        'Map 에 기본값 allColumns 로 설정되어 리턴되어야 한다.', () {
      final List<PlutoRow> filterRows = [
        PlutoRow(cells: {
          FilterHelper.filterFieldColumn: PlutoCell(value: 'column'),
          FilterHelper.filterFieldType: PlutoCell(
            value: const PlutoFilterTypeContains(),
          ),
          FilterHelper.filterFieldValue: PlutoCell(value: '123'),
        }),
        PlutoRow(cells: {
          FilterHelper.filterFieldColumn: PlutoCell(
            value: FilterHelper.filterFieldAllColumns,
          ),
          FilterHelper.filterFieldType: PlutoCell(
            value: const PlutoFilterTypeContains(),
          ),
          FilterHelper.filterFieldValue: PlutoCell(value: '123'),
        }),
      ];

      final result = FilterHelper.convertRowsToMap(
        filterRows,
        allField: 'allColumns',
      );

      expect(result.length, 2);
      expect(result, PlutoObjectMatcher<Map<String, List<Map<String, String>>>>(
        rule: (value) {
          return value.containsKey('allColumns');
        },
      ));
    });
  });

  group('isFilteredColumn', () {
    test(
      'filterRows : null, empty, '
      'Should be returned false.',
      () {
        expect(
          FilterHelper.isFilteredColumn(
            PlutoColumn(
              title: 'column',
              field: 'column',
              type: PlutoColumnType.text(),
            ),
            null,
          ),
          isFalse,
        );

        expect(
          FilterHelper.isFilteredColumn(
            PlutoColumn(
              title: 'column',
              field: 'column',
              type: PlutoColumnType.text(),
            ),
            [],
          ),
          isFalse,
        );
      },
    );

    test(
      'filterRows : [All columns], '
      'Should be returned true.',
      () {
        expect(
          FilterHelper.isFilteredColumn(
            PlutoColumn(
              title: 'column',
              field: 'column',
              type: PlutoColumnType.text(),
            ),
            [FilterHelper.createFilterRow()],
          ),
          isTrue,
        );
      },
    );

    test(
      'filterRows : [column], '
      'Should be returned true.',
      () {
        expect(
          FilterHelper.isFilteredColumn(
            PlutoColumn(
              title: 'column',
              field: 'column',
              type: PlutoColumnType.text(),
            ),
            [FilterHelper.createFilterRow(columnField: 'column')],
          ),
          isTrue,
        );
      },
    );

    test(
      'filterRows : [non_exists_column], '
      'Should be returned false.',
      () {
        expect(
          FilterHelper.isFilteredColumn(
            PlutoColumn(
              title: 'column',
              field: 'column',
              type: PlutoColumnType.text(),
            ),
            [FilterHelper.createFilterRow(columnField: 'non_exists_column')],
          ),
          isFalse,
        );
      },
    );
  });

  group('compareByFilterType', () {
    late bool Function(dynamic a, dynamic b) Function(
      PlutoFilterType filterType, {
      PlutoColumn? column,
    }) makeCompareFunction;

    setUp(() {
      makeCompareFunction = (
        PlutoFilterType filterType, {
        PlutoColumn? column,
      }) {
        column ??= PlutoColumn(
          title: 'column',
          field: 'column',
          type: PlutoColumnType.text(),
        );

        return (dynamic a, dynamic b) {
          return FilterHelper.compareByFilterType(
            filterType: filterType,
            base: a.toString(),
            search: b.toString(),
            column: column!,
          );
        };
      };
    });

    group('Contains', () {
      late Function compare;

      setUp(() {
        compare = makeCompareFunction(const PlutoFilterTypeContains());
      });

      test('apple contains le', () {
        expect(compare('apple', 'le'), isTrue);
      });

      test('apple is not contains banana', () {
        expect(compare('apple', 'banana'), isFalse);
      });
    });

    group('Equals', () {
      late Function compare;

      setUp(() {
        compare = makeCompareFunction(const PlutoFilterTypeEquals());
      });

      test('apple equals apple', () {
        expect(compare('apple', 'apple'), isTrue);
      });

      test('apple is not equals banana', () {
        expect(compare('apple', 'banana'), isFalse);
      });

      test('0 equals "0"', () {
        expect(compare(0, '0'), isTrue);
      });
    });

    group('StartsWith', () {
      late Function compare;

      setUp(() {
        compare = makeCompareFunction(const PlutoFilterTypeStartsWith());
      });

      test('apple startsWith ap', () {
        expect(compare('apple', 'ap'), isTrue);
      });

      test('apple is not startsWith banana', () {
        expect(compare('apple', 'banana'), isFalse);
      });
    });

    group('EndsWith', () {
      late Function compare;

      setUp(() {
        compare = makeCompareFunction(const PlutoFilterTypeEndsWith());
      });

      test('apple endsWith le', () {
        expect(compare('apple', 'le'), isTrue);
      });

      test('apple is not endsWith app', () {
        expect(compare('apple', 'app'), isFalse);
      });
    });

    group('GreaterThan', () {
      late Function compare;

      setUp(() {
        compare = makeCompareFunction(const PlutoFilterTypeGreaterThan());
      });

      test('banana GreaterThan apple', () {
        expect(compare('banana', 'apple'), isTrue);
      });

      test('apple is not GreaterThan banana', () {
        expect(compare('apple', 'banana'), isFalse);
      });
    });

    group('GreaterThanOrEqualTo', () {
      late Function compare;

      setUp(() {
        compare = makeCompareFunction(
          const PlutoFilterTypeGreaterThanOrEqualTo(),
        );
      });

      test('banana GreaterThanOrEqualTo apple', () {
        expect(compare('banana', 'apple'), isTrue);
      });

      test('banana GreaterThanOrEqualTo apple', () {
        expect(compare('banana', 'banana'), isTrue);
      });

      test('apple is not GreaterThanOrEqualTo banana', () {
        expect(compare('apple', 'banana'), isFalse);
      });
    });

    group('LessThan', () {
      late Function compare;

      setUp(() {
        compare = makeCompareFunction(const PlutoFilterTypeLessThan());
      });

      test('A LessThan B', () {
        expect(compare('A', 'B'), isTrue);
      });

      test('B is not LessThan A', () {
        expect(compare('B', 'A'), isFalse);
      });
    });

    group('LessThanOrEqualTo', () {
      late Function compare;

      setUp(() {
        compare = makeCompareFunction(const PlutoFilterTypeLessThanOrEqualTo());
      });

      test('A LessThanOrEqualTo B', () {
        expect(compare('A', 'B'), isTrue);
      });

      test('A LessThanOrEqualTo A', () {
        expect(compare('A', 'A'), isTrue);
      });

      test('B is not LessThanOrEqualTo A', () {
        expect(compare('B', 'A'), isFalse);
      });
    });
  });

  group('FilterPopupState', () {
    test(
      'columns should not be empty.',
      () {
        expect(
          () {
            FilterPopupState(
              context: MockBuildContext(),
              configuration: const PlutoGridConfiguration(),
              handleAddNewFilter: (_) {},
              handleApplyFilter: (_) {},
              columns: [],
              filterRows: [],
              focusFirstFilterValue: false,
            );
          },
          throwsA(isA<AssertionError>()),
        );
      },
    );

    group('onLoaded', () {
      test(
        'should be called setSelectingMode, addListener.',
        () {
          final List<PlutoRow> filterRows = [];

          var filterPopupState = FilterPopupState(
            context: MockBuildContext(),
            configuration: const PlutoGridConfiguration(),
            handleAddNewFilter: (_) {},
            handleApplyFilter: (_) {},
            columns: ColumnHelper.textColumn('column'),
            filterRows: filterRows,
            focusFirstFilterValue: false,
          );

          var stateManager = MockPlutoGridStateManager();

          when(stateManager.rows).thenReturn(filterRows);

          filterPopupState.onLoaded(
            PlutoGridOnLoadedEvent(stateManager: stateManager),
          );

          verify(stateManager.setSelectingMode(
            PlutoGridSelectingMode.row,
            notify: false,
          )).called(1);

          verify(
            stateManager.addListener(filterPopupState.stateListener),
          ).called(1);
        },
      );

      test(
        'if focusFirstFilterValue is true and stateManager has rows, '
        'then setKeepFocus, setCurrentCell and setEditing should be called.',
        () {
          var columns = ColumnHelper.textColumn('column');
          var rows = RowHelper.count(1, columns);

          var filterPopupState = FilterPopupState(
            context: MockBuildContext(),
            configuration: const PlutoGridConfiguration(),
            handleAddNewFilter: (_) {},
            handleApplyFilter: (_) {},
            columns: columns,
            filterRows: [
              FilterHelper.createFilterRow(
                columnField: columns[0].enableFilterMenuItem
                    ? columns[0].field
                    : FilterHelper.filterFieldAllColumns,
                filterType: columns[0].defaultFilter,
              ),
            ],
            focusFirstFilterValue: true,
          );

          var stateManager = MockPlutoGridStateManager();

          when(stateManager.rows).thenReturn(rows);

          filterPopupState.onLoaded(
            PlutoGridOnLoadedEvent(stateManager: stateManager),
          );

          verify(stateManager.setKeepFocus(true, notify: false)).called(1);

          verify(stateManager.setCurrentCell(
            rows.first.cells[FilterHelper.filterFieldValue],
            0,
            notify: false,
          )).called(1);

          verify(stateManager.setEditing(true, notify: false)).called(1);

          verify(stateManager.notifyListeners()).called(1);
        },
      );
    });

    test('onChanged', () {
      final columns = ColumnHelper.textColumn('column');

      final rows = RowHelper.count(1, columns);

      var mock = MockMethods();

      var filterPopupState = FilterPopupState(
        context: MockBuildContext(),
        configuration: const PlutoGridConfiguration(),
        handleAddNewFilter: (_) {},
        handleApplyFilter: mock.oneParamReturnVoid,
        columns: columns,
        filterRows: [],
        focusFirstFilterValue: true,
      );

      filterPopupState.onChanged(PlutoGridOnChangedEvent(
        columnIdx: 0,
        column: columns.first,
        rowIdx: 0,
        row: rows.first,
      ));

      verify(mock.oneParamReturnVoid(any)).called(1);
    });

    test('onSelected', () {
      final List<PlutoRow> filterRows = [];

      var filterPopupState = FilterPopupState(
        context: MockBuildContext(),
        configuration: const PlutoGridConfiguration(),
        handleAddNewFilter: (_) {},
        handleApplyFilter: (_) {},
        columns: ColumnHelper.textColumn('column'),
        filterRows: filterRows,
        focusFirstFilterValue: false,
      );

      var stateManager = MockPlutoGridStateManager();

      when(stateManager.rows).thenReturn(filterRows);

      filterPopupState.onLoaded(
        PlutoGridOnLoadedEvent(stateManager: stateManager),
      );

      filterPopupState.onSelected(const PlutoGridOnSelectedEvent());

      verify(
        stateManager.removeListener(filterPopupState.stateListener),
      ).called(1);
    });

    group('stateListener', () {
      test('filterRows 가 변경되지 않았으면 handleApplyFilter 가 호출되지 않아야 한다.', () {
        var mock = MockMethods();

        var columns = ColumnHelper.textColumn('column');

        var filterRows = RowHelper.count(1, columns);

        var filterPopupState = FilterPopupState(
          context: MockBuildContext(),
          configuration: const PlutoGridConfiguration(),
          handleAddNewFilter: (_) {},
          handleApplyFilter: mock.oneParamReturnVoid,
          columns: columns,
          filterRows: filterRows,
          focusFirstFilterValue: false,
        );

        var stateManager = MockPlutoGridStateManager();

        when(stateManager.rows).thenReturn([...filterRows]);

        filterPopupState.onLoaded(
          PlutoGridOnLoadedEvent(stateManager: stateManager),
        );

        filterPopupState.stateListener();

        verifyNever(mock.oneParamReturnVoid(stateManager));
      });

      test('filterRows 가 변경 되었으면 handleApplyFilter 가 호출 되어야 한다.', () {
        var mock = MockMethods();

        var columns = ColumnHelper.textColumn('column');

        var filterPopupState = FilterPopupState(
          context: MockBuildContext(),
          configuration: const PlutoGridConfiguration(),
          handleAddNewFilter: (_) {},
          handleApplyFilter: mock.oneParamReturnVoid,
          columns: columns,
          filterRows: [],
          focusFirstFilterValue: false,
        );

        var stateManager = MockPlutoGridStateManager();

        when(stateManager.rows).thenReturn(RowHelper.count(1, columns));

        filterPopupState.onLoaded(
          PlutoGridOnLoadedEvent(stateManager: stateManager),
        );

        filterPopupState.stateListener();

        verify(mock.oneParamReturnVoid(stateManager)).called(1);
      });
    });

    group('makeColumns', () {
      var columns = ColumnHelper.textColumn('column', count: 3);

      var configuration = const PlutoGridConfiguration();

      var filterPopupState = FilterPopupState(
        context: MockBuildContext(),
        configuration: configuration,
        handleAddNewFilter: (_) {},
        handleApplyFilter: (_) {},
        columns: columns,
        filterRows: [],
        focusFirstFilterValue: false,
      );

      var filterColumns = filterPopupState.makeColumns();

      test('3개의 컬럼이 생성 되어야 한다.', () {
        expect(filterColumns.length, 3);
        expect(filterColumns[0].field, FilterHelper.filterFieldColumn);
        expect(filterColumns[1].field, FilterHelper.filterFieldType);
        expect(filterColumns[2].field, FilterHelper.filterFieldValue);
      });

      test('filterColumns 의 첫번째 컬럼이 select type 으로 생성 되어야 한다.', () {
        var filterColumn = filterColumns[0];

        expect(filterColumn.type, isA<PlutoColumnTypeSelect>());

        var columnType = filterColumn.type as PlutoColumnTypeSelect;

        // 전체 검색 필드가 추가 되어 +1 (FilterHelper.filterFieldAllColumns)
        expect(columnType.items.length, columns.length + 1);

        expect(columnType.items[0], FilterHelper.filterFieldAllColumns);
        expect(columnType.items[1], columns[0].field);
        expect(columnType.items[2], columns[1].field);
        expect(columnType.items[3], columns[2].field);

        // formatter (column 의 field 가 값으로써 formatter 에서 title 로 반환한다.)
        expect(
          filterColumn.formatter!(FilterHelper.filterFieldAllColumns),
          configuration.localeText.filterAllColumns,
        );

        for (var i = 0; i < columns.length; i += 1) {
          expect(
            filterColumn.formatter!(columns[i].field),
            columns[i].title,
          );
        }
      });

      test('filterColumns 의 두번째 컬럼이 select type 으로 생성 되어야 한다.', () {
        var filterColumn = filterColumns[1];

        expect(filterColumn.type, isA<PlutoColumnTypeSelect>());

        var columnType = filterColumn.type as PlutoColumnTypeSelect;

        // configuration 의 필터 수 만큼 생성 되어야 한다. (기본 8개)
        expect(configuration.columnFilter.filters.length, 8);
        expect(
            columnType.items.length, configuration.columnFilter.filters.length);

        // formatter (filter 가 값으로 써 formatter 에서 title 을 반환한다.)
        for (var i = 0; i < configuration.columnFilter.filters.length; i += 1) {
          expect(
            filterColumn.formatter!(configuration.columnFilter.filters[i]),
            configuration.columnFilter.filters[i].title,
          );
        }
      });

      test('filterColumns 의 세번째 컬럼이 text type 으로 생성 되어야 한다.', () {
        var filterColumn = filterColumns[2];

        expect(filterColumn.type, isA<PlutoColumnTypeText>());
      });
    });
  });

  group('PlutoGridFilterPopupHeader', () {
    testWidgets(
      'add 버튼을 탭하면 handleAddNewFilter 콜백이 호출 되어야 한다.',
      (tester) async {
        final stateManager = MockPlutoGridStateManager();
        const configuration = PlutoGridConfiguration();
        final mockListener = MockMethods();

        await tester.pumpWidget(MaterialApp(
          home: Material(
            child: PlutoGridFilterPopupHeader(
              stateManager: stateManager,
              configuration: configuration,
              handleAddNewFilter: mockListener.oneParamReturnVoid,
            ),
          ),
        ));

        final button = find.byType(IconButton).first;

        await tester.tap(button);

        expect(
          ((button.evaluate().first.widget as IconButton).icon as Icon).icon,
          Icons.add,
        );

        verify(mockListener.oneParamReturnVoid(any)).called(1);
      },
    );

    testWidgets(
      'currentSelectingRows 이 empty 인 상태에서 remove 아이콘을 탭하면 removeCurrentRow 가 호출 되어야 한다.',
      (tester) async {
        final stateManager = MockPlutoGridStateManager();
        const configuration = PlutoGridConfiguration();
        final mockListener = MockMethods();

        when(stateManager.currentSelectingRows).thenReturn([]);

        await tester.pumpWidget(MaterialApp(
          home: Material(
            child: PlutoGridFilterPopupHeader(
              stateManager: stateManager,
              configuration: configuration,
              handleAddNewFilter: mockListener.oneParamReturnVoid,
            ),
          ),
        ));

        final button = find.byType(IconButton).at(1);

        await tester.tap(button);

        expect(
          ((button.evaluate().first.widget as IconButton).icon as Icon).icon,
          Icons.remove,
        );

        verify(stateManager.removeCurrentRow()).called(1);
      },
    );

    testWidgets(
      'currentSelectingRows 이 empty 가 아닌 상태에서 remove 아이콘을 탭하면 removeRows 가 호출 되어야 한다.',
      (tester) async {
        final stateManager = MockPlutoGridStateManager();
        const configuration = PlutoGridConfiguration();
        final mockListener = MockMethods();

        final dummyRow = PlutoRow(cells: {'test': PlutoCell(value: '')});

        when(stateManager.currentSelectingRows).thenReturn([dummyRow]);

        await tester.pumpWidget(MaterialApp(
          home: Material(
            child: PlutoGridFilterPopupHeader(
              stateManager: stateManager,
              configuration: configuration,
              handleAddNewFilter: mockListener.oneParamReturnVoid,
            ),
          ),
        ));

        final button = find.byType(IconButton).at(1);

        await tester.tap(button);

        expect(
          ((button.evaluate().first.widget as IconButton).icon as Icon).icon,
          Icons.remove,
        );

        verify(stateManager.removeRows([dummyRow])).called(1);
      },
    );
  });
}
