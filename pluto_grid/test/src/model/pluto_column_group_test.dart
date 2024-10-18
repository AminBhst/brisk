import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';

void main() {
  test('fields 가 null 이면 children 이 null 인 경우 assert 에러가 발생 되어야 한다.', () {
    expect(
      () => PlutoColumnGroup(
        title: 'column group',
        fields: null,
        children: null,
      ),
      throwsAssertionError,
    );
  });

  test('fields 가 null 이면 children 이 빈리스트인 경우 assert 에러가 발생 되어야 한다.', () {
    expect(
      () => PlutoColumnGroup(
        title: 'column group',
        fields: null,
        children: [],
      ),
      throwsAssertionError,
    );
  });

  test('fields 가 null 이고 children 이 최소 한개의 요소를 가지면 에러가 발생되지 않아야 한다.', () {
    expect(
      () => PlutoColumnGroup(
        title: 'column group',
        fields: null,
        children: [
          PlutoColumnGroup(title: 'title', fields: ['column1']),
        ],
      ),
      isNot(throwsAssertionError),
    );
  });

  test('fields 가 [] 이고 children 이 null 이면 에러가 발생 되어야 한다.', () {
    expect(
      () => PlutoColumnGroup(
        title: 'column group',
        fields: [],
        children: null,
      ),
      throwsAssertionError,
    );
  });

  test('fields 가 [] 이고 children 이 [] 이면 에러가 발생 되어야 한다.', () {
    expect(
      () => PlutoColumnGroup(
        title: 'column group',
        fields: [],
        children: [],
      ),
      throwsAssertionError,
    );
  });

  test('fields 가 [] 이고 children 이 빈리스트가 아니어도 에러가 발생 되어야 한다.', () {
    expect(
      () => PlutoColumnGroup(
        title: 'column group',
        fields: [],
        children: [
          PlutoColumnGroup(title: 'title', fields: ['column1']),
        ],
      ),
      throwsAssertionError,
    );
  });

  test('fields 가 [column1] 이고 children 이 [] 이면 에러가 발생 되어야 한다.', () {
    expect(
      () => PlutoColumnGroup(
        title: 'column group',
        fields: ['column1'],
        children: [],
      ),
      throwsAssertionError,
    );
  });

  test('fields 가 [column1] 이고 children 이 [PlutoColumnGroup] 이면 에러가 발생 되어야 한다.',
      () {
    expect(
      () => PlutoColumnGroup(
        title: 'column group',
        fields: ['column1'],
        children: [
          PlutoColumnGroup(title: 'sub group', fields: ['column2'])
        ],
      ),
      throwsAssertionError,
    );
  });

  test('fields 가 [column1] 이고 children 이 null 이면 에러가 발생 되지 않아야 한다.', () {
    expect(
      () => PlutoColumnGroup(
        title: 'column group',
        fields: ['column1'],
        children: null,
      ),
      isNot(throwsAssertionError),
    );
  });

  test(
    'fields 가 null 이고 children 이 최소 한개의 요소를 가지면, '
    'hasFields 가 false 고 hasChildren 이 true 이어야 한다.',
    () {
      final columnGroup = PlutoColumnGroup(
        title: 'column group',
        fields: null,
        children: [
          PlutoColumnGroup(title: 'sub group', fields: ['column1']),
        ],
      );

      expect(columnGroup.hasFields, false);
      expect(columnGroup.hasChildren, true);
    },
  );

  test(
    'fields 가 최소 한개의 요소를 가지고 children 이 null 이면, '
    'hasFields 가 true 고 hasChildren 이 false 이어야 한다.',
    () {
      final columnGroup = PlutoColumnGroup(
        title: 'column group',
        fields: ['column1'],
        children: null,
      );

      expect(columnGroup.hasFields, true);
      expect(columnGroup.hasChildren, false);
    },
  );

  test('expandedColumn 이 true 이고 fields 의 요소가 1개를 초과하면 에러가 발생 되어야 한다.', () {
    expect(
      () => PlutoColumnGroup(
        title: 'column group',
        fields: ['column1', 'column2'],
        children: null,
        expandedColumn: true,
      ),
      throwsAssertionError,
    );
  });

  test('expandedColumn 이 true 이고 fields 의 요소가 1개면 에러가 발생되지 않아야 한다.', () {
    expect(
      () => PlutoColumnGroup(
        title: 'column group',
        fields: ['column1'],
        children: null,
        expandedColumn: true,
      ),
      isNot(throwsAssertionError),
    );
  });
}
