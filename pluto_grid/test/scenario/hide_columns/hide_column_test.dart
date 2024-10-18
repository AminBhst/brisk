import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:pluto_grid/src/ui/ui.dart';

import '../../helper/column_helper.dart';
import '../../helper/pluto_widget_test_helper.dart';
import '../../helper/row_helper.dart';

void main() {
  group('숨김 컬럼이 없는 상태에서', () {
    late List<PlutoColumn> columns;

    late List<PlutoRow> rows;

    late PlutoGridStateManager stateManager;

    final withTenColumns = PlutoWidgetTestHelper(
      '10개의 컬럼을 생성',
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
              ),
            ),
          ),
        );
      },
    );

    withTenColumns.test(
      'hideColumn 으로 header1 을 숨기면 header1 컬럼이 숨겨져야 한다.',
      (tester) async {
        var column = find.text('header1');

        expect(column, findsOneWidget);

        stateManager.hideColumn(columns[1], true);

        await tester.pumpAndSettle();

        expect(column, findsNothing);
      },
    );

    withTenColumns.test(
      'showSetColumnsPopup 을 호출 하면 컬럼 설정 팝업이 호출 되어야 한다.',
      (tester) async {
        stateManager.showSetColumnsPopup(stateManager.gridFocusNode.context!);

        await tester.pumpAndSettle();

        var columnTitleOfPopup = find.text(
          stateManager.configuration.localeText.setColumnsTitle,
        );

        expect(columnTitleOfPopup, findsOneWidget);
      },
    );

    withTenColumns.test(
      '컬럼 설정 팝업에서 전체 체크 박스를 탭하면 전체 컬럼이 숨겨져야 한다.',
      (tester) async {
        stateManager.showSetColumnsPopup(stateManager.gridFocusNode.context!);

        await tester.pumpAndSettle();

        final allCheckbox = find.descendant(
          of: find.byType(PlutoBaseColumn),
          matching: find.byType(PlutoScaledCheckbox),
        );

        await tester.tap(allCheckbox, warnIfMissed: false);

        await tester.pump();

        expect(stateManager.refColumns.length, 0);
      },
    );

    withTenColumns.test(
      '컬럼 설정 팝업에서 header0 컬럼의 체크 박스를 탭하면 header0 컬럼이 숨겨져야 한다.',
      (tester) async {
        stateManager.showSetColumnsPopup(stateManager.gridFocusNode.context!);

        await tester.pumpAndSettle();

        final columnTitleOfPopup = find.text(
          stateManager.configuration.localeText.setColumnsTitle,
        );

        final firstColumnCell = find
            .descendant(
              of: find.ancestor(
                of: columnTitleOfPopup,
                matching: find.byType(PlutoGrid),
              ),
              matching: find.byType(PlutoBaseCell),
            )
            .first;

        final firstColumnTitle =
            (firstColumnCell.evaluate().first.widget as PlutoBaseCell)
                .cell
                .value;

        final headerCheckbox0 = find.descendant(
          of: firstColumnCell,
          matching: find.byType(PlutoScaledCheckbox),
        );

        await tester.tap(headerCheckbox0, warnIfMissed: false);

        await tester.pump();

        expect(stateManager.refColumns.length, 9);

        expect(
          stateManager.refColumns
              .where((e) => e.title == firstColumnTitle)
              .length,
          0,
        );
      },
    );

    withTenColumns.test(
      'header0 컬럼이 숨겨진 상태에서 header0 의 체크 박스를 탭하면 header0 컬럼이 나타나야 한다.',
      (tester) async {
        stateManager.hideColumn(stateManager.refColumns.first, true);

        await tester.pumpAndSettle();

        expect(stateManager.refColumns.length, 9);

        stateManager.showSetColumnsPopup(stateManager.gridFocusNode.context!);

        await tester.pumpAndSettle();

        final columnTitleOfPopup = find.text(
          stateManager.configuration.localeText.setColumnsTitle,
        );

        final firstColumnCell = find
            .descendant(
              of: find.ancestor(
                of: columnTitleOfPopup,
                matching: find.byType(PlutoGrid),
              ),
              matching: find.byType(PlutoBaseCell),
            )
            .first;

        final firstColumnTitle =
            (firstColumnCell.evaluate().first.widget as PlutoBaseCell)
                .cell
                .value;

        final headerCheckbox0 = find.descendant(
          of: firstColumnCell,
          matching: find.byType(PlutoScaledCheckbox),
        );

        await tester.tap(headerCheckbox0, warnIfMissed: false);

        await tester.pump();

        expect(stateManager.refColumns.length, 10);

        expect(
          stateManager.refColumns
              .where((e) => e.title == firstColumnTitle)
              .length,
          1,
        );
      },
    );

    withTenColumns.test(
      '모든 컬럼을 숨긴 상태에서 컬럼 설정 팝업의 전체 체크 박스를 탭하면 전체 컬럼이 나타나야 한다.',
      (tester) async {
        stateManager.hideColumns(stateManager.refColumns, true);

        await tester.pumpAndSettle();

        expect(stateManager.refColumns.length, 0);

        stateManager.showSetColumnsPopup(stateManager.gridFocusNode.context!);

        await tester.pumpAndSettle();

        final allCheckbox = find.descendant(
          of: find.byType(PlutoBaseColumn),
          matching: find.byType(PlutoScaledCheckbox),
        );

        await tester.tap(allCheckbox, warnIfMissed: false);

        await tester.pump();

        expect(stateManager.refColumns.length, 10);
      },
    );
  });

  group('숨김 컬럼이 없는 상태에서', () {
    List<PlutoColumn> columns;

    List<PlutoRow> rows;

    PlutoGridStateManager? stateManager;

    final withTenColumns = PlutoWidgetTestHelper(
      '10개의 컬럼을 생성하고 0, 5번 컬럼을 숨김',
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
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        stateManager!.hideColumn(columns[0], true, notify: false);
        stateManager!.hideColumn(columns[5], true);
      },
    );

    withTenColumns.test(
      'hideColumn 으로 header0 을 숨김 해제 하면 컬럼이 나타나야 한다.',
      (tester) async {
        var column = find.text('header0');

        expect(column, findsNothing);

        stateManager!.hideColumn(
          stateManager!.refColumns.originalList[0],
          false,
        );

        await tester.pumpAndSettle(const Duration(milliseconds: 300));

        expect(column, findsOneWidget);
      },
    );
  });
}
