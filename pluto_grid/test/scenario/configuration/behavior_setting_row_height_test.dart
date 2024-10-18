import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:pluto_grid/src/ui/ui.dart';

import '../../helper/column_helper.dart';
import '../../helper/pluto_widget_test_helper.dart';
import '../../helper/row_helper.dart';

/// 행 높이 설정 후 동작 테스트
void main() {
  const PlutoGridSelectingMode selectingMode = PlutoGridSelectingMode.row;

  PlutoGridStateManager? stateManager;

  buildRowsWithSettingRowHeight({
    int numberOfRows = 10,
    List<PlutoColumn>? columns,
    int columnIdx = 0,
    int rowIdx = 0,
    double rowHeight = 45.0,
  }) {
    // given
    final safetyColumns =
        columns ?? ColumnHelper.textColumn('header', count: 10);
    final rows = RowHelper.count(numberOfRows, safetyColumns);

    return PlutoWidgetTestHelper(
      'build with setting row height.',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Material(
              child: PlutoGrid(
                columns: safetyColumns,
                rows: rows,
                onLoaded: (PlutoGridOnLoadedEvent event) {
                  stateManager = event.stateManager;
                  stateManager!.setSelectingMode(selectingMode);

                  stateManager!.setCurrentCell(
                    stateManager!.rows[rowIdx].cells['header$columnIdx'],
                    rowIdx,
                  );
                },
                configuration: PlutoGridConfiguration(
                  style: PlutoGridStyleConfig(
                    rowHeight: rowHeight,
                  ),
                ),
              ),
            ),
          ),
        );

        expect(stateManager!.currentCell, isNotNull);
        expect(stateManager!.currentCellPosition!.columnIdx, columnIdx);
        expect(stateManager!.currentCellPosition!.rowIdx, rowIdx);
      },
    );
  }

  group('state', () {
    const rowHeight = 90.0;

    buildRowsWithSettingRowHeight(rowHeight: rowHeight).test(
      'rowHeight 를 90으로 설정 하면, '
      'rowTotalHeight 값이 90 + PlutoDefaultSettings.rowBorderWidth 이어야 한다.',
      (tester) async {
        expect(
          stateManager!.rowTotalHeight,
          rowHeight + PlutoGridSettings.rowBorderWidth,
        );
      },
    );
  });

  group('widget', () {
    const rowHeight = 90.0;

    buildRowsWithSettingRowHeight(rowHeight: rowHeight).test(
      'CellWidget 의 높이가 설정 한 높이 값을 가져야 한다.',
      (tester) async {
        final Size cellSize = tester.getSize(find.byType(PlutoBaseCell).first);

        expect(cellSize.height, rowHeight);
      },
    );

    buildRowsWithSettingRowHeight(
      rowHeight: rowHeight,
      columns: [
        PlutoColumn(
            title: 'header',
            field: 'header0',
            type: PlutoColumnType.select(<String>['one', 'two', 'three'])),
      ],
    ).test(
      'CellWidget 의 높이를 설정하면 selectColumn 의 팝업의 셀 높이는 '
      '설정한 값으로 설정 되어야 한다.',
      (tester) async {
        // Editing 상태로 설정
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        expect(stateManager!.isEditing, isTrue);

        // select 팝업 호출
        await tester.pumpAndSettle(const Duration(milliseconds: 300));
        await tester.sendKeyEvent(LogicalKeyboardKey.f2);
        await tester.pumpAndSettle(const Duration(milliseconds: 300));

        final popupGrid = find.byType(PlutoGrid).last;

        final Size cellPopupSize = tester.getSize(find
            .descendant(of: popupGrid, matching: find.byType(PlutoBaseCell))
            .first);

        // select 팝업 높이 확인
        expect(cellPopupSize.height, rowHeight);
      },
    );

    buildRowsWithSettingRowHeight(
      rowHeight: rowHeight,
      columns: ColumnHelper.dateColumn('header', count: 10),
    ).test(
      'CellWidget 의 높이를 설정하면 dateColumn 의 팝업의 셀 높이는 '
      '설정한 값으로 설정 되어야 한다.',
      (tester) async {
        // Editing 상태로 설정
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        expect(stateManager!.isEditing, isTrue);

        // date 팝업 호출
        await tester.pumpAndSettle(const Duration(milliseconds: 300));
        await tester.sendKeyEvent(LogicalKeyboardKey.f2);
        await tester.pumpAndSettle(const Duration(milliseconds: 300));

        final sundayColumn =
            find.text(stateManager!.configuration.localeText.sunday);

        expect(
          sundayColumn,
          findsOneWidget,
        );

        // date 팝업의 CellWidget 높이 확인
        final parent =
            find.ancestor(of: sundayColumn, matching: find.byType(PlutoGrid));

        final Size cellSize = tester.getSize(find
            .descendant(of: parent, matching: find.byType(PlutoBaseCell))
            .first);

        expect(cellSize.height, rowHeight);
      },
    );

    buildRowsWithSettingRowHeight(
      rowHeight: rowHeight,
      columns: ColumnHelper.timeColumn('header', count: 10),
    ).test(
      'CellWidget 의 높이를 설정하면 timeColumn 의 팝업의 셀 높이는 '
      '설정한 값으로 설정 되어야 한다.',
      (tester) async {
        // Editing 상태로 설정
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        expect(stateManager!.isEditing, isTrue);

        // time 팝업 호출
        await tester.pumpAndSettle(const Duration(milliseconds: 300));
        await tester.sendKeyEvent(LogicalKeyboardKey.f2);
        await tester.pumpAndSettle(const Duration(milliseconds: 300));

        final hourColumn =
            find.text(stateManager!.configuration.localeText.hour);

        expect(
          hourColumn,
          findsOneWidget,
        );

        // time 팝업의 CellWidget 높이 확인
        final parent =
            find.ancestor(of: hourColumn, matching: find.byType(PlutoGrid));

        final Size cellSize = tester.getSize(find
            .descendant(of: parent, matching: find.byType(PlutoBaseCell))
            .first);

        expect(cellSize.height, rowHeight);
      },
    );
  });
}
