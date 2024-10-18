import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../helper/column_helper.dart';
import '../../helper/pluto_widget_test_helper.dart';
import '../../helper/row_helper.dart';
import '../../mock/mock_methods.dart';

void main() {
  group('ESC 키 테스트', () {
    List<PlutoColumn> columns;

    List<PlutoRow> rows;

    PlutoGridStateManager? stateManager;

    late MockMethods mock = MockMethods();

    setUp(() {
      mock = MockMethods();
    });

    withTheCellSelected([PlutoGridMode mode = PlutoGridMode.normal]) {
      return PlutoWidgetTestHelper(
        '0, 0 셀이 선택 된 상태에서',
        (tester) async {
          columns = [
            ...ColumnHelper.textColumn('header', count: 10),
          ];

          rows = RowHelper.count(10, columns);

          await tester.pumpWidget(
            MaterialApp(
              home: Material(
                child: PlutoGrid(
                  columns: columns,
                  rows: rows,
                  onLoaded: (PlutoGridOnLoadedEvent event) {
                    stateManager = event.stateManager;
                  },
                  mode: mode,
                  onSelected: mock.oneParamReturnVoid,
                ),
              ),
            ),
          );

          await tester.pump();

          await tester.tap(find.text('header0 value 0'));
        },
      );
    }

    withTheCellSelected(PlutoGridMode.select).test(
      '그리드가 Select 모드 라면 onSelected 이벤트가 발생 되어야 한다.',
      (tester) async {
        verify(mock.oneParamReturnVoid(any)).called(1);

        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      },
    );

    withTheCellSelected().test(
      '그리드가 Select 모드가 아니고, '
      'editing true 상태라면 editing 이 false 가 되어야 한다.',
      (tester) async {
        expect(stateManager!.mode.isSelect, isFalse);

        stateManager!.setEditing(true);

        await tester.sendKeyEvent(LogicalKeyboardKey.escape);

        expect(stateManager!.isEditing, false);
      },
    );

    withTheCellSelected().test(
      '그리드가 Select 모드가 아니고,'
      'Cell 값이 변경 된 상태라면 원래 셀 값으로 되돌려 져야 한다.',
      (tester) async {
        expect(stateManager!.mode.isSelect, isFalse);

        expect(stateManager!.currentCell!.value, 'header0 value 0');

        await tester.sendKeyEvent(LogicalKeyboardKey.keyA);

        await tester.pumpAndSettle();

        expect(stateManager!.textEditingController!.text, 'a');

        await tester.sendKeyEvent(LogicalKeyboardKey.escape);

        expect(stateManager!.currentCell!.value, isNot('a'));

        expect(stateManager!.currentCell!.value, 'header0 value 0');
      },
    );
  });
}
