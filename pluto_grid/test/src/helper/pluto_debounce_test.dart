import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';

void main() {
  group('PlutoDebounce', () {
    test(
      'duration 이 1ms 인 상태에서, '
      '1ms 동안 콜백을 10번 호출 하면, '
      '총 1번이 호출 되어야 한다.',
      () async {
        const duration = Duration(milliseconds: 1);
        final debounce = PlutoDebounce(duration: duration);
        int count = 0;
        callback() => ++count;

        for (final _ in List.generate(10, (i) => i)) {
          debounce.debounce(callback: callback);
        }

        await Future.delayed(duration);

        expect(count, 1);
      },
    );

    test(
      'duration 이 1ms 인 상태에서, '
      '2ms 동안 콜백을 10번 호출 하면, '
      '총 2번이 호출 되어야 한다.',
      () async {
        const duration = Duration(milliseconds: 1);
        final debounce = PlutoDebounce(duration: duration);
        int count = 0;
        callback() => ++count;

        for (final i in List.generate(10, (i) => i)) {
          debounce.debounce(callback: callback);
          if (i == 4) await Future.delayed(duration);
        }

        await Future.delayed(duration);

        expect(count, 2);
      },
    );
  });

  group('PlutoDebounceByHashCode', () {
    test(
      'duration 이 1ms 인 상태에서, '
      '1ms 동안 콜백을 10번 호출 하면, '
      'isDebounced false 조건이 총 1번이 호출 되어야 한다.',
      () async {
        const duration = Duration(milliseconds: 1);
        final debounce = PlutoDebounceByHashCode(duration: duration);
        String testString = 'test';
        int count = 0;

        for (final _ in List.generate(10, (i) => i)) {
          if (!debounce.isDebounced(hashCode: testString.hashCode)) {
            ++count;
          }
        }

        await Future.delayed(duration);

        expect(count, 1);
      },
    );

    test(
      'duration 이 1ms 인 상태에서, '
      '2ms 동안 콜백을 10번 호출 하면, '
      'isDebounced false 조건이 총 2번이 호출 되어야 한다.',
      () async {
        const duration = Duration(milliseconds: 1);
        final debounce = PlutoDebounceByHashCode(duration: duration);
        String testString = 'test';
        int count = 0;

        for (final i in List.generate(10, (i) => i)) {
          if (!debounce.isDebounced(hashCode: testString.hashCode)) {
            ++count;
          }
          if (i == 4) await Future.delayed(duration);
        }

        await Future.delayed(duration);

        expect(count, 2);
      },
    );

    test(
      'duration 이 1ms 인 상태에서, '
      '1ms 동안 다른 hashCode 로 콜백을 10번 호출 하면, '
      'isDebounced false 조건이 총 2번이 호출 되어야 한다.',
      () async {
        const duration = Duration(milliseconds: 1);
        final debounce = PlutoDebounceByHashCode(duration: duration);
        String testString = 'test';
        int count = 0;

        for (final i in List.generate(10, (i) => i)) {
          if (!debounce.isDebounced(hashCode: testString.hashCode)) {
            ++count;
          }

          if (i == 4) testString = 'changed test';
        }

        await Future.delayed(duration);

        expect(count, 2);
      },
    );
  });
}
