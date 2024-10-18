import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../matcher/pluto_object_matcher.dart';

void main() {
  group('fromJson', () {
    test('단일 행 text.', () {
      final json = {
        'column1': 'value1',
        'column2': 'value2',
        'column3': 'value3',
      };

      expect(
        PlutoRow.fromJson(json),
        PlutoObjectMatcher<PlutoRow>(rule: (row) {
          return row.cells.length == 3 &&
              row.cells['column1']!.value == 'value1' &&
              row.cells['column2']!.value == 'value2' &&
              row.cells['column3']!.value == 'value3' &&
              row.type.isNormal;
        }),
      );
    });

    test('단일 행 number.', () {
      final json = {
        'column1': 123,
        'column2': 3.12,
        'column3': -123,
      };

      expect(
        PlutoRow.fromJson(json),
        PlutoObjectMatcher<PlutoRow>(rule: (row) {
          return row.cells.length == 3 &&
              row.cells['column1']!.value == 123 &&
              row.cells['column2']!.value == 3.12 &&
              row.cells['column3']!.value == -123 &&
              row.type.isNormal;
        }),
      );
    });

    test('그룹행 1뎁스.', () {
      final json = {
        'column1': 'group value1',
        'column2': 'group value2',
        'column3': 'group value3',
        'children': [
          {
            'column1': 'child1 value1',
            'column2': 'child1 value2',
            'column3': 'child1 value3',
          },
          {
            'column1': 'child2 value1',
            'column2': 'child2 value2',
            'column3': 'child2 value3',
          },
        ],
      };

      expect(
        PlutoRow.fromJson(json, childrenField: 'children'),
        PlutoObjectMatcher<PlutoRow>(rule: (row) {
          final bool checkCell = row.cells.length == 3 &&
              row.cells['column1']!.value == 'group value1' &&
              row.cells['column2']!.value == 'group value2' &&
              row.cells['column3']!.value == 'group value3';

          final bool checkChild1 = row.type.group.children[0].type.isNormal &&
              row.type.group.children[0].cells['column1']!.value ==
                  'child1 value1' &&
              row.type.group.children[0].cells['column2']!.value ==
                  'child1 value2' &&
              row.type.group.children[0].cells['column3']!.value ==
                  'child1 value3';

          final bool checkChild2 = row.type.group.children[1].type.isNormal &&
              row.type.group.children[1].cells['column1']!.value ==
                  'child2 value1' &&
              row.type.group.children[1].cells['column2']!.value ==
                  'child2 value2' &&
              row.type.group.children[1].cells['column3']!.value ==
                  'child2 value3';

          return checkCell &&
              row.type.isGroup &&
              row.type.group.children.length == 2 &&
              checkChild1 &&
              checkChild2;
        }),
      );
    });

    test('그룹행 1뎁스. childrenField 가 items', () {
      final json = {
        'column1': 'group value1',
        'column2': 'group value2',
        'column3': 'group value3',
        'items': [
          {
            'column1': 'child1 value1',
            'column2': 'child1 value2',
            'column3': 'child1 value3',
          },
          {
            'column1': 'child2 value1',
            'column2': 'child2 value2',
            'column3': 'child2 value3',
          },
        ],
      };

      expect(
        PlutoRow.fromJson(json, childrenField: 'items'),
        PlutoObjectMatcher<PlutoRow>(rule: (row) {
          final bool checkCell = row.cells.length == 3 &&
              row.cells['column1']!.value == 'group value1' &&
              row.cells['column2']!.value == 'group value2' &&
              row.cells['column3']!.value == 'group value3';

          final bool checkChild1 = row.type.group.children[0].type.isNormal &&
              row.type.group.children[0].cells['column1']!.value ==
                  'child1 value1' &&
              row.type.group.children[0].cells['column2']!.value ==
                  'child1 value2' &&
              row.type.group.children[0].cells['column3']!.value ==
                  'child1 value3';

          final bool checkChild2 = row.type.group.children[1].type.isNormal &&
              row.type.group.children[1].cells['column1']!.value ==
                  'child2 value1' &&
              row.type.group.children[1].cells['column2']!.value ==
                  'child2 value2' &&
              row.type.group.children[1].cells['column3']!.value ==
                  'child2 value3';

          return checkCell &&
              row.type.isGroup &&
              row.type.group.children.length == 2 &&
              checkChild1 &&
              checkChild2;
        }),
      );
    });

    test('그룹행 1뎁스. childrenField 가 null 이면 type 이 normal 이어야 한다.', () {
      final json = {
        'column1': 'group value1',
        'column2': 'group value2',
        'column3': 'group value3',
        'children': [
          {
            'column1': 'child1 value1',
            'column2': 'child1 value2',
            'column3': 'child1 value3',
          },
          {
            'column1': 'child2 value1',
            'column2': 'child2 value2',
            'column3': 'child2 value3',
          },
        ],
      };

      expect(
        PlutoRow.fromJson(json, childrenField: null),
        PlutoObjectMatcher<PlutoRow>(rule: (row) {
          return row.cells.length == 4 &&
              row.cells['column1']!.value == 'group value1' &&
              row.cells['column2']!.value == 'group value2' &&
              row.cells['column3']!.value == 'group value3' &&
              row.cells['children']!.value is List<Map<String, String>> &&
              row.type.isNormal;
        }),
      );
    });

    test('그룹행 2뎁스.', () {
      final json = {
        'column1': 'group value1',
        'column2': 'group value2',
        'column3': 'group value3',
        'children': [
          {
            'column1': 'child1 value1',
            'column2': 'child1 value2',
            'column3': 'child1 value3',
            'children': [
              {
                'column1': 'child1-1 value1',
                'column2': 'child1-1 value2',
                'column3': 'child1-1 value3',
              },
              {
                'column1': 'child1-2 value1',
                'column2': 'child1-2 value2',
                'column3': 'child1-2 value3',
              },
            ],
          },
          {
            'column1': 'child2 value1',
            'column2': 'child2 value2',
            'column3': 'child2 value3',
          },
        ],
      };

      expect(
        PlutoRow.fromJson(json, childrenField: 'children'),
        PlutoObjectMatcher<PlutoRow>(rule: (row) {
          final bool checkCell = row.cells.length == 3 &&
              row.cells['column1']!.value == 'group value1' &&
              row.cells['column2']!.value == 'group value2' &&
              row.cells['column3']!.value == 'group value3';

          final bool checkChild1 = row.type.group.children[0].type.isGroup &&
              row.type.group.children[0].cells['column1']!.value ==
                  'child1 value1' &&
              row.type.group.children[0].cells['column2']!.value ==
                  'child1 value2' &&
              row.type.group.children[0].cells['column3']!.value ==
                  'child1 value3';

          final bool checkChild1_1 =
              row.type.group.children[0].type.group.children[0].type.isNormal &&
                  row.type.group.children[0].type.group.children[0]
                          .cells['column1']!.value ==
                      'child1-1 value1' &&
                  row.type.group.children[0].type.group.children[0]
                          .cells['column2']!.value ==
                      'child1-1 value2' &&
                  row.type.group.children[0].type.group.children[0]
                          .cells['column3']!.value ==
                      'child1-1 value3';

          final checkChild1_2 =
              row.type.group.children[0].type.group.children[1].type.isNormal &&
                  row.type.group.children[0].type.group.children[1]
                          .cells['column1']!.value ==
                      'child1-2 value1' &&
                  row.type.group.children[0].type.group.children[1]
                          .cells['column2']!.value ==
                      'child1-2 value2' &&
                  row.type.group.children[0].type.group.children[1]
                          .cells['column3']!.value ==
                      'child1-2 value3';

          final checkChild2 = row.type.group.children[1].type.isNormal &&
              row.type.group.children[1].cells['column1']!.value ==
                  'child2 value1' &&
              row.type.group.children[1].cells['column2']!.value ==
                  'child2 value2' &&
              row.type.group.children[1].cells['column3']!.value ==
                  'child2 value3';

          return checkCell &&
              row.type.isGroup &&
              row.type.group.children.length == 2 &&
              checkChild1 &&
              row.type.group.children[0].type.group.children.length == 2 &&
              checkChild1_1 &&
              checkChild1_2 &&
              checkChild2;
        }),
      );
    });
  });

  group('toJson', () {
    test('단일 행 text.', () {
      final PlutoRow row = PlutoRow(cells: {
        'column1': PlutoCell(value: 'value1'),
        'column2': PlutoCell(value: 'value2'),
        'column3': PlutoCell(value: 'value3'),
      });

      expect(row.toJson(), {
        'column1': 'value1',
        'column2': 'value2',
        'column3': 'value3',
      });
    });

    test('단일 행 number.', () {
      final PlutoRow row = PlutoRow(cells: {
        'column1': PlutoCell(value: 123),
        'column2': PlutoCell(value: 3.12),
        'column3': PlutoCell(value: -123),
      });

      expect(row.toJson(), {
        'column1': 123,
        'column2': 3.12,
        'column3': -123,
      });
    });

    test('그룹행 1뎁스.', () {
      final PlutoRow row = PlutoRow(
        cells: {
          'column1': PlutoCell(value: 'group value1'),
          'column2': PlutoCell(value: 'group value2'),
          'column3': PlutoCell(value: 'group value3'),
        },
        type: PlutoRowType.group(
          children: FilteredList(initialList: [
            PlutoRow(
              cells: {
                'column1': PlutoCell(value: 'child1 value1'),
                'column2': PlutoCell(value: 'child1 value2'),
                'column3': PlutoCell(value: 'child1 value3'),
              },
            ),
            PlutoRow(
              cells: {
                'column1': PlutoCell(value: 'child2 value1'),
                'column2': PlutoCell(value: 'child2 value2'),
                'column3': PlutoCell(value: 'child2 value3'),
              },
            ),
          ]),
        ),
      );

      expect(row.toJson(), {
        'column1': 'group value1',
        'column2': 'group value2',
        'column3': 'group value3',
        'children': [
          {
            'column1': 'child1 value1',
            'column2': 'child1 value2',
            'column3': 'child1 value3',
          },
          {
            'column1': 'child2 value1',
            'column2': 'child2 value2',
            'column3': 'child2 value3',
          },
        ],
      });
    });

    test('그룹행 1뎁스. includeChildren 가 false 면 children 이 포함 되지 않아야 한다.', () {
      final PlutoRow row = PlutoRow(
        cells: {
          'column1': PlutoCell(value: 'group value1'),
          'column2': PlutoCell(value: 'group value2'),
          'column3': PlutoCell(value: 'group value3'),
        },
        type: PlutoRowType.group(
          children: FilteredList(initialList: [
            PlutoRow(
              cells: {
                'column1': PlutoCell(value: 'child1 value1'),
                'column2': PlutoCell(value: 'child1 value2'),
                'column3': PlutoCell(value: 'child1 value3'),
              },
            ),
            PlutoRow(
              cells: {
                'column1': PlutoCell(value: 'child2 value1'),
                'column2': PlutoCell(value: 'child2 value2'),
                'column3': PlutoCell(value: 'child2 value3'),
              },
            ),
          ]),
        ),
      );

      expect(row.toJson(includeChildren: false), {
        'column1': 'group value1',
        'column2': 'group value2',
        'column3': 'group value3',
      });
    });

    test('그룹행 2뎁스.', () {
      final PlutoRow row = PlutoRow(
        cells: {
          'column1': PlutoCell(value: 'group value1'),
          'column2': PlutoCell(value: 'group value2'),
          'column3': PlutoCell(value: 'group value3'),
        },
        type: PlutoRowType.group(
          children: FilteredList(initialList: [
            PlutoRow(
              cells: {
                'column1': PlutoCell(value: 'child1 value1'),
                'column2': PlutoCell(value: 'child1 value2'),
                'column3': PlutoCell(value: 'child1 value3'),
              },
              type: PlutoRowType.group(
                children: FilteredList(initialList: [
                  PlutoRow(
                    cells: {
                      'column1': PlutoCell(value: 'child1-1 value1'),
                      'column2': PlutoCell(value: 'child1-1 value2'),
                      'column3': PlutoCell(value: 'child1-1 value3'),
                    },
                  ),
                  PlutoRow(
                    cells: {
                      'column1': PlutoCell(value: 'child1-2 value1'),
                      'column2': PlutoCell(value: 'child1-2 value2'),
                      'column3': PlutoCell(value: 'child1-2 value3'),
                    },
                  ),
                ]),
              ),
            ),
            PlutoRow(
              cells: {
                'column1': PlutoCell(value: 'child2 value1'),
                'column2': PlutoCell(value: 'child2 value2'),
                'column3': PlutoCell(value: 'child2 value3'),
              },
            ),
          ]),
        ),
      );

      expect(row.toJson(), {
        'column1': 'group value1',
        'column2': 'group value2',
        'column3': 'group value3',
        'children': [
          {
            'column1': 'child1 value1',
            'column2': 'child1 value2',
            'column3': 'child1 value3',
            'children': [
              {
                'column1': 'child1-1 value1',
                'column2': 'child1-1 value2',
                'column3': 'child1-1 value3',
              },
              {
                'column1': 'child1-2 value1',
                'column2': 'child1-2 value2',
                'column3': 'child1-2 value3',
              },
            ],
          },
          {
            'column1': 'child2 value1',
            'column2': 'child2 value2',
            'column3': 'child2 value3',
          },
        ],
      });
    });

    test('그룹행 2뎁스. childrenField 가 items 면 자식 필드가 items 로 리턴 되어야 한다.', () {
      final PlutoRow row = PlutoRow(
        cells: {
          'column1': PlutoCell(value: 'group value1'),
          'column2': PlutoCell(value: 'group value2'),
          'column3': PlutoCell(value: 'group value3'),
        },
        type: PlutoRowType.group(
          children: FilteredList(initialList: [
            PlutoRow(
              cells: {
                'column1': PlutoCell(value: 'child1 value1'),
                'column2': PlutoCell(value: 'child1 value2'),
                'column3': PlutoCell(value: 'child1 value3'),
              },
              type: PlutoRowType.group(
                children: FilteredList(initialList: [
                  PlutoRow(
                    cells: {
                      'column1': PlutoCell(value: 'child1-1 value1'),
                      'column2': PlutoCell(value: 'child1-1 value2'),
                      'column3': PlutoCell(value: 'child1-1 value3'),
                    },
                  ),
                  PlutoRow(
                    cells: {
                      'column1': PlutoCell(value: 'child1-2 value1'),
                      'column2': PlutoCell(value: 'child1-2 value2'),
                      'column3': PlutoCell(value: 'child1-2 value3'),
                    },
                  ),
                ]),
              ),
            ),
            PlutoRow(
              cells: {
                'column1': PlutoCell(value: 'child2 value1'),
                'column2': PlutoCell(value: 'child2 value2'),
                'column3': PlutoCell(value: 'child2 value3'),
              },
            ),
          ]),
        ),
      );

      expect(row.toJson(childrenField: 'items'), {
        'column1': 'group value1',
        'column2': 'group value2',
        'column3': 'group value3',
        'items': [
          {
            'column1': 'child1 value1',
            'column2': 'child1 value2',
            'column3': 'child1 value3',
            'items': [
              {
                'column1': 'child1-1 value1',
                'column2': 'child1-1 value2',
                'column3': 'child1-1 value3',
              },
              {
                'column1': 'child1-2 value1',
                'column2': 'child1-2 value2',
                'column3': 'child1-2 value3',
              },
            ],
          },
          {
            'column1': 'child2 value1',
            'column2': 'child2 value2',
            'column3': 'child2 value3',
          },
        ],
      });
    });
  });
}
