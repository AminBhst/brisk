import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../helper/column_helper.dart';
import '../../../helper/pluto_widget_test_helper.dart';
import '../../../helper/row_helper.dart';
import '../../../mock/mock_methods.dart';
import '../../../mock/shared_mocks.mocks.dart';

void main() {
  final scroll = MockPlutoGridScrollController();

  final vertical = MockLinkedScrollControllerGroup();

  when(scroll.vertical).thenReturn(vertical);

  PlutoGridStateManager createStateManager({
    required List<PlutoColumn> columns,
    required List<PlutoRow> rows,
    FocusNode? gridFocusNode,
    PlutoGridScrollController? scroll,
    BoxConstraints? layout,
    PlutoGridConfiguration configuration = const PlutoGridConfiguration(),
    Widget Function(PlutoGridStateManager)? createHeader,
  }) {
    final stateManager = PlutoGridStateManager(
      columns: columns,
      rows: rows,
      gridFocusNode: gridFocusNode ?? MockFocusNode(),
      scroll: scroll ?? MockPlutoGridScrollController(),
      configuration: configuration,
      createHeader: createHeader,
    );

    stateManager.setEventManager(MockPlutoGridEventManager());

    if (layout != null) {
      stateManager.setLayout(layout);
    }

    return stateManager;
  }

  group('checkedRows', () {
    testWidgets(
      '선택 된 행이 없는 경우 빈 List 를 리턴 해야 한다.',
      (WidgetTester tester) async {
        // given
        List<PlutoColumn> columns =
            ColumnHelper.textColumn('body', count: 3, width: 150);

        List<PlutoRow> rows = RowHelper.count(10, columns);

        PlutoGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: scroll,
        );

        // when
        // then
        expect(stateManager.checkedRows.toList(), <PlutoRow>[]);
      },
    );

    testWidgets(
      '선택 된 행이 있는 경우 선택 된 List 를 리턴 해야 한다.',
      (WidgetTester tester) async {
        // given
        List<PlutoColumn> columns =
            ColumnHelper.textColumn('body', count: 1, width: 150);

        final checkedRows = RowHelper.count(3, columns, checked: true);

        List<PlutoRow> rows = [...checkedRows, ...RowHelper.count(10, columns)];

        PlutoGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: scroll,
        );

        // when
        final keys =
            stateManager.checkedRows.toList().map((e) => e.key).toList();

        // then
        expect(keys.length, 3);
        expect(keys.contains(checkedRows[0].key), isTrue);
        expect(keys.contains(checkedRows[1].key), isTrue);
        expect(keys.contains(checkedRows[2].key), isTrue);
      },
    );
  });

  group('unCheckedRows', () {
    testWidgets(
      '선택 된 행이 없는 경우 모든 List 를 리턴 해야 한다.',
      (WidgetTester tester) async {
        // given
        List<PlutoColumn> columns =
            ColumnHelper.textColumn('body', count: 3, width: 150);

        List<PlutoRow> rows = RowHelper.count(10, columns);

        PlutoGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: scroll,
        );

        // when
        // then
        expect(stateManager.unCheckedRows.toList().length, rows.length);
      },
    );

    testWidgets(
      '선택 된 행이 있는 경우 선택 된 List 를 제외하고 리턴 해야 한다.',
      (WidgetTester tester) async {
        // given
        List<PlutoColumn> columns =
            ColumnHelper.textColumn('body', count: 1, width: 150);

        final checkedRows = RowHelper.count(3, columns, checked: true);

        List<PlutoRow> rows = [...checkedRows, ...RowHelper.count(10, columns)];

        PlutoGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: scroll,
        );

        // when
        final keys =
            stateManager.unCheckedRows.toList().map((e) => e.key).toList();

        // then
        expect(keys.length, 10);
        expect(keys.contains(checkedRows[0].key), isFalse);
        expect(keys.contains(checkedRows[1].key), isFalse);
        expect(keys.contains(checkedRows[2].key), isFalse);
      },
    );
  });

  group('hasCheckedRow', () {
    testWidgets(
      '선택 된 행이 없는 경우 false 를 리턴 해야 한다.',
      (WidgetTester tester) async {
        // given
        List<PlutoColumn> columns =
            ColumnHelper.textColumn('body', count: 3, width: 150);

        List<PlutoRow> rows = RowHelper.count(10, columns);

        PlutoGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: scroll,
        );

        // when
        // then
        expect(stateManager.hasCheckedRow, isFalse);
      },
    );

    testWidgets(
      '선택 된 행이 있는 경우 true 를 리턴 해야 한다.',
      (WidgetTester tester) async {
        // given
        List<PlutoColumn> columns =
            ColumnHelper.textColumn('body', count: 1, width: 150);

        final checkedRows = RowHelper.count(3, columns, checked: true);

        List<PlutoRow> rows = [...checkedRows, ...RowHelper.count(10, columns)];

        PlutoGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: scroll,
        );

        // when
        // then
        expect(stateManager.hasCheckedRow, isTrue);
      },
    );
  });

  group('hasUnCheckedRow', () {
    testWidgets(
      '선택 된 행이 없는 경우 true 를 리턴 해야 한다.',
      (WidgetTester tester) async {
        // given
        List<PlutoColumn> columns =
            ColumnHelper.textColumn('body', count: 3, width: 150);

        List<PlutoRow> rows = RowHelper.count(10, columns);

        PlutoGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: scroll,
        );

        // when
        // then
        expect(stateManager.hasUnCheckedRow, isTrue);
      },
    );

    testWidgets(
      '선택 되지 않은 행이 하나라도 있는 경우 true 를 리턴해야 한다.',
      (WidgetTester tester) async {
        // given
        List<PlutoColumn> columns =
            ColumnHelper.textColumn('body', count: 1, width: 150);

        final checkedRows = RowHelper.count(3, columns, checked: true);

        final uncheckedRows = RowHelper.count(1, columns, checked: false);

        List<PlutoRow> rows = [...checkedRows, ...uncheckedRows];

        PlutoGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: scroll,
        );

        // when
        // then
        expect(stateManager.hasUnCheckedRow, isTrue);
      },
    );

    testWidgets(
      '모든 행이 선택 된 경우 false 를 리턴해야 한다.',
      (WidgetTester tester) async {
        // given
        List<PlutoColumn> columns =
            ColumnHelper.textColumn('body', count: 1, width: 150);

        final checkedRows = RowHelper.count(3, columns, checked: true);

        List<PlutoRow> rows = [...checkedRows];

        PlutoGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: scroll,
        );

        // when
        // then
        expect(stateManager.hasUnCheckedRow, isFalse);
      },
    );
  });

  group('currentRowIdx', () {
    testWidgets('currentCell 이 선택되지 않는 경우 null 을 리턴해야 한다.',
        (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn('left',
            count: 3, frozen: PlutoColumnFrozen.start),
        ...ColumnHelper.textColumn('body', count: 3, width: 150),
        ...ColumnHelper.textColumn('right',
            count: 3, frozen: PlutoColumnFrozen.end),
      ];

      List<PlutoRow> rows = RowHelper.count(10, columns);

      PlutoGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: scroll,
      );

      // when
      int? currentRowIdx = stateManager.currentRowIdx;

      // when
      expect(currentRowIdx, null);
    });

    testWidgets('currentCell 이 선택 된 경우 선택 된 셀의 rowIdx 를 리턴해야 한다.',
        (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn('left',
            count: 3, frozen: PlutoColumnFrozen.start),
        ...ColumnHelper.textColumn('body', count: 3, width: 150),
        ...ColumnHelper.textColumn('right',
            count: 3, frozen: PlutoColumnFrozen.end),
      ];

      List<PlutoRow> rows = RowHelper.count(10, columns);

      PlutoGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: scroll,
      );

      stateManager.setLayout(const BoxConstraints());

      // when
      String selectColumnField = 'right1';
      stateManager.setCurrentCell(rows[7].cells[selectColumnField], 7);

      int? currentRowIdx = stateManager.currentRowIdx;

      // when
      expect(currentRowIdx, 7);
    });
  });

  group('currentRow', () {
    testWidgets('currentCell 이 선택되지 않는 경우 null 을 리턴해야 한다.',
        (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn('left',
            count: 3, frozen: PlutoColumnFrozen.start),
        ...ColumnHelper.textColumn('body', count: 3, width: 150),
        ...ColumnHelper.textColumn('right',
            count: 3, frozen: PlutoColumnFrozen.end),
      ];

      List<PlutoRow> rows = RowHelper.count(10, columns);

      PlutoGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: scroll,
      );

      // when
      PlutoRow? currentRow = stateManager.currentRow;

      // when
      expect(currentRow, null);
    });

    testWidgets('currentCell 이 선택 된 경우 선택 된 row 를 리턴해야 한다.',
        (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn('left',
            count: 3, frozen: PlutoColumnFrozen.start),
        ...ColumnHelper.textColumn('body', count: 3, width: 150),
        ...ColumnHelper.textColumn('right',
            count: 3, frozen: PlutoColumnFrozen.end),
      ];

      List<PlutoRow> rows = RowHelper.count(10, columns);

      PlutoGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: scroll,
        layout: const BoxConstraints(),
      );

      // when
      String selectColumnField = 'left1';
      stateManager.setCurrentCell(rows[3].cells[selectColumnField], 3);

      PlutoRow currentRow = stateManager.currentRow!;

      // when
      expect(currentRow, isNot(null));
      expect(currentRow.key, rows[3].key);
    });
  });

  group('getRowIdxByOffset', () {
    late PlutoGridStateManager stateManager;

    const rowsLength = 10;

    buildRows() {
      return PlutoWidgetTestHelper('build rows', (tester) async {
        List<PlutoColumn> columns = [
          ...ColumnHelper.textColumn('text', count: 3, width: 150),
        ];

        List<PlutoRow> rows = RowHelper.count(rowsLength, columns);

        when(scroll.verticalOffset).thenReturn(0);

        stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: scroll,
          layout: const BoxConstraints(
            maxWidth: 500,
            maxHeight: 300,
          ),
        );

        stateManager.setGridGlobalOffset(const Offset(0.0, 0.0));
      });
    }

    buildRows().test(
      '0 번 row 보다 위인 offset 인 경우 null 을 리턴해야 한다.',
      (tester) async {
        final rowIdx =
            stateManager.getRowIdxByOffset(stateManager.rowTotalHeight * 0.7);

        expect(rowIdx, isNull);
      },
    );

    buildRows().test(
      '0 번 row 의 중간 offset.',
      (tester) async {
        final rowIdx =
            stateManager.getRowIdxByOffset(stateManager.rowTotalHeight * 1.5);

        expect(rowIdx, 0);
      },
    );

    buildRows().test(
      '1 번 row 의 중간 offset.',
      (tester) async {
        final rowIdx =
            stateManager.getRowIdxByOffset(stateManager.rowTotalHeight * 2.5);

        expect(rowIdx, 1);
      },
    );

    buildRows().test(
      '마지막 9번 row 의 중간 offset.',
      (tester) async {
        final rowIdx =
            stateManager.getRowIdxByOffset(stateManager.rowTotalHeight * 10.5);

        expect(rowIdx, 9);
      },
    );

    buildRows().test(
      '마지막 row 보다 아래 offset 을 전달 한 경우 null 을 리턴해야 한다.',
      (tester) async {
        final rowIdx =
            stateManager.getRowIdxByOffset(stateManager.rowTotalHeight * 11.5);

        expect(rowIdx, isNull);
      },
    );
  });

  group('getRowByIdx', () {
    testWidgets(
      'rowIdx 가 null 인 경우 null 을 리턴해야 한다.',
      (WidgetTester tester) async {
        // given
        List<PlutoColumn> columns = [
          ...ColumnHelper.textColumn('text', count: 3, width: 150),
        ];

        List<PlutoRow> rows = RowHelper.count(5, columns);

        PlutoGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: null,
        );

        // when
        final found = stateManager.getRowByIdx(null);

        // then
        expect(found, isNull);
      },
    );

    testWidgets(
      'rowIdx 가 0보다 작은 경우 null 을 리턴해야 한다.',
      (WidgetTester tester) async {
        // given
        List<PlutoColumn> columns = [
          ...ColumnHelper.textColumn('text', count: 3, width: 150),
        ];

        List<PlutoRow> rows = RowHelper.count(5, columns);

        PlutoGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: null,
        );

        // when
        final found = stateManager.getRowByIdx(-1);

        // then
        expect(found, isNull);
      },
    );

    testWidgets(
      'rowIdx 가 rows 범위보다 큰 경우 null 을 리턴해야 한다.',
      (WidgetTester tester) async {
        // given
        List<PlutoColumn> columns = [
          ...ColumnHelper.textColumn('text', count: 3, width: 150),
        ];

        List<PlutoRow> rows = RowHelper.count(5, columns);

        PlutoGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: null,
        );

        // when
        final found = stateManager.getRowByIdx(5);

        // then
        expect(found, isNull);
      },
    );

    testWidgets(
      'rowIdx 가 rows 범위 안에 있는 경우 PlutoRow 를 리턴해야 한다.',
      (WidgetTester tester) async {
        // given
        List<PlutoColumn> columns = [
          ...ColumnHelper.textColumn('text', count: 3, width: 150),
        ];

        List<PlutoRow> rows = RowHelper.count(5, columns);

        PlutoGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: null,
        );

        // when
        final found = stateManager.getRowByIdx(4)!;

        // then
        expect(found.key, rows[4].key);
      },
    );
  });

  group('setRowChecked', () {
    testWidgets(
      '해당 row 가 없는 경우 notifyListener 가 호출 되지 않아야 한다.',
      (WidgetTester tester) async {
        // given
        List<PlutoColumn> columns = [
          ...ColumnHelper.textColumn('text', count: 3, width: 150),
        ];

        List<PlutoRow> rows = RowHelper.count(5, columns);

        PlutoGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: null,
        );

        final listener = MockMethods();

        stateManager.addListener(listener.noParamReturnVoid);

        // when
        stateManager.setRowChecked(PlutoRow(cells: {}), true);

        // then
        verifyNever(listener.noParamReturnVoid());
      },
    );

    testWidgets(
      '해당 row 가 있는 경우 notifyListener 가 호출 되고 checked 가 true 로 변경 되어야 한다.',
      (WidgetTester tester) async {
        // given
        List<PlutoColumn> columns = [
          ...ColumnHelper.textColumn('text', count: 3, width: 150),
        ];

        List<PlutoRow> rows = RowHelper.count(5, columns);

        PlutoGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: null,
        );

        final listener = MockMethods();

        stateManager.addListener(listener.noParamReturnVoid);

        // when
        final row = rows.first;

        stateManager.setRowChecked(row, true);

        // then
        expect(
          stateManager.rows
              .firstWhere((element) => element.key == row.key)
              .checked,
          isTrue,
        );

        verify(listener.noParamReturnVoid()).called(1);
      },
    );
  });

  group('insertRows', () {
    testWidgets(
      '삽입 할 위치가 rows 인덱스 범위가 0 보다 작으면 0에 최대 index 보다 크면 최대 index 에 insert 된다.',
      (WidgetTester tester) async {
        // given
        List<PlutoColumn> columns = [
          ...ColumnHelper.textColumn('text', count: 3, width: 150),
        ];

        List<PlutoRow> rows = RowHelper.count(5, columns);

        PlutoGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: null,
        );

        // when
        int countRows = stateManager.rows.length;

        // then
        {
          final addedRows = RowHelper.count(3, columns);
          stateManager.insertRows(-1, addedRows);
          countRows += 3;
          expect(stateManager.rows.length, countRows);
          expect(stateManager.rows.getRange(0, 3), addedRows);
        }

        {
          final addedRows = RowHelper.count(3, columns);
          stateManager.insertRows(-2, addedRows);
          countRows += 3;
          expect(stateManager.rows.length, countRows);
          expect(stateManager.rows.getRange(0, 3), addedRows);
        }

        {
          final addedRows = RowHelper.count(3, columns);
          stateManager.insertRows(stateManager.rows.length + 1, addedRows);
          countRows += 3;
          expect(stateManager.rows.length, countRows);
          final length = stateManager.rows.length;
          expect(stateManager.rows.getRange(length - 3, length), addedRows);
        }
      },
    );

    testWidgets(
      '삽입 할 위치가 rows 인덱스 범위에 있으면 행이 추가 되어야 한다.',
      (WidgetTester tester) async {
        // given
        List<PlutoColumn> columns = [
          ...ColumnHelper.textColumn('text', count: 3, width: 150),
        ];

        List<PlutoRow> rows = RowHelper.count(5, columns);

        PlutoGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: null,
        );

        // when
        final countRows = stateManager.rows.length;

        int countAdded = 0;

        // then
        countAdded += 3;
        stateManager.insertRows(0, RowHelper.count(3, columns));
        expect(stateManager.rows.length, countRows + countAdded);

        countAdded += 4;
        stateManager.insertRows(1, RowHelper.count(4, columns));
        expect(stateManager.rows.length, countRows + countAdded);

        countAdded += 5;
        stateManager.insertRows(
          stateManager.rows.length,
          RowHelper.count(5, columns),
        );
        expect(stateManager.rows.length, countRows + countAdded);
      },
    );

    testWidgets(
      '컬럼 정렬 상태가 없으면 sortIdx 가 0부터 증가 되어야 한다.',
      (WidgetTester tester) async {
        // given
        List<PlutoColumn> columns = [
          ...ColumnHelper.textColumn('text', count: 3, width: 150),
        ];

        List<PlutoRow> rows = RowHelper.count(5, columns);

        PlutoGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: null,
        );

        // when
        final rowsToAdd = RowHelper.count(3, columns);

        stateManager.insertRows(1, rowsToAdd);

        expect(stateManager.rows.length, 8);

        for (var i = 0; i < stateManager.rows.length; i += 1) {
          expect(stateManager.rows[i].sortIdx, i);
        }
      },
    );

    testWidgets(
      '컬럼 정렬 상태가 있으면 삽입 할 rows 의 sortIdx 는 삽입 할 위치부터 증가되고, '
      '기존 rows 의 sortIdx 는 삽입 할 위치보다 작으면 유지되고, '
      '삽입 할 위치보다 크면 삽입 할 rows 크기 만큼 증가 되어야 한다.',
      (WidgetTester tester) async {
        // given
        List<PlutoColumn> columns = [
          ...ColumnHelper.textColumn('text', count: 1, width: 150),
        ];

        List<PlutoRow> rows = [
          PlutoRow(sortIdx: 0, cells: {
            'text0': PlutoCell(value: '3'),
          }),
          PlutoRow(sortIdx: 1, cells: {
            'text0': PlutoCell(value: '1'),
          }),
          PlutoRow(sortIdx: 2, cells: {
            'text0': PlutoCell(value: '2'),
          }),
        ];

        PlutoGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: null,
        );

        stateManager.toggleSortColumn(columns.first);
        expect(stateManager.hasSortedColumn, isTrue);
        expect(stateManager.rows[0].sortIdx, 1); // 1
        expect(stateManager.rows[1].sortIdx, 2); // 2
        expect(stateManager.rows[2].sortIdx, 0); // 3

        // when
        final rowsToAdd = [
          PlutoRow(cells: {
            'text0': PlutoCell(value: 'a'),
          }),
          PlutoRow(cells: {
            'text0': PlutoCell(value: 'b'),
          }),
          PlutoRow(cells: {
            'text0': PlutoCell(value: 'c'),
          }),
        ];

        stateManager.insertRows(1, rowsToAdd);

        expect(stateManager.rows.length, 6);
        expect(stateManager.rows[0].sortIdx, 1);
        expect(stateManager.rows[0].cells['text0']!.value, '1');

        expect(stateManager.rows[1].sortIdx, 2);
        expect(stateManager.rows[1].cells['text0']!.value, 'a');

        expect(stateManager.rows[2].sortIdx, 3);
        expect(stateManager.rows[2].cells['text0']!.value, 'b');

        expect(stateManager.rows[3].sortIdx, 4);
        expect(stateManager.rows[3].cells['text0']!.value, 'c');

        expect(stateManager.rows[4].sortIdx, 5);
        expect(stateManager.rows[4].cells['text0']!.value, '2');

        expect(stateManager.rows[5].sortIdx, 0);
        expect(stateManager.rows[5].cells['text0']!.value, '3');
      },
    );
  });

  group('prependNewRows', () {
    testWidgets(
      'count 기본값 1 만큼 rows 앞쪽에 추가 되어야 한다.',
      (WidgetTester tester) async {
        // given
        List<PlutoColumn> columns = [
          ...ColumnHelper.textColumn('text', count: 3, width: 150),
        ];

        List<PlutoRow> rows = RowHelper.count(5, columns);

        PlutoGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: null,
        );

        // when
        stateManager.prependNewRows();

        // then
        // 추가된 행의 기본 값 및 sortIdx
        expect(stateManager.rows.length, 6);
        expect(
          stateManager.rows[0].cells['text0']!.value,
          columns[0].type.defaultValue,
        );
        expect(stateManager.rows[0].sortIdx, 0);
        // 원래 있던 첫번 째 Row 의 셀이 두번 째로 이동
        expect(stateManager.rows[1].cells['text0']!.value, 'text0 value 0');
        expect(stateManager.rows[1].sortIdx, 1);
      },
    );

    testWidgets(
      'count 5 만큼 rows 앞쪽에 추가 되어야 한다.',
      (WidgetTester tester) async {
        // given
        List<PlutoColumn> columns = [
          ...ColumnHelper.textColumn('text', count: 3, width: 150),
        ];

        List<PlutoRow> rows = RowHelper.count(5, columns);

        PlutoGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: null,
        );

        // when
        stateManager.prependNewRows(count: 5);

        // then
        expect(stateManager.rows.length, 10);
        // 원래 있던 첫번 째 Row 의 셀이 6번 째로 이동
        expect(stateManager.rows[5].cells['text0']!.value, 'text0 value 0');
        expect(stateManager.rows[5].sortIdx, 5);
      },
    );
  });

  group('prependRows', () {
    testWidgets('A new row must be added before the existing row.',
        (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
      ];

      List<PlutoRow> rows = RowHelper.count(5, columns);

      PlutoGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
      );

      PlutoRow newRow = RowHelper.count(1, columns).first;

      // when
      stateManager.prependRows([newRow]);

      // then
      expect(stateManager.rows[0].key, newRow.key);
      expect(stateManager.rows[0].sortIdx, 0);
      expect(stateManager.rows.length, 6);
    });

    testWidgets('Row is not added when passing an empty array.',
        (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
      ];

      List<PlutoRow> rows = RowHelper.count(5, columns);

      PlutoGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
      );

      // when
      stateManager.prependRows([]);

      // then
      expect(stateManager.rows.length, 5);
    });

    testWidgets(
        'WHEN currentCell 이 있는 상태에서 '
        'THEN '
        'currentRowIdx 와 currentCellPosition 이 '
        'rows 가 추가 된 만큼에 따라 업데이트 되어야 한다.', (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
      ];

      List<PlutoRow> rows = RowHelper.count(5, columns);

      PlutoGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: scroll,
        layout: const BoxConstraints(),
      );

      const int rowIdxBeforePrependRows = 0;

      stateManager.setCurrentCell(
          rows.first.cells['text1'], rowIdxBeforePrependRows);

      expect(stateManager.currentRowIdx, rowIdxBeforePrependRows);

      List<PlutoRow> newRows = RowHelper.count(5, columns);

      // when
      stateManager.prependRows(newRows);

      // then
      // 앞에 새로운 Row 가 추가 되면 현재 idx 에 추가 된 row 수량 만큼 더해 포커스를 유지.
      final rowIdxAfterPrependRows = newRows.length + rowIdxBeforePrependRows;

      expect(stateManager.currentRowIdx, rowIdxAfterPrependRows);

      expect(stateManager.currentCellPosition!.columnIdx, 1);

      expect(stateManager.currentCellPosition!.rowIdx, rowIdxAfterPrependRows);
    });

    testWidgets(
        'WHEN _currentSelectingPosition 이 있는 상태에서 '
        'THEN currentSelectingPosition 이 업데이트 되어야 한다.',
        (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
      ];

      List<PlutoRow> rows = RowHelper.count(5, columns);

      PlutoGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: scroll,
      );

      const int rowIdxBeforePrependRows = 3;

      stateManager.setCurrentSelectingPosition(
        cellPosition: const PlutoGridCellPosition(
          columnIdx: 2,
          rowIdx: rowIdxBeforePrependRows,
        ),
      );

      expect(
        stateManager.currentSelectingPosition!.rowIdx,
        rowIdxBeforePrependRows,
      );

      List<PlutoRow> newRows = RowHelper.count(7, columns);

      // when
      stateManager.prependRows(newRows);

      // then
      expect(stateManager.currentSelectingPosition!.columnIdx, 2);

      expect(
        stateManager.currentSelectingPosition!.rowIdx,
        newRows.length + rowIdxBeforePrependRows,
      );
    });
  });

  group('appendNewRows', () {
    testWidgets(
      'count 기본값 1 만큼 rows 뒤쪽에 추가 되어야 한다.',
      (WidgetTester tester) async {
        // given
        List<PlutoColumn> columns = [
          ...ColumnHelper.textColumn('text', count: 3, width: 150),
        ];

        List<PlutoRow> rows = RowHelper.count(5, columns);

        PlutoGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: null,
        );

        expect(stateManager.rows[4].sortIdx, 4);

        // when
        stateManager.appendNewRows();

        // then
        expect(stateManager.rows.length, 6);
        // 마지막 Row 에 추가 됨
        expect(
          stateManager.rows[5].cells['text0']!.value,
          columns[0].type.defaultValue,
        );
        // sortIdx 가 마지막
        expect(stateManager.rows[4].sortIdx, 4);
        expect(stateManager.rows[5].sortIdx, 5);
      },
    );

    testWidgets(
      'count 5 만큼 rows 뒤쪽에 추가 되어야 한다.',
      (WidgetTester tester) async {
        // given
        List<PlutoColumn> columns = [
          ...ColumnHelper.textColumn('text', count: 3, width: 150),
        ];

        List<PlutoRow> rows = RowHelper.count(5, columns);

        PlutoGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: null,
        );

        // when
        stateManager.appendNewRows(count: 5);

        // then
        expect(stateManager.rows.length, 10);
        // 추가 된 5~9 번 셀의 기본 값
        expect(
          stateManager.rows[5].cells['text0']!.value,
          columns[0].type.defaultValue,
        );
        expect(
          stateManager.rows[9].cells['text0']!.value,
          columns[0].type.defaultValue,
        );
        // sortIdx
        expect(stateManager.rows[5].sortIdx, 5);
        expect(stateManager.rows[9].sortIdx, 9);
      },
    );
  });

  group('appendRows', () {
    testWidgets('New rows must be added after the existing row.',
        (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
      ];

      List<PlutoRow> rows = RowHelper.count(5, columns);

      PlutoGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
      );

      List<PlutoRow> newRows = RowHelper.count(2, columns);

      // when
      stateManager.appendRows(newRows);

      // then
      expect(stateManager.rows[5].key, newRows[0].key);
      expect(stateManager.rows[6].key, newRows[1].key);
      expect(stateManager.rows[5].sortIdx, 5);
      expect(stateManager.rows[6].sortIdx, 6);
      expect(stateManager.rows.length, 7);
    });

    testWidgets('Row is not added when passing an empty array.',
        (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
      ];

      List<PlutoRow> rows = RowHelper.count(5, columns);

      PlutoGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
      );

      // when
      stateManager.appendRows([]);

      // then
      expect(stateManager.rows.length, 5);
    });
  });

  group('getNewRow', () {
    testWidgets(
      'Should be returned a row including cells filled with defaultValue of the column',
      (WidgetTester tester) async {
        // given
        List<PlutoColumn> columns = [
          PlutoColumn(
            title: 'text',
            field: 'text',
            type: PlutoColumnType.text(defaultValue: 'default text'),
          ),
          PlutoColumn(
            title: 'number',
            field: 'number',
            type: PlutoColumnType.number(defaultValue: 123),
          ),
          PlutoColumn(
            title: 'select',
            field: 'select',
            type: PlutoColumnType.select(<String>['One', 'Two'],
                defaultValue: 'Two'),
          ),
          PlutoColumn(
            title: 'date',
            field: 'date',
            type: PlutoColumnType.date(
                defaultValue: DateTime.parse('2020-09-01')),
          ),
          PlutoColumn(
            title: 'time',
            field: 'time',
            type: PlutoColumnType.time(defaultValue: '23:59'),
          ),
        ];

        List<PlutoRow> rows = [];

        PlutoGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: null,
        );

        // when
        PlutoRow newRow = stateManager.getNewRow();

        // then
        expect(newRow.cells['text']!.value, 'default text');
        expect(newRow.cells['number']!.value, 123);
        expect(newRow.cells['select']!.value, 'Two');
        expect(newRow.cells['date']!.value, DateTime.parse('2020-09-01'));
        expect(newRow.cells['time']!.value, '23:59');
      },
    );
  });

  group('getNewRows', () {
    testWidgets(
      'count 기본값 1 만큼 생성 되어야 한다.',
      (WidgetTester tester) async {
        // given
        // given
        List<PlutoColumn> columns = [
          ...ColumnHelper.textColumn('text', count: 2),
        ];

        List<PlutoRow> rows = [];

        PlutoGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: null,
        );
        // when
        List<PlutoRow> newRows = stateManager.getNewRows();

        // then
        expect(newRows.length, 1);
      },
    );

    testWidgets(
      'count 3 만큼 생성 되어야 한다.',
      (WidgetTester tester) async {
        // given
        // given
        List<PlutoColumn> columns = [
          ...ColumnHelper.textColumn('text', count: 2),
        ];

        List<PlutoRow> rows = [];

        PlutoGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: null,
        );
        // when
        List<PlutoRow> newRows = stateManager.getNewRows(count: 3);

        // then
        expect(newRows.length, 3);
      },
    );
  });

  group('removeCurrentRow', () {
    testWidgets('Should not be removed rows, when currentRow is null.',
        (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
      ];

      List<PlutoRow> rows = RowHelper.count(5, columns);

      PlutoGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
      );

      // when
      stateManager.removeCurrentRow();

      // then
      expect(stateManager.rows.length, 5);
    });

    testWidgets('Should be removed currentRow, when currentRow is not null.',
        (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
      ];

      List<PlutoRow> rows = RowHelper.count(5, columns);

      PlutoGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
        layout: const BoxConstraints(),
      );

      // when
      final currentRowKey = rows[3].key;

      stateManager.setCurrentCell(rows[3].cells['text1'], 3);

      stateManager.removeCurrentRow();

      // then
      expect(stateManager.rows.length, 4);
      expect(stateManager.rows[0].key, isNot(currentRowKey));
      expect(stateManager.rows[1].key, isNot(currentRowKey));
      expect(stateManager.rows[2].key, isNot(currentRowKey));
      expect(stateManager.rows[3].key, isNot(currentRowKey));
    });
  });

  group('removeRows', () {
    testWidgets('Should not be removed rows, when rows parameter is null.',
        (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
      ];

      List<PlutoRow> rows = RowHelper.count(5, columns);

      PlutoGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
      );

      // when
      stateManager.removeRows([]);

      // then
      expect(stateManager.rows.length, 5);
    });

    testWidgets('Should be removed rows, when rows parameter is not null.',
        (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
      ];

      List<PlutoRow> rows = RowHelper.count(5, columns);

      PlutoGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
      );

      // when
      final deleteRows = [rows[0], rows[1]];

      stateManager.removeRows(deleteRows);

      // then
      final deleteRowKeys =
          deleteRows.map((e) => e.key).toList(growable: false);

      expect(stateManager.rows.length, 3);
      expect(deleteRowKeys.contains(stateManager.rows[0].key), false);
      expect(deleteRowKeys.contains(stateManager.rows[1].key), false);
      expect(deleteRowKeys.contains(stateManager.rows[2].key), false);
    });

    testWidgets('Should be removed all rows', (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
      ];

      List<PlutoRow> rows = RowHelper.count(5, columns);

      PlutoGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
      );

      // when
      final deleteRows = [...rows];

      stateManager.removeRows(deleteRows);

      // then
      expect(stateManager.rows.length, 0);
    });
  });

  group('moveRowsByOffset', () {
    testWidgets(
      '0번 row 를 1번 row 로 이동 시키기',
      (WidgetTester tester) async {
        // given
        List<PlutoColumn> columns = [
          ...ColumnHelper.textColumn('text', count: 3, width: 150),
        ];

        List<PlutoRow> rows = RowHelper.count(5, columns);

        when(scroll.verticalOffset).thenReturn(0);

        PlutoGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: scroll,
          layout: const BoxConstraints(
            maxWidth: 500,
            maxHeight: 300,
          ),
        );

        stateManager.setGridGlobalOffset(const Offset(0.0, 0.0));

        final listener = MockMethods();

        stateManager.addListener(listener.noParamReturnVoid);

        // when
        final rowKey = rows.first.key;

        // header size + row 0 + row 1(중간)
        final offset = stateManager.rowTotalHeight * 2.5;

        stateManager.moveRowsByOffset(
          [rows.first],
          offset,
        );

        // then
        expect(stateManager.rows.length, 5);
        expect(stateManager.rows[1].key, rowKey);
        verify(listener.noParamReturnVoid()).called(1);
      },
    );

    testWidgets(
      '2번 row 를 1번 row 로 이동 시키기',
      (WidgetTester tester) async {
        // given
        List<PlutoColumn> columns = [
          ...ColumnHelper.textColumn('text', count: 3, width: 150),
        ];

        List<PlutoRow> rows = RowHelper.count(5, columns);

        when(scroll.verticalOffset).thenReturn(0);

        PlutoGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: scroll,
          layout: const BoxConstraints(
            maxWidth: 500,
            maxHeight: 300,
          ),
        );

        stateManager.setGridGlobalOffset(const Offset(0.0, 0.0));

        final listener = MockMethods();

        stateManager.addListener(listener.noParamReturnVoid);

        // when
        final rowKey = rows[2].key;

        // header size + row 0 + row 1(중간)
        final offset = stateManager.rowTotalHeight * 2.5;

        stateManager.moveRowsByOffset(
          [rows[2]],
          offset,
        );

        // then
        expect(stateManager.rows.length, 5);
        expect(stateManager.rows[1].key, rowKey);
        verify(listener.noParamReturnVoid()).called(1);
      },
    );

    testWidgets(
      '이동 할 index + 이동 할 row 개수가 전체 rows 길이보다 크면 마지막 행으로 이동',
      (WidgetTester tester) async {
        // given
        List<PlutoColumn> columns = [
          ...ColumnHelper.textColumn('text', count: 3, width: 150),
        ];

        List<PlutoRow> rows = RowHelper.count(5, columns);

        when(scroll.verticalOffset).thenReturn(0);

        PlutoGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: scroll,
          layout: const BoxConstraints(
            maxWidth: 500,
            maxHeight: 300,
          ),
        );

        stateManager.setGridGlobalOffset(const Offset(0.0, 0.0));

        final listener = MockMethods();

        stateManager.addListener(listener.noParamReturnVoid);

        // when
        final rowKey = rows.first.key;

        // header size + row0 ~ row4
        final offset = stateManager.rowTotalHeight * 5.5;

        stateManager.moveRowsByOffset(
          <PlutoRow>[rows.first],
          offset,
        );

        // then
        expect(stateManager.rows.length, 5);
        expect(stateManager.rows[4].key, rowKey);
        verify(listener.noParamReturnVoid()).called(1);
      },
    );

    testWidgets(
      'offset 값이 0 보다 작으면 notifyListener 가 호출 되지 않아야 한다.',
      (WidgetTester tester) async {
        // given
        List<PlutoColumn> columns = [
          ...ColumnHelper.textColumn('text', count: 3, width: 150),
        ];

        List<PlutoRow> rows = RowHelper.count(5, columns);

        when(scroll.verticalOffset).thenReturn(0);

        PlutoGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: scroll,
          layout: const BoxConstraints(
            maxWidth: 500,
            maxHeight: 300,
          ),
        );

        stateManager.setGridGlobalOffset(const Offset(0.0, 0.0));

        final listener = MockMethods();

        stateManager.addListener(listener.noParamReturnVoid);

        // when
        const offset = -10.0;

        stateManager.moveRowsByOffset(
          [rows.first],
          offset,
        );

        // then
        expect(stateManager.rows.length, 5);
        verifyNever(listener.noParamReturnVoid());
      },
    );

    testWidgets(
      'offset 값이 행 범위 보다 크면 notifyListener 가 호출 되지 않아야 한다.',
      (WidgetTester tester) async {
        // given
        List<PlutoColumn> columns = [
          ...ColumnHelper.textColumn('text', count: 3, width: 150),
        ];

        List<PlutoRow> rows = RowHelper.count(5, columns);

        when(scroll.verticalOffset).thenReturn(0);

        PlutoGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: scroll,
          layout: const BoxConstraints(
            maxWidth: 500,
            maxHeight: 300,
          ),
        );

        stateManager.setGridGlobalOffset(const Offset(0.0, 0.0));

        final listener = MockMethods();

        stateManager.addListener(listener.noParamReturnVoid);

        // when
        // header + row0 ~ row4 + 1
        final offset = stateManager.rowTotalHeight * 7;

        stateManager.moveRowsByOffset(
          [rows.first],
          offset,
        );

        // then
        expect(stateManager.rows.length, 5);
        verifyNever(listener.noParamReturnVoid());
      },
    );

    testWidgets(
      'createHeader 가 있는 상태에서 1번 row 를 0번 row 로 이동 시키기',
      (WidgetTester tester) async {
        // given
        List<PlutoColumn> columns = [
          ...ColumnHelper.textColumn('text', count: 3, width: 150),
        ];

        List<PlutoRow> rows = RowHelper.count(5, columns);

        when(scroll.verticalOffset).thenReturn(0);

        PlutoGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: scroll,
          createHeader: (PlutoGridStateManager? stateManager) =>
              const Text('header'),
          layout: const BoxConstraints(
            maxWidth: 500,
            maxHeight: 300,
          ),
        );

        stateManager.setGridGlobalOffset(const Offset(0.0, 0.0));

        final listener = MockMethods();

        stateManager.addListener(listener.noParamReturnVoid);

        // when
        final rowKey = rows[1].key;

        // header size + column size + row 0(중간)
        final offset = stateManager.rowTotalHeight * 2.5;

        stateManager.moveRowsByOffset(
          [rows[1]],
          offset,
        );

        // then
        expect(stateManager.rows.length, 5);
        expect(stateManager.rows[0].key, rowKey);
        verify(listener.noParamReturnVoid()).called(1);
      },
    );
  });

  group('moveRowsByIndex', () {
    testWidgets(
      '0번 row 를 1번 row 로 이동 시키기',
      (WidgetTester tester) async {
        // given
        List<PlutoColumn> columns = [
          ...ColumnHelper.textColumn('text', count: 3, width: 150),
        ];

        List<PlutoRow> rows = RowHelper.count(5, columns);

        PlutoGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: scroll,
        );

        final listener = MockMethods();

        stateManager.addListener(listener.noParamReturnVoid);

        // when
        final rowKey = rows.first.key;

        stateManager.moveRowsByIndex(
          [rows.first],
          1,
        );

        // then
        expect(stateManager.rows.length, 5);
        expect(stateManager.rows[1].key, rowKey);
        verify(listener.noParamReturnVoid()).called(1);
      },
    );

    testWidgets(
      '2번 row 를 1번 row 로 이동 시키기',
      (WidgetTester tester) async {
        // given
        List<PlutoColumn> columns = [
          ...ColumnHelper.textColumn('text', count: 3, width: 150),
        ];

        List<PlutoRow> rows = RowHelper.count(5, columns);

        PlutoGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: scroll,
        );

        final listener = MockMethods();

        stateManager.addListener(listener.noParamReturnVoid);

        // when
        final rowKey = rows[2].key;

        stateManager.moveRowsByIndex(
          [rows[2]],
          1,
        );

        // then
        expect(stateManager.rows.length, 5);
        expect(stateManager.rows[1].key, rowKey);
        verify(listener.noParamReturnVoid()).called(1);
      },
    );

    testWidgets(
      '행 2개가 있는 상태에서 0번 컬럼을 1번으로 이동 할 경우 타입에러가 발생되지 않고 이동 되어야 한다.',
      (WidgetTester tester) async {
        // given
        List<PlutoColumn> columns = [
          ...ColumnHelper.textColumn('text', count: 3, width: 150),
        ];

        List<PlutoRow> rows = RowHelper.count(2, columns);

        PlutoGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: scroll,
        );

        final listener = MockMethods();

        stateManager.addListener(listener.noParamReturnVoid);

        // when
        final rowKey = rows[0].key;

        stateManager.moveRowsByIndex(
          [rows[0]],
          1,
        );

        // then
        expect(stateManager.rows.length, 2);
        expect(stateManager.rows[1].key, rowKey);
        verify(listener.noParamReturnVoid()).called(1);
      },
    );
  });

  group('toggleAllRowChecked', () {
    testWidgets(
      '전체 행이 checked true 로 변경 되어야 한다.',
      (WidgetTester tester) async {
        // given
        List<PlutoColumn> columns =
            ColumnHelper.textColumn('body', count: 1, width: 150);

        List<PlutoRow> rows = [...RowHelper.count(10, columns)];

        PlutoGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: null,
        );

        final listener = MockMethods();

        stateManager.addListener(listener.noParamReturnVoid);

        // when
        stateManager.toggleAllRowChecked(true);

        // then
        expect(
            stateManager.rows.where((element) => element.checked!).length, 10);
        verify(listener.noParamReturnVoid()).called(1);
      },
    );

    testWidgets(
      '전체 행이 checked false 로 변경 되어야 한다.',
      (WidgetTester tester) async {
        // given
        List<PlutoColumn> columns =
            ColumnHelper.textColumn('body', count: 1, width: 150);

        List<PlutoRow> rows = [...RowHelper.count(10, columns)];

        PlutoGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: null,
        );

        final listener = MockMethods();

        stateManager.addListener(listener.noParamReturnVoid);

        // when
        stateManager.toggleAllRowChecked(false);

        // then
        expect(
            stateManager.rows.where((element) => !element.checked!).length, 10);
        verify(listener.noParamReturnVoid()).called(1);
      },
    );

    testWidgets(
      'notify 가 false 인 경우 notifyListener 가 호출 되지 않아야 한다.',
      (WidgetTester tester) async {
        // given
        List<PlutoColumn> columns =
            ColumnHelper.textColumn('body', count: 1, width: 150);

        List<PlutoRow> rows = [...RowHelper.count(10, columns)];

        PlutoGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: null,
        );

        final listener = MockMethods();

        stateManager.addListener(listener.noParamReturnVoid);

        // when
        stateManager.toggleAllRowChecked(true, notify: false);

        // then
        expect(
            stateManager.rows.where((element) => element.checked!).length, 10);
        verifyNever(listener.noParamReturnVoid());
      },
    );
  });
}
