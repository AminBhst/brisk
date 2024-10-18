import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../helper/column_helper.dart';
import '../helper/pluto_widget_test_helper.dart';
import '../helper/row_helper.dart';

void main() {
  testWidgets(
    '두개의 그리드가 생성 되고 셀이 출력 되어야 한다.',
    (WidgetTester tester) async {
      // given
      final gridAColumns = ColumnHelper.textColumn('headerA');
      final gridARows = RowHelper.count(3, gridAColumns);

      final gridBColumns = ColumnHelper.textColumn('headerB');
      final gridBRows = RowHelper.count(3, gridBColumns);

      // when
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: PlutoDualGrid(
              gridPropsA: PlutoDualGridProps(
                columns: gridAColumns,
                rows: gridARows,
              ),
              gridPropsB: PlutoDualGridProps(
                columns: gridBColumns,
                rows: gridBRows,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 1));

      // then
      final gridACell1 = find.text('headerA0 value 0');
      expect(gridACell1, findsOneWidget);

      final gridACell2 = find.text('headerA0 value 1');
      expect(gridACell2, findsOneWidget);

      final gridACell3 = find.text('headerA0 value 2');
      expect(gridACell3, findsOneWidget);

      final gridBCell1 = find.text('headerB0 value 0');
      expect(gridBCell1, findsOneWidget);

      final gridBCell2 = find.text('headerB0 value 1');
      expect(gridBCell2, findsOneWidget);

      final gridBCell3 = find.text('headerB0 value 2');
      expect(gridBCell3, findsOneWidget);
    },
  );

  testWidgets(
    'Directionality 가 LTR 인 경우 그리드 A 가 좌측, 그리드 B 가 우측에 위치해야 한다.',
    (WidgetTester tester) async {
      // given
      final gridAColumns = ColumnHelper.textColumn('headerA');
      final gridARows = RowHelper.count(3, gridAColumns);

      final gridBColumns = ColumnHelper.textColumn('headerB');
      final gridBRows = RowHelper.count(3, gridBColumns);

      // when
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: PlutoDualGrid(
                gridPropsA: PlutoDualGridProps(
                  columns: gridAColumns,
                  rows: gridARows,
                ),
                gridPropsB: PlutoDualGridProps(
                  columns: gridBColumns,
                  rows: gridBRows,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 1));

      final gridAFirstColumn = find.text('headerA0');
      final gridBFirstColumn = find.text('headerB0');

      final gridAFistDx = tester.getTopRight(gridAFirstColumn).dx;
      final gridBFistDx = tester.getTopRight(gridBFirstColumn).dx;

      expect(gridAFistDx, lessThan(gridBFistDx));
    },
  );

  testWidgets(
    'Directionality 가 RTL 인 경우 그리드 A 가 우측, 그리드 B 가 좌측에 위치해야 한다.',
    (WidgetTester tester) async {
      // given
      final gridAColumns = ColumnHelper.textColumn('headerA');
      final gridARows = RowHelper.count(3, gridAColumns);

      final gridBColumns = ColumnHelper.textColumn('headerB');
      final gridBRows = RowHelper.count(3, gridBColumns);

      // when
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: PlutoDualGrid(
                gridPropsA: PlutoDualGridProps(
                  columns: gridAColumns,
                  rows: gridARows,
                ),
                gridPropsB: PlutoDualGridProps(
                  columns: gridBColumns,
                  rows: gridBRows,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 1));

      final gridAFirstColumn = find.text('headerA0');
      final gridBFirstColumn = find.text('headerB0');

      final gridAFistDx = tester.getTopRight(gridAFirstColumn).dx;
      final gridBFistDx = tester.getTopRight(gridBFirstColumn).dx;

      expect(gridAFistDx, greaterThan(gridBFistDx));
    },
  );

  group('divider 테스트', () {
    GlobalKey gridAKey = GlobalKey();
    GlobalKey gridBKey = GlobalKey();

    dualGrid(
      PlutoDualGridDivider divider, {
      PlutoDualGridDisplay? display,
      TextDirection textDirection = TextDirection.ltr,
    }) {
      return PlutoWidgetTestHelper('그리드 생성.', (tester) async {
        final gridAColumns = ColumnHelper.textColumn('headerA', count: 3);
        final gridARows = RowHelper.count(3, gridAColumns);

        final gridBColumns = ColumnHelper.textColumn('headerB', count: 3);
        final gridBRows = RowHelper.count(3, gridBColumns);

        await tester.pumpWidget(
          MaterialApp(
            home: Material(
              child: Directionality(
                textDirection: textDirection,
                child: PlutoDualGrid(
                  gridPropsA: PlutoDualGridProps(
                    columns: gridAColumns,
                    rows: gridARows,
                    key: gridAKey,
                  ),
                  gridPropsB: PlutoDualGridProps(
                    columns: gridBColumns,
                    rows: gridBRows,
                    key: gridBKey,
                  ),
                  divider: divider,
                  display: display,
                ),
              ),
            ),
          ),
        );
      });
    }

    dualGrid(const PlutoDualGridDivider()).test(
      'Divider 위젯이 렌더링 되어야 한다.',
      (tester) async {
        final findDivider = find.byType(PlutoDualGridDividerWidget);

        expect(findDivider, findsOneWidget);
      },
    );

    dualGrid(const PlutoDualGridDivider()).test(
      'Divider 가 기본 컬러로 렌더링 되어야 한다.',
      (tester) async {
        final findDivider = find.byType(PlutoDualGridDividerWidget);

        final coloredBox = tester.widget<ColoredBox>(
          find.descendant(of: findDivider, matching: find.byType(ColoredBox)),
        );

        expect(coloredBox.color, Colors.white);

        final icon = tester.widget<Icon>(
          find.descendant(of: findDivider, matching: find.byType(Icon)),
        );

        expect(icon.color, const Color(0xFFA1A5AE));
      },
    );

    dualGrid(const PlutoDualGridDivider(
      backgroundColor: Colors.deepOrange,
      indicatorColor: Colors.indigoAccent,
    )).test(
      'Divider 가변경 된 컬러로 렌더링 되어야 한다.',
      (tester) async {
        final findDivider = find.byType(PlutoDualGridDividerWidget);

        final coloredBox = tester.widget<ColoredBox>(
          find.descendant(of: findDivider, matching: find.byType(ColoredBox)),
        );

        expect(coloredBox.color, Colors.deepOrange);

        final icon = tester.widget<Icon>(
          find.descendant(of: findDivider, matching: find.byType(Icon)),
        );

        expect(icon.color, Colors.indigoAccent);
      },
    );

    dualGrid(const PlutoDualGridDivider(
      show: false,
    )).test(
      'show 가 false 인 경우 Divider 가 렌더링 되지 않아야 한다.',
      (tester) async {
        final findDivider = find.byType(PlutoDualGridDividerWidget);

        expect(findDivider, findsNothing);
      },
    );

    dualGrid(const PlutoDualGridDivider()).test(
      'Divider 를 우측으로 드래그 하는 경우 Divider 의 위치가 증가해야 한다.',
      (tester) async {
        final findDivider = find.byType(PlutoDualGridDividerWidget);

        final firstCenter = tester.getCenter(findDivider);

        await tester.drag(findDivider, const Offset(100, 0));

        await tester.pump();

        final movedCenter = tester.getCenter(findDivider);

        expect(movedCenter.dx, firstCenter.dx + 100);
      },
    );

    dualGrid(const PlutoDualGridDivider()).test(
      'Divider 를 좌측으로 드래그 하는 경우 Divider 의 위치가 증가해야 한다.',
      (tester) async {
        final findDivider = find.byType(PlutoDualGridDividerWidget);

        final firstCenter = tester.getCenter(findDivider);

        await tester.drag(findDivider, const Offset(-100, 0));

        await tester.pump();

        final movedCenter = tester.getCenter(findDivider);

        expect(movedCenter.dx, firstCenter.dx - 100);
      },
    );

    dualGrid(const PlutoDualGridDivider()).test(
      'Divider 를 우측으로 100 드래그 하는 경우, '
      '좌측 그리드의 위치가 100 늘어나고, '
      '우측 그리드의 위치가 100 줄어들어야 한다.',
      (tester) async {
        final findDivider = find.byType(PlutoDualGridDividerWidget);

        final findGridA = find.byKey(gridAKey);
        final findGridB = find.byKey(gridBKey);

        final firstAWidth = tester.getSize(findGridA).width;
        final firstBWidth = tester.getSize(findGridB).width;

        await tester.drag(findDivider, const Offset(100, 0));

        await tester.pump();

        final movedAWidth = tester.getSize(findGridA).width;
        final movedBWidth = tester.getSize(findGridB).width;

        expect(movedAWidth, firstAWidth + 100);
        expect(movedBWidth, firstBWidth - 100);
      },
    );

    dualGrid(
      const PlutoDualGridDivider(),
      textDirection: TextDirection.rtl,
    ).test(
      'RTL 인 경우 Divider 를 우측으로 100 드래그 하는 경우, '
      'GridB 의 위치가 100 늘어나고, '
      'GridA 의 위치가 100 줄어들어야 한다.',
      (tester) async {
        final findDivider = find.byType(PlutoDualGridDividerWidget);

        final findGridA = find.byKey(gridAKey);
        final findGridB = find.byKey(gridBKey);

        final firstAWidth = tester.getSize(findGridA).width;
        final firstBWidth = tester.getSize(findGridB).width;

        await tester.drag(findDivider, const Offset(100, 0));

        await tester.pump();

        final movedAWidth = tester.getSize(findGridA).width;
        final movedBWidth = tester.getSize(findGridB).width;

        expect(movedAWidth, firstAWidth - 100);
        expect(movedBWidth, firstBWidth + 100);
      },
    );

    dualGrid(const PlutoDualGridDivider()).test(
      'Divider 를 좌측으로 100 드래그 하는 경우, '
      '좌측 그리드의 위치가 100 즐어들고, '
      '우측 그리드의 위치가 100 늘어나야 한다.',
      (tester) async {
        final findDivider = find.byType(PlutoDualGridDividerWidget);

        final findGridA = find.byKey(gridAKey);
        final findGridB = find.byKey(gridBKey);

        final firstAWidth = tester.getSize(findGridA).width;
        final firstBWidth = tester.getSize(findGridB).width;

        await tester.drag(findDivider, const Offset(-100, 0));

        await tester.pump();

        final movedAWidth = tester.getSize(findGridA).width;
        final movedBWidth = tester.getSize(findGridB).width;

        expect(movedAWidth, firstAWidth - 100);
        expect(movedBWidth, firstBWidth + 100);
      },
    );

    dualGrid(
      const PlutoDualGridDivider(),
      textDirection: TextDirection.rtl,
    ).test(
      'RTL 인 경우 Divider 를 좌측으로 100 드래그 하는 경우, '
      'gridB 의 위치가 100 즐어들고, '
      'gridA 의 위치가 100 늘어나야 한다.',
      (tester) async {
        final findDivider = find.byType(PlutoDualGridDividerWidget);

        final findGridA = find.byKey(gridAKey);
        final findGridB = find.byKey(gridBKey);

        final firstAWidth = tester.getSize(findGridA).width;
        final firstBWidth = tester.getSize(findGridB).width;

        await tester.drag(findDivider, const Offset(-100, 0));

        await tester.pump();

        final movedAWidth = tester.getSize(findGridA).width;
        final movedBWidth = tester.getSize(findGridB).width;

        expect(movedAWidth, firstAWidth + 100);
        expect(movedBWidth, firstBWidth - 100);
      },
    );
  });

  group(
    '그리드간 셀 이동 테스트',
    () {
      PlutoGridStateManager? stateManagerA;
      PlutoGridStateManager? stateManagerB;

      group('왼쪽 그리드의', () {
        buildLeftGridCellSelected({
          TextDirection textDirection = TextDirection.ltr,
        }) {
          return PlutoWidgetTestHelper('첫번째 셀이 선택 된 상태에서', (tester) async {
            final gridAColumns = ColumnHelper.textColumn('headerA', count: 3);
            final gridARows = RowHelper.count(3, gridAColumns);

            final gridBColumns = ColumnHelper.textColumn('headerB', count: 3);
            final gridBRows = RowHelper.count(3, gridBColumns);

            await tester.pumpWidget(
              MaterialApp(
                home: Material(
                  child: PlutoDualGrid(
                    gridPropsA: PlutoDualGridProps(
                      columns: gridAColumns,
                      rows: gridARows,
                      onLoaded: (PlutoGridOnLoadedEvent event) =>
                          stateManagerA = event.stateManager,
                    ),
                    gridPropsB: PlutoDualGridProps(
                      columns: gridBColumns,
                      rows: gridBRows,
                      onLoaded: (PlutoGridOnLoadedEvent event) =>
                          stateManagerB = event.stateManager,
                    ),
                  ),
                ),
              ),
            );

            await tester.pump();

            await tester.tap(find.text('headerA0 value 0'));
          });
        }

        buildLeftGridCellSelected().test(
          '우측 끝으로 이동 후 한번 더 우측 방향키를 입력하면,'
          '포커스가 우측 그리드로 바뀌어야 한다.'
          '그리고 한번 더 우측 방향키를 입력하면,'
          '우측 그리드의 첫번째 셀이 선택 되어야 한다.',
          (tester) async {
            // 0 > 1
            await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
            await tester.pumpAndSettle();
            // 1 > 2
            await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
            await tester.pumpAndSettle();

            expect(stateManagerA!.gridFocusNode.hasFocus, isTrue);
            expect(stateManagerB!.gridFocusNode.hasFocus, isFalse);

            // 2 > right grid
            await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
            await tester.pumpAndSettle();

            expect(stateManagerA!.gridFocusNode.hasFocus, isFalse);
            expect(stateManagerB!.gridFocusNode.hasFocus, isTrue);

            // right grid > 0
            await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
            expect(stateManagerB!.currentCell!.value, 'headerB0 value 0');
          },
        );

        buildLeftGridCellSelected().test(
          '우측 끝으로 이동 후 탭 키를 입력하면'
          '포커스가 우측 그리드로 바뀌어야 한다.'
          '그리고 탭 키를 입력하면'
          '우측 그리드의 첫번째 셀이 선택 되어야 한다.',
          (tester) async {
            // 0 > 1
            await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
            await tester.pumpAndSettle();
            // 1 > 2
            await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
            await tester.pumpAndSettle();
            // 2 > right grid
            await tester.sendKeyEvent(LogicalKeyboardKey.tab);
            await tester.pumpAndSettle();

            expect(stateManagerA!.gridFocusNode.hasFocus, isFalse);
            expect(stateManagerB!.gridFocusNode.hasFocus, isTrue);

            // right grid > 0
            await tester.sendKeyEvent(LogicalKeyboardKey.tab);
            expect(stateManagerB!.currentCell!.value, 'headerB0 value 0');
          },
        );

        buildLeftGridCellSelected().test(
          '우측 끝으로 이동 후 탭 키를 입력하면'
          '포커스가 우측 그리드로 바뀌어야 한다.'
          '그리고 쉬프트 + 탭 키를 입력하면'
          '우측 그리드의 첫번째 셀이 선택 되어야 한다.'
          '이어스 쉬프트 + 탭 키를 입력 하면'
          '다시 왼쪽 그리드로 포커스가 바뀌어야 한다.',
          (tester) async {
            // 0 > 1
            await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
            await tester.pumpAndSettle();
            // 1 > 2
            await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
            await tester.pumpAndSettle();
            // 2 > right grid
            await tester.sendKeyEvent(LogicalKeyboardKey.tab);
            await tester.pumpAndSettle();

            expect(stateManagerA!.gridFocusNode.hasFocus, isFalse);
            expect(stateManagerB!.gridFocusNode.hasFocus, isTrue);

            // right grid > 0
            await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
            await tester.pumpAndSettle();
            await tester.sendKeyEvent(LogicalKeyboardKey.tab);
            await tester.pumpAndSettle();
            await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
            await tester.pumpAndSettle();
            expect(stateManagerB!.currentCell!.value, 'headerB0 value 0');

            // right grid > left grid
            await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
            await tester.pumpAndSettle();
            await tester.sendKeyEvent(LogicalKeyboardKey.tab);
            await tester.pumpAndSettle();
            await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);

            expect(stateManagerA!.gridFocusNode.hasFocus, isTrue);
            expect(stateManagerB!.gridFocusNode.hasFocus, isFalse);
          },
        );
      });
    },
  );

  group('PlutoDualGridDisplayRatio', () {
    test('ratio 가 0 인 경우 assert 에러', () {
      expect(() {
        PlutoDualGridDisplayRatio(ratio: 0);
      }, throwsA(isA<AssertionError>()));
    });

    test('ratio 가 1 인 경우 assert 에러', () {
      expect(() {
        PlutoDualGridDisplayRatio(ratio: 1);
      }, throwsA(isA<AssertionError>()));
    });

    test('ratio 가 0.5 인 경우 width 가 5:5', () {
      var display = PlutoDualGridDisplayRatio(ratio: 0.5);

      const size = BoxConstraints(maxWidth: 200);

      expect(display.gridAWidth(size), 100);
      expect(display.gridBWidth(size), 100);
    });

    test('ratio 가 0.1 인 경우 width 가 1:9', () {
      var display = PlutoDualGridDisplayRatio(ratio: 0.1);

      const size = BoxConstraints(maxWidth: 200);

      expect(display.gridAWidth(size), 20);
      expect(display.gridBWidth(size), 180);
    });
  });

  group('PlutoDualGridDisplayFixedAndExpanded', () {
    test('width 가 100', () {
      var display = PlutoDualGridDisplayFixedAndExpanded(width: 100);

      const size = BoxConstraints(maxWidth: 200);

      expect(display.gridAWidth(size), 100);
      expect(display.gridBWidth(size), 100);
    });

    test('width 가 50', () {
      var display = PlutoDualGridDisplayFixedAndExpanded(width: 50);

      const size = BoxConstraints(maxWidth: 200);

      expect(display.gridAWidth(size), 50);
      expect(display.gridBWidth(size), 150);
    });
  });

  group('PlutoDualGridDisplayExpandedAndFixed', () {
    test('width 가 100', () {
      var display = PlutoDualGridDisplayExpandedAndFixed(width: 100);

      const size = BoxConstraints(maxWidth: 200);

      expect(display.gridAWidth(size), 100);
      expect(display.gridBWidth(size), 100);
    });

    test('width 가 50', () {
      var display = PlutoDualGridDisplayExpandedAndFixed(width: 50);

      const size = BoxConstraints(maxWidth: 200);

      expect(display.gridAWidth(size), 150);
      expect(display.gridBWidth(size), 50);
    });
  });
}
