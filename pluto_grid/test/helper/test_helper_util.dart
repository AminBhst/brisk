import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

class TestHelperUtil {
  static Type typeOf<T>() => T;

  static Future<void> changeWidth({
    required WidgetTester tester,
    required double width,
    required double height,
  }) async {
    addTearDown(tester.view.resetPhysicalSize);

    tester.view.physicalSize = Size(width, height);

    tester.view.devicePixelRatio = 1.0;

    await tester.pumpAndSettle();
  }
}
