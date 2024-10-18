import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../helper/column_helper.dart';
import '../../helper/pluto_widget_test_helper.dart';
import '../../helper/row_helper.dart';

void main() {
  group('Enter 키 테스트', () {
    List<PlutoColumn> columns;

    List<PlutoRow> rows;

    PlutoGridStateManager? stateManager;

    final withTheCellSelected = PlutoWidgetTestHelper(
      '3, 3 셀이 선택 된 상태에서',
      (tester) async {
        columns = [
          ...ColumnHelper.textColumn('header', count: 10),
        ];

        rows = RowHelper.count(10, columns);

        await tester.pumpWidget(
          MaterialApp(
            home: Material(
              child: PlutoGrid(
                columns: columns,
                rows: rows,
                onLoaded: (PlutoGridOnLoadedEvent event) {
                  stateManager = event.stateManager;
                },
              ),
            ),
          ),
        );

        await tester.pump();

        await tester.tap(find.text('header3 value 3'));
      },
    );

    withTheCellSelected.test(
      'editing 상태에서 shift + enter 입력 시 위 셀로 이동 되어야 한다.',
      (tester) async {
        stateManager!.setEditing(true);
        expect(stateManager!.currentCell!.value, 'header3 value 3');
        expect(stateManager!.currentCellPosition!.columnIdx, 3);
        expect(stateManager!.currentCellPosition!.rowIdx, 3);

        await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);

        expect(stateManager!.currentCell!.value, 'header3 value 2');
        expect(stateManager!.currentCellPosition!.columnIdx, 3);
        expect(stateManager!.currentCellPosition!.rowIdx, 2);
      },
    );

    withTheCellSelected.test(
      'editing 상태에서 enter 입력 시 아래 셀로 이동 되어야 한다.',
      (tester) async {
        stateManager!.setEditing(true);
        expect(stateManager!.currentCell!.value, 'header3 value 3');
        expect(stateManager!.currentCellPosition!.columnIdx, 3);
        expect(stateManager!.currentCellPosition!.rowIdx, 3);

        await tester.sendKeyEvent(LogicalKeyboardKey.enter);

        expect(stateManager!.currentCell!.value, 'header3 value 4');
        expect(stateManager!.currentCellPosition!.columnIdx, 3);
        expect(stateManager!.currentCellPosition!.rowIdx, 4);
      },
    );
  });
}
