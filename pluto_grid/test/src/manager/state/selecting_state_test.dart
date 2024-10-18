import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../helper/column_helper.dart';
import '../../../helper/row_helper.dart';
import '../../../mock/shared_mocks.mocks.dart';

void main() {
  PlutoGridStateManager createStateManager({
    required List<PlutoColumn> columns,
    required List<PlutoRow> rows,
    FocusNode? gridFocusNode,
    PlutoGridScrollController? scroll,
    BoxConstraints? layout,
    PlutoGridConfiguration configuration = const PlutoGridConfiguration(),
  }) {
    final stateManager = PlutoGridStateManager(
      columns: columns,
      rows: rows,
      gridFocusNode: gridFocusNode ?? MockFocusNode(),
      scroll: scroll ?? MockPlutoGridScrollController(),
      configuration: configuration,
    );

    stateManager.setEventManager(MockPlutoGridEventManager());

    if (layout != null) {
      stateManager.setLayout(layout);
    }

    return stateManager;
  }

  group('currentSelectingPositionList', () {
    testWidgets(
      'selectingMode.Row 상태에서'
      '빈 배열을 리턴해야 한다.',
      (WidgetTester tester) async {
        // given
        List<PlutoColumn> columns = [
          ...ColumnHelper.textColumn('text', count: 3, width: 150),
        ];

        List<PlutoRow> rows = RowHelper.count(5, columns);

        PlutoGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: null,
          layout: const BoxConstraints(maxHeight: 300, maxWidth: 50),
        );

        stateManager.setSelectingMode(PlutoGridSelectingMode.row);

        stateManager.setCurrentSelectingRowsByRange(1, 2);

        // when
        final currentSelectingPositionList =
            stateManager.currentSelectingPositionList;

        // then
        expect(currentSelectingPositionList.length, 0);
      },
    );

    testWidgets(
      'selectingMode.Square 상태에서'
      '(1, 3) ~ (2, 4) 선택 시 4개의 선택 된 셀이 리턴 되어야 한다.',
      (WidgetTester tester) async {
        // given
        List<PlutoColumn> columns = [
          ...ColumnHelper.textColumn('text', count: 3, width: 150),
        ];

        List<PlutoRow> rows = RowHelper.count(5, columns);

        PlutoGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: null,
          layout: const BoxConstraints(maxHeight: 300, maxWidth: 50),
        );

        stateManager.setSelectingMode(PlutoGridSelectingMode.cell);

        final currentCell = rows[3].cells['text1'];

        stateManager.setCurrentCell(currentCell, 3);

        stateManager.setCurrentSelectingPosition(
          cellPosition: const PlutoGridCellPosition(
            columnIdx: 2,
            rowIdx: 4,
          ),
        );

        // when
        final currentSelectingPositionList =
            stateManager.currentSelectingPositionList;

        // then
        expect(currentSelectingPositionList.length, 4);
        expect(currentSelectingPositionList[0].rowIdx, 3);
        expect(currentSelectingPositionList[0].field, 'text1');
        expect(currentSelectingPositionList[1].rowIdx, 3);
        expect(currentSelectingPositionList[1].field, 'text2');
        expect(currentSelectingPositionList[2].rowIdx, 4);
        expect(currentSelectingPositionList[2].field, 'text1');
        expect(currentSelectingPositionList[3].rowIdx, 4);
        expect(currentSelectingPositionList[3].field, 'text2');
      },
    );
  });

  group('currentSelectingText', () {
    testWidgets(
        'WHEN'
        'selectingMode.Row'
        'currentSelectingRows.length > 0'
        'THEN'
        'The values of the selected rows should be returned.',
        (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
      ];

      List<PlutoRow> rows = RowHelper.count(5, columns);

      PlutoGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
        layout: const BoxConstraints(maxHeight: 300, maxWidth: 50),
      );

      stateManager.setSelectingMode(PlutoGridSelectingMode.row);

      stateManager.setCurrentSelectingRowsByRange(1, 2);

      // when
      final currentSelectingText = stateManager.currentSelectingText;

      final transformedSelectingText =
          PlutoClipboardTransformation.stringToList(currentSelectingText);

      // then
      expect(transformedSelectingText[0][0], rows[1].cells['text0']!.value);
      expect(transformedSelectingText[0][1], rows[1].cells['text1']!.value);
      expect(transformedSelectingText[0][2], rows[1].cells['text2']!.value);

      expect(transformedSelectingText[1][0], rows[2].cells['text0']!.value);
      expect(transformedSelectingText[1][1], rows[2].cells['text1']!.value);
      expect(transformedSelectingText[1][2], rows[2].cells['text2']!.value);
    });

    testWidgets(
        'WHEN'
        'selectingMode.Row'
        'currentSelectingRows.length > 0'
        'THEN'
        'The value of the row selected with toggleSelectingRow should be returned.',
        (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
      ];

      List<PlutoRow> rows = RowHelper.count(5, columns);

      PlutoGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
        layout: const BoxConstraints(maxHeight: 300, maxWidth: 50),
      );

      stateManager.setSelectingMode(PlutoGridSelectingMode.row);

      stateManager.toggleSelectingRow(1);
      stateManager.toggleSelectingRow(3);

      // when
      final currentSelectingText = stateManager.currentSelectingText;

      final transformedSelectingText =
          PlutoClipboardTransformation.stringToList(currentSelectingText);

      // then
      expect(transformedSelectingText[0][0], rows[1].cells['text0']!.value);
      expect(transformedSelectingText[0][1], rows[1].cells['text1']!.value);
      expect(transformedSelectingText[0][2], rows[1].cells['text2']!.value);

      expect(
          transformedSelectingText[1][0], isNot(rows[2].cells['text0']!.value));
      expect(
          transformedSelectingText[1][1], isNot(rows[2].cells['text1']!.value));
      expect(
          transformedSelectingText[1][2], isNot(rows[2].cells['text2']!.value));

      expect(transformedSelectingText[1][0], rows[3].cells['text0']!.value);
      expect(transformedSelectingText[1][1], rows[3].cells['text1']!.value);
      expect(transformedSelectingText[1][2], rows[3].cells['text2']!.value);
    });

    testWidgets(
        'WHEN'
        'selectingMode.Row'
        'currentSelectingRows.length == 0'
        'currentCellPosition == null'
        'currentSelectingPosition == null'
        'THEN'
        'The values of the selected rows should be returned as an empty value.',
        (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
      ];

      List<PlutoRow> rows = RowHelper.count(5, columns);

      PlutoGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
        layout: const BoxConstraints(maxHeight: 300, maxWidth: 50),
      );

      stateManager.setSelectingMode(PlutoGridSelectingMode.row);

      // when
      final currentSelectingText = stateManager.currentSelectingText;

      // then
      expect(currentSelectingText, '');
    });

    testWidgets(
        'WHEN'
        'selectingMode.Row'
        'currentSelectingRows.length == 0'
        'currentCellPosition != null'
        'currentSelectingPosition == null'
        'THEN'
        'The values of the selected rows should be returned as an empty value.',
        (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
      ];

      List<PlutoRow> rows = RowHelper.count(5, columns);

      PlutoGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
        layout: const BoxConstraints(maxHeight: 300, maxWidth: 50),
      );

      stateManager.setSelectingMode(PlutoGridSelectingMode.row);

      final currentCell = rows[3].cells['text2']!;

      stateManager.setCurrentCell(currentCell, 3);

      // when
      final currentSelectingText = stateManager.currentSelectingText;

      // then
      expect(currentSelectingText, currentCell.value);
    });

    testWidgets(
        'WHEN'
        'selectingMode.Row'
        'currentSelectingRows.length > 0'
        'has frozen column In a state of sufficient width'
        'THEN'
        'The values of the selected rows should be returned.',
        (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn(
          'left',
          count: 1,
          width: 150,
          frozen: PlutoColumnFrozen.start,
        ),
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
        ...ColumnHelper.textColumn(
          'right',
          count: 1,
          width: 150,
          frozen: PlutoColumnFrozen.end,
        ),
      ];

      List<PlutoRow> rows = RowHelper.count(5, columns);

      PlutoGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
        layout: const BoxConstraints(maxHeight: 500, maxWidth: 600),
      );

      stateManager.setSelectingMode(PlutoGridSelectingMode.row);

      stateManager.setCurrentSelectingRowsByRange(1, 2);

      // when
      final currentSelectingText = stateManager.currentSelectingText;

      final transformedSelectingText =
          PlutoClipboardTransformation.stringToList(currentSelectingText);

      // then
      expect(stateManager.showFrozenColumn, true);

      expect(transformedSelectingText[0][0], rows[1].cells['left0']!.value);
      expect(transformedSelectingText[0][1], rows[1].cells['text0']!.value);
      expect(transformedSelectingText[0][2], rows[1].cells['text1']!.value);
      expect(transformedSelectingText[0][3], rows[1].cells['text2']!.value);
      expect(transformedSelectingText[0][4], rows[1].cells['right0']!.value);

      expect(transformedSelectingText[1][0], rows[2].cells['left0']!.value);
      expect(transformedSelectingText[1][1], rows[2].cells['text0']!.value);
      expect(transformedSelectingText[1][2], rows[2].cells['text1']!.value);
      expect(transformedSelectingText[1][3], rows[2].cells['text2']!.value);
      expect(transformedSelectingText[1][4], rows[2].cells['right0']!.value);
    });

    testWidgets(
        'WHEN'
        'selectingMode.Row'
        'currentSelectingRows.length > 0'
        'has frozen column In a narrow area'
        'THEN'
        'The values of the selected rows should be returned.',
        (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn(
          'left',
          count: 1,
          width: 150,
          frozen: PlutoColumnFrozen.start,
        ),
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
        ...ColumnHelper.textColumn(
          'right',
          count: 1,
          width: 150,
          frozen: PlutoColumnFrozen.end,
        ),
      ];

      List<PlutoRow> rows = RowHelper.count(5, columns);

      PlutoGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
        // 최소 넓이(고정 컬럼 2개 + PlutoDefaultSettings.bodyMinWidth) 부족
        layout: const BoxConstraints(maxHeight: 500, maxWidth: 400),
      );

      stateManager.setSelectingMode(PlutoGridSelectingMode.row);

      stateManager.setCurrentSelectingRowsByRange(1, 2);

      // when
      final currentSelectingText = stateManager.currentSelectingText;

      final transformedSelectingText =
          PlutoClipboardTransformation.stringToList(currentSelectingText);

      // then
      expect(stateManager.showFrozenColumn, false);

      expect(transformedSelectingText[0][0], rows[1].cells['left0']!.value);
      expect(transformedSelectingText[0][1], rows[1].cells['text0']!.value);
      expect(transformedSelectingText[0][2], rows[1].cells['text1']!.value);
      expect(transformedSelectingText[0][3], rows[1].cells['text2']!.value);
      expect(transformedSelectingText[0][4], rows[1].cells['right0']!.value);

      expect(transformedSelectingText[1][0], rows[2].cells['left0']!.value);
      expect(transformedSelectingText[1][1], rows[2].cells['text0']!.value);
      expect(transformedSelectingText[1][2], rows[2].cells['text1']!.value);
      expect(transformedSelectingText[1][3], rows[2].cells['text2']!.value);
      expect(transformedSelectingText[1][4], rows[2].cells['right0']!.value);
    });

    testWidgets(
        'WHEN'
        'selectingMode.Square'
        'currentSelectingRows.length == 0'
        'currentCellPosition != null'
        'currentSelectingPosition != null'
        'THEN'
        'The values of the selected cells should be returned.',
        (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
      ];

      List<PlutoRow> rows = RowHelper.count(5, columns);

      PlutoGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
        layout: const BoxConstraints(maxHeight: 300, maxWidth: 50),
      );

      stateManager.setSelectingMode(PlutoGridSelectingMode.cell);

      final currentCell = rows[3].cells['text1'];

      stateManager.setCurrentCell(currentCell, 3);

      stateManager.setCurrentSelectingPosition(
        cellPosition: const PlutoGridCellPosition(
          columnIdx: 2,
          rowIdx: 4,
        ),
      );

      // when
      final currentSelectingText = stateManager.currentSelectingText;

      // then
      expect(currentSelectingText,
          'text1 value 3\ttext2 value 3\ntext1 value 4\ttext2 value 4');
    });
  });

  group('setSelecting', () {
    testWidgets(
      'selectingMode == None 면 isSelecting 가 변경 되지 않아야 한다.',
      (WidgetTester tester) async {
        // given
        List<PlutoColumn> columns = [
          ...ColumnHelper.textColumn('text', count: 3, width: 150),
        ];

        PlutoGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: [],
          gridFocusNode: null,
          scroll: null,
          layout: const BoxConstraints(maxHeight: 500, maxWidth: 400),
        );

        stateManager.setSelectingMode(PlutoGridSelectingMode.none);

        expect(stateManager.isSelecting, false);
        // when
        stateManager.setSelecting(true);

        // then
        expect(stateManager.isSelecting, false);
      },
    );

    testWidgets(
      'selectingMode == Square'
      'currentCell == null 이면'
      'isSelecting 이 변경 되지 않아야 한다.',
      (WidgetTester tester) async {
        // given
        List<PlutoColumn> columns = [
          ...ColumnHelper.textColumn('text', count: 3, width: 150),
        ];

        PlutoGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: [],
          gridFocusNode: null,
          scroll: null,
          layout: const BoxConstraints(maxHeight: 500, maxWidth: 400),
        );

        stateManager.setSelectingMode(PlutoGridSelectingMode.cell);

        expect(stateManager.currentCell, null);
        expect(stateManager.isSelecting, false);
        // when
        stateManager.setSelecting(true);

        // then
        expect(stateManager.isSelecting, false);
      },
    );

    testWidgets(
      'selectingMode == Row'
      'currentCell == null 이면'
      'isSelecting 이 변경 되지 않아야 한다.',
      (WidgetTester tester) async {
        // given
        List<PlutoColumn> columns = [
          ...ColumnHelper.textColumn('text', count: 3, width: 150),
        ];

        PlutoGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: [],
          gridFocusNode: null,
          scroll: null,
          layout: const BoxConstraints(maxHeight: 500, maxWidth: 400),
        );

        stateManager.setSelectingMode(PlutoGridSelectingMode.row);

        expect(stateManager.currentCell, null);
        expect(stateManager.isSelecting, false);
        // when
        stateManager.setSelecting(true);

        // then
        expect(stateManager.isSelecting, false);
      },
    );

    testWidgets(
      'selectingMode == Row'
      'currentCell != null 이면'
      'isSelecting 이 변경 된다.',
      (WidgetTester tester) async {
        // given
        List<PlutoColumn> columns = [
          ...ColumnHelper.textColumn('text', count: 3, width: 150),
        ];

        List<PlutoRow> rows = RowHelper.count(10, columns);

        PlutoGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: null,
          layout: const BoxConstraints(maxHeight: 500, maxWidth: 400),
        );

        stateManager.setSelectingMode(PlutoGridSelectingMode.row);
        stateManager.setCurrentCell(rows.first.cells['text1'], 0);

        expect(stateManager.currentCell, isNot(null));
        expect(stateManager.isSelecting, false);
        // when
        stateManager.setSelecting(true);

        // then
        expect(stateManager.isSelecting, true);
      },
    );

    testWidgets(
      'selectingMode == Row'
      'currentCell != null 이면'
      'isSelecting 이 변경 된다.'
      'isEditing 이 true 면 isEditing 이 false 로 변경 된다.',
      (WidgetTester tester) async {
        // given
        List<PlutoColumn> columns = [
          ...ColumnHelper.textColumn('text', count: 3, width: 150),
        ];

        List<PlutoRow> rows = RowHelper.count(10, columns);

        PlutoGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: null,
          layout: const BoxConstraints(maxHeight: 500, maxWidth: 400),
        );

        stateManager.setSelectingMode(PlutoGridSelectingMode.row);
        stateManager.setCurrentCell(rows.first.cells['text1'], 0);
        stateManager.setEditing(true);

        expect(stateManager.currentCell, isNot(null));
        expect(stateManager.isEditing, true);
        expect(stateManager.isSelecting, false);
        // when
        stateManager.setSelecting(true);

        // then
        expect(stateManager.isSelecting, true);
        expect(stateManager.isEditing, false);
      },
    );
  });

  group('clearCurrentSelectingPosition', () {
    testWidgets(
      'currentSelectingPosition 이 null 이 아니라면 null 이 되어야 한다.',
      (WidgetTester tester) async {
        // given
        List<PlutoColumn> columns = [
          ...ColumnHelper.textColumn('text', count: 3, width: 150),
        ];

        List<PlutoRow> rows = RowHelper.count(10, columns);

        PlutoGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: null,
          layout: const BoxConstraints(maxHeight: 500, maxWidth: 400),
        );

        // when
        stateManager.setCurrentCell(rows.first.cells['text1'], 0);

        stateManager.setCurrentSelectingPosition(
          cellPosition: const PlutoGridCellPosition(
            columnIdx: 0,
            rowIdx: 1,
          ),
        );

        expect(stateManager.currentSelectingPosition, isNot(null));

        stateManager.clearCurrentSelecting();

        // then
        expect(stateManager.currentSelectingPosition, null);
      },
    );
  });

  group('clearCurrentSelectingRows', () {
    testWidgets(
      'currentSelectingRows 에 값이 있다면 빈 배열로 설정 되어야 한다.',
      (WidgetTester tester) async {
        // given
        List<PlutoColumn> columns = [
          ...ColumnHelper.textColumn('text', count: 3, width: 150),
        ];

        List<PlutoRow> rows = RowHelper.count(10, columns);

        PlutoGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: null,
          layout: const BoxConstraints(maxHeight: 500, maxWidth: 400),
        );

        // when
        stateManager.setSelectingMode(PlutoGridSelectingMode.row);

        stateManager.toggleSelectingRow(1);

        expect(stateManager.currentSelectingRows.length, 1);

        stateManager.clearCurrentSelecting();

        // then
        expect(stateManager.currentSelectingRows.length, 0);
      },
    );
  });

  group('setAllCurrentSelecting', () {
    testWidgets(
        'WHEN '
        'rows == null '
        'THEN'
        '', (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
      ];

      PlutoGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: [],
        gridFocusNode: null,
        scroll: null,
        layout: const BoxConstraints(maxHeight: 500, maxWidth: 400),
      );

      // when
      stateManager.setAllCurrentSelecting();

      // then
      expect(stateManager.currentCell, null);
      expect(stateManager.currentSelectingPosition, null);
      expect(stateManager.currentSelectingRows.length, 0);
    });

    testWidgets(
        'WHEN '
        'rows.length < 1 '
        'THEN'
        '', (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
      ];

      PlutoGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: [],
        gridFocusNode: null,
        scroll: null,
        layout: const BoxConstraints(maxHeight: 500, maxWidth: 400),
      );

      // when
      stateManager.setAllCurrentSelecting();

      // then
      expect(stateManager.currentCell, null);
      expect(stateManager.currentSelectingPosition, null);
      expect(stateManager.currentSelectingRows.length, 0);
    });

    testWidgets(
        'WHEN '
        'selectingMode.Square '
        'rows.length > 0 '
        'THEN '
        '현재 셀은 처음 셀로, 선택 된 셀 위치는 마지막 셀 위치로 설정 되어야 한다.',
        (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
      ];

      List<PlutoRow> rows = RowHelper.count(5, columns);

      PlutoGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
        layout: const BoxConstraints(maxHeight: 500, maxWidth: 400),
      );

      stateManager.setSelectingMode(PlutoGridSelectingMode.cell);

      // when
      stateManager.setAllCurrentSelecting();

      // then
      expect(stateManager.currentCell, rows.first.cells['text0']);
      expect(stateManager.currentSelectingPosition!.rowIdx, 4);
      expect(stateManager.currentSelectingPosition!.columnIdx, 2);
    });

    testWidgets(
        'WHEN '
        'selectingMode.Row '
        'rows.length > 0 '
        'THEN '
        '선택 된 Row 의 개수가 맞아야 한다.', (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
      ];

      List<PlutoRow> rows = RowHelper.count(5, columns);

      PlutoGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
        layout: const BoxConstraints(maxHeight: 500, maxWidth: 400),
      );

      stateManager.setSelectingMode(PlutoGridSelectingMode.row);

      // when
      stateManager.setAllCurrentSelecting();

      // then
      expect(stateManager.currentCell!.value, rows.first.cells['text0']!.value);
      expect(stateManager.currentSelectingPosition!.columnIdx, 2);
      expect(stateManager.currentSelectingPosition!.rowIdx, 4);
      expect(stateManager.currentSelectingRows.length, 5);
    });

    testWidgets(
        'WHEN'
        'selectingMode.None'
        'rows.length > 0'
        'THEN'
        '아무것도 선택되지 않아야 한다.', (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
      ];

      List<PlutoRow> rows = RowHelper.count(5, columns);

      PlutoGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
        layout: const BoxConstraints(maxHeight: 500, maxWidth: 400),
      );

      stateManager.setSelectingMode(PlutoGridSelectingMode.none);

      // when
      stateManager.setAllCurrentSelecting();

      // then
      expect(stateManager.currentCell, null);
      expect(stateManager.currentSelectingPosition, null);
      expect(stateManager.currentSelectingRows.length, 0);
    });
  });

  group('setCurrentSelectingPosition', () {
    testWidgets(
      'selectingMode == Row'
      'currentRowIdx, rowIdx 로 currentSelectingRows 가 설정 되어야 한다.',
      (WidgetTester tester) async {
        // given
        List<PlutoColumn> columns = [
          ...ColumnHelper.textColumn('text', count: 3, width: 150),
        ];

        List<PlutoRow> rows = RowHelper.count(5, columns);

        PlutoGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: null,
          layout: const BoxConstraints(maxHeight: 500, maxWidth: 400),
        );

        stateManager.setSelectingMode(PlutoGridSelectingMode.row);

        stateManager.setCurrentCell(rows[3].cells['text1'], 3);

        stateManager.setCurrentSelectingPosition(
          cellPosition: const PlutoGridCellPosition(
            columnIdx: 1,
            rowIdx: 4,
          ),
        );

        // then
        // 3, 4 번 Row 선택 됨.
        expect(stateManager.currentSelectingRows.length, 2);

        final List<Key> keys =
            stateManager.currentSelectingRows.map((e) => e.key).toList();

        expect(keys.contains(rows[3].key), isTrue);
        expect(keys.contains(rows[4].key), isTrue);
      },
    );
  });

  group('toggleSelectingRow', () {
    testWidgets(
      'selectingMode == Row, '
      '이미 선택 된 Row 라면 다시 해제 되어야 한다.',
      (WidgetTester tester) async {
        // given
        List<PlutoColumn> columns = [
          ...ColumnHelper.textColumn('text', count: 3, width: 150),
        ];

        List<PlutoRow> rows = RowHelper.count(5, columns);

        PlutoGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: null,
          layout: const BoxConstraints(maxHeight: 500, maxWidth: 400),
        );

        stateManager.setSelectingMode(PlutoGridSelectingMode.row);

        stateManager.toggleSelectingRow(3);

        expect(stateManager.isSelectedRow(rows[3].key), true);

        stateManager.toggleSelectingRow(3);
        // then

        expect(stateManager.isSelectedRow(rows[3].key), false);
      },
    );
  });

  group('isSelectingInteraction', () {
    testWidgets(
      'selectingMode 가 None 인 경우 false',
      (WidgetTester tester) async {
        // given
        List<PlutoColumn> columns = [
          ...ColumnHelper.textColumn('text', count: 3, width: 150),
        ];

        List<PlutoRow> rows = RowHelper.count(5, columns);

        PlutoGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: null,
          layout: const BoxConstraints(maxHeight: 500, maxWidth: 400),
        );

        // when
        stateManager.setSelectingMode(PlutoGridSelectingMode.none);

        // then
        expect(stateManager.isSelectingInteraction(), isFalse);
      },
    );

    testWidgets(
      'selectingMode 가 None 이 아니지만, '
      'shift or ctrl 키가 눌려지지 않으면 false',
      (WidgetTester tester) async {
        // given
        List<PlutoColumn> columns = [
          ...ColumnHelper.textColumn('text', count: 3, width: 150),
        ];

        List<PlutoRow> rows = RowHelper.count(5, columns);

        PlutoGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: null,
          layout: const BoxConstraints(maxHeight: 500, maxWidth: 400),
        );

        // when
        stateManager.setSelectingMode(PlutoGridSelectingMode.row);

        // then
        expect(stateManager.isSelectingInteraction(), isFalse);
      },
    );

    testWidgets(
      'selectingMode 가 None 이 아니지만, '
      'shift 가 눌려졌지만, '
      'currentCell 이 null 인경우 false',
      (WidgetTester tester) async {
        // given
        List<PlutoColumn> columns = [
          ...ColumnHelper.textColumn('text', count: 3, width: 150),
        ];

        List<PlutoRow> rows = RowHelper.count(5, columns);

        PlutoGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: null,
          layout: const BoxConstraints(maxHeight: 500, maxWidth: 400),
        );

        // when
        stateManager.setSelectingMode(PlutoGridSelectingMode.row);
        await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);

        // then
        expect(stateManager.isSelectingInteraction(), isFalse);
      },
    );

    testWidgets(
      'selectingMode 가 None 이 아니지만, '
      'ctrl 가 눌려졌지만, '
      'currentCell 이 null 인경우 false',
      (WidgetTester tester) async {
        // given
        List<PlutoColumn> columns = [
          ...ColumnHelper.textColumn('text', count: 3, width: 150),
        ];

        List<PlutoRow> rows = RowHelper.count(5, columns);

        PlutoGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: null,
          layout: const BoxConstraints(maxHeight: 500, maxWidth: 400),
        );

        // when
        stateManager.setSelectingMode(PlutoGridSelectingMode.row);
        await tester.sendKeyDownEvent(LogicalKeyboardKey.control);

        // then
        expect(stateManager.isSelectingInteraction(), isFalse);
      },
    );

    testWidgets(
      'selectingMode 가 None 이 아니고, '
      'shift 가 눌려졌고, '
      'currentCell 이 null 이 아닌 경우 true',
      (WidgetTester tester) async {
        // given
        List<PlutoColumn> columns = [
          ...ColumnHelper.textColumn('text', count: 3, width: 150),
        ];

        List<PlutoRow> rows = RowHelper.count(5, columns);

        PlutoGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: null,
          layout: const BoxConstraints(maxHeight: 500, maxWidth: 400),
        );

        // when
        stateManager.setSelectingMode(PlutoGridSelectingMode.row);
        await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
        stateManager.setCurrentCell(rows.first.cells['text0'], 0);

        // then
        expect(stateManager.isSelectingInteraction(), isTrue);
      },
    );

    testWidgets(
      'selectingMode 가 None 이 아니고, '
      'ctrl 가 눌려졌고, '
      'currentCell 이 null 이 아닌 경우 true',
      (WidgetTester tester) async {
        // given
        List<PlutoColumn> columns = [
          ...ColumnHelper.textColumn('text', count: 3, width: 150),
        ];

        List<PlutoRow> rows = RowHelper.count(5, columns);

        PlutoGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: null,
          layout: const BoxConstraints(maxHeight: 500, maxWidth: 400),
        );

        // when
        stateManager.setSelectingMode(PlutoGridSelectingMode.cell);
        await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
        stateManager.setCurrentCell(rows.first.cells['text0'], 0);

        // then
        expect(stateManager.isSelectingInteraction(), isTrue);
      },
    );
  });

  group('isSelectedCell', () {
    testWidgets(
        'WHEN'
        '아무것도 선택되지 않음.'
        'THEN'
        '모든 셀이 false.', (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
      ];

      List<PlutoRow> rows = RowHelper.count(5, columns);

      PlutoGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
        layout: const BoxConstraints(maxHeight: 500, maxWidth: 400),
      );

      // when
      expect(stateManager.selectingMode.isCell, isTrue);

      // then
      for (var i = 0; i < rows.length; i += 1) {
        for (var column in columns) {
          expect(
            stateManager.isSelectedCell(
              rows[i].cells[column.field]!,
              column,
              i,
            ),
            false,
          );
        }
      }
    });

    testWidgets(
        'WHEN '
        '현재 셀이 0번 Row, 0번 Column 이고 '
        '0번 Row, 1번 Column 이 선택 됨. '
        'THEN '
        '해당 셀이 true.', (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
      ];

      List<PlutoRow> rows = RowHelper.count(5, columns);

      PlutoGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
        layout: const BoxConstraints(maxHeight: 500, maxWidth: 400),
      );

      stateManager.setCurrentCell(stateManager.firstCell, 0);

      stateManager.setCurrentSelectingPosition(
        cellPosition: const PlutoGridCellPosition(
          columnIdx: 1,
          rowIdx: 0,
        ),
      );

      // when
      expect(stateManager.selectingMode.isCell, isTrue);

      // then
      for (var i = 0; i < rows.length; i += 1) {
        for (var column in columns) {
          if (i == 0 && (column.field == 'text0' || column.field == 'text1')) {
            expect(
              stateManager.isSelectedCell(
                rows[i].cells[column.field]!,
                column,
                i,
              ),
              true,
            );
          } else {
            expect(
              stateManager.isSelectedCell(
                rows[i].cells[column.field]!,
                column,
                i,
              ),
              false,
            );
          }
        }
      }
    });

    testWidgets(
        'WHEN '
        '현재 셀이 1번 Row, 1번 Column 이고 '
        '3번 Row, 2번 Column 이 선택 됨. '
        'THEN '
        '해당 셀이 true.', (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
      ];

      List<PlutoRow> rows = RowHelper.count(5, columns);

      PlutoGridStateManager stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
        layout: const BoxConstraints(maxHeight: 500, maxWidth: 400),
      );

      stateManager.setCurrentCell(rows[1].cells['text1'], 1);

      stateManager.setCurrentSelectingPosition(
        cellPosition: const PlutoGridCellPosition(
          rowIdx: 3,
          columnIdx: 2,
        ),
      );

      // when
      expect(stateManager.selectingMode.isCell, isTrue);

      // then
      for (var i = 0; i < rows.length; i += 1) {
        for (var column in columns) {
          if ((i >= 1 && i <= 3) &&
              (column.field == 'text1' || column.field == 'text2')) {
            expect(
              stateManager.isSelectedCell(
                rows[i].cells[column.field]!,
                column,
                i,
              ),
              true,
            );
          } else {
            expect(
              stateManager.isSelectedCell(
                rows[i].cells[column.field]!,
                column,
                i,
              ),
              false,
            );
          }
        }
      }
    });
  });

  group('handleAfterSelectingRow', () {
    testWidgets(
      'WHEN '
      'enableMoveDownAfterSelecting 이 false 이면 '
      '셀 값 변경 후 다음 행으로 이동 되지 않아야 한다.',
      (WidgetTester tester) async {
        // given
        List<PlutoColumn> columns = [
          ...ColumnHelper.textColumn('text', count: 3, width: 150),
        ];

        List<PlutoRow> rows = RowHelper.count(5, columns);

        PlutoGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: FocusNode(),
          scroll: null,
          configuration: const PlutoGridConfiguration(
            enableMoveDownAfterSelecting: false,
          ),
        );

        stateManager
            .setLayout(const BoxConstraints(maxHeight: 500, maxWidth: 400));

        stateManager.setCurrentCell(rows[1].cells['text1'], 1);

        stateManager.setCurrentSelectingPosition(
          cellPosition: const PlutoGridCellPosition(
            rowIdx: 3,
            columnIdx: 2,
          ),
        );

        // when
        expect(stateManager.currentCellPosition!.rowIdx, 1);

        stateManager.handleAfterSelectingRow(
          rows[1].cells['text1']!,
          'new value',
        );

        // then
        expect(stateManager.currentCellPosition!.rowIdx, 1);
      },
    );

    testWidgets(
      'WHEN '
      'enableMoveDownAfterSelecting 이 true 이면 '
      '셀 값 변경 후 다음 행으로 이동 되어야 한다.',
      (WidgetTester tester) async {
        // given
        List<PlutoColumn> columns = [
          ...ColumnHelper.textColumn('text', count: 3, width: 150),
        ];

        List<PlutoRow> rows = RowHelper.count(5, columns);

        final vertical = MockLinkedScrollControllerGroup();

        when(vertical.offset).thenReturn(0);

        PlutoGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: FocusNode(),
          scroll: PlutoGridScrollController(
            vertical: vertical,
            horizontal: MockLinkedScrollControllerGroup(),
          ),
          configuration: const PlutoGridConfiguration(
            enableMoveDownAfterSelecting: true,
          ),
          layout: const BoxConstraints(maxHeight: 500, maxWidth: 400),
        );

        stateManager.setCurrentCell(rows[1].cells['text1'], 1);

        stateManager.setCurrentSelectingPosition(
          cellPosition: const PlutoGridCellPosition(
            rowIdx: 3,
            columnIdx: 2,
          ),
        );

        // when
        expect(stateManager.currentCellPosition!.rowIdx, 1);

        stateManager.handleAfterSelectingRow(
          rows[1].cells['text1']!,
          'new value',
        );

        // then
        expect(stateManager.currentCellPosition!.rowIdx, 2);
      },
    );
  });
}
