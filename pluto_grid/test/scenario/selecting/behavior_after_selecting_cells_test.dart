import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../helper/column_helper.dart';
import '../../helper/pluto_widget_test_helper.dart';
import '../../helper/row_helper.dart';

/// 셀 선택 상태 이후의 동작 테스트
void main() {
  late PlutoGridStateManager stateManager;

  buildRowsWithSelectingCellsFunction({
    required PlutoGridSelectingMode selectingMode,
  }) {
    return ({
      int numberOfRows = 10,
      int numberOfColumns = 10,
      int columnIdx = 0,
      int rowIdx = 0,
      int columnIdxToSelect = 1,
      int rowIdxToSelect = 0,
    }) {
      // given
      final columns = ColumnHelper.textColumn('header', count: numberOfColumns);
      final rows = RowHelper.count(numberOfRows, columns);

      return PlutoWidgetTestHelper(
        'build with selecting cells.',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Material(
                child: PlutoGrid(
                  columns: columns,
                  rows: rows,
                  onLoaded: (PlutoGridOnLoadedEvent event) {
                    stateManager = event.stateManager;
                    stateManager.setSelectingMode(selectingMode);

                    stateManager.setCurrentCell(
                      stateManager.rows[rowIdx].cells['header$columnIdx'],
                      rowIdx,
                    );

                    stateManager.setCurrentSelectingPosition(
                      cellPosition: PlutoGridCellPosition(
                        columnIdx: columnIdxToSelect,
                        rowIdx: rowIdxToSelect,
                      ),
                    );
                  },
                ),
              ),
            ),
          );

          expect(stateManager.currentCell, isNotNull);
          expect(stateManager.currentCellPosition!.columnIdx, columnIdx);
          expect(stateManager.currentCellPosition!.rowIdx, rowIdx);

          expect(stateManager.currentSelectingPosition, isNotNull);
          expect(stateManager.currentSelectingPosition!.columnIdx,
              columnIdxToSelect);
          expect(stateManager.currentSelectingPosition!.rowIdx, rowIdxToSelect);
        },
      );
    };
  }

  selectCellsFunction({
    buildRowsWithSelectingCells,
    int numberOfRows = 10,
    int numberOfColumns = 10,
    int columnIdx = 0,
    int rowIdx = 0,
    int columnIdxToSelect = 1,
    int rowIdxToSelect = 0,
  }) {
    return buildRowsWithSelectingCells(
      numberOfRows: numberOfRows,
      numberOfColumns: numberOfColumns,
      columnIdx: columnIdx,
      rowIdx: rowIdx,
      columnIdxToSelect: columnIdxToSelect,
      rowIdxToSelect: rowIdxToSelect,
    );
  }

  const PlutoGridSelectingMode selectingMode = PlutoGridSelectingMode.cell;

  final buildRowsWithSelectingCells = buildRowsWithSelectingCellsFunction(
    selectingMode: selectingMode,
  );

  group('(0, 1) 부터 (1, 2) 셀 선택', () {
    const countTotalRows = 10;
    const currentColumnIdx = 0;
    const currentRowIdx = 1;
    const columnIdxToSelect = 1;
    const rowIdxToSelect = 2;

    selectCellsFunction(
      buildRowsWithSelectingCells: buildRowsWithSelectingCells,
      numberOfRows: countTotalRows,
      columnIdx: currentColumnIdx,
      rowIdx: currentRowIdx,
      columnIdxToSelect: columnIdxToSelect,
      rowIdxToSelect: rowIdxToSelect,
    ).test(
      '0번 행에 새로운 행을 추가하면, '
      '선택 된 셀이 (0, 2), (1, 3) 로 변경 되어야 한다.',
      (tester) async {
        // before
        expect(stateManager.currentCellPosition!.columnIdx, currentColumnIdx);
        expect(stateManager.currentCellPosition!.rowIdx, currentRowIdx);

        expect(stateManager.currentSelectingPosition!.columnIdx,
            columnIdxToSelect);
        expect(stateManager.currentSelectingPosition!.rowIdx, rowIdxToSelect);

        final rowToInsert = stateManager.getNewRow();

        stateManager.insertRows(0, [rowToInsert]);

        // after
        expect(stateManager.currentCellPosition!.columnIdx, 0);
        expect(stateManager.currentCellPosition!.rowIdx, 2);

        expect(stateManager.currentSelectingPosition!.columnIdx, 1);
        expect(stateManager.currentSelectingPosition!.rowIdx, 3);
      },
    );

    selectCellsFunction(
      buildRowsWithSelectingCells: buildRowsWithSelectingCells,
      numberOfRows: countTotalRows,
      columnIdx: currentColumnIdx,
      rowIdx: currentRowIdx,
      columnIdxToSelect: columnIdxToSelect,
      rowIdxToSelect: rowIdxToSelect,
    ).test(
      '0번 행을 삭제 하면, '
      '선택 된 셀이 (0, 0), (1, 1) 로 변경 되어야 한다.',
      (tester) async {
        // before
        expect(stateManager.currentCellPosition!.columnIdx, currentColumnIdx);
        expect(stateManager.currentCellPosition!.rowIdx, currentRowIdx);

        expect(stateManager.currentSelectingPosition!.columnIdx,
            columnIdxToSelect);
        expect(stateManager.currentSelectingPosition!.rowIdx, rowIdxToSelect);

        final rowToDelete = stateManager.rows.first;

        stateManager.removeRows([rowToDelete]);

        // after
        expect(stateManager.currentCellPosition!.columnIdx, 0);
        expect(stateManager.currentCellPosition!.rowIdx, 0);

        expect(stateManager.currentSelectingPosition!.columnIdx, 1);
        expect(stateManager.currentSelectingPosition!.rowIdx, 1);
      },
    );
  });

  group('전체 셀을 선택', () {
    const countTotalRows = 10;
    const countTotalColumns = 10;
    const currentColumnIdx = 0;
    const currentRowIdx = 0;
    const columnIdxToSelect = 9;
    const rowIdxToSelect = 9;

    selectCellsFunction(
      buildRowsWithSelectingCells: buildRowsWithSelectingCells,
      numberOfRows: countTotalRows,
      numberOfColumns: countTotalColumns,
      columnIdx: currentColumnIdx,
      rowIdx: currentRowIdx,
      columnIdxToSelect: columnIdxToSelect,
      rowIdxToSelect: rowIdxToSelect,
    ).test(
      '선택 된 행을 마지막 행부터 차례대로 삭제.',
      (tester) async {
        expect(stateManager.rows.length, 10);

        getLastRow() {
          return stateManager.rows.last;
        }

        stateManager.removeRows([getLastRow()]);
        expect(stateManager.rows.length, 9);

        stateManager.removeRows([getLastRow()]);
        expect(stateManager.rows.length, 8);
      },
    );
  });
}
