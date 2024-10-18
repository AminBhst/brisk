import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:pluto_grid/src/ui/ui.dart';

import '../../helper/column_helper.dart';
import '../../helper/row_helper.dart';
import '../../helper/test_helper_util.dart';

void main() {
  late PlutoGridStateManager stateManager;

  buildGrid({
    required WidgetTester tester,
    required List<PlutoColumn> columns,
    required List<PlutoRow> rows,
  }) async {
    await TestHelperUtil.changeWidth(tester: tester, width: 1200, height: 800);

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

    await tester.pumpAndSettle();
  }

  testWidgets(
    '컬럼의 footerRenderer 가 없는 경우 컬럼 푸터 위젯들이 렌더링 되지 않아야 한다.',
    (tester) async {
      final columns = [
        ...ColumnHelper.textColumn(
          'left',
          count: 2,
          frozen: PlutoColumnFrozen.start,
        ),
        ...ColumnHelper.textColumn(
          'body',
          count: 2,
        ),
        ...ColumnHelper.textColumn(
          'right',
          count: 2,
          frozen: PlutoColumnFrozen.end,
        ),
      ];

      final rows = RowHelper.count(3, columns);

      await buildGrid(tester: tester, columns: columns, rows: rows);

      expect(find.byType(PlutoLeftFrozenColumnsFooter), findsNothing);
      expect(find.byType(PlutoBodyColumnsFooter), findsNothing);
      expect(find.byType(PlutoRightFrozenColumnsFooter), findsNothing);
      expect(find.byType(PlutoBaseColumnFooter), findsNothing);
    },
  );

  testWidgets(
    '컬럼의 footerRenderer 가 없어도 setShowColumnFooter 를 true 로 호출하면 '
    '컬럼 푸터 위젯들이 렌더링 되어야 한다.',
    (tester) async {
      final columns = [
        ...ColumnHelper.textColumn(
          'left',
          count: 2,
          frozen: PlutoColumnFrozen.start,
        ),
        ...ColumnHelper.textColumn(
          'body',
          count: 2,
        ),
        ...ColumnHelper.textColumn(
          'right',
          count: 2,
          frozen: PlutoColumnFrozen.end,
        ),
      ];

      final rows = RowHelper.count(3, columns);

      await buildGrid(tester: tester, columns: columns, rows: rows);

      stateManager.setShowColumnFooter(true);

      await tester.pumpAndSettle();

      expect(find.byType(PlutoLeftFrozenColumnsFooter), findsOneWidget);
      expect(find.byType(PlutoBodyColumnsFooter), findsOneWidget);
      expect(find.byType(PlutoRightFrozenColumnsFooter), findsOneWidget);
      expect(find.byType(PlutoBaseColumnFooter), findsNWidgets(6));
    },
  );

  testWidgets(
    '컬럼의 footerRenderer 가 있는 경우 컬럼 푸터 위젯들이 렌더링 되어야 한다.',
    (tester) async {
      final columns = [
        ...ColumnHelper.textColumn(
          'left',
          count: 2,
          frozen: PlutoColumnFrozen.start,
          footerRenderer: (ctx) => Text(ctx.column.title),
        ),
        ...ColumnHelper.textColumn(
          'body',
          count: 2,
        ),
        ...ColumnHelper.textColumn(
          'right',
          count: 2,
          frozen: PlutoColumnFrozen.end,
        ),
      ];

      final rows = RowHelper.count(3, columns);

      await buildGrid(tester: tester, columns: columns, rows: rows);

      expect(find.byType(PlutoLeftFrozenColumnsFooter), findsOneWidget);
      expect(find.byType(PlutoBodyColumnsFooter), findsOneWidget);
      expect(find.byType(PlutoRightFrozenColumnsFooter), findsOneWidget);
      expect(find.byType(PlutoBaseColumnFooter), findsNWidgets(6));
    },
  );
}
