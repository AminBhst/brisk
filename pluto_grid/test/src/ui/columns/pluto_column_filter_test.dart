import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:pluto_grid/src/ui/ui.dart';
import 'package:rxdart/rxdart.dart';

import '../../../matcher/pluto_object_matcher.dart';
import '../../../mock/shared_mocks.mocks.dart';

void main() {
  late MockPlutoGridStateManager stateManager;
  late PublishSubject<PlutoNotifierEvent> subject;
  MockPlutoGridEventManager? eventManager;
  MockStreamSubscription<PlutoGridEvent> streamSubscription;

  setUp(() {
    stateManager = MockPlutoGridStateManager();
    eventManager = MockPlutoGridEventManager();
    streamSubscription = MockStreamSubscription();
    subject = PublishSubject<PlutoNotifierEvent>();

    const configuration = PlutoGridConfiguration();
    when(stateManager.eventManager).thenReturn(eventManager);
    when(stateManager.configuration).thenReturn(configuration);
    when(stateManager.style).thenReturn(configuration.style);
    when(stateManager.streamNotifier).thenAnswer((_) => subject);
    when(stateManager.localeText).thenReturn(const PlutoGridLocaleText());
    when(stateManager.filterRowsByField(any)).thenReturn([]);
    when(stateManager.columnHeight).thenReturn(
      stateManager.configuration.style.columnHeight,
    );
    when(stateManager.columnFilterHeight).thenReturn(
      stateManager.configuration.style.columnFilterHeight,
    );

    when(eventManager!.listener(any)).thenReturn(streamSubscription);
  });

  tearDown(() {
    subject.close();
  });

  testWidgets(
    'TextField 를 탭하면 setKeepFocus 가 false 로 호출 되어야 한다.',
    (WidgetTester tester) async {
      // given
      final PlutoColumn column = PlutoColumn(
        title: 'column title',
        field: 'column_field_name',
        type: PlutoColumnType.text(),
      );

      // when
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: PlutoColumnFilter(
              stateManager: stateManager,
              column: column,
            ),
          ),
        ),
      );

      // then
      await tester.tap(find.byType(TextField));

      verify(stateManager.setKeepFocus(false)).called(1);
    },
  );

  testWidgets(
    'TextField 에 텍스트를 입력하면 PlutoChangeColumnFilterEvent 가 호출 되어야 한다.',
    (WidgetTester tester) async {
      // given
      final PlutoColumn column = PlutoColumn(
        title: 'column title',
        field: 'column_field_name',
        type: PlutoColumnType.text(),
      );

      // when
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: PlutoColumnFilter(
              stateManager: stateManager,
              column: column,
            ),
          ),
        ),
      );

      // then
      await tester.enterText(find.byType(TextField), 'abc');

      verify(eventManager!.addEvent(
        argThat(PlutoObjectMatcher<PlutoGridChangeColumnFilterEvent>(
            rule: (object) {
          return object.column.field == column.field &&
              object.filterType.runtimeType == PlutoFilterTypeContains &&
              object.filterValue == 'abc';
        })),
      )).called(1);
    },
  );

  group('enabled', () {
    testWidgets(
      'enableFilterMenuItem 이 false 면 TextField 의 enabled 가 false 이어야 한다.',
      (WidgetTester tester) async {
        // given
        final PlutoColumn column = PlutoColumn(
          title: 'column title',
          field: 'column_field_name',
          type: PlutoColumnType.text(),
          enableFilterMenuItem: false,
        );

        // when
        await tester.pumpWidget(
          MaterialApp(
            home: Material(
              child: PlutoColumnFilter(
                stateManager: stateManager,
                column: column,
              ),
            ),
          ),
        );

        // then
        var textField = find.byType(TextField);

        var textFieldWidget = textField.evaluate().first.widget as TextField;

        expect(textFieldWidget.enabled, isFalse);
      },
    );

    testWidgets(
      'enableFilterMenuItem 이 true 이고, '
      'filterRows.length 가 2 이상 이면 TextField 의 enabled 가 false 이어야 한다.',
      (WidgetTester tester) async {
        // given
        final PlutoColumn column = PlutoColumn(
          title: 'column title',
          field: 'column_field_name',
          type: PlutoColumnType.text(),
          enableFilterMenuItem: true,
        );

        when(stateManager.filterRowsByField('column_field_name')).thenReturn([
          FilterHelper.createFilterRow(
            columnField: 'column_field_name',
          ),
          FilterHelper.createFilterRow(
            columnField: 'column_field_name',
          ),
        ]);

        // when
        await tester.pumpWidget(
          MaterialApp(
            home: Material(
              child: PlutoColumnFilter(
                stateManager: stateManager,
                column: column,
              ),
            ),
          ),
        );

        // then
        var textField = find.byType(TextField);

        var textFieldWidget = textField.evaluate().first.widget as TextField;

        expect(textFieldWidget.enabled, isFalse);
      },
    );

    testWidgets(
      'enableFilterMenuItem 이 true 이고, '
      'filterRows.length 가 2 미만이고, '
      'filterRows 에 filterFieldAllColumns 가 있으면, '
      'TextField 의 enabled 가 false 이어야 한다.',
      (WidgetTester tester) async {
        // given
        final PlutoColumn column = PlutoColumn(
          title: 'column title',
          field: 'column_field_name',
          type: PlutoColumnType.text(),
          enableFilterMenuItem: true,
        );

        when(stateManager.filterRowsByField(any)).thenReturn([
          FilterHelper.createFilterRow(
            columnField: FilterHelper.filterFieldAllColumns,
          ),
        ]);

        // when
        await tester.pumpWidget(
          MaterialApp(
            home: Material(
              child: PlutoColumnFilter(
                stateManager: stateManager,
                column: column,
              ),
            ),
          ),
        );

        // then
        var textField = find.byType(TextField);

        var textFieldWidget = textField.evaluate().first.widget as TextField;

        expect(textFieldWidget.enabled, isFalse);
      },
    );

    testWidgets(
      'enableFilterMenuItem 이 true 이고, '
      'filterRows.length 가 2 미만이고, '
      'filterRows 에 filterFieldAllColumns 가 없으면, '
      'TextField 의 enabled 가 true 이어야 한다.',
      (WidgetTester tester) async {
        // given
        final PlutoColumn column = PlutoColumn(
          title: 'column title',
          field: 'column_field_name',
          type: PlutoColumnType.text(),
          enableFilterMenuItem: true,
        );

        when(stateManager.filterRowsByField('column_field_name')).thenReturn([
          FilterHelper.createFilterRow(
            columnField: 'column_field_name',
          ),
        ]);

        when(
          stateManager.filterRowsByField(FilterHelper.filterFieldAllColumns),
        ).thenReturn([]);

        // when
        await tester.pumpWidget(
          MaterialApp(
            home: Material(
              child: PlutoColumnFilter(
                stateManager: stateManager,
                column: column,
              ),
            ),
          ),
        );

        // then
        var textField = find.byType(TextField);

        var textFieldWidget = textField.evaluate().first.widget as TextField;

        expect(textFieldWidget.enabled, isTrue);
      },
    );
  });
}
