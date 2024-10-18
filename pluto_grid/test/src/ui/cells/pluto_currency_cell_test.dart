import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:pluto_grid/src/ui/ui.dart';

import '../../../helper/row_helper.dart';
import '../../../mock/shared_mocks.mocks.dart';

void main() {
  late MockPlutoGridStateManager stateManager;

  setUp(() {
    stateManager = MockPlutoGridStateManager();
    stateManager = MockPlutoGridStateManager();
    when(stateManager.configuration).thenReturn(
      const PlutoGridConfiguration(),
    );
    when(stateManager.keyPressed).thenReturn(PlutoGridKeyPressed());
    when(stateManager.columnHeight).thenReturn(
      stateManager.configuration.style.columnHeight,
    );
    when(stateManager.rowHeight).thenReturn(
      stateManager.configuration.style.rowHeight,
    );
    when(stateManager.headerHeight).thenReturn(
      stateManager.configuration.style.columnHeight,
    );
    when(stateManager.rowTotalHeight).thenReturn(
      RowHelper.resolveRowTotalHeight(
        stateManager.configuration.style.rowHeight,
      ),
    );
    when(stateManager.localeText).thenReturn(const PlutoGridLocaleText());
    when(stateManager.keepFocus).thenReturn(true);
    when(stateManager.hasFocus).thenReturn(true);
    when(stateManager.isEditing).thenReturn(true);
  });

  buildWidget({
    required WidgetTester tester,
    num? cellValue = 10000,
    String? locale,
    int? decimalPoint,
  }) async {
    final PlutoColumn column = PlutoColumn(
      title: 'column',
      field: 'column',
      type: PlutoColumnType.currency(
        locale: locale,
        decimalDigits: decimalPoint,
      ),
    );

    final PlutoCell cell = PlutoCell(value: cellValue);

    final PlutoRow row = PlutoRow(
      cells: {'column': cell},
    );

    when(stateManager.currentColumn).thenReturn(column);

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: PlutoCurrencyCell(
            stateManager: stateManager,
            cell: cell,
            column: column,
            row: row,
          ),
        ),
      ),
    );
  }

  testWidgets('10000 이 렌더링 되어야 한다.', (tester) async {
    const num cellValue = 10000;

    await buildWidget(tester: tester, cellValue: cellValue);

    expect(find.text(cellValue.toString()), findsOneWidget);
  });

  testWidgets('10000.09 이 렌더링 되어야 한다.', (tester) async {
    const num cellValue = 10000.09;

    await buildWidget(tester: tester, cellValue: cellValue);

    expect(find.text(cellValue.toString()), findsOneWidget);
  });

  testWidgets(
    'comma 를 소수점 구분자로 사용하는 da_DK 인 경우 10000,09 가 렌더링 되어야 한다.',
    (tester) async {
      const num cellValue = 10000.09;

      await buildWidget(tester: tester, cellValue: cellValue, locale: 'da_DK');

      expect(find.text('10000,09'), findsOneWidget);
    },
  );

  testWidgets('소수점 3자리 까지 렌더링 되어야 한다.', (tester) async {
    const num cellValue = 10000.123;

    await buildWidget(tester: tester, cellValue: cellValue, decimalPoint: 3);

    expect(find.text(cellValue.toString()), findsOneWidget);
  });
}
