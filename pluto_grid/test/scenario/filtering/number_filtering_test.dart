import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:pluto_grid/src/ui/ui.dart';

void main() {
  late PlutoGridStateManager stateManager;

  Widget buildGrid({
    required List<PlutoColumn> columns,
    required List<PlutoRow> rows,
  }) {
    return MaterialApp(
      home: Material(
        child: PlutoGrid(
          columns: columns,
          rows: rows,
          onLoaded: (e) {
            stateManager = e.stateManager;
            stateManager.setShowColumnFilter(true);
          },
        ),
      ),
    );
  }

  Finder findFilterTextField() {
    return find.descendant(
      of: find.byType(PlutoColumnFilter),
      matching: find.byType(TextField),
    );
  }

  Future<void> tapAndEnterTextColumnFilter(
    WidgetTester tester,
    String? enterText,
  ) async {
    final textField = findFilterTextField();

    // 텍스트 박스가 최초에 포커스를 받으려면 두번 탭.
    await tester.tap(textField);
    await tester.tap(textField);

    if (enterText != null) {
      await tester.enterText(textField, enterText);
    }
  }

  group('기본 숫자 컬럼 테스트.', () {
    final columns = [
      PlutoColumn(
        title: 'column',
        field: 'column',
        type: PlutoColumnType.number(),
      ),
    ];

    final rows = [
      PlutoRow(cells: {'column': PlutoCell(value: 0)}),
      PlutoRow(cells: {'column': PlutoCell(value: -100)}),
      PlutoRow(cells: {'column': PlutoCell(value: -123000)}),
      PlutoRow(cells: {'column': PlutoCell(value: 123000)}),
      PlutoRow(cells: {'column': PlutoCell(value: 1)}),
      PlutoRow(cells: {'column': PlutoCell(value: -1)}),
      PlutoRow(cells: {'column': PlutoCell(value: 300)}),
      PlutoRow(cells: {'column': PlutoCell(value: 311)}),
      PlutoRow(cells: {'column': PlutoCell(value: -999)}),
      PlutoRow(cells: {'column': PlutoCell(value: 3133)}),
    ];

    testWidgets('렌더링 테스트', (tester) async {
      await tester.pumpWidget(buildGrid(columns: columns, rows: rows));

      expect(find.text('0'), findsOneWidget);
      expect(find.text('-100'), findsOneWidget);
      expect(find.text('-123,000'), findsOneWidget);
      expect(find.text('123,000'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('-1'), findsOneWidget);
      expect(find.text('300'), findsOneWidget);
      expect(find.text('311'), findsOneWidget);
      expect(find.text('-999'), findsOneWidget);
      expect(find.text('3,133'), findsOneWidget);
    });

    testWidgets('300 보다 큰 수 필터링.', (tester) async {
      await tester.pumpWidget(buildGrid(columns: columns, rows: rows));
      await tester.pump();

      columns.first.setDefaultFilter(const PlutoFilterTypeGreaterThan());

      await tapAndEnterTextColumnFilter(tester, '300');
      await tester.pumpAndSettle(const Duration(seconds: 1));

      final values = stateManager.refRows.map((e) => e.cells['column']!.value);

      expect(values, [123000, 311, 3133]);
    });

    testWidgets('300 보다 크거나 같은 수 필터링.', (tester) async {
      await tester.pumpWidget(buildGrid(columns: columns, rows: rows));
      await tester.pump();

      columns.first.setDefaultFilter(
        const PlutoFilterTypeGreaterThanOrEqualTo(),
      );

      await tapAndEnterTextColumnFilter(tester, '300');
      await tester.pumpAndSettle(const Duration(seconds: 1));

      final values = stateManager.refRows.map((e) => e.cells['column']!.value);

      expect(values, [123000, 300, 311, 3133]);
    });
  });
}
