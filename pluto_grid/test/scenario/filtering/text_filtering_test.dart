import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:pluto_grid/src/ui/ui.dart';

import '../../helper/column_helper.dart';
import '../../helper/row_helper.dart';

void main() {
  late PlutoGridStateManager stateManager;

  Widget buildGrid({
    required List<PlutoColumn> columns,
    required List<PlutoRow> rows,
  }) {
    return MaterialApp(
      home: Material(
        child: PlutoGrid(
          columns: columns,
          rows: rows,
          onLoaded: (e) {
            stateManager = e.stateManager;
            stateManager.setShowColumnFilter(true);
          },
        ),
      ),
    );
  }

  Finder findFilterTextField() {
    return find.descendant(
      of: find.byType(PlutoColumnFilter),
      matching: find.byType(TextField),
    );
  }

  Future<void> tapAndEnterTextColumnFilter(
    WidgetTester tester,
    String? enterText,
  ) async {
    final textField = findFilterTextField();

    // 텍스트 박스가 최초에 포커스를 받으려면 두번 탭.
    await tester.tap(textField);
    await tester.tap(textField);

    if (enterText != null) {
      await tester.enterText(textField, enterText);
    }
  }

  testWidgets(
    '기본 필터 상태에서 필터 값을 value 1 로 설정하면 필터 값에 해당 되는 행만 출력 되어야 한다.',
    (tester) async {
      final columns = ColumnHelper.textColumn('column');

      final rows = RowHelper.count(20, columns);

      await tester.pumpWidget(buildGrid(columns: columns, rows: rows));

      await tester.pump();

      await tapAndEnterTextColumnFilter(tester, 'value 1');

      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(stateManager.refRows.length, 11);

      expect(find.text('column0 value 1'), findsOneWidget);
      expect(find.text('column0 value 10'), findsOneWidget);
      expect(find.text('column0 value 11'), findsOneWidget);
      expect(find.text('column0 value 12'), findsOneWidget);
      expect(find.text('column0 value 13'), findsOneWidget);
      expect(find.text('column0 value 14'), findsOneWidget);
      expect(find.text('column0 value 15'), findsOneWidget);
      expect(find.text('column0 value 16'), findsOneWidget);
      expect(find.text('column0 value 17'), findsOneWidget);
      expect(find.text('column0 value 18'), findsOneWidget);
      expect(find.text('column0 value 19'), findsOneWidget);
    },
  );

  testWidgets(
    '기본 필터 상태에서 필터 값을 value 11 로 설정하면 필터 값에 해당 되는 행만 출력 되어야 한다.',
    (tester) async {
      final columns = ColumnHelper.textColumn('column');

      final rows = RowHelper.count(20, columns);

      await tester.pumpWidget(buildGrid(columns: columns, rows: rows));

      await tester.pump();

      await tapAndEnterTextColumnFilter(tester, 'value 11');

      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(stateManager.refRows.length, 1);

      expect(find.text('column0 value 11'), findsOneWidget);
    },
  );

  testWidgets(
    '필터 값이 value 11 로 설정된 상태에서, '
    'Ctrl + A 를 입력 후 백스페이스를 입력하면 전체 행이 출력 되어야 한다.',
    (tester) async {
      final columns = ColumnHelper.textColumn('column');

      final rows = RowHelper.count(20, columns);

      await tester.pumpWidget(buildGrid(columns: columns, rows: rows));

      await tester.pump();

      await tapAndEnterTextColumnFilter(tester, 'value 11');

      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(stateManager.refRows.length, 1);

      expect(find.text('column0 value 11'), findsOneWidget);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);

      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(stateManager.refRows.length, 20);

      expect(find.text('column0 value 0'), findsOneWidget);

      stateManager.moveScrollByRow(PlutoMoveDirection.down, 19);

      await tester.pump();

      expect(find.text('column0 value 19'), findsOneWidget);
    },
  );
}
