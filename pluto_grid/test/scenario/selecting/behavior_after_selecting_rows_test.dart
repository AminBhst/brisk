import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../helper/column_helper.dart';
import '../../helper/pluto_widget_test_helper.dart';
import '../../helper/row_helper.dart';

/// 행 선택(selectingRows) 상태 이후의 동작 테스트
void main() {
  const PlutoGridSelectingMode selectingMode = PlutoGridSelectingMode.row;

  PlutoGridStateManager? stateManager;

  buildRowsWithSelectingRows({
    int numberOfRows = 10,
    int from = 0,
    int to = 0,
  }) {
    // given
    final columns = ColumnHelper.textColumn('header');
    final rows = RowHelper.count(numberOfRows, columns);

    return PlutoWidgetTestHelper(
      'build with selecting rows.',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Material(
              child: PlutoGrid(
                columns: columns,
                rows: rows,
                onLoaded: (PlutoGridOnLoadedEvent event) {
                  stateManager = event.stateManager;
                  stateManager!.setSelectingMode(selectingMode);
                  stateManager!.setCurrentSelectingRowsByRange(from, to);
                },
              ),
            ),
          ),
        );

        final selectingRows = stateManager!.currentSelectingRows;

        final int length = (from - to).abs() + 1;

        expect(selectingRows.length, length);
      },
    );
  }

  group(
    '10개 행에서 3개 행 선택. (1 ~ 3)',
    () {
      const countTotalRows = 10;
      const countSelectedRows = 3;
      const from = 1;
      const to = 3;

      selectRowsFrom1To3() {
        return buildRowsWithSelectingRows(
          numberOfRows: countTotalRows,
          from: from,
          to: to,
        );
      }

      selectRowsFrom1To3().test(
        '0번 행을 삭제하면, '
        '0 ~ 2 번 index 의 행이 선택 상태가 되어야 한다.',
        (tester) async {
          final rowToRemove = stateManager!.rows.first;

          stateManager!.removeRows([rowToRemove]);

          final selectedRows = stateManager!.currentSelectingRows;
          final selectedRowKeys = selectedRows.map((e) => e.key);

          expect(selectedRows.length, countSelectedRows);
          expect(selectedRowKeys.contains(stateManager!.rows[0].key), isTrue);
          expect(selectedRowKeys.contains(stateManager!.rows[1].key), isTrue);
          expect(selectedRowKeys.contains(stateManager!.rows[2].key), isTrue);
        },
      );

      selectRowsFrom1To3().test(
        '선택 된 1 ~3번 행 앞쪽인 1번에 새로운 행을 추가하면, '
        '2 ~ 4번 행이 선택 상태가 되어야 한다.',
        (tester) async {
          final rowToRemove = stateManager!.rows.first;

          stateManager!.insertRows(1, [rowToRemove]);

          expect(stateManager!.rows.length, countTotalRows + 1);

          final selectedRows = stateManager!.currentSelectingRows;
          final selectedRowKeys = selectedRows.map((e) => e.key);

          expect(selectedRows.length, countSelectedRows);
          expect(selectedRowKeys.contains(stateManager!.rows[2].key), isTrue);
          expect(selectedRowKeys.contains(stateManager!.rows[3].key), isTrue);
          expect(selectedRowKeys.contains(stateManager!.rows[4].key), isTrue);
        },
      );
    },
  );
}
