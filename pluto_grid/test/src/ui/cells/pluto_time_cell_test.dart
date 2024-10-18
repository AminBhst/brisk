import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:pluto_grid/src/ui/ui.dart';

import '../../../helper/pluto_widget_test_helper.dart';
import '../../../helper/row_helper.dart';
import '../../../mock/shared_mocks.mocks.dart';

void main() {
  late MockPlutoGridStateManager stateManager;

  setUp(() {
    const configuration = PlutoGridConfiguration();
    stateManager = MockPlutoGridStateManager();
    when(stateManager.configuration).thenReturn(configuration);
    when(stateManager.style).thenReturn(configuration.style);
    when(stateManager.keyPressed).thenReturn(PlutoGridKeyPressed());
    when(stateManager.rowTotalHeight).thenReturn(
      RowHelper.resolveRowTotalHeight(
        stateManager.configuration.style.rowHeight,
      ),
    );
    when(stateManager.localeText).thenReturn(const PlutoGridLocaleText());
    when(stateManager.keepFocus).thenReturn(true);
    when(stateManager.hasFocus).thenReturn(true);
  });

  BoxDecoration getCellDecoration(Finder cell) {
    final container = find
        .ancestor(
          of: cell,
          matching: find.byType(DecoratedBox),
        )
        .first
        .evaluate()
        .first
        .widget as DecoratedBox;

    return container.decoration as BoxDecoration;
  }

  TextStyle getCellTextStyle(Finder cell) {
    final text = cell.first.evaluate().first.widget as Text;

    return text.style as TextStyle;
  }

  group('suffixIcon 렌더링', () {
    final PlutoCell cell = PlutoCell(value: '12:30');

    final PlutoRow row = PlutoRow(
      cells: {
        'column_field_name': cell,
      },
    );

    testWidgets('기본 시간 아이콘이 렌더링 되어야 한다.', (tester) async {
      final PlutoColumn column = PlutoColumn(
        title: 'column title',
        field: 'column_field_name',
        type: PlutoColumnType.time(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: PlutoTimeCell(
              stateManager: stateManager,
              cell: cell,
              column: column,
              row: row,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.access_time), findsOneWidget);
    });

    testWidgets('변경한 아이콘이 렌더링 되어야 한다.', (tester) async {
      final PlutoColumn column = PlutoColumn(
        title: 'column title',
        field: 'column_field_name',
        type: PlutoColumnType.time(
          popupIcon: Icons.add,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: PlutoTimeCell(
              stateManager: stateManager,
              cell: cell,
              column: column,
              row: row,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('popupIcon 이 null 인 경우 아이콘이 렌더링 되지 않아야 한다.', (tester) async {
      final PlutoColumn column = PlutoColumn(
        title: 'column title',
        field: 'column_field_name',
        type: PlutoColumnType.time(
          popupIcon: null,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: PlutoTimeCell(
              stateManager: stateManager,
              cell: cell,
              column: column,
              row: row,
            ),
          ),
        ),
      );

      expect(find.byType(Icon), findsNothing);
    });
  });

  testWidgets('셀 값이 출력 되어야 한다.', (WidgetTester tester) async {
    // given
    final PlutoColumn column = PlutoColumn(
      title: 'column title',
      field: 'column_field_name',
      type: PlutoColumnType.time(),
    );

    final PlutoCell cell = PlutoCell(value: '12:30');

    final PlutoRow row = PlutoRow(
      cells: {
        'column_field_name': cell,
      },
    );

    // when
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: PlutoTimeCell(
            stateManager: stateManager,
            cell: cell,
            column: column,
            row: row,
          ),
        ),
      ),
    );

    // then
    expect(find.text('12:30'), findsOneWidget);
  });

  group('수정 가능 상태인 경우', () {
    final PlutoColumn column = PlutoColumn(
      title: 'column title',
      field: 'column_field_name',
      type: PlutoColumnType.time(),
    );

    final PlutoCell cell = PlutoCell(value: '12:30');

    final PlutoRow row = PlutoRow(cells: {'column_field_name': cell});

    final tapCell = PlutoWidgetTestHelper('Tap cell', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: PlutoTimeCell(
              stateManager: stateManager,
              cell: cell,
              column: column,
              row: row,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextField));
    });

    tapCell.test('Hour, minute 컬럼이 호출 되어야 한다.', (tester) async {
      expect(find.text('Hour'), findsOneWidget);
      expect(find.text('Minute'), findsOneWidget);
    });

    tapCell.test('12:28 분 선택.', (tester) async {
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);

      verify(stateManager.handleAfterSelectingRow(cell, '12:28')).called(1);
    });

    tapCell.test('12:33 분 선택.', (tester) async {
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);

      verify(stateManager.handleAfterSelectingRow(cell, '12:33')).called(1);
    });

    tapCell.test('12:29 분 선택.', (tester) async {
      await tester.tap(find.text('29'));
      await tester.tap(find.text('29'));

      verify(stateManager.handleAfterSelectingRow(cell, '12:29')).called(1);
    });

    tapCell.test('15:28 분 선택.', (tester) async {
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);

      verify(stateManager.handleAfterSelectingRow(cell, '15:28')).called(1);
    });

    group('날짜 활성, 비활성 color 체크', () {
      late Color activatedCellColor;
      late Color activatedTextColor;
      late Color inactivatedCellColor;
      late Color inactivatedTextColor;

      setUp(() {
        activatedCellColor =
            stateManager.configuration.style.activatedBorderColor;
        activatedTextColor =
            stateManager.configuration.style.gridBackgroundColor;
        inactivatedCellColor =
            stateManager.configuration.style.gridBackgroundColor;
        inactivatedTextColor =
            stateManager.configuration.style.cellTextStyle.color!;
      });

      tapCell.test(
        '12:30 선택 된 상태에서 color 가 12는 비활성, 30은 활성으로 되어야 한다.',
        (tester) async {
          final hour = find.text('12');
          final hourContainerDecoration = getCellDecoration(hour);
          final hourTextStyle = getCellTextStyle(hour);

          final minute = find.text('30');
          final minuteContainerDecoration = getCellDecoration(minute);
          final minuteTextStyle = getCellTextStyle(minute);

          expect(hourContainerDecoration.color, inactivatedCellColor);
          expect(hourTextStyle.color, inactivatedTextColor);

          expect(minuteContainerDecoration.color, activatedCellColor);
          expect(minuteTextStyle.color, activatedTextColor);

          await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          verify(stateManager.handleAfterSelectingRow(cell, '12:30')).called(1);
        },
      );

      tapCell.test(
        '12:30 선택 된 상태에서 왼쪽 방향키를 입력하면, '
        '12의 color 가 활성, 30의 color 가 비활성이 되어야 한다.',
        (tester) async {
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
          await tester.pumpAndSettle();

          final hour = find.text('12');
          final hourTextStyle = getCellTextStyle(hour);
          final hourContainerDecoration = getCellDecoration(hour);

          final minute = find.text('30');
          final minuteContainerDecoration = getCellDecoration(minute);
          final minuteTextStyle = getCellTextStyle(minute);

          expect(hourContainerDecoration.color, activatedCellColor);
          expect(hourTextStyle.color, activatedTextColor);

          expect(minuteContainerDecoration.color, inactivatedCellColor);
          expect(minuteTextStyle.color, inactivatedTextColor);

          await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          verify(stateManager.handleAfterSelectingRow(cell, '12:30')).called(1);
        },
      );

      tapCell.test(
        '12:30 선택 된 상태에서 아래쪽 방향키를 입력하면, '
        '30의 color 가 비활성, 31의 color 가 활성이 되어야 한다.',
        (tester) async {
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
          await tester.pumpAndSettle();

          final min30 = find.text('30');
          final min30ContainerDecoration = getCellDecoration(min30);
          final min30TextStyle = getCellTextStyle(min30);

          final min31 = find.text('31');
          final min31ContainerDecoration = getCellDecoration(min31);
          final min31TextStyle = getCellTextStyle(min31);

          expect(min30ContainerDecoration.color, inactivatedCellColor);
          expect(min30TextStyle.color, inactivatedTextColor);

          expect(min31ContainerDecoration.color, activatedCellColor);
          expect(min31TextStyle.color, activatedTextColor);

          await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          verify(stateManager.handleAfterSelectingRow(cell, '12:31')).called(1);
        },
      );

      tapCell.test(
        '12:30 선택 된 상태에서 위쪽 방향키를 입력하면, '
        '30의 color 가 비활성, 29의 color 가 활성이 되어야 한다.',
        (tester) async {
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
          await tester.pumpAndSettle();

          final min30 = find.text('30');
          final min30ContainerDecoration = getCellDecoration(min30);
          final min30TextStyle = getCellTextStyle(min30);

          final min29 = find.text('29');
          final min29ContainerDecoration = getCellDecoration(min29);
          final min29TextStyle = getCellTextStyle(min29);

          expect(min30ContainerDecoration.color, inactivatedCellColor);
          expect(min30TextStyle.color, inactivatedTextColor);

          expect(min29ContainerDecoration.color, activatedCellColor);
          expect(min29TextStyle.color, activatedTextColor);

          await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          verify(stateManager.handleAfterSelectingRow(cell, '12:29')).called(1);
        },
      );

      tapCell.test(
        '12:30 선택 된 상태에서 왼쪽, 위 방향키를 입력하면, '
        '30의 color 가 비활성, 11의 color 가 활성이 되어야 한다.(11:30)',
        (tester) async {
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
          await tester.pumpAndSettle();
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
          await tester.pumpAndSettle();

          final min30 = find.text('30');
          final min30ContainerDecoration = getCellDecoration(min30);
          final min30TextStyle = getCellTextStyle(min30);

          final hour11 = find.text('11');
          final hour11ContainerDecoration = getCellDecoration(hour11);
          final hour11TextStyle = getCellTextStyle(hour11);

          expect(min30ContainerDecoration.color, inactivatedCellColor);
          expect(min30TextStyle.color, inactivatedTextColor);

          expect(hour11ContainerDecoration.color, activatedCellColor);
          expect(hour11TextStyle.color, activatedTextColor);

          await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          verify(stateManager.handleAfterSelectingRow(cell, '11:30')).called(1);
        },
      );
    });
  });
}
