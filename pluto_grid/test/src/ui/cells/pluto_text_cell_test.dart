import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:pluto_grid/src/ui/ui.dart';

import '../../../mock/shared_mocks.mocks.dart';

void main() {
  late PlutoGridStateManager stateManager;

  setUp(() {
    stateManager = MockPlutoGridStateManager();
    when(stateManager.configuration).thenReturn(
      const PlutoGridConfiguration(),
    );
    when(stateManager.localeText).thenReturn(const PlutoGridLocaleText());
    when(stateManager.keepFocus).thenReturn(true);
    when(stateManager.hasFocus).thenReturn(true);
    when(stateManager.isEditing).thenReturn(true);
  });

  testWidgets('셀 값이 출력 되어야 한다.', (WidgetTester tester) async {
    // given
    final PlutoColumn column = PlutoColumn(
      title: 'column title',
      field: 'column_field_name',
      type: PlutoColumnType.text(),
    );

    final PlutoCell cell = PlutoCell(value: 'text value');

    final PlutoRow row = PlutoRow(
      cells: {
        'column_field_name': cell,
      },
    );

    when(stateManager.currentColumn).thenReturn(column);

    // when
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: PlutoTextCell(
            stateManager: stateManager,
            cell: cell,
            column: column,
            row: row,
          ),
        ),
      ),
    );

    // then
    expect(find.text('text value'), findsOneWidget);
  });
}
