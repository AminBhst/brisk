import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'column_helper.dart';
import 'pluto_widget_test_helper.dart';
import 'row_helper.dart';

class BuildGridHelper {
  late PlutoGridStateManager stateManager;

  late TestGesture gesture;

  Future<void> selectRows({
    String columnTitle = 'column',
    required int startRowIdx,
    required int endRowIdx,
    required WidgetTester tester,
  }) async {
    final startRow = find.text('$columnTitle value $startRowIdx');

    final targetRow = find.text('$columnTitle value $endRowIdx');

    final startPosition = tester.getCenter(startRow);

    final targetPosition = tester.getCenter(targetRow);

    gesture = await tester.startGesture(startPosition);

    await tester.longPress(startRow);

    await gesture.moveTo(
      targetPosition,
      timeStamp: const Duration(milliseconds: 10),
    );

    await gesture.up();

    await tester.pumpAndSettle();
  }

  Future<void> selectCells({
    required String startCellValue,
    required String endCellValue,
    required WidgetTester tester,
  }) async {
    final startCell = find.text(startCellValue);

    final targetCell = find.text(endCellValue);

    final startPosition = tester.getCenter(startCell);

    final targetPosition = tester.getCenter(targetCell);

    gesture = await tester.startGesture(startPosition);

    await tester.longPress(startCell);

    await gesture.moveTo(
      targetPosition,
      timeStamp: const Duration(milliseconds: 10),
    );

    await gesture.up();

    await tester.pumpAndSettle();
  }

  PlutoWidgetTestHelper buildSelectedRows({
    required int numberOfRows,
    required int startRowIdx,
    required int endRowIdx,
    List<PlutoColumn>? columns,
    List<PlutoRow>? rows,
    int numberOfColumns = 1,
    int startColumnIndex = 1,
    String columnName = 'column',
  }) {
    // given
    final safetyColumns = columns ??
        ColumnHelper.textColumn(
          columnName,
          count: numberOfColumns,
          start: startColumnIndex,
        );

    final safetyRows = rows ??
        RowHelper.count(
          numberOfRows,
          safetyColumns,
          start: startColumnIndex,
        );

    return PlutoWidgetTestHelper(
      'build with selecting rows.',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Material(
              child: PlutoGrid(
                columns: safetyColumns,
                rows: safetyRows,
                onLoaded: (PlutoGridOnLoadedEvent event) {
                  stateManager = event.stateManager;
                  stateManager.setSelectingMode(PlutoGridSelectingMode.row);
                },
              ),
            ),
          ),
        );

        await tester.pump();

        await selectRows(
          startRowIdx: startRowIdx,
          endRowIdx: endRowIdx,
          tester: tester,
          columnTitle: '$columnName$startColumnIndex',
        );

        final length = (startRowIdx - endRowIdx).abs() + 1;

        expect(stateManager.currentSelectingRows.length, length);
      },
    );
  }

  PlutoWidgetTestHelper build({
    List<PlutoColumn>? columns,
    List<PlutoRow>? rows,
    int numberOfColumns = 1,
    int numberOfRows = 1,
    int startColumnIndex = 1,
    String columnName = 'column',
    PlutoGridSelectingMode selectingMode = PlutoGridSelectingMode.none,
  }) {
    // given
    final safetyColumns = columns ??
        ColumnHelper.textColumn(
          columnName,
          count: numberOfColumns,
          start: startColumnIndex,
        );

    final safetyRows = rows ??
        RowHelper.count(
          numberOfRows,
          safetyColumns,
          start: startColumnIndex,
        );

    return PlutoWidgetTestHelper(
      'build with selecting rows.',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Material(
              child: PlutoGrid(
                columns: safetyColumns,
                rows: safetyRows,
                onLoaded: (PlutoGridOnLoadedEvent event) {
                  stateManager = event.stateManager;
                  stateManager.setSelectingMode(selectingMode);
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
