import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../helper/column_helper.dart';
import '../../helper/pluto_widget_test_helper.dart';
import '../../helper/row_helper.dart';
import '../../helper/test_helper_util.dart';

void main() {
  group('PlutoGridTabKeyAction.moveToNextOnEdge - Tab 키 테스트', () {
    late List<PlutoColumn> columns;

    late List<PlutoRow> rows;

    late PlutoGridStateManager stateManager;

    PlutoWidgetTestHelper buildGrid({String? tapValue}) {
      return PlutoWidgetTestHelper(
        '5 컬럼 5 행.',
        (tester) async {
          await TestHelperUtil.changeWidth(
            tester: tester,
            width: 1200,
            height: 600,
          );

          columns = ColumnHelper.textColumn('column', count: 5);

          rows = RowHelper.count(5, columns);

          await tester.pumpWidget(
            MaterialApp(
              home: Material(
                child: PlutoGrid(
                  columns: columns,
                  rows: rows,
                  onLoaded: (PlutoGridOnLoadedEvent event) {
                    stateManager = event.stateManager;
                  },
                  configuration: const PlutoGridConfiguration(
                    tabKeyAction: PlutoGridTabKeyAction.moveToNextOnEdge,
                  ),
                ),
              ),
            ),
          );

          if (tapValue != null) {
            await tester.tap(find.text(tapValue));
          }
        },
      );
    }

    buildGrid(tapValue: 'column4 value 0').test(
      '0번 행의 마지막 셀에서 Tab 키를 입력하면 1번 행의 첫번째 셀로 이동 되어야 한다.',
      (tester) async {
        expect(stateManager.currentCellPosition!.rowIdx, 0);
        expect(stateManager.currentCellPosition!.columnIdx, 4);

        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();

        expect(stateManager.currentCellPosition!.rowIdx, 1);
        expect(stateManager.currentCellPosition!.columnIdx, 0);
      },
    );

    buildGrid(tapValue: 'column4 value 1').test(
      '1번 행의 마지막 이전의 셀에서 Tab 키를 두번 입력하면 2번 행의 첫번째 셀로 이동 되어야 한다.',
      (tester) async {
        expect(stateManager.currentCellPosition!.rowIdx, 1);
        expect(stateManager.currentCellPosition!.columnIdx, 4);

        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();

        expect(stateManager.currentCellPosition!.rowIdx, 2);
        expect(stateManager.currentCellPosition!.columnIdx, 0);
      },
    );

    buildGrid(tapValue: 'column4 value 4').test(
      '마지막 행의 마지막 셀에서 Tab 키를 입력하면 위치가 변경 되지 않아야 한다.',
      (tester) async {
        expect(stateManager.currentCellPosition!.rowIdx, 4);
        expect(stateManager.currentCellPosition!.columnIdx, 4);

        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();

        expect(stateManager.currentCellPosition!.rowIdx, 4);
        expect(stateManager.currentCellPosition!.columnIdx, 4);
      },
    );
  });

  group('PlutoGridTabKeyAction.moveToNextOnEdge - Shift + Tab 키 테스트', () {
    late List<PlutoColumn> columns;

    late List<PlutoRow> rows;

    late PlutoGridStateManager stateManager;

    PlutoWidgetTestHelper buildGrid({String? tapValue}) {
      return PlutoWidgetTestHelper(
        '5 컬럼 5 행.',
        (tester) async {
          await TestHelperUtil.changeWidth(
            tester: tester,
            width: 1200,
            height: 600,
          );

          columns = ColumnHelper.textColumn('column', count: 5);

          rows = RowHelper.count(5, columns);

          await tester.pumpWidget(
            MaterialApp(
              home: Material(
                child: PlutoGrid(
                  columns: columns,
                  rows: rows,
                  onLoaded: (PlutoGridOnLoadedEvent event) {
                    stateManager = event.stateManager;
                  },
                  configuration: const PlutoGridConfiguration(
                    tabKeyAction: PlutoGridTabKeyAction.moveToNextOnEdge,
                  ),
                ),
              ),
            ),
          );

          if (tapValue != null) {
            await tester.tap(find.text(tapValue));
          }
        },
      );
    }

    buildGrid(tapValue: 'column0 value 1').test(
      '1번 행의 첫 셀에서 Shift + Tab 키를 입력하면 0번 행의 마지막 셀로 이동 되어야 한다.',
      (tester) async {
        expect(stateManager.currentCellPosition!.rowIdx, 1);
        expect(stateManager.currentCellPosition!.columnIdx, 0);

        await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
        await tester.pumpAndSettle();

        expect(stateManager.currentCellPosition!.rowIdx, 0);
        expect(stateManager.currentCellPosition!.columnIdx, 4);
      },
    );

    buildGrid(tapValue: 'column0 value 2').test(
      '2번 행의 첫 셀에서 Shift + Tab 키를 두번 입력하면 1번 행의 마지막 셀로 이동 되어야 한다.',
      (tester) async {
        expect(stateManager.currentCellPosition!.rowIdx, 2);
        expect(stateManager.currentCellPosition!.columnIdx, 0);

        await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
        await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
        await tester.pumpAndSettle();

        expect(stateManager.currentCellPosition!.rowIdx, 1);
        expect(stateManager.currentCellPosition!.columnIdx, 4);
      },
    );

    buildGrid(tapValue: 'column0 value 0').test(
      '첫번째 행의 첫번째 셀에서 Shift + Tab 키를 입력하면 위치가 변경 되지 않아야 한다.',
      (tester) async {
        expect(stateManager.currentCellPosition!.rowIdx, 0);
        expect(stateManager.currentCellPosition!.columnIdx, 0);

        await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
        await tester.pumpAndSettle();

        expect(stateManager.currentCellPosition!.rowIdx, 0);
        expect(stateManager.currentCellPosition!.columnIdx, 0);
      },
    );
  });
}
