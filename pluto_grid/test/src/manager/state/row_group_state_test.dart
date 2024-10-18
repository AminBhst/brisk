// ignore_for_file: non_constant_identifier_names

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../mock/shared_mocks.mocks.dart';

void main() {
  PlutoGridStateManager createStateManager({
    required List<PlutoColumn> columns,
    required List<PlutoRow> rows,
  }) {
    WidgetsFlutterBinding.ensureInitialized();

    final stateManager = PlutoGridStateManager(
      columns: columns,
      rows: rows,
      gridFocusNode: MockFocusNode(),
      scroll: MockPlutoGridScrollController(),
    );

    stateManager.setEventManager(MockPlutoGridEventManager());
    stateManager.setLayout(const BoxConstraints());

    return stateManager;
  }

  group('No delegate', () {
    test('delegate 가 없으면 hasRowGroups 가 false 를 리턴 해야 한다.', () {
      final stateManager = createStateManager(columns: [], rows: []);

      expect(stateManager.hasRowGroups, false);
    });

    test('delegate 가 없으면 enabledRowGroups 가 false 를 리턴 해야 한다.', () {
      final stateManager = createStateManager(columns: [], rows: []);

      expect(stateManager.enabledRowGroups, false);
    });

    test('delegate 가 없으면 rowGroupDelegate 가 null 를 리턴 해야 한다.', () {
      final stateManager = createStateManager(columns: [], rows: []);

      expect(stateManager.rowGroupDelegate, null);
    });

    test('iterateMainRowGroup 는 5개의 행을 리턴해야 한다.', () {
      final rows = [
        PlutoRow(cells: {}),
        PlutoRow(cells: {}),
        PlutoRow(cells: {}),
        PlutoRow(cells: {}),
        PlutoRow(cells: {}),
      ];

      final stateManager = createStateManager(columns: [], rows: rows);

      expect(stateManager.iterateAllMainRowGroup.length, 5);
    });

    group('[그룹행(3 자식), 일반행, 일반행]', () {
      late PlutoGridStateManager stateManager;

      late PlutoRow groupedRow;

      late FilteredList<PlutoRow> children;

      late List<PlutoRow> rows;

      setUp(() {
        children = FilteredList(
          initialList: [
            PlutoRow(cells: {}, sortIdx: 10),
            PlutoRow(cells: {}, sortIdx: 11),
            PlutoRow(cells: {}, sortIdx: 12),
          ],
        );

        groupedRow = PlutoRow(
          cells: {},
          type: PlutoRowType.group(children: children),
          sortIdx: 0,
        );

        setParent(e) => e.setParent(groupedRow);

        children.forEach(setParent);

        rows = [
          groupedRow,
          PlutoRow(cells: {}, sortIdx: 1),
          PlutoRow(cells: {}, sortIdx: 2),
        ];

        stateManager = createStateManager(columns: [], rows: rows);
      });

      test('iterateMainRowGroup.length 는 3을 리턴해야 한다.', () {
        expect(stateManager.iterateAllMainRowGroup.length, 3);
      });

      test('iterateRowGroup.length 는 1을 리턴해야 한다.', () {
        expect(stateManager.iterateAllRowGroup.length, 1);
      });

      test('iterateRowAndGroup.length 는 6을 리턴해야 한다.', () {
        final rowAndGroup = stateManager.iterateAllRowAndGroup;
        expect(rowAndGroup.length, 6);
        expect(rowAndGroup.elementAt(0).sortIdx, 0);
        expect(rowAndGroup.elementAt(1).sortIdx, 10);
        expect(rowAndGroup.elementAt(2).sortIdx, 11);
        expect(rowAndGroup.elementAt(3).sortIdx, 12);
        expect(rowAndGroup.elementAt(4).sortIdx, 1);
        expect(rowAndGroup.elementAt(5).sortIdx, 2);
      });

      test('iterateRow.length 는 5을 리턴해야 한다.', () {
        expect(stateManager.iterateAllRow.length, 5);
      });

      test('refRows 의 행은 isMainRow 가 true 를 리턴해야 한다.', () {
        final List<bool> result = [];

        addResult(e) => result.add(stateManager.isMainRow(e));

        stateManager.refRows.forEach(addResult);

        expect(result.length, 3);
        expect(result, [true, true, true]);
      });

      test('children 의 행은 isMainRow 가 false 를 리턴해야 한다.', () {
        final List<bool> result = [];

        addResult(e) => result.add(stateManager.isMainRow(e));

        children.forEach(addResult);

        expect(result.length, 3);
        expect(result, [false, false, false]);
      });

      test('refRows 의 행은 isNotMainGroupedRow 가 false 를 리턴해야 한다.', () {
        final List<bool> result = [];

        addResult(e) => result.add(stateManager.isNotMainGroupedRow(e));

        stateManager.refRows.forEach(addResult);

        expect(result.length, 3);
        expect(result, [false, false, false]);
      });

      test('children 의 행은 isNotMainGroupedRow 가 true 를 리턴해야 한다.', () {
        final List<bool> result = [];

        addResult(e) => result.add(stateManager.isNotMainGroupedRow(e));

        children.forEach(addResult);

        expect(result.length, 3);
        expect(result, [true, true, true]);
      });

      test('children 의 행은 isExpandedGroupedRow 가 false 를 리턴해야 한다.', () {
        final List<bool> result = [];

        addResult(e) => result.add(stateManager.isExpandedGroupedRow(e));

        children.forEach(addResult);

        expect(result.length, 3);
        expect(result, [false, false, false]);
      });

      test(
        'groupedRow 의 expanded 를 true 로 설정하면, '
        'isExpandedGroupedRow 가 true 를 리턴해야 한다.',
        () {
          groupedRow.type.group.setExpanded(true);

          expect(stateManager.isExpandedGroupedRow(groupedRow), true);
        },
      );

      test(
        'groupedRow 의 expanded 를 false 로 설정하면, '
        'isExpandedGroupedRow 가 false 를 리턴해야 한다.',
        () {
          groupedRow.type.group.setExpanded(false);

          expect(stateManager.isExpandedGroupedRow(groupedRow), false);
        },
      );
    });
  });

  /// A
  ///   - 1
  ///     - 001
  ///   - 2
  ///     - 002
  /// B
  ///   - 1
  ///     - 003
  ///     - 004
  ///   - 2
  ///     - 005
  group('2개의 컬럼으로 그룹핑 - PlutoRowGroupByColumnDelegate.', () {
    late List<PlutoColumn> columns;

    late List<PlutoRow> rows;

    late PlutoGridStateManager stateManager;

    PlutoRow createRow(String value1, String value2, String value3) {
      return PlutoRow(cells: {
        'column1': PlutoCell(value: value1),
        'column2': PlutoCell(value: value2),
        'column3': PlutoCell(value: value3),
      });
    }

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
      ];

      rows = [
        PlutoRow(cells: {
          'column1': PlutoCell(value: 'A'),
          'column2': PlutoCell(value: '1'),
          'column3': PlutoCell(value: '001'),
        }),
        PlutoRow(cells: {
          'column1': PlutoCell(value: 'A'),
          'column2': PlutoCell(value: '2'),
          'column3': PlutoCell(value: '002'),
        }),
        PlutoRow(cells: {
          'column1': PlutoCell(value: 'B'),
          'column2': PlutoCell(value: '1'),
          'column3': PlutoCell(value: '003'),
        }),
        PlutoRow(cells: {
          'column1': PlutoCell(value: 'B'),
          'column2': PlutoCell(value: '1'),
          'column3': PlutoCell(value: '004'),
        }),
        PlutoRow(cells: {
          'column1': PlutoCell(value: 'B'),
          'column2': PlutoCell(value: '2'),
          'column3': PlutoCell(value: '005'),
        }),
      ];

      stateManager = createStateManager(columns: columns, rows: rows);

      stateManager.setRowGroup(PlutoRowGroupByColumnDelegate(columns: [
        columns[0],
        columns[1],
      ]));
    });

    test('hasRowGroups 이 true 를 리턴해야 한다.', () {
      expect(stateManager.hasRowGroups, true);
    });

    test('enabledRowGroups 이 true 를 리턴해야 한다.', () {
      expect(stateManager.enabledRowGroups, true);
    });

    test('rowGroupDelegate 는 PlutoRowGroupByColumnDelegate 이어야 한다.', () {
      expect(
        stateManager.rowGroupDelegate is PlutoRowGroupByColumnDelegate,
        true,
      );
    });

    test('iterateMainRowGroup 가 2개의 행을 리턴해야 한다.', () {
      final mainRowGroup = stateManager.iterateAllMainRowGroup.toList();

      expect(mainRowGroup.length, 2);
    });

    test('iterateRowGroup 가 6개의 행을 리턴해야 한다.', () {
      final mainRowGroup = stateManager.iterateAllRowGroup.toList();

      expect(mainRowGroup.length, 6);
    });

    test('iterateRowAndGroup 가 11개의 행을 리턴해야 한다.', () {
      final mainRowGroup = stateManager.iterateAllRowAndGroup.toList();

      expect(mainRowGroup.length, 11);
    });

    test('iterateRow 가 5개의 행을 리턴해야 한다.', () {
      final mainRowGroup = stateManager.iterateAllRow.toList();

      expect(mainRowGroup.length, 5);
    });

    test('전체 컬럼을 지우고 새 컬럼을 추가하면 기존 행의 셀이 추가 되어야 한다.', () {
      stateManager.removeColumns(columns);

      expect(stateManager.refColumns.originalList.length, 0);
      expect(stateManager.refRows.originalList.length, 5);

      for (final row in stateManager.refRows.originalList) {
        // 그룹 된 컬럼이 삭제되어 모든 행의 parent 가 null 로 초기화 되어야 한다.
        expect(row.parent, null);
        expect(row.cells['column1'], null);
        expect(row.cells['column2'], null);
        expect(row.cells['column3'], null);
      }

      stateManager.insertColumns(0, [
        PlutoColumn(
          title: 'column4',
          field: 'column4',
          type: PlutoColumnType.text(),
        ),
      ]);

      expect(stateManager.refColumns.originalList.length, 1);
      expect(stateManager.refRows.originalList.length, 5);

      final rowAndGroup = stateManager.iterateAllRowAndGroup.toList();

      expect(rowAndGroup.length, 5);
      for (final row in rowAndGroup) {
        expect(row.cells['column1'], null);
        expect(row.cells['column2'], null);
        expect(row.cells['column3'], null);
        expect(row.cells['column4'], isNot(null));
      }
    });

    test('첫번째 행을 expand 하면 refRows 는 4개의 행을 리턴해야 한다.', () {
      final firstRowGroup = stateManager.refRows.first;

      stateManager.toggleExpandedRowGroup(rowGroup: firstRowGroup);

      expect(firstRowGroup.type.group.expanded, true);
      expect(stateManager.refRows.length, 4);
    });

    test('첫번째 행을 expand 하고 다시 collapse 하면 refRows 는 2개의 행을 리턴해야 한다.', () {
      final firstRowGroup = stateManager.refRows.first;

      stateManager.toggleExpandedRowGroup(rowGroup: firstRowGroup);

      expect(firstRowGroup.type.group.expanded, true);
      expect(stateManager.refRows.length, 4);

      stateManager.toggleExpandedRowGroup(rowGroup: firstRowGroup);

      expect(firstRowGroup.type.group.expanded, false);
      expect(stateManager.refRows.length, 2);
    });

    test(
      '첫번째 행을 expand 하고 펼처진 두번째 행을 expand 하면, '
      'refRows 는 5개의 행을 리턴해야 한다.',
      () {
        final firstRowGroup = stateManager.refRows.first;
        final firstRowGroupFirstChild = firstRowGroup.type.group.children.first;

        stateManager.toggleExpandedRowGroup(rowGroup: firstRowGroup);
        stateManager.toggleExpandedRowGroup(rowGroup: firstRowGroupFirstChild);

        expect(firstRowGroup.type.group.expanded, true);
        expect(firstRowGroupFirstChild.type.group.expanded, true);
        expect(stateManager.refRows.length, 5);
      },
    );

    test(
      '첫번째 행과 그 첫번째 자식을 expand 하고 첫번째 행을 다시 collapse 하면, '
      'refRows 는 2개의 행을 리턴해야 한다.'
      '그리고 다시 첫번째 행을 expand 하면 이미 펼쳐져 있던 첫번째 자식은 함께 펼쳐져야 한다.',
      () {
        final firstRowGroup = stateManager.refRows.first;
        final firstRowGroupFirstChild = firstRowGroup.type.group.children.first;

        stateManager.toggleExpandedRowGroup(rowGroup: firstRowGroup);
        stateManager.toggleExpandedRowGroup(rowGroup: firstRowGroupFirstChild);

        expect(firstRowGroup.type.group.expanded, true);
        expect(firstRowGroupFirstChild.type.group.expanded, true);
        expect(stateManager.refRows.length, 5);

        stateManager.toggleExpandedRowGroup(rowGroup: firstRowGroup);
        expect(firstRowGroup.type.group.expanded, false);
        expect(stateManager.refRows.length, 2);

        stateManager.toggleExpandedRowGroup(rowGroup: firstRowGroup);
        expect(firstRowGroup.type.group.expanded, true);
        expect(stateManager.refRows.length, 5);
      },
    );

    test('refRows 가 설정한 2개의 컬럼으로 그룹핑 되어야 한다.', () {
      final firstGroupField = columns[0].field;

      expect(stateManager.refRows.length, 2);

      expect(stateManager.refRows[0].type.isGroup, true);
      expect(stateManager.refRows[0].cells[firstGroupField]!.value, 'A');

      expect(stateManager.refRows[1].type.isGroup, true);
      expect(stateManager.refRows[1].cells[firstGroupField]!.value, 'B');
    });

    group('첫번째 그룹.', () {
      late FilteredList<PlutoRow> aGroupChildren;

      setUp(() {
        aGroupChildren = stateManager.refRows[0].type.group.children;
      });

      test('자식들이 두번째 컬럼으로 그룹핑 되어야 한다.', () {
        final secondGroupField = columns[1].field;

        expect(aGroupChildren.length, 2);

        expect(aGroupChildren[0].type.isGroup, true);
        expect(aGroupChildren[0].cells[secondGroupField]!.value, '1');

        expect(aGroupChildren[1].type.isGroup, true);
        expect(aGroupChildren[1].cells[secondGroupField]!.value, '2');
      });

      test('자식들은 각 1개의 자식을 가지고 있어야 한다.', () {
        final normalColumnField = columns[2].field;

        final aGroupFirstChildren = aGroupChildren[0].type.group.children;
        expect(aGroupFirstChildren.length, 1);
        expect(aGroupFirstChildren[0].type.isNormal, true);
        expect(aGroupFirstChildren[0].cells[normalColumnField]!.value, '001');

        final aGroupSecondChildren = aGroupChildren[1].type.group.children;
        expect(aGroupSecondChildren.length, 1);
        expect(aGroupSecondChildren[0].type.isNormal, true);
        expect(
          aGroupSecondChildren[0].cells[normalColumnField]!.value,
          '002',
        );
      });
    });

    group('두번째 그룹.', () {
      late FilteredList<PlutoRow> bGroupChildren;

      setUp(() {
        bGroupChildren = stateManager.refRows[1].type.group.children;
      });

      test('자식들이 두번째 컬럼으로 그룹핑 되어야 한다.', () {
        final secondGroupField = columns[1].field;

        expect(bGroupChildren.length, 2);

        expect(bGroupChildren[0].type.isGroup, true);
        expect(bGroupChildren[0].cells[secondGroupField]!.value, '1');

        expect(bGroupChildren[1].type.isGroup, true);
        expect(bGroupChildren[1].cells[secondGroupField]!.value, '2');
      });

      test('자식들은 각 2개, 1개의 자식을 가지고 있어야 한다.', () {
        final normalColumnField = columns[2].field;

        final bGroupFirstChildren = bGroupChildren[0].type.group.children;
        expect(bGroupFirstChildren.length, 2);
        expect(bGroupFirstChildren[0].type.isNormal, true);
        expect(bGroupFirstChildren[0].cells[normalColumnField]!.value, '003');
        expect(bGroupFirstChildren[1].type.isNormal, true);
        expect(bGroupFirstChildren[1].cells[normalColumnField]!.value, '004');

        final bGroupSecondChildren = bGroupChildren[1].type.group.children;
        expect(bGroupSecondChildren.length, 1);
        expect(bGroupSecondChildren[0].type.isNormal, true);
        expect(
          bGroupSecondChildren[0].cells[normalColumnField]!.value,
          '005',
        );
      });
    });

    test('column1 을 A 값으로 필터링 하면 1개의 행이 리턴 되어야 한다.', () {
      stateManager.setFilter((row) => row.cells['column1']!.value == 'A');

      expect(stateManager.refRows.length, 1);
    });

    test('첫번째 행을 펼친 후 column1 을 A 값으로 필터링 하면 3개의 행이 리턴 되어야 한다.', () {
      final firstRowGroup = stateManager.refRows.first;

      stateManager.toggleExpandedRowGroup(rowGroup: firstRowGroup);

      stateManager.setFilter((row) => row.cells['column1']!.value == 'A');

      // 첫번째 행 + 첫번째 행의 2개의 자식 = 3개
      expect(stateManager.refRows.length, 3);
    });

    test('두개의 행을 모두 펼친 후 column2 을 1 값으로 필터링 하면 4개의 행이 리턴 되어야 한다.', () {
      final firstRowGroup = stateManager.refRows[0];
      final secondRowGroup = stateManager.refRows[1];

      stateManager.toggleExpandedRowGroup(rowGroup: firstRowGroup);
      stateManager.toggleExpandedRowGroup(rowGroup: secondRowGroup);
      expect(stateManager.refRows.length, 6);

      stateManager.setFilter((row) => row.cells['column2']!.value == '1');

      expect(stateManager.refRows.length, 4);
    });

    test('column1 을 descending 정렬 하면 두개의 행의 위치가 바뀌어야 한다.', () {
      expect(stateManager.refRows[0].cells['column1']!.value, 'A');
      expect(stateManager.refRows[1].cells['column1']!.value, 'B');

      // Ascending
      stateManager.toggleSortColumn(columns[0]);
      // Descending
      stateManager.toggleSortColumn(columns[0]);

      expect(stateManager.refRows[0].cells['column1']!.value, 'B');
      expect(stateManager.refRows[1].cells['column1']!.value, 'A');
    });

    test(
      '두번째 행을 모두 펼친 후 column3 를 descending 정렬 하면, '
      '두번째 행의 2개의 자식의 위치가 바뀌어야 한다.',
      () {
        final secondRowGroup = stateManager.refRows[1];

        stateManager.toggleExpandedRowGroup(rowGroup: secondRowGroup);

        final secondRowGroupFirstChild = secondRowGroup.type.group.children[0];
        stateManager.toggleExpandedRowGroup(rowGroup: secondRowGroupFirstChild);

        final secondRowGroupSecondChild = secondRowGroup.type.group.children[1];
        stateManager.toggleExpandedRowGroup(
          rowGroup: secondRowGroupSecondChild,
        );

        {
          final fistChild = secondRowGroupFirstChild.type.group.children[0];
          expect(fistChild.cells['column3']!.value, '003');

          final secondChild = secondRowGroupFirstChild.type.group.children[1];
          expect(secondChild.cells['column3']!.value, '004');
        }

        // Ascending
        stateManager.toggleSortColumn(columns[2]);
        // Descending
        stateManager.toggleSortColumn(columns[2]);

        {
          final fistChild = secondRowGroupFirstChild.type.group.children[0];
          expect(fistChild.cells['column3']!.value, '004');

          final secondChild = secondRowGroupFirstChild.type.group.children[1];
          expect(secondChild.cells['column3']!.value, '003');
        }
      },
    );

    test('첫번째 행에 column2 의 값이 3인 행을 추가 하면 첫번째 행의 자식은 3개가 되어야 한다.', () {
      final rowToAdd = PlutoRow(cells: {
        'column1': PlutoCell(value: 'A'),
        'column2': PlutoCell(value: '3'),
        'column3': PlutoCell(value: '006'),
      });

      expect(stateManager.refRows.first.type.group.children.length, 2);

      stateManager.insertRows(0, [rowToAdd]);

      expect(stateManager.refRows.first.type.group.children.length, 3);
    });

    test('첫번째 행에 column2 의 값이 3인 행을 추가 하면 추가 된 자식의 parent 가 설정 되어야 한다.', () {
      final rowToAdd = PlutoRow(cells: {
        'column1': PlutoCell(value: 'A'),
        'column2': PlutoCell(value: '3'),
        'column3': PlutoCell(value: '006'),
      });

      stateManager.insertRows(0, [rowToAdd]);

      expect(rowToAdd.parent?.cells['column2']!.value, '3');
      expect(rowToAdd.parent?.parent, stateManager.refRows.first);
    });

    test(
      '정렬 된 상태에서 첫번째 행에 column2 의 값이 3인 행을 추가 하면, '
      '추가 된 자식의 parent 가 설정 되어야 한다.',
      () {
        final rowToAdd = PlutoRow(cells: {
          'column1': PlutoCell(value: 'A'),
          'column2': PlutoCell(value: '3'),
          'column3': PlutoCell(value: '006'),
        });

        stateManager.toggleSortColumn(columns.first);

        stateManager.insertRows(0, [rowToAdd]);

        expect(rowToAdd.parent?.cells['column2']!.value, '3');
        expect(rowToAdd.parent?.parent, stateManager.refRows.first);
      },
    );

    test(
      'prependRows 로 column2 의 값이 3인 행을 추가 하면, '
      '추가 된 자식의 parent 가 설정 되어야 한다.',
      () {
        final rowToAdd = PlutoRow(cells: {
          'column1': PlutoCell(value: 'A'),
          'column2': PlutoCell(value: '3'),
          'column3': PlutoCell(value: '006'),
        });

        stateManager.toggleSortColumn(columns.first);

        stateManager.prependRows([rowToAdd]);

        expect(rowToAdd.parent?.cells['column2']!.value, '3');
        expect(rowToAdd.parent?.parent, stateManager.refRows.first);
      },
    );

    test(
      'appendRows 로 column2 의 값이 3인 행을 추가 하면, '
      '추가 된 자식의 parent 가 설정 되어야 한다.',
      () {
        final rowToAdd = PlutoRow(cells: {
          'column1': PlutoCell(value: 'A'),
          'column2': PlutoCell(value: '3'),
          'column3': PlutoCell(value: '006'),
        });

        stateManager.toggleSortColumn(columns.first);

        stateManager.appendRows([rowToAdd]);

        expect(rowToAdd.parent?.cells['column2']!.value, '3');
        expect(rowToAdd.parent?.parent, stateManager.refRows.first);
      },
    );

    test('첫번째 행을 삭제 하면 그 자식들도 모두 삭제 되어야 한다.', () {
      final firstRowGroup = stateManager.refRows.first;

      expect(stateManager.iterateAllRowAndGroup.length, 11);

      stateManager.removeRows([firstRowGroup]);

      expect(stateManager.iterateAllRowAndGroup.length, 6);
    });

    test('column1 을 삭제 하면 column2 로 다시 그룹핑 되어야 한다.', () {
      final firstColumn = stateManager.refColumns.first;

      stateManager.removeColumns([firstColumn]);

      expect(stateManager.refRows.length, 2);

      {
        final rowGroup = stateManager.refRows[0];
        expect(rowGroup.cells['column2']!.value, '1');
        expect(rowGroup.type.group.children.length, 3);
      }

      {
        final rowGroup = stateManager.refRows[1];
        expect(rowGroup.cells['column2']!.value, '2');
        expect(rowGroup.type.group.children.length, 2);
      }
    });

    test('column1 을 숨기면 하면 column2 로 다시 그룹핑 되어야 한다.', () {
      final firstColumn = stateManager.refColumns.first;

      stateManager.hideColumn(firstColumn, true);

      expect(stateManager.refRows.length, 2);

      {
        final rowGroup = stateManager.refRows[0];
        expect(rowGroup.cells['column2']!.value, '1');
        expect(rowGroup.type.group.children.length, 3);
      }

      {
        final rowGroup = stateManager.refRows[1];
        expect(rowGroup.cells['column2']!.value, '2');
        expect(rowGroup.type.group.children.length, 2);
      }
    });

    test('column1 을 숨기고 다시 해제 하면 column1 로 다시 그룹핑 되어야 한다.', () {
      final firstColumn = stateManager.refColumns.first;

      stateManager.hideColumn(firstColumn, true);

      expect(stateManager.refRows.length, 2);

      {
        final rowGroup = stateManager.refRows[0];
        expect(rowGroup.cells['column2']!.value, '1');
        expect(rowGroup.type.group.children.length, 3);
      }

      {
        final rowGroup = stateManager.refRows[1];
        expect(rowGroup.cells['column2']!.value, '2');
        expect(rowGroup.type.group.children.length, 2);
      }

      stateManager.hideColumn(firstColumn, false);

      {
        final rowGroup = stateManager.refRows[0];
        expect(rowGroup.cells['column1']!.value, 'A');
        expect(rowGroup.type.group.children.length, 2);
      }

      {
        final rowGroup = stateManager.refRows[1];
        expect(rowGroup.cells['column1']!.value, 'B');
        expect(rowGroup.type.group.children.length, 2);
      }
    });

    group('insertRows', () {
      test('index 0 에 (C, 1, 006) 을 추가.', () {
        /// Before
        /// 0. A [V]
        /// 1. B
        /// After
        /// 0. C (1 > 006) [V]
        /// 1. A
        /// 2. B
        expect(stateManager.refRows.length, 2);
        expect(stateManager.refRows[0].cells['column1']!.value, 'A');
        expect(stateManager.refRows[1].cells['column1']!.value, 'B');

        stateManager.insertRows(0, [createRow('C', '1', '006')]);

        expect(stateManager.refRows.length, 3);
        expect(stateManager.refRows[0].cells['column1']!.value, 'C');
        expect(stateManager.refRows[1].cells['column1']!.value, 'A');
        expect(stateManager.refRows[2].cells['column1']!.value, 'B');

        final GROUP_C = stateManager.refRows[0];
        final GROUP_C_1 = GROUP_C.type.group.children.first;
        expect(GROUP_C_1.parent, GROUP_C);
        expect(GROUP_C_1.type.group.children.first.parent, GROUP_C_1);
      });

      test('index 2 에 (C, 1, 006) 을 추가.', () {
        /// Before
        /// 0. A
        /// 1. B
        /// 2. [V]
        /// After
        /// 0. A
        /// 1. B
        /// 2. C (1 > 006) [V]
        expect(stateManager.refRows.length, 2);
        expect(stateManager.refRows[0].cells['column1']!.value, 'A');
        expect(stateManager.refRows[1].cells['column1']!.value, 'B');

        stateManager.insertRows(2, [createRow('C', '1', '006')]);

        expect(stateManager.refRows.length, 3);
        expect(stateManager.refRows[0].cells['column1']!.value, 'A');
        expect(stateManager.refRows[1].cells['column1']!.value, 'B');
        expect(stateManager.refRows[2].cells['column1']!.value, 'C');

        final GROUP_C = stateManager.refRows[2];
        final GROUP_C_1 = GROUP_C.type.group.children.first;
        expect(GROUP_C_1.parent, GROUP_C);
        expect(GROUP_C_1.type.group.children.first.parent, GROUP_C_1);
      });

      test('index 1 에 (C, 1, 006) 을 추가.', () {
        /// Before
        /// 0. A
        /// 1. B [V]
        /// 2.   - 1
        /// 3.     - 003
        /// 4.     - 004
        /// 5.   - 2
        /// After
        /// 0. A
        /// 1. C (1 > 006) [V]
        /// 2. B
        /// 3.   - 1
        /// 4.     - 003
        /// 5.     - 004
        /// 6.   - 2
        final GROUP_B = stateManager.refRows[1];
        final GROUP_B_1 = GROUP_B.type.group.children.first;
        stateManager.toggleExpandedRowGroup(rowGroup: GROUP_B);
        stateManager.toggleExpandedRowGroup(rowGroup: GROUP_B_1);

        expect(stateManager.refRows.length, 6);
        expect(stateManager.refRows[0].cells['column1']!.value, 'A');
        expect(stateManager.refRows[1].cells['column1']!.value, 'B');
        expect(stateManager.refRows[2].cells['column2']!.value, '1');
        expect(stateManager.refRows[3].cells['column3']!.value, '003');
        expect(stateManager.refRows[4].cells['column3']!.value, '004');
        expect(stateManager.refRows[5].cells['column2']!.value, '2');

        stateManager.insertRows(1, [createRow('C', '1', '006')]);

        expect(stateManager.refRows.length, 7);
        expect(stateManager.refRows[0].cells['column1']!.value, 'A');
        expect(stateManager.refRows[1].cells['column1']!.value, 'C');
        expect(stateManager.refRows[2].cells['column1']!.value, 'B');
        expect(stateManager.refRows[3].cells['column2']!.value, '1');
        expect(stateManager.refRows[4].cells['column3']!.value, '003');
        expect(stateManager.refRows[5].cells['column3']!.value, '004');
        expect(stateManager.refRows[6].cells['column2']!.value, '2');

        final GROUP_C = stateManager.refRows[1];
        final GROUP_C_1 = GROUP_C.type.group.children.first;
        expect(GROUP_C_1.parent, GROUP_C);
        expect(GROUP_C_1.type.group.children.first.parent, GROUP_C_1);
      });

      test('index 5 에 (C, 1, 006) 을 추가.', () {
        /// Before
        /// 0. A
        /// 1. B
        /// 2.   - 1
        /// 3.   - 2
        /// 4.     - 005
        /// 5. [V]
        /// After
        /// 0. A
        /// 1. B
        /// 2.   - 1
        /// 3.   - 2
        /// 4.     - 005
        /// 5. C [V]
        final GROUP_B = stateManager.refRows[1];
        final GROUP_B_2 = GROUP_B.type.group.children.last;
        stateManager.toggleExpandedRowGroup(rowGroup: GROUP_B);
        stateManager.toggleExpandedRowGroup(rowGroup: GROUP_B_2);

        expect(stateManager.refRows.length, 5);
        expect(stateManager.refRows[0].cells['column1']!.value, 'A');
        expect(stateManager.refRows[1].cells['column1']!.value, 'B');
        expect(stateManager.refRows[2].cells['column2']!.value, '1');
        expect(stateManager.refRows[3].cells['column2']!.value, '2');
        expect(stateManager.refRows[4].cells['column3']!.value, '005');

        stateManager.insertRows(5, [createRow('C', '1', '006')]);

        expect(stateManager.refRows.length, 6);
        expect(stateManager.refRows[0].cells['column1']!.value, 'A');
        expect(stateManager.refRows[1].cells['column1']!.value, 'B');
        expect(stateManager.refRows[2].cells['column2']!.value, '1');
        expect(stateManager.refRows[3].cells['column2']!.value, '2');
        expect(stateManager.refRows[4].cells['column3']!.value, '005');
        expect(stateManager.refRows[5].cells['column1']!.value, 'C');
      });

      test('index 5 에 (B, 3, 006) 을 추가.', () {
        /// Before
        /// 0. A
        /// 1. B
        /// 2.   - 1
        /// 3.   - 2
        /// 4.     - 005
        /// 5. [V]
        /// After
        /// 0. A
        /// 1. B
        /// 2.   - 1
        /// 3.   - 2
        /// 4.     - 005
        /// 5.   - 3 [V]
        final GROUP_B = stateManager.refRows[1];
        final GROUP_B_2 = GROUP_B.type.group.children.last;
        stateManager.toggleExpandedRowGroup(rowGroup: GROUP_B);
        stateManager.toggleExpandedRowGroup(rowGroup: GROUP_B_2);

        stateManager.insertRows(5, [createRow('B', '3', '006')]);

        expect(stateManager.refRows.length, 6);
        expect(stateManager.refRows[0].cells['column1']!.value, 'A');
        expect(stateManager.refRows[1].cells['column1']!.value, 'B');
        expect(stateManager.refRows[2].cells['column2']!.value, '1');
        expect(stateManager.refRows[3].cells['column2']!.value, '2');
        expect(stateManager.refRows[4].cells['column3']!.value, '005');
        expect(stateManager.refRows[5].cells['column2']!.value, '3');
      });

      test('index 6 에 (B, 1, 006) 을 추가.', () {
        /// Before
        /// 0. A
        /// 1. B
        /// 2.   - 1
        /// 3.     - 003
        /// 4.     - 004
        /// 5.   - 2
        /// 6. [V]
        /// After
        /// 0. A
        /// 1. B
        /// 2.   - 1
        /// 3.     - 003
        /// 4.     - 004
        /// 5.     - 006 [V]
        /// 6.   - 2
        final GROUP_B = stateManager.refRows[1];
        final GROUP_B_1 = GROUP_B.type.group.children.first;
        stateManager.toggleExpandedRowGroup(rowGroup: GROUP_B);
        stateManager.toggleExpandedRowGroup(rowGroup: GROUP_B_1);

        stateManager.insertRows(6, [createRow('B', '1', '006')]);

        expect(stateManager.refRows.length, 7);
        expect(stateManager.refRows[0].cells['column1']!.value, 'A');
        expect(stateManager.refRows[1].cells['column1']!.value, 'B');
        expect(stateManager.refRows[2].cells['column2']!.value, '1');
        expect(stateManager.refRows[3].cells['column3']!.value, '003');
        expect(stateManager.refRows[4].cells['column3']!.value, '004');
        expect(stateManager.refRows[5].cells['column3']!.value, '006');
        expect(stateManager.refRows[6].cells['column2']!.value, '2');
      });

      test('index 1 에 (C, 1, 006), (B, 3, 007) 을 추가', () {
        /// Before
        /// 0. A
        /// 1. B [V]
        /// 2.   - 1
        /// 3.     - 003
        /// 4.     - 004
        /// 5.   - 2
        /// After
        /// 0. A
        /// 1. C (1 > 006) [V]
        /// 2. B
        /// 3.   - 1
        /// 4.     - 003
        /// 5.     - 004
        /// 6.   - 2
        /// 7.   - 3 > (007)
        final GROUP_B = stateManager.refRows[1];
        final GROUP_B_1 = GROUP_B.type.group.children.first;
        stateManager.toggleExpandedRowGroup(rowGroup: GROUP_B);
        stateManager.toggleExpandedRowGroup(rowGroup: GROUP_B_1);

        expect(stateManager.refRows.length, 6);
        expect(stateManager.refRows[0].cells['column1']!.value, 'A');
        expect(stateManager.refRows[1].cells['column1']!.value, 'B');
        expect(stateManager.refRows[2].cells['column2']!.value, '1');
        expect(stateManager.refRows[3].cells['column3']!.value, '003');
        expect(stateManager.refRows[4].cells['column3']!.value, '004');
        expect(stateManager.refRows[5].cells['column2']!.value, '2');

        stateManager.insertRows(1, [
          createRow('C', '1', '006'),
          createRow('B', '3', '007'),
        ]);

        expect(stateManager.refRows.length, 8);
        expect(stateManager.refRows[0].cells['column1']!.value, 'A');
        expect(stateManager.refRows[1].cells['column1']!.value, 'C');
        expect(stateManager.refRows[2].cells['column1']!.value, 'B');
        expect(stateManager.refRows[3].cells['column2']!.value, '1');
        expect(stateManager.refRows[4].cells['column3']!.value, '003');
        expect(stateManager.refRows[5].cells['column3']!.value, '004');
        expect(stateManager.refRows[6].cells['column2']!.value, '2');
        expect(stateManager.refRows[7].cells['column2']!.value, '3');

        final GROUP_C = stateManager.refRows[1];
        final GROUP_C_1 = GROUP_C.type.group.children.first;
        expect(GROUP_C_1.parent, GROUP_C);
        expect(GROUP_C_1.type.group.children.first.parent, GROUP_C_1);

        final GROUP_B_3 = stateManager.refRows[7];
        expect(GROUP_B_3.parent, GROUP_B);
        expect(GROUP_B_3.type.group.children.first.parent, GROUP_B_3);
      });

      test('insert 5 에 (C, 2, 006), (C, 3, 007) 을 추가.', () {
        /// Before
        /// 0. A
        /// 1. B
        /// 2.   - 1
        /// 3.     - 003
        /// 4.     - 004
        /// 5.   - 2 [V]
        /// After
        /// 0. A
        /// 1. B
        /// 2.   - 1
        /// 3.     - 003
        /// 4.     - 004
        /// 5.   - 3 > (007) [V]
        /// 6.   - 2 > (005, 006)
        final GROUP_B = stateManager.refRows[1];
        final GROUP_B_1 = GROUP_B.type.group.children.first;
        stateManager.toggleExpandedRowGroup(rowGroup: GROUP_B);
        stateManager.toggleExpandedRowGroup(rowGroup: GROUP_B_1);

        final GROUP_B_2 = stateManager.refRows[5];
        expect(GROUP_B_2.type.group.children.length, 1);

        stateManager.insertRows(5, [
          createRow('C', '2', '006'),
          createRow('C', '3', '007'),
        ]);

        expect(GROUP_B_2.type.group.children.length, 2);
        final GROUP_B_2_006 = GROUP_B_2.type.group.children[1];
        expect(GROUP_B_2_006.cells['column3']!.value, '006');
        expect(GROUP_B_2_006.parent, GROUP_B_2);
        expect(stateManager.refRows[6].cells['column2']!.value, '2');

        expect(GROUP_B.type.group.children.length, 3);
        final GROUP_B_3 = stateManager.refRows[5];
        final GROUP_B_3_007 = GROUP_B_3.type.group.children[0];
        expect(GROUP_B_3.cells['column2']!.value, '3');
        expect(GROUP_B_3_007.cells['column3']!.value, '007');
        expect(GROUP_B_3.parent, GROUP_B);
        expect(GROUP_B_3_007.parent, GROUP_B_3);
      });

      test(
        'Column1 을 Descending 정렬 상태에서 index 5 에, '
        '(C, 1, 006), (D, 1, 007) 을 추가.',
        () {
          /// Before
          /// 0. B
          /// 1.   - 1
          /// 2.     - 003
          /// 3.     - 004
          /// 4.   - 2
          /// 5. A [V]
          /// After
          /// 0. B
          /// 1.   - 1
          /// 2.     - 003
          /// 3.     - 004
          /// 4.   - 2
          /// 5. C (1 > 006) [V]
          /// 6. D (1 > 007)
          /// 7. A
          final GROUP_B = stateManager.refRows[1];
          final GROUP_B_1 = GROUP_B.type.group.children.first;

          stateManager.toggleExpandedRowGroup(rowGroup: GROUP_B);
          stateManager.toggleExpandedRowGroup(rowGroup: GROUP_B_1);

          stateManager.sortDescending(stateManager.columns.first);

          expect(stateManager.refRows[0].cells['column1']!.value, 'B');
          expect(stateManager.refRows[5].cells['column1']!.value, 'A');

          stateManager.insertRows(5, [
            createRow('C', '1', '006'),
            createRow('D', '1', '007'),
          ]);

          expect(stateManager.refRows[0].cells['column1']!.value, 'B');
          expect(stateManager.refRows[5].cells['column1']!.value, 'C');
          expect(stateManager.refRows[6].cells['column1']!.value, 'D');
          expect(stateManager.refRows[7].cells['column1']!.value, 'A');

          stateManager.sortBySortIdx(stateManager.columns.first);

          expect(stateManager.refRows[0].cells['column1']!.value, 'C');
          expect(stateManager.refRows[1].cells['column1']!.value, 'D');
          expect(stateManager.refRows[2].cells['column1']!.value, 'A');
        },
      );

      test(
        'Column1 을 Descending 정렬 상태에서 insert 2 에, '
        '(C, 1, 006), (C, 3, 007) 을 추가.',
        () {
          /// Before
          /// 0. B
          /// 1.   - 1
          /// 2.     - 003 [V]
          /// 3.     - 004
          /// 4.   - 2
          /// 5. A
          /// After
          /// 0. B
          /// 1.   - 1
          /// 2.     - 006 [V]
          /// 3.     - 007
          /// 4.     - 003
          /// 5.     - 004
          /// 6.   - 2
          /// 7. A
          final GROUP_B = stateManager.refRows[1];
          final GROUP_B_1 = GROUP_B.type.group.children.first;

          stateManager.toggleExpandedRowGroup(rowGroup: GROUP_B);
          stateManager.toggleExpandedRowGroup(rowGroup: GROUP_B_1);

          stateManager.sortDescending(stateManager.columns.first);

          expect(stateManager.refRows[0].cells['column1']!.value, 'B');
          expect(stateManager.refRows[5].cells['column1']!.value, 'A');

          stateManager.insertRows(2, [
            createRow('C', '1', '006'),
            createRow('C', '3', '007'),
          ]);

          expect(stateManager.refRows[0].cells['column1']!.value, 'B');
          expect(stateManager.refRows[1].cells['column2']!.value, '1');
          expect(stateManager.refRows[2].cells['column3']!.value, '006');
          expect(stateManager.refRows[3].cells['column3']!.value, '007');
          expect(stateManager.refRows[4].cells['column3']!.value, '003');
          expect(stateManager.refRows[5].cells['column3']!.value, '004');
          expect(stateManager.refRows[6].cells['column2']!.value, '2');
          expect(stateManager.refRows[7].cells['column1']!.value, 'A');

          stateManager.sortBySortIdx(stateManager.columns.first);

          expect(stateManager.refRows[0].cells['column1']!.value, 'A');
          expect(stateManager.refRows[1].cells['column1']!.value, 'B');
          expect(stateManager.refRows[2].cells['column2']!.value, '1');
          expect(stateManager.refRows[3].cells['column3']!.value, '006');
          expect(stateManager.refRows[4].cells['column3']!.value, '007');
          expect(stateManager.refRows[5].cells['column3']!.value, '003');
          expect(stateManager.refRows[6].cells['column3']!.value, '004');
        },
      );
    });

    group('prependRows', () {
      test('(C, 1, 006) 을 추가.', () {
        /// Before
        /// 0. A
        /// 1. B
        /// After
        /// 0. C
        /// 1. A
        /// 2. B
        stateManager.prependRows([createRow('C', '1', '006')]);

        expect(stateManager.refRows.length, 3);
        final GROUP_C = stateManager.refRows[0];
        final GROUP_C_1 = GROUP_C.type.group.children.first;
        final GROUP_C_1_006 = GROUP_C_1.type.group.children.first;
        expect(GROUP_C.cells['column1']!.value, 'C');
        expect(GROUP_C_1.cells['column2']!.value, '1');
        expect(GROUP_C_1_006.cells['column3']!.value, '006');
        expect(GROUP_C_1_006.parent, GROUP_C_1);
        expect(GROUP_C_1_006.parent?.parent, GROUP_C);
      });

      test('(B, 2, 006) 을 추가.', () {
        /// Before
        /// 0. A
        /// 1. B
        /// After
        /// 0. A
        /// 1. B (2 > 005, 006)
        final GROUP_B = stateManager.refRows[1];
        final GROUP_B_2 = GROUP_B.type.group.children[1];
        expect(stateManager.refRows.length, 2);
        expect(GROUP_B_2.type.group.children.length, 1);

        stateManager.prependRows([createRow('B', '2', '006')]);

        final GROUP_B_2_006 = GROUP_B_2.type.group.children[1];
        expect(stateManager.refRows.length, 2);
        expect(GROUP_B_2.type.group.children.length, 2);
        expect(GROUP_B_2_006.cells['column3']!.value, '006');
      });

      test('(A, 1, 006), (B, 1, 007), (C, 1, 008) 을 추가.', () {
        /// Before
        /// 0. A
        /// 1. B
        /// After
        /// 0. C (1 > 008)
        /// 1. A (1 > 001 006)
        /// 2. B (1 > 003, 004, 007)
        stateManager.prependRows([
          createRow('A', '1', '006'),
          createRow('B', '1', '007'),
          createRow('C', '1', '008'),
        ]);

        final GROUP_C = stateManager.refRows[0];
        final GROUP_C_1 = GROUP_C.type.group.children.first;
        final GROUP_C_1_008 = GROUP_C_1.type.group.children.first;
        final GROUP_A = stateManager.refRows[1];
        final GROUP_A_1 = GROUP_A.type.group.children.first;
        final GROUP_A_1_006 = GROUP_A_1.type.group.children.last;
        final GROUP_B = stateManager.refRows[2];
        final GROUP_B_1 = GROUP_B.type.group.children.first;
        final GROUP_B_1_007 = GROUP_B_1.type.group.children.last;

        expect(GROUP_C.cells['column1']!.value, 'C');
        expect(GROUP_C_1.cells['column2']!.value, '1');
        expect(GROUP_C_1_008.cells['column3']!.value, '008');
        expect(GROUP_C_1_008.parent, GROUP_C_1);
        expect(GROUP_C_1_008.parent?.parent, GROUP_C);

        expect(GROUP_A_1_006.cells['column3']!.value, '006');
        expect(GROUP_A_1_006.parent, GROUP_A_1);
        expect(GROUP_A_1_006.parent?.parent, GROUP_A);
        expect(GROUP_B_1_007.cells['column3']!.value, '007');
        expect(GROUP_B_1_007.parent, GROUP_B_1);
        expect(GROUP_B_1_007.parent?.parent, GROUP_B);
      });
    });

    group('appendRows', () {
      test('(C, 1, 006) 을 추가.', () {
        /// Before
        /// 0. A
        /// 1. B
        /// After
        /// 0. A
        /// 1. B
        /// 2. C (1 > 006)
        stateManager.appendRows([createRow('C', '1', '006')]);

        expect(stateManager.refRows.length, 3);
        final GROUP_C = stateManager.refRows[2];
        final GROUP_C_1 = GROUP_C.type.group.children.first;
        final GROUP_C_1_006 = GROUP_C_1.type.group.children.first;
        expect(GROUP_C.cells['column1']!.value, 'C');
        expect(GROUP_C_1.cells['column2']!.value, '1');
        expect(GROUP_C_1_006.cells['column3']!.value, '006');
      });

      test('(B, 3, 006), (C, 1, 007), (C, 2, 008) 을 추가.', () {
        /// Before
        /// 0. A
        /// 1. B
        /// After
        /// 0. A
        /// 1. B (3 > 006)
        /// 2. C (1 > 007, 2 > 008)
        stateManager.appendRows([
          createRow('B', '3', '006'),
          createRow('C', '1', '007'),
          createRow('C', '2', '008'),
        ]);

        expect(stateManager.refRows.length, 3);
        final GROUP_B = stateManager.refRows[1];
        final GROUP_B_3 = GROUP_B.type.group.children.last;
        final GROUP_B_3_006 = GROUP_B_3.type.group.children.first;
        expect(GROUP_B_3.cells['column2']!.value, '3');
        expect(GROUP_B_3_006.cells['column3']!.value, '006');

        final GROUP_C = stateManager.refRows[2];
        final GROUP_C_1 = GROUP_C.type.group.children.first;
        final GROUP_C_1_007 = GROUP_C_1.type.group.children.first;
        final GROUP_C_2 = GROUP_C.type.group.children.last;
        final GROUP_C_2_008 = GROUP_C_2.type.group.children.first;
        expect(GROUP_C.cells['column1']!.value, 'C');
        expect(GROUP_C_1.cells['column2']!.value, '1');
        expect(GROUP_C_1_007.cells['column3']!.value, '007');
        expect(GROUP_C_2.cells['column2']!.value, '2');
        expect(GROUP_C_2_008.cells['column3']!.value, '008');
      });
    });

    group('removeRows', () {
      test('A 그룹의 001 을 삭제하면 A 그룹의 1 그룹과 함께 삭제 되어야 한다.', () {
        /// A - 1 - 001
        ///   - 2 - 002
        /// B - 1 - 003, 004
        ///   - 2 - 005
        final A = stateManager.refRows[0];
        final A_1 = A.type.group.children[0];
        final A_1_001 = A_1.type.group.children[0];
        expect(A_1_001.cells['column3']!.value, '001');

        stateManager.removeRows([A_1_001]);

        expect(stateManager.refRows[0], A);
        expect(stateManager.refRows[0].type.group.children.length, 1);
        expect(stateManager.refRows[0].type.group.children[0], isNot(A_1));

        findRemovedRows(e) => e.key == A_1.key || e.key == A_1_001.key;
        expect(
          stateManager.iterateAllRowAndGroup.where(findRemovedRows).length,
          0,
        );
      });

      test('B 그룹의 003 을 삭제하면 003 만 삭제 되어야 한다.', () {
        /// A - 1 - 001
        ///   - 2 - 002
        /// B - 1 - 003, 004
        ///   - 2 - 005
        final B = stateManager.refRows[1];
        final B_1 = B.type.group.children[0];
        final B_1_003 = B_1.type.group.children[0];

        expect(stateManager.iterateAllRowAndGroup.length, 11);

        stateManager.removeRows([B_1_003]);

        expect(stateManager.iterateAllRowAndGroup.length, 10);

        expect(B_1.type.group.children.length, 1);
        expect(B_1.type.group.children[0], isNot(B_1_003));
        findRemovedRows(e) => e.key == B_1_003;
        expect(
          stateManager.iterateAllRowAndGroup.where(findRemovedRows).length,
          0,
        );
      });

      test('B 그룹의 003, 004 을 삭제하면 B_1 과 함께 삭제 되어야 한다.', () {
        /// A - 1 - 001
        ///   - 2 - 002
        /// B - 1 - 003, 004
        ///   - 2 - 005
        final B = stateManager.refRows[1];
        final B_1 = B.type.group.children[0];
        final B_1_003 = B_1.type.group.children[0];
        final B_1_004 = B_1.type.group.children[1];

        expect(B.type.group.children.length, 2);
        expect(stateManager.iterateAllRowAndGroup.length, 11);

        stateManager.removeRows([B_1_003, B_1_004]);

        expect(B.type.group.children.length, 1);
        expect(stateManager.iterateAllRowAndGroup.length, 8);
        expect(B.type.group.children[0], isNot(B_1));
        findRemovedRows(e) =>
            e.key == B_1 || e.key == B_1_003 || e.key == B_1_004;
        expect(
          stateManager.iterateAllRowAndGroup.where(findRemovedRows).length,
          0,
        );
      });
    });
  });

  /// G100
  ///   - G110
  ///     - R111
  ///     - R112
  ///   - R120
  ///   - R130
  /// G200
  ///   - R210
  ///   - G220
  ///     - R221
  ///     - R222
  group('최대 3 뎁스로 그룹화 - PlutoRowGroupTreeDelegate', () {
    late List<PlutoColumn> columns;

    late List<PlutoRow> rows;

    late PlutoGridStateManager stateManager;

    Map<String, PlutoCell> createCell(String value) {
      return {
        'column1': PlutoCell(value: value),
        'column2': PlutoCell(value: ''),
        'column3': PlutoCell(value: ''),
        'column4': PlutoCell(value: ''),
        'column5': PlutoCell(value: ''),
      };
    }

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
        PlutoRow(
          cells: createCell('G100'),
          type: PlutoRowType.group(
            children: FilteredList(
              initialList: [
                PlutoRow(
                  cells: createCell('G110'),
                  type: PlutoRowType.group(
                    children: FilteredList(
                      initialList: [
                        PlutoRow(cells: createCell('R111')),
                        PlutoRow(cells: createCell('R112')),
                      ],
                    ),
                  ),
                ),
                PlutoRow(cells: createCell('R120')),
                PlutoRow(cells: createCell('R130')),
              ],
            ),
          ),
        ),
        PlutoRow(
          cells: createCell('G200'),
          type: PlutoRowType.group(
            children: FilteredList(
              initialList: [
                PlutoRow(cells: createCell('R210')),
                PlutoRow(
                  cells: createCell('G220'),
                  type: PlutoRowType.group(
                    children: FilteredList(
                      initialList: [
                        PlutoRow(cells: createCell('R221')),
                        PlutoRow(cells: createCell('R222')),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ];

      stateManager = createStateManager(columns: columns, rows: rows);

      stateManager.setRowGroup(
        PlutoRowGroupTreeDelegate(
          resolveColumnDepth: (column) => stateManager.columnIndex(column),
          showText: (cell) => cell.row.type.isNormal,
        ),
      );
    });

    test('hasRowGroups 가 true 를 리턴해야 한다.', () {
      expect(stateManager.hasRowGroups, true);
    });

    test('enabledRowGroups 가 true 를 리턴해야 한다.', () {
      expect(stateManager.enabledRowGroups, true);
    });

    test('rowGroupDelegate 가 PlutoRowGroupTreeDelegate 이어야 한다.', () {
      expect(stateManager.rowGroupDelegate is PlutoRowGroupTreeDelegate, true);
    });

    test('iterateMainRowGroup 가 2개 행을 리턴해야 한다.', () {
      expect(stateManager.iterateAllMainRowGroup.length, 2);
    });

    test('iterateRowGroup 가 4개 행을 리턴해야 한다.', () {
      expect(stateManager.iterateAllRowGroup.length, 4);
    });

    test('iterateRowAndGroup 가 11개 행을 리턴해야 한다.', () {
      expect(stateManager.iterateAllRowAndGroup.length, 11);
    });

    test('iterateRow 가 7개 행을 리턴해야 한다.', () {
      expect(stateManager.iterateAllRow.length, 7);
    });

    test('refRows 의 두개의 행이 isMainRow true 를 반환해야 한다.', () {
      expect(stateManager.refRows.length, 2);
      expect(stateManager.isMainRow(stateManager.refRows[0]), true);
      expect(stateManager.isMainRow(stateManager.refRows[1]), true);
    });

    test('계층에 맞게 parent 가 설정 되어야 한다.', () {
      final G100 = stateManager.refRows[0];
      final G100_CHILDREN = G100.type.group.children;
      expect(G100.parent, null);
      expect(G100_CHILDREN.length, 3);
      expect(G100_CHILDREN.length, 3);
      expect(G100_CHILDREN[0].parent, G100);
      expect(G100_CHILDREN[1].parent, G100);
      expect(G100_CHILDREN[2].parent, G100);

      final G110 = G100_CHILDREN[0];
      final G110_CHILDREN = G110.type.group.children;
      expect(G110_CHILDREN.length, 2);
      expect(G110_CHILDREN[0].parent, G110);
      expect(G110_CHILDREN[0].parent?.parent, G100);
      expect(G110_CHILDREN[1].parent, G110);
      expect(G110_CHILDREN[1].parent?.parent, G100);

      final G200 = stateManager.refRows[1];
      expect(G200.parent, null);
      expect(G200.type.group.children.length, 2);
      expect(G200.type.group.children[0].parent, G200);
      expect(G200.type.group.children[1].parent, G200);

      final G220 = G200.type.group.children[1];
      final G220_CHILDREN = G220.type.group.children;
      expect(G220_CHILDREN.length, 2);
      expect(G220_CHILDREN[0].parent, G220);
      expect(G220_CHILDREN[0].parent?.parent, G200);
      expect(G220_CHILDREN[1].parent, G220);
      expect(G220_CHILDREN[1].parent?.parent, G200);
    });

    test('전체 컬럼을 지우고 새 컬럼을 추가하면 기존 행의 셀이 추가 되어야 한다.', () {
      stateManager.removeColumns(columns);

      expect(stateManager.refColumns.originalList.length, 0);
      expect(stateManager.refRows.originalList.length, 2);

      for (final row in stateManager.refRows.originalList) {
        expect(row.parent, null);
        expect(row.cells['column1'], null);
        expect(row.cells['column2'], null);
        expect(row.cells['column3'], null);
        expect(row.cells['column4'], null);
        expect(row.cells['column5'], null);
      }

      stateManager.insertColumns(0, [
        PlutoColumn(
          title: 'column6',
          field: 'column6',
          type: PlutoColumnType.text(),
        ),
      ]);

      expect(stateManager.refColumns.originalList.length, 1);
      expect(stateManager.refRows.originalList.length, 2);

      final rowAndGroup = stateManager.iterateAllRowAndGroup.toList();

      expect(rowAndGroup.length, 11);
      for (final row in rowAndGroup) {
        expect(row.cells['column1'], null);
        expect(row.cells['column2'], null);
        expect(row.cells['column3'], null);
        expect(row.cells['column4'], null);
        expect(row.cells['column5'], null);
        expect(row.cells['column6'], isNot(null));
      }
    });

    /// G300
    ///   - G310
    ///   - G320
    ///     - G321
    ///     - G322
    /// G100
    ///   - G110
    ///     - R111
    ///     - R112
    ///   - R120
    ///   - R130
    /// G200
    ///   - R210
    ///   - G220
    ///     - R221
    ///     - R222
    group('insertAll', () {
      group('0번에 3뎁스의 그룹 추가.', () {
        setUp(() {
          stateManager.insertRows(0, [
            PlutoRow(
              cells: createCell('G300'),
              type: PlutoRowType.group(
                children: FilteredList(initialList: [
                  PlutoRow(cells: createCell('G310')),
                  PlutoRow(
                    cells: createCell('G320'),
                    type: PlutoRowType.group(
                      children: FilteredList(initialList: [
                        PlutoRow(cells: createCell('G321')),
                        PlutoRow(cells: createCell('G322')),
                      ]),
                    ),
                  ),
                ]),
              ),
            ),
          ]);
        });

        test('첫번째 행에 G300 이 추가 되어야 한다.', () {
          expect(stateManager.refRows[0].cells['column1']!.value, 'G300');
          expect(stateManager.refRows[1].cells['column1']!.value, 'G100');
          expect(stateManager.refRows[2].cells['column1']!.value, 'G200');
        });

        test('추가 된 행들의 parent 가 설정 되어야 한다.', () {
          final G300 = stateManager.refRows[0];
          final G310 = G300.type.group.children[0];
          final G320 = G300.type.group.children[1];
          final G321 = G320.type.group.children[0];
          final G322 = G320.type.group.children[1];

          expect(G310.parent, G300);
          expect(G320.parent, G300);
          expect(G321.parent, G320);
          expect(G321.parent?.parent, G300);
          expect(G322.parent, G320);
          expect(G322.parent?.parent, G300);
        });

        test('추가 된 G300의 sortIdx 가 설정 되어야 한다.', () {
          final G300 = stateManager.refRows[0];
          final G100 = stateManager.refRows[1];
          final G200 = stateManager.refRows[2];
          expect(G300.sortIdx, 0);
          expect(G100.sortIdx, 1);
          expect(G200.sortIdx, 2);
        });

        test('G300 을 토글 하면 G310,G320 이 refRows 에 추가 되어야 한다.', () {
          final G300 = stateManager.refRows[0];
          expect(G300.cells['column1']!.value, 'G300');

          stateManager.toggleExpandedRowGroup(rowGroup: G300);

          expect(stateManager.refRows[0].cells['column1']!.value, 'G300');
          expect(stateManager.refRows[1].cells['column1']!.value, 'G310');
          expect(stateManager.refRows[2].cells['column1']!.value, 'G320');
        });

        test(
          'G300 을 토글 후 1번 인덱스 G310에 G400을 추가하면, '
          'G400 은 G310 의 부모인 G300 의 자식이 되어야 한다.',
          () {
            final G300 = stateManager.refRows[0];
            stateManager.toggleExpandedRowGroup(rowGroup: G300);

            final addedRow = PlutoRow(cells: createCell('G400'));

            stateManager.insertRows(1, [addedRow]);

            expect(stateManager.refRows[0].cells['column1']!.value, 'G300');
            expect(stateManager.refRows[1].cells['column1']!.value, 'G400');
            expect(stateManager.refRows[2].cells['column1']!.value, 'G310');
            expect(stateManager.refRows[3].cells['column1']!.value, 'G320');
            expect(stateManager.refRows[4].cells['column1']!.value, 'G100');
            expect(stateManager.refRows[5].cells['column1']!.value, 'G200');

            final G400 = stateManager.refRows[1];
            expect(G400.parent, G300);

            expect(G300.type.group.children[0].sortIdx, 0);
            expect(G300.type.group.children[0], G400);
            expect(G300.type.group.children[1].sortIdx, 1);
            expect(G300.type.group.children[1].cells['column1']!.value, 'G310');
            expect(G300.type.group.children[2].sortIdx, 2);
            expect(G300.type.group.children[2].cells['column1']!.value, 'G320');

            /// 다시 300 을 접으면 다음 레벨인 G100, G200 이 위치해야 한다.
            stateManager.toggleExpandedRowGroup(rowGroup: G300);
            expect(stateManager.refRows[0].cells['column1']!.value, 'G300');
            expect(stateManager.refRows[1].cells['column1']!.value, 'G100');
            expect(stateManager.refRows[2].cells['column1']!.value, 'G200');
          },
        );

        test(
          'G200, G220 을 토글 후 7번 인덱스에 G400 추가하면 마지막 그룹으로 추가 되어야 한다.',
          () {
            final G200 = stateManager.refRows[2];
            final G220 = G200.type.group.children[1];
            stateManager.toggleExpandedRowGroup(rowGroup: G200);
            stateManager.toggleExpandedRowGroup(rowGroup: G220);

            final addedRow = PlutoRow(cells: createCell('G400'));

            stateManager.insertRows(7, [addedRow]);

            expect(stateManager.refRows[0].cells['column1']!.value, 'G300');
            expect(stateManager.refRows[1].cells['column1']!.value, 'G100');
            expect(stateManager.refRows[2].cells['column1']!.value, 'G200');
            expect(stateManager.refRows[3].cells['column1']!.value, 'R210');
            expect(stateManager.refRows[4].cells['column1']!.value, 'G220');
            expect(stateManager.refRows[5].cells['column1']!.value, 'R221');
            expect(stateManager.refRows[6].cells['column1']!.value, 'R222');
            expect(stateManager.refRows[7].cells['column1']!.value, 'G400');
          },
        );
      });
    });
  });
}
