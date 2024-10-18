import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../helper/column_helper.dart';
import '../../../helper/row_helper.dart';
import '../../../mock/mock_methods.dart';
import '../../../mock/shared_mocks.mocks.dart';

void main() {
  PlutoGridStateManager createStateManager({
    required List<PlutoColumn> columns,
    required List<PlutoRow> rows,
    FocusNode? gridFocusNode,
    PlutoGridScrollController? scroll,
    BoxConstraints? layout,
    PlutoGridConfiguration configuration = const PlutoGridConfiguration(),
    PlutoGridMode? mode,
  }) {
    final stateManager = PlutoGridStateManager(
      columns: columns,
      rows: rows,
      gridFocusNode: gridFocusNode ?? MockFocusNode(),
      scroll: scroll ?? MockPlutoGridScrollController(),
      configuration: configuration,
      mode: mode,
    );

    stateManager.setEventManager(MockPlutoGridEventManager());

    if (layout != null) {
      stateManager.setLayout(layout);
    }

    return stateManager;
  }

  group('currentCellPosition', () {
    testWidgets(
        'currentCellPosition - currentCell 이 선택되지 않은 경우 null 을 리턴해야 한다.',
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
        scroll: null,
      );

      // when
      PlutoGridCellPosition? currentCellPosition =
          stateManager.currentCellPosition;

      // when
      expect(currentCellPosition, null);
    });

    testWidgets('currentCellPosition - currentCell 이 선택된 경우 선택 된 위치를 리턴해야 한다.',
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
        scroll: null,
      );

      // when
      stateManager
          .setLayout(const BoxConstraints(maxWidth: 1900, maxHeight: 500));

      String selectColumnField = 'body1';
      stateManager.setCurrentCell(rows[5].cells[selectColumnField], 5);

      PlutoGridCellPosition currentCellPosition =
          stateManager.currentCellPosition!;

      // when
      expect(currentCellPosition, isNot(null));
      expect(currentCellPosition.rowIdx, 5);
      expect(currentCellPosition.columnIdx, 4);
    });

    testWidgets(
        'currentCellPosition - currentCell 이 선택된 경우 선택 된 위치를 리턴해야 한다.'
        '컬럼 고정 상태가 바뀌고, body 최소 넓이가 작은 경우', (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn('body', count: 10, width: 150),
      ];

      List<PlutoRow> rows = RowHelper.count(10, columns);

      PlutoGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
      );

      stateManager.setLayout(
        const BoxConstraints(maxWidth: 300, maxHeight: 500),
      );

      // when
      stateManager.toggleFrozenColumn(columns[2], PlutoColumnFrozen.start);
      stateManager.toggleFrozenColumn(columns[4], PlutoColumnFrozen.end);

      stateManager.setLayout(
        const BoxConstraints(maxWidth: 300, maxHeight: 500),
      );

      String selectColumnField = 'body2';
      stateManager.setCurrentCell(rows[5].cells[selectColumnField], 5);

      PlutoGridCellPosition currentCellPosition =
          stateManager.currentCellPosition!;

      // when
      expect(currentCellPosition, isNot(null));
      expect(currentCellPosition.rowIdx, 5);
      // 3번 째 컬럼을 왼쪽으로 옴겨 첫번 째 컬럼이 되었지만 그리드 최소 넓이가 300으로
      // 충분하지 않아 고정 컬럼이 풀리고 원래 순서대로 노출 된다.
      expect(currentCellPosition.columnIdx, 2);
    });

    testWidgets(
        'currentCellPosition - currentCell 이 선택된 경우 선택 된 위치를 리턴해야 한다.'
        '컬럼 고정 상태가 바뀌고, body 최소 넓이가 충분한 경우', (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn('body', count: 10, width: 150),
      ];

      List<PlutoRow> rows = RowHelper.count(10, columns);

      PlutoGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
      );

      stateManager.setLayout(
        const BoxConstraints(maxWidth: 1900, maxHeight: 500),
      );

      // when
      stateManager.toggleFrozenColumn(columns[2], PlutoColumnFrozen.start);
      stateManager.toggleFrozenColumn(columns[4], PlutoColumnFrozen.end);

      stateManager.setLayout(
        const BoxConstraints(maxWidth: 1900, maxHeight: 500),
      );

      String selectColumnField = 'body2';
      stateManager.setCurrentCell(rows[5].cells[selectColumnField], 5);

      PlutoGridCellPosition currentCellPosition =
          stateManager.currentCellPosition!;

      // when
      expect(currentCellPosition, isNot(null));
      expect(currentCellPosition.rowIdx, 5);
      // 3번 째 컬럼을 왼쪽으로 고정 후 넓이가 충분하여 첫번 째 컬럼이 된다.
      expect(currentCellPosition.columnIdx, 0);
    });
  });

  group('setCurrentCellPosition', () {
    testWidgets(
      'cellPosition 이 currentCellPosition 과 같다면 '
      'currentCellPosition 이 업데이트 되지 않아야 한다.',
      (WidgetTester tester) async {
        // given
        List<PlutoColumn> columns = [
          ...ColumnHelper.textColumn('body', count: 10, width: 150),
        ];

        List<PlutoRow> rows = RowHelper.count(10, columns);

        PlutoGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: null,
        );

        final listener = MockMethods();

        stateManager.addListener(listener.noParamReturnVoid);

        expect(stateManager.currentCellPosition, isNull);

        stateManager.setCurrentCellPosition(
          const PlutoGridCellPosition(columnIdx: 0, rowIdx: 1),
        );

        expect(stateManager.currentCellPosition!.columnIdx, 0);
        expect(stateManager.currentCellPosition!.rowIdx, 1);

        // when
        stateManager.setCurrentCellPosition(
          const PlutoGridCellPosition(columnIdx: 0, rowIdx: 1),
        );

        // then
        verify(listener.noParamReturnVoid()).called(1);
      },
    );

    testWidgets(
      'cellPosition 의 columnIdx 가 currentCellPosition 의 columnIdx 와 다르면 '
      'currentCellPosition 이 업데이트 되어야 한다.',
      (WidgetTester tester) async {
        // given
        List<PlutoColumn> columns = [
          ...ColumnHelper.textColumn('body', count: 10, width: 150),
        ];

        List<PlutoRow> rows = RowHelper.count(10, columns);

        PlutoGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: null,
        );

        final listener = MockMethods();

        stateManager.addListener(listener.noParamReturnVoid);

        expect(stateManager.currentCellPosition, isNull);

        stateManager.setCurrentCellPosition(
          const PlutoGridCellPosition(columnIdx: 0, rowIdx: 1),
        );

        expect(stateManager.currentCellPosition!.columnIdx, 0);
        expect(stateManager.currentCellPosition!.rowIdx, 1);

        // when
        stateManager.setCurrentCellPosition(
          const PlutoGridCellPosition(columnIdx: 1, rowIdx: 1),
        );

        stateManager.setCurrentCellPosition(
          const PlutoGridCellPosition(columnIdx: 2, rowIdx: 1),
        );

        stateManager.setCurrentCellPosition(
          const PlutoGridCellPosition(columnIdx: 2, rowIdx: 2),
        );

        // then
        verify(listener.noParamReturnVoid()).called(4);
      },
    );

    testWidgets(
      'cellPosition 의 columnIdx 가 currentCellPosition 의 columnIdx 와 다르지만 '
      'column 의 index 범위가 아니면 '
      'currentCellPosition 이 업데이트 되지 않아야 한다.',
      (WidgetTester tester) async {
        // given
        List<PlutoColumn> columns = [
          ...ColumnHelper.textColumn('body', count: 10, width: 150),
        ];

        List<PlutoRow> rows = RowHelper.count(10, columns);

        PlutoGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: null,
        );

        final listener = MockMethods();

        stateManager.addListener(listener.noParamReturnVoid);

        expect(stateManager.currentCellPosition, isNull);

        stateManager.setCurrentCellPosition(
          const PlutoGridCellPosition(columnIdx: 0, rowIdx: 1),
        );

        expect(stateManager.currentCellPosition!.columnIdx, 0);
        expect(stateManager.currentCellPosition!.rowIdx, 1);

        // when
        stateManager.setCurrentCellPosition(
          const PlutoGridCellPosition(columnIdx: -1, rowIdx: 1),
        );

        stateManager.setCurrentCellPosition(
          PlutoGridCellPosition(columnIdx: columns.length, rowIdx: 1),
        );

        stateManager.setCurrentCellPosition(
          const PlutoGridCellPosition(columnIdx: 1, rowIdx: -1),
        );

        stateManager.setCurrentCellPosition(
          PlutoGridCellPosition(columnIdx: 1, rowIdx: rows.length),
        );

        // then
        verify(listener.noParamReturnVoid()).called(1);
      },
    );
  });

  group('cellPositionByCellKey', () {
    testWidgets('should be returned null', (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn('body', count: 10, width: 150),
      ];

      List<PlutoRow> rows = RowHelper.count(10, columns);

      PlutoGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
      );

      // when
      // then
      expect(stateManager.cellPositionByCellKey(null), isNull);
    });

    testWidgets('should be returned null', (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn('body', count: 10, width: 150),
      ];

      List<PlutoRow> rows = RowHelper.count(10, columns);

      PlutoGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
      );

      stateManager
          .setLayout(const BoxConstraints(maxHeight: 300, maxWidth: 50));

      // when
      final Key nonExistsKey = UniqueKey();

      // then
      expect(stateManager.cellPositionByCellKey(nonExistsKey), isNull);
    });

    testWidgets('should be returned cellPosition columnIdx: 0, rowIdx 0',
        (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn('body', count: 10, width: 150),
      ];

      List<PlutoRow> rows = RowHelper.count(10, columns);

      PlutoGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
      );

      stateManager
          .setLayout(const BoxConstraints(maxHeight: 300, maxWidth: 50));

      // when
      final Key cellKey = rows.first.cells['body0']!.key;

      final cellPosition = stateManager.cellPositionByCellKey(cellKey)!;

      // then
      expect(cellPosition.columnIdx, 0);
      expect(cellPosition.rowIdx, 0);
    });

    testWidgets('should be returned cellPosition columnIdx: 3, rowIdx 7',
        (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn('body', count: 10, width: 150),
      ];

      List<PlutoRow> rows = RowHelper.count(10, columns);

      PlutoGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
      );

      stateManager
          .setLayout(const BoxConstraints(maxHeight: 300, maxWidth: 50));

      // when
      final Key cellKey = rows[7].cells['body3']!.key;

      final cellPosition = stateManager.cellPositionByCellKey(cellKey)!;

      // then
      expect(cellPosition.columnIdx, 3);
      expect(cellPosition.rowIdx, 7);
    });
  });

  group('canChangeCellValue', () {
    createColumn({
      bool readonly = false,
      bool enableEditingMode = true,
    }) {
      return PlutoColumn(
        title: 'title',
        field: 'field',
        readOnly: readonly,
        type: PlutoColumnType.text(),
        enableEditingMode: enableEditingMode,
      );
    }

    test(
      'readonly column.'
      'should be returned false.',
      () {
        final normalGridAndReadonlyColumn = createStateManager(
          columns: [],
          rows: [],
          gridFocusNode: null,
          scroll: null,
        );

        final cell = PlutoCell(value: '');
        final column = createColumn(readonly: true);
        final row = PlutoRow(cells: {'field': cell});
        cell
          ..setColumn(column)
          ..setRow(row);

        final bool result = normalGridAndReadonlyColumn.canChangeCellValue(
          cell: cell,
          newValue: 'abc',
          oldValue: 'ABC',
        );

        expect(result, isFalse);
      },
    );

    test(
      'enableEditingMode = false, '
      'should be returned false.',
      () {
        final normalGridAndReadonlyColumn = createStateManager(
          columns: [],
          rows: [],
          gridFocusNode: null,
          scroll: null,
        );

        final cell = PlutoCell(value: '');
        final column = createColumn(enableEditingMode: false);
        final row = PlutoRow(cells: {'field': cell});
        cell
          ..setColumn(column)
          ..setRow(row);

        final bool result = normalGridAndReadonlyColumn.canChangeCellValue(
          cell: cell,
          newValue: 'abc',
          oldValue: 'ABC',
        );

        expect(result, isFalse);
      },
    );

    test(
      'not readonly column.'
      'grid mode is normal.'
      'should be returned true.',
      () {
        final normalGridAndReadonlyColumn = createStateManager(
          columns: [],
          rows: [],
          gridFocusNode: null,
          scroll: null,
        );

        final cell = PlutoCell(value: '');
        final column = createColumn(readonly: false);
        final row = PlutoRow(cells: {'field': cell});
        cell
          ..setColumn(column)
          ..setRow(row);

        final bool result = normalGridAndReadonlyColumn.canChangeCellValue(
          cell: cell,
          newValue: 'abc',
          oldValue: 'ABC',
        );

        expect(result, isTrue);
      },
    );

    test(
      'not readonly column.'
      'grid mode is select.'
      'should be returned false.',
      () {
        final normalGridAndReadonlyColumn = createStateManager(
          columns: [],
          rows: [],
          gridFocusNode: null,
          scroll: null,
          mode: PlutoGridMode.select,
        );

        final cell = PlutoCell(value: '');
        final column = createColumn(readonly: false);
        final row = PlutoRow(cells: {'field': cell});
        cell
          ..setColumn(column)
          ..setRow(row);

        final bool result = normalGridAndReadonlyColumn.canChangeCellValue(
          cell: cell,
          newValue: 'abc',
          oldValue: 'ABC',
        );

        expect(result, isFalse);
      },
    );

    test(
      'not readonly column.'
      'grid mode is normal.'
      'but same values.'
      'should be returned false.',
      () {
        final normalGridAndReadonlyColumn = createStateManager(
          columns: [],
          rows: [],
          gridFocusNode: null,
          scroll: null,
        );

        final cell = PlutoCell(value: '');
        final column = createColumn(readonly: false);
        final row = PlutoRow(cells: {'field': cell});
        cell
          ..setColumn(column)
          ..setRow(row);

        final bool result = normalGridAndReadonlyColumn.canChangeCellValue(
          cell: cell,
          newValue: 'abc',
          oldValue: 'abc',
        );

        expect(result, isFalse);
      },
    );
  });

  group('filteredCellValue', () {
    testWidgets(
        'select column'
        'WHEN newValue is not contained in select items'
        'THEN the return value should be oldValue.',
        (WidgetTester tester) async {
      // given
      const String newValue = 'four';

      const String oldValue = 'one';

      PlutoColumn column = PlutoColumn(
        title: 'column',
        field: 'column',
        type: PlutoColumnType.select(<String>['one', 'two', 'three']),
      );

      PlutoGridStateManager stateManager = createStateManager(
        columns: [column],
        rows: [],
        gridFocusNode: null,
        scroll: null,
      );

      // when
      final String filteredValue = stateManager
          .filteredCellValue(
            column: column,
            newValue: newValue,
            oldValue: oldValue,
          )
          .toString();

      // then
      expect(filteredValue, oldValue);
    });

    testWidgets(
        'select column'
        'WHEN newValue is contained in select items'
        'THEN the return value should be newValue.',
        (WidgetTester tester) async {
      // given
      const String newValue = 'four';

      const String oldValue = 'one';

      PlutoColumn column = PlutoColumn(
        title: 'column',
        field: 'column',
        type: PlutoColumnType.select(<String>['one', 'two', 'three', 'four']),
      );

      PlutoGridStateManager stateManager = createStateManager(
        columns: [column],
        rows: [],
        gridFocusNode: null,
        scroll: null,
      );

      // when
      final String filteredValue = stateManager
          .filteredCellValue(
            column: column,
            newValue: newValue,
            oldValue: oldValue,
          )
          .toString();

      // then
      expect(filteredValue, newValue);
    });

    testWidgets(
        'date column'
        'WHEN newValue is not parsed to DateTime'
        'THEN the return value should be oldValue.',
        (WidgetTester tester) async {
      // given
      const String newValue = 'not date';

      const String oldValue = '2020-01-01';

      PlutoColumn column = PlutoColumn(
        title: 'column',
        field: 'column',
        type: PlutoColumnType.date(),
      );

      PlutoGridStateManager stateManager = createStateManager(
        columns: [column],
        rows: [],
        gridFocusNode: null,
        scroll: null,
      );

      // when
      final String filteredValue = stateManager
          .filteredCellValue(
            column: column,
            newValue: newValue,
            oldValue: oldValue,
          )
          .toString();

      // then
      expect(filteredValue, oldValue);
    });

    testWidgets(
        'date column'
        'WHEN newValue is parsed to DateTime'
        'THEN the return value should be newValue.',
        (WidgetTester tester) async {
      // given
      const String newValue = '2020-12-12';

      const String oldValue = '2020-01-01';

      PlutoColumn column = PlutoColumn(
        title: 'column',
        field: 'column',
        type: PlutoColumnType.date(),
      );

      PlutoGridStateManager stateManager = createStateManager(
        columns: [column],
        rows: [],
        gridFocusNode: null,
        scroll: null,
      );

      // when
      final String filteredValue = stateManager
          .filteredCellValue(
            column: column,
            newValue: newValue,
            oldValue: oldValue,
          )
          .toString();

      // then
      expect(filteredValue, newValue);
    });

    testWidgets(
        'time column'
        'WHEN newValue is not in 00:00 format'
        'THEN the return value should be oldValue.',
        (WidgetTester tester) async {
      // given
      const String newValue = 'not 00:00';

      const String oldValue = '23:59';

      PlutoColumn column = PlutoColumn(
        title: 'column',
        field: 'column',
        type: PlutoColumnType.time(),
      );

      PlutoGridStateManager stateManager = createStateManager(
        columns: [column],
        rows: [],
        gridFocusNode: null,
        scroll: null,
      );

      // when
      final String filteredValue = stateManager
          .filteredCellValue(
            column: column,
            newValue: newValue,
            oldValue: oldValue,
          )
          .toString();

      // then
      expect(filteredValue, oldValue);
    });

    testWidgets(
        'time column'
        'WHEN newValue is in the 00:00 format'
        'THEN the return value should be newValue.',
        (WidgetTester tester) async {
      // given
      const String newValue = '12:59';

      const String oldValue = '23:59';

      PlutoColumn column = PlutoColumn(
        title: 'column',
        field: 'column',
        type: PlutoColumnType.time(),
      );

      PlutoGridStateManager stateManager = createStateManager(
        columns: [column],
        rows: [],
        gridFocusNode: null,
        scroll: null,
      );

      // when
      final String filteredValue = stateManager
          .filteredCellValue(
            column: column,
            newValue: newValue,
            oldValue: oldValue,
          )
          .toString();

      // then
      expect(filteredValue, newValue);
    });
  });
}
