import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:pluto_grid/src/ui/ui.dart';

import '../../helper/column_helper.dart';
import '../../helper/pluto_widget_test_helper.dart';
import '../../helper/row_helper.dart';

void main() {
  List<PlutoColumn> columns;

  List<PlutoRow> rows;

  late PlutoGridStateManager stateManager;

  final tenByTenGrid = PlutoWidgetTestHelper(
    '10 개 컬럼과 10개 행을 생성. ',
    (tester) async {
      columns = ColumnHelper.textColumn('column', count: 10);

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
    },
  );

  Finder findFilter(String columnTitle) {
    return find.descendant(
      of: find.ancestor(
        of: find.text(columnTitle),
        matching: find.byType(PlutoBaseColumn),
      ),
      matching: find.byType(TextField),
    );
  }

  Future<void> tapFilter(WidgetTester tester, Finder filter) async {
    // 텍스트 박스가 최초에 포커스를 받으려면 두번 탭.
    await tester.tap(filter);
    await tester.pump();
    await tester.tap(filter);
    await tester.pump();
  }

  tenByTenGrid.test('0번 컬럼의 필터를 탭한 후 우측 방향키 이동', (tester) async {
    final firstColumnFilter = findFilter('column0');

    await tapFilter(tester, firstColumnFilter);
    await tester.pump();
    expect(stateManager.refColumns[0].filterFocusNode!.hasFocus, true);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(stateManager.refColumns[1].filterFocusNode!.hasFocus, true);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(stateManager.refColumns[2].filterFocusNode!.hasFocus, true);
  });

  tenByTenGrid.test('2번 컬럼의 필터를 탭한 후 좌측 방향키 이동', (tester) async {
    final firstColumnFilter = findFilter('column2');

    await tapFilter(tester, firstColumnFilter);
    await tester.pump();
    expect(stateManager.refColumns[2].filterFocusNode!.hasFocus, true);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pump();
    expect(stateManager.refColumns[1].filterFocusNode!.hasFocus, true);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pump();
    expect(stateManager.refColumns[0].filterFocusNode!.hasFocus, true);
  });

  tenByTenGrid.test('0번 컬럼의 필터를 탭한 후 탭키 이동', (tester) async {
    final firstColumnFilter = findFilter('column0');

    await tapFilter(tester, firstColumnFilter);
    await tester.pump();
    expect(stateManager.refColumns[0].filterFocusNode!.hasFocus, true);

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(stateManager.refColumns[1].filterFocusNode!.hasFocus, true);

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(stateManager.refColumns[2].filterFocusNode!.hasFocus, true);
  });

  tenByTenGrid.test('2번 컬럼의 필터를 탭한 후 쉬프트 + 탭키 이동', (tester) async {
    final firstColumnFilter = findFilter('column2');

    await tapFilter(tester, firstColumnFilter);
    await tester.pump();
    expect(stateManager.refColumns[2].filterFocusNode!.hasFocus, true);

    await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
    await tester.pump();
    expect(stateManager.refColumns[1].filterFocusNode!.hasFocus, true);

    await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
    await tester.pump();
    expect(stateManager.refColumns[0].filterFocusNode!.hasFocus, true);
  });
}
