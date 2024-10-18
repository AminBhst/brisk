import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../helper/column_helper.dart';
import '../../helper/test_helper_util.dart';

void main() {
  late PlutoGridStateManager stateManager;

  Future<void> buildGrid({
    required WidgetTester tester,
    required List<PlutoColumn> columns,
    required List<PlutoRow> rows,
    required PlutoRowGroupDelegate delegate,
    Widget Function(PlutoGridStateManager)? createFooter,
  }) async {
    await TestHelperUtil.changeWidth(tester: tester, width: 1200, height: 800);

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: PlutoGrid(
            columns: columns,
            rows: rows,
            createFooter: createFooter,
            onLoaded: (PlutoGridOnLoadedEvent event) {
              stateManager = event.stateManager;
              stateManager.setRowGroup(delegate);
            },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
  }

  group('PlutoRowGroupTreeDelegate', () {
    late List<PlutoColumn> columns;

    late List<PlutoRow> rows;

    setUp(() {
      columns = [
        PlutoColumn(
            title: 'column1', field: 'column1', type: PlutoColumnType.text()),
        PlutoColumn(
            title: 'column2', field: 'column2', type: PlutoColumnType.text()),
        PlutoColumn(
            title: 'column3', field: 'column3', type: PlutoColumnType.text()),
        PlutoColumn(
            title: 'column4', field: 'column4', type: PlutoColumnType.text()),
        PlutoColumn(
            title: 'column5', field: 'column5', type: PlutoColumnType.text()),
      ];

      rows = [
        createRow('A', 'a1', 'a2', 'a3', 'a4', columns),
        createGroup('B', 'b1', 'b2', 'b3', 'b4', columns, [
          createRow('B1', 'b1-1', 'b1-2', 'b1-3', 'b1-3', columns),
          createRow('B2', 'b2-1', 'b2-2', 'b2-3', 'b2-4', columns),
          createRow('B3', 'b3-1', 'b3-2', 'b3-3', 'b3-4', columns),
          createGroup('B4', 'b4-1', 'b4-2', 'b4-3', 'b4-4', columns, [
            createRow('B41', 'b41-1', 'b41-2', 'b41-3', 'b41-4', columns),
            createRow('B42', 'b42-1', 'b42-2', 'b42-3', 'b42-4', columns),
            createGroup('B43', 'b43-1', 'b43-2', 'b43-3', 'b43-4', columns, [
              createRow(
                  'B431', 'b431-1', 'b431-2', 'b431-3', 'b431-4', columns),
              createRow(
                  'B432', 'b432-1', 'b432-2', 'b432-3', 'b432-4', columns),
            ]),
          ]),
        ]),
        createRow('C', 'c1', 'c2', 'c3', 'c4', columns),
        createRow('D', 'd1', 'd2', 'd3', 'd4', columns),
        createGroup('E', 'e1', 'e2', 'e3', 'e4', columns, [
          createRow('E1', 'e1-1', 'e1-2', 'e1-3', 'e1-4', columns),
          createRow('E2', 'e2-1', 'e2-2', 'e2-3', 'e2-4', columns),
        ]),
      ];
    });

    testWidgets('B 그룹을 토글 하면 onToggled 콜백이 호출 되어야 한다.', (tester) async {
      PlutoRow? toggledRow;
      bool? isExpanded;

      void onToggled({required bool expanded, required PlutoRow row}) {
        toggledRow = row;
        isExpanded = expanded;
      }

      await buildGrid(
        tester: tester,
        columns: columns,
        rows: rows,
        delegate: PlutoRowGroupTreeDelegate(
          resolveColumnDepth: (column) =>
              int.parse(column.field.replaceAll('column', '')) - 1,
          showText: (cell) => true,
          showFirstExpandableIcon: true,
          onToggled: onToggled,
        ),
      );

      stateManager.toggleExpandedRowGroup(rowGroup: rows[1]);

      expect(toggledRow, rows[1]);
      expect(isExpanded, true);
    });
  });

  group('PlutoRowGroupByColumnDelegate', () {
    late List<PlutoColumn> columns;

    late List<PlutoRow> rows;

    setUp(() {
      columns = ColumnHelper.textColumn('column', count: 5, start: 1);

      rows = [
        createRow('A', 'a1', 'a1-1', 'a1-1', 'a1-1', columns),
        createRow('A', 'a1', 'a1-2', 'a1-2', 'a1-2', columns),
        createRow('A', 'a2', 'a2-1', 'a2-1', 'a2-1', columns),
        createRow('A', 'a2', 'a2-2', 'a2-2', 'a2-2', columns),
        createRow('A', 'a2', 'a2-3', 'a2-3', 'a2-3', columns),
        createRow('A', 'a3', 'a3-1', 'a3-1', 'a3-1', columns),
        createRow('B', 'b1', 'b1-1', 'b1-1', 'b1-1', columns),
        createRow('B', 'b1', 'b1-2', 'b1-2', 'b1-2', columns),
        createRow('B', 'b2', 'b2-1', 'b2-1', 'b2-1', columns),
        createRow('B', 'b2', 'b2-2', 'b2-2', 'b2-2', columns),
        createRow('B', 'b2', 'b2-3', 'b2-3', 'b2-3', columns),
        createRow('B', 'b3', 'b3-1', 'b3-1', 'b3-1', columns),
      ];
    });

    testWidgets('A 그룹을 토글하면 onToggled 콜백이 호출 되어야 한다.', (tester) async {
      PlutoRow? toggledRow;
      bool? isExpanded;

      void onToggled({required bool expanded, required PlutoRow row}) {
        toggledRow = row;
        isExpanded = expanded;
      }

      await buildGrid(
        tester: tester,
        columns: columns,
        rows: rows,
        delegate: PlutoRowGroupByColumnDelegate(
          columns: [columns[0], columns[1]],
          showFirstExpandableIcon: true,
          onToggled: onToggled,
        ),
      );

      stateManager.toggleExpandedRowGroup(rowGroup: stateManager.refRows.first);

      expect(toggledRow, stateManager.refRows.first);
      expect(isExpanded, true);
    });
  });
}

PlutoRow createRow(
  String value1,
  String value2,
  String value3,
  String value4,
  String value5,
  List<PlutoColumn> columns, [
  PlutoRowType? type,
]) {
  final Map<String, PlutoCell> cells = {};

  final row = PlutoRow(cells: cells, type: type);

  cells['column1'] = PlutoCell(value: value1)
    ..setRow(row)
    ..setColumn(columns[0]);
  cells['column2'] = PlutoCell(value: value2)
    ..setRow(row)
    ..setColumn(columns[1]);
  cells['column3'] = PlutoCell(value: value3)
    ..setRow(row)
    ..setColumn(columns[2]);
  cells['column4'] = PlutoCell(value: value4)
    ..setRow(row)
    ..setColumn(columns[3]);
  cells['column5'] = PlutoCell(value: value5)
    ..setRow(row)
    ..setColumn(columns[4]);

  return row;
}

PlutoRow createGroup(
  String value1,
  String value2,
  String value3,
  String value4,
  String value5,
  List<PlutoColumn> columns,
  List<PlutoRow> children,
) {
  return createRow(
    value1,
    value2,
    value3,
    value4,
    value5,
    columns,
    PlutoRowType.group(children: FilteredList(initialList: children)),
  );
}
