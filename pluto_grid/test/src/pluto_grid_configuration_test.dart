import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';

void main() {
  testWidgets(
    'dark 생성자를 호출 할 수 있어야 한다.',
    (WidgetTester tester) async {
      const PlutoGridConfiguration configuration = PlutoGridConfiguration.dark(
        style: PlutoGridStyleConfig(
          enableColumnBorderVertical: false,
        ),
      );

      expect(configuration.style.enableColumnBorderVertical, false);
    },
  );

  group('PlutoGridStyleConfig.copyWith', () {
    test('oddRowColor 를 null 로 설정하면 값이 변경 되어야 한다.', () {
      const style = PlutoGridStyleConfig(
        oddRowColor: Colors.cyan,
      );

      final copiedStyle = style.copyWith(
        oddRowColor: const PlutoOptional<Color?>(null),
      );

      expect(copiedStyle.oddRowColor, null);
    });

    test('evenRowColor 를 null 로 설정하면 값이 변경 되어야 한다.', () {
      const style = PlutoGridStyleConfig(
        evenRowColor: Colors.cyan,
      );

      final copiedStyle = style.copyWith(
        evenRowColor: const PlutoOptional<Color?>(null),
      );

      expect(copiedStyle.evenRowColor, null);
    });
  });

  group('PlutoGridColumnSizeConfig.copyWith', () {
    test('autoSizeMode 를 scale 설정하면 값이 변경 되어야 한다.', () {
      const size = PlutoGridColumnSizeConfig(
        autoSizeMode: PlutoAutoSizeMode.none,
      );

      final copiedSize = size.copyWith(autoSizeMode: PlutoAutoSizeMode.scale);

      expect(copiedSize.autoSizeMode, PlutoAutoSizeMode.scale);
    });

    test('resizeMode 를 none 으로 설정하면 값이 변경 되어야 한다.', () {
      const size = PlutoGridColumnSizeConfig(
        resizeMode: PlutoResizeMode.normal,
      );

      final copiedSize = size.copyWith(resizeMode: PlutoResizeMode.pushAndPull);

      expect(copiedSize.resizeMode, PlutoResizeMode.pushAndPull);
    });
  });

  group('configuration', () {
    test('configuration 의 값이 동일한 경우 동등 비교가 true 여야 한다.', () {
      const configurationA = PlutoGridConfiguration(
        enableMoveDownAfterSelecting: true,
        enterKeyAction: PlutoGridEnterKeyAction.editingAndMoveRight,
        style: PlutoGridStyleConfig(
          columnResizeIcon: IconData(0),
        ),
        scrollbar: PlutoGridScrollbarConfig(
          isAlwaysShown: true,
        ),
        localeText: PlutoGridLocaleText(
          setColumnsTitle: 'test',
        ),
      );

      const configurationB = PlutoGridConfiguration(
        enableMoveDownAfterSelecting: true,
        enterKeyAction: PlutoGridEnterKeyAction.editingAndMoveRight,
        style: PlutoGridStyleConfig(
          columnResizeIcon: IconData(0),
        ),
        scrollbar: PlutoGridScrollbarConfig(
          isAlwaysShown: true,
        ),
        localeText: PlutoGridLocaleText(
          setColumnsTitle: 'test',
        ),
      );

      expect(configurationA == configurationB, true);
    });

    test('configuration 의 값이 동일한 경우 hashCode 비교가 true 여야 한다.', () {
      const configurationA = PlutoGridConfiguration(
        enableMoveDownAfterSelecting: true,
        enterKeyAction: PlutoGridEnterKeyAction.editingAndMoveRight,
        style: PlutoGridStyleConfig(
          columnResizeIcon: IconData(0),
        ),
        scrollbar: PlutoGridScrollbarConfig(
          isAlwaysShown: true,
        ),
        localeText: PlutoGridLocaleText(
          setColumnsTitle: 'test',
        ),
      );

      const configurationB = PlutoGridConfiguration(
        enableMoveDownAfterSelecting: true,
        enterKeyAction: PlutoGridEnterKeyAction.editingAndMoveRight,
        style: PlutoGridStyleConfig(
          columnResizeIcon: IconData(0),
        ),
        scrollbar: PlutoGridScrollbarConfig(
          isAlwaysShown: true,
        ),
        localeText: PlutoGridLocaleText(
          setColumnsTitle: 'test',
        ),
      );

      expect(configurationA.hashCode == configurationB.hashCode, true);
    });

    test('enableMoveDownAfterSelecting 값이 다른 경우 동등 비교가 false 여야 한다.', () {
      const configurationA = PlutoGridConfiguration(
        enableMoveDownAfterSelecting: true,
        enterKeyAction: PlutoGridEnterKeyAction.editingAndMoveRight,
        style: PlutoGridStyleConfig(
          columnResizeIcon: IconData(0),
        ),
        scrollbar: PlutoGridScrollbarConfig(
          isAlwaysShown: true,
        ),
        localeText: PlutoGridLocaleText(
          setColumnsTitle: 'test',
        ),
      );

      const configurationB = PlutoGridConfiguration(
        enableMoveDownAfterSelecting: false,
        enterKeyAction: PlutoGridEnterKeyAction.editingAndMoveRight,
        style: PlutoGridStyleConfig(
          columnResizeIcon: IconData(0),
        ),
        scrollbar: PlutoGridScrollbarConfig(
          isAlwaysShown: true,
        ),
        localeText: PlutoGridLocaleText(
          setColumnsTitle: 'test',
        ),
      );

      expect(configurationA == configurationB, false);
    });

    test('isAlwaysShown 값이 다른 경우 동등 비교가 false 여야 한다.', () {
      const configurationA = PlutoGridConfiguration(
        enableMoveDownAfterSelecting: true,
        enterKeyAction: PlutoGridEnterKeyAction.editingAndMoveRight,
        style: PlutoGridStyleConfig(
          columnResizeIcon: IconData(0),
        ),
        scrollbar: PlutoGridScrollbarConfig(
          isAlwaysShown: true,
        ),
        localeText: PlutoGridLocaleText(
          setColumnsTitle: 'test',
        ),
      );

      const configurationB = PlutoGridConfiguration(
        enableMoveDownAfterSelecting: true,
        enterKeyAction: PlutoGridEnterKeyAction.editingAndMoveRight,
        style: PlutoGridStyleConfig(
          columnResizeIcon: IconData(0),
        ),
        scrollbar: PlutoGridScrollbarConfig(
          isAlwaysShown: false,
        ),
        localeText: PlutoGridLocaleText(
          setColumnsTitle: 'test',
        ),
      );

      expect(configurationA == configurationB, false);
    });

    test('localeText 값이 다른 경우 동등 비교가 false 여야 한다.', () {
      const configurationA = PlutoGridConfiguration(
        enableMoveDownAfterSelecting: true,
        enterKeyAction: PlutoGridEnterKeyAction.editingAndMoveRight,
        style: PlutoGridStyleConfig(
          columnResizeIcon: IconData(0),
        ),
        scrollbar: PlutoGridScrollbarConfig(
          isAlwaysShown: true,
        ),
        localeText: PlutoGridLocaleText(
          setColumnsTitle: 'setColumnsTitle',
        ),
      );

      const configurationB = PlutoGridConfiguration(
        enableMoveDownAfterSelecting: true,
        enterKeyAction: PlutoGridEnterKeyAction.editingAndMoveRight,
        style: PlutoGridStyleConfig(
          columnResizeIcon: IconData(0),
        ),
        scrollbar: PlutoGridScrollbarConfig(
          isAlwaysShown: true,
        ),
        localeText: PlutoGridLocaleText(
          setColumnsTitle: '컬럼제목설정',
        ),
      );

      expect(configurationA == configurationB, false);
    });
  });

  group('style', () {
    test('값이 동일한 경우 동등 비교가 true 여야 한다.', () {
      const styleA = PlutoGridStyleConfig(
        enableGridBorderShadow: true,
        oddRowColor: Colors.lightGreen,
        columnTextStyle: TextStyle(fontSize: 20),
        rowGroupExpandedIcon: IconData(0),
        gridBorderRadius: BorderRadius.all(Radius.circular(15)),
      );

      const styleB = PlutoGridStyleConfig(
        enableGridBorderShadow: true,
        oddRowColor: Colors.lightGreen,
        columnTextStyle: TextStyle(fontSize: 20),
        rowGroupExpandedIcon: IconData(0),
        gridBorderRadius: BorderRadius.all(Radius.circular(15)),
      );

      expect(styleA == styleB, true);
    });

    test('값이 동일한 경우 hashCode 비교가 true 여야 한다.', () {
      const styleA = PlutoGridStyleConfig(
        enableGridBorderShadow: true,
        oddRowColor: Colors.lightGreen,
        columnTextStyle: TextStyle(fontSize: 20),
        rowGroupExpandedIcon: IconData(0),
        gridBorderRadius: BorderRadius.all(Radius.circular(15)),
      );

      const styleB = PlutoGridStyleConfig(
        enableGridBorderShadow: true,
        oddRowColor: Colors.lightGreen,
        columnTextStyle: TextStyle(fontSize: 20),
        rowGroupExpandedIcon: IconData(0),
        gridBorderRadius: BorderRadius.all(Radius.circular(15)),
      );

      expect(styleA.hashCode == styleB.hashCode, true);
    });

    test('enableGridBorderShadow 값이 다른 경우 동등 비교가 false 여야 한다.', () {
      const styleA = PlutoGridStyleConfig(
        enableGridBorderShadow: true,
        oddRowColor: Colors.lightGreen,
        columnTextStyle: TextStyle(fontSize: 20),
        rowGroupExpandedIcon: IconData(0),
        gridBorderRadius: BorderRadius.all(Radius.circular(15)),
      );

      const styleB = PlutoGridStyleConfig(
        enableGridBorderShadow: false,
        oddRowColor: Colors.lightGreen,
        columnTextStyle: TextStyle(fontSize: 20),
        rowGroupExpandedIcon: IconData(0),
        gridBorderRadius: BorderRadius.all(Radius.circular(15)),
      );

      expect(styleA == styleB, false);
    });

    test('oddRowColor 값이 다른 경우 동등 비교가 false 여야 한다.', () {
      const styleA = PlutoGridStyleConfig(
        enableGridBorderShadow: true,
        oddRowColor: Colors.lightGreen,
        columnTextStyle: TextStyle(fontSize: 20),
        rowGroupExpandedIcon: IconData(0),
        gridBorderRadius: BorderRadius.all(Radius.circular(15)),
      );

      const styleB = PlutoGridStyleConfig(
        enableGridBorderShadow: true,
        oddRowColor: Colors.red,
        columnTextStyle: TextStyle(fontSize: 20),
        rowGroupExpandedIcon: IconData(0),
        gridBorderRadius: BorderRadius.all(Radius.circular(15)),
      );

      expect(styleA == styleB, false);
    });

    test('gridBorderRadius 값이 다른 경우 동등 비교가 false 여야 한다.', () {
      const styleA = PlutoGridStyleConfig(
        enableGridBorderShadow: true,
        oddRowColor: Colors.lightGreen,
        columnTextStyle: TextStyle(fontSize: 20),
        rowGroupExpandedIcon: IconData(0),
        gridBorderRadius: BorderRadius.horizontal(left: Radius.circular(10)),
      );

      const styleB = PlutoGridStyleConfig(
        enableGridBorderShadow: true,
        oddRowColor: Colors.lightGreen,
        columnTextStyle: TextStyle(fontSize: 20),
        rowGroupExpandedIcon: IconData(0),
        gridBorderRadius: BorderRadius.all(Radius.circular(15)),
      );

      expect(styleA == styleB, false);
    });
  });

  group('scrollbar', () {
    test('값이 동일한 경우 동등 비교가 true 여야 한다.', () {
      const scrollA = PlutoGridScrollbarConfig(
        draggableScrollbar: true,
        isAlwaysShown: true,
        scrollbarThicknessWhileDragging: 10,
      );

      const scrollB = PlutoGridScrollbarConfig(
        draggableScrollbar: true,
        isAlwaysShown: true,
        scrollbarThicknessWhileDragging: 10,
      );

      expect(scrollA == scrollB, true);
    });

    test('값이 동일한 경우 hashCode 비교가 true 여야 한다.', () {
      const scrollA = PlutoGridScrollbarConfig(
        draggableScrollbar: true,
        isAlwaysShown: true,
        scrollbarThicknessWhileDragging: 10,
      );

      const scrollB = PlutoGridScrollbarConfig(
        draggableScrollbar: true,
        isAlwaysShown: true,
        scrollbarThicknessWhileDragging: 10,
      );

      expect(scrollA.hashCode == scrollB.hashCode, true);
    });

    test('isAlwaysShown 값이 다른 경우 동등 비교가 false 여야 한다.', () {
      const scrollA = PlutoGridScrollbarConfig(
        draggableScrollbar: true,
        isAlwaysShown: true,
        scrollbarThicknessWhileDragging: 10,
      );

      const scrollB = PlutoGridScrollbarConfig(
        draggableScrollbar: true,
        isAlwaysShown: false,
        scrollbarThicknessWhileDragging: 10,
      );

      expect(scrollA == scrollB, false);
    });

    test('scrollbarRadiusWhileDragging 값이 다른 경우 동등 비교가 false 여야 한다.', () {
      const scrollA = PlutoGridScrollbarConfig(
        draggableScrollbar: true,
        isAlwaysShown: true,
        scrollbarRadiusWhileDragging: Radius.circular(10),
      );

      const scrollB = PlutoGridScrollbarConfig(
        draggableScrollbar: true,
        isAlwaysShown: true,
        scrollbarRadiusWhileDragging: Radius.circular(11),
      );

      expect(scrollA == scrollB, false);
    });
  });

  group('columnFilter', () {
    test('값이 동일한 경우 동등 비교가 true 여야 한다.', () {
      const columnFilterA = PlutoGridColumnFilterConfig(
        filters: [
          ...FilterHelper.defaultFilters,
        ],
        debounceMilliseconds: 300,
      );

      const columnFilterB = PlutoGridColumnFilterConfig(
        filters: [
          ...FilterHelper.defaultFilters,
        ],
        debounceMilliseconds: 300,
      );

      expect(columnFilterA == columnFilterB, true);
    });

    test('값이 동일한 경우 hashCode 비교가 true 여야 한다.', () {
      const columnFilterA = PlutoGridColumnFilterConfig(
        filters: [
          ...FilterHelper.defaultFilters,
        ],
        debounceMilliseconds: 300,
      );

      const columnFilterB = PlutoGridColumnFilterConfig(
        filters: [
          ...FilterHelper.defaultFilters,
        ],
        debounceMilliseconds: 300,
      );

      expect(columnFilterA.hashCode == columnFilterB.hashCode, true);
    });

    test('filters 값이 다른 경우 동등 비교가 false 여야 한다.', () {
      final columnFilterA = PlutoGridColumnFilterConfig(
        filters: [
          ...FilterHelper.defaultFilters,
        ].reversed.toList(),
        debounceMilliseconds: 300,
      );

      const columnFilterB = PlutoGridColumnFilterConfig(
        filters: [
          ...FilterHelper.defaultFilters,
        ],
        debounceMilliseconds: 300,
      );

      expect(columnFilterA == columnFilterB, false);
    });

    test('debounceMilliseconds 값이 다른 경우 동등 비교가 false 여야 한다.', () {
      const columnFilterA = PlutoGridColumnFilterConfig(
        filters: [
          ...FilterHelper.defaultFilters,
        ],
        debounceMilliseconds: 300,
      );

      const columnFilterB = PlutoGridColumnFilterConfig(
        filters: [
          ...FilterHelper.defaultFilters,
        ],
        debounceMilliseconds: 301,
      );

      expect(columnFilterA == columnFilterB, false);
    });
  });

  group('columnSize', () {
    test('PlutoGridColumnSizeConfig 의 속성이 동일한 경우 동등 비교가 true 여야 한다.', () {
      const sizeA = PlutoGridColumnSizeConfig(
        autoSizeMode: PlutoAutoSizeMode.scale,
        resizeMode: PlutoResizeMode.none,
        restoreAutoSizeAfterHideColumn: true,
        restoreAutoSizeAfterFrozenColumn: false,
        restoreAutoSizeAfterMoveColumn: true,
        restoreAutoSizeAfterInsertColumn: false,
        restoreAutoSizeAfterRemoveColumn: false,
      );

      const sizeB = PlutoGridColumnSizeConfig(
        autoSizeMode: PlutoAutoSizeMode.scale,
        resizeMode: PlutoResizeMode.none,
        restoreAutoSizeAfterHideColumn: true,
        restoreAutoSizeAfterFrozenColumn: false,
        restoreAutoSizeAfterMoveColumn: true,
        restoreAutoSizeAfterInsertColumn: false,
        restoreAutoSizeAfterRemoveColumn: false,
      );

      expect(sizeA == sizeB, true);
    });

    test('PlutoGridColumnSizeConfig 의 속성이 동일한 경우 hashCode 비교가 true 여야 한다.', () {
      const sizeA = PlutoGridColumnSizeConfig(
        autoSizeMode: PlutoAutoSizeMode.scale,
        resizeMode: PlutoResizeMode.none,
        restoreAutoSizeAfterHideColumn: true,
        restoreAutoSizeAfterFrozenColumn: false,
        restoreAutoSizeAfterMoveColumn: true,
        restoreAutoSizeAfterInsertColumn: false,
        restoreAutoSizeAfterRemoveColumn: false,
      );

      const sizeB = PlutoGridColumnSizeConfig(
        autoSizeMode: PlutoAutoSizeMode.scale,
        resizeMode: PlutoResizeMode.none,
        restoreAutoSizeAfterHideColumn: true,
        restoreAutoSizeAfterFrozenColumn: false,
        restoreAutoSizeAfterMoveColumn: true,
        restoreAutoSizeAfterInsertColumn: false,
        restoreAutoSizeAfterRemoveColumn: false,
      );

      expect(sizeA.hashCode == sizeB.hashCode, true);
    });

    test('PlutoGridColumnSizeConfig 의 속성이 다른 경우 동등 비교가 false 여야 한다.', () {
      const sizeA = PlutoGridColumnSizeConfig(
        autoSizeMode: PlutoAutoSizeMode.scale,
        resizeMode: PlutoResizeMode.none,
        restoreAutoSizeAfterHideColumn: true,
        restoreAutoSizeAfterFrozenColumn: false,
        restoreAutoSizeAfterMoveColumn: true,
        restoreAutoSizeAfterInsertColumn: false,
        restoreAutoSizeAfterRemoveColumn: false,
      );

      const sizeB = PlutoGridColumnSizeConfig(
        autoSizeMode: PlutoAutoSizeMode.scale,
        resizeMode: PlutoResizeMode.none,
        restoreAutoSizeAfterHideColumn: true,
        restoreAutoSizeAfterFrozenColumn: false,
        restoreAutoSizeAfterMoveColumn: true,
        restoreAutoSizeAfterInsertColumn: false,
        restoreAutoSizeAfterRemoveColumn: true,
      );

      expect(sizeA == sizeB, false);
    });
  });

  group('locale', () {
    test('locale 값이 동일한 경우 동등 비교가 true 여야 한다.', () {
      const localeA = PlutoGridLocaleText(
        unfreezeColumn: '고정해제',
        filterContains: '포함',
        loadingText: '로딩중',
      );

      const localeB = PlutoGridLocaleText(
        unfreezeColumn: '고정해제',
        filterContains: '포함',
        loadingText: '로딩중',
      );

      expect(localeA == localeB, true);
    });

    test('locale 값이 동일한 경우 hashCode 비교가 true 여야 한다.', () {
      const localeA = PlutoGridLocaleText(
        unfreezeColumn: '고정해제',
        filterContains: '포함',
        loadingText: '로딩중',
      );

      const localeB = PlutoGridLocaleText(
        unfreezeColumn: '고정해제',
        filterContains: '포함',
        loadingText: '로딩중',
      );

      expect(localeA.hashCode == localeB.hashCode, true);
    });

    test('locale 값이 다른 경우 동등 비교가 false 여야 한다.', () {
      const localeA = PlutoGridLocaleText(
        unfreezeColumn: '고정해제',
        filterContains: '포함',
        loadingText: '로딩중 입니다.',
      );

      const localeB = PlutoGridLocaleText(
        unfreezeColumn: '고정해제',
        filterContains: '포함',
        loadingText: '로딩중',
      );

      expect(localeA == localeB, false);
    });

    test('china 가 호출 되어야 한다.', () {
      const locale = PlutoGridLocaleText.china();

      expect(locale.loadingText, '加载中');
    });

    test('korean 이 호출 되어야 한다.', () {
      const locale = PlutoGridLocaleText.korean();

      expect(locale.loadingText, '로딩중');
    });

    test('russian 이 호출 되어야 한다.', () {
      const locale = PlutoGridLocaleText.russian();

      expect(locale.loadingText, 'Загрузка');
    });

    test('czech 이 호출 되어야 한다.', () {
      const locale = PlutoGridLocaleText.czech();

      expect(locale.loadingText, 'Načítání');
    });

    test('brazilianPortuguese 이 호출 되어야 한다.', () {
      const locale = PlutoGridLocaleText.brazilianPortuguese();

      expect(locale.loadingText, 'Carregando');
    });

    test('spanish 이 호출 되어야 한다.', () {
      const locale = PlutoGridLocaleText.spanish();

      expect(locale.loadingText, 'Cargando');
    });

    test('persian 이 호출 되어야 한다.', () {
      const locale = PlutoGridLocaleText.persian();

      expect(locale.loadingText, 'در حال بارگیری');
    });

    test('arabic 이 호출 되어야 한다.', () {
      const locale = PlutoGridLocaleText.arabic();

      expect(locale.loadingText, 'جاري التحميل');
    });

    test('norway 이 호출 되어야 한다.', () {
      const locale = PlutoGridLocaleText.norway();

      expect(locale.loadingText, 'Laster');
    });

    test('german 이 호출 되어야 한다.', () {
      const locale = PlutoGridLocaleText.german();

      expect(locale.loadingText, 'Lädt');
    });

    test('turkish 이 호출 되어야 한다.', () {
      const locale = PlutoGridLocaleText.turkish();

      expect(locale.loadingText, 'Yükleniyor');
    });

    test('japanese 이 호출 되어야 한다.', () {
      const locale = PlutoGridLocaleText.japanese();

      expect(locale.loadingText, 'にゃ〜');
    });
  });
}
