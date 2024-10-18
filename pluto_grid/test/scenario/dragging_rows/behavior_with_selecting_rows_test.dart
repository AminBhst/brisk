import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helper/build_grid_helper.dart';
import '../../helper/column_helper.dart';

void main() {
  final grid = BuildGridHelper();

  final columns = ColumnHelper.textColumn('column', count: 1, start: 1);

  columns.first.enableRowDrag = true;

  grid
      .buildSelectedRows(
    numberOfRows: 10,
    startRowIdx: 3,
    endRowIdx: 5,
    columns: columns,
  )
      .test('선택되지 않은 행의 드래그 아이콘을 드래그 하면 선택 된 행이 무효화 되어야 한다.',
          (WidgetTester tester) async {
    final selectedCell = find.text(
      grid.stateManager.refRows[0].cells['column1']!.value,
    );

    final dragIcon = find.descendant(
      of: find.ancestor(of: selectedCell, matching: find.byType(Row)),
      matching: find.byType(Icon),
    );

    await tester.drag(dragIcon, const Offset(5, 5));

    await tester.pumpAndSettle();

    expect(grid.stateManager.currentSelectingRows.length, 0);
  });

  grid
      .buildSelectedRows(
    numberOfRows: 10,
    startRowIdx: 3,
    endRowIdx: 5,
    columns: columns,
  )
      .test('선택되지 않은 행의 드래그 아이콘을 드래그 하면 드래그 한 행이 이동 되어야 한다.',
          (WidgetTester tester) async {
    final dragRow = grid.stateManager.refRows[0];

    final movedRow = grid.stateManager.refRows[1];

    final selectedCell = find.text(
      dragRow.cells['column1']!.value,
    );

    final dragIcon = find.descendant(
      of: find.ancestor(of: selectedCell, matching: find.byType(Row)),
      matching: find.byType(Icon),
    );

    await tester.drag(dragIcon, Offset(5, grid.stateManager.columnHeight));

    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    expect(grid.stateManager.refRows[0], movedRow);

    expect(grid.stateManager.refRows[1], dragRow);

    expect(grid.stateManager.currentSelectingRows.length, 0);
  });

  grid
      .buildSelectedRows(
    numberOfRows: 10,
    startRowIdx: 3,
    endRowIdx: 5,
    columns: columns,
  )
      .test('선택된 행의 드래그 아이콘을 드래그 하면 선택 된 행이 유지 되어야 한다.',
          (WidgetTester tester) async {
    final selectedCell = find.text(
      grid.stateManager.currentSelectingRows[0].cells['column1']!.value,
    );

    final dragIcon = find.descendant(
      of: find.ancestor(of: selectedCell, matching: find.byType(Row)),
      matching: find.byType(Icon),
    );

    await tester.drag(dragIcon, const Offset(5, 5));

    await tester.pumpAndSettle();

    expect(grid.stateManager.currentSelectingRows.length, 3);
  });

  grid
      .buildSelectedRows(
    numberOfRows: 10,
    startRowIdx: 3,
    endRowIdx: 5,
    columns: columns,
  )
      .test(
          '선택 되지 않은 행의 드래그 아이콘을 길게 탭하여 드래그 하면, '
          '기존 선택이 무효화 되고 드래그 한 행이 선택되고 드래깅은 되지 않아야 한다.',
          (WidgetTester tester) async {
    final existsSelectingRows = [...grid.stateManager.currentSelectingRows];

    final dragRowCellValue =
        grid.stateManager.refRows[0].cells['column1']!.value;

    final targetRowCellValue =
        grid.stateManager.refRows[1].cells['column1']!.value;

    expect(dragRowCellValue, 'column1 value 1');

    expect(targetRowCellValue, 'column1 value 2');

    final dragRow = find.text(dragRowCellValue);

    final targetRow = find.text(targetRowCellValue);

    await grid.gesture.down(tester.getCenter(dragRow));

    await tester.longPress(dragRow);

    await grid.gesture.moveTo(
      tester.getCenter(targetRow),
      timeStamp: const Duration(milliseconds: 10),
    );

    await grid.gesture.up();

    await tester.pumpAndSettle();

    expect(grid.stateManager.currentSelectingRows.length, 2);

    expect(
      existsSelectingRows.contains(grid.stateManager.currentSelectingRows[0]),
      false,
    );

    expect(
      existsSelectingRows.contains(grid.stateManager.currentSelectingRows[1]),
      false,
    );

    expect(
      grid.stateManager.currentSelectingRows[0].cells['column1']!.value,
      dragRowCellValue,
    );

    expect(
      grid.stateManager.currentSelectingRows[1].cells['column1']!.value,
      targetRowCellValue,
    );
  });
}
