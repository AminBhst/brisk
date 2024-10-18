import 'package:flutter_test/flutter_test.dart';

import '../../helper/build_grid_helper.dart';

void main() {
  final grid = BuildGridHelper();

  const columnTitle = 'column1';

  group('10개 행이 있는 상태에서 3~5번 행을 선택 한 후, ', () {
    selectRowsFrom3To5(
      String description,
      Future<void> Function(WidgetTester tester) testWithSelectedRowsFrom3To5,
    ) {
      const numberOfRows = 10;
      const startRowIdx = 3;
      const endRowIdx = 5;

      grid
          .buildSelectedRows(
        numberOfRows: numberOfRows,
        startRowIdx: startRowIdx,
        endRowIdx: endRowIdx,
      )
          .test(description, (tester) async {
        await testWithSelectedRowsFrom3To5(tester);
      });
    }

    selectRowsFrom3To5(
      '다른 행을 탭하면 이전 선택 된 행이 무효화 되어야 한다.',
      (tester) async {
        final nonSelectedRow = grid.stateManager.refRows[0];

        final nonSelectedRowWidget = find.text(
          nonSelectedRow.cells[columnTitle]!.value,
        );

        expect(grid.stateManager.isSelectedRow(nonSelectedRow.key), false);

        await tester.tap(nonSelectedRowWidget);

        expect(grid.stateManager.currentSelectingRows.length, 0);
      },
    );

    selectRowsFrom3To5(
      '다른 행을 길게 탭하면 이전의 선택 된 행이 무효화 되고 길게 탭한 행이 선택 되어야 한다.',
      (tester) async {
        await grid.selectRows(
          columnTitle: columnTitle,
          startRowIdx: 1,
          endRowIdx: 1,
          tester: tester,
        );

        expect(grid.stateManager.currentSelectingRows.length, 1);

        expect(
          grid.stateManager.currentSelectingRows[0],
          grid.stateManager.refRows[0],
        );
      },
    );

    selectRowsFrom3To5(
      'setCurrentCell 로 현재 셀을 변경 하면 선택 된 행들이 무효화 되어야 한다.',
      (tester) async {
        final cell = grid.stateManager.refRows[8].cells[columnTitle];

        expect(grid.stateManager.isCurrentCell(cell), false);

        grid.stateManager.setCurrentCell(cell, 8);

        await tester.pumpAndSettle();

        expect(grid.stateManager.isCurrentCell(cell), true);

        expect(grid.stateManager.currentSelectingRows.length, 0);
      },
    );

    selectRowsFrom3To5(
      '탭하여 현재 셀을 변경 하면 선택 된 행들이 무효화 되어야 한다.',
      (tester) async {
        final cell = grid.stateManager.refRows[7].cells[columnTitle];

        await tester.tap(find.text(cell!.value));

        await tester.pumpAndSettle();

        expect(grid.stateManager.isCurrentCell(cell), true);

        expect(grid.stateManager.currentSelectingRows.length, 0);
      },
    );

    selectRowsFrom3To5(
      'setEditing 으로 편집상태로 변경 하면 선택 된 행들이 무효화 되어야 한다.',
      (tester) async {
        final currentCell = grid.stateManager.currentCell;

        expect(currentCell, isNotNull);

        grid.stateManager.setEditing(true);

        await tester.pumpAndSettle();

        expect(grid.stateManager.currentSelectingRows.length, 0);
      },
    );

    selectRowsFrom3To5(
      '현재 셀을 탭하여 편집상태로 변경 하면 선택 된 행들이 무효화 되어야 한다.',
      (tester) async {
        expect(grid.stateManager.isEditing, false);

        final currentCell = grid.stateManager.currentCell;

        expect(currentCell, isNotNull);

        await tester.tap(find.text(currentCell!.value));

        await tester.tap(find.text(currentCell.value));

        expect(grid.stateManager.isEditing, true);

        expect(grid.stateManager.currentSelectingRows.length, 0);
      },
    );
  });
}
