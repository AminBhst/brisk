import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:pluto_grid/src/ui/ui.dart';

import '../../helper/column_helper.dart';
import '../../helper/row_helper.dart';
import '../../helper/test_helper_util.dart';

void main() {
  Widget buildGrid({
    required List<PlutoColumn> columns,
    required List<PlutoRow> rows,
    PlutoGridConfiguration configuration = const PlutoGridConfiguration(),
  }) {
    return MaterialApp(
      home: Material(
        child: PlutoGrid(
          columns: columns,
          rows: rows,
          configuration: configuration,
        ),
      ),
    );
  }

  testWidgets(
    '화면 사이즈를 넓히면 넓이에 맞게 컬럼과 셀이 출력 되어야 한다.',
    (tester) async {
      await TestHelperUtil.changeWidth(
        tester: tester,
        width: 450,
        height: 600,
      );

      final columns = ColumnHelper.textColumn('column', count: 10);

      final rows = RowHelper.count(10, columns);

      await tester.pumpWidget(buildGrid(columns: columns, rows: rows));

      final columnWidgets = find.byType(PlutoBaseColumn);

      final firstRowCells = find.descendant(
        of: find.byType(PlutoBaseRow).first,
        matching: find.byType(PlutoBaseCell),
      );

      // visible columns
      expect(columnWidgets.evaluate().length, 3);
      expect(
        columnWidgets.at(0).hitTestable(at: Alignment.centerLeft),
        findsOneWidget,
      );
      expect(
        columnWidgets.at(1).hitTestable(at: Alignment.centerLeft),
        findsOneWidget,
      );
      expect(
        columnWidgets.at(2).hitTestable(at: Alignment.centerLeft),
        findsOneWidget,
      );

      // visible cells
      expect(firstRowCells.evaluate().length, 3);
      expect(
        firstRowCells.at(0).hitTestable(at: Alignment.centerLeft),
        findsOneWidget,
      );
      expect(
        firstRowCells.at(1).hitTestable(at: Alignment.centerLeft),
        findsOneWidget,
      );
      expect(
        firstRowCells.at(2).hitTestable(at: Alignment.centerLeft),
        findsOneWidget,
      );

      // resize
      await TestHelperUtil.changeWidth(
        tester: tester,
        width: 1050,
        height: 600,
      );

      final columnWidgetsAfterResize = find.byType(PlutoBaseColumn);

      final firstRowCellsAfterResize = find.descendant(
        of: find.byType(PlutoBaseRow).first,
        matching: find.byType(PlutoBaseCell),
      );

      expect(columnWidgetsAfterResize.evaluate().length, 6);
      expect(firstRowCellsAfterResize.evaluate().length, 6);
    },
  );

  testWidgets(
    '화면 사이즈를 좁히면 넓이에 맞게 컬럼과 셀이 출력 되어야 한다.',
    (tester) async {
      await TestHelperUtil.changeWidth(
        tester: tester,
        width: 1250,
        height: 600,
      );

      final columns = ColumnHelper.textColumn('column', count: 10);

      final rows = RowHelper.count(10, columns);

      await tester.pumpWidget(buildGrid(columns: columns, rows: rows));

      final columnWidgets = find.byType(PlutoBaseColumn);

      final firstRowCells = find.descendant(
        of: find.byType(PlutoBaseRow).first,
        matching: find.byType(PlutoBaseCell),
      );

      expect(columnWidgets.evaluate().length, 7);
      expect(firstRowCells.evaluate().length, 7);

      // resize
      await TestHelperUtil.changeWidth(
        tester: tester,
        width: 350,
        height: 600,
      );

      final columnWidgetsAfterResize = find.byType(PlutoBaseColumn);

      final firstRowCellsAfterResize = find.descendant(
        of: find.byType(PlutoBaseRow).first,
        matching: find.byType(PlutoBaseCell),
      );

      expect(columnWidgetsAfterResize.evaluate().length, 2);
      expect(firstRowCellsAfterResize.evaluate().length, 2);
    },
  );

  testWidgets(
    'PlutoAutoSizeMode.equal 에서 화면 넓이를 넓히면 컬럼과 셀이 폭에 맞게 출력 되어야 한다.',
    (tester) async {
      await TestHelperUtil.changeWidth(
        tester: tester,
        width: 550,
        height: 600,
      );

      final columns = ColumnHelper.textColumn('column', count: 10);

      final rows = RowHelper.count(10, columns);

      await tester.pumpWidget(buildGrid(
        columns: columns,
        rows: rows,
        configuration: const PlutoGridConfiguration(
          columnSize: PlutoGridColumnSizeConfig(
            autoSizeMode: PlutoAutoSizeMode.equal,
          ),
        ),
      ));

      await tester.pump();

      final columnWidgets = find.byType(PlutoBaseColumn);

      final firstRowCells = find.descendant(
        of: find.byType(PlutoBaseRow).first,
        matching: find.byType(PlutoBaseCell),
      );

      // 넓이 550 에서 컬럼 최소 넓이 80 이면 6.8 개 출력 됨.
      expect(columnWidgets.evaluate().length, 7);
      expect(firstRowCells.evaluate().length, 7);

      // resize
      await TestHelperUtil.changeWidth(
        tester: tester,
        width: 700,
        height: 600,
      );

      final columnWidgetsAfterResize = find.byType(PlutoBaseColumn);

      final firstRowCellsAfterResize = find.descendant(
        of: find.byType(PlutoBaseRow).first,
        matching: find.byType(PlutoBaseCell),
      );

      // 넓이 700 에서 컬럼 최소 넓이 80 이면 8.7 개 출력 됨.
      expect(columnWidgetsAfterResize.evaluate().length, 9);
      expect(firstRowCellsAfterResize.evaluate().length, 9);
    },
  );

  testWidgets(
    'PlutoAutoSizeMode.equal 에서 화면 넓이를 충분히 넓히면 컬럼과 셀이 모두 출력 되어야 한다.',
    (tester) async {
      await TestHelperUtil.changeWidth(
        tester: tester,
        width: 550,
        height: 600,
      );

      final columns = ColumnHelper.textColumn('column', count: 10);

      final rows = RowHelper.count(10, columns);

      await tester.pumpWidget(buildGrid(
        columns: columns,
        rows: rows,
        configuration: const PlutoGridConfiguration(
          columnSize: PlutoGridColumnSizeConfig(
            autoSizeMode: PlutoAutoSizeMode.equal,
          ),
        ),
      ));

      await tester.pump();

      final columnWidgets = find.byType(PlutoBaseColumn);

      final firstRowCells = find.descendant(
        of: find.byType(PlutoBaseRow).first,
        matching: find.byType(PlutoBaseCell),
      );

      // 넓이 550 에서 컬럼 최소 넓이 80 이면 6.8 개 출력 됨.
      expect(columnWidgets.evaluate().length, 7);
      expect(firstRowCells.evaluate().length, 7);

      // resize
      await TestHelperUtil.changeWidth(
        tester: tester,
        width: 1000,
        height: 600,
      );

      final columnWidgetsAfterResize = find.byType(PlutoBaseColumn);

      final firstRowCellsAfterResize = find.descendant(
        of: find.byType(PlutoBaseRow).first,
        matching: find.byType(PlutoBaseCell),
      );

      // 넓이 1,000 에서 컬럼 최소 넓이 80 이면 10 개 모두 출력 됨.
      expect(columnWidgetsAfterResize.evaluate().length, 10);
      expect(firstRowCellsAfterResize.evaluate().length, 10);
    },
  );

  testWidgets(
    'PlutoAutoSizeMode.equal 에서 화면 넓이를 좁히면 컬럼과 셀이 폭에 맞게 출력 되어야 한다.',
    (tester) async {
      await TestHelperUtil.changeWidth(
        tester: tester,
        width: 1200,
        height: 600,
      );

      final columns = ColumnHelper.textColumn('column', count: 10);

      final rows = RowHelper.count(10, columns);

      await tester.pumpWidget(buildGrid(
        columns: columns,
        rows: rows,
        configuration: const PlutoGridConfiguration(
          columnSize: PlutoGridColumnSizeConfig(
            autoSizeMode: PlutoAutoSizeMode.equal,
          ),
        ),
      ));

      await tester.pump();

      final columnWidgets = find.byType(PlutoBaseColumn);

      final firstRowCells = find.descendant(
        of: find.byType(PlutoBaseRow).first,
        matching: find.byType(PlutoBaseCell),
      );

      // 넓이 1200 에서 컬럼 최소 넓이 80 이면 10 개 모두 출력 됨.
      expect(columnWidgets.evaluate().length, 10);
      expect(firstRowCells.evaluate().length, 10);

      // resize
      await TestHelperUtil.changeWidth(
        tester: tester,
        width: 360,
        height: 600,
      );

      final columnWidgetsAfterResize = find.byType(PlutoBaseColumn);

      final firstRowCellsAfterResize = find.descendant(
        of: find.byType(PlutoBaseRow).first,
        matching: find.byType(PlutoBaseCell),
      );

      // 넓이 360 에서 컬럼 최소 넓이 80 이면 4.5 개 출력 됨.
      expect(columnWidgetsAfterResize.evaluate().length, 5);
      expect(firstRowCellsAfterResize.evaluate().length, 5);
    },
  );

  testWidgets(
    'PlutoAutoSizeMode.scale 에서 화면 넓이를 넓히면 컬럼과 셀이 폭에 맞게 출력 되어야 한다.',
    (tester) async {
      await TestHelperUtil.changeWidth(
        tester: tester,
        width: 550,
        height: 600,
      );

      final columns = ColumnHelper.textColumn('column', count: 10);

      final rows = RowHelper.count(10, columns);

      await tester.pumpWidget(buildGrid(
        columns: columns,
        rows: rows,
        configuration: const PlutoGridConfiguration(
          columnSize: PlutoGridColumnSizeConfig(
            autoSizeMode: PlutoAutoSizeMode.scale,
          ),
        ),
      ));

      await tester.pump();

      final columnWidgets = find.byType(PlutoBaseColumn);

      final firstRowCells = find.descendant(
        of: find.byType(PlutoBaseRow).first,
        matching: find.byType(PlutoBaseCell),
      );

      // 넓이 550 에서 컬럼 최소 넓이 80 이면 6.8 개 출력 됨.
      expect(columnWidgets.evaluate().length, 7);
      expect(firstRowCells.evaluate().length, 7);

      // resize
      await TestHelperUtil.changeWidth(
        tester: tester,
        width: 700,
        height: 600,
      );

      final columnWidgetsAfterResize = find.byType(PlutoBaseColumn);

      final firstRowCellsAfterResize = find.descendant(
        of: find.byType(PlutoBaseRow).first,
        matching: find.byType(PlutoBaseCell),
      );

      // 넓이 700 에서 컬럼 최소 넓이 80 이면 8.7 개 출력 됨.
      expect(columnWidgetsAfterResize.evaluate().length, 9);
      expect(firstRowCellsAfterResize.evaluate().length, 9);
    },
  );

  testWidgets(
    'PlutoAutoSizeMode.scale 에서 화면 넓이를 충분히 넓히면 컬럼과 셀이 모두 출력 되어야 한다.',
    (tester) async {
      await TestHelperUtil.changeWidth(
        tester: tester,
        width: 550,
        height: 600,
      );

      final columns = ColumnHelper.textColumn('column', count: 10);

      final rows = RowHelper.count(10, columns);

      await tester.pumpWidget(buildGrid(
        columns: columns,
        rows: rows,
        configuration: const PlutoGridConfiguration(
          columnSize: PlutoGridColumnSizeConfig(
            autoSizeMode: PlutoAutoSizeMode.scale,
          ),
        ),
      ));

      await tester.pump();

      final columnWidgets = find.byType(PlutoBaseColumn);

      final firstRowCells = find.descendant(
        of: find.byType(PlutoBaseRow).first,
        matching: find.byType(PlutoBaseCell),
      );

      // 넓이 550 에서 컬럼 최소 넓이 80 이면 6.8 개 출력 됨.
      expect(columnWidgets.evaluate().length, 7);
      expect(firstRowCells.evaluate().length, 7);

      // resize
      await TestHelperUtil.changeWidth(
        tester: tester,
        width: 1000,
        height: 600,
      );

      final columnWidgetsAfterResize = find.byType(PlutoBaseColumn);

      final firstRowCellsAfterResize = find.descendant(
        of: find.byType(PlutoBaseRow).first,
        matching: find.byType(PlutoBaseCell),
      );

      // 넓이 1,000 에서 컬럼 최소 넓이 80 이면 10 개 모두 출력 됨.
      expect(columnWidgetsAfterResize.evaluate().length, 10);
      expect(firstRowCellsAfterResize.evaluate().length, 10);
    },
  );

  testWidgets(
    'PlutoAutoSizeMode.scale 에서 화면 넓이를 좁히면 컬럼과 셀이 폭에 맞게 출력 되어야 한다.',
    (tester) async {
      await TestHelperUtil.changeWidth(
        tester: tester,
        width: 1200,
        height: 600,
      );

      final columns = ColumnHelper.textColumn('column', count: 10);

      final rows = RowHelper.count(10, columns);

      await tester.pumpWidget(buildGrid(
        columns: columns,
        rows: rows,
        configuration: const PlutoGridConfiguration(
          columnSize: PlutoGridColumnSizeConfig(
            autoSizeMode: PlutoAutoSizeMode.scale,
          ),
        ),
      ));

      await tester.pump();

      final columnWidgets = find.byType(PlutoBaseColumn);

      final firstRowCells = find.descendant(
        of: find.byType(PlutoBaseRow).first,
        matching: find.byType(PlutoBaseCell),
      );

      // 넓이 1200 에서 컬럼 최소 넓이 80 이면 10 개 모두 출력 됨.
      expect(columnWidgets.evaluate().length, 10);
      expect(firstRowCells.evaluate().length, 10);

      // resize
      await TestHelperUtil.changeWidth(
        tester: tester,
        width: 360,
        height: 600,
      );

      final columnWidgetsAfterResize = find.byType(PlutoBaseColumn);

      final firstRowCellsAfterResize = find.descendant(
        of: find.byType(PlutoBaseRow).first,
        matching: find.byType(PlutoBaseCell),
      );

      // 넓이 360 에서 컬럼 최소 넓이 80 이면 4.5 개 출력 됨.
      expect(columnWidgetsAfterResize.evaluate().length, 5);
      expect(firstRowCellsAfterResize.evaluate().length, 5);
    },
  );
}
