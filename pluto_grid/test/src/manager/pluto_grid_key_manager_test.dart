import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../helper/pluto_widget_test_helper.dart';
import '../../helper/row_helper.dart';
import '../../mock/shared_mocks.mocks.dart';

void main() {
  late MockPlutoGridStateManager stateManager;

  PlutoGridConfiguration configuration;

  late FocusNode keyboardFocusNode;

  setUp(() {
    stateManager = MockPlutoGridStateManager();
    configuration = const PlutoGridConfiguration();
    when(stateManager.configuration).thenReturn(configuration);
    when(stateManager.keyPressed).thenReturn(PlutoGridKeyPressed());
    when(stateManager.rowTotalHeight).thenReturn(
      RowHelper.resolveRowTotalHeight(
        stateManager.configuration.style.rowHeight,
      ),
    );
    when(stateManager.localeText).thenReturn(const PlutoGridLocaleText());
    when(stateManager.gridFocusNode).thenReturn(FocusNode());
    when(stateManager.keepFocus).thenReturn(true);
    when(stateManager.hasFocus).thenReturn(true);

    keyboardFocusNode = FocusNode();
  });

  testWidgets(
    'Ctrl + C',
    (WidgetTester tester) async {
      // given
      final PlutoGridKeyManager keyManager = PlutoGridKeyManager(
        stateManager: stateManager,
      );

      keyManager.init();

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: RawKeyboardListener(
              onKey: (event) {
                keyManager.subject.add(PlutoKeyManagerEvent(
                  focusNode: FocusNode(),
                  event: event,
                ));
              },
              focusNode: keyboardFocusNode,
              child: const TextField(),
            ),
          ),
        ),
      );

      when(stateManager.isEditing).thenReturn(false);
      when(stateManager.currentSelectingText).thenReturn('copied');

      String? copied;

      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform, (MethodCall methodCall) async {
        if (methodCall.method == 'Clipboard.setData') {
          copied = (await methodCall.arguments['text']).toString();
        }
        return null;
      });

      // when
      keyboardFocusNode.requestFocus();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyC);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);

      // then
      expect(copied, 'copied');
    },
  );

  testWidgets(
    'Ctrl + C - editing 상태에서는 selectingText 값이 클립보드에 복사 되지 않는다.',
    (WidgetTester tester) async {
      // given
      final PlutoGridKeyManager keyManager = PlutoGridKeyManager(
        stateManager: stateManager,
      );

      keyManager.init();

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: RawKeyboardListener(
              onKey: (event) {
                keyManager.subject.add(PlutoKeyManagerEvent(
                  focusNode: FocusNode(),
                  event: event,
                ));
              },
              focusNode: keyboardFocusNode,
              child: const TextField(),
            ),
          ),
        ),
      );

      when(stateManager.currentSelectingText).thenReturn('copied');

      when(stateManager.isEditing).thenReturn(true);
      expect(stateManager.isEditing, true);

      String? copied;

      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform, (MethodCall methodCall) async {
        if (methodCall.method == 'Clipboard.setData') {
          copied = (await methodCall.arguments['text']).toString();
        }
        return null;
      });

      // when
      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyC);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);

      // then
      expect(copied, isNull);
    },
  );

  testWidgets(
    'Ctrl + V - pasteCellValue 가 호출 되어야 한다.',
    (WidgetTester tester) async {
      // given
      final PlutoGridKeyManager keyManager = PlutoGridKeyManager(
        stateManager: stateManager,
      );

      keyManager.init();

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: RawKeyboardListener(
              onKey: (event) {
                keyManager.subject.add(PlutoKeyManagerEvent(
                  focusNode: FocusNode(),
                  event: event,
                ));
              },
              focusNode: keyboardFocusNode,
              child: const TextField(),
            ),
          ),
        ),
      );

      when(stateManager.currentCell).thenReturn(PlutoCell(value: 'test'));
      when(stateManager.isEditing).thenReturn(false);

      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform, (MethodCall methodCall) async {
        if (methodCall.method == 'Clipboard.getData') {
          return const <String, dynamic>{'text': 'pasted'};
        }
        return null;
      });

      // when
      keyboardFocusNode.requestFocus();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyV);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);

      // then
      expect(stateManager.currentCell, isNotNull);
      expect(stateManager.isEditing, false);
      verify(stateManager.pasteCellValue([
        ['pasted']
      ])).called(1);
    },
  );

  testWidgets(
    'Ctrl + V - currentCell 이 null 이면 pasteCellValue 가 호출 되지 않는다.',
    (WidgetTester tester) async {
      // given
      final PlutoGridKeyManager keyManager = PlutoGridKeyManager(
        stateManager: stateManager,
      );

      keyManager.init();

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: RawKeyboardListener(
              onKey: (event) {
                keyManager.subject.add(PlutoKeyManagerEvent(
                  focusNode: FocusNode(),
                  event: event,
                ));
              },
              focusNode: keyboardFocusNode,
              child: const TextField(),
            ),
          ),
        ),
      );

      when(stateManager.currentCell).thenReturn(null);
      when(stateManager.isEditing).thenReturn(false);

      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform, (MethodCall methodCall) async {
        if (methodCall.method == 'Clipboard.getData') {
          return const <String, dynamic>{'text': 'pasted'};
        }
        return null;
      });

      // when
      keyboardFocusNode.requestFocus();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyV);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);

      // then
      expect(stateManager.currentCell, null);
      expect(stateManager.isEditing, false);
      verifyNever(stateManager.pasteCellValue([
        ['pasted']
      ]));
    },
  );

  testWidgets(
    'Ctrl + V - isEditing 이 true 이면 pasteCellValue 가 호출 되지 않는다.',
    (WidgetTester tester) async {
      // given
      final PlutoGridKeyManager keyManager = PlutoGridKeyManager(
        stateManager: stateManager,
      );

      keyManager.init();

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: RawKeyboardListener(
              onKey: (event) {
                keyManager.subject.add(PlutoKeyManagerEvent(
                  focusNode: FocusNode(),
                  event: event,
                ));
              },
              focusNode: keyboardFocusNode,
              child: const TextField(),
            ),
          ),
        ),
      );

      when(stateManager.currentCell).thenReturn(PlutoCell(value: 'test'));
      when(stateManager.isEditing).thenReturn(true);

      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform, (MethodCall methodCall) async {
        if (methodCall.method == 'Clipboard.getData') {
          return const <String, dynamic>{'text': 'pasted'};
        }
        return null;
      });

      // when
      keyboardFocusNode.requestFocus();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyV);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);

      // then
      expect(stateManager.currentCell, isNotNull);
      expect(stateManager.isEditing, true);
      verifyNever(stateManager.pasteCellValue([
        ['pasted']
      ]));
    },
  );

  group('_handleHomeEnd', () {
    final withKeyboardListener =
        PlutoWidgetTestHelper('키 입력 테스트', (tester) async {
      final PlutoGridKeyManager keyManager = PlutoGridKeyManager(
        stateManager: stateManager,
      );

      keyManager.init();

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: RawKeyboardListener(
              onKey: (event) {
                keyManager.subject.add(PlutoKeyManagerEvent(
                  focusNode: FocusNode(),
                  event: event,
                ));
              },
              focusNode: keyboardFocusNode,
              child: const TextField(),
            ),
          ),
        ),
      );

      // when
      keyboardFocusNode.requestFocus();

      await tester.pumpAndSettle();
    });

    withKeyboardListener.test('home', (tester) async {
      await tester.sendKeyDownEvent(LogicalKeyboardKey.home);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.home);

      // then
      verify(stateManager
              .moveCurrentCellToEdgeOfColumns(PlutoMoveDirection.left))
          .called(1);
    });

    withKeyboardListener.test('home + shift', (tester) async {
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.home);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.home);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);

      // then
      verify(stateManager
              .moveSelectingCellToEdgeOfColumns(PlutoMoveDirection.left))
          .called(1);
    });

    withKeyboardListener.test('home + ctrl', (tester) async {
      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.home);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.home);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);

      // then
      verify(stateManager.moveCurrentCellToEdgeOfRows(PlutoMoveDirection.up))
          .called(1);
    });

    withKeyboardListener.test('home + ctrl + shift', (tester) async {
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.home);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.home);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);

      // then
      verify(stateManager.moveSelectingCellToEdgeOfRows(PlutoMoveDirection.up))
          .called(1);
    });

    withKeyboardListener.test('end', (tester) async {
      await tester.sendKeyDownEvent(LogicalKeyboardKey.end);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.end);

      // then
      verify(stateManager
              .moveCurrentCellToEdgeOfColumns(PlutoMoveDirection.right))
          .called(1);
    });

    withKeyboardListener.test('end + shift', (tester) async {
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.end);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.end);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);

      // then
      verify(stateManager
              .moveSelectingCellToEdgeOfColumns(PlutoMoveDirection.right))
          .called(1);
    });

    withKeyboardListener.test('end + ctrl', (tester) async {
      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.end);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.end);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);

      // then
      verify(stateManager.moveCurrentCellToEdgeOfRows(PlutoMoveDirection.down))
          .called(1);
    });

    withKeyboardListener.test('end + ctrl + shift', (tester) async {
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.end);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.end);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);

      // then
      verify(stateManager
              .moveSelectingCellToEdgeOfRows(PlutoMoveDirection.down))
          .called(1);
    });
  });

  group('_handlePageUpDown', () {
    final withKeyboardListener =
        PlutoWidgetTestHelper('키 입력 테스트', (tester) async {
      final PlutoGridKeyManager keyManager = PlutoGridKeyManager(
        stateManager: stateManager,
      );

      keyManager.init();

      when(stateManager.rowContainerHeight).thenReturn(230);
      when(stateManager.currentRowIdx).thenReturn(0);

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: RawKeyboardListener(
              onKey: (event) {
                keyManager.subject.add(PlutoKeyManagerEvent(
                  focusNode: FocusNode(),
                  event: event,
                ));
              },
              focusNode: keyboardFocusNode,
              child: const TextField(),
            ),
          ),
        ),
      );

      // when
      keyboardFocusNode.requestFocus();

      await tester.pumpAndSettle();
    });

    withKeyboardListener.test('pageUp', (tester) async {
      await tester.sendKeyDownEvent(LogicalKeyboardKey.pageUp);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.pageUp);

      // then
      verify(stateManager.moveCurrentCellByRowIdx(-5, PlutoMoveDirection.up))
          .called(1);
    });

    withKeyboardListener.test('pageUp + shift', (tester) async {
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.pageUp);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.pageUp);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);

      // then
      verify(stateManager.moveSelectingCellByRowIdx(-5, PlutoMoveDirection.up))
          .called(1);
    });

    withKeyboardListener.test('pageDown', (tester) async {
      await tester.sendKeyDownEvent(LogicalKeyboardKey.pageDown);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.pageDown);

      // then
      verify(stateManager.moveCurrentCellByRowIdx(5, PlutoMoveDirection.down))
          .called(1);
    });

    withKeyboardListener.test('pageDown + shift', (tester) async {
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.pageDown);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.pageDown);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);

      // then
      verify(stateManager.moveSelectingCellByRowIdx(5, PlutoMoveDirection.down))
          .called(1);
    });
  });
}
