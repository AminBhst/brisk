import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:pluto_grid/src/ui/ui.dart';

import '../../../helper/column_helper.dart';
import '../../../helper/row_helper.dart';
import '../../../mock/mock_methods.dart';
import '../../../mock/shared_mocks.mocks.dart';

void main() {
  final PlutoGridScrollController scroll = MockPlutoGridScrollController();
  final LinkedScrollControllerGroup horizontal =
      MockLinkedScrollControllerGroup();
  final ScrollController scrollController = MockScrollController();
  final ScrollPosition scrollPosition = MockScrollPosition();
  final PlutoGridEventManager eventManager = MockPlutoGridEventManager();

  when(scroll.horizontal).thenReturn(horizontal);
  when(scroll.horizontalOffset).thenReturn(0);
  when(scroll.maxScrollHorizontal).thenReturn(0);
  when(scroll.bodyRowsHorizontal).thenReturn(scrollController);
  when(scrollController.hasClients).thenReturn(true);
  when(scrollController.offset).thenReturn(0);
  when(scrollController.position).thenReturn(scrollPosition);
  when(scrollPosition.viewportDimension).thenReturn(0.0);
  when(scrollPosition.hasViewportDimension).thenReturn(true);

  PlutoGridStateManager getStateManager({
    required List<PlutoColumn> columns,
    required List<PlutoRow> rows,
    required FocusNode? gridFocusNode,
    required PlutoGridScrollController scroll,
    List<PlutoColumnGroup>? columnGroups,
    PlutoGridConfiguration configuration = const PlutoGridConfiguration(),
  }) {
    return PlutoGridStateManager(
      columns: columns,
      rows: rows,
      columnGroups: columnGroups,
      gridFocusNode: MockFocusNode(),
      scroll: scroll,
      configuration: configuration,
    )..setEventManager(eventManager);
  }

  testWidgets('columnIndexes - columns 에 맞는 index list 가 리턴 되어야 한다.',
      (WidgetTester tester) async {
    // given
    PlutoGridStateManager stateManager = getStateManager(
      columns: [
        PlutoColumn(title: '', field: '', type: PlutoColumnType.text()),
        PlutoColumn(title: '', field: '', type: PlutoColumnType.text()),
        PlutoColumn(title: '', field: '', type: PlutoColumnType.text()),
      ],
      rows: [],
      gridFocusNode: null,
      scroll: scroll,
    );

    // when
    final List<int> result = stateManager.columnIndexes;

    // then
    expect(result.length, 3);
    expect(result, [0, 1, 2]);
  });

  testWidgets('columnIndexesForShowFrozen - 고정 컬럼 순서에 맞게 리턴 되어야 한다.',
      (WidgetTester tester) async {
    // given
    PlutoGridStateManager stateManager = getStateManager(
      columns: [
        PlutoColumn(
          title: '',
          field: '',
          type: PlutoColumnType.text(),
          frozen: PlutoColumnFrozen.end,
        ),
        PlutoColumn(title: '', field: '', type: PlutoColumnType.text()),
        PlutoColumn(
          title: '',
          field: '',
          type: PlutoColumnType.text(),
          frozen: PlutoColumnFrozen.start,
        ),
      ],
      rows: [],
      gridFocusNode: null,
      scroll: scroll,
    );

    // when
    final List<int> result = stateManager.columnIndexesForShowFrozen;

    // then
    expect(result.length, 3);
    expect(result, [2, 1, 0]);
  });

  testWidgets('columnsWidth - 컬럼 넓이 합계를 리턴 해야 한다.',
      (WidgetTester tester) async {
    // given
    PlutoGridStateManager stateManager = getStateManager(
      columns: [
        PlutoColumn(
          title: '',
          field: '',
          type: PlutoColumnType.text(),
          width: 150,
        ),
        PlutoColumn(
          title: '',
          field: '',
          type: PlutoColumnType.text(),
          width: 200,
        ),
        PlutoColumn(
          title: '',
          field: '',
          type: PlutoColumnType.text(),
          width: 250,
        ),
      ],
      rows: [],
      gridFocusNode: null,
      scroll: scroll,
    );

    // when
    final double result = stateManager.columnsWidth;

    // then
    expect(result, 600);
  });

  testWidgets('leftFrozenColumns - 왼쪽 고정 컬럼 리스트만 리턴 되어야 한다.',
      (WidgetTester tester) async {
    // given
    PlutoGridStateManager stateManager = getStateManager(
      columns: [
        PlutoColumn(
          title: 'left1',
          field: '',
          type: PlutoColumnType.text(),
          frozen: PlutoColumnFrozen.start,
        ),
        PlutoColumn(title: 'body', field: '', type: PlutoColumnType.text()),
        PlutoColumn(
          title: 'left2',
          field: '',
          type: PlutoColumnType.text(),
          frozen: PlutoColumnFrozen.start,
        ),
      ],
      rows: [],
      gridFocusNode: null,
      scroll: scroll,
    );

    // when
    final List<PlutoColumn> result = stateManager.leftFrozenColumns;

    // then
    expect(result.length, 2);
    expect(result[0].title, 'left1');
    expect(result[1].title, 'left2');
  });

  testWidgets('leftFrozenColumnIndexes - 왼쪽 고정 컬럼 인덱스 리스트만 리턴 되어야 한다.',
      (WidgetTester tester) async {
    // given
    PlutoGridStateManager stateManager = getStateManager(
      columns: [
        PlutoColumn(
          title: 'right1',
          field: '',
          type: PlutoColumnType.text(),
          frozen: PlutoColumnFrozen.end,
        ),
        PlutoColumn(title: 'body', field: '', type: PlutoColumnType.text()),
        PlutoColumn(
          title: 'left2',
          field: '',
          type: PlutoColumnType.text(),
          frozen: PlutoColumnFrozen.start,
        ),
      ],
      rows: [],
      gridFocusNode: null,
      scroll: scroll,
    );

    // when
    final List<int> result = stateManager.leftFrozenColumnIndexes;

    // then
    expect(result.length, 1);
    expect(result[0], 2);
  });

  testWidgets('leftFrozenColumnsWidth - 왼쪽 고정 컬럼 넓이 합계를 리턴해야 한다.',
      (WidgetTester tester) async {
    // given
    PlutoGridStateManager stateManager = getStateManager(
      columns: [
        PlutoColumn(
          title: 'right1',
          field: '',
          type: PlutoColumnType.text(),
          frozen: PlutoColumnFrozen.start,
          width: 150,
        ),
        PlutoColumn(
          title: 'body',
          field: '',
          type: PlutoColumnType.text(),
          width: 150,
        ),
        PlutoColumn(
          title: 'left2',
          field: '',
          type: PlutoColumnType.text(),
          frozen: PlutoColumnFrozen.start,
          width: 150,
        ),
      ],
      rows: [],
      gridFocusNode: null,
      scroll: scroll,
    );

    // when
    final double result = stateManager.leftFrozenColumnsWidth;

    // then
    expect(result, 300);
  });

  testWidgets('rightFrozenColumns - 오른쪽 고정 컬럼 리스트만 리턴 되어야 한다.',
      (WidgetTester tester) async {
    // given
    PlutoGridStateManager stateManager = getStateManager(
      columns: [
        PlutoColumn(
          title: 'left1',
          field: '',
          type: PlutoColumnType.text(),
          frozen: PlutoColumnFrozen.start,
        ),
        PlutoColumn(title: 'body', field: '', type: PlutoColumnType.text()),
        PlutoColumn(
          title: 'right1',
          field: '',
          type: PlutoColumnType.text(),
          frozen: PlutoColumnFrozen.end,
        ),
      ],
      rows: [],
      gridFocusNode: null,
      scroll: scroll,
    );

    // when
    final List<PlutoColumn> result = stateManager.rightFrozenColumns;

    // then
    expect(result.length, 1);
    expect(result[0].title, 'right1');
  });

  testWidgets('rightFrozenColumnIndexes - 오른쪽 고정 컬럼 인덱스 리스트만 리턴 되어야 한다.',
      (WidgetTester tester) async {
    // given
    PlutoGridStateManager stateManager = getStateManager(
      columns: [
        PlutoColumn(
          title: 'right1',
          field: '',
          type: PlutoColumnType.text(),
          frozen: PlutoColumnFrozen.end,
        ),
        PlutoColumn(title: 'body', field: '', type: PlutoColumnType.text()),
        PlutoColumn(
          title: 'right2',
          field: '',
          type: PlutoColumnType.text(),
          frozen: PlutoColumnFrozen.end,
        ),
      ],
      rows: [],
      gridFocusNode: null,
      scroll: scroll,
    );

    // when
    final List<int> result = stateManager.rightFrozenColumnIndexes;

    // then
    expect(result.length, 2);
    expect(result[0], 0);
    expect(result[1], 2);
  });

  testWidgets('rightFrozenColumnsWidth - 오른쪽 고정 컬럼 넓이 합계를 리턴해야 한다.',
      (WidgetTester tester) async {
    // given
    PlutoGridStateManager stateManager = getStateManager(
      columns: [
        PlutoColumn(
          title: 'right1',
          field: '',
          type: PlutoColumnType.text(),
          frozen: PlutoColumnFrozen.end,
          width: 120,
        ),
        PlutoColumn(
          title: 'right2',
          field: '',
          type: PlutoColumnType.text(),
          frozen: PlutoColumnFrozen.end,
          width: 120,
        ),
        PlutoColumn(
          title: 'body',
          field: '',
          type: PlutoColumnType.text(),
          width: 100,
        ),
        PlutoColumn(
          title: 'left1',
          field: '',
          type: PlutoColumnType.text(),
          frozen: PlutoColumnFrozen.start,
          width: 120,
        ),
      ],
      rows: [],
      gridFocusNode: null,
      scroll: scroll,
    );

    // when
    final double result = stateManager.rightFrozenColumnsWidth;

    // then
    expect(result, 240);
  });

  testWidgets('bodyColumns - body 컬럼 리스트만 리턴 되어야 한다.',
      (WidgetTester tester) async {
    // given
    PlutoGridStateManager stateManager = getStateManager(
      columns: [
        ...ColumnHelper.textColumn('left',
            count: 3, frozen: PlutoColumnFrozen.start),
        ...ColumnHelper.textColumn('body', count: 3),
        ...ColumnHelper.textColumn('right',
            count: 3, frozen: PlutoColumnFrozen.end),
      ],
      rows: [],
      gridFocusNode: null,
      scroll: scroll,
    );

    stateManager.setLayout(const BoxConstraints(maxWidth: 1800));

    // when
    final List<PlutoColumn> result = stateManager.bodyColumns;

    // then
    expect(result.length, 3);
    expect(result[0].title, 'body0');
    expect(result[1].title, 'body1');
    expect(result[2].title, 'body2');
  });

  testWidgets('bodyColumnIndexes - body 컬럼 인덱스 리스트만 리턴 되어야 한다.',
      (WidgetTester tester) async {
    // given
    PlutoGridStateManager stateManager = getStateManager(
      columns: [
        ...ColumnHelper.textColumn('left',
            count: 3, frozen: PlutoColumnFrozen.start),
        ...ColumnHelper.textColumn('body', count: 3),
        ...ColumnHelper.textColumn('right',
            count: 3, frozen: PlutoColumnFrozen.end),
      ],
      rows: [],
      gridFocusNode: null,
      scroll: scroll,
    );

    // when
    final List<int> result = stateManager.bodyColumnIndexes;

    // then
    expect(result.length, 3);
    expect(result[0], 3);
    expect(result[1], 4);
    expect(result[2], 5);
  });

  testWidgets('bodyColumnsWidth - body 컬럼 넓이 합계를 리턴해야 한다.',
      (WidgetTester tester) async {
    // given
    PlutoGridStateManager stateManager = getStateManager(
      columns: [
        ...ColumnHelper.textColumn('left',
            count: 3, frozen: PlutoColumnFrozen.start),
        ...ColumnHelper.textColumn('body', count: 3, width: 150),
        ...ColumnHelper.textColumn('right',
            count: 3, frozen: PlutoColumnFrozen.end),
      ],
      rows: [],
      gridFocusNode: null,
      scroll: scroll,
    );

    // when
    final double result = stateManager.bodyColumnsWidth;

    // then
    expect(result, 450);
  });

  testWidgets('currentColumn - currentColumnField 값이 없는 경우 null 을 리턴해야 한다.',
      (WidgetTester tester) async {
    // given
    PlutoGridStateManager stateManager = getStateManager(
      columns: [
        ...ColumnHelper.textColumn('left',
            count: 3, frozen: PlutoColumnFrozen.start),
        ...ColumnHelper.textColumn('body', count: 3, width: 150),
        ...ColumnHelper.textColumn('right',
            count: 3, frozen: PlutoColumnFrozen.end),
      ],
      rows: [],
      gridFocusNode: null,
      scroll: scroll,
    );

    // when
    PlutoColumn? currentColumn = stateManager.currentColumn;

    // when
    expect(currentColumn, null);
  });

  testWidgets('currentColumn - currentCell 이 선택 된 경우 currentColumn 을 리턴해야 한다.',
      (WidgetTester tester) async {
    // given
    List<PlutoColumn> columns = [
      ...ColumnHelper.textColumn('left',
          count: 3, frozen: PlutoColumnFrozen.start),
      ...ColumnHelper.textColumn('body', count: 3, width: 150),
      ...ColumnHelper.textColumn('right',
          count: 3, frozen: PlutoColumnFrozen.end),
    ];

    List<PlutoRow> rows = RowHelper.count(10, columns);

    PlutoGridStateManager stateManager = getStateManager(
      columns: columns,
      rows: rows,
      gridFocusNode: null,
      scroll: scroll,
    );

    stateManager.setLayout(
      const BoxConstraints(maxWidth: 1000, maxHeight: 600),
    );

    // when
    String selectColumnField = 'body2';
    stateManager.setCurrentCell(rows[2].cells[selectColumnField], 2);

    PlutoColumn currentColumn = stateManager.currentColumn!;

    // when
    expect(currentColumn, isNot(null));
    expect(currentColumn.field, selectColumnField);
    expect(currentColumn.width, 150);
  });

  testWidgets('currentColumnField - currentCell 이 선택되지 않는 경우 null 을 리턴해야 한다.',
      (WidgetTester tester) async {
    // given
    List<PlutoColumn> columns = [
      ...ColumnHelper.textColumn('left',
          count: 3, frozen: PlutoColumnFrozen.start),
      ...ColumnHelper.textColumn('body', count: 3, width: 150),
      ...ColumnHelper.textColumn('right',
          count: 3, frozen: PlutoColumnFrozen.end),
    ];

    List<PlutoRow> rows = RowHelper.count(10, columns);

    PlutoGridStateManager stateManager = getStateManager(
      columns: columns,
      rows: rows,
      gridFocusNode: null,
      scroll: scroll,
    );

    // when
    String? currentColumnField = stateManager.currentColumnField;

    // when
    expect(currentColumnField, null);
  });

  testWidgets(
      'currentColumnField - currentCell 이 선택 된 경우 선택 된 컬럼의 field 를 리턴해야 한다.',
      (WidgetTester tester) async {
    // given
    List<PlutoColumn> columns = [
      ...ColumnHelper.textColumn('left',
          count: 3, frozen: PlutoColumnFrozen.start),
      ...ColumnHelper.textColumn('body', count: 3, width: 150),
      ...ColumnHelper.textColumn('right',
          count: 3, frozen: PlutoColumnFrozen.end),
    ];

    List<PlutoRow> rows = RowHelper.count(10, columns);

    PlutoGridStateManager stateManager = getStateManager(
      columns: columns,
      rows: rows,
      gridFocusNode: null,
      scroll: scroll,
    );

    stateManager.setLayout(const BoxConstraints());

    // when
    String selectColumnField = 'body1';
    stateManager.setCurrentCell(rows[2].cells[selectColumnField], 2);

    String? currentColumnField = stateManager.currentColumnField;

    // when
    expect(currentColumnField, isNot(null));
    expect(currentColumnField, selectColumnField);
  });

  group('getSortedColumn', () {
    test('Sort 컬럼이 없는 경우 null 을 리턴해야 한다.', () {
      final columns = ColumnHelper.textColumn('title', count: 3);

      PlutoGridStateManager stateManager = getStateManager(
        columns: columns,
        rows: [],
        gridFocusNode: null,
        scroll: scroll,
      );

      expect(stateManager.getSortedColumn, null);
    });

    test('Sort 컬럼이 있는 경우 sort 된 컬럼을 리턴해야 한다.', () {
      final columns = ColumnHelper.textColumn('title', count: 3);
      columns[1].sort = PlutoColumnSort.ascending;

      PlutoGridStateManager stateManager = getStateManager(
        columns: columns,
        rows: [],
        gridFocusNode: null,
        scroll: scroll,
      );

      expect(stateManager.getSortedColumn!.key, columns[1].key);
    });
  });

  group('columnIndexesByShowFrozen', () {
    testWidgets(
        '고정 컬럼이 없는 상태에서 '
        'columnIndexes 가 리턴 되어야 한다.', (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn('body', count: 3, width: 150),
      ];

      List<PlutoRow> rows = RowHelper.count(10, columns);

      PlutoGridStateManager stateManager = getStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: scroll,
      );

      stateManager.setLayout(const BoxConstraints());

      // when
      // then
      expect(stateManager.columnIndexesByShowFrozen, [0, 1, 2]);
    });

    testWidgets(
        '고정 컬럼이 없는 상태에서 '
        '3번 째 컬럼을 왼쪽 고정 토글 하고 '
        '넓이가 충분한 경우 '
        'columnIndexesForShowFrozen 가 리턴 되어야 한다.', (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn('body', count: 5, width: 150),
      ];

      List<PlutoRow> rows = RowHelper.count(10, columns);

      PlutoGridStateManager stateManager = getStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: scroll,
      );

      stateManager.setLayout(
        const BoxConstraints(maxWidth: 1000, maxHeight: 600),
      );

      // when
      stateManager.toggleFrozenColumn(columns[2], PlutoColumnFrozen.start);

      stateManager.setLayout(
        const BoxConstraints(maxWidth: 1000, maxHeight: 600),
      );

      // then
      expect(stateManager.showFrozenColumn, true);
      expect(stateManager.columnIndexesByShowFrozen, [2, 0, 1, 3, 4]);
    });

    testWidgets(
        '고정 컬럼이 없는 상태에서 '
        '3번 째 컬럼을 왼쪽 고정 토글 하고 '
        '넓이가 충분하지 않은 경우 '
        'columnIndexes 가 리턴 되어야 한다.', (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn('body', count: 5, width: 150),
      ];

      List<PlutoRow> rows = RowHelper.count(10, columns);

      PlutoGridStateManager stateManager = getStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: scroll,
      );

      stateManager.setLayout(
        const BoxConstraints(maxWidth: 300, maxHeight: 600),
      );

      // when
      stateManager.toggleFrozenColumn(columns[2], PlutoColumnFrozen.start);

      stateManager.setLayout(
        const BoxConstraints(maxWidth: 300, maxHeight: 600),
      );

      // then
      expect(stateManager.columnIndexesByShowFrozen, [0, 1, 2, 3, 4]);
    });

    testWidgets(
        '고정 컬럼이 있는 상태에서 '
        '넓이가 충분한 경우 '
        'columnIndexes 가 리턴 되어야 한다.', (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn(
          'left',
          count: 1,
          frozen: PlutoColumnFrozen.start,
          width: 150,
        ),
        ...ColumnHelper.textColumn('body', count: 3, width: 150),
        ...ColumnHelper.textColumn(
          'right',
          count: 1,
          frozen: PlutoColumnFrozen.end,
          width: 150,
        ),
      ];

      List<PlutoRow> rows = RowHelper.count(10, columns);

      PlutoGridStateManager stateManager = getStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: scroll,
      );

      stateManager
          .setLayout(const BoxConstraints(maxWidth: 500, maxHeight: 600));

      // when
      // then
      expect(stateManager.columnIndexesByShowFrozen, [0, 1, 2, 3, 4]);
    });

    testWidgets(
        '고정 컬럼이 있는 상태에서 '
        '고정 컬럼 하나를 토글하여 왼쪽 추가하고  '
        '넓이가 충분한 경우 '
        'columnIndexesForShowFrozen 가 리턴 되어야 한다.', (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn(
          'left',
          count: 1,
          frozen: PlutoColumnFrozen.start,
          width: 150,
        ),
        ...ColumnHelper.textColumn('body', count: 3, width: 150),
        ...ColumnHelper.textColumn(
          'right',
          count: 1,
          frozen: PlutoColumnFrozen.end,
          width: 150,
        ),
      ];

      List<PlutoRow> rows = RowHelper.count(10, columns);

      PlutoGridStateManager stateManager = getStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: scroll,
      );

      stateManager.setLayout(
        const BoxConstraints(maxWidth: 700, maxHeight: 600),
      );

      stateManager.toggleFrozenColumn(columns[2], PlutoColumnFrozen.start);

      stateManager.setLayout(
        const BoxConstraints(maxWidth: 700, maxHeight: 600),
      );

      // when
      // then
      expect(stateManager.columnIndexesByShowFrozen, [0, 2, 1, 3, 4]);
    });

    testWidgets(
        '고정 컬럼이 있는 상태에서 '
        '고정 컬럼 하나를 토글하여 오른쪽 추가하고  '
        '넓이가 충분한 경우 '
        'columnIndexesForShowFrozen 가 리턴 되어야 한다.', (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn(
          'left',
          count: 1,
          frozen: PlutoColumnFrozen.start,
          width: 150,
        ),
        ...ColumnHelper.textColumn('body', count: 3, width: 150),
        ...ColumnHelper.textColumn(
          'right',
          count: 1,
          frozen: PlutoColumnFrozen.end,
          width: 150,
        ),
      ];

      List<PlutoRow> rows = RowHelper.count(10, columns);

      PlutoGridStateManager stateManager = getStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: scroll,
      );

      stateManager.setLayout(
        const BoxConstraints(maxWidth: 700, maxHeight: 600),
      );

      stateManager.toggleFrozenColumn(columns[2], PlutoColumnFrozen.end);

      stateManager.setLayout(
        const BoxConstraints(maxWidth: 700, maxHeight: 600),
      );

      // when
      // then
      expect(stateManager.columnIndexesByShowFrozen, [0, 1, 3, 2, 4]);
    });
  });

  testWidgets(
    '고정 컬럼이 있고 넓이가 넓이가 충분한 경우 고정 컬럼이 보여지는 상태에서, '
    '고정 컬럼 넓이를 제약범위보다 크게 변경하면 넓이가 변경 되지 않아야 한다.',
    (WidgetTester tester) async {
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn(
          'left',
          count: 1,
          frozen: PlutoColumnFrozen.start,
          width: 150,
        ),
        ...ColumnHelper.textColumn('body', count: 3, width: 150),
        ...ColumnHelper.textColumn(
          'right',
          count: 1,
          frozen: PlutoColumnFrozen.end,
          width: 150,
        ),
      ];

      List<PlutoRow> rows = RowHelper.count(10, columns);

      PlutoGridStateManager stateManager = getStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: scroll,
      );

      // 150 + 200 + 150 = 최소 500 필요
      stateManager
          .setLayout(const BoxConstraints(maxWidth: 550, maxHeight: 600));

      expect(stateManager.showFrozenColumn, true);
      expect(columns.first.width, 150);

      // 최소 넓이에서 남는 50 이상 크기를 키움
      stateManager.resizeColumn(columns.first, 60);

      expect(stateManager.showFrozenColumn, true);
      expect(columns.first.width, 150);
    },
  );

  testWidgets(
    '고정 컬럼이 있지만 넓이가 좁아 고정 컬럼이 풀리면, '
    '고정 시킨 컬럼 설정이 풀려야 된다.',
    (WidgetTester tester) async {
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn(
          'left',
          count: 1,
          frozen: PlutoColumnFrozen.start,
          width: 150,
        ),
        ...ColumnHelper.textColumn('body', count: 3, width: 150),
        ...ColumnHelper.textColumn(
          'right',
          count: 1,
          frozen: PlutoColumnFrozen.end,
          width: 150,
        ),
      ];

      List<PlutoRow> rows = RowHelper.count(10, columns);

      PlutoGridStateManager stateManager = getStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: scroll,
      );

      // 150 + 200 + 150 = 최소 500 필요
      stateManager.setLayout(
        const BoxConstraints(maxWidth: 450, maxHeight: 600),
      );

      expect(stateManager.showFrozenColumn, false);
      expect(stateManager.columns[0].frozen, PlutoColumnFrozen.none);
      expect(stateManager.columns[1].frozen, PlutoColumnFrozen.none);
      expect(stateManager.columns[2].frozen, PlutoColumnFrozen.none);
      expect(stateManager.columns[3].frozen, PlutoColumnFrozen.none);
      expect(stateManager.columns[4].frozen, PlutoColumnFrozen.none);
    },
  );

  group('toggleFrozenColumn', () {
    test(
        'columnSizeConfig.restoreAutoSizeAfterFrozenColumn 이 false 면, '
        'activatedColumnsAutoSize 가 false 로 변경 되어야 한다.', () {
      final columns = ColumnHelper.textColumn('title', count: 5);

      PlutoGridStateManager stateManager = getStateManager(
        columns: columns,
        rows: [],
        gridFocusNode: null,
        scroll: scroll,
        configuration: const PlutoGridConfiguration(
          columnSize: PlutoGridColumnSizeConfig(
            autoSizeMode: PlutoAutoSizeMode.equal,
            restoreAutoSizeAfterFrozenColumn: false,
          ),
        ),
      );

      stateManager.setLayout(
        const BoxConstraints(maxWidth: 450, maxHeight: 600),
      );

      expect(stateManager.activatedColumnsAutoSize, true);

      stateManager.toggleFrozenColumn(columns.first, PlutoColumnFrozen.start);

      expect(stateManager.activatedColumnsAutoSize, false);
    });
  });

  group('insertColumns', () {
    testWidgets(
      '기존 컬럼이 없는 상태에서 0번 인덱스에 컬럼 1개가 추가 되어야 한다.',
      (WidgetTester tester) async {
        const columnIdxToInsert = 0;

        final List<PlutoColumn> columnsToInsert = ColumnHelper.textColumn(
          'column',
          count: 1,
        );

        final List<PlutoColumn> columns = [];

        final List<PlutoRow> rows = [];

        PlutoGridStateManager stateManager = getStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: scroll,
        );

        stateManager.setLayout(const BoxConstraints(maxWidth: 800));

        stateManager.insertColumns(columnIdxToInsert, columnsToInsert);

        expect(stateManager.refColumns.length, 1);
      },
    );

    testWidgets(
      '기존 컬럼 1개 있는 상태에서 0번 인덱스에 컬럼 1개가 추가 되어야 한다.',
      (WidgetTester tester) async {
        const columnIdxToInsert = 0;

        final List<PlutoColumn> columnsToInsert = ColumnHelper.textColumn(
          'column',
          count: 1,
          start: 1,
        );

        final List<PlutoColumn> columns = ColumnHelper.textColumn(
          'column',
          count: 1,
          start: 0,
        );

        final List<PlutoRow> rows = [];

        PlutoGridStateManager stateManager = getStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: scroll,
        );

        stateManager.setLayout(const BoxConstraints(maxWidth: 800));

        stateManager.insertColumns(columnIdxToInsert, columnsToInsert);

        expect(stateManager.refColumns.length, 2);

        expect(stateManager.refColumns[0].key, columnsToInsert[0].key);
      },
    );

    testWidgets(
      '기존 컬럼 1개 있는 상태에서 추가된 컬럼의 셀이 행에 추가 되어야 한다.',
      (WidgetTester tester) async {
        const columnIdxToInsert = 0;

        const defaultValue = 'inserted column';

        final List<PlutoColumn> columnsToInsert = ColumnHelper.textColumn(
          'column',
          count: 1,
          start: 1,
          defaultValue: defaultValue,
        );

        final List<PlutoColumn> columns = ColumnHelper.textColumn(
          'column',
          count: 1,
          start: 0,
        );

        final List<PlutoRow> rows = RowHelper.count(2, columns);

        PlutoGridStateManager stateManager = getStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: scroll,
        );

        stateManager.setLayout(const BoxConstraints(maxWidth: 800));

        stateManager.insertColumns(columnIdxToInsert, columnsToInsert);

        expect(
          stateManager.refRows[0].cells['column1']!.value,
          defaultValue,
        );

        expect(
          stateManager.refRows[1].cells['column1']!.value,
          defaultValue,
        );
      },
    );

    test(
        'columnSizeConfig.restoreAutoSizeAfterInsertColumn 이 false 면, '
        'activatedColumnsAutoSize 가 false 로 변경 되어야 한다.', () {
      final columns = ColumnHelper.textColumn('title', count: 5);

      PlutoGridStateManager stateManager = getStateManager(
        columns: columns,
        rows: [],
        gridFocusNode: null,
        scroll: scroll,
        configuration: const PlutoGridConfiguration(
          columnSize: PlutoGridColumnSizeConfig(
            autoSizeMode: PlutoAutoSizeMode.equal,
            restoreAutoSizeAfterInsertColumn: false,
          ),
        ),
      );

      stateManager.setLayout(
        const BoxConstraints(maxWidth: 450, maxHeight: 600),
      );

      expect(stateManager.activatedColumnsAutoSize, true);

      stateManager.insertColumns(0, ColumnHelper.textColumn('title'));

      expect(stateManager.activatedColumnsAutoSize, false);
    });
  });

  group('removeColumns', () {
    testWidgets(
      '0번 컬럼을 삭제하면 컬럼이 삭제되어야 한다.',
      (WidgetTester tester) async {
        final List<PlutoColumn> columns = ColumnHelper.textColumn(
          'column',
          count: 10,
        );

        final List<PlutoRow> rows = RowHelper.count(2, columns);

        PlutoGridStateManager stateManager = getStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: scroll,
        );

        stateManager.setLayout(const BoxConstraints(maxWidth: 800));

        stateManager.removeColumns([columns[0]]);

        expect(stateManager.refColumns.length, 9);
      },
    );

    testWidgets(
      '0번 컬럼을 삭제하면 해당 컬럼의 셀이 삭제 되어야 한다.',
      (WidgetTester tester) async {
        final List<PlutoColumn> columns = ColumnHelper.textColumn(
          'column',
          count: 10,
        );

        final List<PlutoRow> rows = RowHelper.count(2, columns);

        PlutoGridStateManager stateManager = getStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: scroll,
        );

        stateManager.setLayout(const BoxConstraints(maxWidth: 800));

        expect(stateManager.refRows[0].cells.entries.length, 10);

        stateManager.removeColumns([columns[0]]);

        expect(stateManager.refRows[0].cells.entries.length, 9);
      },
    );

    testWidgets(
      '8, 8번 컬럼을 삭제하면 해당 컬럼의 셀이 삭제 되어야 한다.',
      (WidgetTester tester) async {
        final List<PlutoColumn> columns = ColumnHelper.textColumn(
          'column',
          count: 10,
        );

        final List<PlutoRow> rows = RowHelper.count(2, columns);

        PlutoGridStateManager stateManager = getStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: scroll,
        );

        stateManager.setLayout(const BoxConstraints(maxWidth: 800));

        expect(stateManager.refRows[0].cells.entries.length, 10);

        stateManager.removeColumns([columns[8], columns[9]]);

        expect(stateManager.refRows[0].cells.entries.length, 8);
      },
    );

    testWidgets(
      '컬럼 그룹이 있는 상태에서 컬럼을 삭제하면 빈 그룹이 삭제 되어야 한다.',
      (WidgetTester tester) async {
        final List<PlutoColumn> columns = ColumnHelper.textColumn(
          'column',
          count: 10,
        );

        final List<PlutoColumnGroup> columnGroups = [
          PlutoColumnGroup(title: 'a', fields: ['column0']),
          PlutoColumnGroup(
              title: 'b',
              fields: columns
                  .where((element) => element.field != 'column0')
                  .map((e) => e.field)
                  .toList()),
        ];

        final List<PlutoRow> rows = RowHelper.count(2, columns);

        PlutoGridStateManager stateManager = getStateManager(
          columns: columns,
          columnGroups: columnGroups,
          rows: rows,
          gridFocusNode: null,
          scroll: scroll,
        );

        stateManager.setLayout(const BoxConstraints(maxWidth: 800));

        stateManager.removeColumns([columns[0]]);

        expect(stateManager.columnGroups.length, 1);

        expect(stateManager.columnGroups[0].title, 'b');
      },
    );

    testWidgets(
      '컬럼 그룹이 있는 상태에서 컬럼을 삭제하면 해당 그룹에서 컬럼이 삭제되어야 한다.',
      (WidgetTester tester) async {
        final List<PlutoColumn> columns = ColumnHelper.textColumn(
          'column',
          count: 10,
        );

        final List<PlutoColumnGroup> columnGroups = [
          PlutoColumnGroup(title: 'a', fields: ['column0']),
          PlutoColumnGroup(
              title: 'b',
              fields: columns
                  .where((element) => element.field != 'column0')
                  .map((e) => e.field)
                  .toList()),
        ];

        final List<PlutoRow> rows = RowHelper.count(2, columns);

        PlutoGridStateManager stateManager = getStateManager(
          columns: columns,
          columnGroups: columnGroups,
          rows: rows,
          gridFocusNode: null,
          scroll: scroll,
        );

        stateManager.setLayout(const BoxConstraints(maxWidth: 800));

        stateManager.removeColumns([columns[1]]);

        expect(stateManager.columnGroups.length, 2);

        expect(
          stateManager.columnGroups[1].fields!.contains('column1'),
          false,
        );

        expect(stateManager.columnGroups[1].fields!.length, 8);
      },
    );

    testWidgets(
      '하위 컬럼 그룹이 있는 상태에서 컬럼을 삭제하면 빈 해당 하위 그룹이 삭제 되어야 한다.',
      (WidgetTester tester) async {
        final List<PlutoColumn> columns = ColumnHelper.textColumn(
          'column',
          count: 10,
        );

        final List<PlutoColumnGroup> columnGroups = [
          PlutoColumnGroup(title: 'a', fields: ['column0']),
          PlutoColumnGroup(
            title: 'b',
            children: [
              PlutoColumnGroup(title: 'c', fields: ['column1']),
              PlutoColumnGroup(
                  title: 'd',
                  fields: columns
                      .where((element) =>
                          !['column0', 'column1'].contains(element.field))
                      .map((e) => e.field)
                      .toList()),
            ],
          ),
        ];

        final List<PlutoRow> rows = RowHelper.count(2, columns);

        PlutoGridStateManager stateManager = getStateManager(
          columns: columns,
          columnGroups: columnGroups,
          rows: rows,
          gridFocusNode: null,
          scroll: scroll,
        );

        stateManager.setLayout(const BoxConstraints(maxWidth: 800));

        expect(stateManager.columnGroups[1].children!.length, 2);

        stateManager.removeColumns([columns[1]]);

        expect(stateManager.columnGroups[1].children!.length, 1);

        expect(stateManager.columnGroups[1].children![0].title, 'd');
      },
    );

    testWidgets(
      '필터가 있는 컬럼을 삭제 한 경우 해당 컬럼의 필터가 삭제 되어야 한다.',
      (WidgetTester tester) async {
        final List<PlutoColumn> columns = ColumnHelper.textColumn(
          'column',
          count: 10,
        );

        final List<PlutoRow> rows = RowHelper.count(2, columns);

        final List<PlutoRow> filterRows = [
          FilterHelper.createFilterRow(
            columnField: columns[0].field,
            filterType: const PlutoFilterTypeContains(),
            filterValue: 'filter',
          ),
          FilterHelper.createFilterRow(
            columnField: columns[0].field,
            filterType: const PlutoFilterTypeContains(),
            filterValue: 'filter',
          ),
        ];

        PlutoGridStateManager stateManager = getStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: scroll,
        );

        stateManager.setLayout(const BoxConstraints(maxWidth: 800));

        stateManager.setFilterWithFilterRows(filterRows);

        expect(stateManager.filterRows.length, 2);

        stateManager.removeColumns([columns[0]]);

        expect(stateManager.filterRows.length, 0);
      },
    );

    test(
        'columnSizeConfig.restoreAutoSizeAfterRemoveColumn 이 false 면, '
        'activatedColumnsAutoSize 가 false 로 변경 되어야 한다.', () {
      final columns = ColumnHelper.textColumn('title', count: 5);

      PlutoGridStateManager stateManager = getStateManager(
        columns: columns,
        rows: [],
        gridFocusNode: null,
        scroll: scroll,
        configuration: const PlutoGridConfiguration(
          columnSize: PlutoGridColumnSizeConfig(
            autoSizeMode: PlutoAutoSizeMode.equal,
            restoreAutoSizeAfterRemoveColumn: false,
          ),
        ),
      );

      stateManager.setLayout(
        const BoxConstraints(maxWidth: 450, maxHeight: 600),
      );

      expect(stateManager.activatedColumnsAutoSize, true);

      stateManager.removeColumns([columns.first]);

      expect(stateManager.activatedColumnsAutoSize, false);
    });
  });

  group('moveColumn', () {
    test('고정 컬럼 제한으로 컬럼이동이 불가하면 notifyListeners 가 호출 되지 않아야 한다.', () async {
      final columns = ColumnHelper.textColumn('title', count: 5);

      PlutoGridStateManager stateManager = getStateManager(
        columns: columns,
        rows: [],
        gridFocusNode: null,
        scroll: scroll,
      );

      stateManager.setLayout(const BoxConstraints(maxWidth: 500));

      final listeners = MockMethods();

      stateManager.addListener(listeners.noParamReturnVoid);

      final column = columns[0];

      final targetColumn = columns[1]..frozen = PlutoColumnFrozen.start;

      stateManager.moveColumn(
        column: column,
        targetColumn: targetColumn,
      );

      verifyNever(listeners.noParamReturnVoid());
    });

    test('고정 컬럼 넓이가 충분하면 notifyListeners 가 호출 되어야 한다.', () async {
      final columns = ColumnHelper.textColumn('title', count: 5);

      PlutoGridStateManager stateManager = getStateManager(
        columns: columns,
        rows: [],
        gridFocusNode: null,
        scroll: scroll,
      );

      stateManager.setLayout(const BoxConstraints(maxWidth: 500));

      final listeners = MockMethods();

      stateManager.addListener(listeners.noParamReturnVoid);

      final column = columns[0]..width = 50;

      final targetColumn = columns[1]..frozen = PlutoColumnFrozen.start;

      stateManager.moveColumn(
        column: column,
        targetColumn: targetColumn,
      );

      verify(listeners.noParamReturnVoid()).called(1);
    });

    test('0 번 비고정 컬럼을 4번 우측 고정 컬럼으로 이동 시키면 컬럼 순서가 바뀌어야 한다.', () async {
      final columns = ColumnHelper.textColumn('title', count: 5);

      columns[0].frozen = PlutoColumnFrozen.none;
      columns[1].frozen = PlutoColumnFrozen.none;
      columns[2].frozen = PlutoColumnFrozen.start;
      columns[3].frozen = PlutoColumnFrozen.start;
      columns[4].frozen = PlutoColumnFrozen.end;

      PlutoGridStateManager stateManager = getStateManager(
        columns: columns,
        rows: [],
        gridFocusNode: null,
        scroll: scroll,
      );

      stateManager.setLayout(const BoxConstraints(maxWidth: 1200));

      stateManager.moveColumn(
        column: columns[0],
        targetColumn: columns[4],
      );

      expect(stateManager.refColumns[0].title, 'title1');
      expect(stateManager.refColumns[1].title, 'title2');
      expect(stateManager.refColumns[2].title, 'title3');
      expect(stateManager.refColumns[3].title, 'title4');
      expect(stateManager.refColumns[4].title, 'title0');
    });

    test('4 번 비고정 컬럼을 1번 좌측 고정 컬럼으로 이동 시키면 컬럼 순서가 바뀌어야 한다.', () async {
      final columns = ColumnHelper.textColumn('title', count: 5);

      columns[0].frozen = PlutoColumnFrozen.none;
      columns[1].frozen = PlutoColumnFrozen.start;
      columns[2].frozen = PlutoColumnFrozen.none;
      columns[3].frozen = PlutoColumnFrozen.none;
      columns[4].frozen = PlutoColumnFrozen.none;

      PlutoGridStateManager stateManager = getStateManager(
        columns: columns,
        rows: [],
        gridFocusNode: null,
        scroll: scroll,
      );

      stateManager.setLayout(const BoxConstraints(maxWidth: 1200));

      stateManager.moveColumn(
        column: columns[4],
        targetColumn: columns[1],
      );

      expect(stateManager.refColumns[0].title, 'title0');
      expect(stateManager.refColumns[1].title, 'title4');
      expect(stateManager.refColumns[2].title, 'title1');
      expect(stateManager.refColumns[3].title, 'title2');
      expect(stateManager.refColumns[4].title, 'title3');
    });

    test('3번 좌측 고정을 1번 비고정 컬럼으로 이동 시키면 컬럼 순서가 바뀌어야 한다.', () async {
      final columns = ColumnHelper.textColumn('title', count: 5);

      columns[0].frozen = PlutoColumnFrozen.none;
      columns[1].frozen = PlutoColumnFrozen.none;
      columns[2].frozen = PlutoColumnFrozen.none;
      columns[3].frozen = PlutoColumnFrozen.start;
      columns[4].frozen = PlutoColumnFrozen.none;

      PlutoGridStateManager stateManager = getStateManager(
        columns: columns,
        rows: [],
        gridFocusNode: null,
        scroll: scroll,
      );

      stateManager.setLayout(const BoxConstraints(maxWidth: 1200));

      stateManager.moveColumn(
        column: columns[3],
        targetColumn: columns[1],
      );

      // 3번이 좌측 고정 되어있어 1번 보다 우측에 있다.
      // 3번 컬럼이 1번 컬럼 우측으로 이동하면 1번 좌측에 있는 3번이 빠지면서
      // 3번이 1번의 위치에 위치한다.
      expect(stateManager.refColumns[0].title, 'title0');
      expect(stateManager.refColumns[1].title, 'title1');
      expect(stateManager.refColumns[2].title, 'title3');
      expect(stateManager.refColumns[3].title, 'title2');
      expect(stateManager.refColumns[4].title, 'title4');
    });

    test('1번 우측 고정을 4번 비고정 컬럼으로 이동 시키면 컬럼 순서가 바뀌어야 한다.', () async {
      final columns = ColumnHelper.textColumn('title', count: 5);

      columns[0].frozen = PlutoColumnFrozen.none;
      columns[1].frozen = PlutoColumnFrozen.end;
      columns[2].frozen = PlutoColumnFrozen.none;
      columns[3].frozen = PlutoColumnFrozen.none;
      columns[4].frozen = PlutoColumnFrozen.none;

      PlutoGridStateManager stateManager = getStateManager(
        columns: columns,
        rows: [],
        gridFocusNode: null,
        scroll: scroll,
      );

      stateManager.setLayout(const BoxConstraints(maxWidth: 1200));

      stateManager.moveColumn(
        column: columns[1],
        targetColumn: columns[4],
      );

      // 1번이 우측 고정 되어 4번 보다 우측에 있는 상태에서
      // 1번이 4번 위치로 가고 4번은 1번 좌측에 위치하게 된다.
      expect(stateManager.refColumns[0].title, 'title0');
      expect(stateManager.refColumns[1].title, 'title2');
      expect(stateManager.refColumns[2].title, 'title3');
      expect(stateManager.refColumns[3].title, 'title1');
      expect(stateManager.refColumns[4].title, 'title4');
    });

    test(
        'columnSizeConfig.restoreAutoSizeAfterMoveColumn 이 false 면, '
        'activatedColumnsAutoSize 가 false 로 변경 되어야 한다.', () {
      final columns = ColumnHelper.textColumn('title', count: 5);

      PlutoGridStateManager stateManager = getStateManager(
        columns: columns,
        rows: [],
        gridFocusNode: null,
        scroll: scroll,
        configuration: const PlutoGridConfiguration(
          columnSize: PlutoGridColumnSizeConfig(
            autoSizeMode: PlutoAutoSizeMode.equal,
            restoreAutoSizeAfterMoveColumn: false,
          ),
        ),
      );

      stateManager.setLayout(
        const BoxConstraints(maxWidth: 450, maxHeight: 600),
      );

      expect(stateManager.activatedColumnsAutoSize, true);

      stateManager.moveColumn(
        column: columns.first,
        targetColumn: columns.last,
      );

      expect(stateManager.activatedColumnsAutoSize, false);
    });
  });

  group('resizeColumn', () {
    test('columnsResizeMode.isNone 이면 notifyResizingListeners 가 호출 되지 않아야 한다.',
        () {
      final columns = ColumnHelper.textColumn('title', count: 5);
      final mockListener = MockMethods();

      PlutoGridStateManager stateManager = getStateManager(
          columns: columns,
          rows: [],
          gridFocusNode: null,
          scroll: scroll,
          configuration: const PlutoGridConfiguration(
            columnSize: PlutoGridColumnSizeConfig(
              resizeMode: PlutoResizeMode.none,
            ),
          ));

      stateManager.setLayout(const BoxConstraints(maxWidth: 800));

      stateManager.resizingChangeNotifier.addListener(
        mockListener.noParamReturnVoid,
      );

      stateManager.resizeColumn(columns.first, 10);

      verifyNever(mockListener.noParamReturnVoid());

      stateManager.resizingChangeNotifier.removeListener(
        mockListener.noParamReturnVoid,
      );
    });

    test(
        'column.enableDropToResize 가 false 이면 notifyResizingListeners 가 호출 되지 않아야 한다.',
        () {
      final columns = ColumnHelper.textColumn('title', count: 5);
      final mockListener = MockMethods();

      PlutoGridStateManager stateManager = getStateManager(
          columns: columns,
          rows: [],
          gridFocusNode: null,
          scroll: scroll,
          configuration: const PlutoGridConfiguration(
            columnSize: PlutoGridColumnSizeConfig(
              resizeMode: PlutoResizeMode.normal,
            ),
          ));

      stateManager.setLayout(const BoxConstraints(maxWidth: 800));

      stateManager.resizingChangeNotifier.addListener(
        mockListener.noParamReturnVoid,
      );

      stateManager.resizeColumn(columns.first..enableDropToResize = false, 10);

      verifyNever(mockListener.noParamReturnVoid());

      stateManager.resizingChangeNotifier.removeListener(
        mockListener.noParamReturnVoid,
      );
    });

    test('offset 10 만큼 컬럼의 넓이가 늘어나야 한다.', () {
      final columns = ColumnHelper.textColumn('title', count: 5);
      final mockListener = MockMethods();

      PlutoGridStateManager stateManager = getStateManager(
          columns: columns,
          rows: [],
          gridFocusNode: null,
          scroll: scroll,
          configuration: const PlutoGridConfiguration(
            columnSize: PlutoGridColumnSizeConfig(
              resizeMode: PlutoResizeMode.normal,
            ),
          ));

      stateManager.setLayout(const BoxConstraints(maxWidth: 800));

      stateManager.resizingChangeNotifier.addListener(
        mockListener.noParamReturnVoid,
      );

      expect(columns.first.width, 200);

      stateManager.resizeColumn(columns.first, 10);

      verify(mockListener.noParamReturnVoid()).called(1);
      expect(columns.first.width, 210);

      stateManager.resizingChangeNotifier.removeListener(
        mockListener.noParamReturnVoid,
      );
    });

    test(
      'PlutoResizeMode.pushAndPull 인경우 scroll.horizontal.notifyListeners 호출 되어야 한다.',
      () {
        final columns = ColumnHelper.textColumn('title', count: 5);

        PlutoGridStateManager stateManager = getStateManager(
            columns: columns,
            rows: [],
            gridFocusNode: null,
            scroll: scroll,
            configuration: const PlutoGridConfiguration(
              columnSize: PlutoGridColumnSizeConfig(
                resizeMode: PlutoResizeMode.pushAndPull,
              ),
            ));

        stateManager.setLayout(const BoxConstraints(maxWidth: 800));

        reset(horizontal);

        stateManager.resizeColumn(columns.first, 10);

        verify(horizontal.notifyListeners()).called(1);
      },
    );
  });

  group('autoFitColumn', () {
    testWidgets('가장 넓은 셀이 컬럼 최소 넓이보다 작은 경우 최소 넓이로 변경 되어야 한다.', (tester) async {
      final columns = ColumnHelper.textColumn('title');

      final rows = RowHelper.count(3, columns);
      rows[0].cells['title0']!.value = 'a';
      rows[1].cells['title0']!.value = 'ab';
      rows[2].cells['title0']!.value = 'abc';

      late final BuildContext context;

      PlutoGridStateManager stateManager = getStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: scroll,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: Builder(
              builder: (builderContext) {
                context = builderContext;
                return Directionality(
                  textDirection: TextDirection.ltr,
                  child: PlutoBaseColumn(
                    stateManager: stateManager,
                    column: columns.first,
                  ),
                );
              },
            ),
          ),
        ),
      );

      stateManager.autoFitColumn(context, columns.first);

      expect(columns.first.width, columns.first.minWidth);
    });

    testWidgets('가장 넓은 셀이 컬럼 최소 넓이보다 큰 경우 최소 넓이 이상으로 변경 되어야 한다.',
        (tester) async {
      final columns = ColumnHelper.textColumn('title');

      final rows = RowHelper.count(3, columns);
      rows[0].cells['title0']!.value = 'a';
      rows[1].cells['title0']!.value = 'ab';
      rows[2].cells['title0']!.value = 'abc abc abc';

      late final BuildContext context;

      PlutoGridStateManager stateManager = getStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: scroll,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: Builder(
              builder: (builderContext) {
                context = builderContext;
                return Directionality(
                  textDirection: TextDirection.ltr,
                  child: PlutoBaseColumn(
                    stateManager: stateManager,
                    column: columns.first,
                  ),
                );
              },
            ),
          ),
        ),
      );

      stateManager.autoFitColumn(context, columns.first);

      expect(columns.first.width, greaterThan(columns.first.minWidth));
    });
  });

  group('hideColumn', () {
    testWidgets('flag 를 true 로 호출 한 경우 컬럼의 hide 가 true 로 변경 되어야 한다.',
        (WidgetTester tester) async {
      // given
      var columns = [
        PlutoColumn(title: '', field: '', type: PlutoColumnType.text()),
        PlutoColumn(title: '', field: '', type: PlutoColumnType.text()),
        PlutoColumn(title: '', field: '', type: PlutoColumnType.text()),
      ];

      PlutoGridStateManager stateManager = getStateManager(
        columns: columns,
        rows: [],
        gridFocusNode: null,
        scroll: scroll,
      );

      // when
      expect(stateManager.columns.first.hide, isFalse);

      stateManager.setLayout(const BoxConstraints(maxWidth: 800));

      stateManager.hideColumn(columns.first, true);

      // then
      expect(stateManager.refColumns.originalList.first.hide, isTrue);
    });

    testWidgets(
        'hide 가 true 인 컬럼을 flag 를 false 로 호출하여 hide 가 false 로 변경 되어야 한다.',
        (WidgetTester tester) async {
      // given
      var columns = [
        PlutoColumn(
          title: '',
          field: '',
          type: PlutoColumnType.text(),
          hide: true,
        ),
        PlutoColumn(title: '', field: '', type: PlutoColumnType.text()),
        PlutoColumn(title: '', field: '', type: PlutoColumnType.text()),
      ];

      PlutoGridStateManager stateManager = getStateManager(
        columns: columns,
        rows: [],
        gridFocusNode: null,
        scroll: scroll,
      );

      stateManager.setLayout(const BoxConstraints(maxWidth: 800));

      // when
      expect(stateManager.refColumns.originalList.first.hide, isTrue);

      stateManager.hideColumn(columns.first, false);

      // then
      expect(stateManager.columns.first.hide, isFalse);
    });

    testWidgets(
      '고정 컬럼인 hide 가 true 인 컬럼을 flag 를 false 로 호출 할 때, '
      '고정 컬럼 제약 넓이가 좁은 경우 컬럼의 고정 상태가 풀려야 한다.',
      (WidgetTester tester) async {
        // given
        var columns = [
          PlutoColumn(
            title: '',
            field: '',
            width: 700,
            type: PlutoColumnType.text(),
            hide: true,
          ),
          PlutoColumn(title: '', field: '', type: PlutoColumnType.text()),
          PlutoColumn(title: '', field: '', type: PlutoColumnType.text()),
        ];

        PlutoGridStateManager stateManager = getStateManager(
          columns: columns,
          rows: [],
          gridFocusNode: null,
          scroll: scroll,
        );

        stateManager.setLayout(const BoxConstraints(maxWidth: 800));

        stateManager.columns.first.frozen = PlutoColumnFrozen.start;

        // when
        expect(stateManager.refColumns.originalList.first.hide, isTrue);

        stateManager.hideColumn(columns.first, false);

        // then
        expect(stateManager.columns.first.hide, isFalse);

        expect(stateManager.columns.first.frozen, PlutoColumnFrozen.none);
      },
    );

    testWidgets('flag 를 true 로 호출 한 경우 notifyListeners 가 호출 되어야 한다.',
        (WidgetTester tester) async {
      // given
      var columns = [
        PlutoColumn(title: '', field: '', type: PlutoColumnType.text()),
        PlutoColumn(title: '', field: '', type: PlutoColumnType.text()),
        PlutoColumn(title: '', field: '', type: PlutoColumnType.text()),
      ];

      PlutoGridStateManager stateManager = getStateManager(
        columns: columns,
        rows: [],
        gridFocusNode: null,
        scroll: scroll,
      );

      stateManager.setLayout(const BoxConstraints(maxWidth: 800));

      var listeners = MockMethods();

      stateManager.addListener(listeners.noParamReturnVoid);

      // when
      expect(stateManager.columns.first.hide, isFalse);

      stateManager.hideColumn(columns.first, true);

      // then
      verify(listeners.noParamReturnVoid()).called(1);
    });

    testWidgets(
        'hide 가 false 이 경우 flag 를 false 로 호출 하면 notifyListeners 가 호출 되지 않아야 한다.',
        (WidgetTester tester) async {
      // given
      var columns = [
        PlutoColumn(title: '', field: '', type: PlutoColumnType.text()),
        PlutoColumn(title: '', field: '', type: PlutoColumnType.text()),
        PlutoColumn(title: '', field: '', type: PlutoColumnType.text()),
      ];

      PlutoGridStateManager stateManager = getStateManager(
        columns: columns,
        rows: [],
        gridFocusNode: null,
        scroll: scroll,
      );

      var listeners = MockMethods();

      stateManager.addListener(listeners.noParamReturnVoid);

      // when
      expect(stateManager.columns.first.hide, isFalse);

      stateManager.hideColumn(columns.first, false);

      // then
      verifyNever(listeners.noParamReturnVoid());
    });
  });

  group('hideColumns', () {
    test('columns 가 empty 면 notifyListeners 가 호출 되지 않아야 한다.', () async {
      final columns = <PlutoColumn>[];

      PlutoGridStateManager stateManager = getStateManager(
        columns: columns,
        rows: [],
        gridFocusNode: null,
        scroll: scroll,
      );

      var listeners = MockMethods();

      stateManager.addListener(listeners.noParamReturnVoid);

      stateManager.hideColumns(columns, true);

      verifyNever(listeners.noParamReturnVoid());
    });

    test('columns 가 empty 가 아니면 notifyListeners 가 호출 되어야 한다.', () async {
      final columns = ColumnHelper.textColumn('title', count: 5);

      PlutoGridStateManager stateManager = getStateManager(
        columns: columns,
        rows: [],
        gridFocusNode: null,
        scroll: scroll,
      );

      stateManager.setLayout(const BoxConstraints(maxWidth: 800));

      var listeners = MockMethods();

      stateManager.addListener(listeners.noParamReturnVoid);

      stateManager.hideColumns(columns, true);

      verify(listeners.noParamReturnVoid()).called(1);
    });

    test('hide 가 true 면 컬럼이 모두 업데이트 되어야 한다.', () async {
      final columns = ColumnHelper.textColumn('title', count: 5);

      PlutoGridStateManager stateManager = getStateManager(
        columns: columns,
        rows: [],
        gridFocusNode: null,
        scroll: scroll,
      );

      stateManager.setLayout(const BoxConstraints(maxWidth: 800));

      stateManager.hideColumns(columns, true);

      final hideList = stateManager.refColumns.originalList.where(
        (element) => element.hide,
      );

      expect(hideList.length, 5);
    });

    test(
      '0, 1 번 컬럼을 hide 를 false 로 호출 하면 컬럼이 모두 업데이트 되어야 한다.',
      () async {
        final columns = ColumnHelper.textColumn('title', count: 5, hide: true);

        PlutoGridStateManager stateManager = getStateManager(
          columns: columns,
          rows: [],
          gridFocusNode: null,
          scroll: scroll,
        );

        stateManager.setLayout(const BoxConstraints(maxWidth: 1000));

        stateManager.hideColumns(columns.getRange(0, 2).toList(), false);

        // 호출 한 컬럼
        expect(columns[0].hide, false);
        expect(columns[1].hide, false);
        // 호출 하지 않은 컬럼
        expect(columns[2].hide, true);
        expect(columns[3].hide, true);
        expect(columns[4].hide, true);
      },
    );

    test(
      '고정 컬럼 제약 조건이 부족한 상태에서 0, 1번 컬럼을 hide 를 false 로 호출 하면 '
      'frozen 컬럼이 none 으로 변경 되어야 한다.',
      () async {
        final columns = ColumnHelper.textColumn(
          'title',
          count: 5,
          hide: true,
          frozen: PlutoColumnFrozen.start,
        );

        PlutoGridStateManager stateManager = getStateManager(
          columns: columns,
          rows: [],
          gridFocusNode: null,
          scroll: scroll,
        );

        stateManager.setLayout(const BoxConstraints(maxWidth: 300));

        // setLayout 실행 시 고정 컬럼이 하나도 없어 showFrozenColumn 이 false 이면
        // 모든 컬럼의 frozen 을 none 으로 초기화 하여 테스트를 위해 다시 고정 컬럼으로 설정.
        for (final column in columns) {
          column.frozen = PlutoColumnFrozen.start;
        }

        stateManager.hideColumns(columns.getRange(0, 2).toList(), false);

        // 호출 한 컬럼
        expect(columns[0].hide, false);
        expect(columns[0].frozen, PlutoColumnFrozen.none);
        expect(columns[1].hide, false);
        expect(columns[1].frozen, PlutoColumnFrozen.none);
        // 호출 하지 않은 컬럼
        expect(columns[2].hide, true);
        expect(columns[2].frozen, PlutoColumnFrozen.start);
        expect(columns[3].hide, true);
        expect(columns[3].frozen, PlutoColumnFrozen.start);
        expect(columns[4].hide, true);
        expect(columns[4].frozen, PlutoColumnFrozen.start);
      },
    );
  });

  group('limitResizeColumn', () {
    test('offset 이 0 보다 작으면 false 를 리턴해야 한다.', () {
      final PlutoColumn column = PlutoColumn(
        title: 'title',
        field: 'field',
        type: PlutoColumnType.text(),
      );

      const offset = -1.0;

      PlutoGridStateManager stateManager = getStateManager(
        columns: [column],
        rows: [],
        gridFocusNode: null,
        scroll: scroll,
      );

      expect(stateManager.limitResizeColumn(column, offset), false);
    });

    test('column 의 frozen 이 none 이면 false 를 리턴해야 한다.', () {
      final PlutoColumn column = PlutoColumn(
        title: 'title',
        field: 'field',
        type: PlutoColumnType.text(),
        frozen: PlutoColumnFrozen.none,
      );

      const offset = 1.0;

      PlutoGridStateManager stateManager = getStateManager(
        columns: [column],
        rows: [],
        gridFocusNode: null,
        scroll: scroll,
      );

      expect(stateManager.limitResizeColumn(column, offset), false);
    });

    test('고정 컬럼의 넓이를 제약 조건 범위에서 offset 을 호출 하면 false 를 리턴해야 한다.', () {
      final PlutoColumn column = PlutoColumn(
        title: 'title',
        field: 'field',
        type: PlutoColumnType.text(),
        frozen: PlutoColumnFrozen.start,
        width: 100,
      );

      PlutoGridStateManager stateManager = getStateManager(
        columns: [
          column,
          ...ColumnHelper.textColumn('title', count: 3, width: 100),
        ],
        rows: [],
        gridFocusNode: null,
        scroll: scroll,
      );

      stateManager.setLayout(const BoxConstraints(maxWidth: 500));

      // 500 - 306 = 194 보다 작게 크기 증가 가능.
      // print(stateManager.maxWidth);
      // 좌측 고정 컬럼 하나 100
      // print(stateManager.leftFrozenColumnsWidth);
      // 우측 고정 컬럼 없음 0
      // print(stateManager.rightFrozenColumnsWidth);
      // 200
      // print(PlutoGridSettings.bodyMinWidth);
      // 6
      // print(PlutoGridSettings.totalShadowLineWidth);

      expect(stateManager.limitResizeColumn(column, 193.0), false);
    });

    test('고정 컬럼의 넓이를 제약 조건 범위 보다 크게 offset 을 호출 하면 true 를 리턴해야 한다.', () {
      final PlutoColumn column = PlutoColumn(
        title: 'title',
        field: 'field',
        type: PlutoColumnType.text(),
        frozen: PlutoColumnFrozen.start,
        width: 100,
      );

      PlutoGridStateManager stateManager = getStateManager(
        columns: [
          column,
          ...ColumnHelper.textColumn('title', count: 3, width: 100),
        ],
        rows: [],
        gridFocusNode: null,
        scroll: scroll,
      );

      stateManager.setLayout(const BoxConstraints(maxWidth: 500));

      // 500 - 306 = 194 보다 작게 크기 증가 가능.
      // print(stateManager.maxWidth);
      // 좌측 고정 컬럼 하나 100
      // print(stateManager.leftFrozenColumnsWidth);
      // 우측 고정 컬럼 없음 0
      // print(stateManager.rightFrozenColumnsWidth);
      // 200
      // print(PlutoGridSettings.bodyMinWidth);
      // 6
      // print(PlutoGridSettings.totalShadowLineWidth);

      expect(stateManager.limitResizeColumn(column, 194.0), true);
    });
  });

  group('limitMoveColumn', () {
    test(
      'column 이 고정 컬럼이면 고정 컬럼 넓이 제약을 초과 하지 않으므로 false 를 리턴 해야 한다.',
      () async {
        final PlutoColumn column = PlutoColumn(
          title: 'title1',
          field: 'field1',
          type: PlutoColumnType.text(),
          frozen: PlutoColumnFrozen.start,
          width: 100,
        );

        final PlutoColumn targetColumn = PlutoColumn(
          title: 'title2',
          field: 'field2',
          type: PlutoColumnType.text(),
          frozen: PlutoColumnFrozen.end,
          width: 100,
        );

        PlutoGridStateManager stateManager = getStateManager(
          columns: [
            column,
            ...ColumnHelper.textColumn('title', count: 3, width: 100),
          ],
          rows: [],
          gridFocusNode: null,
          scroll: scroll,
        );

        stateManager.setLayout(const BoxConstraints(maxWidth: 500));

        // 500 - 406 = 94 보다 작은 컬럼 이동 가능.
        // print(stateManager.maxWidth);
        // 좌측 고정 컬럼 하나 100
        // print(stateManager.leftFrozenColumnsWidth);
        // 우측 고정 컬럼 하나 100
        // print(stateManager.rightFrozenColumnsWidth);
        // 200
        // print(PlutoGridSettings.bodyMinWidth);
        // 6
        // print(PlutoGridSettings.totalShadowLineWidth);

        expect(
          stateManager.limitMoveColumn(
            column: column,
            targetColumn: targetColumn,
          ),
          false,
        );
      },
    );

    test(
      '고정 컬럼을 일반 컬럼 영역으로 이동 하면 제약이 없으므로 false 를 리턴 해야 한다.',
      () async {
        final PlutoColumn column = PlutoColumn(
          title: 'title1',
          field: 'field1',
          type: PlutoColumnType.text(),
          frozen: PlutoColumnFrozen.start,
          width: 100,
        );

        final PlutoColumn targetColumn = PlutoColumn(
          title: 'title2',
          field: 'field2',
          type: PlutoColumnType.text(),
          frozen: PlutoColumnFrozen.none,
          width: 100,
        );

        PlutoGridStateManager stateManager = getStateManager(
          columns: [
            column,
            ...ColumnHelper.textColumn('title', count: 3, width: 100),
          ],
          rows: [],
          gridFocusNode: null,
          scroll: scroll,
        );

        stateManager.setLayout(const BoxConstraints(maxWidth: 500));

        // 500 - 306 = 294 보다 작은 컬럼 이동 가능.
        // print(stateManager.maxWidth);
        // 좌측 고정 컬럼 하나 100
        // print(stateManager.leftFrozenColumnsWidth);
        // 우측 고정 컬럼 없음 0
        // print(stateManager.rightFrozenColumnsWidth);
        // 200
        // print(PlutoGridSettings.bodyMinWidth);
        // 6
        // print(PlutoGridSettings.totalShadowLineWidth);

        expect(
          stateManager.limitMoveColumn(
            column: column,
            targetColumn: targetColumn,
          ),
          false,
        );
      },
    );

    test(
      '일반 컬럼을 고정 컬럼 영역으로 이동 할 때 제약 조건 넓이가 충분하면 false 를 리턴 해야 한다.',
      () async {
        final PlutoColumn column = PlutoColumn(
          title: 'title1',
          field: 'field1',
          type: PlutoColumnType.text(),
          frozen: PlutoColumnFrozen.none,
          width: 100,
        );

        final PlutoColumn targetColumn = PlutoColumn(
          title: 'title2',
          field: 'field2',
          type: PlutoColumnType.text(),
          frozen: PlutoColumnFrozen.start,
          width: 100,
        );

        PlutoGridStateManager stateManager = getStateManager(
          columns: [
            column,
            ...ColumnHelper.textColumn('title', count: 3, width: 100),
          ],
          rows: [],
          gridFocusNode: null,
          scroll: scroll,
        );

        stateManager.setLayout(const BoxConstraints(maxWidth: 500));

        // 500 - 306 = 294 보다 작은 컬럼 이동 가능.
        // print(stateManager.maxWidth);
        // 좌측 고정 컬럼 하나 100
        // print(stateManager.leftFrozenColumnsWidth);
        // 우측 고정 컬럼 없음 0
        // print(stateManager.rightFrozenColumnsWidth);
        // 200
        // print(PlutoGridSettings.bodyMinWidth);
        // 6
        // print(PlutoGridSettings.totalShadowLineWidth);

        expect(
          stateManager.limitMoveColumn(
            column: column,
            targetColumn: targetColumn,
          ),
          false,
        );
      },
    );

    test(
      '일반 컬럼을 고정 컬럼 영역으로 이동 할 때 제약 조건 넓이가 부족하면 true 를 리턴 해야 한다.',
      () async {
        final PlutoColumn column = PlutoColumn(
          title: 'title1',
          field: 'field1',
          type: PlutoColumnType.text(),
          frozen: PlutoColumnFrozen.none,
          width: 294,
        );

        final PlutoColumn targetColumn = PlutoColumn(
          title: 'title2',
          field: 'field2',
          type: PlutoColumnType.text(),
          frozen: PlutoColumnFrozen.start,
          width: 100,
        );

        PlutoGridStateManager stateManager = getStateManager(
          columns: [
            column,
            ...ColumnHelper.textColumn('title', count: 3, width: 100),
          ],
          rows: [],
          gridFocusNode: null,
          scroll: scroll,
        );

        stateManager.setLayout(const BoxConstraints(maxWidth: 500));

        // 500 - 306 = 294 보다 작은 컬럼 이동 가능.
        // print(stateManager.maxWidth! - column.width);
        // 좌측 고정 컬럼 하나 100
        // print(stateManager.leftFrozenColumnsWidth);
        // 우측 고정 컬럼 없음 0
        // print(stateManager.rightFrozenColumnsWidth);
        // 200
        // print(PlutoGridSettings.bodyMinWidth);
        // 6
        // print(PlutoGridSettings.totalShadowLineWidth);

        expect(
          stateManager.limitMoveColumn(
            column: column,
            targetColumn: targetColumn,
          ),
          true,
        );
      },
    );
  });

  group('limitToggleFrozenColumn', () {
    test(
      'column 의 frozen 이 isFrozen 이면 토글 되었을 때 고정이 풀리므로 '
      '제약조건을 받지 않아 false 를 리턴 해야 한다.',
      () async {
        final PlutoColumn column = PlutoColumn(
          title: 'title1',
          field: 'field1',
          type: PlutoColumnType.text(),
          frozen: PlutoColumnFrozen.start,
          width: 100,
        );

        PlutoGridStateManager stateManager = getStateManager(
          columns: [
            column,
            ...ColumnHelper.textColumn('title', count: 3, width: 100),
          ],
          rows: [],
          gridFocusNode: null,
          scroll: scroll,
        );

        stateManager.setLayout(const BoxConstraints(maxWidth: 500));

        expect(
          stateManager.limitToggleFrozenColumn(column, PlutoColumnFrozen.none),
          false,
        );
      },
    );

    test(
      'column 의 frozen 이 none 이고 frozen 컬럼으로 토글 할 때, '
      '제약 조건 범위가 충분하면 false 를 리턴 해야 한다.',
      () async {
        final PlutoColumn column = PlutoColumn(
          title: 'title1',
          field: 'field1',
          type: PlutoColumnType.text(),
          frozen: PlutoColumnFrozen.none,
          width: 100,
        );

        PlutoGridStateManager stateManager = getStateManager(
          columns: [
            column,
            ...ColumnHelper.textColumn('title', count: 3, width: 100),
          ],
          rows: [],
          gridFocusNode: null,
          scroll: scroll,
        );

        stateManager.setLayout(const BoxConstraints(maxWidth: 500));

        // 500 - 206 = 394 보다 작은 컬럼 이동 가능.
        // print(stateManager.maxWidth! - column.width);
        // 좌측 고정 컬럼 없음 0
        // print(stateManager.leftFrozenColumnsWidth);
        // 우측 고정 컬럼 없음 0
        // print(stateManager.rightFrozenColumnsWidth);
        // 200
        // print(PlutoGridSettings.bodyMinWidth);
        // 6
        // print(PlutoGridSettings.totalShadowLineWidth);

        expect(
          stateManager.limitToggleFrozenColumn(column, PlutoColumnFrozen.start),
          false,
        );
      },
    );

    test(
      'column 의 frozen 이 none 이고 frozen 컬럼으로 토글 할 때, '
      '제약 조건 범위가 부족하면 true 를 리턴 해야 한다.',
      () async {
        final PlutoColumn column = PlutoColumn(
          title: 'title1',
          field: 'field1',
          type: PlutoColumnType.text(),
          frozen: PlutoColumnFrozen.none,
          width: 394,
        );

        PlutoGridStateManager stateManager = getStateManager(
          columns: [
            column,
            ...ColumnHelper.textColumn('title', count: 3, width: 100),
          ],
          rows: [],
          gridFocusNode: null,
          scroll: scroll,
        );

        stateManager.setLayout(const BoxConstraints(maxWidth: 500));

        // 500 - 206 = 394 보다 작은 컬럼 이동 가능.
        // print(stateManager.maxWidth! - column.width);
        // 좌측 고정 컬럼 없음 0
        // print(stateManager.leftFrozenColumnsWidth);
        // 우측 고정 컬럼 없음 0
        // print(stateManager.rightFrozenColumnsWidth);
        // 200
        // print(PlutoGridSettings.bodyMinWidth);
        // 6
        // print(PlutoGridSettings.totalShadowLineWidth);

        expect(
          stateManager.limitToggleFrozenColumn(column, PlutoColumnFrozen.start),
          true,
        );
      },
    );
  });

  group('limitHideColumn', () {
    test(
      'column 의 hide 를 true 로 호출하면 숨겨지므로 제약조건을 받지 않아 false 를 리턴 해야 한다.',
      () async {
        final PlutoColumn column = PlutoColumn(
          title: 'title1',
          field: 'field1',
          type: PlutoColumnType.text(),
          frozen: PlutoColumnFrozen.end,
          width: 394,
        );

        PlutoGridStateManager stateManager = getStateManager(
          columns: [
            column,
            ...ColumnHelper.textColumn('title', count: 3, width: 100),
          ],
          rows: [],
          gridFocusNode: null,
          scroll: scroll,
        );

        stateManager.setLayout(const BoxConstraints(maxWidth: 500));

        expect(stateManager.limitHideColumn(column, true), false);
      },
    );

    test(
      'column 의 frozen 이 none 이면 제약 조건을 받지 않으므로 false 를 리턴 해야 한다.',
      () async {
        final PlutoColumn column = PlutoColumn(
          title: 'title1',
          field: 'field1',
          type: PlutoColumnType.text(),
          frozen: PlutoColumnFrozen.none,
          hide: true,
          width: 394,
        );

        PlutoGridStateManager stateManager = getStateManager(
          columns: [
            column,
            ...ColumnHelper.textColumn('title', count: 3, width: 100),
          ],
          rows: [],
          gridFocusNode: null,
          scroll: scroll,
        );

        stateManager.setLayout(const BoxConstraints(maxWidth: 500));

        expect(stateManager.limitHideColumn(column, false), false);
      },
    );

    test(
      '고정 컬럼을 숨김 해제 해도 제약 조건이 충분하면 false 를 리턴 해야 한다.',
      () async {
        final PlutoColumn column = PlutoColumn(
          title: 'title1',
          field: 'field1',
          type: PlutoColumnType.text(),
          frozen: PlutoColumnFrozen.start,
          hide: true,
          width: 394,
        );

        PlutoGridStateManager stateManager = getStateManager(
          columns: [
            column,
            ...ColumnHelper.textColumn('title', count: 3, width: 100),
          ],
          rows: [],
          gridFocusNode: null,
          scroll: scroll,
        );

        stateManager.setLayout(const BoxConstraints(maxWidth: 500));

        // stateManager.setLayout 에서 showFrozenColumn 이 아닌 경우
        // 강제로 컬럼의 고정 상태를 none 으로 업데이트 해서 강제로 left 로 변경.
        column.frozen = PlutoColumnFrozen.start;

        // 500 - 206 = 394 보다 작은 컬럼 숨김 해제 가능.
        // print(stateManager.maxWidth! - column.width);
        // 좌측 고정 컬럼 없음 0
        // print(stateManager.leftFrozenColumnsWidth);
        // 우측 고정 컬럼 없음 0
        // print(stateManager.rightFrozenColumnsWidth);
        // 200
        // print(PlutoGridSettings.bodyMinWidth);
        // 6
        // print(PlutoGridSettings.totalShadowLineWidth);

        expect(stateManager.limitHideColumn(column, false), true);
      },
    );
  });
}
