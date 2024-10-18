import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../helper/pluto_widget_test_helper.dart';

/// 키보드로 팝업 그리드 호출 및 선택 테스트
void main() {
  PlutoGridStateManager? stateManager;

  buildGrid({
    int numberOfRows = 10,
    int numberOfColumns = 10,
    PlutoGridConfiguration configuration = const PlutoGridConfiguration(),
  }) {
    // given
    final columns = [
      PlutoColumn(
        title: 'date',
        field: 'date',
        type: PlutoColumnType.date(
          startDate: DateTime.parse('2020-01-01'),
          endDate: DateTime.parse('2020-01-31'),
        ),
      )
    ];

    final rows = [
      PlutoRow(cells: {'date': PlutoCell(value: '2020-01-01')}),
      PlutoRow(cells: {'date': PlutoCell(value: '2020-01-02')}),
      PlutoRow(cells: {'date': PlutoCell(value: '2020-01-03')}),
      PlutoRow(cells: {'date': PlutoCell(value: '2020-01-04')}),
      PlutoRow(cells: {'date': PlutoCell(value: '2020-01-05')}),
    ];

    return PlutoWidgetTestHelper(
      'build with selecting cells.',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Material(
              child: PlutoGrid(
                columns: columns,
                rows: rows,
                onLoaded: (PlutoGridOnLoadedEvent event) {
                  stateManager = event.stateManager;
                },
                configuration: configuration,
              ),
            ),
          ),
        );
      },
    );
  }

  buildGrid(
    configuration: const PlutoGridConfiguration(
      enableMoveDownAfterSelecting: true,
    ),
  ).test(
    '문자열 입력으로 날짜 팝업을 호출 하고 날짜를 선택하면 다음 행으로 이동 되며, '
    '다음 행에서 다시 문자열 입력으로 팝업을 호출 할 수 있어야 한다.',
    (tester) async {
      // 0번 행인 2020년 1월 1일 을 선택
      await tester.tap(find.text('2020-01-01'));

      // 문자열 입력으로 팝업 호출 후 2020-01-01 아래 있는
      // 2020-01-08 날짜를 선택하고 엔터를 입력 해 다음 행으로 이동 한다.
      await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
      expect(stateManager!.isEditing, isTrue);
      await tester.pumpAndSettle(const Duration(milliseconds: 300));

      await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
      await tester.pumpAndSettle(const Duration(milliseconds: 300));

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle(const Duration(milliseconds: 300));

      // 기존 셀 값이 2020-01-08 로 변경 되어야 한다.
      expect(stateManager!.rows[0].cells['date']!.value, '2020-01-08');

      // 현재 셀이 다음 행으로 변경 되어야 한다.
      expect(stateManager!.currentCellPosition!.rowIdx, 1);

      // 수정 상태가 유지 되어야 한다.
      expect(stateManager!.isEditing, isTrue);

      // 문자열 입력으로 팝업을 다시 호출 하고 2020-01-02 아래 날짜인
      // 2020-01-09 를 선택 하고 엔터를 입력 해 다음 행으로 이동 한다.
      await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
      await tester.pumpAndSettle(const Duration(milliseconds: 300));

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);

      // 기존 셀 값이 2020-01-09 로 변경 되어야 한다.
      expect(stateManager!.rows[1].cells['date']!.value, '2020-01-09');

      // 현재 셀이 다음 행으로 변경 되어야 한다.
      expect(stateManager!.currentCellPosition!.rowIdx, 2);

      // 수정 상태가 유지 되어야 한다.
      expect(stateManager!.isEditing, isTrue);
    },
  );
}
