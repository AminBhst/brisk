import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../helper/column_helper.dart';
import '../../../helper/pluto_widget_test_helper.dart';
import '../../../helper/row_helper.dart';
import '../../../mock/shared_mocks.mocks.dart';

void main() {
  late List<PlutoColumn> columns;

  late List<PlutoRow> rows;

  PlutoGridScrollController scrollController;

  PlutoGridEventManager eventManager;

  LinkedScrollControllerGroup horizontal;

  LinkedScrollControllerGroup vertical;

  late PlutoGridStateManager stateManager;

  final withColumnAndRows =
      PlutoWidgetTestHelper('컬럼 10개와 행 10개 인 상태에서, ', (tester) async {
    columns = [
      ...ColumnHelper.textColumn('column', count: 10, width: 100),
    ];

    rows = RowHelper.count(10, columns);

    scrollController = MockPlutoGridScrollController();

    eventManager = MockPlutoGridEventManager();

    horizontal = MockLinkedScrollControllerGroup();

    vertical = MockLinkedScrollControllerGroup();

    when(scrollController.verticalOffset).thenReturn(100);

    when(scrollController.maxScrollHorizontal).thenReturn(0);

    when(scrollController.maxScrollVertical).thenReturn(0);

    when(scrollController.horizontal).thenReturn(horizontal);

    when(scrollController.vertical).thenReturn(vertical);

    stateManager = PlutoGridStateManager(
      columns: columns,
      rows: rows,
      gridFocusNode: MockFocusNode(),
      scroll: scrollController,
    );

    stateManager.setEventManager(eventManager);
    stateManager.setLayout(const BoxConstraints(maxWidth: 500, maxHeight: 500));
  });

  group('moveCurrentCellToEdgeOfColumns', () {
    withColumnAndRows.test(
      'PlutoMoveDirection 이 Up 이면 셀이 선택 되지 않아야 한다.',
      (tester) async {
        stateManager.moveCurrentCellToEdgeOfColumns(PlutoMoveDirection.up);

        expect(stateManager.currentCell, isNull);
      },
    );

    withColumnAndRows.test(
      'PlutoMoveDirection 이 Down 이면 셀이 선택 되지 않아야 한다.',
      (tester) async {
        stateManager.moveCurrentCellToEdgeOfColumns(PlutoMoveDirection.down);

        expect(stateManager.currentCell, isNull);
      },
    );

    withColumnAndRows.test(
      'currentCell 이 null 이면 셀이 선택 되지 않아야 한다.',
      (tester) async {
        expect(stateManager.currentCell, isNull);

        stateManager.moveCurrentCellToEdgeOfColumns(PlutoMoveDirection.left);

        expect(stateManager.currentCell, isNull);
      },
    );

    withColumnAndRows.test(
      'isEditing 이 true 면 셀이 이동 되지 않아야 한다.',
      (tester) async {
        stateManager.setCurrentCell(stateManager.firstCell, 0);

        stateManager.setEditing(true);

        expect(stateManager.isEditing, isTrue);

        expect(stateManager.currentCellPosition!.columnIdx, 0);
        expect(stateManager.currentCellPosition!.rowIdx, 0);

        stateManager.moveCurrentCellToEdgeOfColumns(PlutoMoveDirection.right);

        expect(stateManager.currentCellPosition!.columnIdx, 0);
        expect(stateManager.currentCellPosition!.rowIdx, 0);
      },
    );

    withColumnAndRows.test(
      'isEditing 이 true 라도 force 가 true 면 셀이 이동 되어야 한다.',
      (tester) async {
        stateManager.setCurrentCell(stateManager.firstCell, 0);

        stateManager.setEditing(true);

        expect(stateManager.isEditing, isTrue);

        expect(stateManager.currentCellPosition!.columnIdx, 0);
        expect(stateManager.currentCellPosition!.rowIdx, 0);

        stateManager.moveCurrentCellToEdgeOfColumns(
          PlutoMoveDirection.right,
          force: true,
        );

        expect(stateManager.currentCellPosition!.columnIdx, 9);
        expect(stateManager.currentCellPosition!.rowIdx, 0);
      },
    );

    withColumnAndRows.test(
      'PlutoMoveDirection 이 Left 면 왼쪽 끝으로 이동 해야 한다.',
      (tester) async {
        stateManager.setCurrentCell(rows.first.cells['column3'], 0);

        stateManager.setEditing(false);

        expect(stateManager.isEditing, isFalse);

        expect(stateManager.currentCellPosition!.columnIdx, 3);
        expect(stateManager.currentCellPosition!.rowIdx, 0);

        stateManager.moveCurrentCellToEdgeOfColumns(
          PlutoMoveDirection.left,
        );

        expect(stateManager.currentCellPosition!.columnIdx, 0);
        expect(stateManager.currentCellPosition!.rowIdx, 0);
      },
    );

    withColumnAndRows.test(
      'PlutoMoveDirection 이 Right 면 오른쪽 끝으로 이동 해야 한다.',
      (tester) async {
        stateManager.setCurrentCell(rows.first.cells['column3'], 0);

        stateManager.setEditing(false);

        expect(stateManager.isEditing, isFalse);

        expect(stateManager.currentCellPosition!.columnIdx, 3);
        expect(stateManager.currentCellPosition!.rowIdx, 0);

        stateManager.moveCurrentCellToEdgeOfColumns(
          PlutoMoveDirection.right,
        );

        expect(stateManager.currentCellPosition!.columnIdx, 9);
        expect(stateManager.currentCellPosition!.rowIdx, 0);
      },
    );
  });

  group('moveCurrentCellToEdgeOfRows', () {
    withColumnAndRows.test(
      'PlutoMoveDirection 이 Left 이면 셀이 선택 되지 않아야 한다.',
      (tester) async {
        stateManager.moveCurrentCellToEdgeOfRows(PlutoMoveDirection.left);

        expect(stateManager.currentCell, isNull);
      },
    );

    withColumnAndRows.test(
      'PlutoMoveDirection 이 Right 이면 셀이 선택 되지 않아야 한다.',
      (tester) async {
        stateManager.moveCurrentCellToEdgeOfRows(PlutoMoveDirection.right);

        expect(stateManager.currentCell, isNull);
      },
    );

    withColumnAndRows.test(
      'isEditing 이 true 면 셀이 이동 되지 않아야 한다.',
      (tester) async {
        stateManager.setCurrentCell(stateManager.firstCell, 0);

        stateManager.setEditing(true);

        expect(stateManager.isEditing, isTrue);

        expect(stateManager.currentCellPosition!.columnIdx, 0);
        expect(stateManager.currentCellPosition!.rowIdx, 0);

        stateManager.moveCurrentCellToEdgeOfRows(PlutoMoveDirection.down);

        expect(stateManager.currentCellPosition!.columnIdx, 0);
        expect(stateManager.currentCellPosition!.rowIdx, 0);
      },
    );

    withColumnAndRows.test(
      'isEditing 이 true 라도 force 가 true 면 셀이 이동 되어야 한다.',
      (tester) async {
        stateManager.setCurrentCell(stateManager.firstCell, 0);

        stateManager.setEditing(true);

        expect(stateManager.isEditing, isTrue);

        expect(stateManager.currentCellPosition!.columnIdx, 0);
        expect(stateManager.currentCellPosition!.rowIdx, 0);

        stateManager.moveCurrentCellToEdgeOfRows(
          PlutoMoveDirection.down,
          force: true,
        );

        expect(stateManager.currentCellPosition!.columnIdx, 0);
        expect(stateManager.currentCellPosition!.rowIdx, 9);
      },
    );

    withColumnAndRows.test(
      'PlutoMoveDirection 이 Up 이면 맨 위 Row 로 이동 되어야 한다.',
      (tester) async {
        stateManager.setCurrentCell(stateManager.rows[4].cells['column7'], 4);

        stateManager.setEditing(false);

        expect(stateManager.isEditing, isFalse);

        expect(stateManager.currentCellPosition!.columnIdx, 7);
        expect(stateManager.currentCellPosition!.rowIdx, 4);

        stateManager.moveCurrentCellToEdgeOfRows(
          PlutoMoveDirection.up,
        );

        expect(stateManager.currentCellPosition!.columnIdx, 7);
        expect(stateManager.currentCellPosition!.rowIdx, 0);
      },
    );

    withColumnAndRows.test(
      'PlutoMoveDirection 이 Down 이면 맨 아래 Row 로 이동 되어야 한다.',
      (tester) async {
        stateManager.setCurrentCell(stateManager.rows[4].cells['column7'], 4);

        stateManager.setEditing(false);

        expect(stateManager.isEditing, isFalse);

        expect(stateManager.currentCellPosition!.columnIdx, 7);
        expect(stateManager.currentCellPosition!.rowIdx, 4);

        stateManager.moveCurrentCellToEdgeOfRows(
          PlutoMoveDirection.down,
        );

        expect(stateManager.currentCellPosition!.columnIdx, 7);
        expect(stateManager.currentCellPosition!.rowIdx, 9);
      },
    );
  });

  group('moveCurrentCellByRowIdx', () {
    withColumnAndRows.test(
      'PlutoMoveDirection 이 Left 이면 셀이 선택 되지 않아야 한다.',
      (tester) async {
        stateManager.moveCurrentCellByRowIdx(0, PlutoMoveDirection.left);

        expect(stateManager.currentCell, isNull);
      },
    );

    withColumnAndRows.test(
      'PlutoMoveDirection 이 Right 이면 셀이 선택 되지 않아야 한다.',
      (tester) async {
        stateManager.moveCurrentCellByRowIdx(0, PlutoMoveDirection.right);

        expect(stateManager.currentCell, isNull);
      },
    );

    withColumnAndRows.test(
      'rowIdx 가 0보다 작으면 0번 행으로 이동 되어야 한다.',
      (tester) async {
        stateManager.moveCurrentCellByRowIdx(-1, PlutoMoveDirection.down);

        expect(stateManager.currentCellPosition!.rowIdx, 0);
        expect(stateManager.currentCellPosition!.columnIdx, 0);
      },
    );

    withColumnAndRows.test(
      'rowIdx 가 전체 행 인덱스보다 많으면 마지막 행으로 이동 되어야 한다.',
      (tester) async {
        stateManager.moveCurrentCellByRowIdx(11, PlutoMoveDirection.down);

        expect(stateManager.currentCellPosition!.rowIdx, 9);
        expect(stateManager.currentCellPosition!.columnIdx, 0);
      },
    );
  });

  group('moveSelectingCellToEdgeOfColumns', () {
    withColumnAndRows.test(
      'PlutoMoveDirection 이 Up 이면 셀이 선택 되지 않아야 한다.',
      (tester) async {
        stateManager.moveSelectingCellToEdgeOfColumns(PlutoMoveDirection.up);

        expect(stateManager.currentSelectingPosition, isNull);
      },
    );

    withColumnAndRows.test(
      'PlutoMoveDirection 이 Down 이면 셀이 선택 되지 않아야 한다.',
      (tester) async {
        stateManager.moveSelectingCellToEdgeOfColumns(PlutoMoveDirection.down);

        expect(stateManager.currentSelectingPosition, isNull);
      },
    );

    withColumnAndRows.test(
      'isEditing 이 true 면 셀이 선택 되지 않아야 한다.',
      (tester) async {
        stateManager.setCurrentCell(stateManager.firstCell, 0);

        stateManager.setEditing(true);

        expect(stateManager.isEditing, isTrue);

        expect(stateManager.currentSelectingPosition, isNull);

        stateManager.moveSelectingCellToEdgeOfColumns(PlutoMoveDirection.right);

        expect(stateManager.currentSelectingPosition, isNull);
      },
    );

    withColumnAndRows.test(
      'isEditing 이 true 라도 force 가 true 면 셀이 선택 되어야 한다.',
      (tester) async {
        stateManager.setCurrentCell(stateManager.firstCell, 0);

        stateManager.setEditing(true);

        expect(stateManager.isEditing, isTrue);

        expect(stateManager.currentSelectingPosition, isNull);

        stateManager.moveSelectingCellToEdgeOfColumns(
          PlutoMoveDirection.right,
          force: true,
        );

        expect(stateManager.currentSelectingPosition, isNotNull);
        expect(stateManager.currentSelectingPosition!.columnIdx, 9);
        expect(stateManager.currentSelectingPosition!.rowIdx, 0);
      },
    );

    withColumnAndRows.test(
      'PlutoMoveDirection 이 Left 면 현재 셀 부터 왼쪽 끝까지 선택 되어야 한다.',
      (tester) async {
        stateManager.setCurrentCell(stateManager.rows[0].cells['column3'], 0);

        stateManager.setEditing(false);

        expect(stateManager.isEditing, isFalse);

        expect(stateManager.currentSelectingPosition, isNull);

        stateManager.moveSelectingCellToEdgeOfColumns(
          PlutoMoveDirection.left,
        );

        expect(stateManager.currentCellPosition!.rowIdx, 0);
        expect(stateManager.currentCellPosition!.columnIdx, 3);

        expect(stateManager.currentSelectingPosition, isNotNull);
        expect(stateManager.currentSelectingPosition!.columnIdx, 0);
        expect(stateManager.currentSelectingPosition!.rowIdx, 0);
      },
    );

    withColumnAndRows.test(
      'PlutoMoveDirection 이 Left 이고 현재 선택 된 셀이 있다면 선택 된 셀이 왼쪽 끝으로 변경 되어야 한다.',
      (tester) async {
        stateManager.setCurrentCell(stateManager.rows[0].cells['column3'], 0);

        stateManager.setEditing(false);

        expect(stateManager.isEditing, isFalse);

        stateManager.setCurrentSelectingPosition(
          cellPosition: const PlutoGridCellPosition(
            columnIdx: 2,
            rowIdx: 0,
          ),
        );

        expect(stateManager.currentSelectingPosition, isNotNull);
        expect(stateManager.currentSelectingPosition!.columnIdx, 2);
        expect(stateManager.currentSelectingPosition!.rowIdx, 0);

        stateManager.moveSelectingCellToEdgeOfColumns(
          PlutoMoveDirection.left,
        );

        expect(stateManager.currentCellPosition!.rowIdx, 0);
        expect(stateManager.currentCellPosition!.columnIdx, 3);

        expect(stateManager.currentSelectingPosition, isNotNull);
        expect(stateManager.currentSelectingPosition!.columnIdx, 0);
        expect(stateManager.currentSelectingPosition!.rowIdx, 0);
      },
    );

    withColumnAndRows.test(
      'PlutoMoveDirection 이 Right 면 현재 셀 부터 오른쪽 끝까지 선택 되어야 한다.',
      (tester) async {
        stateManager.setCurrentCell(stateManager.rows[0].cells['column3'], 0);

        stateManager.setEditing(false);

        expect(stateManager.isEditing, isFalse);

        expect(stateManager.currentSelectingPosition, isNull);

        stateManager.moveSelectingCellToEdgeOfColumns(
          PlutoMoveDirection.right,
        );

        expect(stateManager.currentCellPosition!.rowIdx, 0);
        expect(stateManager.currentCellPosition!.columnIdx, 3);

        expect(stateManager.currentSelectingPosition, isNotNull);
        expect(stateManager.currentSelectingPosition!.columnIdx, 9);
        expect(stateManager.currentSelectingPosition!.rowIdx, 0);
      },
    );

    withColumnAndRows.test(
      'PlutoMoveDirection 이 Right 이고 현재 선택 된 셀이 있다면 선택 된 셀이 오른쪽 끝으로 변경 되어야 한다.',
      (tester) async {
        stateManager.setCurrentCell(stateManager.rows[0].cells['column3'], 0);

        stateManager.setEditing(false);

        expect(stateManager.isEditing, isFalse);

        stateManager.setCurrentSelectingPosition(
          cellPosition: const PlutoGridCellPosition(
            columnIdx: 2,
            rowIdx: 0,
          ),
        );

        expect(stateManager.currentSelectingPosition, isNotNull);
        expect(stateManager.currentSelectingPosition!.columnIdx, 2);
        expect(stateManager.currentSelectingPosition!.rowIdx, 0);

        stateManager.moveSelectingCellToEdgeOfColumns(
          PlutoMoveDirection.right,
        );

        expect(stateManager.currentCellPosition!.rowIdx, 0);
        expect(stateManager.currentCellPosition!.columnIdx, 3);

        expect(stateManager.currentSelectingPosition, isNotNull);
        expect(stateManager.currentSelectingPosition!.columnIdx, 9);
        expect(stateManager.currentSelectingPosition!.rowIdx, 0);
      },
    );
  });

  group('moveSelectingCellToEdgeOfRows', () {
    withColumnAndRows.test(
      'PlutoMoveDirection 이 Left 이면 셀이 선택 되지 않아야 한다.',
      (tester) async {
        stateManager.moveSelectingCellToEdgeOfRows(PlutoMoveDirection.left);

        expect(stateManager.currentSelectingPosition, isNull);
      },
    );

    withColumnAndRows.test(
      'PlutoMoveDirection 이 Right 이면 셀이 선택 되지 않아야 한다.',
      (tester) async {
        stateManager.moveSelectingCellToEdgeOfRows(PlutoMoveDirection.right);

        expect(stateManager.currentSelectingPosition, isNull);
      },
    );

    withColumnAndRows.test(
      'isEditing 이 true 면 셀이 이동 되지 않아야 한다.',
      (tester) async {
        stateManager.setCurrentCell(stateManager.firstCell, 0);

        stateManager.setEditing(true);

        expect(stateManager.isEditing, isTrue);

        expect(stateManager.currentSelectingPosition, isNull);

        stateManager.moveSelectingCellToEdgeOfRows(PlutoMoveDirection.down);

        expect(stateManager.currentSelectingPosition, isNull);
      },
    );

    withColumnAndRows.test(
      'isEditing 이 true 라도 force 가 true 면 셀이 이동 되어야 한다.',
      (tester) async {
        stateManager.setCurrentCell(stateManager.firstCell, 0);

        stateManager.setEditing(true);

        expect(stateManager.isEditing, isTrue);

        expect(stateManager.currentSelectingPosition, isNull);

        stateManager.moveSelectingCellToEdgeOfRows(
          PlutoMoveDirection.down,
          force: true,
        );

        expect(stateManager.currentSelectingPosition, isNotNull);
        expect(stateManager.currentSelectingPosition!.columnIdx, 0);
        expect(stateManager.currentSelectingPosition!.rowIdx, 9);
      },
    );

    withColumnAndRows.test(
      'currentCell 이 없으면 셀 선택이 되지 않아야 한다.',
      (tester) async {
        stateManager.setEditing(false);

        expect(stateManager.isEditing, isFalse);

        expect(stateManager.currentSelectingPosition, isNull);

        stateManager.moveSelectingCellToEdgeOfRows(
          PlutoMoveDirection.down,
        );

        expect(stateManager.currentSelectingPosition, isNull);
      },
    );

    withColumnAndRows.test(
      'PlutoMoveDirection 이 Down 이면 가장 아래 셀이 선택 되어야 한다.',
      (tester) async {
        stateManager.setCurrentCell(stateManager.firstCell, 0);

        stateManager.setEditing(false);

        expect(stateManager.isEditing, isFalse);

        expect(stateManager.currentSelectingPosition, isNull);

        stateManager.moveSelectingCellToEdgeOfRows(
          PlutoMoveDirection.down,
        );

        expect(stateManager.currentSelectingPosition, isNotNull);
        expect(stateManager.currentSelectingPosition!.columnIdx, 0);
        expect(stateManager.currentSelectingPosition!.rowIdx, 9);
      },
    );

    withColumnAndRows.test(
      'PlutoMoveDirection 이 Up 이면 가장 위의 셀이 선택 되어야 한다.',
      (tester) async {
        stateManager.setCurrentCell(stateManager.rows[4].cells['column3'], 4);

        stateManager.setEditing(false);

        expect(stateManager.isEditing, isFalse);

        expect(stateManager.currentSelectingPosition, isNull);

        stateManager.moveSelectingCellToEdgeOfRows(
          PlutoMoveDirection.up,
        );

        expect(stateManager.currentSelectingPosition, isNotNull);
        expect(stateManager.currentSelectingPosition!.columnIdx, 3);
        expect(stateManager.currentSelectingPosition!.rowIdx, 0);
      },
    );

    withColumnAndRows.test(
      'PlutoMoveDirection 이 Down 이고 선택 된 셀이 있으면 컬럼은 유지하고 가장 아래로 이동 해야 한다.',
      (tester) async {
        stateManager.setCurrentCell(stateManager.firstCell, 0);

        stateManager.setEditing(false);

        expect(stateManager.isEditing, isFalse);

        stateManager.setCurrentSelectingPosition(
          cellPosition: const PlutoGridCellPosition(
            columnIdx: 3,
            rowIdx: 2,
          ),
        );

        expect(stateManager.currentSelectingPosition!.columnIdx, 3);
        expect(stateManager.currentSelectingPosition!.rowIdx, 2);

        stateManager.moveSelectingCellToEdgeOfRows(
          PlutoMoveDirection.down,
        );

        expect(stateManager.currentSelectingPosition, isNotNull);
        expect(stateManager.currentSelectingPosition!.columnIdx, 3);
        expect(stateManager.currentSelectingPosition!.rowIdx, 9);
      },
    );
  });

  group('moveSelectingCellByRowIdx', () {
    withColumnAndRows.test(
      'PlutoMoveDirection 이 Left 이면 셀이 선택 되지 않아야 한다.',
      (tester) async {
        stateManager.moveSelectingCellByRowIdx(0, PlutoMoveDirection.left);

        expect(stateManager.currentSelectingPosition, isNull);
      },
    );

    withColumnAndRows.test(
      'PlutoMoveDirection 이 Right 이면 셀이 선택 되지 않아야 한다.',
      (tester) async {
        stateManager.moveSelectingCellByRowIdx(0, PlutoMoveDirection.right);

        expect(stateManager.currentSelectingPosition, isNull);
      },
    );

    withColumnAndRows.test(
      'currentCell 이 없으면 셀이 선택 되지 않아야 한다.',
      (tester) async {
        expect(stateManager.currentCell, isNull);

        expect(stateManager.currentSelectingPosition, isNull);

        stateManager.moveSelectingCellByRowIdx(0, PlutoMoveDirection.down);

        expect(stateManager.currentSelectingPosition, isNull);
      },
    );

    withColumnAndRows.test(
      'rowIdx 가 0 보다 작으면 0번 행이 선택 되어야 한다.',
      (tester) async {
        stateManager.setCurrentCell(stateManager.rows[3].cells['column3'], 3);

        expect(stateManager.currentCell, isNotNull);

        expect(stateManager.currentSelectingPosition, isNull);

        stateManager.moveSelectingCellByRowIdx(-1, PlutoMoveDirection.down);

        expect(stateManager.currentSelectingPosition, isNotNull);
        expect(stateManager.currentSelectingPosition!.columnIdx, 3);
        expect(stateManager.currentSelectingPosition!.rowIdx, 0);
      },
    );

    withColumnAndRows.test(
      'rowIdx 가 0 보다 크면 마지막 행이 선택 되어야 한다.',
      (tester) async {
        stateManager.setCurrentCell(stateManager.rows[3].cells['column3'], 3);

        expect(stateManager.currentCell, isNotNull);

        expect(stateManager.currentSelectingPosition, isNull);

        stateManager.moveSelectingCellByRowIdx(11, PlutoMoveDirection.down);

        expect(stateManager.currentSelectingPosition, isNotNull);
        expect(stateManager.currentSelectingPosition!.columnIdx, 3);
        expect(stateManager.currentSelectingPosition!.rowIdx, 9);
      },
    );

    withColumnAndRows.test(
      'rowIdx 가 3이면 3번 행의 셀이 선택 되어야 한다.',
      (tester) async {
        stateManager.setCurrentCell(stateManager.firstCell, 0);

        expect(stateManager.currentCell, isNotNull);

        expect(stateManager.currentSelectingPosition, isNull);

        stateManager.moveSelectingCellByRowIdx(3, PlutoMoveDirection.down);

        expect(stateManager.currentSelectingPosition, isNotNull);
        expect(stateManager.currentSelectingPosition!.columnIdx, 0);
        expect(stateManager.currentSelectingPosition!.rowIdx, 3);
      },
    );

    withColumnAndRows.test(
      '선택 된 셀이 있으면 컬럼 위치가 유지되어야 한다.',
      (tester) async {
        stateManager.setCurrentCell(stateManager.rows[3].cells['column3'], 0);

        expect(stateManager.currentCell, isNotNull);

        stateManager.setCurrentSelectingPosition(
          cellPosition: const PlutoGridCellPosition(
            columnIdx: 5,
            rowIdx: 3,
          ),
        );

        expect(stateManager.currentSelectingPosition!.columnIdx, 5);
        expect(stateManager.currentSelectingPosition!.rowIdx, 3);

        stateManager.moveSelectingCellByRowIdx(6, PlutoMoveDirection.down);

        expect(stateManager.currentSelectingPosition, isNotNull);
        expect(stateManager.currentSelectingPosition!.columnIdx, 5);
        expect(stateManager.currentSelectingPosition!.rowIdx, 6);
      },
    );
  });
}
