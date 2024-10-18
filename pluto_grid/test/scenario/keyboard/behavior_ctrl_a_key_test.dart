import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../helper/column_helper.dart';
import '../../helper/pluto_widget_test_helper.dart';
import '../../helper/row_helper.dart';

void main() {
  group('Ctrl + A 키 테스트', () {
    List<PlutoColumn> columns;

    List<PlutoRow> rows;

    PlutoGridStateManager? stateManager;

    final withTheCellSelected = PlutoWidgetTestHelper(
      '0, 0 셀이 선택 된 상태에서',
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

        await tester.tap(find.text('header0 value 0'));
      },
    );

    withTheCellSelected.test(
      'editing 상태가 아니면 Ctrl + A 키 입력 시 전체 셀이 선택 되어야 한다.',
      (tester) async {
        expect(stateManager!.selectingMode.isCell, true);
        expect(stateManager!.isEditing, false);

        await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
        await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.control);

        expect(stateManager!.currentCellPosition!.rowIdx, 0);
        expect(stateManager!.currentCellPosition!.columnIdx, 0);

        expect(stateManager!.currentSelectingPosition!.rowIdx, 9);
        expect(stateManager!.currentSelectingPosition!.columnIdx, 9);
      },
    );

    withTheCellSelected.test(
      'editing 상태가 맞다면 Ctrl + A 키 입력 시 셀 선택이 되지 않아야 한다.',
      (tester) async {
        expect(stateManager!.selectingMode.isCell, true);
        stateManager!.setEditing(true);
        expect(stateManager!.isEditing, true);

        await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
        await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.control);

        expect(stateManager!.currentCellPosition!.rowIdx, 0);
        expect(stateManager!.currentCellPosition!.columnIdx, 0);

        expect(stateManager!.currentSelectingPosition, null);
      },
    );
  });
}
