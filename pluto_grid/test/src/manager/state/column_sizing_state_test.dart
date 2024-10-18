import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../helper/column_helper.dart';
import '../../../mock/shared_mocks.mocks.dart';

void main() {
  group('getColumnsAutoSizeHelper', () {
    test('columns.isEmpty 이면 assertion 이 발생 되어야 한다.', () {
      final stateManager = PlutoGridStateManager(
        columns: [],
        rows: [],
        gridFocusNode: MockFocusNode(),
        scroll: MockPlutoGridScrollController(),
        configuration: const PlutoGridConfiguration(
          columnSize: PlutoGridColumnSizeConfig(
            autoSizeMode: PlutoAutoSizeMode.equal,
          ),
        ),
      );

      expect(() {
        stateManager.getColumnsAutoSizeHelper(
          columns: [],
          maxWidth: 500,
        );
      }, throwsAssertionError);
    });

    test('PlutoAutoSizeMode.none 이면 assertion 이 발생 되어야 한다.', () {
      final columns = ColumnHelper.textColumn('title', count: 5);

      final stateManager = PlutoGridStateManager(
        columns: columns,
        rows: [],
        gridFocusNode: MockFocusNode(),
        scroll: MockPlutoGridScrollController(),
        configuration: const PlutoGridConfiguration(
          columnSize: PlutoGridColumnSizeConfig(
            autoSizeMode: PlutoAutoSizeMode.none,
          ),
        ),
      );

      expect(() {
        stateManager.getColumnsAutoSizeHelper(
          columns: columns,
          maxWidth: 500,
        );
      }, throwsAssertionError);
    });

    test('PlutoAutoSizeMode.equal 이면 PlutoAutoSize 를 리턴해야 한다.', () {
      final columns = ColumnHelper.textColumn('title', count: 5);

      final stateManager = PlutoGridStateManager(
        columns: columns,
        rows: [],
        gridFocusNode: MockFocusNode(),
        scroll: MockPlutoGridScrollController(),
        configuration: const PlutoGridConfiguration(
          columnSize: PlutoGridColumnSizeConfig(
            autoSizeMode: PlutoAutoSizeMode.equal,
          ),
        ),
      );

      final helper = stateManager.getColumnsAutoSizeHelper(
        columns: columns,
        maxWidth: 500,
      );

      expect(helper, isA<PlutoAutoSize>());
    });

    test('PlutoAutoSizeMode.scale 이면 PlutoAutoSize 를 리턴해야 한다.', () {
      final columns = ColumnHelper.textColumn('title', count: 5);

      final stateManager = PlutoGridStateManager(
        columns: columns,
        rows: [],
        gridFocusNode: MockFocusNode(),
        scroll: MockPlutoGridScrollController(),
        configuration: const PlutoGridConfiguration(
          columnSize: PlutoGridColumnSizeConfig(
            autoSizeMode: PlutoAutoSizeMode.scale,
          ),
        ),
      );

      final helper = stateManager.getColumnsAutoSizeHelper(
        columns: columns,
        maxWidth: 500,
      );

      expect(helper, isA<PlutoAutoSize>());
    });
  });

  group('getColumnsResizeHelper', () {
    test('PlutoResizeMode.none 이면 assertion 이 발생 되어야 한다.', () {
      final columns = ColumnHelper.textColumn('title', count: 5);

      final stateManager = PlutoGridStateManager(
        columns: columns,
        rows: [],
        gridFocusNode: MockFocusNode(),
        scroll: MockPlutoGridScrollController(),
        configuration: const PlutoGridConfiguration(
          columnSize: PlutoGridColumnSizeConfig(
            resizeMode: PlutoResizeMode.none,
          ),
        ),
      );

      expect(() {
        stateManager.getColumnsResizeHelper(
          columns: columns,
          column: columns.first,
          offset: 10,
        );
      }, throwsAssertionError);
    });

    test('PlutoResizeMode.normal 이면 assertion 이 발생 되어야 한다.', () {
      final columns = ColumnHelper.textColumn('title', count: 5);

      final stateManager = PlutoGridStateManager(
        columns: columns,
        rows: [],
        gridFocusNode: MockFocusNode(),
        scroll: MockPlutoGridScrollController(),
        configuration: const PlutoGridConfiguration(
          columnSize: PlutoGridColumnSizeConfig(
            resizeMode: PlutoResizeMode.normal,
          ),
        ),
      );

      expect(() {
        stateManager.getColumnsResizeHelper(
          columns: columns,
          column: columns.first,
          offset: 10,
        );
      }, throwsAssertionError);
    });

    test('columns.isEmpty 이면 assertion 이 발생 되어야 한다.', () {
      final columns = <PlutoColumn>[];

      final stateManager = PlutoGridStateManager(
        columns: columns,
        rows: [],
        gridFocusNode: MockFocusNode(),
        scroll: MockPlutoGridScrollController(),
        configuration: const PlutoGridConfiguration(
          columnSize: PlutoGridColumnSizeConfig(
            resizeMode: PlutoResizeMode.normal,
          ),
        ),
      );

      expect(() {
        stateManager.getColumnsResizeHelper(
          columns: columns,
          column: ColumnHelper.textColumn('title').first,
          offset: 10,
        );
      }, throwsAssertionError);
    });
  });
}
