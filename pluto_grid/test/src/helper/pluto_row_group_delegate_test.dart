// ignore_for_file: non_constant_identifier_names

import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';

void main() {
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

  test('PlutoRowGroupDelegateType', () {
    const tree = PlutoRowGroupDelegateType.tree;
    expect(tree.isTree, true);
    expect(tree.isByColumn, false);

    const byColumn = PlutoRowGroupDelegateType.byColumn;
    expect(byColumn.isTree, false);
    expect(byColumn.isByColumn, true);
  });

  group('PlutoRowGroupTreeDelegate 최대 3뎁스로 그룹핑.', () {
    late List<PlutoColumn> columns;

    late List<PlutoRow> rows;

    setUp(() {
      columns = [
        PlutoColumn(
          title: 'column1',
          field: 'column1',
          type: PlutoColumnType.text(),
        ),
        PlutoColumn(
          title: 'column2',
          field: 'column2',
          type: PlutoColumnType.text(),
        ),
        PlutoColumn(
          title: 'column3',
          field: 'column3',
          type: PlutoColumnType.text(),
        ),
        PlutoColumn(
          title: 'column4',
          field: 'column4',
          type: PlutoColumnType.text(),
        ),
        PlutoColumn(
          title: 'column5',
          field: 'column5',
          type: PlutoColumnType.text(),
        ),
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
        createRow('C', '1', '11', 'C111', '01', columns),
        createRow('D', 'd1', 'd2', 'd3', 'd4', columns),
        createGroup('E', 'e1', 'e2', 'e3', 'e4', columns, [
          createRow('E1', 'e1-1', 'e1-2', 'e1-3', 'e1-4', columns),
          createRow('E2', 'e2-1', 'e2-2', 'e2-3', 'e2-4', columns),
        ]),
      ];
    });

    PlutoRowGroupTreeDelegate createDelegate({
      int Function(PlutoColumn)? resolveColumnDepth,
      bool Function(PlutoCell)? showText,
    }) {
      return PlutoRowGroupTreeDelegate(
        resolveColumnDepth: resolveColumnDepth ??
            (column) => int.parse(column.field.replaceAll('column', '')) - 1,
        showText: showText ?? (cell) => true,
      );
    }

    group('toGroup', () {
      test('리스트의 length 는 5 를 리턴해야 한다.', () {
        final delegate = createDelegate();

        final groups = delegate.toGroup(rows: rows);

        expect(groups.length, 5);
      });

      test('1, 4 번 행은 그룹이어야 한다.', () {
        final delegate = createDelegate();

        final groups = delegate.toGroup(rows: rows);

        expect(groups[0].type.isGroup, false);
        expect(groups[1].type.isGroup, true);
        expect(groups[2].type.isGroup, false);
        expect(groups[3].type.isGroup, false);
        expect(groups[4].type.isGroup, true);
      });

      test('B 그룹의 첫번째 뎁스의 자식의 길이가 4를 리턴해야 한다.', () {
        final delegate = createDelegate();

        final groups = delegate.toGroup(rows: rows);

        expect(groups[1].type.group.children.length, 4);
      });

      test('B 그룹의 행들이 위치에 맞게 parent 가 설정 되어야 한다.', () {
        final delegate = createDelegate();

        final groups = delegate.toGroup(rows: rows);

        final B = groups[1];
        final B1 = B.type.group.children[0];
        final B2 = B.type.group.children[1];
        final B3 = B.type.group.children[2];
        final B4 = B.type.group.children[3];
        final B41 = B4.type.group.children[0];
        final B42 = B4.type.group.children[1];
        final B43 = B4.type.group.children[2];
        final B431 = B43.type.group.children[0];
        final B432 = B43.type.group.children[1];

        expect(B.parent, null);
        expect(B1.parent, B);
        expect(B2.parent, B);
        expect(B3.parent, B);
        expect(B4.parent, B);
        expect(B41.parent, B4);
        expect(B41.parent?.parent, B);
        expect(B42.parent, B4);
        expect(B42.parent?.parent, B);
        expect(B43.parent, B4);
        expect(B43.parent?.parent, B);
        expect(B431.parent, B43);
        expect(B431.parent?.parent, B4);
        expect(B431.parent?.parent?.parent, B);
        expect(B432.parent, B43);
        expect(B432.parent?.parent, B4);
        expect(B432.parent?.parent?.parent, B);
      });

      test('isEditableCell 이 설정한 showText 조건으로 리턴 되어야 한다.', () {
        final delegate = createDelegate(
          showText: (cell) => cell.column.field == 'column1',
        );

        final groups = delegate.toGroup(rows: rows);

        final sampleRow = groups.first;

        expect(delegate.isEditableCell(sampleRow.cells['column1']!), true);
        expect(delegate.isEditableCell(sampleRow.cells['column2']!), false);
      });

      test('isExpandableCell 이 설정한 resolveColumnDepth 조건으로 리턴 되어야 한다.', () {
        final delegate = createDelegate(
          resolveColumnDepth: (column) => {
            'column1': 0,
            'column2': 1,
            'column3': 2,
            'column4': 3,
            'column5': 4,
          }[column.field]!,
        );

        final groups = delegate.toGroup(rows: rows);

        final sampleRow = groups[0];
        final sampleGroupDepth0 = groups[1];
        final sampleGroupDepth1 = groups[1].type.group.children[3];

        expect(delegate.isExpandableCell(sampleRow.cells['column1']!), false);
        expect(
          delegate.isExpandableCell(sampleGroupDepth0.cells['column1']!),
          true,
        );
        expect(
          delegate.isExpandableCell(sampleGroupDepth0.cells['column2']!),
          false,
        );
        expect(
          delegate.isExpandableCell(sampleGroupDepth1.cells['column1']!),
          false,
        );
        expect(
          delegate.isExpandableCell(sampleGroupDepth1.cells['column2']!),
          true,
        );
      });
    });
  });

  /// (G) A-1-11
  /// (R)      -A111-01
  /// (G)    -12
  /// (R)      -A121-02
  /// (R)      -A122-03
  /// (G)  -2-21
  /// (R)      -A211-04
  /// (G) B-1-11
  /// (R)      -B111-05
  /// (G)    -12
  /// (R)      -B112-06
  /// (G)  -2-21
  /// (R)      -B211-07
  /// (G)  -3-31
  /// (R)      -B311-08
  /// (G)  -4-41
  /// (R)      -B411-09
  /// (G)    -42
  /// (R)      -B412-10
  group('PlutoRowGroupByColumnDelegate. 3개 컬럼으로 그룹핑.', () {
    late PlutoRowGroupByColumnDelegate delegate;

    late List<PlutoColumn> columns;

    late List<PlutoRow> rows;

    setUp(() {
      columns = [
        PlutoColumn(
          title: 'column1',
          field: 'column1',
          type: PlutoColumnType.text(),
        ),
        PlutoColumn(
          title: 'column2',
          field: 'column2',
          type: PlutoColumnType.text(),
        ),
        PlutoColumn(
          title: 'column3',
          field: 'column3',
          type: PlutoColumnType.text(),
        ),
        PlutoColumn(
          title: 'column4',
          field: 'column4',
          type: PlutoColumnType.text(),
        ),
        PlutoColumn(
          title: 'column5',
          field: 'column5',
          type: PlutoColumnType.text(),
        ),
      ];

      rows = [
        createRow('A', '1', '11', 'A111', '01', columns),
        createRow('A', '1', '12', 'A121', '02', columns),
        createRow('A', '1', '12', 'A122', '03', columns),
        createRow('A', '2', '21', 'A211', '04', columns),
        createRow('B', '1', '11', 'B111', '05', columns),
        createRow('B', '1', '12', 'B112', '06', columns),
        createRow('B', '2', '21', 'B211', '07', columns),
        createRow('B', '3', '31', 'B311', '08', columns),
        createRow('B', '4', '41', 'B411', '09', columns),
        createRow('B', '4', '42', 'B412', '10', columns),
      ];

      delegate = PlutoRowGroupByColumnDelegate(columns: [
        columns[0],
        columns[1],
        columns[2],
      ]);
    });

    test('type 이 byColumn 을 리턴해야 한다.', () {
      expect(delegate.type, PlutoRowGroupDelegateType.byColumn);
    });

    test('enabled 가 true 를 리턴해야 한다.', () {
      expect(delegate.enabled, true);
    });

    test('visibleColumns.length 가 3 이어야 한다.', () {
      expect(delegate.visibleColumns.length, 3);
    });

    test('visibleColumns 1개 hide 하면 length 가 2 를 리턴해야 한다.', () {
      delegate.visibleColumns.first.hide = true;
      expect(delegate.enabled, true);
      expect(delegate.visibleColumns.length, 2);
    });

    test(
      'visibleColumns 를 모두 hide 하면, '
      'length 가 0 을 리턴하고 enabled 가 false 를 리턴해야 한다.',
      () {
        setHide(c) => c.hide = true;
        delegate.visibleColumns.forEach(setHide);
        expect(delegate.enabled, false);
        expect(delegate.visibleColumns.length, 0);
      },
    );

    test('셀의 행이 그룹이 아니면 isEditableCell 이 true 를 리턴해야 한다.', () {
      final sampleColumn = columns[3]; // 그룹 컬럼이 아님.
      final sampleRow = PlutoRow(cells: {}, type: PlutoRowType.normal());
      final sampleCell = PlutoCell()
        ..setRow(sampleRow)
        ..setColumn(sampleColumn);

      expect(delegate.isEditableCell(sampleCell), true);
    });

    test('셀의 행이 그룹이면 isEditableCell 이 false 를 리턴해야 한다.', () {
      final sampleColumn = columns[1];
      final sampleGroup = PlutoRow(
        cells: {},
        type: PlutoRowType.group(children: FilteredList()),
      );
      final sampleCell = PlutoCell()
        ..setRow(sampleGroup)
        ..setColumn(sampleColumn);

      expect(delegate.isEditableCell(sampleCell), false);
    });

    test('셀의 행이 그룹이 아니면 isExpandableCell 이 false 를 리턴해야 한다.', () {
      final sampleColumn = columns[1];
      final sampleRow = PlutoRow(cells: {}, type: PlutoRowType.normal());
      final sampleCell = PlutoCell()
        ..setRow(sampleRow)
        ..setColumn(sampleColumn);

      expect(delegate.isExpandableCell(sampleCell), false);
    });

    test(
      '셀의 행이 그룹이고 컬럼도 그룹컬럼이며 둘의 depth 가 맞다면, '
      'isExpandableCell 이 true 를 리턴해야 한다.',
      () {
        final grouped = delegate.toGroup(rows: rows);
        final sampleColumn = columns[0]; // 0 depth
        final sampleGroup = grouped.first; // 0 depth
        final sampleCell = PlutoCell()
          ..setRow(sampleGroup)
          ..setColumn(sampleColumn);

        expect(delegate.isExpandableCell(sampleCell), true);
      },
    );

    test(
      '셀의 행이 그룹이고 컬럼도 그룹컬럼이며 둘의 depth 가 다르면, '
      'isExpandableCell 이 false 를 리턴해야 한다.',
      () {
        final grouped = delegate.toGroup(rows: rows);
        final sampleColumn = columns[1]; // 1 depth
        final sampleGroup = grouped.first; // 0 depth
        final sampleCell = PlutoCell()
          ..setRow(sampleGroup)
          ..setColumn(sampleColumn);

        expect(delegate.isExpandableCell(sampleCell), false);
      },
    );

    test('그룹 설정 된 column1 을 isRowGroupColumn 로 호출하면 true 를 리턴해야 한다.', () {
      final sampleColumn = columns[1];

      expect(delegate.isRowGroupColumn(sampleColumn), true);
    });

    test('그룹 설정 되지 않은 column4 을 isRowGroupColumn 로 호출하면 false 를 리턴해야 한다.', () {
      final sampleColumn = columns[4];

      expect(delegate.isRowGroupColumn(sampleColumn), false);
    });

    group('toGroup', () {
      test('2개의 그룹행을 리턴해야 한다.', () {
        final grouped = delegate.toGroup(rows: rows);

        expect(grouped.length, 2);
      });

      test('첫번째 그룹의 자식들의 길이와 parent 가 상태에 맞게 설정 되어야 한다.', () {
        /// (G) A-1-11
        /// (R)      -A111-01
        /// (G)    -12
        /// (R)      -A121-02
        /// (R)      -A122-03
        /// (G)  -2-21
        /// (R)      -A211-04
        final grouped = delegate.toGroup(rows: rows);
        final A = grouped.first;
        final A_CHILDREN = A.type.group.children;
        expect(A.parent, null);
        expect(A_CHILDREN.length, 2);
        expect(A_CHILDREN[0].parent, A);
        expect(A_CHILDREN[1].parent, A);

        final A_1 = A_CHILDREN[0];
        final A_1_CHILDREN = A_1.type.group.children;
        expect(A_1_CHILDREN.length, 2);
        expect(A_1_CHILDREN[0].parent, A_1);
        expect(A_1_CHILDREN[1].parent, A_1);

        final A_1_11 = A_1_CHILDREN[0];
        expect(A_1_11.type.group.children.length, 1);
        final A111_01 = A_1_11.type.group.children[0];
        expect(A111_01.parent, A_1_11);
        expect(A111_01.type.isNormal, true);

        final A_1_12 = A_1_CHILDREN[1];
        expect(A_1_12.type.group.children.length, 2);
        final A121_02 = A_1_12.type.group.children[0];
        expect(A121_02.parent, A_1_12);
        expect(A121_02.type.isNormal, true);
        final A122_03 = A_1_12.type.group.children[1];
        expect(A122_03.parent, A_1_12);
        expect(A122_03.type.isNormal, true);

        final A_2 = A_CHILDREN[1];
        final A_2_CHILDREN = A_2.type.group.children;
        expect(A_2_CHILDREN.length, 1);

        final A_2_21 = A_2_CHILDREN[0];
        final A_2_21_CHILDREN = A_2_21.type.group.children;
        expect(A_2_21_CHILDREN.length, 1);
        final A2111_04 = A_2_21_CHILDREN[0];
        expect(A2111_04.parent, A_2_21);
        expect(A2111_04.type.isNormal, true);
      });
    });
  });
}
