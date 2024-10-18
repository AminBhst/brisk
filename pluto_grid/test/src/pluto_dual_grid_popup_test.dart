import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../helper/column_helper.dart';
import '../helper/row_helper.dart';
import '../helper/test_helper_util.dart';

void main() {
  const buttonText = 'open grid popup';

  const columnWidth = PlutoGridSettings.columnWidth;

  testWidgets(
    'Directionality 가 RTL 인 경우 컬럼이 RTL 에 맞게 위치해야 한다.',
    (WidgetTester tester) async {
      // given
      await TestHelperUtil.changeWidth(
        tester: tester,
        width: 1200,
        height: 600,
      );

      final gridAColumns = ColumnHelper.textColumn('headerA', count: 3);
      final gridARows = RowHelper.count(3, gridAColumns);

      final gridBColumns = ColumnHelper.textColumn('headerB', count: 3);
      final gridBRows = RowHelper.count(3, gridBColumns);

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Builder(
                builder: (BuildContext context) {
                  return TextButton(
                    onPressed: () {
                      PlutoDualGridPopup(
                        context: context,
                        gridPropsA: PlutoDualGridProps(
                          columns: gridAColumns,
                          rows: gridARows,
                        ),
                        gridPropsB: PlutoDualGridProps(
                          columns: gridBColumns,
                          rows: gridBRows,
                        ),
                      );
                    },
                    child: const Text(buttonText),
                  );
                },
              ),
            ),
          ),
        ),
      );

      // when
      await tester.tap(find.byType(TextButton));

      await tester.pumpAndSettle();

      // then
      final gridAColumn1 = find.text('headerA0');
      final gridAColumn2 = find.text('headerA1');
      final gridAColumn3 = find.text('headerA2');
      final gridBColumn1 = find.text('headerB0');
      final gridBColumn2 = find.text('headerB1');
      final gridBColumn3 = find.text('headerB2');

      final gridAColumn1Dx = tester.getTopRight(gridAColumn1).dx;
      final gridAColumn2Dx = tester.getTopRight(gridAColumn2).dx;
      final gridAColumn3Dx = tester.getTopRight(gridAColumn3).dx;
      final gridBColumn1Dx = tester.getTopRight(gridBColumn1).dx;
      final gridBColumn2Dx = tester.getTopRight(gridBColumn2).dx;
      final gridBColumn3Dx = tester.getTopRight(gridBColumn3).dx;

      expect(gridAColumn1Dx - gridAColumn2Dx, columnWidth);
      expect(gridAColumn2Dx - gridAColumn3Dx, columnWidth);

      // 그리드의 넓이로 스크롤에 대한 위치는 체크하지 않고
      // 위치상 gridA 마지막 컬럼이 gridB 의 처음 컬럼의 좌측에 위치하는지만 체크.
      expect(gridBColumn1Dx, lessThan(gridAColumn3Dx));
      expect(gridBColumn1Dx - gridBColumn2Dx, columnWidth);
      expect(gridBColumn2Dx - gridBColumn3Dx, columnWidth);
    },
  );

  testWidgets('그리드 팝업이 호출 되고 셀 값이 출력 되어야 한다.', (WidgetTester tester) async {
    // given
    final gridAColumns = ColumnHelper.textColumn('headerA');
    final gridARows = RowHelper.count(3, gridAColumns);

    final gridBColumns = ColumnHelper.textColumn('headerB');
    final gridBRows = RowHelper.count(3, gridBColumns);

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: Builder(
            builder: (BuildContext context) {
              return TextButton(
                onPressed: () {
                  PlutoDualGridPopup(
                    context: context,
                    gridPropsA: PlutoDualGridProps(
                      columns: gridAColumns,
                      rows: gridARows,
                    ),
                    gridPropsB: PlutoDualGridProps(
                      columns: gridBColumns,
                      rows: gridBRows,
                    ),
                  );
                },
                child: const Text(buttonText),
              );
            },
          ),
        ),
      ),
    );

    // when
    await tester.tap(find.byType(TextButton));

    await tester.pumpAndSettle();

    // then
    final gridACell1 = find.text('headerA0 value 0');
    expect(gridACell1, findsOneWidget);

    final gridBCell1 = find.text('headerB0 value 0');
    expect(gridBCell1, findsOneWidget);
  });
}
