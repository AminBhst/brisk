import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';

void main() {
  group('text', () {
    const textTypeColumn = PlutoColumnTypeText();

    test('text 속성 접근시 TypeError 가 발생 되지 않아야 한다.', () {
      expect(() => textTypeColumn.text, isNot(throwsA(isA<TypeError>())));
    });

    test('number 속성 접근시 TypeError 가 발생 되어야 한다.', () {
      expect(() => textTypeColumn.number, throwsA(isA<TypeError>()));
    });

    test('currency 속성 접근시 TypeError 가 발생 되어야 한다.', () {
      expect(() => textTypeColumn.currency, throwsA(isA<TypeError>()));
    });

    test('select 속성 접근시 TypeError 가 발생 되어야 한다.', () {
      expect(() => textTypeColumn.select, throwsA(isA<TypeError>()));
    });

    test('date 속성 접근시 TypeError 가 발생 되어야 한다.', () {
      expect(() => textTypeColumn.date, throwsA(isA<TypeError>()));
    });

    test('time 속성 접근시 TypeError 가 발생 되어야 한다.', () {
      expect(() => textTypeColumn.time, throwsA(isA<TypeError>()));
    });
  });

  group('time', () {
    group('compare', () {
      const timeColumn = PlutoColumnTypeTime();

      test('동일한 값인 경우 0 을 리턴해야 한다.', () {
        expect(timeColumn.compare('00:00', '00:00'), 0);
      });

      test('a 값이 큰 경우 1 을 리턴해야 한다.', () {
        expect(timeColumn.compare('12:00', '00:00'), 1);
      });

      test('b 값이 큰 경우 -1 을 리턴해야 한다.', () {
        expect(timeColumn.compare('12:00', '24:00'), -1);
      });

      test('a 값이 null 이고 b 값이 있는 경우 -1 을 리턴해야 한다.', () {
        expect(timeColumn.compare(null, '00:00'), -1);
      });

      test('b 값이 null 이고 a 값이 있는 경우 1 을 리턴해야 한다.', () {
        expect(timeColumn.compare('00:00', null), 1);
      });
    });
  });
}
