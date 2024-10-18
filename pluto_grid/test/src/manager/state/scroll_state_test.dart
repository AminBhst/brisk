import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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

  group('고정 컬럼이 있는 상태에서 needMovingScroll', () {
    late PlutoGridStateManager stateManager;

    List<PlutoColumn> columns;

    List<PlutoRow> rows;

    setUp(() {
      columns = [
        ...ColumnHelper.textColumn('left',
            count: 3, frozen: PlutoColumnFrozen.start),
        ...ColumnHelper.textColumn('body', count: 3, width: 150),
        ...ColumnHelper.textColumn('right',
            count: 3, frozen: PlutoColumnFrozen.end),
      ];

      rows = RowHelper.count(10, columns);

      stateManager = createStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
        layout: const BoxConstraints(maxWidth: 300, maxHeight: 500),
      );

      stateManager.setGridGlobalOffset(Offset.zero);
    });

    testWidgets(
      '스크롤 할 offset.dx 값이 bodyLeftScrollOffset 보다 작으면 true'
      '하지만, selectingMode 가 None 이면 false 를 리턴해야 한다.',
      (WidgetTester tester) async {
        stateManager.setSelectingMode(PlutoGridSelectingMode.none);

        expect(stateManager.selectingMode.isNone, true);

        expect(
          stateManager.needMovingScroll(
            Offset(stateManager.bodyLeftScrollOffset - 1, 0),
            PlutoMoveDirection.left,
          ),
          false,
        );
      },
    );

    testWidgets(
      '스크롤 할 offset.dx 값이 bodyLeftScrollOffset 보다 작으면 true',
      (WidgetTester tester) async {
        expect(
          stateManager.needMovingScroll(
            Offset(stateManager.bodyLeftScrollOffset - 1, 0),
            PlutoMoveDirection.left,
          ),
          true,
        );
      },
    );

    testWidgets(
      '스크롤 할 offset.dx 값이 bodyLeftScrollOffset 와 같으면 false',
      (WidgetTester tester) async {
        expect(
          stateManager.needMovingScroll(
            Offset(stateManager.bodyLeftScrollOffset, 0),
            PlutoMoveDirection.left,
          ),
          false,
        );
      },
    );

    testWidgets(
      '스크롤 할 offset.dx 값이 bodyLeftScrollOffset 보다 크면 false',
      (WidgetTester tester) async {
        expect(
          stateManager.needMovingScroll(
            Offset(stateManager.bodyLeftScrollOffset + 1, 0),
            PlutoMoveDirection.left,
          ),
          false,
        );
      },
    );

    testWidgets(
      '스크롤 할 offset.dx 값이 bodyRightScrollOffset 보다 크면 true'
      '하지만, selectingMode 가 None 이면 false 를 리턴해야 한다.',
      (WidgetTester tester) async {
        stateManager.setSelectingMode(PlutoGridSelectingMode.none);

        expect(stateManager.selectingMode.isNone, true);

        expect(
          stateManager.needMovingScroll(
            Offset(stateManager.bodyRightScrollOffset + 1, 0),
            PlutoMoveDirection.right,
          ),
          false,
        );
      },
    );

    testWidgets(
      '스크롤 할 offset.dx 값이 bodyRightScrollOffset 보다 크면 true',
      (WidgetTester tester) async {
        expect(
          stateManager.needMovingScroll(
            Offset(stateManager.bodyRightScrollOffset + 1, 0),
            PlutoMoveDirection.right,
          ),
          true,
        );
      },
    );

    testWidgets(
      '스크롤 할 offset.dx 값이 bodyRightScrollOffset 같으면 false',
      (WidgetTester tester) async {
        expect(
          stateManager.needMovingScroll(
            Offset(stateManager.bodyRightScrollOffset, 0),
            PlutoMoveDirection.right,
          ),
          false,
        );
      },
    );

    testWidgets(
      '스크롤 할 offset.dx 값이 bodyRightScrollOffset 보다 작으면 false',
      (WidgetTester tester) async {
        expect(
          stateManager.needMovingScroll(
            Offset(stateManager.bodyRightScrollOffset - 1, 0),
            PlutoMoveDirection.right,
          ),
          false,
        );
      },
    );

    testWidgets(
      '스크롤 할 offset.dy 값이 bodyUpScrollOffset 보다 작으면 true',
      (WidgetTester tester) async {
        expect(
          stateManager.needMovingScroll(
            Offset(0, stateManager.bodyUpScrollOffset - 1),
            PlutoMoveDirection.up,
          ),
          true,
        );
      },
    );

    testWidgets(
      '스크롤 할 offset.dy 값이 bodyUpScrollOffset 같으면 false',
      (WidgetTester tester) async {
        expect(
          stateManager.needMovingScroll(
            Offset(0, stateManager.bodyUpScrollOffset),
            PlutoMoveDirection.up,
          ),
          false,
        );
      },
    );

    testWidgets(
      '스크롤 할 offset.dy 값이 bodyUpScrollOffset 보다 크면 false',
      (WidgetTester tester) async {
        expect(
          stateManager.needMovingScroll(
            Offset(0, stateManager.bodyUpScrollOffset + 1),
            PlutoMoveDirection.up,
          ),
          false,
        );
      },
    );

    testWidgets(
      '스크롤 할 offset.dy 값이 bodyDownScrollOffset 보다 크면 true',
      (WidgetTester tester) async {
        expect(
          stateManager.needMovingScroll(
            Offset(0, stateManager.bodyDownScrollOffset + 1),
            PlutoMoveDirection.down,
          ),
          true,
        );
      },
    );

    testWidgets(
      '스크롤 할 offset.dy 값이 bodyDownScrollOffset 같으면 false',
      (WidgetTester tester) async {
        expect(
          stateManager.needMovingScroll(
            Offset(0, stateManager.bodyDownScrollOffset),
            PlutoMoveDirection.down,
          ),
          false,
        );
      },
    );

    testWidgets(
      '스크롤 할 offset.dy 값이 bodyDownScrollOffset 보다 작으면 false',
      (WidgetTester tester) async {
        expect(
          stateManager.needMovingScroll(
            Offset(0, stateManager.bodyDownScrollOffset - 1),
            PlutoMoveDirection.down,
          ),
          false,
        );
      },
    );
  });
}
