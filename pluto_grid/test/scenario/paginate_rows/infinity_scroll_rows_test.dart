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
    bool initialFetch = true,
    bool fetchWithSorting = true,
    bool fetchWithFiltering = true,
    bool showColumnFilter = false,
    required PlutoInfinityScrollRowsFetch fetch,
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
            createFooter: (s) => PlutoInfinityScrollRows(
              initialFetch: initialFetch,
              fetchWithSorting: fetchWithSorting,
              fetchWithFiltering: fetchWithFiltering,
              fetch: fetch,
              stateManager: s,
            ),
          ),
        ),
      ),
    );
  }

  PlutoInfinityScrollRowsFetch makeFetch({
    int pageSize = 20,
    int delayedMS = 20,
    required List<PlutoRow> dummyRows,
  }) {
    return (PlutoInfinityScrollRowsRequest request) async {
      List<PlutoRow> tempList = dummyRows;

      if (request.filterRows.isNotEmpty) {
        final filter = FilterHelper.convertRowsToFilter(
          request.filterRows,
          stateManager.refColumns,
        );

        tempList = dummyRows.where(filter!).toList();
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

      Iterable<PlutoRow> fetchedRows = tempList.skipWhile(
        (row) => request.lastRow != null && row.key != request.lastRow!.key,
      );
      if (request.lastRow == null) {
        fetchedRows = fetchedRows.take(pageSize);
      } else {
        fetchedRows = fetchedRows.skip(1).take(pageSize);
      }

      await Future.delayed(Duration(milliseconds: delayedMS));

      final bool isLast =
          fetchedRows.isEmpty || tempList.last.key == fetchedRows.last.key;

      return Future.value(PlutoInfinityScrollRowsResponse(
        isLast: isLast,
        rows: fetchedRows.toList(),
      ));
    };
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

  testWidgets('최초 20개 행이 렌더링 되어야 한다.', (tester) async {
    final dummyRows = RowHelper.count(90, columns);
    final fetch = makeFetch(dummyRows: dummyRows);

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
    expect(find.text('column0 value 16'), findsOneWidget);
    expect(find.text('column4 value 16'), findsOneWidget);
  });

  testWidgets('initialFetch 가 false 인 경우 행이 렌더링 되지 않아야 한다.', (tester) async {
    final dummyRows = RowHelper.count(90, columns);
    final fetch = makeFetch(dummyRows: dummyRows);

    await buildGrid(tester, fetch: fetch, initialFetch: false);
    await tester.pumpAndSettle(const Duration(milliseconds: 30));

    expect(stateManager.refRows.length, 0);
    expect(find.byType(PlutoBaseRow), findsNothing);
  });

  testWidgets('fetchWithSorting 를 true 로 설정하면 sortOnlyEvent 의 값도 변경 되어야 한다.',
      (tester) async {
    final dummyRows = RowHelper.count(90, columns);
    final fetch = makeFetch(dummyRows: dummyRows);

    await buildGrid(
      tester,
      fetch: fetch,
      initialFetch: false,
      fetchWithSorting: true,
    );

    expect(stateManager.sortOnlyEvent, true);
  });

  testWidgets(
      'fetchWithFiltering 를 true 로 설정하면 filterOnlyEvent 의 값도 변경 되어야 한다.',
      (tester) async {
    final dummyRows = RowHelper.count(90, columns);
    final fetch = makeFetch(dummyRows: dummyRows);

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
    final fetch = makeFetch(dummyRows: dummyRows);

    rows = dummyRows.getRange(0, 20).toList();
    await buildGrid(tester, fetch: fetch, initialFetch: false);
    await tester.pumpAndSettle();

    expect(stateManager.refRows.length, 20);
    // 화면 사이즈가 17개 행을 표현
    expect(find.byType(PlutoBaseRow), findsNWidgets(17));
  });

  testWidgets('가장 아래로 스크롤 되면 20개 행이 더 렌더링 되어야 한다.', (tester) async {
    final dummyRows = RowHelper.count(90, columns);
    final fetch = makeFetch(dummyRows: dummyRows);

    await buildGrid(tester, fetch: fetch);
    await tester.pumpAndSettle(const Duration(milliseconds: 30));

    expect(stateManager.refRows.length, 20);

    await tester.scrollUntilVisible(
      find.text('column0 value 19'),
      500.0,
      scrollable: find.descendant(
        of: find.byType(ListView),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 30));

    expect(stateManager.refRows.length, 40);

    await tester.tap(find.text('column0 value 19'));
    await tester.pumpAndSettle();

    await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
    await tester.pumpAndSettle();

    expect(find.text('column0 value 35'), findsOneWidget);
  });

  testWidgets(
      'PageDown 버튼으로 가장 아래로 이동하면, '
      '20개 행이 더 렌더링 되어야 한다.', (tester) async {
    final dummyRows = RowHelper.count(90, columns);
    final fetch = makeFetch(dummyRows: dummyRows);

    await buildGrid(tester, fetch: fetch);
    await tester.pumpAndSettle(const Duration(milliseconds: 30));

    expect(stateManager.refRows.length, 20);

    await tester.tap(find.text('column0 value 15'));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
    await tester.pumpAndSettle(const Duration(milliseconds: 30));

    expect(stateManager.refRows.length, 40);

    await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
    await tester.pumpAndSettle();

    expect(find.text('column0 value 30'), findsOneWidget);
  });

  testWidgets(
      '40 개 이상의 행을 렌더링 한 후 컬럼 정렬을 하면, '
      '새로 정렬된 20개 행이 렌더링 되어야 한다.', (tester) async {
    final dummyRows = RowHelper.count(90, columns);
    final fetch = makeFetch(dummyRows: dummyRows);

    await buildGrid(tester, fetch: fetch);
    await tester.pumpAndSettle(const Duration(milliseconds: 30));

    await tester.tap(find.text('column0 value 15'));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
    await tester.pumpAndSettle(const Duration(milliseconds: 30));

    expect(stateManager.refRows.length, 40);

    await tester.tap(find.text('column0'));
    await tester.pumpAndSettle();

    expect(stateManager.refRows.length, 20);
  });

  testWidgets(
      '40 개 이상의 행을 렌더링 한 후 column0 의 필터링 값을 설정하면, '
      '필터링이 적용된 새로운 행이 렌더링 되어야 한다.', (tester) async {
    final dummyRows = RowHelper.count(90, columns);
    final fetch = makeFetch(dummyRows: dummyRows);

    await buildGrid(tester, fetch: fetch, showColumnFilter: true);
    await tester.pumpAndSettle(const Duration(milliseconds: 30));

    await tester.tap(find.text('column0 value 14'));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
    await tester.pumpAndSettle(const Duration(milliseconds: 30));

    expect(stateManager.refRows.length, 40);

    await tapAndEnterTextColumnFilter(tester, 'column0', 'value');
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(stateManager.refRows.length, 20);
  });

  testWidgets(
      '필터링이 적용된 상태에서, '
      '필터링 아이콘이 렌더링 되어야 한다.', (tester) async {
    final dummyRows = RowHelper.count(90, columns);
    final fetch = makeFetch(dummyRows: dummyRows);

    await buildGrid(tester, fetch: fetch, showColumnFilter: true);
    await tester.pumpAndSettle(const Duration(milliseconds: 30));

    expect(stateManager.hasFilter, false);

    await tapAndEnterTextColumnFilter(tester, 'column0', 'value');
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(stateManager.hasFilter, true);
    expect(find.byIcon(Icons.filter_alt_outlined), findsOneWidget);
  });

  testWidgets(
      '마지막 페이지까지 스크롤을 하면, '
      '총 90 개의 행이 렌더링 되어야 한다.', (tester) async {
    final dummyRows = RowHelper.count(90, columns);
    final fetch = makeFetch(dummyRows: dummyRows);

    await buildGrid(tester, fetch: fetch);
    await tester.pumpAndSettle(const Duration(milliseconds: 30));

    await tester.scrollUntilVisible(
      find.text('column0 value 89'),
      500.0,
      scrollable: find.descendant(
        of: find.byType(ListView),
        matching: find.byType(Scrollable),
      ),
    );

    expect(stateManager.refRows.length, 90);

    await tester.tap(find.text('column0 value 89'));
    await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
    await tester.pumpAndSettle(const Duration(milliseconds: 30));

    expect(stateManager.refRows.length, 90);
  });
}
