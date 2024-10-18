import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../helper/column_helper.dart';
import '../../../helper/row_helper.dart';
import '../../../mock/mock_methods.dart';
import '../../../mock/shared_mocks.mocks.dart';

void main() {
  late List<PlutoColumn> columns;

  late List<PlutoRow> rows;

  late PlutoGridStateManager stateManager;

  MockMethods? listener;

  setUp(() {
    columns = [
      ...ColumnHelper.textColumn('column', count: 1, width: 150),
    ];

    rows = RowHelper.count(10, columns);

    stateManager = PlutoGridStateManager(
      columns: columns,
      rows: rows,
      gridFocusNode: MockFocusNode(),
      scroll: MockPlutoGridScrollController(),
    );

    listener = MockMethods();

    stateManager.addListener(listener!.noParamReturnVoid);
  });

  group('setIsDraggingRow', () {
    test(
      '기존 isDragging 값이 변경 하려는 값이랑 같은 경우, '
      'notifyListeners 가 호출 되지 않아야 한다.',
      () {
        // given
        expect(stateManager.isDraggingRow, isFalse);

        // when
        stateManager.setIsDraggingRow(false);

        // then
        verifyNever(listener!.noParamReturnVoid());
      },
    );

    test(
      '기존 isDragging 값이 변경 하려는 값이랑 다른 경우, '
      'notifyListeners 가 호출 되어야 한다.',
      () {
        // given
        expect(stateManager.isDraggingRow, isFalse);

        // when
        stateManager.setIsDraggingRow(true);

        // then
        expect(stateManager.isDraggingRow, isTrue);
        verify(listener!.noParamReturnVoid()).called(1);
      },
    );

    test(
      '기존 isDragging 값이 변경 하려는 값이랑 다르지만, notify 가 false 인 경우 '
      'notifyListeners 가 호출 되지 않아야 한다.',
      () {
        // given
        expect(stateManager.isDraggingRow, isFalse);

        // when
        stateManager.setIsDraggingRow(true, notify: false);

        // then
        expect(stateManager.isDraggingRow, isTrue);
        verifyNever(listener!.noParamReturnVoid());
      },
    );
  });

  group('setDragRows', () {
    test(
      '인수로 전달 한 rows 가 dragRows 에 설정 되어야 한다.',
      () {
        // given
        expect(stateManager.dragRows, isEmpty);

        // when
        stateManager.setDragRows([rows[1], rows[2]]);

        // then
        expect(stateManager.dragRows.length, 2);
        expect(stateManager.dragRows[0].key, rows[1].key);
        expect(stateManager.dragRows[1].key, rows[2].key);
        verify(listener!.noParamReturnVoid()).called(1);
      },
    );

    test(
      '인수로 전달 한 rows 가 dragRows 에 설정 되지만, '
      'notify 가 false 인 경우 notifyListeners 가 호출 되지 않아야 한다.',
      () {
        // given
        expect(stateManager.dragRows, isEmpty);

        // when
        stateManager.setDragRows([rows[1], rows[2]], notify: false);

        // then
        expect(stateManager.dragRows.length, 2);
        expect(stateManager.dragRows[0].key, rows[1].key);
        expect(stateManager.dragRows[1].key, rows[2].key);
        verifyNever(listener!.noParamReturnVoid());
      },
    );
  });

  group('setDragTargetRowIdx', () {
    test(
      '인수로 전달 한 rowIdx 가 dragTargetRowIdx 와 같다면, '
      'notifyListeners 가 호출 되지 않아야 한다.',
      () {
        // given
        stateManager.setDragTargetRowIdx(1);
        expect(stateManager.dragTargetRowIdx, 1);

        // when
        clearInteractions(listener);
        stateManager.setDragTargetRowIdx(1);

        // then
        verifyNever(listener!.noParamReturnVoid());
      },
    );

    test(
      '인수로 전달 한 rowIdx 가 dragTargetRowIdx 와 다르면, '
      'notifyListeners 가 호출 되어야 한다.',
      () {
        // given
        stateManager.setDragTargetRowIdx(1);
        expect(stateManager.dragTargetRowIdx, 1);

        // when
        clearInteractions(listener);
        stateManager.setDragTargetRowIdx(2);

        // then
        expect(stateManager.dragTargetRowIdx, 2);
        verify(listener!.noParamReturnVoid()).called(1);
      },
    );

    test(
      '인수로 전달 한 rowIdx 가 dragTargetRowIdx 와 다르지만, '
      'notify 가 false 면 notifyListeners 가 호출 되지 않아야 한다.',
      () {
        // given
        stateManager.setDragTargetRowIdx(1);
        expect(stateManager.dragTargetRowIdx, 1);

        // when
        clearInteractions(listener);
        stateManager.setDragTargetRowIdx(2, notify: false);

        // then
        expect(stateManager.dragTargetRowIdx, 2);
        verifyNever(listener!.noParamReturnVoid());
      },
    );
  });

  group('isRowIdxDragTarget', () {
    const int givenDragTargetRowIdx = 3;
    late List<PlutoRow> givenDragRows;

    setUp(() {
      givenDragRows = [
        rows[5],
        rows[6],
      ];
      stateManager.setDragTargetRowIdx(givenDragTargetRowIdx);
      stateManager.setDragRows(givenDragRows);
    });

    test('rowIdx 가 null 이면 false 를 리턴해야 한다.', () {
      expect(stateManager.isRowIdxDragTarget(null), isFalse);
    });

    test('rowIdx 가 주어진 rowIdx 보다 작으면 false 를 리턴 해야 한다.', () {
      expect(
        stateManager.isRowIdxDragTarget(givenDragTargetRowIdx - 1),
        isFalse,
      );
    });

    test('rowIdx 가 주어진 rowIdx + dragRows.length 보다 크면 false 를 리턴해야 한다.', () {
      expect(
        stateManager.isRowIdxDragTarget(
          givenDragTargetRowIdx + givenDragRows.length + 1,
        ),
        isFalse,
      );
    });

    test('rowIdx 가 주어진 rowIdx 와 같으면 true 를 리턴해야 한다.', () {
      expect(
        stateManager.isRowIdxDragTarget(givenDragTargetRowIdx),
        isTrue,
      );
    });

    test(
      'rowIdx 가 주어진 rowIdx 보다 크고 '
      '주어진 rowIdx + dragRows.length 보다 작으면 true 를 리턴해야 한다.',
      () {
        const rowIdx = givenDragTargetRowIdx + 1;

        expect(rowIdx, greaterThan(givenDragTargetRowIdx));
        expect(rowIdx, lessThan(rowIdx + givenDragRows.length));

        expect(
          stateManager.isRowIdxDragTarget(rowIdx),
          isTrue,
        );
      },
    );
  });

  group('isRowIdxTopDragTarget', () {
    const int givenDragTargetRowIdx = 3;
    List<PlutoRow> givenDragRows;

    setUp(() {
      givenDragRows = [
        rows[5],
        rows[6],
      ];
      stateManager.setDragTargetRowIdx(givenDragTargetRowIdx);
      stateManager.setDragRows(givenDragRows);
    });

    test(
      'rowIdx 가 null 이면 false 를 리턴해야 한다.',
      () {
        expect(stateManager.isRowIdxTopDragTarget(null), isFalse);
      },
    );

    test(
      'rowIdx 가 dragTargetRowIdx 와 다르면 false 를 리턴해야 한다.',
      () {
        expect(stateManager.dragTargetRowIdx, isNot(2));
        expect(stateManager.isRowIdxTopDragTarget(2), isFalse);
      },
    );

    test(
      'rowIdx 가 dragTargetRowIdx 와 같으면 true 를 리턴해야 한다.',
      () {
        expect(stateManager.dragTargetRowIdx, 3);
        expect(stateManager.isRowIdxTopDragTarget(3), isTrue);
      },
    );
  });

  group('isRowIdxBottomDragTarget', () {
    const int givenDragTargetRowIdx = 3;
    List<PlutoRow> givenDragRows;

    setUp(() {
      givenDragRows = [
        rows[5],
        rows[6],
      ];
      stateManager.setDragTargetRowIdx(givenDragTargetRowIdx);
      stateManager.setDragRows(givenDragRows);
    });

    test(
      'rowIdx 가 null 이면 false 를 리턴해야 한다.',
      () {
        expect(stateManager.isRowIdxBottomDragTarget(null), isFalse);
      },
    );

    test(
      'rowIdx 가 dragTargetRowIdx + dragRows.length - 1 과 다르면 false 를 리턴해야 한다.',
      () {
        const int rowIdx = 2;

        expect(
          rowIdx,
          isNot(
            stateManager.dragTargetRowIdx! + stateManager.dragRows.length - 1,
          ),
        );

        expect(stateManager.isRowIdxBottomDragTarget(rowIdx), isFalse);
      },
    );

    test(
      'rowIdx 가 dragTargetRowIdx + dragRows.length - 1 과 같으면 true 를 리턴해야 한다.',
      () {
        const int rowIdx = 4;

        expect(
          rowIdx,
          stateManager.dragTargetRowIdx! + stateManager.dragRows.length - 1,
        );

        expect(stateManager.isRowIdxBottomDragTarget(rowIdx), isTrue);
      },
    );
  });

  group('isRowBeingDragged', () {
    const int givenDragTargetRowIdx = 3;
    List<PlutoRow> givenDragRows;

    setDrag() {
      givenDragRows = [
        rows[5],
        rows[6],
      ];
      stateManager.setDragTargetRowIdx(givenDragTargetRowIdx);
      stateManager.setDragRows(givenDragRows);
    }

    setUp(setDrag);

    test(
      'rowKey 가 null 이면 false 를 리턴해야 한다.',
      () {
        expect(stateManager.isRowBeingDragged(null), isFalse);
      },
    );

    test(
      'isDragging 이 true 인 상태에서, '
      'rowKey 가 dragRows 에 포함 되어 있지 않으면 false 를 리턴해야 한다.',
      () {
        stateManager.setIsDraggingRow(true);
        setDrag();

        expect(stateManager.isDraggingRow, isTrue);

        expect(stateManager.isRowBeingDragged(rows[0].key), isFalse);
      },
    );

    test(
      'rowKey 가 dragRows 에 포함 되어 있으면 true 를 리턴해야 한다.',
      () {
        stateManager.setIsDraggingRow(true);
        setDrag();

        expect(stateManager.isDraggingRow, isTrue);

        expect(stateManager.isRowBeingDragged(rows[5].key), isTrue);
        expect(stateManager.isRowBeingDragged(rows[6].key), isTrue);
      },
    );

    test(
      'rowKey 가 dragRows 에 포함 되어 있어도, '
      'isDraggingRow 가 false 면 false 를 리턴해야 한다.',
      () {
        stateManager.setIsDraggingRow(false);
        setDrag();

        expect(stateManager.isDraggingRow, isFalse);
        expect(
          stateManager.dragRows
              .firstWhereOrNull((element) => element.key == rows[5].key),
          isNot(isNull),
        );
        expect(
          stateManager.dragRows
              .firstWhereOrNull((element) => element.key == rows[6].key),
          isNot(isNull),
        );

        expect(stateManager.isRowBeingDragged(rows[5].key), isFalse);
        expect(stateManager.isRowBeingDragged(rows[6].key), isFalse);
      },
    );
  });
}
