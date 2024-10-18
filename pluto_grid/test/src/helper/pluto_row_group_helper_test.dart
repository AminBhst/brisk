import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../mock/mock_methods.dart';

void main() {
  final mock = MockMethods();

  group('applyFilter', () {
    test('rows 가 비어있는 경우 filter 가 호출되지 않아야 한다.', () {
      final FilteredList<PlutoRow> rows = FilteredList();

      final mockFilter = mock.oneParamReturnBool<PlutoRow>;

      expect(rows.originalList.length, 0);

      PlutoRowGroupHelper.applyFilter(rows: rows, filter: mockFilter);

      verifyNever(mockFilter(any));
    });

    test('row 가 있는 경우 filter 가 호출 되어야 한다.', () {
      final FilteredList<PlutoRow> rows = FilteredList(initialList: [
        PlutoRow(cells: {}),
      ]);

      final mockFilter = mock.oneParamReturnBool<PlutoRow>;

      expect(rows.originalList.length, 1);

      when(mockFilter(any)).thenReturn(true);

      PlutoRowGroupHelper.applyFilter(rows: rows, filter: mockFilter);

      verify(mockFilter(any)).called(1);
    });

    test('filter 가 설정 된 상태에서 null 로 호출하면 필터가 삭제 되어야 한다.', () {
      final FilteredList<PlutoRow> rows = FilteredList(initialList: [
        PlutoRow(cells: {'column1': PlutoCell(value: 'test1')}),
        PlutoRow(cells: {'column1': PlutoCell(value: 'test2')}),
        PlutoRow(cells: {'column1': PlutoCell(value: 'test3')}),
      ]);

      filter(PlutoRow row) => row.cells['column1']!.value == 'test1';

      expect(rows.length, 3);

      PlutoRowGroupHelper.applyFilter(rows: rows, filter: filter);

      expect(rows.length, 1);

      expect(rows.hasFilter, true);

      PlutoRowGroupHelper.applyFilter(rows: rows, filter: null);

      expect(rows.length, 3);

      expect(rows.hasFilter, false);
    });

    test('그룹 행이 포함 된 경우 그룹행의 filter 를 포함해서 호출 되어야 한다.', () {
      final FilteredList<PlutoRow> rows = FilteredList(initialList: [
        PlutoRow(cells: {'column1': PlutoCell(value: 'test1')}),
        PlutoRow(cells: {'column1': PlutoCell(value: 'test2')}),
        PlutoRow(
          cells: {'column1': PlutoCell(value: 'test3')},
          type: PlutoRowType.group(
            children: FilteredList(initialList: [
              PlutoRow(cells: {'column1': PlutoCell(value: 'group1')}),
              PlutoRow(cells: {'column1': PlutoCell(value: 'group2')}),
            ]),
          ),
        ),
      ]);

      final mockFilter = mock.oneParamReturnBool<PlutoRow>;

      when(mockFilter(any)).thenReturn(true);

      PlutoRowGroupHelper.applyFilter(rows: rows, filter: mockFilter);

      verify(mockFilter(any)).called(greaterThanOrEqualTo(2));
    });

    test('그룹의 자식 행을 필터링 한 후 필터를 제거하면 자식 행이 리스트에 포함 되어야 한다.', () {
      final FilteredList<PlutoRow> rows = FilteredList(initialList: [
        PlutoRow(cells: {'column1': PlutoCell(value: 'test1')}),
        PlutoRow(cells: {'column1': PlutoCell(value: 'test2')}),
        PlutoRow(
          cells: {'column1': PlutoCell(value: 'test3')},
          type: PlutoRowType.group(
            children: FilteredList(initialList: [
              PlutoRow(cells: {'column1': PlutoCell(value: 'group1')}),
              PlutoRow(cells: {'column1': PlutoCell(value: 'group2')}),
            ]),
          ),
        ),
      ]);

      filter(PlutoRow row) =>
          !row.cells['column1']!.value.toString().startsWith('group');

      PlutoRowGroupHelper.applyFilter(rows: rows, filter: filter);

      expect(rows[2].type.group.children.length, 0);

      PlutoRowGroupHelper.applyFilter(rows: rows, filter: null);

      expect(rows[2].type.group.children.length, 2);
    });
  });
}
