import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';

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
  }

  testWidgets('좌측 고정 컬럼을 추가하면 렌더링 되어야 한다.', (tester) async {
    final columns = ColumnHelper.textColumn('column', count: 10);

    final rows = RowHelper.count(10, columns);

    final columnToInsert = PlutoColumn(
      title: 'column10',
      field: 'column10',
      frozen: PlutoColumnFrozen.start,
      type: PlutoColumnType.text(
        defaultValue: 'column10 value new',
      ),
    );

    await buildGrid(tester: tester, columns: columns, rows: rows);

    stateManager.insertColumns(5, [columnToInsert]);

    await tester.pump();

    expect(find.text('column10'), findsOneWidget);
    expect(find.text('column10 value new'), findsWidgets);
  });

  testWidgets('우측 고정 컬럼을 추가하면 렌더링 되어야 한다.', (tester) async {
    final columns = ColumnHelper.textColumn('column', count: 10);

    final rows = RowHelper.count(10, columns);

    final columnToInsert = PlutoColumn(
      title: 'column10',
      field: 'column10',
      frozen: PlutoColumnFrozen.end,
      type: PlutoColumnType.text(
        defaultValue: 'column10 value new',
      ),
    );

    await buildGrid(tester: tester, columns: columns, rows: rows);

    stateManager.insertColumns(5, [columnToInsert]);

    await tester.pump();

    expect(find.text('column10'), findsOneWidget);
    expect(find.text('column10 value new'), findsWidgets);
  });

  testWidgets('촤측 고정 컬럼을 추가하면 위치가 좌측 끝이어야 한다.', (tester) async {
    final columns = ColumnHelper.textColumn('column', count: 10);

    final rows = RowHelper.count(10, columns);

    final columnToInsert = PlutoColumn(
      title: 'column10',
      field: 'column10',
      frozen: PlutoColumnFrozen.start,
      type: PlutoColumnType.text(
        defaultValue: 'column10 value new',
      ),
    );

    await buildGrid(tester: tester, columns: columns, rows: rows);

    stateManager.insertColumns(5, [columnToInsert]);

    await tester.pump();

    final Offset position = tester.getTopLeft(find.text('column10'));

    final Offset firstPosition = tester.getTopLeft(find.text('column0'));

    expect(position.dx, lessThan(firstPosition.dx));
  });

  testWidgets('우측 고정 컬럼을 추가하면 위치가 우측 끝이어야 한다.', (tester) async {
    final columns = ColumnHelper.textColumn('column', count: 10);

    final rows = RowHelper.count(10, columns);

    final columnToInsert = PlutoColumn(
      title: 'column10',
      field: 'column10',
      frozen: PlutoColumnFrozen.end,
      type: PlutoColumnType.text(
        defaultValue: 'column10 value new',
      ),
    );

    await buildGrid(tester: tester, columns: columns, rows: rows);

    stateManager.insertColumns(5, [columnToInsert]);

    await tester.pump();

    final Offset position = tester.getTopLeft(find.text('column10'));

    // 화면 사이즈 1200에서 5번째 컬럼이 column4 가 마지막 보여지는 컬럼.
    final Offset lastPosition = tester.getTopLeft(find.text('column4'));

    expect(position.dx, greaterThan(lastPosition.dx));
  });
}
