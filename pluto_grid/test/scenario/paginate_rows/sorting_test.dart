import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:pluto_grid/src/ui/pluto_base_cell.dart';

void main() {
  late PlutoGridStateManager stateManager;

  late List<PlutoColumn> columns;

  late List<PlutoRow> rows;

  Future<void> buildGrid(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Material(
        child: PlutoGrid(
          columns: columns,
          rows: rows,
          onLoaded: (PlutoGridOnLoadedEvent event) {
            stateManager = event.stateManager;
          },
          createFooter: (s) {
            s.setPageSize(3);
            return PlutoPagination(s);
          },
        ),
      ),
    ));
  }

  Future<List<PlutoBaseCell>> getCells(WidgetTester tester, {int? page}) async {
    if (page != null) {
      await tester.tap(find.text('$page'));
      await tester.pump();
    }

    final cells = find
        .byType(PlutoBaseCell)
        .evaluate()
        .map((e) => e.widget)
        .cast<PlutoBaseCell>()
        .toList();

    return cells;
  }

  group('date 컬럼 정렬.', () {
    setUp(() {
      columns = [
        PlutoColumn(
          title: 'date',
          field: 'date',
          type: PlutoColumnType.date(format: 'dd/MM/yyyy'),
        ),
      ];

      rows = [
        PlutoRow(cells: {'date': PlutoCell(value: DateTime(2022, 4, 1))}),
        PlutoRow(cells: {'date': PlutoCell(value: DateTime(2022, 2, 10))}),
        PlutoRow(cells: {'date': PlutoCell(value: DateTime(2022, 2, 2))}),
        PlutoRow(cells: {'date': PlutoCell(value: DateTime(2022, 2, 3))}),
        PlutoRow(cells: {'date': PlutoCell(value: DateTime(2022, 4, 3))}),
        PlutoRow(cells: {'date': PlutoCell(value: DateTime(2022, 3, 1))}),
        PlutoRow(cells: {'date': PlutoCell(value: DateTime(2022, 5, 1))}),
        PlutoRow(cells: {'date': PlutoCell(value: DateTime(2022, 1, 20))}),
        PlutoRow(cells: {'date': PlutoCell(value: DateTime(2022, 8, 2))}),
        PlutoRow(cells: {'date': PlutoCell(value: DateTime(2022, 8, 1))}),
      ];
    });

    group('컬럼을 탭하여 정렬.', () {
      testWidgets('dd/MM/yyyy 포멧이 적용되어 ascending 정렬 되어야 한다.', (tester) async {
        await buildGrid(tester);
        await tester.tap(find.text('date'));
        await tester.pump();

        final List<PlutoBaseCell> cells = [];

        cells.addAll(await getCells(tester));
        cells.addAll(await getCells(tester, page: 2));
        cells.addAll(await getCells(tester, page: 3));
        cells.addAll(await getCells(tester, page: 4));

        expect(cells.length, 10);
        expect(cells[0].cell.value, '20/01/2022');
        expect(cells[1].cell.value, '02/02/2022');
        expect(cells[2].cell.value, '03/02/2022');
        expect(cells[3].cell.value, '10/02/2022');
        expect(cells[4].cell.value, '01/03/2022');
        expect(cells[5].cell.value, '01/04/2022');
        expect(cells[6].cell.value, '03/04/2022');
        expect(cells[7].cell.value, '01/05/2022');
        expect(cells[8].cell.value, '01/08/2022');
        expect(cells[9].cell.value, '02/08/2022');
      });

      testWidgets('dd/MM/yyyy 포멧이 적용되어 descending 정렬 되어야 한다.', (tester) async {
        await buildGrid(tester);
        await tester.tap(find.text('date'));
        await tester.tap(find.text('date')); // descending
        await tester.pump();

        final List<PlutoBaseCell> cells = [];

        cells.addAll(await getCells(tester));
        cells.addAll(await getCells(tester, page: 2));
        cells.addAll(await getCells(tester, page: 3));
        cells.addAll(await getCells(tester, page: 4));

        expect(cells.length, 10);
        expect(cells[0].cell.value, '02/08/2022');
        expect(cells[1].cell.value, '01/08/2022');
        expect(cells[2].cell.value, '01/05/2022');
        expect(cells[3].cell.value, '03/04/2022');
        expect(cells[4].cell.value, '01/04/2022');
        expect(cells[5].cell.value, '01/03/2022');
        expect(cells[6].cell.value, '10/02/2022');
        expect(cells[7].cell.value, '03/02/2022');
        expect(cells[8].cell.value, '02/02/2022');
        expect(cells[9].cell.value, '20/01/2022');
      });

      testWidgets('dd/MM/yyyy 포멧이 적용되어 descending 후 다시 원래 순서로 정렬 되어야 한다.',
          (tester) async {
        await buildGrid(tester);
        await tester.tap(find.text('date'));
        await tester.tap(find.text('date')); // descending
        await tester.tap(find.text('date')); // none
        await tester.pump();

        final List<PlutoBaseCell> cells = [];

        cells.addAll(await getCells(tester));
        cells.addAll(await getCells(tester, page: 2));
        cells.addAll(await getCells(tester, page: 3));
        cells.addAll(await getCells(tester, page: 4));

        expect(cells.length, 10);
        expect(cells[0].cell.value, '01/04/2022');
        expect(cells[1].cell.value, '10/02/2022');
        expect(cells[2].cell.value, '02/02/2022');
        expect(cells[3].cell.value, '03/02/2022');
        expect(cells[4].cell.value, '03/04/2022');
        expect(cells[5].cell.value, '01/03/2022');
        expect(cells[6].cell.value, '01/05/2022');
        expect(cells[7].cell.value, '20/01/2022');
        expect(cells[8].cell.value, '02/08/2022');
        expect(cells[9].cell.value, '01/08/2022');
      });
    });

    group('stateManager 로 정렬.', () {
      testWidgets('dd/MM/yyyy 포멧이 적용되어 ascending 정렬 되어야 한다.', (tester) async {
        await buildGrid(tester);
        stateManager.sortAscending(stateManager.columns.first);
        await tester.pump();

        final List<PlutoBaseCell> cells = [];

        cells.addAll(await getCells(tester));
        cells.addAll(await getCells(tester, page: 2));
        cells.addAll(await getCells(tester, page: 3));
        cells.addAll(await getCells(tester, page: 4));

        expect(cells.length, 10);
        expect(cells[0].cell.value, '20/01/2022');
        expect(cells[1].cell.value, '02/02/2022');
        expect(cells[2].cell.value, '03/02/2022');
        expect(cells[3].cell.value, '10/02/2022');
        expect(cells[4].cell.value, '01/03/2022');
        expect(cells[5].cell.value, '01/04/2022');
        expect(cells[6].cell.value, '03/04/2022');
        expect(cells[7].cell.value, '01/05/2022');
        expect(cells[8].cell.value, '01/08/2022');
        expect(cells[9].cell.value, '02/08/2022');
      });

      testWidgets('dd/MM/yyyy 포멧이 적용되어 descending 정렬 되어야 한다.', (tester) async {
        await buildGrid(tester);
        stateManager.sortDescending(stateManager.columns.first);
        await tester.pump();

        final List<PlutoBaseCell> cells = [];

        cells.addAll(await getCells(tester));
        cells.addAll(await getCells(tester, page: 2));
        cells.addAll(await getCells(tester, page: 3));
        cells.addAll(await getCells(tester, page: 4));

        expect(cells.length, 10);
        expect(cells[0].cell.value, '02/08/2022');
        expect(cells[1].cell.value, '01/08/2022');
        expect(cells[2].cell.value, '01/05/2022');
        expect(cells[3].cell.value, '03/04/2022');
        expect(cells[4].cell.value, '01/04/2022');
        expect(cells[5].cell.value, '01/03/2022');
        expect(cells[6].cell.value, '10/02/2022');
        expect(cells[7].cell.value, '03/02/2022');
        expect(cells[8].cell.value, '02/02/2022');
        expect(cells[9].cell.value, '20/01/2022');
      });

      testWidgets('dd/MM/yyyy 포멧이 적용되어 descending 후 다시 원래 순서로 정렬 되어야 한다.',
          (tester) async {
        await buildGrid(tester);
        stateManager.sortDescending(stateManager.columns.first);
        stateManager.toggleSortColumn(stateManager.columns.first);
        await tester.pump();

        final List<PlutoBaseCell> cells = [];

        cells.addAll(await getCells(tester));
        cells.addAll(await getCells(tester, page: 2));
        cells.addAll(await getCells(tester, page: 3));
        cells.addAll(await getCells(tester, page: 4));

        expect(cells.length, 10);
        expect(cells[0].cell.value, '01/04/2022');
        expect(cells[1].cell.value, '10/02/2022');
        expect(cells[2].cell.value, '02/02/2022');
        expect(cells[3].cell.value, '03/02/2022');
        expect(cells[4].cell.value, '03/04/2022');
        expect(cells[5].cell.value, '01/03/2022');
        expect(cells[6].cell.value, '01/05/2022');
        expect(cells[7].cell.value, '20/01/2022');
        expect(cells[8].cell.value, '02/08/2022');
        expect(cells[9].cell.value, '01/08/2022');
      });
    });
  });
}
