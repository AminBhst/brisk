import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../helper/column_helper.dart';
import '../../helper/pluto_widget_test_helper.dart';
import '../../helper/row_helper.dart';

void main() {
  group('F3 키 테스트', () {
    List<PlutoColumn> columns;

    List<PlutoRow> rows;

    late PlutoGridStateManager stateManager;

    final focusedCell = find.text('header3 value 3');

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
                  stateManager.setShowColumnFilter(true);
                },
              ),
            ),
          ),
        );

        await tester.pump();

        await tester.tap(focusedCell);
      },
    );

    withTheCellSelected.test(
      'F3 키 입력 시 포커스가 header3 컬럼의 필터링 입력 박스로 이동 해야 한다. '
      '컬럼 필터링 박스로 이동 된 이후에 F3 키를 한번 더 입력하면 필터링 팝업이 호출 되어야 한다.',
      (tester) async {
        await tester.sendKeyEvent(LogicalKeyboardKey.f3);

        await tester.pump();

        final currentColumn = stateManager.currentColumn;

        final focusNode = currentColumn!.filterFocusNode;

        expect(currentColumn.title, 'header3');

        expect(focusNode!.hasFocus, true);

        await tester.sendKeyEvent(LogicalKeyboardKey.f3);

        await tester.pump();

        expect(find.byType(PlutoGridFilterPopupHeader), findsOneWidget);
      },
    );

    withTheCellSelected.test(
      'F3 키 입력 하여 포커스를 header3 컬럼의 필터링 입력 박스로 이동 후, '
      '방향키 아래를 입력하면 해당 컬럼의 첫번째 행의 셀로 포커스가 변경 되어야 한다.',
      (tester) async {
        await tester.sendKeyEvent(LogicalKeyboardKey.f3);

        await tester.pump();

        final currentColumn = stateManager.currentColumn;

        final focusNode = currentColumn!.filterFocusNode;

        expect(currentColumn.title, 'header3');

        expect(focusNode!.hasFocus, true);

        expect(stateManager.hasFocus, false);

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);

        await tester.pump();

        expect(focusNode.hasFocus, false);

        expect(stateManager.hasFocus, true);

        expect(stateManager.currentCell?.value, 'header3 value 0');
      },
    );

    withTheCellSelected.test(
      'F3 키 입력 하여 포커스를 header3 컬럼의 필터링 입력 박스로 이동 후, '
      '엔터키를 입력하면 해당 컬럼의 첫번째 행의 셀로 포커스가 변경 되어야 한다.',
      (tester) async {
        await tester.sendKeyEvent(LogicalKeyboardKey.f3);

        await tester.pump();

        final currentColumn = stateManager.currentColumn;

        final focusNode = currentColumn!.filterFocusNode;

        expect(currentColumn.title, 'header3');

        expect(focusNode!.hasFocus, true);

        expect(stateManager.hasFocus, false);

        await tester.sendKeyEvent(LogicalKeyboardKey.enter);

        await tester.pump();

        expect(focusNode.hasFocus, false);

        expect(stateManager.hasFocus, true);

        expect(stateManager.currentCell?.value, 'header3 value 0');
      },
    );

    withTheCellSelected.test(
      'F3 키 입력 하여 포커스를 header3 컬럼의 필터링 입력 박스로 이동 후, '
      'ESC 키를 입력하면 기존 셀로 포커스가 변경 되어야 한다.',
      (tester) async {
        await tester.sendKeyEvent(LogicalKeyboardKey.f3);

        await tester.pump();

        final currentColumn = stateManager.currentColumn;

        final focusNode = currentColumn!.filterFocusNode;

        expect(currentColumn.title, 'header3');

        expect(focusNode!.hasFocus, true);

        expect(stateManager.hasFocus, false);

        await tester.sendKeyEvent(LogicalKeyboardKey.escape);

        await tester.pump();

        expect(focusNode.hasFocus, false);

        expect(stateManager.hasFocus, true);

        expect(stateManager.currentCell?.value, 'header3 value 3');
      },
    );

    withTheCellSelected.test(
      '컬럼 필터 영역이 비 활성화 된 상태에서 F3 키를 입력하면 포커스가 이동 되지 않아야 한다.',
      (tester) async {
        stateManager.setShowColumnFilter(false);

        await tester.pump();

        await tester.sendKeyEvent(LogicalKeyboardKey.f3);

        await tester.pump();

        expect(stateManager.gridFocusNode.hasFocus, true);

        expect(find.byType(PlutoGridFilterPopupHeader), findsNothing);
      },
    );

    withTheCellSelected.test(
      '선택 된 셀이 없는 상태에서 F3 키를 호출하면 포커스가 이동 되지 않아야 한다.',
      (tester) async {
        stateManager.clearCurrentCell();

        await tester.pump();

        await tester.sendKeyEvent(LogicalKeyboardKey.f3);

        await tester.pump();

        expect(stateManager.gridFocusNode.hasFocus, true);

        expect(find.byType(PlutoGridFilterPopupHeader), findsNothing);
      },
    );
  });
}
