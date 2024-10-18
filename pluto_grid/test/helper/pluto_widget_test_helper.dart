import 'package:flutter_test/flutter_test.dart';

typedef PlutoWidgetTestContext = Future<void> Function(
  String description,
  Function(WidgetTester tester) callback,
);

typedef PlutoWidgetTestCallback = Future<void> Function(WidgetTester tester);

class PlutoWidgetTestHelper {
  PlutoWidgetTestHelper(
    String description,
    WidgetTesterCallback testContext,
  ) {
    _setTestContext(description, testContext);
  }

  late PlutoWidgetTestContext _testContext;

  void _setTestContext(
      String contextDescription, WidgetTesterCallback testContext) {
    _testContext =
        (String testDescription, Function(WidgetTester tester) callback) async {
      group(contextDescription, () {
        testWidgets(testDescription, (WidgetTester tester) async {
          await testContext(tester);
          await tester.pumpAndSettle();
          await callback(tester);
          await tester.pumpAndSettle();
        });
      });
    };
  }

  void test(String description, PlutoWidgetTestCallback widgetTest) async {
    await _testContext(description, (tester) async {
      await widgetTest(tester);
    });
  }
}
