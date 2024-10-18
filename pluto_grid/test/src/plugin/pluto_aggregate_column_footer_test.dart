import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:rxdart/rxdart.dart';

import '../../helper/pluto_widget_test_helper.dart';
import '../../mock/shared_mocks.mocks.dart';

void main() {
  late MockPlutoGridStateManager stateManager;

  late PublishSubject<PlutoNotifierEvent> subject;

  buildWidget({
    required PlutoColumn column,
    required FilteredList<PlutoRow> rows,
    required PlutoAggregateColumnType type,
    PlutoAggregateColumnGroupedRowType groupedRowType =
        PlutoAggregateColumnGroupedRowType.all,
    PlutoAggregateColumnIterateRowType iterateRowType =
        PlutoAggregateColumnIterateRowType.filteredAndPaginated,
    PlutoAggregateFilter? filter,
    String? locale,
    String? format,
    List<InlineSpan> Function(String)? titleSpanBuilder,
    AlignmentGeometry? alignment,
    EdgeInsets? padding,
    bool enabledRowGroups = false,
  }) {
    return PlutoWidgetTestHelper('PlutoAggregateColumnFooter : ',
        (tester) async {
      stateManager = MockPlutoGridStateManager();

      subject = PublishSubject<PlutoNotifierEvent>();

      when(stateManager.streamNotifier).thenAnswer((_) => subject);

      when(stateManager.configuration)
          .thenReturn(const PlutoGridConfiguration());

      when(stateManager.refRows).thenReturn(rows);

      when(stateManager.enabledRowGroups).thenReturn(enabledRowGroups);

      when(stateManager.iterateAllMainRowGroup)
          .thenReturn(rows.originalList.where((r) => r.isMain));

      when(stateManager.iterateFilteredMainRowGroup)
          .thenReturn(rows.filterOrOriginalList.where((r) => r.isMain));

      when(stateManager.iterateMainRowGroup)
          .thenReturn(rows.where((r) => r.isMain));

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: PlutoAggregateColumnFooter(
              rendererContext: PlutoColumnFooterRendererContext(
                stateManager: stateManager,
                column: column,
              ),
              type: type,
              groupedRowType: groupedRowType,
              iterateRowType: iterateRowType,
              filter: filter,
              format: format ?? '#,###',
              locale: locale,
              titleSpanBuilder: titleSpanBuilder,
              alignment: alignment,
              padding: padding,
            ),
          ),
        ),
      );
    });
  }

  group('number 컬럼.', () {
    final columns = [
      PlutoColumn(
        title: 'column',
        field: 'column',
        type: PlutoColumnType.number(),
      ),
    ];

    buildWidget(
      column: columns.first,
      rows: FilteredList<PlutoRow>(initialList: []),
      type: PlutoAggregateColumnType.sum,
    ).test('행이 없는 경우 sum 값은 0이 되어야 한다.', (tester) async {
      final found = find.text('0');

      expect(found, findsOneWidget);
    });

    buildWidget(
      column: columns.first,
      rows: FilteredList<PlutoRow>(initialList: []),
      type: PlutoAggregateColumnType.average,
    ).test('행이 없는 경우 average 값은 0이 되어야 한다.', (tester) async {
      final found = find.text('0');

      expect(found, findsOneWidget);
    });

    buildWidget(
      column: columns.first,
      rows: FilteredList<PlutoRow>(initialList: []),
      type: PlutoAggregateColumnType.min,
    ).test('행이 없는 경우 min 값은 빈문자열이 출력되어야 한다.', (tester) async {
      final found = find.text('');

      expect(found, findsOneWidget);
    });

    buildWidget(
      column: columns.first,
      rows: FilteredList<PlutoRow>(initialList: []),
      type: PlutoAggregateColumnType.max,
    ).test('행이 없는 경우 max 값은 빈문자열이 출력되어야 한다.', (tester) async {
      final found = find.text('');

      expect(found, findsOneWidget);
    });

    buildWidget(
      column: columns.first,
      rows: FilteredList<PlutoRow>(initialList: []),
      type: PlutoAggregateColumnType.count,
    ).test('행이 없는 경우 max 값은 0이 출력되어야 한다.', (tester) async {
      final found = find.text('0');

      expect(found, findsOneWidget);
    });

    buildWidget(
      column: columns.first,
      rows: FilteredList<PlutoRow>(initialList: [
        PlutoRow(cells: {'column': PlutoCell(value: 1000)}),
        PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
        PlutoRow(cells: {'column': PlutoCell(value: 3000)}),
      ]),
      type: PlutoAggregateColumnType.sum,
    ).test('행이 있는 경우 sum 값은 포멧에 맞게 6,000이 출력 되어야 한다.', (tester) async {
      final found = find.text('6,000');

      expect(found, findsOneWidget);
    });

    buildWidget(
      column: columns.first,
      rows: FilteredList<PlutoRow>(initialList: [
        PlutoRow(cells: {'column': PlutoCell(value: 1000)}),
        PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
        PlutoRow(cells: {'column': PlutoCell(value: 3000)}),
      ]),
      type: PlutoAggregateColumnType.average,
    ).test('행이 있는 경우 average 값은 포멧에 맞게 2,000이 출력 되어야 한다.', (tester) async {
      final found = find.text('2,000');

      expect(found, findsOneWidget);
    });

    buildWidget(
      column: columns.first,
      rows: FilteredList<PlutoRow>(initialList: [
        PlutoRow(cells: {'column': PlutoCell(value: 1000)}),
        PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
        PlutoRow(cells: {'column': PlutoCell(value: 3000)}),
      ]),
      type: PlutoAggregateColumnType.min,
    ).test('행이 있는 경우 min 값은 포멧에 맞게 1,000이 출력 되어야 한다.', (tester) async {
      final found = find.text('1,000');

      expect(found, findsOneWidget);
    });

    buildWidget(
      column: columns.first,
      rows: FilteredList<PlutoRow>(initialList: [
        PlutoRow(cells: {'column': PlutoCell(value: 1000)}),
        PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
        PlutoRow(cells: {'column': PlutoCell(value: 3000)}),
      ]),
      type: PlutoAggregateColumnType.max,
    ).test('행이 있는 경우 max 값은 포멧에 맞게 3,000이 출력 되어야 한다.', (tester) async {
      final found = find.text('3,000');

      expect(found, findsOneWidget);
    });

    buildWidget(
      column: columns.first,
      rows: FilteredList<PlutoRow>(initialList: [
        PlutoRow(cells: {'column': PlutoCell(value: 1000)}),
        PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
        PlutoRow(cells: {'column': PlutoCell(value: 3000)}),
      ]),
      type: PlutoAggregateColumnType.count,
    ).test('행이 있는 경우 count 값은 포멧에 맞게 3이 출력 되어야 한다.', (tester) async {
      final found = find.text('3');

      expect(found, findsOneWidget);
    });

    buildWidget(
      column: columns.first,
      rows: FilteredList<PlutoRow>(initialList: [
        PlutoRow(cells: {'column': PlutoCell(value: 1000)}),
        PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
        PlutoRow(cells: {'column': PlutoCell(value: 3000)}),
      ]),
      type: PlutoAggregateColumnType.count,
      filter: (cell) => cell.value > 1000,
    ).test('filter 가 설정 된 경우 count 값은 필터 조건에 맞게 2이 출력 되어야 한다.', (tester) async {
      final found = find.text('2');

      expect(found, findsOneWidget);
    });

    buildWidget(
      column: columns.first,
      rows: FilteredList<PlutoRow>(initialList: [
        PlutoRow(cells: {'column': PlutoCell(value: 1000)}),
        PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
        PlutoRow(cells: {'column': PlutoCell(value: 3000)}),
      ]),
      type: PlutoAggregateColumnType.count,
      format: 'Total : #,###',
    ).test(
      '행이 있는 경우 count 값은 설정한 포멧에 맞게 Total : 3이 출력 되어야 한다.',
      (tester) async {
        final found = find.text('Total : 3');

        expect(found, findsOneWidget);
      },
    );

    buildWidget(
      column: columns.first,
      rows: FilteredList<PlutoRow>(initialList: [
        PlutoRow(cells: {'column': PlutoCell(value: 1000)}),
        PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
        PlutoRow(cells: {'column': PlutoCell(value: 3000)}),
      ]),
      type: PlutoAggregateColumnType.sum,
      titleSpanBuilder: (text) {
        return [
          const WidgetSpan(child: Text('Left ')),
          WidgetSpan(child: Text('Value : $text')),
          const WidgetSpan(child: Text(' Right')),
        ];
      },
    ).test(
      'titleSpanBuilder 이 있는 경우 sum 값은 설정한 위젯에 맞게 '
      'Left Value : 6,000 Right 이 출력 되어야 한다.',
      (tester) async {
        expect(find.text('Left '), findsOneWidget);
        expect(find.text('Value : 6,000'), findsOneWidget);
        expect(find.text(' Right'), findsOneWidget);
      },
    );

    buildWidget(
      column: columns.first,
      rows: FilteredList<PlutoRow>(initialList: [
        PlutoRow(cells: {'column': PlutoCell(value: 1000)}),
        PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
        PlutoRow(cells: {'column': PlutoCell(value: 3000)}),
      ])
        ..setFilter((element) => element.cells['column']!.value > 1000),
      type: PlutoAggregateColumnType.sum,
    ).test(
      '필터가 적용 된 경우 필터 된 결과만 집계 되어야 한다.',
      (tester) async {
        expect(find.text('5,000'), findsOneWidget);
      },
    );

    buildWidget(
      column: columns.first,
      rows: FilteredList<PlutoRow>(initialList: [
        PlutoRow(cells: {'column': PlutoCell(value: 1000)}),
        PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
        PlutoRow(cells: {'column': PlutoCell(value: 3000)}),
      ])
        ..setFilterRange(FilteredListRange(0, 2)),
      type: PlutoAggregateColumnType.sum,
    ).test(
      '페이지네이션이 적용 된 경우 페이지네이션 된 결과만 집계 되어야 한다.',
      (tester) async {
        expect(find.text('3,000'), findsOneWidget);
      },
    );

    buildWidget(
      column: columns.first,
      rows: FilteredList<PlutoRow>(initialList: [
        PlutoRow(cells: {'column': PlutoCell(value: 1000)}),
        PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
        PlutoRow(cells: {'column': PlutoCell(value: 3000)}),
      ])
        ..setFilterRange(FilteredListRange(0, 2)),
      type: PlutoAggregateColumnType.sum,
      iterateRowType: PlutoAggregateColumnIterateRowType.all,
    ).test(
      'iterateRowType 이 all 인 경우 페이지네이션이 적용되어도 전체 행이 집계 되어야 한다.',
      (tester) async {
        expect(find.text('6,000'), findsOneWidget);
      },
    );

    buildWidget(
      column: columns.first,
      rows: FilteredList<PlutoRow>(initialList: [
        PlutoRow(cells: {'column': PlutoCell(value: 1000)}),
        PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
        PlutoRow(cells: {'column': PlutoCell(value: 3000)}),
      ])
        ..setFilter((element) => element.cells['column']!.value > 1000)
        ..setFilterRange(FilteredListRange(0, 2)),
      type: PlutoAggregateColumnType.sum,
      iterateRowType: PlutoAggregateColumnIterateRowType.filtered,
    ).test(
      'iterateRowType 이 filtered 인 경우 페이지네이션 된 결과를 무시하고 필터링 된 결과만 집계에 포함 해야 한다.',
      (tester) async {
        expect(find.text('5,000'), findsOneWidget);
      },
    );

    buildWidget(
      column: columns.first,
      rows: FilteredList<PlutoRow>(initialList: [
        PlutoRow(cells: {'column': PlutoCell(value: 1000)}),
        PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
        PlutoRow(cells: {'column': PlutoCell(value: 3000)}),
      ])
        ..setFilter((element) => element.cells['column']!.value > 1000),
      type: PlutoAggregateColumnType.sum,
      iterateRowType: PlutoAggregateColumnIterateRowType.all,
    ).test(
      'iterateRowType 이 all 인 경우 필터가 적용되어도 모든 행이 집계 되어야 한다.',
      (tester) async {
        expect(find.text('6,000'), findsOneWidget);
      },
    );
  });

  group('RowGroups', () {
    final columns = [
      PlutoColumn(
        title: 'column',
        field: 'column',
        type: PlutoColumnType.number(),
      ),
    ];

    buildWidget(
      column: columns.first,
      rows: FilteredList<PlutoRow>(initialList: [
        PlutoRow(
            cells: {'column': PlutoCell(value: 1000)},
            type: PlutoRowType.group(
                children: FilteredList(
              initialList: [
                PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
                PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
              ],
            ))),
        PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
        PlutoRow(cells: {'column': PlutoCell(value: 3000)}),
      ]),
      type: PlutoAggregateColumnType.sum,
      groupedRowType: PlutoAggregateColumnGroupedRowType.all,
      enabledRowGroups: true,
      titleSpanBuilder: (text) {
        return [
          WidgetSpan(child: Text('Value : $text')),
        ];
      },
    ).test(
      'GroupedRowType 이 all 인 경우 '
      'Value : 10,000 이 출력 되어야 한다.',
      (tester) async {
        expect(find.text('Value : 10,000'), findsOneWidget);
      },
    );

    buildWidget(
      column: columns.first,
      rows: FilteredList<PlutoRow>(initialList: [
        PlutoRow(
            cells: {'column': PlutoCell(value: 1000)},
            type: PlutoRowType.group(
                children: FilteredList(
              initialList: [
                PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
                PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
              ],
            ))),
        PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
        PlutoRow(cells: {'column': PlutoCell(value: 3000)}),
      ]),
      type: PlutoAggregateColumnType.sum,
      groupedRowType: PlutoAggregateColumnGroupedRowType.expandedAll,
      enabledRowGroups: true,
      titleSpanBuilder: (text) {
        return [
          WidgetSpan(child: Text('Value : $text')),
        ];
      },
    ).test(
      'GroupedRowType 이 expandedAll 이고 그룹행이 접혀진 경우 '
      'Value : 6,000 이 출력 되어야 한다.',
      (tester) async {
        expect(find.text('Value : 6,000'), findsOneWidget);
      },
    );

    buildWidget(
      column: columns.first,
      rows: FilteredList<PlutoRow>(initialList: [
        PlutoRow(
            cells: {'column': PlutoCell(value: 1000)},
            type: PlutoRowType.group(
              children: FilteredList(
                initialList: [
                  PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
                  PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
                ],
              ),
              expanded: true,
            )),
        PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
        PlutoRow(cells: {'column': PlutoCell(value: 3000)}),
      ]),
      type: PlutoAggregateColumnType.sum,
      groupedRowType: PlutoAggregateColumnGroupedRowType.expandedAll,
      enabledRowGroups: true,
      titleSpanBuilder: (text) {
        return [
          WidgetSpan(child: Text('Value : $text')),
        ];
      },
    ).test(
      'GroupedRowType 이 expandedAll 이고 그룹행이 펼쳐진 경우 '
      'Value : 10,000 이 출력 되어야 한다.',
      (tester) async {
        expect(find.text('Value : 10,000'), findsOneWidget);
      },
    );

    buildWidget(
      column: columns.first,
      rows: FilteredList<PlutoRow>(initialList: [
        PlutoRow(
            cells: {'column': PlutoCell(value: 1000)},
            type: PlutoRowType.group(
              children: FilteredList(
                initialList: [
                  PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
                  PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
                ],
              ),
              expanded: true,
            )),
        PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
        PlutoRow(cells: {'column': PlutoCell(value: 3000)}),
      ]),
      type: PlutoAggregateColumnType.sum,
      groupedRowType: PlutoAggregateColumnGroupedRowType.rows,
      enabledRowGroups: true,
      titleSpanBuilder: (text) {
        return [
          WidgetSpan(child: Text('Value : $text')),
        ];
      },
    ).test(
      'GroupedRowType 이 rows 인 경우 '
      'Value : 9,000 이 출력 되어야 한다.',
      (tester) async {
        expect(find.text('Value : 9,000'), findsOneWidget);
      },
    );

    buildWidget(
      column: columns.first,
      rows: FilteredList<PlutoRow>(initialList: [
        PlutoRow(
            cells: {'column': PlutoCell(value: 1000)},
            type: PlutoRowType.group(
              children: FilteredList(
                initialList: [
                  PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
                  PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
                ],
              ),
              expanded: false,
            )),
        PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
        PlutoRow(cells: {'column': PlutoCell(value: 3000)}),
      ]),
      type: PlutoAggregateColumnType.sum,
      groupedRowType: PlutoAggregateColumnGroupedRowType.expandedRows,
      enabledRowGroups: true,
      titleSpanBuilder: (text) {
        return [
          WidgetSpan(child: Text('Value : $text')),
        ];
      },
    ).test(
      'GroupedRowType 이 expandedRows 이고 그룹행이 접혀진 경우 '
      'Value : 5,000 이 출력 되어야 한다.',
      (tester) async {
        expect(find.text('Value : 5,000'), findsOneWidget);
      },
    );

    buildWidget(
      column: columns.first,
      rows: FilteredList<PlutoRow>(initialList: [
        PlutoRow(
            cells: {'column': PlutoCell(value: 1000)},
            type: PlutoRowType.group(
              children: FilteredList(
                initialList: [
                  PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
                  PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
                ],
              ),
              expanded: true,
            )),
        PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
        PlutoRow(cells: {'column': PlutoCell(value: 3000)}),
      ]),
      type: PlutoAggregateColumnType.sum,
      groupedRowType: PlutoAggregateColumnGroupedRowType.expandedRows,
      enabledRowGroups: true,
      titleSpanBuilder: (text) {
        return [
          WidgetSpan(child: Text('Value : $text')),
        ];
      },
    ).test(
      'GroupedRowType 이 expandedRows 이고 그룹행이 펼쳐진 경우 '
      'Value : 9,000 이 출력 되어야 한다.',
      (tester) async {
        expect(find.text('Value : 9,000'), findsOneWidget);
      },
    );

    buildWidget(
      column: columns.first,
      rows: FilteredList<PlutoRow>(initialList: [
        PlutoRow(
            cells: {'column': PlutoCell(value: 1000)},
            type: PlutoRowType.group(
              children: FilteredList(
                initialList: [
                  PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
                  PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
                ],
              ),
              expanded: true,
            )),
        PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
        PlutoRow(cells: {'column': PlutoCell(value: 3000)}),
      ])
        ..setFilter((element) => element.cells['column']!.value > 1000),
      type: PlutoAggregateColumnType.sum,
      groupedRowType: PlutoAggregateColumnGroupedRowType.all,
      enabledRowGroups: true,
    ).test(
      '필터가 적용 된 경우 필터가 적용 된 결과만 집계에 포함 되어야 한다.',
      (tester) async {
        expect(find.text('5,000'), findsOneWidget);
      },
    );

    buildWidget(
      column: columns.first,
      rows: FilteredList<PlutoRow>(initialList: [
        PlutoRow(
            cells: {'column': PlutoCell(value: 1000)},
            type: PlutoRowType.group(
              children: FilteredList(
                initialList: [
                  PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
                  PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
                ],
              ),
              expanded: true,
            )),
        PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
        PlutoRow(cells: {'column': PlutoCell(value: 3000)}),
      ])
        ..setFilterRange(FilteredListRange(0, 2)),
      type: PlutoAggregateColumnType.sum,
      groupedRowType: PlutoAggregateColumnGroupedRowType.all,
      enabledRowGroups: true,
    ).test(
      '페이지네이션이 설정 된 경우 페이지네이션 된 결과만 집계에 포함 되어야 한다.',
      (tester) async {
        expect(find.text('7,000'), findsOneWidget);
      },
    );

    buildWidget(
      column: columns.first,
      rows: FilteredList<PlutoRow>(initialList: [
        PlutoRow(
            cells: {'column': PlutoCell(value: 1000)},
            type: PlutoRowType.group(
              children: FilteredList(
                initialList: [
                  PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
                  PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
                ],
              ),
              expanded: true,
            )),
        PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
        PlutoRow(cells: {'column': PlutoCell(value: 3000)}),
      ])
        ..setFilter((element) => element.cells['column']!.value > 1000),
      type: PlutoAggregateColumnType.sum,
      iterateRowType: PlutoAggregateColumnIterateRowType.all,
      groupedRowType: PlutoAggregateColumnGroupedRowType.all,
      enabledRowGroups: true,
    ).test(
      'iterateRowType 가 all 인 경우 필터가 적용되어도 전체 행이 집계에 포함 되어야 한다.',
      (tester) async {
        expect(find.text('10,000'), findsOneWidget);
      },
    );

    buildWidget(
      column: columns.first,
      rows: FilteredList<PlutoRow>(initialList: [
        PlutoRow(
            cells: {'column': PlutoCell(value: 1000)},
            type: PlutoRowType.group(
              children: FilteredList(
                initialList: [
                  PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
                  PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
                ],
              ),
              expanded: true,
            )),
        PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
        PlutoRow(cells: {'column': PlutoCell(value: 3000)}),
      ])
        ..setFilter((element) => element.cells['column']!.value > 1000)
        ..setFilterRange(FilteredListRange(0, 2)),
      type: PlutoAggregateColumnType.sum,
      iterateRowType: PlutoAggregateColumnIterateRowType.filtered,
      groupedRowType: PlutoAggregateColumnGroupedRowType.all,
      enabledRowGroups: true,
    ).test(
      'iterateRowType 가 filtered 인 경우 페이지네이션을 무시하고 필터링 된 결과만 집계에 포함 되어야 한다.',
      (tester) async {
        expect(find.text('5,000'), findsOneWidget);
      },
    );
  });
}
