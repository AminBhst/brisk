import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../helper/build_grid_helper.dart';
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
                mode: PlutoGridMode.multiSelect,
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
    'multiSelect 모드로 실행하면 selectingMode 가 row 가 되어야 한다.',
    (tester) async {
      expect(stateManager.selectingMode.isRow, true);
    },
  );

  buildGrid(onSelected: mock.oneParamReturnVoid<PlutoGridOnSelectedEvent>).test(
    '0, 2, 4 행을 탭하면 onSelected 콜백의 selectedRows 에 탭한 행이 포함 되어야 한다.',
    (tester) async {
      await tester.tap(find.text('column0 value 0'));
      await tester.pumpAndSettle();

      verify(
        mock.oneParamReturnVoid(
            argThat(PlutoObjectMatcher<PlutoGridOnSelectedEvent>(rule: (event) {
          final selectedKeys = event.selectedRows!.map((e) => e.key);

          return event.selectedRows?.length == 1 &&
              selectedKeys.contains(stateManager.refRows[0].key);
        }))),
      ).called(1);

      await tester.tap(find.text('column0 value 2'));
      await tester.pumpAndSettle();

      verify(
        mock.oneParamReturnVoid(
            argThat(PlutoObjectMatcher<PlutoGridOnSelectedEvent>(rule: (event) {
          final selectedKeys = event.selectedRows!.map((e) => e.key);

          return event.selectedRows?.length == 2 &&
              selectedKeys.contains(stateManager.refRows[0].key) &&
              selectedKeys.contains(stateManager.refRows[2].key);
        }))),
      ).called(1);

      await tester.tap(find.text('column0 value 4'));
      await tester.pumpAndSettle();

      verify(
        mock.oneParamReturnVoid(
            argThat(PlutoObjectMatcher<PlutoGridOnSelectedEvent>(rule: (event) {
          final selectedKeys = event.selectedRows!.map((e) => e.key);

          return event.selectedRows?.length == 3 &&
              selectedKeys.contains(stateManager.refRows[0].key) &&
              selectedKeys.contains(stateManager.refRows[2].key) &&
              selectedKeys.contains(stateManager.refRows[4].key);
        }))),
      ).called(1);

      expect(stateManager.currentSelectingRows.length, 3);
    },
  );

  buildGrid(onSelected: mock.oneParamReturnVoid<PlutoGridOnSelectedEvent>).test(
    '0, 2, 4 행을 탭하고 0, 2 를 다시 탭하면, '
    '4번 행만 onSelected 콜백의 selectedRows 에 포함 되어야 한다.',
    (tester) async {
      await tester.tap(find.text('column0 value 0'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('column0 value 2'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('column0 value 4'));
      await tester.pumpAndSettle();

      reset(mock);

      await tester.tap(find.text('column0 value 0'));
      await tester.pumpAndSettle();

      verify(
        mock.oneParamReturnVoid(
            argThat(PlutoObjectMatcher<PlutoGridOnSelectedEvent>(rule: (event) {
          final selectedKeys = event.selectedRows!.map((e) => e.key);

          return event.selectedRows?.length == 2 &&
              selectedKeys.contains(stateManager.refRows[2].key) &&
              selectedKeys.contains(stateManager.refRows[4].key);
        }))),
      ).called(1);

      expect(stateManager.currentSelectingRows.length, 2);

      reset(mock);

      await tester.tap(find.text('column0 value 2'));
      await tester.pumpAndSettle();

      verify(
        mock.oneParamReturnVoid(
            argThat(PlutoObjectMatcher<PlutoGridOnSelectedEvent>(rule: (event) {
          final selectedKeys = event.selectedRows!.map((e) => e.key);

          return event.selectedRows?.length == 1 &&
              selectedKeys.contains(stateManager.refRows[4].key);
        }))),
      ).called(1);

      expect(stateManager.currentSelectingRows.length, 1);
    },
  );

  buildGrid(onSelected: mock.oneParamReturnVoid<PlutoGridOnSelectedEvent>).test(
    '첫번째 셀이 선택 된 상태에서, '
    'shift + arrowDown 키를 3번 입력하고 엔터키를 입력하면, '
    'onSelected 콜백이 0, 1, 2, 3 행을 포함해야 한다.',
    (tester) async {
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      verify(
        mock.oneParamReturnVoid(
            argThat(PlutoObjectMatcher<PlutoGridOnSelectedEvent>(rule: (event) {
          final selectedKeys = event.selectedRows!.map((e) => e.key);

          return event.selectedRows?.length == 4 &&
              selectedKeys.contains(stateManager.refRows[0].key) &&
              selectedKeys.contains(stateManager.refRows[1].key) &&
              selectedKeys.contains(stateManager.refRows[2].key) &&
              selectedKeys.contains(stateManager.refRows[3].key);
        }))),
      ).called(1);

      expect(stateManager.currentSelectingRows.length, 4);
    },
  );

  buildGrid(onSelected: mock.oneParamReturnVoid<PlutoGridOnSelectedEvent>).test(
    '첫번째 셀이 선택 된 상태에서, '
    'shift + tap 으로 2번 행을 탭하면, '
    'onSelected 콜백이 0, 1, 2 행을 포함해야 한다.',
    (tester) async {
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
      await tester.tap(find.text('column0 value 2'));
      await tester.pumpAndSettle();

      verify(
        mock.oneParamReturnVoid(
            argThat(PlutoObjectMatcher<PlutoGridOnSelectedEvent>(rule: (event) {
          final selectedKeys = event.selectedRows!.map((e) => e.key);

          return event.selectedRows?.length == 3 &&
              selectedKeys.contains(stateManager.refRows[0].key) &&
              selectedKeys.contains(stateManager.refRows[1].key) &&
              selectedKeys.contains(stateManager.refRows[2].key);
        }))),
      ).called(1);

      expect(stateManager.currentSelectingRows.length, 3);
    },
  );

  buildGrid(onSelected: mock.oneParamReturnVoid<PlutoGridOnSelectedEvent>).test(
    '첫번째 셀이 선택 된 상태에서, '
    'control + tap 으로 3번 행을 탭하면, '
    'onSelected 콜백이 3 행을 포함해야 한다.',
    (tester) async {
      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.tap(find.text('column0 value 3'));
      await tester.pumpAndSettle();

      verify(
        mock.oneParamReturnVoid(
            argThat(PlutoObjectMatcher<PlutoGridOnSelectedEvent>(rule: (event) {
          final selectedKeys = event.selectedRows!.map((e) => e.key);

          return event.selectedRows?.length == 1 &&
              selectedKeys.contains(stateManager.refRows[3].key);
        }))),
      ).called(1);

      expect(stateManager.currentSelectingRows.length, 1);
    },
  );

  buildGrid(onSelected: mock.oneParamReturnVoid<PlutoGridOnSelectedEvent>).test(
    '1, 3, 5 행이 선택 된 상태에서, '
    'escape 키를 입력하면, '
    'onSelected 콜백의 selectedRows 가 null 로 호출 되어야 한다.',
    (tester) async {
      await tester.tap(find.text('column0 value 1'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('column0 value 3'));
      await tester.pumpAndSettle();
      reset(mock);
      await tester.tap(find.text('column0 value 5'));
      await tester.pumpAndSettle();

      verify(
        mock.oneParamReturnVoid(
            argThat(PlutoObjectMatcher<PlutoGridOnSelectedEvent>(rule: (event) {
          final selectedKeys = event.selectedRows!.map((e) => e.key);

          return event.selectedRows?.length == 3 &&
              selectedKeys.contains(stateManager.refRows[1].key) &&
              selectedKeys.contains(stateManager.refRows[3].key) &&
              selectedKeys.contains(stateManager.refRows[5].key);
        }))),
      ).called(1);

      expect(stateManager.currentSelectingRows.length, 3);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      verify(
        mock.oneParamReturnVoid(
            argThat(PlutoObjectMatcher<PlutoGridOnSelectedEvent>(rule: (event) {
          return event.selectedRows == null;
        }))),
      ).called(1);

      expect(stateManager.currentSelectingRows.length, 0);
    },
  );

  buildGrid(onSelected: mock.oneParamReturnVoid<PlutoGridOnSelectedEvent>).test(
    '2 ~ 5 행을 드래그해서 선택하면, '
    'onSelected 콜백의 selectedRows 가 2 ~ 5 행을 포함하여 호출 되어야 한다.',
    (tester) async {
      final gridHelper = BuildGridHelper();

      await gridHelper.selectRows(
        columnTitle: 'column0',
        startRowIdx: 2,
        endRowIdx: 5,
        tester: tester,
      );
      await tester.pumpAndSettle();

      verify(
        mock.oneParamReturnVoid(
            argThat(PlutoObjectMatcher<PlutoGridOnSelectedEvent>(rule: (event) {
          final selectedKeys = event.selectedRows!.map((e) => e.key);

          return event.selectedRows?.length == 4 &&
              selectedKeys.contains(stateManager.refRows[2].key) &&
              selectedKeys.contains(stateManager.refRows[3].key) &&
              selectedKeys.contains(stateManager.refRows[4].key) &&
              selectedKeys.contains(stateManager.refRows[5].key);
        }))),
      ).called(1);
    },
  );
}
