import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:pluto_grid/src/ui/ui.dart';

import '../../helper/column_helper.dart';
import '../../helper/row_helper.dart';
import '../../helper/test_helper_util.dart';

void main() {
  late PlutoGridStateManager stateManager;
  late List<PlutoColumn> columns;
  late List<PlutoColumnGroup> columnGroups;
  late List<PlutoRow> rows;

  setUp(() {
    columns = ColumnHelper.textColumn('column', count: 5);
    rows = RowHelper.count(10, columns);
    columnGroups = [
      PlutoColumnGroup(title: 'group1', children: [
        PlutoColumnGroup(title: 'group1-1', fields: ['column0', 'column1']),
      ]),
    ];
  });

  Future<void> buildGrid({
    required WidgetTester tester,
    required List<PlutoColumn> columns,
    required List<PlutoRow> rows,
    List<PlutoColumnGroup>? columnGroups,
    bool? showColumnFilter,
  }) async {
    await TestHelperUtil.changeWidth(tester: tester, width: 1200, height: 800);

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: PlutoGrid(
            columns: columns,
            columnGroups: columnGroups,
            rows: rows,
            onLoaded: (PlutoGridOnLoadedEvent event) {
              stateManager = event.stateManager;

              if (showColumnFilter == true) {
                stateManager.setShowColumnFilter(true);
              }
            },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
  }

  Finder findPlutoBaseColumn(String title) {
    return find.ancestor(
      of: find.text(title),
      matching: find.byType(PlutoBaseColumn),
    );
  }

  testWidgets('컬럼 그룹을 숨기면 컬럼 영역의 높이가 변경 되어야 한다.', (tester) async {
    columns[2].frozen = PlutoColumnFrozen.start;
    columns[3].frozen = PlutoColumnFrozen.end;

    await buildGrid(
      tester: tester,
      columns: columns,
      rows: rows,
      columnGroups: columnGroups,
    );

    expect(
      tester.getSize(find.byType(PlutoLeftFrozenColumns)).height,
      stateManager.columnHeight * 3,
    );
    expect(
      tester.getSize(find.byType(PlutoBodyColumns)).height,
      stateManager.columnHeight * 3,
    );
    expect(
      tester.getSize(find.byType(PlutoRightFrozenColumns)).height,
      stateManager.columnHeight * 3,
    );

    stateManager.setShowColumnGroups(false);
    await tester.pumpAndSettle();

    expect(
      tester.getSize(find.byType(PlutoLeftFrozenColumns)).height,
      stateManager.columnHeight,
    );
    expect(
      tester.getSize(find.byType(PlutoBodyColumns)).height,
      stateManager.columnHeight,
    );
    expect(
      tester.getSize(find.byType(PlutoRightFrozenColumns)).height,
      stateManager.columnHeight,
    );
  });

  testWidgets('컬럼 그룹을 숨기면 컬럼 그룹이 제거 되어야 한다.', (tester) async {
    columns[2].frozen = PlutoColumnFrozen.start;
    columns[3].frozen = PlutoColumnFrozen.end;

    await buildGrid(
      tester: tester,
      columns: columns,
      rows: rows,
      columnGroups: columnGroups,
    );

    expect(find.text('group1'), findsOneWidget);
    expect(find.text('group1-1'), findsOneWidget);

    stateManager.setShowColumnGroups(false);
    await tester.pumpAndSettle();

    expect(find.text('group1'), findsNothing);
    expect(find.text('group1-1'), findsNothing);
  });

  testWidgets('컬럼 그룹을 숨기면 컬럼 높이가 변경 되어야 한다.', (tester) async {
    columns[2].frozen = PlutoColumnFrozen.start;
    columns[3].frozen = PlutoColumnFrozen.end;

    await buildGrid(
      tester: tester,
      columns: columns,
      rows: rows,
      columnGroups: columnGroups,
    );

    // group columns
    expect(
      tester.getSize(findPlutoBaseColumn('column0')).height,
      stateManager.columnHeight,
    );
    expect(
      tester.getSize(findPlutoBaseColumn('column1')).height,
      stateManager.columnHeight,
    );
    // expanded columns
    expect(
      tester.getSize(findPlutoBaseColumn('column2')).height,
      stateManager.columnHeight * 3,
    );
    expect(
      tester.getSize(findPlutoBaseColumn('column3')).height,
      stateManager.columnHeight * 3,
    );
    expect(
      tester.getSize(findPlutoBaseColumn('column4')).height,
      stateManager.columnHeight * 3,
    );

    stateManager.setShowColumnGroups(false);
    await tester.pumpAndSettle();

    // group columns
    expect(
      tester.getSize(findPlutoBaseColumn('column0')).height,
      stateManager.columnHeight,
    );
    expect(
      tester.getSize(findPlutoBaseColumn('column1')).height,
      stateManager.columnHeight,
    );
    // expanded columns
    expect(
      tester.getSize(findPlutoBaseColumn('column2')).height,
      stateManager.columnHeight,
    );
    expect(
      tester.getSize(findPlutoBaseColumn('column3')).height,
      stateManager.columnHeight,
    );
    expect(
      tester.getSize(findPlutoBaseColumn('column4')).height,
      stateManager.columnHeight,
    );
  });

  testWidgets('컬럼 그룹을 숨기면 행 영역의 높이가 변경 되어야 한다.', (tester) async {
    columns[2].frozen = PlutoColumnFrozen.start;
    columns[3].frozen = PlutoColumnFrozen.end;

    await buildGrid(
      tester: tester,
      columns: columns,
      rows: rows,
      columnGroups: columnGroups,
    );

    final changedSize = Size(0, stateManager.columnHeight * 2);

    final leftSize = tester.getSize(find.byType(PlutoLeftFrozenRows));
    final bodySize = tester.getSize(find.byType(PlutoBodyRows));
    final rightSize = tester.getSize(find.byType(PlutoRightFrozenRows));

    stateManager.setShowColumnGroups(false);
    await tester.pumpAndSettle();

    final afterLeftSize = tester.getSize(find.byType(PlutoLeftFrozenRows));
    final afterBodySize = tester.getSize(find.byType(PlutoBodyRows));
    final afterRightSize = tester.getSize(find.byType(PlutoRightFrozenRows));

    expect(afterLeftSize.height - changedSize.height, leftSize.height);
    expect(afterBodySize.height - changedSize.height, bodySize.height);
    expect(afterRightSize.height - changedSize.height, rightSize.height);

    expect(afterLeftSize.width - changedSize.width, leftSize.width);
    expect(afterBodySize.width - changedSize.width, bodySize.width);
    expect(afterRightSize.width - changedSize.width, rightSize.width);
  });

  testWidgets('화면 크기를 좁게 변경하면 고정 컬럼이 풀려야 한다.', (tester) async {
    columns[2].frozen = PlutoColumnFrozen.start;
    columns[3].frozen = PlutoColumnFrozen.end;

    await buildGrid(
      tester: tester,
      columns: columns,
      rows: rows,
      columnGroups: columnGroups,
    );

    // 시작 고정 컬럼
    expect(
      tester.getTopLeft(findPlutoBaseColumn('column2')).dx,
      lessThan(tester.getTopLeft(findPlutoBaseColumn('column0')).dx),
    );
    expect(
      tester.getTopLeft(findPlutoBaseColumn('column0')).dx,
      lessThan(tester.getTopLeft(findPlutoBaseColumn('column1')).dx),
    );
    expect(
      tester.getTopLeft(findPlutoBaseColumn('column1')).dx,
      lessThan(tester.getTopLeft(findPlutoBaseColumn('column4')).dx),
    );
    // 끝 고정 컬럼
    expect(
      tester.getTopLeft(findPlutoBaseColumn('column4')).dx,
      lessThan(tester.getTopLeft(findPlutoBaseColumn('column3')).dx),
    );

    await TestHelperUtil.changeWidth(tester: tester, width: 500, height: 800);
    await tester.pumpAndSettle();

    expect(
      tester.getTopLeft(findPlutoBaseColumn('column0')).dx,
      lessThan(tester.getTopLeft(findPlutoBaseColumn('column1')).dx),
    );
    expect(
      tester.getTopLeft(findPlutoBaseColumn('column1')).dx,
      lessThan(tester.getTopLeft(findPlutoBaseColumn('column2')).dx),
    );

    stateManager.moveScrollByColumn(PlutoMoveDirection.right, 3);
    await tester.pumpAndSettle();

    expect(
      tester.getTopLeft(findPlutoBaseColumn('column2')).dx,
      lessThan(tester.getTopLeft(findPlutoBaseColumn('column3')).dx),
    );
    expect(
      tester.getTopLeft(findPlutoBaseColumn('column3')).dx,
      lessThan(tester.getTopLeft(findPlutoBaseColumn('column4')).dx),
    );
  });

  testWidgets('컬럼을 숨기면 컬럼 영역의 높이가 0이 되어야 한다.', (tester) async {
    columns[2].frozen = PlutoColumnFrozen.start;
    columns[3].frozen = PlutoColumnFrozen.end;

    await buildGrid(
      tester: tester,
      columns: columns,
      rows: rows,
      columnGroups: columnGroups,
    );

    stateManager.setShowColumnTitle(false);
    await tester.pumpAndSettle();

    expect(tester.getSize(find.byType(PlutoLeftFrozenColumns)).height, 0);
    expect(tester.getSize(find.byType(PlutoBodyColumns)).height, 0);
    expect(tester.getSize(find.byType(PlutoRightFrozenColumns)).height, 0);
  });

  testWidgets('컬럼을 숨기면 행 영역의 높이가 변경 되어야 한다.', (tester) async {
    columns[2].frozen = PlutoColumnFrozen.start;
    columns[3].frozen = PlutoColumnFrozen.end;

    await buildGrid(
      tester: tester,
      columns: columns,
      rows: rows,
      columnGroups: columnGroups,
    );

    final changedSize = Size(0, stateManager.columnHeight * 3);

    final leftSize = tester.getSize(find.byType(PlutoLeftFrozenRows));
    final bodySize = tester.getSize(find.byType(PlutoBodyRows));
    final rightSize = tester.getSize(find.byType(PlutoRightFrozenRows));

    stateManager.setShowColumnTitle(false);
    await tester.pumpAndSettle();

    final afterLeftSize = tester.getSize(find.byType(PlutoLeftFrozenRows));
    final afterBodySize = tester.getSize(find.byType(PlutoBodyRows));
    final afterRightSize = tester.getSize(find.byType(PlutoRightFrozenRows));

    expect(afterLeftSize.height - changedSize.height, leftSize.height);
    expect(afterBodySize.height - changedSize.height, bodySize.height);
    expect(afterRightSize.height - changedSize.height, rightSize.height);

    expect(afterLeftSize.width - changedSize.width, leftSize.width);
    expect(afterBodySize.width - changedSize.width, bodySize.width);
    expect(afterRightSize.width - changedSize.width, rightSize.width);
  });
}
