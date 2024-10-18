import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../helper/column_helper.dart';
import '../../helper/pluto_widget_test_helper.dart';
import '../../helper/row_helper.dart';
import '../../helper/test_helper_util.dart';

void main() {
  group('고정 컬럼이 없는 상태에서', () {
    List<PlutoColumn> columns;

    List<PlutoRow> rows;

    PlutoGridStateManager? stateManager;

    final toLeftColumn1 = PlutoWidgetTestHelper(
      '1번 컬럼의 셀 하나를 선택하고 1번 컬럼을 왼쪽 고정',
      (tester) async {
        await TestHelperUtil.changeWidth(
          tester: tester,
          width: 1920,
          height: 1080,
        );

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

        await tester.tap(find.text('header1 value 3'));

        stateManager!.toggleFrozenColumn(columns[1], PlutoColumnFrozen.start);
      },
    );

    toLeftColumn1.test(
      'currentCellPosition 이 null 이어야 한다.',
      (tester) async {
        expect(stateManager!.currentCellPosition, null);
      },
    );

    toLeftColumn1.test(
      '키보드로 셀 이동시 currentCellPosition 이 업데이트 되어야 한다.',
      (tester) async {
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
        await tester.pumpAndSettle();
        // toggleFrozenColumn 호출 후에는 currentCellPosition 이 null
        // 현재 셀이 없는 상태에서 방향키 이동시 처음 셀이 선택 된다.
        expect(stateManager!.currentCellPosition!.columnIdx, 0);
        expect(stateManager!.currentCellPosition!.rowIdx, 0);

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pumpAndSettle();
        // 우측 이동으로 columnIdx 가 1 증가
        expect(stateManager!.currentCellPosition!.columnIdx, 1);
        expect(stateManager!.currentCellPosition!.rowIdx, 0);

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();
        // 하단 이동시 rowIdx 가 1 증가
        expect(stateManager!.currentCellPosition!.columnIdx, 1);
        expect(stateManager!.currentCellPosition!.rowIdx, 1);

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
        await tester.pumpAndSettle();
        // 상단 이동시 rowIdx 가 1 감소
        expect(stateManager!.currentCellPosition!.columnIdx, 1);
        expect(stateManager!.currentCellPosition!.rowIdx, 0);

        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();
        // 탭키 이동시 columnIdx 가 1 증가
        expect(stateManager!.currentCellPosition!.columnIdx, 2);
        expect(stateManager!.currentCellPosition!.rowIdx, 0);

        await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
        await tester.pumpAndSettle();
        // 쉬프트 + 탭키 이동시 columnIdx 가 1 감소
        expect(stateManager!.currentCellPosition!.columnIdx, 1);
        expect(stateManager!.currentCellPosition!.rowIdx, 0);
      },
    );
  });

  group('고정 컬럼이 없는 상태에서', () {
    List<PlutoColumn> columns;

    List<PlutoRow> rows;

    PlutoGridStateManager? stateManager;

    final toLeftColumn1 = PlutoWidgetTestHelper(
      '3번 컬럼의 셀 하나를 선택하고 3번 컬럼을 오른쪽 고정',
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

        await tester.tap(find.text('header3 value 5'));

        stateManager!.toggleFrozenColumn(columns[3], PlutoColumnFrozen.end);
      },
    );

    toLeftColumn1.test(
      'currentCellPosition 가 null 이 되어야 한다.',
      (tester) async {
        expect(stateManager!.currentCellPosition, null);
      },
    );

    toLeftColumn1.test(
      '현재 셀이 없는 상태에서 좌측 키 이동 시 처음 셀이 선택 되어야 한다.',
      (tester) async {
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);

        expect(stateManager!.currentCellPosition!.columnIdx, 0);
        expect(stateManager!.currentCellPosition!.rowIdx, 0);

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
        // 좌측 이동시 처음 셀에서 이동 할 수 없으므로 값이 유지
        expect(stateManager!.currentCellPosition!.columnIdx, 0);
        expect(stateManager!.currentCellPosition!.rowIdx, 0);

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        // 상단 이동시 처음 셀에서 이동 할 수 없으므로 값이 유지
        expect(stateManager!.currentCellPosition!.columnIdx, 0);
        expect(stateManager!.currentCellPosition!.rowIdx, 0);
      },
    );
  });
}
