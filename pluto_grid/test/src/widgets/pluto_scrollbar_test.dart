import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../helper/test_helper_util.dart';

void main() {
  late ScrollController verticalScroll;

  late ScrollController horizontalScroll;

  const double screenWidth = 500;

  const double screenHeight = 400;

  setUp(() {
    verticalScroll = ScrollController();
    horizontalScroll = ScrollController();
  });

  tearDown(() {
    verticalScroll.dispose();
    horizontalScroll.dispose();
  });

  Future<void> buildWidget(
    WidgetTester tester, {
    bool isMobile = false,
    bool enableHover = false,
    Set<PointerDeviceKind>? dragDevices,
  }) async {
    await TestHelperUtil.changeWidth(
      tester: tester,
      width: screenWidth,
      height: screenHeight,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ScrollConfiguration(
          behavior: PlutoScrollBehavior(
            isMobile: isMobile,
            userDragDevices: dragDevices,
          ),
          child: PlutoScrollbar(
            verticalController: verticalScroll,
            horizontalController: horizontalScroll,
            thickness: PlutoScrollbar.defaultScrollbarHoverWidth,
            thicknessWhileDragging: PlutoScrollbar.defaultScrollbarHoverWidth,
            mainAxisMargin: 0,
            crossAxisMargin: 0,
            enableHover: enableHover,
            child: SizedBox(
              width: screenWidth,
              height: screenHeight,
              child: SingleChildScrollView(
                controller: horizontalScroll,
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: 1000,
                  child: ListView.builder(
                    controller: verticalScroll,
                    itemCount: 10,
                    itemExtent: 50,
                    itemBuilder: (ctx, i) {
                      return SizedBox(
                        key: ValueKey('$i'),
                        width: 1000,
                        height: 50,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('8개의 행이 렌더링 되어야 한다.', (tester) async {
    await buildWidget(tester);
    // visible
    expect(find.byKey(const ValueKey('0')), findsOneWidget);
    expect(find.byKey(const ValueKey('1')), findsOneWidget);
    expect(find.byKey(const ValueKey('2')), findsOneWidget);
    expect(find.byKey(const ValueKey('3')), findsOneWidget);
    expect(find.byKey(const ValueKey('4')), findsOneWidget);
    expect(find.byKey(const ValueKey('5')), findsOneWidget);
    expect(find.byKey(const ValueKey('6')), findsOneWidget);
    expect(find.byKey(const ValueKey('7')), findsOneWidget);
    // invisible
    expect(find.byKey(const ValueKey('8')), findsNothing);
    expect(find.byKey(const ValueKey('9')), findsNothing);
  });

  testWidgets(
    '세로 스크롤바를 hover 하여 스크롤을 이동 할 수 있어야 한다.',
    (tester) async {
      await buildWidget(tester, enableHover: true);

      const scrollbarPosition = Offset(
        screenWidth - (PlutoScrollbar.defaultScrollbarHoverWidth / 2),
        50,
      );
      const moveOffset = 100.0;
      expect(verticalScroll.offset, 0);

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.moveTo(scrollbarPosition);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      await gesture.down(scrollbarPosition);
      await tester.pumpAndSettle();
      await gesture.moveTo(scrollbarPosition + const Offset(0, moveOffset));
      await tester.pumpAndSettle();
      await gesture.up();
      await tester.pumpAndSettle();

      expect(verticalScroll.offset, greaterThanOrEqualTo(moveOffset));
      expect(find.byKey(const ValueKey('8')), findsOneWidget);
      expect(find.byKey(const ValueKey('9')), findsOneWidget);
    },
  );

  testWidgets(
    '가로 스크롤바를 hover 하여 스크롤을 이동 할 수 있어야 한다.',
    (tester) async {
      await buildWidget(tester, enableHover: true);

      const scrollbarPosition = Offset(
        50,
        screenHeight - (PlutoScrollbar.defaultScrollbarHoverWidth / 2),
      );
      const moveOffset = 100.0;
      expect(horizontalScroll.offset, 0);

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.moveTo(scrollbarPosition);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      await gesture.down(scrollbarPosition);
      await tester.pumpAndSettle();
      await gesture.moveTo(scrollbarPosition + const Offset(moveOffset, 0));
      await tester.pumpAndSettle();
      await gesture.up();
      await tester.pumpAndSettle();

      expect(horizontalScroll.offset, greaterThanOrEqualTo(moveOffset));
    },
  );
}
