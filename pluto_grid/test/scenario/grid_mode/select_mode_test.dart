import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../helper/column_helper.dart';
import '../../helper/pluto_widget_test_helper.dart';
import '../../helper/row_helper.dart';
import '../../matcher/pluto_object_matcher.dart';
import '../../mock/mock_methods.dart';

void main() {
  late PlutoGridStateManager stateManager;

  final MockMethods mock = MockMethods();

  setUp(() {
    reset(mock);
  });

  buildGrid({
    int numberOfRows = 10,
    void Function(PlutoGridOnLoadedEvent)? onLoaded,
    void Function(PlutoGridOnSelectedEvent)? onSelected,
  }) {
    // given
    final columns = ColumnHelper.textColumn('column');
    final rows = RowHelper.count(numberOfRows, columns);

    return PlutoWidgetTestHelper(
      'build with selecting rows.',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Material(
              child: PlutoGrid(
                mode: PlutoGridMode.select,
                columns: columns,
                rows: rows,
                onLoaded: (PlutoGridOnLoadedEvent event) {
                  stateManager = event.stateManager;
                  if (onLoaded != null) onLoaded(event);
                },
                onSelected: onSelected,
              ),
            ),
          ),
        );
      },
    );
  }

  buildGrid().test(
    '첫번째 셀이 포커스 되어야 한다.',
    (tester) async {
      expect(stateManager.currentCell, isNot(null));
      expect(stateManager.currentCellPosition?.rowIdx, 0);
      expect(stateManager.currentCellPosition?.columnIdx, 0);
    },
  );

  buildGrid(numberOfRows: 0).test(
    '행이 없는 경우 에러가 발생 되지 않고 그리드가 포커스 되어야 한다.',
    (tester) async {
      expect(stateManager.refRows.length, 0);
      expect(stateManager.currentCell, null);
      expect(stateManager.hasFocus, true);
    },
  );

  buildGrid(
    onLoaded: (e) => e.stateManager.setCurrentCell(
      e.stateManager.refRows[1].cells['column0'],
      1,
    ),
  ).test(
    'onLoaded 에서 두번째 셀을 선택하면, 두번째 셀이 포커스 되어야 한다.',
    (tester) async {
      expect(stateManager.currentCell, isNot(null));
      expect(stateManager.currentCellPosition?.rowIdx, 1);
      expect(stateManager.currentCellPosition?.columnIdx, 0);
    },
  );

  buildGrid().test(
    '그리드 포커스가 활성화 되어야 한다.',
    (tester) async {
      expect(stateManager.hasFocus, true);
    },
  );

  buildGrid().test(
    'select 모드로 실행하면 selectingMode 가 none 이 되어야 한다.',
    (tester) async {
      expect(stateManager.selectingMode.isNone, true);
    },
  );

  buildGrid(onSelected: mock.oneParamReturnVoid<PlutoGridOnSelectedEvent>).test(
    '첫번 째 셀이 선택 된 상태에서, '
    '첫번 째 셀을 한번 탭하면 onSelected 콜백이 호출 되어야 한다.',
    (tester) async {
      expect(stateManager.currentCellPosition?.rowIdx, 0);

      await tester.tap(find.text('column0 value 0'));
      await tester.pump();

      verify(
        mock.oneParamReturnVoid(
            argThat(PlutoObjectMatcher<PlutoGridOnSelectedEvent>(rule: (event) {
          return event.row?.key == stateManager.refRows.first.key &&
              event.rowIdx == 0 &&
              event.cell?.key ==
                  stateManager.refRows.first.cells['column0']!.key &&
              event.selectedRows == null;
        }))),
      ).called(1);

      // select 모드에서는 currentSelectingRows 에 추가되지 않는다.
      expect(stateManager.currentSelectingRows.length, 0);
    },
  );

  buildGrid(onSelected: mock.oneParamReturnVoid<PlutoGridOnSelectedEvent>).test(
    '두번째 행을 한번 탭하면 현재 셀이 변경 되고, '
    '한번 더 탭하면 onSelected 콜백이 호출 되어야 한다.',
    (tester) async {
      await tester.tap(find.text('column0 value 1'));
      await tester.pump();

      expect(stateManager.currentCellPosition?.rowIdx, 1);

      await tester.tap(find.text('column0 value 1'));
      await tester.pump();

      verify(
        mock.oneParamReturnVoid(
            argThat(PlutoObjectMatcher<PlutoGridOnSelectedEvent>(rule: (event) {
          return event.row?.key == stateManager.refRows[1].key &&
              event.rowIdx == 1 &&
              event.cell?.key ==
                  stateManager.refRows[1].cells['column0']!.key &&
              event.selectedRows == null;
        }))),
      ).called(1);

      // select 모드에서는 currentSelectingRows 에 추가되지 않는다.
      expect(stateManager.currentSelectingRows.length, 0);
    },
  );

  buildGrid(onSelected: mock.oneParamReturnVoid<PlutoGridOnSelectedEvent>).test(
    'shift 키를 누른 상태에서, '
    '두번째 행을 한번 탭하면 현재 셀이 변경 되고, '
    '한번 더 탭하면 onSelected 콜백이 호출 되어야 한다.',
    (tester) async {
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
      await tester.tap(find.text('column0 value 1'));
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
      await tester.pump();

      expect(stateManager.currentCellPosition?.rowIdx, 1);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
      await tester.tap(find.text('column0 value 1'));
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
      await tester.pump();

      verify(
        mock.oneParamReturnVoid(
            argThat(PlutoObjectMatcher<PlutoGridOnSelectedEvent>(rule: (event) {
          return event.row?.key == stateManager.refRows[1].key &&
              event.rowIdx == 1 &&
              event.cell?.key ==
                  stateManager.refRows[1].cells['column0']!.key &&
              event.selectedRows == null;
        }))),
      ).called(1);

      // select 모드에서는 currentSelectingRows 에 추가되지 않는다.
      expect(stateManager.currentSelectingRows.length, 0);
    },
  );

  buildGrid(onSelected: mock.oneParamReturnVoid<PlutoGridOnSelectedEvent>).test(
    'control 키를 누른 상태에서, '
    '두번째 행을 한번 탭하면 현재 셀이 변경 되고, '
    '한번 더 탭하면 onSelected 콜백이 호출 되어야 한다.',
    (tester) async {
      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.tap(find.text('column0 value 1'));
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
      await tester.pump();

      expect(stateManager.currentCellPosition?.rowIdx, 1);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.tap(find.text('column0 value 1'));
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
      await tester.pump();

      verify(
        mock.oneParamReturnVoid(
            argThat(PlutoObjectMatcher<PlutoGridOnSelectedEvent>(rule: (event) {
          return event.row?.key == stateManager.refRows[1].key &&
              event.rowIdx == 1 &&
              event.cell?.key ==
                  stateManager.refRows[1].cells['column0']!.key &&
              event.selectedRows == null;
        }))),
      ).called(1);

      // select 모드에서는 currentSelectingRows 에 추가되지 않는다.
      expect(stateManager.currentSelectingRows.length, 0);
    },
  );

  buildGrid(onSelected: mock.oneParamReturnVoid<PlutoGridOnSelectedEvent>).test(
    '첫번째 셀에 선택 된 상태에서, '
    '방향키 아래를 두번 입력하고 엔터키를 입력하면, '
    '세번째 셀이 onSelected 콜백으로 호출 되어야 한다.',
    (tester) async {
      expect(stateManager.currentCellPosition?.rowIdx, 0);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      verify(
        mock.oneParamReturnVoid(
            argThat(PlutoObjectMatcher<PlutoGridOnSelectedEvent>(rule: (event) {
          return event.row?.key == stateManager.refRows[2].key &&
              event.rowIdx == 2 &&
              event.cell?.key ==
                  stateManager.refRows[2].cells['column0']!.key &&
              event.selectedRows == null;
        }))),
      ).called(1);

      // select 모드에서는 currentSelectingRows 에 추가되지 않는다.
      expect(stateManager.currentSelectingRows.length, 0);
    },
  );

  buildGrid(onSelected: mock.oneParamReturnVoid<PlutoGridOnSelectedEvent>).test(
    '첫번째 셀에 선택 된 상태에서, '
    'shift + 방향키 아래를 두번 입력하고 엔터키를 입력하면, '
    '현재 셀이 변경 되지 않고 onSelected 는 첫번째 셀로 호출 되어야 한다.',
    (tester) async {
      expect(stateManager.currentCellPosition?.rowIdx, 0);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(stateManager.currentCellPosition?.rowIdx, 0);

      verify(
        mock.oneParamReturnVoid(
            argThat(PlutoObjectMatcher<PlutoGridOnSelectedEvent>(rule: (event) {
          return event.row?.key == stateManager.refRows.first.key &&
              event.rowIdx == 0 &&
              event.cell?.key ==
                  stateManager.refRows.first.cells['column0']!.key &&
              event.selectedRows == null;
        }))),
      ).called(1);

      // select 모드에서는 currentSelectingRows 에 추가되지 않는다.
      expect(stateManager.currentSelectingRows.length, 0);
    },
  );

  buildGrid(onSelected: mock.oneParamReturnVoid<PlutoGridOnSelectedEvent>).test(
    '첫번째 셀에 선택 된 상태에서, '
    'escape 키를 입력하면 onSelected 의 row 및 기타 속성이 null 로 호출 되어야 한다.',
    (tester) async {
      expect(stateManager.currentCellPosition?.rowIdx, 0);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(stateManager.currentCellPosition?.rowIdx, 0);

      verify(
        mock.oneParamReturnVoid(
            argThat(PlutoObjectMatcher<PlutoGridOnSelectedEvent>(rule: (event) {
          return event.row == null &&
              event.rowIdx == null &&
              event.cell == null &&
              event.selectedRows == null;
        }))),
      ).called(1);

      // select 모드에서는 currentSelectingRows 에 추가되지 않는다.
      expect(stateManager.currentSelectingRows.length, 0);
    },
  );
}
