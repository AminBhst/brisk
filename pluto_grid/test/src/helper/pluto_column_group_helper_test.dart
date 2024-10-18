import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../helper/column_helper.dart';

void main() {
  group('exists', () {
    test('field 가 columnGroup.fields 리스트에 존재하면 true 를 반환해야 한다.', () {
      const title = 'title';

      const field = 'DUMMY_FIELD';

      final fields = ['DUMMY_FIELD'];

      final columnGroup = PlutoColumnGroup(
        title: title,
        fields: fields,
      );

      expect(
        PlutoColumnGroupHelper.exists(field: field, columnGroup: columnGroup),
        true,
      );
    });

    test('field 가 columnGroup.fields 리스트에 존재하지 않으면 false 를 반환해야 한다.', () {
      const title = 'title';

      const field = 'NON_EXISTS_DUMMY_FIELD';

      final fields = ['DUMMY_FIELD'];

      final columnGroup = PlutoColumnGroup(
        title: title,
        fields: fields,
      );

      expect(
        PlutoColumnGroupHelper.exists(field: field, columnGroup: columnGroup),
        false,
      );
    });

    test('field 가 columnGroup.children 리스트에 존재하면 true 를 반환해야 한다.', () {
      const title = 'title';

      const field = 'DUMMY_FIELD';

      final children = [
        PlutoColumnGroup(title: 'title', fields: ['DUMMY_FIELD']),
      ];

      final columnGroup = PlutoColumnGroup(
        title: title,
        children: children,
      );

      expect(
        PlutoColumnGroupHelper.exists(field: field, columnGroup: columnGroup),
        true,
      );
    });

    test('field 가 columnGroup.children 리스트에 존재하지 않으면 false 를 반환해야 한다.', () {
      const title = 'title';

      const field = 'NON_EXISTS_DUMMY_FIELD';

      final children = [
        PlutoColumnGroup(title: 'title', fields: ['DUMMY_FIELD']),
      ];

      final columnGroup = PlutoColumnGroup(
        title: title,
        children: children,
      );

      expect(
        PlutoColumnGroupHelper.exists(field: field, columnGroup: columnGroup),
        false,
      );
    });

    test('field 가 columnGroup.children 의 2뎁스 하위에 존재하면 true 를 반환해야 한다.', () {
      const title = 'title';

      const field = 'DUMMY_FIELD';

      final children = [
        PlutoColumnGroup(title: 'title', children: [
          PlutoColumnGroup(title: 'title', fields: ['DUMMY_FIELD']),
        ]),
      ];

      final columnGroup = PlutoColumnGroup(
        title: title,
        children: children,
      );

      expect(
        PlutoColumnGroupHelper.exists(field: field, columnGroup: columnGroup),
        true,
      );
    });
  });

  group('existsFromList', () {
    test('column1 필드가 리스트에 존재하면  true 를 리턴해야 한다.', () {
      const field = 'column1';

      final columnGroupList = [
        PlutoColumnGroup(title: 'title', fields: ['column1', 'column2']),
        PlutoColumnGroup(title: 'title', fields: ['column3', 'column4']),
        PlutoColumnGroup(title: 'title', fields: ['column5', 'column6']),
      ];

      expect(
        PlutoColumnGroupHelper.existsFromList(
          field: field,
          columnGroupList: columnGroupList,
        ),
        true,
      );
    });

    test('non_exists 필드가 리스트에 존재하지 않으면 false 를 리턴해야 한다.', () {
      const field = 'non_exists';

      final columnGroupList = [
        PlutoColumnGroup(title: 'title', fields: ['column1', 'column2']),
        PlutoColumnGroup(title: 'title', fields: ['column3', 'column4']),
        PlutoColumnGroup(title: 'title', fields: ['column5', 'column6']),
      ];

      expect(
        PlutoColumnGroupHelper.existsFromList(
          field: field,
          columnGroupList: columnGroupList,
        ),
        false,
      );
    });
  });

  group('getGroupIfExistsFromList', () {
    test('column1 필드가 그룹에 존재하면 해당 그룹이 리턴 되어야 한다.', () {
      const field = 'column1';

      final columnGroup = PlutoColumnGroup(
        title: 'title',
        fields: ['column1', 'column2'],
      );

      final columnGroupList = [
        columnGroup,
        PlutoColumnGroup(title: 'title', fields: ['column3', 'column4']),
        PlutoColumnGroup(title: 'title', fields: ['column5', 'column6']),
      ];

      expect(
        PlutoColumnGroupHelper.getGroupIfExistsFromList(
          field: field,
          columnGroupList: columnGroupList,
        ),
        columnGroup,
      );
    });

    test('non_exists 필드가 그룹에 존재하지 않으면 null 이 리턴 되어야 한다.', () {
      const field = 'non_exists';

      final columnGroupList = [
        PlutoColumnGroup(title: 'title', fields: ['column1', 'column2']),
        PlutoColumnGroup(title: 'title', fields: ['column3', 'column4']),
        PlutoColumnGroup(title: 'title', fields: ['column5', 'column6']),
      ];

      expect(
        PlutoColumnGroupHelper.getGroupIfExistsFromList(
          field: field,
          columnGroupList: columnGroupList,
        ),
        null,
      );
    });
  });

  group('separateLinkedGroup', () {
    test('columnGroupList 가 empty 면 빈 리스트를 리턴해야 한다.', () {
      final columnGroupList = <PlutoColumnGroup>[];

      final columns = ColumnHelper.textColumn('column', count: 6, start: 1);

      expect(
        PlutoColumnGroupHelper.separateLinkedGroup(
          columnGroupList: columnGroupList,
          columns: columns,
        ),
        isEmpty,
      );
    });

    test('columns 가 empty 면 빈 리스트를 리턴해야 한다.', () {
      final columnGroupList = <PlutoColumnGroup>[
        PlutoColumnGroup(title: 'title', fields: ['column1', 'column2']),
        PlutoColumnGroup(title: 'title', fields: ['column3', 'column4']),
        PlutoColumnGroup(title: 'title', fields: ['column5', 'column6']),
      ];

      final columns = <PlutoColumn>[];

      expect(
        PlutoColumnGroupHelper.separateLinkedGroup(
          columnGroupList: columnGroupList,
          columns: columns,
        ),
        isEmpty,
      );
    });

    test(
      'columns 가 [column1, column2, column3, column4, column5, column6] 이면, '
      '3개의 PlutoColumnGroupPair 를 리턴해야 한다.',
      () {
        final columnGroupList = <PlutoColumnGroup>[
          PlutoColumnGroup(title: 'title', fields: ['column1', 'column2']),
          PlutoColumnGroup(title: 'title', fields: ['column3', 'column4']),
          PlutoColumnGroup(title: 'title', fields: ['column5', 'column6']),
        ];

        final columns = ColumnHelper.textColumn('column', count: 6, start: 1);

        final result = PlutoColumnGroupHelper.separateLinkedGroup(
          columnGroupList: columnGroupList,
          columns: columns,
        );

        expect(result.length, 3);

        expect(result[0].group, same(columnGroupList[0]));
        expect(result[1].group, same(columnGroupList[1]));
        expect(result[2].group, same(columnGroupList[2]));

        expect(result[0].columns.length, 2);
        expect(result[1].columns.length, 2);
        expect(result[2].columns.length, 2);

        expect(
          result[0].columns,
          containsAllInOrder(<PlutoColumn>[columns[0], columns[1]]),
        );
        expect(
          result[1].columns,
          containsAllInOrder(<PlutoColumn>[columns[2], columns[3]]),
        );
        expect(
          result[2].columns,
          containsAllInOrder(<PlutoColumn>[columns[4], columns[5]]),
        );
      },
    );

    test(
      'columns 가 [column1, column3, column4, column2, column5, column6] 이면, '
      '4개의 PlutoColumnGroupPair '
      '(column1), (column3, column4), (column2), (column5, column6) '
      '를 리턴해야 한다.',
      () {
        final columnGroupList = <PlutoColumnGroup>[
          PlutoColumnGroup(title: 'title', fields: ['column1', 'column2']),
          PlutoColumnGroup(title: 'title', fields: ['column3', 'column4']),
          PlutoColumnGroup(title: 'title', fields: ['column5', 'column6']),
        ];

        final columns = [
          ...ColumnHelper.textColumn('column', count: 1, start: 1),
          ...ColumnHelper.textColumn('column', count: 1, start: 3),
          ...ColumnHelper.textColumn('column', count: 1, start: 4),
          ...ColumnHelper.textColumn('column', count: 1, start: 2),
          ...ColumnHelper.textColumn('column', count: 1, start: 5),
          ...ColumnHelper.textColumn('column', count: 1, start: 6),
        ];

        final result = PlutoColumnGroupHelper.separateLinkedGroup(
          columnGroupList: columnGroupList,
          columns: columns,
        );

        expect(result.length, 4);

        expect(result[0].group, same(columnGroupList[0]));
        expect(result[1].group, same(columnGroupList[1]));
        expect(result[2].group, same(columnGroupList[0]));
        expect(result[3].group, same(columnGroupList[2]));

        expect(result[0].columns.length, 1);
        expect(result[1].columns.length, 2);
        expect(result[2].columns.length, 1);
        expect(result[3].columns.length, 2);

        expect(
          result[0].columns,
          containsAllInOrder(<PlutoColumn>[columns[0]]),
        );
        expect(
          result[1].columns,
          containsAllInOrder(<PlutoColumn>[columns[1], columns[2]]),
        );
        expect(
          result[2].columns,
          containsAllInOrder(<PlutoColumn>[columns[3]]),
        );
        expect(
          result[3].columns,
          containsAllInOrder(<PlutoColumn>[columns[4], columns[5]]),
        );
      },
    );

    test(
      'columns 가 [column1, column2, column3, column4, column5, column6] 이고, '
      '그룹에 column6 이 없으면 column6이 새 그룹에 포함되어 4개의 그룹을 리턴해야 한다.',
      () {
        final columnGroupList = <PlutoColumnGroup>[
          PlutoColumnGroup(title: 'title', fields: ['column1', 'column2']),
          PlutoColumnGroup(title: 'title', fields: ['column3', 'column4']),
          PlutoColumnGroup(title: 'title', fields: ['column5']),
        ];

        final columns = ColumnHelper.textColumn('column', count: 6, start: 1);

        final result = PlutoColumnGroupHelper.separateLinkedGroup(
          columnGroupList: columnGroupList,
          columns: columns,
        );

        expect(result.length, 4);

        expect(result[0].group.expandedColumn, false);
        expect(result[1].group.expandedColumn, false);
        expect(result[2].group.expandedColumn, false);

        expect(result[3].group.expandedColumn, true);
        expect(result[3].columns, contains(columns[5]));
      },
    );
  });

  group('maxDepth', () {
    test('그룹의 깊이가 1인 경우 1을 리턴해야 한다.', () {
      const expectedDepth = 1;

      final columnGroupList = [
        PlutoColumnGroup(title: 'title', fields: ['column1', 'column2']),
        PlutoColumnGroup(title: 'title', fields: ['column3', 'column4']),
        PlutoColumnGroup(title: 'title', fields: ['column5', 'column6']),
      ];

      expect(
        PlutoColumnGroupHelper.maxDepth(columnGroupList: columnGroupList),
        expectedDepth,
      );
    });

    test('그룹의 깊이가 2인 경우 2를 리턴해야 한다.', () {
      const expectedDepth = 2;

      final columnGroupList = [
        PlutoColumnGroup(
          title: 'title',
          children: [
            PlutoColumnGroup(title: 'title', fields: ['column1']),
            PlutoColumnGroup(title: 'title', fields: ['column2']),
          ],
        ),
        PlutoColumnGroup(title: 'title', fields: ['column3', 'column4']),
        PlutoColumnGroup(title: 'title', fields: ['column5', 'column6']),
      ];

      expect(
        PlutoColumnGroupHelper.maxDepth(columnGroupList: columnGroupList),
        expectedDepth,
      );
    });

    test('그룹의 깊이가 3인 경우 3를 리턴해야 한다.', () {
      const expectedDepth = 3;

      final columnGroupList = [
        PlutoColumnGroup(
          title: 'title',
          children: [
            PlutoColumnGroup(title: 'title', fields: ['column1']),
            PlutoColumnGroup(
              title: 'title',
              children: [
                PlutoColumnGroup(title: 'title', fields: ['column2']),
                PlutoColumnGroup(title: 'title', fields: ['column3']),
              ],
            ),
          ],
        ),
        PlutoColumnGroup(title: 'title', fields: ['column4']),
        PlutoColumnGroup(title: 'title', fields: ['column5', 'column6']),
      ];

      expect(
        PlutoColumnGroupHelper.maxDepth(columnGroupList: columnGroupList),
        expectedDepth,
      );
    });

    test('그룹의 깊이가 3인 경우 3를 리턴해야 한다.', () {
      const expectedDepth = 3;

      final columnGroupList = [
        PlutoColumnGroup(
          title: 'title',
          children: [
            PlutoColumnGroup(
              title: 'title',
              children: [
                PlutoColumnGroup(title: 'title', fields: ['column2']),
                PlutoColumnGroup(title: 'title', fields: ['column3']),
              ],
            ),
            PlutoColumnGroup(title: 'title', fields: ['column1']),
          ],
        ),
        PlutoColumnGroup(title: 'title', fields: ['column4']),
        PlutoColumnGroup(title: 'title', fields: ['column5', 'column6']),
      ];

      expect(
        PlutoColumnGroupHelper.maxDepth(columnGroupList: columnGroupList),
        expectedDepth,
      );
    });

    test('그룹의 깊이가 4인 경우 4를 리턴해야 한다.', () {
      const expectedDepth = 4;

      final columnGroupList = [
        PlutoColumnGroup(
          title: 'title',
          children: [
            PlutoColumnGroup(
              title: 'title',
              children: [
                PlutoColumnGroup(title: 'title', fields: ['column2']),
                PlutoColumnGroup(
                  title: 'title',
                  children: [
                    PlutoColumnGroup(title: 'title', fields: ['column3']),
                    PlutoColumnGroup(title: 'title', fields: ['column5']),
                  ],
                ),
              ],
            ),
            PlutoColumnGroup(title: 'title', fields: ['column1']),
          ],
        ),
        PlutoColumnGroup(title: 'title', fields: ['column4']),
        PlutoColumnGroup(title: 'title', fields: ['column6']),
      ];

      expect(
        PlutoColumnGroupHelper.maxDepth(columnGroupList: columnGroupList),
        expectedDepth,
      );
    });

    test('그룹의 깊이가 5인 경우 5를 리턴해야 한다.', () {
      const expectedDepth = 5;

      final columnGroupList = [
        PlutoColumnGroup(
          title: 'title',
          children: [
            PlutoColumnGroup(
              title: 'title',
              children: [
                PlutoColumnGroup(title: 'title', fields: ['column2']),
                PlutoColumnGroup(
                  title: 'title',
                  children: [
                    PlutoColumnGroup(title: 'title', fields: ['column3']),
                    PlutoColumnGroup(
                      title: 'title',
                      children: [
                        PlutoColumnGroup(title: 'title', fields: ['column5']),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            PlutoColumnGroup(title: 'title', fields: ['column1']),
          ],
        ),
        PlutoColumnGroup(title: 'title', fields: ['column4']),
        PlutoColumnGroup(title: 'title', fields: ['column6']),
      ];

      expect(
        PlutoColumnGroupHelper.maxDepth(columnGroupList: columnGroupList),
        expectedDepth,
      );
    });
  });
}
