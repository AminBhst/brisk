import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:pluto_grid/src/ui/ui.dart';

import '../../helper/column_helper.dart';
import '../../helper/row_helper.dart';
import '../../helper/test_helper_util.dart';

void main() {
  late List<PlutoColumn> columns;

  late List<PlutoRow> rows;

  late PlutoGridStateManager stateManager;

  setUp(() {
    columns = ColumnHelper.textColumn('column', count: 5);
    rows = [];
  });

  Future<void> buildGrid(
    WidgetTester tester, {
    int initialPage = 1,
    int? pageSizeToMove,
    bool initialFetch = true,
    bool fetchWithSorting = true,
    bool fetchWithFiltering = true,
    bool showColumnFilter = false,
    required PlutoLazyPaginationFetch fetch,
  }) async {
    await TestHelperUtil.changeWidth(
      tester: tester,
      width: 1200,
      height: 800,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: PlutoGrid(
            columns: columns,
            rows: rows,
            onLoaded: (PlutoGridOnLoadedEvent event) {
              stateManager = event.stateManager;
              if (showColumnFilter) {
                stateManager.setShowColumnFilter(true);
              }
            },
            createFooter: (s) => PlutoLazyPagination(
              initialPage: initialPage,
              initialFetch: initialFetch,
              fetchWithSorting: fetchWithSorting,
              fetchWithFiltering: fetchWithFiltering,
              pageSizeToMove: pageSizeToMove,
              fetch: fetch,
              stateManager: s,
            ),
          ),
        ),
      ),
    );
  }

  PlutoLazyPaginationFetch makeFetch({
    int pageSize = 20,
    int delayedMS = 20,
    required List<PlutoRow> fakeFetchedRows,
  }) {
    return (
      PlutoLazyPaginationRequest request,
    ) async {
      List<PlutoRow> tempList = fakeFetchedRows;

      if (request.filterRows.isNotEmpty) {
        final filter = FilterHelper.convertRowsToFilter(
          request.filterRows,
          stateManager.refColumns,
        );

        tempList = fakeFetchedRows.where(filter!).toList();
      }

      if (request.sortColumn != null && !request.sortColumn!.sort.isNone) {
        tempList = [...tempList];

        tempList.sort((a, b) {
          final sortA = request.sortColumn!.sort.isAscending ? a : b;
          final sortB = request.sortColumn!.sort.isAscending ? b : a;

          return request.sortColumn!.type.compare(
            sortA.cells[request.sortColumn!.field]!.valueForSorting,
            sortB.cells[request.sortColumn!.field]!.valueForSorting,
          );
        });
      }

      final page = request.page;
      final totalPage = (tempList.length / pageSize).ceil();
      final start = (page - 1) * pageSize;
      final end = start + pageSize;

      Iterable<PlutoRow> fetchedRows = tempList.getRange(
        max(0, start),
        min(tempList.length, end),
      );

      await Future.delayed(Duration(milliseconds: delayedMS));

      return Future.value(PlutoLazyPaginationResponse(
        totalPage: totalPage,
        rows: fetchedRows.toList(),
      ));
    };
  }

  List<TextButton> buttonsToWidgets(Finder pageButtons) {
    return pageButtons
        .evaluate()
        .map((e) => e.widget)
        .cast<TextButton>()
        .toList();
  }

  String? textFromTextButton(TextButton button) {
    return (button.child as Text).data;
  }

  TextStyle textStyleFromTextButton(TextButton button) {
    return (button.child as Text).style as TextStyle;
  }

  Finder getPageButtons() {
    return find.byType(TextButton);
  }

  Finder findFilterTextField(String columnTitle) {
    return find.descendant(
      of: find.descendant(
          of: find.ancestor(
            of: find.text(columnTitle),
            matching: find.byType(PlutoBaseColumn),
          ),
          matching: find.byType(PlutoColumnFilter)),
      matching: find.byType(TextField),
    );
  }

  Future<void> tapAndEnterTextColumnFilter(
    WidgetTester tester,
    String columnTitle,
    String? enterText,
  ) async {
    final textField = findFilterTextField(columnTitle);

    // 텍스트 박스가 최초에 포커스를 받으려면 두번 탭.
    await tester.tap(textField);
    await tester.tap(textField);

    if (enterText != null) {
      await tester.enterText(textField, enterText);
    }
  }

  testWidgets('최초에 20개 행이 렌더링 되어야 한다.', (tester) async {
    final dummyRows = RowHelper.count(90, columns);
    final fetch = makeFetch(fakeFetchedRows: dummyRows);

    await buildGrid(tester, fetch: fetch);
    await tester.pumpAndSettle(const Duration(milliseconds: 30));

    expect(stateManager.refRows.length, 20);

    expect(
      dummyRows.getRange(0, 20).map((e) => e.key),
      stateManager.refRows.map((e) => e.key),
    );

    expect(find.text('column0 value 0'), findsOneWidget);
    expect(find.text('column4 value 0'), findsOneWidget);
    expect(find.text('column0 value 7'), findsOneWidget);
    expect(find.text('column4 value 7'), findsOneWidget);
    expect(find.text('column0 value 15'), findsOneWidget);
    expect(find.text('column4 value 15'), findsOneWidget);

    await tester.tap(find.text('column0 value 14'));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
    await tester.pumpAndSettle();

    expect(find.text('column0 value 19'), findsOneWidget);
    expect(find.text('column4 value 19'), findsOneWidget);
  });

  testWidgets(
      'initialFetch 가 false 인 경우, '
      '행이 렌더링 되지 않아야 한다.', (tester) async {
    final dummyRows = RowHelper.count(90, columns);
    final fetch = makeFetch(fakeFetchedRows: dummyRows);

    await buildGrid(tester, fetch: fetch, initialFetch: false);
    await tester.pumpAndSettle(const Duration(milliseconds: 30));

    expect(stateManager.refRows.length, 0);
    expect(find.byType(PlutoBaseRow), findsNothing);
  });

  testWidgets(
      'fetchWithSorting 를 true 로 설정하면, '
      'sortOnlyEvent 의 값도 변경 되어야 한다.', (tester) async {
    final dummyRows = RowHelper.count(90, columns);
    final fetch = makeFetch(fakeFetchedRows: dummyRows);

    await buildGrid(
      tester,
      fetch: fetch,
      initialFetch: false,
      fetchWithSorting: true,
    );

    expect(stateManager.sortOnlyEvent, true);
  });

  testWidgets(
      'fetchWithFiltering 를 true 로 설정하면, '
      'filterOnlyEvent 의 값도 변경 되어야 한다.', (tester) async {
    final dummyRows = RowHelper.count(90, columns);
    final fetch = makeFetch(fakeFetchedRows: dummyRows);

    await buildGrid(
      tester,
      fetch: fetch,
      initialFetch: false,
      fetchWithFiltering: true,
    );

    expect(stateManager.filterOnlyEvent, true);
  });

  testWidgets(
      'initialFetch 가 false 이고 PlutoGrid 에 20개의 행을 전달한 경우, '
      '20개 행이 렌더링 되어야 한다.', (tester) async {
    final dummyRows = RowHelper.count(90, columns);
    final fetch = makeFetch(fakeFetchedRows: dummyRows);

    rows = dummyRows.getRange(0, 20).toList();
    await buildGrid(tester, fetch: fetch, initialFetch: false);
    await tester.pumpAndSettle();

    expect(stateManager.refRows.length, 20);
    // 화면 사이즈가 16개 행을 표현
    expect(find.byType(PlutoBaseRow), findsNWidgets(16));
  });

  testWidgets('페이지 버튼이 5개 렌더링 되어야 한다.', (tester) async {
    final dummyRows = RowHelper.count(90, columns);
    final fetch = makeFetch(fakeFetchedRows: dummyRows);

    rows = dummyRows.getRange(0, 20).toList();
    await buildGrid(tester, fetch: fetch);
    await tester.pumpAndSettle(const Duration(milliseconds: 30));

    List<TextButton> pageButtonsAsTextButton = buttonsToWidgets(
      getPageButtons(),
    );

    expect(pageButtonsAsTextButton.length, 5);
    expect(textFromTextButton(pageButtonsAsTextButton[0]), '1');
    expect(textFromTextButton(pageButtonsAsTextButton[1]), '2');
    expect(textFromTextButton(pageButtonsAsTextButton[2]), '3');
    expect(textFromTextButton(pageButtonsAsTextButton[3]), '4');
    expect(textFromTextButton(pageButtonsAsTextButton[4]), '5');
  });

  testWidgets('1 페이지 버튼이 활성화 되어야 한다.', (tester) async {
    final dummyRows = RowHelper.count(90, columns);
    final fetch = makeFetch(fakeFetchedRows: dummyRows);

    rows = dummyRows.getRange(0, 20).toList();
    await buildGrid(tester, fetch: fetch);
    await tester.pumpAndSettle(const Duration(milliseconds: 30));

    List<TextButton> pageButtonsAsTextButton = buttonsToWidgets(
      getPageButtons(),
    );

    expect((pageButtonsAsTextButton[0].child as Text).data, '1');

    final style1 = textStyleFromTextButton(pageButtonsAsTextButton[0]);

    expect(style1.color, stateManager.configuration.style.activatedBorderColor);
  });

  testWidgets(
      '2 페이지 버튼을 탭하면, '
      '2 페이지에 해당 되는 행이 렌더링 되어야 한다.', (tester) async {
    final dummyRows = RowHelper.count(90, columns);
    final fetch = makeFetch(fakeFetchedRows: dummyRows);

    await buildGrid(tester, fetch: fetch);
    await tester.pumpAndSettle(const Duration(milliseconds: 30));

    expect(stateManager.refRows.length, 20);

    await tester.tap(getPageButtons().at(1));
    await tester.pumpAndSettle(const Duration(milliseconds: 30));

    expect(stateManager.refRows.length, 20);

    expect(find.text('column0 value 20'), findsOneWidget);
    expect(find.text('column4 value 20'), findsOneWidget);
    expect(find.text('column0 value 21'), findsOneWidget);
    expect(find.text('column4 value 21'), findsOneWidget);
    expect(find.text('column0 value 35'), findsOneWidget);
    expect(find.text('column4 value 35'), findsOneWidget);

    await tester.tap(find.text('column0 value 34'));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
    await tester.pumpAndSettle();

    expect(find.text('column0 value 39'), findsOneWidget);
    expect(find.text('column4 value 39'), findsOneWidget);
  });

  testWidgets(
      'initialPage 를 3으로 설정하면, '
      '3 페이지에 해당 되는 행이 렌더링 되어야 한다.', (tester) async {
    final dummyRows = RowHelper.count(90, columns);
    final fetch = makeFetch(fakeFetchedRows: dummyRows);

    await buildGrid(tester, fetch: fetch, initialPage: 3);
    await tester.pumpAndSettle(const Duration(milliseconds: 30));

    expect(stateManager.refRows.length, 20);

    expect(find.text('column0 value 40'), findsOneWidget);
    expect(find.text('column4 value 40'), findsOneWidget);
    expect(find.text('column0 value 41'), findsOneWidget);
    expect(find.text('column4 value 41'), findsOneWidget);
    expect(find.text('column0 value 55'), findsOneWidget);
    expect(find.text('column4 value 55'), findsOneWidget);

    await tester.tap(find.text('column0 value 54'));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
    await tester.pumpAndSettle();

    expect(find.text('column0 value 59'), findsOneWidget);
    expect(find.text('column4 value 59'), findsOneWidget);
  });

  testWidgets(
      'initialPage 를 3으로 설정하면, '
      '3 페이지 버튼이 활성화 되어야 한다.', (tester) async {
    final dummyRows = RowHelper.count(90, columns);
    final fetch = makeFetch(fakeFetchedRows: dummyRows);

    await buildGrid(tester, fetch: fetch, initialPage: 3);
    await tester.pumpAndSettle(const Duration(milliseconds: 30));

    List<TextButton> pageButtonsAsTextButton = buttonsToWidgets(
      getPageButtons(),
    );

    expect((pageButtonsAsTextButton[2].child as Text).data, '3');

    final style1 = textStyleFromTextButton(pageButtonsAsTextButton[2]);

    expect(style1.color, stateManager.configuration.style.activatedBorderColor);
  });

  testWidgets(
      '필터링이 적용된 상태에서, '
      '필터링 아이콘이 렌더링 되어야 한다.', (tester) async {
    final dummyRows = RowHelper.count(90, columns);
    final fetch = makeFetch(fakeFetchedRows: dummyRows);

    await buildGrid(tester, fetch: fetch, showColumnFilter: true);
    await tester.pumpAndSettle(const Duration(milliseconds: 30));

    expect(stateManager.hasFilter, false);

    await tapAndEnterTextColumnFilter(tester, 'column0', 'value');
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(stateManager.hasFilter, true);
    expect(find.byIcon(Icons.filter_alt_outlined), findsOneWidget);
  });
}
