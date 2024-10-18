import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:pluto_grid/src/ui/ui.dart';
import 'package:rxdart/rxdart.dart';

import '../../helper/pluto_widget_test_helper.dart';
import '../../helper/row_helper.dart';
import '../../matcher/pluto_object_matcher.dart';
import '../../mock/shared_mocks.mocks.dart';

void main() {
  late MockPlutoGridStateManager stateManager;
  MockPlutoGridEventManager? eventManager;
  PublishSubject<PlutoNotifierEvent> streamNotifier;

  setUp(() {
    const configuration = PlutoGridConfiguration();
    stateManager = MockPlutoGridStateManager();
    eventManager = MockPlutoGridEventManager();
    streamNotifier = PublishSubject<PlutoNotifierEvent>();
    when(stateManager.streamNotifier).thenAnswer((_) => streamNotifier);
    when(stateManager.eventManager).thenReturn(eventManager);
    when(stateManager.configuration).thenReturn(configuration);
    when(stateManager.style).thenReturn(configuration.style);
    when(stateManager.keyPressed).thenReturn(PlutoGridKeyPressed());
    when(stateManager.rowHeight).thenReturn(
      stateManager.configuration.style.rowHeight,
    );
    when(stateManager.columnHeight).thenReturn(
      stateManager.configuration.style.columnHeight,
    );
    when(stateManager.columnFilterHeight).thenReturn(
      stateManager.configuration.style.columnHeight,
    );
    when(stateManager.rowTotalHeight).thenReturn(
      RowHelper.resolveRowTotalHeight(
        stateManager.configuration.style.rowHeight,
      ),
    );
    when(stateManager.localeText).thenReturn(const PlutoGridLocaleText());
    when(stateManager.gridFocusNode).thenReturn(FocusNode());
    when(stateManager.keepFocus).thenReturn(true);
    when(stateManager.hasFocus).thenReturn(true);
    when(stateManager.selectingMode).thenReturn(PlutoGridSelectingMode.cell);
    when(stateManager.canRowDrag).thenReturn(true);
    when(stateManager.isSelectedCell(any, any, any)).thenReturn(false);
    when(stateManager.enabledRowGroups).thenReturn(false);
    when(stateManager.rowGroupDelegate).thenReturn(null);
  });

  Widget buildApp({
    required PlutoCell cell,
    required PlutoColumn column,
    required PlutoRow row,
    required int rowIdx,
  }) {
    return MaterialApp(
      home: Material(
        child: PlutoBaseCell(
          cell: cell,
          column: column,
          rowIdx: rowIdx,
          row: row,
          stateManager: stateManager,
        ),
      ),
    );
  }

  testWidgets(
      'WHEN If it is not CurrentCell or not in Editing state'
      'THEN Text widget should be rendered', (WidgetTester tester) async {
    // given
    final PlutoCell cell = PlutoCell(value: 'cell value');

    final PlutoColumn column = PlutoColumn(
      title: 'header',
      field: 'header',
      type: PlutoColumnType.text(),
    );

    final PlutoRow row = PlutoRow(
      cells: {
        'header': cell,
      },
    );

    const rowIdx = 0;

    // when
    when(stateManager.isCurrentCell(any)).thenReturn(false);
    when(stateManager.isSelectedCell(any, any, any)).thenReturn(false);
    when(stateManager.isEditing).thenReturn(false);

    await tester.pumpWidget(
      buildApp(
        cell: cell,
        column: column,
        rowIdx: rowIdx,
        row: row,
      ),
    );

    // then
    expect(find.text('cell value'), findsOneWidget);
    expect(find.byType(PlutoSelectCell), findsNothing);
    expect(find.byType(PlutoNumberCell), findsNothing);
    expect(find.byType(PlutoDateCell), findsNothing);
    expect(find.byType(PlutoTimeCell), findsNothing);
    expect(find.byType(PlutoTextCell), findsNothing);
  });

  testWidgets(
      'WHEN If it is CurrentCell and not in Editing state'
      'THEN Text widget should be rendered', (WidgetTester tester) async {
    // given
    final PlutoCell cell = PlutoCell(value: 'cell value');

    final PlutoColumn column = PlutoColumn(
      title: 'header',
      field: 'header',
      type: PlutoColumnType.text(),
    );

    final PlutoRow row = PlutoRow(
      cells: {
        'header': cell,
      },
    );

    const rowIdx = 0;

    // when
    when(stateManager.isCurrentCell(any)).thenReturn(true);
    when(stateManager.isEditing).thenReturn(false);

    await tester.pumpWidget(
      buildApp(
        cell: cell,
        column: column,
        rowIdx: rowIdx,
        row: row,
      ),
    );

    // then
    expect(find.text('cell value'), findsOneWidget);
    expect(find.byType(PlutoSelectCell), findsNothing);
    expect(find.byType(PlutoNumberCell), findsNothing);
    expect(find.byType(PlutoDateCell), findsNothing);
    expect(find.byType(PlutoTimeCell), findsNothing);
    expect(find.byType(PlutoTextCell), findsNothing);
  });

  testWidgets(
      'WHEN If it is CurrentCell and in Editing state'
      'THEN [TextCellWidget] should be rendered', (WidgetTester tester) async {
    // given
    final PlutoCell cell = PlutoCell(value: 'cell value');

    final PlutoColumn column = PlutoColumn(
      title: 'header',
      field: 'header',
      type: PlutoColumnType.text(),
    );

    final PlutoRow row = PlutoRow(
      cells: {
        'header': cell,
      },
    );

    const rowIdx = 0;

    // when
    when(stateManager.isCurrentCell(any)).thenReturn(true);
    when(stateManager.isEditing).thenReturn(true);

    await tester.pumpWidget(
      buildApp(
        cell: cell,
        column: column,
        rowIdx: rowIdx,
        row: row,
      ),
    );

    // then
    expect(find.text('cell value'), findsOneWidget);
    expect(find.byType(PlutoSelectCell), findsNothing);
    expect(find.byType(PlutoNumberCell), findsNothing);
    expect(find.byType(PlutoDateCell), findsNothing);
    expect(find.byType(PlutoTimeCell), findsNothing);
    expect(find.byType(PlutoTextCell), findsOneWidget);
  });

  testWidgets(
      'WHEN If it is CurrentCell and in Editing state'
      'THEN [TimeCellWidget] should be rendered', (WidgetTester tester) async {
    // given
    final PlutoCell cell = PlutoCell(value: '00:00');

    final PlutoColumn column = PlutoColumn(
      title: 'header',
      field: 'header',
      type: PlutoColumnType.time(),
    );

    final PlutoRow row = PlutoRow(
      cells: {
        'header': cell,
      },
    );

    const rowIdx = 0;

    // when
    when(stateManager.isCurrentCell(any)).thenReturn(true);
    when(stateManager.isEditing).thenReturn(true);

    await tester.pumpWidget(
      buildApp(
        cell: cell,
        column: column,
        rowIdx: rowIdx,
        row: row,
      ),
    );

    // then
    expect(find.text('00:00'), findsOneWidget);
    expect(find.byType(PlutoSelectCell), findsNothing);
    expect(find.byType(PlutoNumberCell), findsNothing);
    expect(find.byType(PlutoDateCell), findsNothing);
    expect(find.byType(PlutoTimeCell), findsOneWidget);
    expect(find.byType(PlutoTextCell), findsNothing);
  });

  testWidgets(
      'WHEN If it is CurrentCell and in Editing state'
      'THEN [DateCellWidget] should be rendered', (WidgetTester tester) async {
    // given
    final PlutoCell cell = PlutoCell(value: '2020-01-01');

    final PlutoColumn column = PlutoColumn(
      title: 'header',
      field: 'header',
      type: PlutoColumnType.date(),
    );

    final PlutoRow row = PlutoRow(
      cells: {
        'header': cell,
      },
    );

    const rowIdx = 0;

    // when
    when(stateManager.isCurrentCell(any)).thenReturn(true);
    when(stateManager.isEditing).thenReturn(true);

    await tester.pumpWidget(
      buildApp(
        cell: cell,
        column: column,
        rowIdx: rowIdx,
        row: row,
      ),
    );

    // then
    expect(find.text('2020-01-01'), findsOneWidget);
    expect(find.byType(PlutoSelectCell), findsNothing);
    expect(find.byType(PlutoNumberCell), findsNothing);
    expect(find.byType(PlutoDateCell), findsOneWidget);
    expect(find.byType(PlutoTimeCell), findsNothing);
    expect(find.byType(PlutoTextCell), findsNothing);
  });

  testWidgets(
      'WHEN If it is CurrentCell and in Editing state'
      'THEN [NumberCellWidget] should be rendered',
      (WidgetTester tester) async {
    // given
    final PlutoCell cell = PlutoCell(value: 1234);

    final PlutoColumn column = PlutoColumn(
      title: 'header',
      field: 'header',
      type: PlutoColumnType.number(),
    );

    final PlutoRow row = PlutoRow(
      cells: {
        'header': cell,
      },
    );

    const rowIdx = 0;

    // when
    when(stateManager.isCurrentCell(any)).thenReturn(true);
    when(stateManager.isEditing).thenReturn(true);

    await tester.pumpWidget(
      buildApp(
        cell: cell,
        column: column,
        rowIdx: rowIdx,
        row: row,
      ),
    );

    // then
    expect(find.text('1234'), findsOneWidget);
    expect(find.byType(PlutoSelectCell), findsNothing);
    expect(find.byType(PlutoNumberCell), findsOneWidget);
    expect(find.byType(PlutoDateCell), findsNothing);
    expect(find.byType(PlutoTimeCell), findsNothing);
    expect(find.byType(PlutoTextCell), findsNothing);
  });

  testWidgets(
      'WHEN If it is CurrentCell and in Editing state'
      'THEN [SelectCellWidget] should be rendered',
      (WidgetTester tester) async {
    // given
    final PlutoCell cell = PlutoCell(value: 'one');

    final PlutoColumn column = PlutoColumn(
      title: 'header',
      field: 'header',
      type: PlutoColumnType.select(<String>['one', 'two', 'three']),
    );

    final PlutoRow row = PlutoRow(
      cells: {
        'header': cell,
      },
    );

    const rowIdx = 0;

    // when
    when(stateManager.isCurrentCell(any)).thenReturn(true);
    when(stateManager.isEditing).thenReturn(true);

    await tester.pumpWidget(
      buildApp(
        cell: cell,
        column: column,
        rowIdx: rowIdx,
        row: row,
      ),
    );

    // then
    expect(find.text('one'), findsOneWidget);
    expect(find.byType(PlutoSelectCell), findsOneWidget);
    expect(find.byType(PlutoNumberCell), findsNothing);
    expect(find.byType(PlutoDateCell), findsNothing);
    expect(find.byType(PlutoTimeCell), findsNothing);
    expect(find.byType(PlutoTextCell), findsNothing);
  });

  testWidgets(
    '셀을 탭하면 PlutoCellGestureEvent 이벤트가 OnTapUp 으로 호출 되어야 한다.',
    (WidgetTester tester) async {
      // given
      final PlutoCell cell = PlutoCell(value: 'one');

      final PlutoColumn column = PlutoColumn(
        title: 'header',
        field: 'header',
        type: PlutoColumnType.text(),
      );

      final PlutoRow row = PlutoRow(
        cells: {
          'header': cell,
        },
      );

      const rowIdx = 0;

      // when
      when(stateManager.isCurrentCell(any)).thenReturn(false);
      when(stateManager.isEditing).thenReturn(false);
      when(stateManager.isSelectedCell(any, any, any)).thenReturn(false);

      await tester.pumpWidget(
        buildApp(
          cell: cell,
          column: column,
          rowIdx: rowIdx,
          row: row,
        ),
      );

      Finder gesture = find.byType(GestureDetector);

      await tester.tap(gesture);

      verify(eventManager!.addEvent(
        argThat(PlutoObjectMatcher<PlutoGridCellGestureEvent>(rule: (object) {
          return object.gestureType.isOnTapUp &&
              object.cell.key == cell.key &&
              object.column.key == column.key &&
              object.rowIdx == rowIdx;
        })),
      )).called(1);
    },
  );

  testWidgets(
    '셀을 길게 탭하면 PlutoCellGestureEvent 이벤트가 OnLongPressStart 으로 호출 되어야 한다.',
    (WidgetTester tester) async {
      // given
      final PlutoCell cell = PlutoCell(value: 'one');

      final PlutoColumn column = PlutoColumn(
        title: 'header',
        field: 'header',
        type: PlutoColumnType.text(),
      );

      final PlutoRow row = PlutoRow(
        cells: {
          'header': cell,
        },
      );

      const rowIdx = 0;

      // when
      when(stateManager.isCurrentCell(any)).thenReturn(false);
      when(stateManager.isEditing).thenReturn(false);
      when(stateManager.isSelectedCell(any, any, any)).thenReturn(false);

      await tester.pumpWidget(
        buildApp(
          cell: cell,
          column: column,
          rowIdx: rowIdx,
          row: row,
        ),
      );

      Finder gesture = find.byType(GestureDetector);

      await tester.longPress(gesture);

      verify(eventManager!.addEvent(
        argThat(PlutoObjectMatcher<PlutoGridCellGestureEvent>(rule: (object) {
          return object.gestureType.isOnLongPressStart &&
              object.cell.key == cell.key &&
              object.column.key == column.key &&
              object.rowIdx == rowIdx;
        })),
      )).called(1);
    },
  );

  testWidgets(
    '셀을 길게 탭하고 이동하면 PlutoCellGestureEvent 이벤트가 '
    'onLongPressMoveUpdate 으로 호출 되어야 한다.',
    (WidgetTester tester) async {
      // given
      final PlutoCell cell = PlutoCell(value: 'one');

      final PlutoColumn column = PlutoColumn(
        title: 'header',
        field: 'header',
        type: PlutoColumnType.text(),
      );

      final PlutoRow row = PlutoRow(
        cells: {
          'header': cell,
        },
      );

      const rowIdx = 0;

      when(stateManager.isCurrentCell(any)).thenReturn(true);
      when(stateManager.isEditing).thenReturn(false);
      when(stateManager.selectingMode).thenReturn(PlutoGridSelectingMode.row);

      when(stateManager.isSelectingInteraction()).thenReturn(false);
      when(stateManager.needMovingScroll(any, any)).thenReturn(false);

      // when
      await tester.pumpWidget(
        buildApp(
          cell: cell,
          column: column,
          rowIdx: rowIdx,
          row: row,
        ),
      );

      // then
      final TestGesture gesture =
          await tester.startGesture(const Offset(100, 18));

      await tester.pump(const Duration(milliseconds: 500));

      await gesture.moveBy(const Offset(50, 0));

      await gesture.up();

      await tester.pump();

      await tester.pumpAndSettle(const Duration(milliseconds: 800));

      verify(eventManager!.addEvent(
        argThat(PlutoObjectMatcher<PlutoGridCellGestureEvent>(rule: (object) {
          return object.gestureType.isOnLongPressMoveUpdate &&
              object.cell.key == cell.key &&
              object.column.key == column.key &&
              object.rowIdx == rowIdx;
        })),
      )).called(1);
    },
  );

  group('DefaultCellWidget 렌더링 조건', () {
    PlutoCell cell;

    PlutoColumn column;

    int rowIdx;

    aCell({
      bool isCurrentCell = true,
      bool isEditing = false,
      bool readOnly = false,
      bool enableEditingMode = true,
    }) {
      return PlutoWidgetTestHelper('a cell.', (tester) async {
        when(stateManager.isCurrentCell(any)).thenReturn(isCurrentCell);
        when(stateManager.isEditing).thenReturn(isEditing);
        when(stateManager.isSelectedCell(any, any, any)).thenReturn(false);
        when(stateManager.hasFocus).thenReturn(true);

        cell = PlutoCell(value: 'one');

        column = PlutoColumn(
          title: 'header',
          field: 'header',
          readOnly: readOnly,
          type: PlutoColumnType.text(),
          enableEditingMode: enableEditingMode,
        );

        final PlutoRow row = PlutoRow(
          cells: {
            'header': cell,
          },
        );

        rowIdx = 0;

        await tester.pumpWidget(
          buildApp(
            cell: cell,
            column: column,
            rowIdx: rowIdx,
            row: row,
          ),
        );

        await tester.pumpAndSettle(const Duration(seconds: 1));
      });
    }

    aCell(isCurrentCell: false).test(
      'currentCell 이 아니면, DefaultCellWidget 이 렌더링 되어야 한다.',
      (tester) async {
        expect(find.byType(PlutoDefaultCell), findsOneWidget);
      },
    );

    aCell(isEditing: false).test(
      'isEditing 이 false, DefaultCellWidget 이 렌더링 되어야 한다.',
      (tester) async {
        expect(find.byType(PlutoDefaultCell), findsOneWidget);
      },
    );

    aCell(enableEditingMode: false).test(
      'enableEditingMode 이 false, DefaultCellWidget 이 렌더링 되어야 한다.',
      (tester) async {
        expect(find.byType(PlutoDefaultCell), findsOneWidget);
      },
    );

    aCell(isCurrentCell: true, isEditing: true, enableEditingMode: true).test(
      'isCurrentCell, isEditing, enableEditingMode 이 true 면, '
      'DefaultCellWidget 이 렌더링 되지 않아야 한다.',
      (tester) async {
        expect(find.byType(PlutoDefaultCell), findsNothing);
      },
    );
  });

  group('configuration', () {
    PlutoCell cell;

    PlutoColumn? column;

    int rowIdx;

    aCellWithConfiguration(
      PlutoGridConfiguration configuration, {
      bool isCurrentCell = true,
      bool isSelectedCell = false,
      bool readOnly = false,
    }) {
      return PlutoWidgetTestHelper('a cell.', (tester) async {
        when(stateManager.isCurrentCell(any)).thenReturn(isCurrentCell);
        when(stateManager.isSelectedCell(any, any, any))
            .thenReturn(isSelectedCell);
        when(stateManager.style).thenReturn(configuration.style);
        when(stateManager.hasFocus).thenReturn(true);
        when(stateManager.isEditing).thenReturn(true);

        cell = PlutoCell(value: 'one');

        column = PlutoColumn(
          title: 'header',
          field: 'header',
          readOnly: readOnly,
          type: PlutoColumnType.text(),
        );

        final PlutoRow row = PlutoRow(
          cells: {
            'header': cell,
          },
        );

        rowIdx = 0;

        when(stateManager.configuration).thenReturn(configuration);

        await tester.pumpWidget(
          buildApp(
            cell: cell,
            column: column!,
            rowIdx: rowIdx,
            row: row,
          ),
        );

        await tester.pumpAndSettle(const Duration(seconds: 1));
      });
    }

    aCellWithConfiguration(
      const PlutoGridConfiguration(
        style: PlutoGridStyleConfig(
          enableCellBorderVertical: false,
          borderColor: Colors.deepOrange,
        ),
      ),
      readOnly: true,
    ).test(
      'if readOnly is true, should be set the color to cellColorInReadOnlyState.',
      (tester) async {
        expect(column!.readOnly, true);

        final target = find.descendant(
          of: find.byType(GestureDetector),
          matching: find.byType(DecoratedBox),
        );

        final container = target.evaluate().first.widget as DecoratedBox;

        final BoxDecoration decoration = container.decoration as BoxDecoration;

        final Color? color = decoration.color;

        expect(
          color,
          stateManager.configuration.style.cellColorInReadOnlyState,
        );
      },
    );

    aCellWithConfiguration(
      const PlutoGridConfiguration(
        style: PlutoGridStyleConfig(
          enableCellBorderVertical: true,
          borderColor: Colors.deepOrange,
        ),
      ),
      isCurrentCell: false,
      isSelectedCell: false,
    ).test(
      'if isCurrentCell, isSelectedCell are false '
      'and enableColumnBorder is true, '
      'should be set the border.',
      (tester) async {
        final target = find.descendant(
          of: find.byType(GestureDetector),
          matching: find.byType(DecoratedBox),
        );

        final container = target.evaluate().first.widget as DecoratedBox;

        final BoxDecoration decoration = container.decoration as BoxDecoration;

        final BorderDirectional border = decoration.border as BorderDirectional;

        expect(
          border.end.color,
          stateManager.configuration.style.borderColor,
        );
      },
    );

    aCellWithConfiguration(
      const PlutoGridConfiguration(
        style: PlutoGridStyleConfig(
          enableCellBorderVertical: false,
          borderColor: Colors.deepOrange,
        ),
      ),
      isCurrentCell: false,
      isSelectedCell: false,
    ).test(
      'if isCurrentCell, isSelectedCell are false '
      'and enableColumnBorder is false, '
      'should not be set the border.',
      (tester) async {
        final target = find.descendant(
          of: find.byType(GestureDetector),
          matching: find.byType(DecoratedBox),
        );

        final container = target.evaluate().first.widget as DecoratedBox;

        final BoxDecoration decoration = container.decoration as BoxDecoration;

        final BorderDirectional? border =
            decoration.border as BorderDirectional?;

        expect(border, isNull);
      },
    );
  });
}
