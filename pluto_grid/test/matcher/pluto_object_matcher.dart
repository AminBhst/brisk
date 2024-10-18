import 'package:flutter_test/flutter_test.dart';

class PlutoObjectMatcher<T> extends Matcher {
  PlutoObjectMatcher({
    this.rule,
  });

  bool Function(T object)? rule;

  @override
  bool matches(dynamic item, Map matchState) {
    if (item is! T) {
      return false;
    }

    return rule!(item);
  }

  @override
  Description describe(Description description) {
    return description.add('Object that passed the rule.');
  }
}
