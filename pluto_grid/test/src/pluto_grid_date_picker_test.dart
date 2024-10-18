import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart' as intl;
import 'package:mockito/mockito.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:pluto_grid/src/ui/ui.dart';

import '../helper/pluto_widget_test_helper.dart';
import '../matcher/pluto_object_matcher.dart';
import '../mock/mock_methods.dart';

final now = DateTime.now();

final mockListener = MockMethods();

void main() {
  late PlutoGridStateManager stateManager;

  buildPopup({
    required String format,
    required String headerFormat,
    DateTime? initDate,
    DateTime? startDate,
    DateTime? endDate,
    PlutoOnLoadedEventCallback? onLoaded,
    PlutoOnSelectedEventCallback? onSelected,
    double? itemHeight,
    PlutoGridConfiguration? configuration,
    TextDirection textDirection = TextDirection.ltr,
  }) {
    final dateFormat = intl.DateFormat(format);

    final headerDateFormat = intl.DateFormat(headerFormat);

    return PlutoWidgetTestHelper('Build date picker.', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: Directionality(
              textDirection: textDirection,
              child: Builder(
                builder: (BuildContext context) {
                  return TextButton(
                    onPressed: () {
                      PlutoGridDatePicker(
                        context: context,
                        dateFormat: dateFormat,
                        headerDateFormat: headerDateFormat,
                        initDate: initDate,
                        startDate: startDate,
                        endDate: endDate,
                        onLoaded: onLoaded,
                        onSelected: onSelected,
                        itemHeight:
                            itemHeight ?? PlutoGridSettings.rowTotalHeight,
                        configuration:
                            configuration ?? const PlutoGridConfiguration(),
                      );
                    },
                    child: const Text('open date picker'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextButton));

      await tester.pumpAndSettle();
    });
  }

  buildPopup(
    format: 'yyyy-MM-dd',
    headerFormat: 'yyyy-MM',
    onLoaded: (event) => stateManager = event.stateManager,
  ).test(
    'Directionality 가 기본값 ltr 이어야 한다.',
    (tester) async {
      expect(stateManager.isLTR, true);
      expect(stateManager.isRTL, false);
    },
  );

  buildPopup(
    format: 'yyyy-MM-dd',
    headerFormat: 'yyyy-MM',
    onLoaded: (event) => stateManager = event.stateManager,
    textDirection: TextDirection.rtl,
  ).test(
    'Directionality.rtl 인 경우 적용 되어야 한다.',
    (tester) async {
      expect(stateManager.isLTR, false);
      expect(stateManager.isRTL, true);
    },
  );

  buildPopup(
    format: 'yyyy-MM-dd',
    headerFormat: 'yyyy-MM',
    initDate: DateTime(2022, 7, 27),
    textDirection: TextDirection.rtl,
  ).test(
    'Directionality.rtl 인 경우 날짜 셀의 위치가 LTR 반대로 적용 되어야 한다.',
    (tester) async {
      final day26 = find.ancestor(
        of: find.text('26'),
        matching: find.byType(PlutoBaseCell),
      );
      final day27 = find.ancestor(
        of: find.text('27'),
        matching: find.byType(PlutoBaseCell),
      );
      final day28 = find.ancestor(
        of: find.text('28'),
        matching: find.byType(PlutoBaseCell),
      );

      final day26Dx = tester.getTopRight(day26).dx;
      final day27Dx = tester.getTopRight(day27).dx;
      final day28Dx = tester.getTopRight(day28).dx;

      // 가장 앞쪽(우측)에 있는 26일 위치에서 다음 좌측에 있는 27일 위치를 빼면 셀 넓이.
      expect(day26Dx - day27Dx, PlutoGridDatePicker.dateCellWidth);
      expect(day27Dx - day28Dx, PlutoGridDatePicker.dateCellWidth);
    },
  );

  buildPopup(
    format: 'yyyy-MM-dd',
    headerFormat: 'yyyy-MM',
    onLoaded: (event) => stateManager = event.stateManager,
  ).test(
    'DatePicker 는 autoSizeMode, resizeMode 가 적용되지 않아야 한다.',
    (tester) async {
      expect(stateManager.enableColumnsAutoSize, false);

      expect(stateManager.activatedColumnsAutoSize, false);

      expect(
        stateManager.columnSizeConfig.autoSizeMode,
        PlutoAutoSizeMode.none,
      );

      expect(
        stateManager.columnSizeConfig.resizeMode,
        PlutoResizeMode.none,
      );
    },
  );

  buildPopup(
    format: 'yyyy-MM-dd',
    headerFormat: 'yyyy-MM',
  ).test(
    '높이와 넓이를 충족하는 위젯이 생성 되어야 한다.',
    (tester) async {
      final size = tester.getSize(find.byType(PlutoGrid));

      // 45 : 기본 행 넓이, 7 : 월~일
      expect(size.width, greaterThan(45 * 7));

      // 6주의 행을 보여준다.
      double rowsHeight = 6 * PlutoGridSettings.rowTotalHeight;

      // itemHeight * 2 = Header Height + Column Height
      double popupHeight = (PlutoGridSettings.rowTotalHeight * 2) +
          rowsHeight +
          PlutoGridSettings.totalShadowLineWidth +
          PlutoGridSettings.gridInnerSpacing;

      expect(size.height, popupHeight);
    },
  );

  buildPopup(
    format: 'yyyy-MM-dd',
    headerFormat: 'yyyy-MM',
  ).test(
    '년,월을 변경하는 IconButton 이 출력 되어야 한다.',
    (tester) async {
      expect(find.byType(IconButton), findsNWidgets(4));
    },
  );

  buildPopup(
    format: 'yyyy-MM-dd',
    headerFormat: 'yyyy-MM',
  ).test(
    'initDate, startDate, endDate 를 전달 하지 않은 경우, '
    '현재 달이 출력 되어야 한다.',
    (tester) async {
      final headerFormat = intl.DateFormat('yyyy-MM');

      final currentYearMonth = headerFormat.format(now);

      const firstDay = '1';

      expect(find.text(currentYearMonth), findsOneWidget);

      expect(find.text(firstDay), findsOneWidget);
    },
  );

  buildPopup(
    format: 'yyyy-MM-dd',
    headerFormat: 'yyyy-MM',
    startDate: DateTime(2022, 5, 10),
  ).test(
    'startDate 를 설정한 경우 해당 월이 출력 되어야 한다.',
    (tester) async {
      final headerFormat = intl.DateFormat('yyyy-MM');

      final currentYearMonth = headerFormat.format(DateTime(2022, 5, 10));

      expect(find.text(currentYearMonth), findsOneWidget);
    },
  );

  buildPopup(
    format: 'yyyy-MM-dd',
    headerFormat: 'yyyy-MM',
    initDate: DateTime(now.year, now.month, 20),
  ).test(
    'initDate 를 설정한 경우 해당 날짜가 선택 되어야 한다.',
    (tester) async {
      const selectedDay = '20';

      final selectedDayText = find.text(selectedDay).first;

      final selectedDayTextWidget =
          selectedDayText.first.evaluate().first.widget as Text;

      final selectedDayTextStyle = selectedDayTextWidget.style as TextStyle;

      expect(selectedDayText, findsOneWidget);

      expect(selectedDayTextStyle.color, Colors.white);

      final selectedDayWidget = find
          .ancestor(
            of: selectedDayText,
            matching: find.byType(DecoratedBox),
          )
          .first;

      final selectedDayContainer =
          selectedDayWidget.first.evaluate().first.widget as DecoratedBox;

      final decoration = selectedDayContainer.decoration as BoxDecoration;

      expect(selectedDayWidget, findsOneWidget);

      expect(decoration.color, Colors.lightBlue);
    },
  );

  buildPopup(
    format: 'yyyy-MM-dd',
    headerFormat: 'yyyy-MM',
  ).test(
    '현재 달에서 1일을 선택하고 키보드 방향키 위를 누르면, '
    '이전 달이 출력 되어야 한다.',
    (tester) async {
      final headerFormat = intl.DateFormat('yyyy-MM');

      final currentMonthYear = headerFormat.format(now);

      expect(find.text(currentMonthYear), findsOneWidget);

      await tester.tap(find.text('2'));
      await tester.tap(find.text('1'));

      await tester.pump();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowUp);

      await tester.pump();

      final expectDate = DateTime(now.year, now.month - 1);

      final expectMonthYear = headerFormat.format(expectDate);

      expect(find.text(expectMonthYear), findsOneWidget);
    },
  );

  buildPopup(
    format: 'yyyy-MM-dd',
    headerFormat: 'yyyy-MM',
    initDate: DateTime(2022, 6, 30),
  ).test(
    '2022.6.30 일을 선택하고 키보드 방향키 아래를 입력하면, '
    '다음 달이 출력 되어야 한다.',
    (tester) async {
      final headerFormat = intl.DateFormat('yyyy-MM');

      final currentMonthYear = headerFormat.format(DateTime(2022, 6, 30));

      expect(find.text(currentMonthYear), findsOneWidget);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowDown);

      await tester.pumpAndSettle();

      final expectDate = DateTime(2022, 7);

      final expectMonthYear = headerFormat.format(expectDate);

      expect(find.text(expectMonthYear), findsOneWidget);
    },
  );

  buildPopup(
    format: 'yyyy-MM-dd',
    headerFormat: 'yyyy-MM',
    initDate: DateTime(2022, 6, 5),
  ).test(
    '2022.6.5 일을 선택하고 키보드 방향키 왼쪽을 입력하면, '
    '이전 년이 출력 되어야 한다.',
    (tester) async {
      final headerFormat = intl.DateFormat('yyyy-MM');

      final currentMonthYear = headerFormat.format(DateTime(2022, 6, 5));

      expect(find.text(currentMonthYear), findsOneWidget);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowLeft);

      await tester.pump();

      final expectDate = DateTime(2021, 6);

      final expectMonthYear = headerFormat.format(expectDate);

      expect(find.text(expectMonthYear), findsOneWidget);
    },
  );

  buildPopup(
    format: 'yyyy-MM-dd',
    headerFormat: 'yyyy-MM',
    initDate: DateTime(2022, 6, 11),
  ).test(
    '2022.6.11 일을 선택하고 키보드 방향키 오른쪽을 입력하면, '
    '다음 년이 출력 되어야 한다.',
    (tester) async {
      final headerFormat = intl.DateFormat('yyyy-MM');

      final currentMonthYear = headerFormat.format(DateTime(2022, 6, 11));

      expect(find.text(currentMonthYear), findsOneWidget);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowRight);

      await tester.pump();

      final expectDate = DateTime(2023, 6);

      final expectMonthYear = headerFormat.format(expectDate);

      expect(find.text(expectMonthYear), findsOneWidget);
    },
  );

  buildPopup(
    format: 'yyyy-MM-dd',
    headerFormat: 'yyyy-MM',
    initDate: DateTime(2022, 6, 11),
    onSelected: mockListener.oneParamReturnVoid<PlutoGridOnSelectedEvent>,
  ).test(
    '2022.6.11 일을 선택하고 탭하면, '
    'onSelected 콜백이 호출 되어야 한다.',
    (tester) async {
      await tester.tap(find.text('11'));

      await tester.pump();

      verify(
        mockListener.oneParamReturnVoid(argThat(
            PlutoObjectMatcher<PlutoGridOnSelectedEvent>(rule: (object) {
          return object.cell!.value == '2022-06-11';
        }))),
      ).called(1);
    },
  );

  buildPopup(
    format: 'yyyy-MM-dd',
    headerFormat: 'yyyy-MM',
    initDate: DateTime(2022, 6, 11),
    onLoaded: mockListener.oneParamReturnVoid<PlutoGridOnLoadedEvent>,
  ).test(
    '2022.6.11 일을 선택하고 탭하면, '
    'onSelected 콜백이 호출 되어야 한다.',
    (tester) async {
      await tester.tap(find.text('11'));

      await tester.pump();

      verify(
        mockListener.oneParamReturnVoid(
          argThat(
            isA<PlutoGridOnLoadedEvent>(),
          ),
        ),
      ).called(1);
    },
  );
}
