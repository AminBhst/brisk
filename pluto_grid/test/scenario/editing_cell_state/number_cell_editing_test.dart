import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../mock/mock_methods.dart';

void main() {
  late PlutoGridStateManager stateManager;

  Widget buildGrid({
    required List<PlutoColumn> columns,
    required List<PlutoRow> rows,
    void Function(PlutoGridOnChangedEvent)? onChanged,
  }) {
    return MaterialApp(
      home: Material(
        child: PlutoGrid(
          columns: columns,
          rows: rows,
          onLoaded: (PlutoGridOnLoadedEvent event) {
            stateManager = event.stateManager;
          },
          onChanged: onChanged,
        ),
      ),
    );
  }

  group('마침표를 Decimal separator 로 사용하는 기본 locale.', () {
    testWidgets('소수점 2자리 숫자가 마침표로 구분되어야 한다.', (tester) async {
      final columns = [
        PlutoColumn(
          title: 'column',
          field: 'column',
          type: PlutoColumnType.number(format: '#,###.##'),
        ),
      ];

      final rows = [
        PlutoRow(cells: {'column': PlutoCell(value: 12345.01)}),
        PlutoRow(cells: {'column': PlutoCell(value: 12345.02)}),
        PlutoRow(cells: {'column': PlutoCell(value: 12345.11)}),
      ];

      await tester.pumpWidget(buildGrid(columns: columns, rows: rows));

      expect(find.text('12,345.01'), findsOneWidget);
      expect(find.text('12,345.02'), findsOneWidget);
      expect(find.text('12,345.11'), findsOneWidget);
    });

    testWidgets('편집 상태에서 소수점 2자리 숫자가 마침표로 구분되어야 한다.', (tester) async {
      final columns = [
        PlutoColumn(
          title: 'column',
          field: 'column',
          type: PlutoColumnType.number(format: '#,###.##'),
        ),
      ];

      final rows = [
        PlutoRow(cells: {'column': PlutoCell(value: 12345.01)}),
        PlutoRow(cells: {'column': PlutoCell(value: 12345.02)}),
        PlutoRow(cells: {'column': PlutoCell(value: 12345.11)}),
      ];

      await tester.pumpWidget(buildGrid(columns: columns, rows: rows));

      await tester.tap(find.text('12,345.01'));
      await tester.tap(find.text('12,345.01'));
      await tester.pump();

      expect(stateManager.isEditing, true);

      expect(find.text('12345.01'), findsOneWidget);
    });

    testWidgets('동일한 값으로 변경 한 경우 onChanged 콜백이 호출되지 않아야 한다.', (tester) async {
      final columns = [
        PlutoColumn(
          title: 'column',
          field: 'column',
          type: PlutoColumnType.number(format: '#,###.##'),
        ),
      ];

      final rows = [
        PlutoRow(cells: {'column': PlutoCell(value: 12345.01)}),
        PlutoRow(cells: {'column': PlutoCell(value: 12345.02)}),
        PlutoRow(cells: {'column': PlutoCell(value: 12345.11)}),
      ];

      final mock = MockMethods();

      await tester.pumpWidget(buildGrid(
        columns: columns,
        rows: rows,
        onChanged: mock.oneParamReturnVoid,
      ));

      final cellWidget = find.text('12,345.01');

      await tester.tap(cellWidget);
      await tester.tap(cellWidget);
      await tester.pump();

      expect(stateManager.isEditing, true);

      await tester.enterText(find.text('12345.01'), '12345.01');
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);

      verifyNever(mock.oneParamReturnVoid(any));
      expect(stateManager.rows.first.cells['column']?.value, 12345.01);
    });

    testWidgets('값을 변경 한 경우 onChanged 콜백이 호출되어야 한다.', (tester) async {
      final columns = [
        PlutoColumn(
          title: 'column',
          field: 'column',
          type: PlutoColumnType.number(format: '#,###.##'),
        ),
      ];

      final rows = [
        PlutoRow(cells: {'column': PlutoCell(value: 12345.01)}),
        PlutoRow(cells: {'column': PlutoCell(value: 12345.02)}),
        PlutoRow(cells: {'column': PlutoCell(value: 12345.11)}),
      ];

      final mock = MockMethods();

      await tester.pumpWidget(buildGrid(
        columns: columns,
        rows: rows,
        onChanged: mock.oneParamReturnVoid,
      ));

      final cellWidget = find.text('12,345.01');

      await tester.tap(cellWidget);
      await tester.tap(cellWidget);
      await tester.pump();

      expect(stateManager.isEditing, true);

      await tester.enterText(find.text('12345.01'), '12345.99');
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);

      verify(mock.oneParamReturnVoid(any)).called(1);
      expect(stateManager.rows.first.cells['column']?.value, 12345.99);
    });
  });

  group('컴마를 Decimal separator 로 사용하는 국가.', () {
    setUpAll(() {
      PlutoGrid.setDefaultLocale('da_DK');
    });

    testWidgets('소수점 2자리 숫자가 컴마로 구분되어야 한다.', (tester) async {
      final columns = [
        PlutoColumn(
          title: 'column',
          field: 'column',
          type: PlutoColumnType.number(format: '#,###.##'),
        ),
      ];

      final rows = [
        PlutoRow(cells: {'column': PlutoCell(value: 12345.01)}),
        PlutoRow(cells: {'column': PlutoCell(value: 12345.02)}),
        PlutoRow(cells: {'column': PlutoCell(value: 12345.11)}),
      ];

      await tester.pumpWidget(buildGrid(columns: columns, rows: rows));

      expect(find.text('12.345,01'), findsOneWidget);
      expect(find.text('12.345,02'), findsOneWidget);
      expect(find.text('12.345,11'), findsOneWidget);
    });

    testWidgets('편집 상태에서 소수점 2자리 숫자가 컴마로 구분되어야 한다.', (tester) async {
      final columns = [
        PlutoColumn(
          title: 'column',
          field: 'column',
          type: PlutoColumnType.number(format: '#,###.##'),
        ),
      ];

      final rows = [
        PlutoRow(cells: {'column': PlutoCell(value: 12345.01)}),
        PlutoRow(cells: {'column': PlutoCell(value: 12345.02)}),
        PlutoRow(cells: {'column': PlutoCell(value: 12345.11)}),
      ];

      await tester.pumpWidget(buildGrid(columns: columns, rows: rows));

      await tester.tap(find.text('12.345,01'));
      await tester.tap(find.text('12.345,01'));
      await tester.pump();

      expect(stateManager.isEditing, true);

      expect(find.text('12345,01'), findsOneWidget);
    });

    testWidgets('동일한 값으로 변경 한 경우 onChanged 콜백이 호출되지 않아야 한다.', (tester) async {
      final columns = [
        PlutoColumn(
          title: 'column',
          field: 'column',
          type: PlutoColumnType.number(format: '#,###.##'),
        ),
      ];

      final rows = [
        PlutoRow(cells: {'column': PlutoCell(value: 12345.01)}),
        PlutoRow(cells: {'column': PlutoCell(value: 12345.02)}),
        PlutoRow(cells: {'column': PlutoCell(value: 12345.11)}),
      ];

      final mock = MockMethods();

      await tester.pumpWidget(buildGrid(
        columns: columns,
        rows: rows,
        onChanged: mock.oneParamReturnVoid,
      ));

      final cellWidget = find.text('12.345,01');

      await tester.tap(cellWidget);
      await tester.tap(cellWidget);
      await tester.pump();

      expect(stateManager.isEditing, true);

      await tester.enterText(find.text('12345,01'), '12345,01');
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);

      verifyNever(mock.oneParamReturnVoid(any));
      expect(stateManager.rows.first.cells['column']?.value, 12345.01);
    });

    testWidgets('값을 변경 한 경우 onChanged 콜백이 호출되어야 한다.', (tester) async {
      final columns = [
        PlutoColumn(
          title: 'column',
          field: 'column',
          type: PlutoColumnType.number(format: '#,###.##'),
        ),
      ];

      final rows = [
        PlutoRow(cells: {'column': PlutoCell(value: 12345.01)}),
        PlutoRow(cells: {'column': PlutoCell(value: 12345.02)}),
        PlutoRow(cells: {'column': PlutoCell(value: 12345.11)}),
      ];

      final mock = MockMethods();

      await tester.pumpWidget(buildGrid(
        columns: columns,
        rows: rows,
        onChanged: mock.oneParamReturnVoid,
      ));

      final cellWidget = find.text('12.345,01');

      await tester.tap(cellWidget);
      await tester.tap(cellWidget);
      await tester.pump();

      expect(stateManager.isEditing, true);

      await tester.enterText(find.text('12345,01'), '12345,99');
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);

      verify(mock.oneParamReturnVoid(any)).called(1);
      expect(stateManager.rows.first.cells['column']?.value, 12345.99);
    });
  });
}
