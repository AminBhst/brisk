import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:pluto_grid/src/ui/pluto_base_column_footer.dart';

import '../../mock/shared_mocks.mocks.dart';

void main() {
  late MockPlutoGridStateManager stateManager;

  late PlutoGridConfiguration configuration;

  buildWidget({
    required WidgetTester tester,
    required PlutoColumn column,
    bool enableColumnBorderVertical = true,
  }) async {
    stateManager = MockPlutoGridStateManager();

    configuration = PlutoGridConfiguration(
      style: PlutoGridStyleConfig(
        enableColumnBorderVertical: enableColumnBorderVertical,
      ),
    );

    when(stateManager.configuration).thenReturn(configuration);
    when(stateManager.style).thenReturn(configuration.style);

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: PlutoBaseColumnFooter(
            stateManager: stateManager,
            column: column,
          ),
        ),
      ),
    );
  }

  testWidgets(
    'footerRenderer 가 없는 경우 SizedBox 가 렌더링 되어야 한다.',
    (tester) async {
      final column = PlutoColumn(
        title: 'column',
        field: 'column',
        type: PlutoColumnType.number(),
      );

      await buildWidget(tester: tester, column: column);

      expect(find.byType(SizedBox), findsOneWidget);
    },
  );

  testWidgets(
    'footerRenderer 가 있는 경우 전달한 위젯이 렌더링 되어야 한다.',
    (tester) async {
      final column = PlutoColumn(
        title: 'column',
        field: 'column',
        type: PlutoColumnType.number(),
        footerRenderer: (ctx) {
          return const Text('footerRenderer');
        },
      );

      await buildWidget(tester: tester, column: column);

      expect(find.text('footerRenderer'), findsOneWidget);
    },
  );

  testWidgets(
    'border.end 가 렌더링 되어야 한다. (enableColumnBorderVertical 기본값 true)',
    (tester) async {
      final column = PlutoColumn(
        title: 'column',
        field: 'column',
        type: PlutoColumnType.number(),
      );

      await buildWidget(tester: tester, column: column);

      final DecoratedBox box = find
          .byType(DecoratedBox)
          .first
          .evaluate()
          .first
          .widget as DecoratedBox;

      final decoration = box.decoration as BoxDecoration;

      final border = decoration.border as BorderDirectional;

      expect(border.end.width, 1.0);
      expect(border.end.color, stateManager.style.borderColor);

      expect(border.top, BorderSide.none);
      expect(border.bottom, BorderSide.none);
      expect(border.start, BorderSide.none);
    },
  );

  testWidgets(
    'enableColumnBorderVertical 가 false 인 경우 border.end 가 렌더링 되지 않아야 한다.',
    (tester) async {
      final column = PlutoColumn(
        title: 'column',
        field: 'column',
        type: PlutoColumnType.number(),
      );

      await buildWidget(
        tester: tester,
        column: column,
        enableColumnBorderVertical: false,
      );

      final DecoratedBox box = find
          .byType(DecoratedBox)
          .first
          .evaluate()
          .first
          .widget as DecoratedBox;

      final decoration = box.decoration as BoxDecoration;

      final border = decoration.border as BorderDirectional;

      expect(border.top, BorderSide.none);
      expect(border.bottom, BorderSide.none);
      expect(border.start, BorderSide.none);
      expect(border.end, BorderSide.none);
    },
  );

  testWidgets(
    'column 의 backgroundColor 가 적용 되어야 한다.',
    (tester) async {
      final column = PlutoColumn(
        title: 'column',
        field: 'column',
        type: PlutoColumnType.number(),
        backgroundColor: Colors.blue,
      );

      await buildWidget(
        tester: tester,
        column: column,
        enableColumnBorderVertical: false,
      );

      final DecoratedBox box = find
          .byType(DecoratedBox)
          .first
          .evaluate()
          .first
          .widget as DecoratedBox;

      final decoration = box.decoration as BoxDecoration;

      expect(decoration.color, Colors.blue);
    },
  );
}
