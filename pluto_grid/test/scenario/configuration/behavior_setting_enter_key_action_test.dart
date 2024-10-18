import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../helper/column_helper.dart';
import '../../helper/pluto_widget_test_helper.dart';
import '../../helper/row_helper.dart';

/// enterKeyAction 설정 후 테스트
void main() {
  group('Enter key test.', () {
    List<PlutoColumn> columns;

    List<PlutoRow> rows;

    PlutoGridStateManager? stateManager;

    withEnterKeyAction(PlutoGridEnterKeyAction enterKeyAction) {
      return PlutoWidgetTestHelper(
        '2, 2 셀이 선택 된 상태에서',
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
                  configuration: PlutoGridConfiguration(
                    enterKeyAction: enterKeyAction,
                  ),
                ),
              ),
            ),
          );

          await tester.pump();

          await tester.tap(find.text('header2 value 2'));
        },
      );
    }

    withEnterKeyAction(PlutoGridEnterKeyAction.none).test(
      'PlutoEnterKeyAction.None 인 경우 기존 상태에서 아무 변화가 없어야 한다.',
      (tester) async {
        stateManager!.setEditing(true);
        expect(stateManager!.isEditing, true);

        await tester.sendKeyEvent(LogicalKeyboardKey.enter);

        expect(stateManager!.currentCellPosition!.rowIdx, 2);
        expect(stateManager!.currentCellPosition!.columnIdx, 2);
      },
    );

    withEnterKeyAction(PlutoGridEnterKeyAction.toggleEditing).test(
      'PlutoEnterKeyAction.ToggleEditing 인 경우 editing 이 false 가 되어야 한다.',
      (tester) async {
        stateManager!.setEditing(true);
        expect(stateManager!.isEditing, true);

        await tester.sendKeyEvent(LogicalKeyboardKey.enter);

        expect(stateManager!.isEditing, isFalse);
        expect(stateManager!.currentCellPosition!.rowIdx, 2);
        expect(stateManager!.currentCellPosition!.columnIdx, 2);
      },
    );

    withEnterKeyAction(PlutoGridEnterKeyAction.toggleEditing).test(
      'PlutoEnterKeyAction.ToggleEditing 인 경우 editing 이 true 가 되어야 한다.',
      (tester) async {
        stateManager!.setEditing(false);
        expect(stateManager!.isEditing, false);

        await tester.sendKeyEvent(LogicalKeyboardKey.enter);

        expect(stateManager!.isEditing, isTrue);
        expect(stateManager!.currentCellPosition!.rowIdx, 2);
        expect(stateManager!.currentCellPosition!.columnIdx, 2);
      },
    );

    withEnterKeyAction(PlutoGridEnterKeyAction.editingAndMoveDown).test(
      'PlutoEnterKeyAction.EditingAndMoveDown 인 경우 아래로 이동 되어야 한다.',
      (tester) async {
        stateManager!.setEditing(true);
        expect(stateManager!.isEditing, true);

        await tester.sendKeyEvent(LogicalKeyboardKey.enter);

        expect(stateManager!.isEditing, isTrue);
        expect(stateManager!.currentCellPosition!.rowIdx, 3);
        expect(stateManager!.currentCellPosition!.columnIdx, 2);
      },
    );

    withEnterKeyAction(PlutoGridEnterKeyAction.editingAndMoveDown).test(
      'PlutoEnterKeyAction.EditingAndMoveDown 인 경우 위로 이동 되어야 한다.',
      (tester) async {
        stateManager!.setEditing(true);
        expect(stateManager!.isEditing, true);

        await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);

        expect(stateManager!.isEditing, isTrue);
        expect(stateManager!.currentCellPosition!.rowIdx, 1);
        expect(stateManager!.currentCellPosition!.columnIdx, 2);
      },
    );

    withEnterKeyAction(PlutoGridEnterKeyAction.editingAndMoveRight).test(
      'PlutoEnterKeyAction.EditingAndMoveRight 인 경우 우측으로 이동 되어야 한다.',
      (tester) async {
        stateManager!.setEditing(true);
        expect(stateManager!.isEditing, true);

        await tester.sendKeyEvent(LogicalKeyboardKey.enter);

        expect(stateManager!.isEditing, isTrue);
        expect(stateManager!.currentCellPosition!.rowIdx, 2);
        expect(stateManager!.currentCellPosition!.columnIdx, 3);
      },
    );

    withEnterKeyAction(PlutoGridEnterKeyAction.editingAndMoveRight).test(
      'PlutoEnterKeyAction.EditingAndMoveRight 인 경우 좌측으로 이동 되어야 한다.',
      (tester) async {
        stateManager!.setEditing(true);
        expect(stateManager!.isEditing, true);

        await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);

        expect(stateManager!.isEditing, isTrue);
        expect(stateManager!.currentCellPosition!.rowIdx, 2);
        expect(stateManager!.currentCellPosition!.columnIdx, 1);
      },
    );
  });
}
