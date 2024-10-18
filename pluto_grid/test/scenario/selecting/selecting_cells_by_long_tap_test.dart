import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../helper/build_grid_helper.dart';

void main() {
  final grid = BuildGridHelper();

  group('PlutoGridSelectingMode.cell', () {
    final fiveByFiveGrid = grid.build(
      numberOfColumns: 5,
      numberOfRows: 5,
      startColumnIndex: 0,
      selectingMode: PlutoGridSelectingMode.cell,
    );

    fiveByFiveGrid.test(
      '(1, 1), (2, 4) 셀을 선택하면, 8개의 셀이 선택 되어야 한다.',
      (tester) async {
        await grid.selectCells(
          startCellValue: 'column1 value 1',
          endCellValue: 'column2 value 4',
          tester: tester,
        );

        final selected = [
          // @formatter:off
          ['column1', 1], ['column2', 1],
          ['column1', 2], ['column2', 2],
          ['column1', 3], ['column2', 3],
          ['column1', 4], ['column2', 4],
          // @formatter:on
        ];

        final length = grid.stateManager.currentSelectingPositionList.length;

        expect(length, 8);

        for (int i = 0; i < length; i += 1) {
          expect(
            grid.stateManager.currentSelectingPositionList[i],
            PlutoGridSelectingCellPosition(
              field: selected[i][0] as String,
              rowIdx: selected[i][1] as int,
            ),
          );
        }
      },
    );

    fiveByFiveGrid.test(
      '(1, 1), (2, 1) 셀을 선택하면, 2개의 셀이 선택 되어야 한다.',
      (tester) async {
        await grid.selectCells(
          startCellValue: 'column1 value 1',
          endCellValue: 'column2 value 1',
          tester: tester,
        );

        final selected = [
          // @formatter:off
          ['column1', 1], ['column2', 1],
          ['column1', 2], ['column2', 2],
          // @formatter:on
        ];

        final length = grid.stateManager.currentSelectingPositionList.length;

        expect(length, 2);

        for (int i = 0; i < length; i += 1) {
          expect(
            grid.stateManager.currentSelectingPositionList[i],
            PlutoGridSelectingCellPosition(
              field: selected[i][0] as String,
              rowIdx: selected[i][1] as int,
            ),
          );
        }
      },
    );
  });

  group('PlutoGridSelectingMode.horizontal', () {
    final fiveByFiveGrid = grid.build(
      numberOfColumns: 5,
      numberOfRows: 5,
      startColumnIndex: 0,
      selectingMode: PlutoGridSelectingMode.horizontal,
    );

    fiveByFiveGrid.test(
      '(1, 0), (0, 1) 셀을 선택하면, 5개의 셀이 선택 되어야 한다.',
      (tester) async {
        await grid.selectCells(
          startCellValue: 'column1 value 0',
          endCellValue: 'column0 value 1',
          tester: tester,
        );

        final selected = [
          // @formatter:off
          ['column1', 0], ['column2', 0], ['column3', 0], ['column4', 0],
          ['column0', 1],
          // @formatter:on
        ];

        final length = grid.stateManager.currentSelectingPositionList.length;

        expect(length, 5);

        for (int i = 0; i < length; i += 1) {
          expect(
            grid.stateManager.currentSelectingPositionList[i],
            PlutoGridSelectingCellPosition(
              field: selected[i][0] as String,
              rowIdx: selected[i][1] as int,
            ),
          );
        }
      },
    );

    fiveByFiveGrid.test(
      '(0, 1), (1, 0) 셀을 선택하면, 5개의 셀이 선택 되어야 한다.',
      (tester) async {
        await grid.selectCells(
          startCellValue: 'column0 value 1',
          endCellValue: 'column1 value 0',
          tester: tester,
        );

        final selected = [
          // @formatter:off
          ['column1', 0], ['column2', 0], ['column3', 0], ['column4', 0],
          ['column0', 1],
          // @formatter:on
        ];

        final length = grid.stateManager.currentSelectingPositionList.length;

        expect(length, 5);

        for (int i = 0; i < length; i += 1) {
          expect(
            grid.stateManager.currentSelectingPositionList[i],
            PlutoGridSelectingCellPosition(
              field: selected[i][0] as String,
              rowIdx: selected[i][1] as int,
            ),
          );
        }
      },
    );

    fiveByFiveGrid.test(
      '(0, 1), (0, 1) 셀을 선택하면, 1개의 셀이 선택 되어야 한다.',
      (tester) async {
        await grid.selectCells(
          startCellValue: 'column0 value 1',
          endCellValue: 'column0 value 1',
          tester: tester,
        );

        final selected = [
          // @formatter:off
          ['column0', 1],
          // @formatter:on
        ];

        final length = grid.stateManager.currentSelectingPositionList.length;

        expect(length, 1);

        for (int i = 0; i < length; i += 1) {
          expect(
            grid.stateManager.currentSelectingPositionList[i],
            PlutoGridSelectingCellPosition(
              field: selected[i][0] as String,
              rowIdx: selected[i][1] as int,
            ),
          );
        }
      },
    );

    fiveByFiveGrid.test(
      '(0, 1), (1, 1) 셀을 선택하면, 2개의 셀이 선택 되어야 한다.',
      (tester) async {
        await grid.selectCells(
          startCellValue: 'column0 value 1',
          endCellValue: 'column1 value 1',
          tester: tester,
        );

        final selected = [
          // @formatter:off
          ['column0', 1], ['column1', 1],
          // @formatter:on
        ];

        final length = grid.stateManager.currentSelectingPositionList.length;

        expect(length, 2);

        for (int i = 0; i < length; i += 1) {
          expect(
            grid.stateManager.currentSelectingPositionList[i],
            PlutoGridSelectingCellPosition(
              field: selected[i][0] as String,
              rowIdx: selected[i][1] as int,
            ),
          );
        }
      },
    );

    fiveByFiveGrid.test(
      '(1, 1), (0, 1) 셀을 선택하면, 2개의 셀이 선택 되어야 한다.',
      (tester) async {
        await grid.selectCells(
          startCellValue: 'column1 value 1',
          endCellValue: 'column0 value 1',
          tester: tester,
        );

        final selected = [
          // @formatter:off
          ['column0', 1], ['column1', 1],
          // @formatter:on
        ];

        final length = grid.stateManager.currentSelectingPositionList.length;

        expect(length, 2);

        for (int i = 0; i < length; i += 1) {
          expect(
            grid.stateManager.currentSelectingPositionList[i],
            PlutoGridSelectingCellPosition(
              field: selected[i][0] as String,
              rowIdx: selected[i][1] as int,
            ),
          );
        }
      },
    );
  });
}
