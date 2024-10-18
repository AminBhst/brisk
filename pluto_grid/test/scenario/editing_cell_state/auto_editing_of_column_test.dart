import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../helper/pluto_widget_test_helper.dart';
import '../../helper/row_helper.dart';

void main() {
  group('autoEditing 이 false 인 상태에서', () {
    List<PlutoColumn> columns;

    List<PlutoRow> rows;

    PlutoGridStateManager? stateManager;

    final plutoGrid = PlutoWidgetTestHelper(
      '0, 3번 컬럼이 autoEditing 인 5개의 컬럼과 10개의 행을 생성',
      (tester) async {
        columns = [
          PlutoColumn(
            title: 'header0',
            field: 'header0',
            type: PlutoColumnType.text(),
            enableAutoEditing: true,
          ),
          PlutoColumn(
              title: 'header1', field: 'header1', type: PlutoColumnType.text()),
          PlutoColumn(
              title: 'header2', field: 'header2', type: PlutoColumnType.text()),
          PlutoColumn(
            title: 'header3',
            field: 'header3',
            type: PlutoColumnType.text(),
            enableAutoEditing: true,
          ),
          PlutoColumn(
              title: 'header4', field: 'header4', type: PlutoColumnType.text()),
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

        expect(stateManager!.autoEditing, false);
      },
    );

    plutoGrid.test(
      '0번 셀을 탭하면 editing 상태가 true 가 되어야 한다.',
      (tester) async {
        expect(stateManager!.isEditing, false);

        await tester.tap(find.text('header0 value 0'));

        expect(stateManager!.currentCell!.value, 'header0 value 0');

        expect(stateManager!.isEditing, true);
      },
    );

    plutoGrid.test(
      '1번 셀을 탭하면 editing 상태가 false 가 되어야 한다.',
      (tester) async {
        expect(stateManager!.isEditing, false);

        await tester.tap(find.text('header1 value 0'));

        expect(stateManager!.currentCell!.value, 'header1 value 0');

        expect(stateManager!.isEditing, false);
      },
    );

    plutoGrid.test(
      '2번 셀을 탭하면 editing 상태가 false 가 되어야 한다.',
      (tester) async {
        expect(stateManager!.isEditing, false);

        await tester.tap(find.text('header2 value 0'));

        expect(stateManager!.currentCell!.value, 'header2 value 0');

        expect(stateManager!.isEditing, false);
      },
    );

    plutoGrid.test(
      '2번 셀을 탭하고 우측 방향키를 입력하면 3번 쎌이 editing 상태가 true 가 되어야 한다.',
      (tester) async {
        expect(stateManager!.isEditing, false);

        await tester.tap(find.text('header2 value 0'));

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);

        expect(stateManager!.currentCell!.value, 'header3 value 0');

        expect(stateManager!.isEditing, true);
      },
    );

    plutoGrid.test(
      '3번 셀을 탭하면 editing 상태가 true 가 되어야 한다.',
      (tester) async {
        expect(stateManager!.isEditing, false);

        await tester.tap(find.text('header3 value 0'));

        expect(stateManager!.currentCell!.value, 'header3 value 0');

        expect(stateManager!.isEditing, true);
      },
    );

    plutoGrid.test(
      '3번 셀을 탭하고 ESC 를 입력 후 좌측 방향키를 입력하면 2번 셀이 editing 상태가 false 가 되어야 한다.',
      (tester) async {
        expect(stateManager!.isEditing, false);

        await tester.tap(find.text('header3 value 0'));

        await tester.sendKeyEvent(LogicalKeyboardKey.escape);

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);

        expect(stateManager!.currentCell!.value, 'header2 value 0');

        expect(stateManager!.isEditing, false);
      },
    );
  });
}
