import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../helper/column_helper.dart';
import '../../helper/row_helper.dart';
import '../../helper/test_helper_util.dart';
import '../../mock/mock_methods.dart';

void main() {
  late List<PlutoColumn> columns;

  late List<PlutoRow> rows;

  late PlutoGridStateManager stateManager;

  final MockMethods mock = MockMethods();

  setUp(() {
    columns = ColumnHelper.textColumn('column', count: 5);

    rows = RowHelper.count(30, columns);

    reset(mock);
  });

  Future<void> buildGrid(
    WidgetTester tester, {
    required PlutoGridShortcut shortcut,
  }) async {
    await TestHelperUtil.changeWidth(
      tester: tester,
      width: 1200,
      height: 800,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: PlutoGrid(
            columns: columns,
            rows: rows,
            onLoaded: (PlutoGridOnLoadedEvent event) {
              stateManager = event.stateManager;
            },
            configuration: PlutoGridConfiguration(shortcut: shortcut),
          ),
        ),
      ),
    );

    stateManager.gridFocusNode.requestFocus();

    await tester.pump();
  }

  testWidgets(
    'enter 키 동작을 추가하면 엔터키 입력시 설정된 동작이 실행 되어야 한다.',
    (tester) async {
      final testAction = _TestAction(mock.noParamReturnVoid);

      final shortcut = PlutoGridShortcut(actions: {
        LogicalKeySet(LogicalKeyboardKey.enter): testAction,
      });

      await buildGrid(tester, shortcut: shortcut);

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);

      verify(mock.noParamReturnVoid()).called(1);
    },
  );

  testWidgets(
    '셀을 포커스 한 후 Control + C 키를 입력하면 기본 동작이 실행 되어야 한다.',
    (tester) async {
      String? copied;

      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform, (MethodCall methodCall) async {
        if (methodCall.method == 'Clipboard.setData') {
          copied = (await methodCall.arguments['text']).toString();
        }
        return null;
      });

      const shortcut = PlutoGridShortcut();

      await buildGrid(tester, shortcut: shortcut);

      await tester.tap(find.text('column0 value 0'));
      await tester.pump();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyC);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
      await tester.pump();

      expect(copied, 'column0 value 0');
    },
  );

  testWidgets(
    '셀을 포커스 한 후 Control + C 의 동작을 재정의 하면 기본 동작이 실행 되지 않아야 한다.',
    (tester) async {
      String? copied;

      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform, (MethodCall methodCall) async {
        if (methodCall.method == 'Clipboard.setData') {
          copied = (await methodCall.arguments['text']).toString();
        }
        return null;
      });

      final testAction = _TestAction(mock.noParamReturnVoid);

      final shortcut = PlutoGridShortcut(
        actions: {
          LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyC):
              testAction,
        },
      );

      await buildGrid(tester, shortcut: shortcut);

      await tester.tap(find.text('column0 value 0'));
      await tester.pump();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyC);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
      await tester.pump();

      expect(copied, null);
      verify(mock.noParamReturnVoid()).called(1);
    },
  );
}

class _TestAction extends PlutoGridShortcutAction {
  const _TestAction(this.callback);

  final void Function() callback;

  @override
  void execute({
    required PlutoKeyManagerEvent keyEvent,
    required PlutoGridStateManager stateManager,
  }) {
    callback();
  }
}
