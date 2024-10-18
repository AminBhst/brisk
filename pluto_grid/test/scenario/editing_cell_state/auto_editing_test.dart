import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../helper/column_helper.dart';
import '../../helper/pluto_widget_test_helper.dart';
import '../../helper/row_helper.dart';

void main() {
  group('autoEditing 이 true 인 상태에서', () {
    List<PlutoColumn> columns;

    List<PlutoRow> rows;

    PlutoGridStateManager? stateManager;

    final plutoGrid = PlutoWidgetTestHelper(
      '5개의 컬럼과 10개의 행을 생성',
      (tester) async {
        columns = [
          ...ColumnHelper.textColumn('header', count: 5),
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
                  stateManager!.setAutoEditing(true);
                },
              ),
            ),
          ),
        );
      },
    );

    plutoGrid.test(
      '첫번째 셀을 탭하면 editing 상태가 true 가 되어야 한다.',
      (tester) async {
        expect(stateManager!.isEditing, false);

        await tester.tap(find.text('header0 value 0'));

        expect(stateManager!.currentCell!.value, 'header0 value 0');

        expect(stateManager!.isEditing, true);
      },
    );

    plutoGrid.test(
      '첫번째 셀을 탭하고 탭키를 입력하면 두번째 셀이 editing 상태가 되어야 한다.',
      (tester) async {
        expect(stateManager!.isEditing, false);

        await tester.tap(find.text('header0 value 0'));

        await tester.sendKeyEvent(LogicalKeyboardKey.tab);

        expect(stateManager!.currentCell!.value, 'header1 value 0');

        expect(stateManager!.isEditing, true);
      },
    );

    plutoGrid.test(
      '첫번째 셀을 탭하고 엔터키를 입력하면 두번째 행의 첫번째 셀이 editing 상태가 되어야 한다.',
      (tester) async {
        expect(stateManager!.isEditing, false);

        await tester.tap(find.text('header0 value 0'));

        await tester.sendKeyEvent(LogicalKeyboardKey.enter);

        expect(stateManager!.currentCell!.value, 'header0 value 1');

        expect(stateManager!.isEditing, true);
      },
    );

    plutoGrid.test(
      '첫번째 셀을 탭하고 ESC 키를 입력하면 editing 상태가 true 에서 false 변경 되야야 한다.',
      (tester) async {
        expect(stateManager!.isEditing, false);

        await tester.tap(find.text('header0 value 0'));

        expect(stateManager!.isEditing, true);

        await tester.sendKeyEvent(LogicalKeyboardKey.escape);

        expect(stateManager!.currentCell!.value, 'header0 value 0');

        expect(stateManager!.isEditing, false);
      },
    );

    plutoGrid.test(
      '첫번째 셀을 탭하고 ESC 키를 입력 후 end 키를 입력하면 마지막 셀이 editing 상태가 되어야 한다.',
      (tester) async {
        await tester.tap(find.text('header0 value 0'));

        await tester.sendKeyEvent(LogicalKeyboardKey.escape);

        await tester.sendKeyEvent(LogicalKeyboardKey.end);

        expect(stateManager!.currentCell!.value, 'header4 value 0');

        expect(stateManager!.isEditing, true);
      },
    );

    plutoGrid.test(
      '첫번째 셀을 탭하고 ESC 키를 입력 후 아래 방향키를 입력하면 두번째 셀이 editing 상태가 되어야 한다.',
      (tester) async {
        await tester.tap(find.text('header0 value 0'));

        await tester.sendKeyEvent(LogicalKeyboardKey.escape);

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);

        expect(stateManager!.currentCell!.value, 'header0 value 1');

        expect(stateManager!.isEditing, true);
      },
    );

    plutoGrid.test(
      '첫번째 셀을 탭하고 ESC 키를 입력 후 우측 방향키를 입력하면 두번째 셀이 editing 상태가 되어야 한다.',
      (tester) async {
        await tester.tap(find.text('header0 value 0'));

        await tester.sendKeyEvent(LogicalKeyboardKey.escape);

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);

        expect(stateManager!.currentCell!.value, 'header1 value 0');

        expect(stateManager!.isEditing, true);
      },
    );
  });
}
