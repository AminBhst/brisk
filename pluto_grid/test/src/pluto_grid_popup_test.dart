import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:pluto_grid/src/ui/ui.dart';

import '../helper/column_helper.dart';
import '../helper/row_helper.dart';
import '../helper/test_helper_util.dart';
import '../matcher/pluto_object_matcher.dart';
import '../mock/mock_methods.dart';

void main() {
  const buttonText = 'open grid popup';

  const columnWidth = PlutoGridSettings.columnWidth;

  late PlutoGridStateManager stateManager;

  Future<void> build({
    required WidgetTester tester,
    List<PlutoColumn> columns = const [],
    List<PlutoRow> rows = const [],
    List<PlutoColumnGroup>? columnGroups,
    PlutoOnChangedEventCallback? onChanged,
    PlutoOnSelectedEventCallback? onSelected,
    PlutoOnSortedEventCallback? onSorted,
    PlutoOnRowCheckedEventCallback? onRowChecked,
    PlutoOnRowDoubleTapEventCallback? onRowDoubleTap,
    PlutoOnRowSecondaryTapEventCallback? onRowSecondaryTap,
    PlutoOnRowsMovedEventCallback? onRowsMoved,
    PlutoOnColumnsMovedEventCallback? onColumnsMoved,
    CreateHeaderCallBack? createHeader,
    CreateFooterCallBack? createFooter,
    Widget? noRowsWidget,
    PlutoRowColorCallback? rowColorCallback,
    PlutoColumnMenuDelegate? columnMenuDelegate,
    PlutoGridConfiguration configuration = const PlutoGridConfiguration(),
    PlutoGridMode mode = PlutoGridMode.normal,
    TextDirection textDirection = TextDirection.ltr,
  }) async {
    await TestHelperUtil.changeWidth(
      tester: tester,
      width: 1000,
      height: 450,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: Directionality(
            textDirection: textDirection,
            child: Builder(
              builder: (BuildContext context) {
                return TextButton(
                  onPressed: () {
                    PlutoGridPopup(
                      context: context,
                      columns: columns,
                      rows: rows,
                      columnGroups: columnGroups,
                      onLoaded: (event) => stateManager = event.stateManager,
                      onChanged: onChanged,
                      onSelected: onSelected,
                      onSorted: onSorted,
                      onRowChecked: onRowChecked,
                      onRowDoubleTap: onRowDoubleTap,
                      onRowSecondaryTap: onRowSecondaryTap,
                      onRowsMoved: onRowsMoved,
                      onColumnsMoved: onColumnsMoved,
                      createHeader: createHeader,
                      createFooter: createFooter,
                      noRowsWidget: noRowsWidget,
                      rowColorCallback: rowColorCallback,
                      columnMenuDelegate: columnMenuDelegate,
                      configuration: configuration,
                      mode: mode,
                    );
                  },
                  child: const Text(buttonText),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  testWidgets(
      'Directionality.ltr 인 경우, '
      'stateManager.isLTR, isRTL 이 적용 되어야 한다.', (tester) async {
    final columns = ColumnHelper.textColumn('title', count: 10);
    final rows = RowHelper.count(10, columns);

    await build(
      tester: tester,
      columns: columns,
      rows: rows,
      textDirection: TextDirection.ltr,
    );

    await tester.tap(find.text(buttonText));

    await tester.pumpAndSettle();

    expect(stateManager.isLTR, true);
    expect(stateManager.isRTL, false);
  });

  testWidgets(
      'Directionality.rtl 인 경우, '
      'stateManager.isLTR, isRTL 이 적용 되어야 한다.', (tester) async {
    final columns = ColumnHelper.textColumn('title', count: 10);
    final rows = RowHelper.count(10, columns);

    await build(
      tester: tester,
      columns: columns,
      rows: rows,
      textDirection: TextDirection.rtl,
    );

    await tester.tap(find.text(buttonText));

    await tester.pumpAndSettle();

    expect(stateManager.isLTR, false);
    expect(stateManager.isRTL, true);
  });

  testWidgets(
    'Directionality.rtl 인 경우 컬럼의 위치가 RTL 적용 되어야 한다.',
    (tester) async {
      final columns = ColumnHelper.textColumn('title', count: 10);
      final rows = RowHelper.count(10, columns);

      await build(
        tester: tester,
        columns: columns,
        rows: rows,
        textDirection: TextDirection.rtl,
      );

      await tester.tap(find.text(buttonText));

      await tester.pumpAndSettle();

      final firstColumn = find.text('title0');
      final firstStartPosition = tester.getTopRight(firstColumn);

      final secondColumn = find.text('title1');
      final secondStartPosition = tester.getTopRight(secondColumn);

      stateManager.moveScrollByColumn(PlutoMoveDirection.right, 8);
      await tester.pumpAndSettle();

      final scrollOffset = stateManager.scroll.horizontal!.offset;

      final lastColumn = find.text('title9');
      final lastStartPosition = tester.getTopRight(lastColumn);

      // 처음 컬럼의 dx 가 우측에 위치해 가장 크고 두번째 컬럼은 컬럼 넓이 만큼 작다.
      expect(firstStartPosition.dx - secondStartPosition.dx, columnWidth);

      // 마지막 컬럼은 앞의 9개 컬럼의 넓이에서 스크롤을 뺀 위치에 있다.
      expect(
        firstStartPosition.dx - lastStartPosition.dx,
        (columnWidth * 9) - scrollOffset,
      );
    },
  );

  testWidgets(
    'Directionality.rtl 인 경우 셀의 위치가 RTL 적용 되어야 한다.',
    (tester) async {
      final columns = ColumnHelper.textColumn('title', count: 10);
      final rows = RowHelper.count(10, columns);

      await build(
        tester: tester,
        columns: columns,
        rows: rows,
        textDirection: TextDirection.rtl,
      );

      await tester.tap(find.text(buttonText));

      await tester.pumpAndSettle();

      final firstCell = find.text('title0 value 0');
      final firstStartPosition = tester.getTopRight(firstCell);

      final secondCell = find.text('title1 value 0');
      final secondStartPosition = tester.getTopRight(secondCell);

      stateManager.moveScrollByColumn(PlutoMoveDirection.right, 8);
      await tester.pumpAndSettle();

      final scrollOffset = stateManager.scroll.horizontal!.offset;

      final lastCell = find.text('title9 value 0');
      final lastStartPosition = tester.getTopRight(lastCell);

      // 처음 셀의 dx 가 우측에 위치해 가장 크고 두번째 셀은 컬럼 넓이 만큼 작다.
      expect(firstStartPosition.dx - secondStartPosition.dx, columnWidth);

      // 마지막 셀은 앞의 9개 셀의 넓이에서 스크롤을 뺀 위치에 있다.
      expect(
        firstStartPosition.dx - lastStartPosition.dx,
        (columnWidth * 9) - scrollOffset,
      );
    },
  );

  testWidgets('셀 값을 변경 하면 onChanged 콜백이 동작해야 한다.', (tester) async {
    final columns = ColumnHelper.textColumn('title', count: 10);
    final rows = RowHelper.count(10, columns);

    PlutoGridOnChangedEvent? event;

    await build(
      tester: tester,
      columns: columns,
      rows: rows,
      onChanged: (e) => event = e,
    );

    await tester.tap(find.text(buttonText));
    await tester.pumpAndSettle();

    final cell = find.text('title0 value 0');
    await tester.tap(cell);
    await tester.pump();
    await tester.tap(cell);
    await tester.pump();
    await tester.enterText(cell, 'test value');
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();

    expect(event, isNotNull);
    expect(event!.value, 'test value');
    expect(event!.columnIdx, 0);
    expect(event!.rowIdx, 0);
  });

  testWidgets('mode 가 select 인 상태에서 행을 두번 탭하면 onSelected 콜백이 호출 되어야 한다.',
      (tester) async {
    final columns = ColumnHelper.textColumn('title', count: 10);
    final rows = RowHelper.count(10, columns);

    PlutoGridOnSelectedEvent? event;

    await build(
      tester: tester,
      columns: columns,
      rows: rows,
      onSelected: (e) => event = e,
      mode: PlutoGridMode.select,
    );

    await tester.tap(find.text(buttonText));
    await tester.pumpAndSettle();

    final cell = find.text('title1 value 3');
    await tester.tap(cell);
    await tester.pump();
    await tester.tap(cell);
    await tester.pump();

    expect(event, isNotNull);
    expect(event!.rowIdx, 3);
    expect(event!.cell!.value, 'title1 value 3');
  });

  testWidgets('mode 가 selectWithOneTap 인 상태에서 행을 탭하면 onSelected 콜백이 호출 되어야 한다.',
      (tester) async {
    final columns = ColumnHelper.textColumn('title', count: 10);
    final rows = RowHelper.count(10, columns);

    PlutoGridOnSelectedEvent? event;

    await build(
      tester: tester,
      columns: columns,
      rows: rows,
      onSelected: (e) => event = e,
      mode: PlutoGridMode.selectWithOneTap,
    );

    await tester.tap(find.text(buttonText));
    await tester.pumpAndSettle();

    final cell = find.text('title2 value 4');
    await tester.tap(cell);
    await tester.pump();

    expect(event, isNotNull);
    expect(event!.rowIdx, 4);
    expect(event!.cell!.value, 'title2 value 4');
  });

  testWidgets('컬럼을 탭하면 onSorted 콜백이 호출 되어야 한다.', (tester) async {
    final columns = ColumnHelper.textColumn('title', count: 10);
    final rows = RowHelper.count(10, columns);

    PlutoGridOnSortedEvent? event;

    await build(
      tester: tester,
      columns: columns,
      rows: rows,
      onSorted: (e) => event = e,
    );

    await tester.tap(find.text(buttonText));
    await tester.pumpAndSettle();

    final cell = find.text('title2');
    await tester.tap(cell);
    await tester.pump();

    expect(event, isNotNull);
    expect(event!.column.title, 'title2');
    expect(event!.column.sort, PlutoColumnSort.ascending);
    expect(event!.oldSort, PlutoColumnSort.none);

    await tester.tap(cell);
    await tester.pump();

    expect(event, isNotNull);
    expect(event!.column.title, 'title2');
    expect(event!.column.sort, PlutoColumnSort.descending);
    expect(event!.oldSort, PlutoColumnSort.ascending);

    await tester.tap(cell);
    await tester.pump();

    expect(event, isNotNull);
    expect(event!.column.title, 'title2');
    expect(event!.column.sort, PlutoColumnSort.none);
    expect(event!.oldSort, PlutoColumnSort.descending);
  });

  testWidgets(
      'PlutoColumn.enableRowChecked 가 true 인 상태에서 '
      '셀의 체크박스를 체크 하면 onRowChecked 콜백이 호출 되어야 한다.', (tester) async {
    final columns = ColumnHelper.textColumn('title', count: 10);
    final rows = RowHelper.count(10, columns);

    columns[0].enableRowChecked = true;

    PlutoGridOnRowCheckedEvent? event;

    await build(
      tester: tester,
      columns: columns,
      rows: rows,
      onRowChecked: (e) => event = e,
    );

    await tester.tap(find.text(buttonText));
    await tester.pumpAndSettle();

    final cell = find.text('title0 value 1');
    final checkbox = find.descendant(
      of: find.ancestor(of: cell, matching: find.byType(PlutoBaseCell)),
      matching: find.byType(Checkbox),
    );
    await tester.tap(checkbox);
    await tester.pump();

    expect(event, isNotNull);
    expect(event!.rowIdx, 1);
    expect(event!.isChecked, true);
    expect(event!.isAll, false);
    expect(event!.isRow, true);
  });

  testWidgets('셀을 두번 탭하면 onRowDoubleTap 콜백이 호출 되어야 한다.', (tester) async {
    final columns = ColumnHelper.textColumn('title', count: 10);
    final rows = RowHelper.count(10, columns);

    PlutoGridOnRowDoubleTapEvent? event;

    await build(
      tester: tester,
      columns: columns,
      rows: rows,
      onRowDoubleTap: (e) => event = e,
    );

    await tester.tap(find.text(buttonText));
    await tester.pumpAndSettle();

    final cell = find.text('title2 value 2');
    await tester.tap(cell);
    await tester.pump(kDoubleTapMinTime);
    await tester.tap(cell);
    await tester.pumpAndSettle();

    expect(event, isNotNull);
    expect(event!.rowIdx, 2);
    expect(event!.cell.value, 'title2 value 2');
  });

  testWidgets('Secondary 버튼을 탭하면 onRowSecondaryTap 콜백이 호출 되어야 한다.',
      (tester) async {
    final columns = ColumnHelper.textColumn('title', count: 10);
    final rows = RowHelper.count(10, columns);

    PlutoGridOnRowSecondaryTapEvent? event;

    await build(
      tester: tester,
      columns: columns,
      rows: rows,
      onRowSecondaryTap: (e) => event = e,
    );

    await tester.tap(find.text(buttonText));
    await tester.pumpAndSettle();

    final cell = find.text('title3 value 5');
    await tester.tap(cell, buttons: kSecondaryButton);
    await tester.pump();

    expect(event, isNotNull);
    expect(event!.rowIdx, 5);
    expect(event!.cell.value, 'title3 value 5');
  });

  testWidgets('행을 드래그 하면 onRowsMoved 콜백이 호출 되어야 한다.', (tester) async {
    final columns = ColumnHelper.textColumn('title', count: 10);
    final rows = RowHelper.count(10, columns);

    columns[0].enableRowDrag = true;

    PlutoGridOnRowsMovedEvent? event;

    await build(
      tester: tester,
      columns: columns,
      rows: rows,
      onRowsMoved: (e) => event = e,
    );

    await tester.tap(find.text(buttonText));
    await tester.pumpAndSettle();

    final cell = find.text('title0 value 0');
    final dragIcon = find.descendant(
      of: find.ancestor(of: cell, matching: find.byType(PlutoBaseCell)),
      matching: find.byType(Icon),
    );
    // 행 기본 높이 45 * 2 (2개 행 아래로 드래그)
    await tester.drag(dragIcon, const Offset(0, 90));
    await tester.pump();

    expect(event, isNotNull);
    expect(event!.idx, 2);
    expect(event!.rows.length, 1);
    expect(event!.rows[0].cells['title0']!.value, 'title0 value 0');
  });

  testWidgets('createHeader 위젯이 렌더링 되어야 한다.', (tester) async {
    final columns = ColumnHelper.textColumn('title', count: 10);
    final rows = RowHelper.count(10, columns);

    final headerKey = GlobalKey();

    await build(
      tester: tester,
      columns: columns,
      rows: rows,
      createHeader: (_) => ColoredBox(color: Colors.cyan, key: headerKey),
    );

    await tester.tap(find.text(buttonText));
    await tester.pumpAndSettle();

    final header = find.byKey(headerKey);
    expect(header, findsOneWidget);
  });

  testWidgets('createFooter 위젯이 렌더링 되어야 한다.', (tester) async {
    final columns = ColumnHelper.textColumn('title', count: 10);
    final rows = RowHelper.count(10, columns);

    final footerKey = GlobalKey();

    await build(
      tester: tester,
      columns: columns,
      rows: rows,
      createFooter: (_) => ColoredBox(color: Colors.cyan, key: footerKey),
    );

    await tester.tap(find.text(buttonText));
    await tester.pumpAndSettle();

    final footer = find.byKey(footerKey);
    expect(footer, findsOneWidget);
  });

  testWidgets('rowColorCallback 이 적용 되어야 한다.', (tester) async {
    final columns = ColumnHelper.textColumn('title', count: 10);
    final rows = RowHelper.count(10, columns);

    await build(
      tester: tester,
      columns: columns,
      rows: rows,
      configuration: const PlutoGridConfiguration(
          style: PlutoGridStyleConfig(
        enableRowColorAnimation: true,
      )),
      rowColorCallback: (context) {
        return context.rowIdx % 2 == 0 ? Colors.pink : Colors.cyan;
      },
    );

    await tester.tap(find.text(buttonText));
    await tester.pumpAndSettle();

    final containers = find
        .descendant(
          of: find.byType(PlutoBaseRow),
          matching: find.byType(AnimatedContainer),
        )
        .evaluate();

    final colors = containers.map(
      (e) =>
          ((e.widget as AnimatedContainer).decoration as BoxDecoration).color,
    );

    expect(colors.elementAt(0), Colors.pink);
    expect(colors.elementAt(1), Colors.cyan);
    expect(colors.elementAt(2), Colors.pink);
    expect(colors.elementAt(3), Colors.cyan);
  });

  testWidgets('columnMenuDelegate 를 설정 한 경우 컬럼 메뉴가 변경 되어야 한다.', (tester) async {
    final columns = ColumnHelper.textColumn('title', count: 10);
    final rows = RowHelper.count(10, columns);

    await build(
      tester: tester,
      columns: columns,
      rows: rows,
      columnMenuDelegate: _TestColumnMenu(),
    );

    await tester.tap(find.text(buttonText));
    await tester.pumpAndSettle();

    final column = find.text('title0');
    final menuIcon = find.descendant(
      of: find.ancestor(of: column, matching: find.byType(PlutoBaseColumn)),
      matching: find.byType(PlutoGridColumnIcon),
    );

    await tester.tap(menuIcon);
    await tester.pump();

    expect(find.text('test menu 1'), findsOneWidget);
    expect(find.text('test menu 2'), findsOneWidget);
  });

  testWidgets('컬럼을 좌측 고정 하면 onColumnsMoved 콜백이 호출 되어야 한다.', (tester) async {
    final mock = MockMethods();
    final columns = ColumnHelper.textColumn('column', count: 10);
    final rows = RowHelper.count(10, columns);

    await build(
      tester: tester,
      columns: columns,
      rows: rows,
      onColumnsMoved: mock.oneParamReturnVoid<PlutoGridOnColumnsMovedEvent>,
    );

    await tester.tap(find.text(buttonText));
    await tester.pumpAndSettle();

    stateManager.toggleFrozenColumn(columns[1], PlutoColumnFrozen.start);
    await tester.pump();

    verify(mock.oneParamReturnVoid(
        PlutoObjectMatcher<PlutoGridOnColumnsMovedEvent>(rule: (e) {
      return e.idx == 1 && e.visualIdx == 0 && e.columns.length == 1;
    }))).called(1);
  });

  testWidgets('컬럼을 우측 고정 하면 onColumnsMoved 콜백이 호출 되어야 한다.', (tester) async {
    final mock = MockMethods();
    final columns = ColumnHelper.textColumn('column', count: 10);
    final rows = RowHelper.count(10, columns);

    await build(
      tester: tester,
      columns: columns,
      rows: rows,
      onColumnsMoved: mock.oneParamReturnVoid<PlutoGridOnColumnsMovedEvent>,
    );

    await tester.tap(find.text(buttonText));
    await tester.pumpAndSettle();

    stateManager.toggleFrozenColumn(columns[1], PlutoColumnFrozen.end);
    await tester.pump();

    verify(mock.oneParamReturnVoid(
        PlutoObjectMatcher<PlutoGridOnColumnsMovedEvent>(rule: (e) {
      return e.idx == 1 && e.visualIdx == 9 && e.columns.length == 1;
    }))).called(1);
  });

  testWidgets('컬럼을 드래그하여 이동하면 onColumnsMoved 콜백이 호출 되어야 한다.', (tester) async {
    final mock = MockMethods();
    final columns = ColumnHelper.textColumn('column', count: 10);
    final rows = RowHelper.count(10, columns);

    await build(
      tester: tester,
      columns: columns,
      rows: rows,
      onColumnsMoved: mock.oneParamReturnVoid<PlutoGridOnColumnsMovedEvent>,
    );

    await tester.tap(find.text(buttonText));
    await tester.pumpAndSettle();

    final sampleColumn = find.text('column1');

    await tester.drag(sampleColumn, const Offset(400, 0));

    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    verify(mock.oneParamReturnVoid(
        PlutoObjectMatcher<PlutoGridOnColumnsMovedEvent>(rule: (e) {
      return e.idx == 3 && e.visualIdx == 3 && e.columns.length == 1;
    }))).called(1);
  });

  group('noRowsWidget', () {
    testWidgets('행이 없는 경우 noRowsWidget 이 렌더링 되어야 한다.', (tester) async {
      final columns = ColumnHelper.textColumn('column', count: 10);
      final rows = <PlutoRow>[];
      const noRowsWidget = Center(
        key: ValueKey('NoRowsWidget'),
        child: Text('There are no rows.'),
      );

      await build(
        tester: tester,
        columns: columns,
        rows: rows,
        noRowsWidget: noRowsWidget,
      );

      await tester.tap(find.text(buttonText));
      await tester.pumpAndSettle();

      expect(find.byKey(noRowsWidget.key!), findsOneWidget);
    });

    testWidgets('행을 삭제하는 경우 noRowsWidget 이 렌더링 되어야 한다.', (tester) async {
      final columns = ColumnHelper.textColumn('column', count: 10);
      final rows = RowHelper.count(10, columns);
      const noRowsWidget = Center(
        key: ValueKey('NoRowsWidget'),
        child: Text('There are no rows.'),
      );

      await build(
        tester: tester,
        columns: columns,
        rows: rows,
        noRowsWidget: noRowsWidget,
      );

      await tester.tap(find.text(buttonText));
      await tester.pumpAndSettle();

      expect(find.byKey(noRowsWidget.key!), findsNothing);

      stateManager.removeAllRows();

      await tester.pump(const Duration(milliseconds: 350));

      expect(find.byKey(noRowsWidget.key!), findsOneWidget);
    });

    testWidgets('행을 추가하는 경우 noRowsWidget 이 렌더링 되지 않아야 한다.', (tester) async {
      final columns = ColumnHelper.textColumn('column', count: 10);
      final rows = <PlutoRow>[];
      const noRowsWidget = Center(
        key: ValueKey('NoRowsWidget'),
        child: Text('There are no rows.'),
      );

      await build(
        tester: tester,
        columns: columns,
        rows: rows,
        noRowsWidget: noRowsWidget,
      );

      await tester.tap(find.text(buttonText));
      await tester.pumpAndSettle();

      expect(find.byKey(noRowsWidget.key!), findsOneWidget);

      stateManager.appendNewRows();

      await tester.pumpAndSettle(const Duration(milliseconds: 350));

      expect(find.byKey(noRowsWidget.key!), findsNothing);
    });
  });
}

class _TestColumnMenu implements PlutoColumnMenuDelegate {
  @override
  List<PopupMenuEntry> buildMenuItems({
    required PlutoGridStateManager stateManager,
    required PlutoColumn column,
  }) {
    return [
      const PopupMenuItem(
        value: 'test1',
        height: 36,
        enabled: true,
        child: Text('test menu 1'),
      ),
      const PopupMenuItem(
        value: 'test2',
        height: 36,
        enabled: true,
        child: Text('test menu 2'),
      ),
    ];
  }

  @override
  void onSelected({
    required BuildContext context,
    required PlutoGridStateManager stateManager,
    required PlutoColumn column,
    required bool mounted,
    required selected,
  }) {}
}
