import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';

void main() {
  group('sum', () {
    test('숫자 컬럼이 아닌경우 0이 리턴 되어야 한다.', () {
      final column = PlutoColumn(
        title: 'column',
        field: 'column',
        type: PlutoColumnType.text(),
      );

      final rows = [
        PlutoRow(cells: {'column': PlutoCell(value: '10.001')}),
        PlutoRow(cells: {'column': PlutoCell(value: '10.001')}),
        PlutoRow(cells: {'column': PlutoCell(value: '10.001')}),
        PlutoRow(cells: {'column': PlutoCell(value: '10.001')}),
        PlutoRow(cells: {'column': PlutoCell(value: '10.001')}),
      ];

      expect(PlutoAggregateHelper.sum(rows: rows, column: column), 0);
    });

    test('[양수] condition 이 없이 sum 을 호출 한 경우 전체 합계 값이 리턴 되어야 한다.', () {
      final column = PlutoColumn(
        title: 'column',
        field: 'column',
        type: PlutoColumnType.number(),
      );

      final rows = [
        PlutoRow(cells: {'column': PlutoCell(value: 10)}),
        PlutoRow(cells: {'column': PlutoCell(value: 20)}),
        PlutoRow(cells: {'column': PlutoCell(value: 30)}),
        PlutoRow(cells: {'column': PlutoCell(value: 40)}),
        PlutoRow(cells: {'column': PlutoCell(value: 50)}),
      ];

      expect(PlutoAggregateHelper.sum(rows: rows, column: column), 150);
    });

    test('[음수] condition 이 없이 sum 을 호출 한 경우 전체 합계 값이 리턴 되어야 한다.', () {
      final column = PlutoColumn(
        title: 'column',
        field: 'column',
        type: PlutoColumnType.number(),
      );

      final rows = [
        PlutoRow(cells: {'column': PlutoCell(value: -10)}),
        PlutoRow(cells: {'column': PlutoCell(value: -20)}),
        PlutoRow(cells: {'column': PlutoCell(value: -30)}),
        PlutoRow(cells: {'column': PlutoCell(value: -40)}),
        PlutoRow(cells: {'column': PlutoCell(value: -50)}),
      ];

      expect(PlutoAggregateHelper.sum(rows: rows, column: column), -150);
    });

    test('[소수] condition 이 없이 sum 을 호출 한 경우 전체 합계 값이 리턴 되어야 한다.', () {
      final column = PlutoColumn(
        title: 'column',
        field: 'column',
        type: PlutoColumnType.number(format: '#,###.###'),
      );

      final rows = [
        PlutoRow(cells: {'column': PlutoCell(value: 10.001)}),
        PlutoRow(cells: {'column': PlutoCell(value: 10.001)}),
        PlutoRow(cells: {'column': PlutoCell(value: 10.001)}),
        PlutoRow(cells: {'column': PlutoCell(value: 10.001)}),
        PlutoRow(cells: {'column': PlutoCell(value: 10.001)}),
      ];

      expect(PlutoAggregateHelper.sum(rows: rows, column: column), 50.005);
    });

    test('condition 이 있는 경우 조건에 맞는 아이템의 합계 값이 리턴 되어야 한다.', () {
      final column = PlutoColumn(
        title: 'column',
        field: 'column',
        type: PlutoColumnType.number(format: '#,###.###'),
      );

      final rows = [
        PlutoRow(cells: {'column': PlutoCell(value: 10.001)}),
        PlutoRow(cells: {'column': PlutoCell(value: 10.002)}),
        PlutoRow(cells: {'column': PlutoCell(value: 10.001)}),
        PlutoRow(cells: {'column': PlutoCell(value: 10.002)}),
        PlutoRow(cells: {'column': PlutoCell(value: 10.001)}),
      ];

      expect(
        PlutoAggregateHelper.sum(
          rows: rows,
          column: column,
          filter: (PlutoCell cell) => cell.value == 10.001,
        ),
        30.003,
      );
    });

    test('condition 이 있는 경우 조건에 맞는 아이템이 없다면 0이 리턴 되어야 한다.', () {
      final column = PlutoColumn(
        title: 'column',
        field: 'column',
        type: PlutoColumnType.number(format: '#,###.###'),
      );

      final rows = [
        PlutoRow(cells: {'column': PlutoCell(value: 10.001)}),
        PlutoRow(cells: {'column': PlutoCell(value: 10.002)}),
        PlutoRow(cells: {'column': PlutoCell(value: 10.001)}),
        PlutoRow(cells: {'column': PlutoCell(value: 10.002)}),
        PlutoRow(cells: {'column': PlutoCell(value: 10.001)}),
      ];

      expect(
        PlutoAggregateHelper.sum(
          rows: rows,
          column: column,
          filter: (PlutoCell cell) => cell.value == 10.003,
        ),
        0,
      );
    });
  });

  group('average', () {
    test('[양수] condition 이 없이 average 을 호출 한 경우 전체 합계 값이 리턴 되어야 한다.', () {
      final column = PlutoColumn(
        title: 'column',
        field: 'column',
        type: PlutoColumnType.number(format: '#,###'),
      );

      final rows = [
        PlutoRow(cells: {'column': PlutoCell(value: 10)}),
        PlutoRow(cells: {'column': PlutoCell(value: 20)}),
        PlutoRow(cells: {'column': PlutoCell(value: 30)}),
        PlutoRow(cells: {'column': PlutoCell(value: 40)}),
        PlutoRow(cells: {'column': PlutoCell(value: 50)}),
      ];

      expect(PlutoAggregateHelper.average(rows: rows, column: column), 30);
    });

    test('[음수] condition 이 없이 average 을 호출 한 경우 전체 합계 값이 리턴 되어야 한다.', () {
      final column = PlutoColumn(
        title: 'column',
        field: 'column',
        type: PlutoColumnType.number(format: '#,###'),
      );

      final rows = [
        PlutoRow(cells: {'column': PlutoCell(value: -10)}),
        PlutoRow(cells: {'column': PlutoCell(value: -20)}),
        PlutoRow(cells: {'column': PlutoCell(value: -30)}),
        PlutoRow(cells: {'column': PlutoCell(value: -40)}),
        PlutoRow(cells: {'column': PlutoCell(value: -50)}),
      ];

      expect(PlutoAggregateHelper.average(rows: rows, column: column), -30);
    });

    test('[소수] condition 이 없이 average 을 호출 한 경우 전체 합계 값이 리턴 되어야 한다.', () {
      final column = PlutoColumn(
        title: 'column',
        field: 'column',
        type: PlutoColumnType.number(format: '#,###.###'),
      );

      final rows = [
        PlutoRow(cells: {'column': PlutoCell(value: 10.001)}),
        PlutoRow(cells: {'column': PlutoCell(value: 10.002)}),
        PlutoRow(cells: {'column': PlutoCell(value: 10.003)}),
        PlutoRow(cells: {'column': PlutoCell(value: 10.004)}),
        PlutoRow(cells: {'column': PlutoCell(value: 10.005)}),
      ];

      expect(PlutoAggregateHelper.average(rows: rows, column: column), 10.003);
    });
  });

  group('min', () {
    test('[양수] condition 이 없이 min 을 호출 한 경우 최소 값이 리턴 되어야 한다.', () {
      final column = PlutoColumn(
        title: 'column',
        field: 'column',
        type: PlutoColumnType.number(format: '#,###'),
      );

      final rows = [
        PlutoRow(cells: {'column': PlutoCell(value: 101)}),
        PlutoRow(cells: {'column': PlutoCell(value: 102)}),
        PlutoRow(cells: {'column': PlutoCell(value: 103)}),
        PlutoRow(cells: {'column': PlutoCell(value: 104)}),
        PlutoRow(cells: {'column': PlutoCell(value: 105)}),
      ];

      expect(PlutoAggregateHelper.min(rows: rows, column: column), 101);
    });

    test('[음수] condition 이 없이 min 을 호출 한 경우 최소 값이 리턴 되어야 한다.', () {
      final column = PlutoColumn(
        title: 'column',
        field: 'column',
        type: PlutoColumnType.number(format: '#,###'),
      );

      final rows = [
        PlutoRow(cells: {'column': PlutoCell(value: -101)}),
        PlutoRow(cells: {'column': PlutoCell(value: -102)}),
        PlutoRow(cells: {'column': PlutoCell(value: -103)}),
        PlutoRow(cells: {'column': PlutoCell(value: -104)}),
        PlutoRow(cells: {'column': PlutoCell(value: -105)}),
      ];

      expect(PlutoAggregateHelper.min(rows: rows, column: column), -105);
    });

    test('[소수] condition 이 없이 min 을 호출 한 경우 최소 값이 리턴 되어야 한다.', () {
      final column = PlutoColumn(
        title: 'column',
        field: 'column',
        type: PlutoColumnType.number(format: '#,###.###'),
      );

      final rows = [
        PlutoRow(cells: {'column': PlutoCell(value: 10.001)}),
        PlutoRow(cells: {'column': PlutoCell(value: 10.002)}),
        PlutoRow(cells: {'column': PlutoCell(value: 10.003)}),
        PlutoRow(cells: {'column': PlutoCell(value: 10.004)}),
        PlutoRow(cells: {'column': PlutoCell(value: 10.005)}),
      ];

      expect(PlutoAggregateHelper.min(rows: rows, column: column), 10.001);
    });

    test('condition 이 있는 경우 조건에 맞는 아이템이 있다면 조건내에서 최소값이 리턴 되어야 한다.', () {
      final column = PlutoColumn(
        title: 'column',
        field: 'column',
        type: PlutoColumnType.number(format: '#,###.###'),
      );

      final rows = [
        PlutoRow(cells: {'column': PlutoCell(value: 10.001)}),
        PlutoRow(cells: {'column': PlutoCell(value: 10.002)}),
        PlutoRow(cells: {'column': PlutoCell(value: 10.003)}),
        PlutoRow(cells: {'column': PlutoCell(value: 10.004)}),
        PlutoRow(cells: {'column': PlutoCell(value: 10.005)}),
      ];

      expect(
        PlutoAggregateHelper.min(
          rows: rows,
          column: column,
          filter: (PlutoCell cell) => cell.value >= 10.003,
        ),
        10.003,
      );
    });

    test('condition 이 있는 경우 조건에 맞는 아이템이 없다면 null 이 리턴 되어야 한다.', () {
      final column = PlutoColumn(
        title: 'column',
        field: 'column',
        type: PlutoColumnType.number(format: '#,###.###'),
      );

      final rows = [
        PlutoRow(cells: {'column': PlutoCell(value: 10.001)}),
        PlutoRow(cells: {'column': PlutoCell(value: 10.002)}),
        PlutoRow(cells: {'column': PlutoCell(value: 10.001)}),
        PlutoRow(cells: {'column': PlutoCell(value: 10.002)}),
        PlutoRow(cells: {'column': PlutoCell(value: 10.001)}),
      ];

      expect(
        PlutoAggregateHelper.min(
          rows: rows,
          column: column,
          filter: (PlutoCell cell) => cell.value == 10.003,
        ),
        null,
      );
    });
  });

  group('max', () {
    test('condition 이 있는 경우 조건에 맞는 아이템이 있다면 조건내에서 최대값이 리턴 되어야 한다.', () {
      final column = PlutoColumn(
        title: 'column',
        field: 'column',
        type: PlutoColumnType.number(format: '#,###.###'),
      );

      final rows = [
        PlutoRow(cells: {'column': PlutoCell(value: 10.001)}),
        PlutoRow(cells: {'column': PlutoCell(value: 10.002)}),
        PlutoRow(cells: {'column': PlutoCell(value: 10.003)}),
        PlutoRow(cells: {'column': PlutoCell(value: 10.004)}),
        PlutoRow(cells: {'column': PlutoCell(value: 10.005)}),
      ];

      expect(
        PlutoAggregateHelper.max(
          rows: rows,
          column: column,
          filter: (PlutoCell cell) => cell.value >= 10.003,
        ),
        10.005,
      );
    });

    test('condition 이 있는 경우 조건에 맞는 아이템이 없다면 null 이 리턴 되어야 한다.', () {
      final column = PlutoColumn(
        title: 'column',
        field: 'column',
        type: PlutoColumnType.number(format: '#,###.###'),
      );

      final rows = [
        PlutoRow(cells: {'column': PlutoCell(value: 10.001)}),
        PlutoRow(cells: {'column': PlutoCell(value: 10.002)}),
        PlutoRow(cells: {'column': PlutoCell(value: 10.003)}),
        PlutoRow(cells: {'column': PlutoCell(value: 10.004)}),
        PlutoRow(cells: {'column': PlutoCell(value: 10.005)}),
      ];

      expect(
        PlutoAggregateHelper.max(
          rows: rows,
          column: column,
          filter: (PlutoCell cell) => cell.value >= 10.006,
        ),
        null,
      );
    });
  });

  group('count', () {
    test('condition 이 없는 경우 전체 리스트 개수가 리턴 되어야 한다.', () {
      final column = PlutoColumn(
        title: 'column',
        field: 'column',
        type: PlutoColumnType.number(format: '#,###.###'),
      );

      final rows = [
        PlutoRow(cells: {'column': PlutoCell(value: 10.001)}),
        PlutoRow(cells: {'column': PlutoCell(value: 10.002)}),
        PlutoRow(cells: {'column': PlutoCell(value: 10.003)}),
        PlutoRow(cells: {'column': PlutoCell(value: 10.004)}),
        PlutoRow(cells: {'column': PlutoCell(value: 10.005)}),
      ];

      expect(PlutoAggregateHelper.count(rows: rows, column: column), 5);
    });

    test('condition 이 있는 경우 조건에 맞는 아이템이 있다면 조건에 맞는 아이템 개수가 리턴 되어야 한다.', () {
      final column = PlutoColumn(
        title: 'column',
        field: 'column',
        type: PlutoColumnType.number(format: '#,###.###'),
      );

      final rows = [
        PlutoRow(cells: {'column': PlutoCell(value: 10.001)}),
        PlutoRow(cells: {'column': PlutoCell(value: 10.002)}),
        PlutoRow(cells: {'column': PlutoCell(value: 10.003)}),
        PlutoRow(cells: {'column': PlutoCell(value: 10.004)}),
        PlutoRow(cells: {'column': PlutoCell(value: 10.005)}),
      ];

      expect(
        PlutoAggregateHelper.count(
          rows: rows,
          column: column,
          filter: (PlutoCell cell) => cell.value >= 10.003,
        ),
        3,
      );
    });

    test('condition 이 있는 경우 조건에 맞는 아이템이 없다면 0 이 리턴 되어야 한다.', () {
      final column = PlutoColumn(
        title: 'column',
        field: 'column',
        type: PlutoColumnType.number(format: '#,###.###'),
      );

      final rows = [
        PlutoRow(cells: {'column': PlutoCell(value: 10.001)}),
        PlutoRow(cells: {'column': PlutoCell(value: 10.002)}),
        PlutoRow(cells: {'column': PlutoCell(value: 10.003)}),
        PlutoRow(cells: {'column': PlutoCell(value: 10.004)}),
        PlutoRow(cells: {'column': PlutoCell(value: 10.005)}),
      ];

      expect(
        PlutoAggregateHelper.count(
          rows: rows,
          column: column,
          filter: (PlutoCell cell) => cell.value >= 10.006,
        ),
        0,
      );
    });
  });
}
