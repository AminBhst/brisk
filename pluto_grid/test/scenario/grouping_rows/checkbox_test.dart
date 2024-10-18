// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:pluto_grid/src/ui/ui.dart';

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

  Finder findExpandIcon(String cellValue) {
    return find.descendant(
      of: find.ancestor(
        of: find.text(cellValue),
        matching: find.byType(PlutoDefaultCell),
      ),
      matching: find.byType(IconButton),
    );
  }

  Finder findAllCheckbox(String columnTitle) {
    return find.descendant(
      of: find.ancestor(
        of: find.text('column1'),
        matching: find.byType(PlutoColumnTitle),
      ),
      matching: find.byType(Checkbox),
    );
  }

  Checkbox findAllCheckboxWidget(String cellValue) {
    return findAllCheckbox(cellValue).first.evaluate().first.widget as Checkbox;
  }

  Finder findCheckbox(String cellValue) {
    return find.descendant(
      of: find.ancestor(
        of: find.text(cellValue),
        matching: find.byType(PlutoDefaultCell),
      ),
      matching: find.byType(Checkbox),
    );
  }

  Checkbox findCheckboxWidget(String cellValue) {
    return findCheckbox(cellValue).first.evaluate().first.widget as Checkbox;
  }

  group('PlutoRowGroupTreeDelegate - 3 뎁스로 그룹핑.', () {
    late List<PlutoColumn> columns;

    late List<PlutoRow> rows;

    late PlutoRowGroupDelegate delegate;

    setUp(() {
      columns = [
        PlutoColumn(
          title: 'column1',
          field: 'column1',
          type: PlutoColumnType.text(),
          enableRowChecked: true,
        ),
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

      delegate = PlutoRowGroupTreeDelegate(
        resolveColumnDepth: (column) =>
            int.parse(column.field.replaceAll('column', '')) - 1,
        showText: (cell) => true,
      );
    });

    testWidgets('전체 체크박스를 체크하면 모든 그룹과 행이 체크 되어야 한다.', (tester) async {
      await buildGrid(
        tester: tester,
        columns: columns,
        rows: rows,
        delegate: delegate,
      );

      final allCheckBox = findAllCheckbox('column1');
      expect(allCheckBox, findsOneWidget);

      await tester.tap(allCheckBox);
      await tester.pumpAndSettle();

      expect(findCheckboxWidget('A').value, true);
      expect(findCheckboxWidget('B').value, true);
      expect(findCheckboxWidget('C').value, true);
      expect(findCheckboxWidget('D').value, true);
      expect(findCheckboxWidget('E').value, true);
    });

    testWidgets('E 그룹을 체크 하면 E 그룹의 하위 행들이 체크 되어야 한다.', (tester) async {
      await buildGrid(
        tester: tester,
        columns: columns,
        rows: rows,
        delegate: delegate,
      );

      // 최초 아무것도 체크 되지 않은 상태 tristate 는 false
      expect(findAllCheckboxWidget('column1').value, false);

      await tester.tap(findCheckbox('E'));
      await tester.pumpAndSettle();

      // 행 하나가 체크 되어 tristate 가 null
      expect(findAllCheckboxWidget('column1').value, null);

      expect(findCheckboxWidget('E').value, true);

      await tester.tap(findExpandIcon('E'));
      await tester.pumpAndSettle();

      expect(findCheckboxWidget('E1').value, true);
      expect(findCheckboxWidget('E2').value, true);
    });

    testWidgets(
      'E 그룹을 체크후 하위 행 E1을 체크 해제 하면, '
      'All 체크박스와 E 그룹의 체크박스의 tristate 가 null 이어야 한다.',
      (tester) async {
        await buildGrid(
          tester: tester,
          columns: columns,
          rows: rows,
          delegate: delegate,
        );

        await tester.tap(findCheckbox('E'));
        await tester.pumpAndSettle();

        await tester.tap(findExpandIcon('E'));
        await tester.pumpAndSettle();

        await tester.tap(findCheckbox('E1'));
        await tester.pumpAndSettle();

        expect(findAllCheckboxWidget('column1').value, null);
        expect(findCheckboxWidget('E').value, null);

        expect(findCheckboxWidget('E1').value, false);
        expect(findCheckboxWidget('E2').value, true);
      },
    );

    testWidgets('전체 체크박스를 체크후 하위 그룹을 열면 하위 행들이 체크 되어 있어야 한다.', (tester) async {
      await buildGrid(
        tester: tester,
        columns: columns,
        rows: rows,
        delegate: delegate,
      );

      final allCheckBox = findAllCheckbox('column1');
      expect(allCheckBox, findsOneWidget);

      await tester.tap(allCheckBox);
      await tester.pumpAndSettle();

      final B_GROUP_EXPAND_ICON = findExpandIcon('B');
      await tester.tap(B_GROUP_EXPAND_ICON);
      await tester.pumpAndSettle();

      expect(find.text('B1'), findsOneWidget);
      expect(find.text('B2'), findsOneWidget);
      expect(find.text('B3'), findsOneWidget);
      expect(find.text('B4'), findsOneWidget);
      expect(findCheckboxWidget('B1').value, true);
      expect(findCheckboxWidget('B2').value, true);
      expect(findCheckboxWidget('B3').value, true);
      expect(findCheckboxWidget('B4').value, true);

      // showFirstExpandableIcon 가 false 이므로 두번째 컬럼의 셀에 확장 아이콘이 있다.
      final B4_GROUP_EXPAND_ICON = findExpandIcon('b4-1');
      await tester.tap(B4_GROUP_EXPAND_ICON);
      await tester.pumpAndSettle();

      expect(find.text('B41'), findsOneWidget);
      expect(find.text('B42'), findsOneWidget);
      expect(find.text('B43'), findsOneWidget);
      expect(findCheckboxWidget('B41').value, true);
      expect(findCheckboxWidget('B42').value, true);
      expect(findCheckboxWidget('B43').value, true);

      // showFirstExpandableIcon 가 false 이므로 세번째 컬럼의 셀에 확장 아이콘이 있다.
      final B43_GROUP_EXPAND_ICON = findExpandIcon('b43-2');
      await tester.tap(B43_GROUP_EXPAND_ICON);
      await tester.pumpAndSettle();

      expect(find.text('B431'), findsOneWidget);
      expect(find.text('B432'), findsOneWidget);
      expect(findCheckboxWidget('B431').value, true);
      expect(findCheckboxWidget('B432').value, true);
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
