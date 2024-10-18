import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../helper/column_helper.dart';
import '../../helper/row_helper.dart';

class _MockScrollController extends Mock implements ScrollController {}

void main() {
  group('selectingModes', () {
    test('Square, Row, None 이 리턴 되야 한다.', () {
      const selectingModes = PlutoGridSelectingMode.values;

      expect(selectingModes.contains(PlutoGridSelectingMode.cell), isTrue);
      expect(selectingModes.contains(PlutoGridSelectingMode.row), isTrue);
      expect(selectingModes.contains(PlutoGridSelectingMode.none), isTrue);
    });
  });

  group('PlutoScrollController', () {
    test('bodyRowsVertical', () {
      final PlutoGridScrollController scrollController =
          PlutoGridScrollController();

      ScrollController scroll = _MockScrollController();
      ScrollController anotherScroll = _MockScrollController();

      scrollController.setBodyRowsVertical(scroll);

      expect(scrollController.bodyRowsVertical == scroll, isTrue);
      expect(scrollController.bodyRowsVertical == anotherScroll, isFalse);
      expect(scroll == anotherScroll, isFalse);
    });
  });

  group('PlutoCellPosition', () {
    testWidgets('null 과의 비교는 false 를 리턴 해야 한다.', (WidgetTester tester) async {
      // given
      const cellPositionA = PlutoGridCellPosition(
        columnIdx: 1,
        rowIdx: 1,
      );

      PlutoGridCellPosition? cellPositionB;

      // when
      final bool compare = cellPositionA == cellPositionB;
      // then

      expect(compare, false);
    });

    testWidgets('값이 다른 비교는 false 를 리턴 해야 한다.', (WidgetTester tester) async {
      // given
      const cellPositionA = PlutoGridCellPosition(
        columnIdx: 1,
        rowIdx: 1,
      );

      const cellPositionB = PlutoGridCellPosition(
        columnIdx: 2,
        rowIdx: 1,
      );

      // when
      final bool compare = cellPositionA == cellPositionB;
      // then

      expect(compare, false);
    });

    testWidgets('값이 동일한 비교는 true 를 리턴 해야 한다.', (WidgetTester tester) async {
      // given
      const cellPositionA = PlutoGridCellPosition(
        columnIdx: 1,
        rowIdx: 1,
      );

      const cellPositionB = PlutoGridCellPosition(
        columnIdx: 1,
        rowIdx: 1,
      );

      // when
      final bool compare = cellPositionA == cellPositionB;
      // then

      expect(compare, true);
    });
  });

  group('initializeRows', () {
    test('전달 한 행의 sortIdx 가 설정 되어야 한다.', () {
      final List<PlutoColumn> columns = ColumnHelper.textColumn('title');

      final List<PlutoRow> rows = [
        PlutoRow(cells: {'title0': PlutoCell(value: 'test')}),
        PlutoRow(cells: {'title0': PlutoCell(value: 'test')}),
        PlutoRow(cells: {'title0': PlutoCell(value: 'test')}),
        PlutoRow(cells: {'title0': PlutoCell(value: 'test')}),
        PlutoRow(cells: {'title0': PlutoCell(value: 'test')}),
      ];

      PlutoGridStateManager.initializeRows(
        columns,
        rows,
        forceApplySortIdx: true,
      );

      expect(rows.first.sortIdx, 0);
      expect(rows.last.sortIdx, 4);
    });

    test(
        'forceApplySortIdx 가 false 이고 이미 sortIdx 가 설정 된 경우 sortIdx 값이 유지 되어야 한다.',
        () {
      final List<PlutoColumn> columns = ColumnHelper.textColumn('title');

      final List<PlutoRow> rows = [
        PlutoRow(
          cells: {'title0': PlutoCell(value: 'test')},
          sortIdx: 3,
        ),
        PlutoRow(
          cells: {'title0': PlutoCell(value: 'test')},
          sortIdx: 4,
        ),
        PlutoRow(
          cells: {'title0': PlutoCell(value: 'test')},
          sortIdx: 5,
        ),
      ];

      expect(rows.first.sortIdx, 3);
      expect(rows.last.sortIdx, 5);

      PlutoGridStateManager.initializeRows(
        columns,
        rows,
        forceApplySortIdx: false,
      );

      expect(rows.first.sortIdx, 3);
      expect(rows.last.sortIdx, 5);
    });

    test(
        'forceApplySortIdx 가 true 인 경우, '
        '이미 sortIdx 가 설정 되어도 0부터 다시 설정 되어야 한다.', () {
      final List<PlutoColumn> columns = ColumnHelper.textColumn('title');

      final List<PlutoRow> rows = [
        PlutoRow(
          cells: {'title0': PlutoCell(value: 'test')},
          sortIdx: 3,
        ),
        PlutoRow(
          cells: {'title0': PlutoCell(value: 'test')},
          sortIdx: 4,
        ),
        PlutoRow(
          cells: {'title0': PlutoCell(value: 'test')},
          sortIdx: 5,
        ),
      ];

      expect(rows.first.sortIdx, 3);
      expect(rows.last.sortIdx, 5);

      PlutoGridStateManager.initializeRows(
        columns,
        rows,
        forceApplySortIdx: true,
      );

      expect(rows.first.sortIdx, 0);
      expect(rows.last.sortIdx, 2);
    });

    test('increase 가 false 인 경우 값이 0부터 음수로 설정 되어야 한다.', () {
      final List<PlutoColumn> columns = ColumnHelper.textColumn('title');

      final List<PlutoRow> rows = [
        PlutoRow(cells: {'title0': PlutoCell(value: 'test')}),
        PlutoRow(cells: {'title0': PlutoCell(value: 'test')}),
        PlutoRow(cells: {'title0': PlutoCell(value: 'test')}),
        PlutoRow(cells: {'title0': PlutoCell(value: 'test')}),
        PlutoRow(cells: {'title0': PlutoCell(value: 'test')}),
      ];

      PlutoGridStateManager.initializeRows(
        columns,
        rows,
        increase: false,
        forceApplySortIdx: true,
      );

      expect(rows.first.sortIdx, 0);
      expect(rows.last.sortIdx, -4);
    });

    test('increase 가 false, start 가 -10 인 경우 값이 -10 부터 음수로 설정 되어야 한다.', () {
      final List<PlutoColumn> columns = ColumnHelper.textColumn('title');

      final List<PlutoRow> rows = [
        PlutoRow(cells: {'title0': PlutoCell(value: 'test')}),
        PlutoRow(cells: {'title0': PlutoCell(value: 'test')}),
        PlutoRow(cells: {'title0': PlutoCell(value: 'test')}),
        PlutoRow(cells: {'title0': PlutoCell(value: 'test')}),
        PlutoRow(cells: {'title0': PlutoCell(value: 'test')}),
      ];

      PlutoGridStateManager.initializeRows(
        columns,
        rows,
        increase: false,
        start: -10,
        forceApplySortIdx: true,
      );

      expect(rows.first.sortIdx, -10);
      expect(rows.last.sortIdx, -14);
    });

    test('컬럼 타입이 숫자인 경우 셀 값이 숫자로 cast 되어야 한다.', () {
      final List<PlutoColumn> columns = [
        PlutoColumn(
          title: 'title',
          field: 'field',
          type: PlutoColumnType.number(),
        )
      ];

      final List<PlutoRow> rows = [
        PlutoRow(cells: {'field': PlutoCell(value: '10')}),
        PlutoRow(cells: {'field': PlutoCell(value: '300')}),
        PlutoRow(cells: {'field': PlutoCell(value: 1000)}),
      ];

      PlutoGridStateManager.initializeRows(
        columns,
        rows,
      );

      expect(rows[0].cells['field']!.value, 10);
      expect(rows[1].cells['field']!.value, 300);
      expect(rows[2].cells['field']!.value, 1000);
    });

    test(
        'applyFormatOnInit 이 false 인 경우, '
        '값이 cast 되지 않아야 한다.', () {
      final List<PlutoColumn> columns = [
        PlutoColumn(
          title: 'title',
          field: 'field',
          type: PlutoColumnType.number(
            applyFormatOnInit: false,
          ),
        )
      ];

      final List<PlutoRow> rows = [
        PlutoRow(cells: {'field': PlutoCell(value: '10')}),
        PlutoRow(cells: {'field': PlutoCell(value: '300')}),
        PlutoRow(cells: {'field': PlutoCell(value: 1000)}),
      ];

      PlutoGridStateManager.initializeRows(
        columns,
        rows,
      );

      expect(rows[0].cells['field']!.value, '10');
      expect(rows[1].cells['field']!.value, '300');
      expect(rows[2].cells['field']!.value, 1000);
    });

    test('컬럼 타입이 Date 인 경우 셀 값이 날짜 포멧에 맞게 변경 되어야 한다.', () {
      final List<PlutoColumn> columns = [
        PlutoColumn(
          title: 'title',
          field: 'field',
          type: PlutoColumnType.date(),
        )
      ];

      final List<PlutoRow> rows = [
        PlutoRow(cells: {'field': PlutoCell(value: '2021-01-01 12:30:51')}),
        PlutoRow(cells: {'field': PlutoCell(value: '2021-01-03 12:40:52')}),
        PlutoRow(cells: {'field': PlutoCell(value: '2021-01-04 12:50:53')}),
      ];

      PlutoGridStateManager.initializeRows(
        columns,
        rows,
      );

      expect(rows[0].cells['field']!.value, '2021-01-01');
      expect(rows[1].cells['field']!.value, '2021-01-03');
      expect(rows[2].cells['field']!.value, '2021-01-04');
    });

    test('applyFormatOnInit 이 false 인 경우 컬럼 타입이 Date 인 셀 값이 변경 되지 않아야 한다.', () {
      final List<PlutoColumn> columns = [
        PlutoColumn(
          title: 'title',
          field: 'field',
          type: PlutoColumnType.date(
            applyFormatOnInit: false,
          ),
        )
      ];

      final List<PlutoRow> rows = [
        PlutoRow(cells: {'field': PlutoCell(value: '2021-01-01 12:30:51')}),
        PlutoRow(cells: {'field': PlutoCell(value: '2021-01-03 12:40:52')}),
        PlutoRow(cells: {'field': PlutoCell(value: '2021-01-04 12:50:53')}),
      ];

      PlutoGridStateManager.initializeRows(
        columns,
        rows,
      );

      expect(rows[0].cells['field']!.value, '2021-01-01 12:30:51');
      expect(rows[1].cells['field']!.value, '2021-01-03 12:40:52');
      expect(rows[2].cells['field']!.value, '2021-01-04 12:50:53');
    });

    test('format 값을 설정한 경우 컬럼 타입이 Date 인 셀 값이 포멧에 맞게 변경 되어야 한다.', () {
      final List<PlutoColumn> columns = [
        PlutoColumn(
          title: 'title',
          field: 'field',
          type: PlutoColumnType.date(format: 'yyyy년 MM월 dd일'),
        )
      ];

      final List<PlutoRow> rows = [
        PlutoRow(cells: {'field': PlutoCell(value: '2021-01-01 12:30:51')}),
        PlutoRow(cells: {'field': PlutoCell(value: '2021-01-03 12:40:52')}),
        PlutoRow(cells: {'field': PlutoCell(value: '2021-01-04 12:50:53')}),
      ];

      PlutoGridStateManager.initializeRows(
        columns,
        rows,
      );

      expect(rows[0].cells['field']!.value, '2021년 01월 01일');
      expect(rows[1].cells['field']!.value, '2021년 01월 03일');
      expect(rows[2].cells['field']!.value, '2021년 01월 04일');
    });

    test('각 셀에 row 와 column 이 설정 되어야 한다.', () {
      final List<PlutoColumn> columns = [
        PlutoColumn(
          title: 'title',
          field: 'field',
          type: PlutoColumnType.date(format: 'yyyy년 MM월 dd일'),
        )
      ];

      final List<PlutoRow> rows = [
        PlutoRow(cells: {'field': PlutoCell(value: '2021-01-01 12:30:51')}),
        PlutoRow(cells: {'field': PlutoCell(value: '2021-01-03 12:40:52')}),
        PlutoRow(cells: {'field': PlutoCell(value: '2021-01-04 12:50:53')}),
      ];

      PlutoGridStateManager.initializeRows(
        columns,
        rows,
      );

      expect(rows[0].cells['field']!.row, rows[0]);
      expect(rows[0].cells['field']!.column, columns.first);

      expect(rows[1].cells['field']!.row, rows[1]);
      expect(rows[1].cells['field']!.column, columns.first);

      expect(rows[2].cells['field']!.row, rows[2]);
      expect(rows[2].cells['field']!.column, columns.first);
    });
  });

  group('initializeRowsAsync', () {
    test('chunkSize 가 0 이면 assert 가 발생 되어야 한다.', () async {
      final List<PlutoColumn> columns = ColumnHelper.textColumn('title');

      final List<PlutoRow> rows = RowHelper.count(1, columns);

      expect(
        () async {
          await PlutoGridStateManager.initializeRowsAsync(
            columns,
            rows,
            chunkSize: 0,
          );
        },
        throwsAssertionError,
      );
    });

    test('chunkSize 가 -1 이면 assert 가 발생 되어야 한다.', () async {
      final List<PlutoColumn> columns = ColumnHelper.textColumn('title');

      final List<PlutoRow> rows = RowHelper.count(1, columns);

      expect(
        () async {
          await PlutoGridStateManager.initializeRowsAsync(
            columns,
            rows,
            chunkSize: -1,
          );
        },
        throwsAssertionError,
      );
    });

    test(
        'sortIdx 가 0부터 설정 된 rows 를 sortIdx 시작 값을 변경하여 실행하면, '
        'sortIdx 값을 10 으로 변경 하면 rows 의 sortIdx 가 변경 되고, '
        '원래 순서대로 리턴 되어야 한다.', () async {
      final List<PlutoColumn> columns = ColumnHelper.textColumn('title');

      final List<PlutoRow> rows = RowHelper.count(100, columns);

      final Iterable<Key> rowKeys = rows.map((e) => e.key);

      expect(rows.first.sortIdx, 0);
      expect(rows.last.sortIdx, 99);

      final initializedRows = await PlutoGridStateManager.initializeRowsAsync(
        columns,
        rows,
        forceApplySortIdx: true,
        start: 10,
        chunkSize: 10,
        duration: const Duration(milliseconds: 1),
      );

      for (int i = 0; i < initializedRows.length; i += 1) {
        expect(initializedRows[i].sortIdx, 10 + i);
        expect(initializedRows[i].key, rowKeys.elementAt(i));
      }
    });

    test(
        'sortIdx 가 0부터 설정 된 rows 를 sortIdx 시작 값을 변경하여 실행하면, '
        'sortIdx 값을 -10 으로 변경 하면 rows 의 sortIdx 가 변경 되고, '
        '원래 순서대로 리턴 되어야 한다.', () async {
      final List<PlutoColumn> columns = ColumnHelper.textColumn('title');

      final List<PlutoRow> rows = RowHelper.count(100, columns);

      final Iterable<Key> rowKeys = rows.map((e) => e.key);

      expect(rows.first.sortIdx, 0);
      expect(rows.last.sortIdx, 99);

      final initializedRows = await PlutoGridStateManager.initializeRowsAsync(
        columns,
        rows,
        forceApplySortIdx: true,
        start: -10,
        chunkSize: 10,
        duration: const Duration(milliseconds: 1),
      );

      for (int i = 0; i < initializedRows.length; i += 1) {
        expect(initializedRows[i].sortIdx, -10 + i);
        expect(initializedRows[i].key, rowKeys.elementAt(i));
      }
    });

    test(
        'sortIdx 가 0부터 설정 된 rows 를 sortIdx 시작 값을 변경하여 실행하면, '
        'sortIdx 값을 -10 으로 변경 하면 rows 의 sortIdx 가 변경 되고, '
        '원래 순서대로 리턴 되어야 한다.', () async {
      final List<PlutoColumn> columns = ColumnHelper.textColumn('title');

      final List<PlutoRow> rows = RowHelper.count(100, columns);

      final Iterable<Key> rowKeys = rows.map((e) => e.key);

      expect(rows.first.sortIdx, 0);
      expect(rows.last.sortIdx, 99);

      final initializedRows = await PlutoGridStateManager.initializeRowsAsync(
        columns,
        rows,
        forceApplySortIdx: true,
        start: -10,
        chunkSize: 10,
        duration: const Duration(milliseconds: 1),
      );

      for (int i = 0; i < initializedRows.length; i += 1) {
        expect(initializedRows[i].sortIdx, -10 + i);
        expect(initializedRows[i].key, rowKeys.elementAt(i));
      }
    });

    test('한개의 행을 전달하고 chunkSize 가 10 인경우 정상적으로 리턴 되어야 한다.', () async {
      final List<PlutoColumn> columns = ColumnHelper.textColumn('title');

      final List<PlutoRow> rows = RowHelper.count(1, columns);

      final initializedRows = await PlutoGridStateManager.initializeRowsAsync(
        columns,
        rows,
        forceApplySortIdx: true,
        start: 99,
        chunkSize: 10,
        duration: const Duration(milliseconds: 1),
      );

      expect(initializedRows.first.sortIdx, 99);
    });
  });
}
