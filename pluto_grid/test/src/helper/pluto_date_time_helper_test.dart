// ignore_for_file: slash_for_doc_comments

import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';

/**
  2022. 11 월 달력
  일   월   화   수   목   금   토
            1    2    3    4   5
   6   7    8    9   10  11   12
  13  14   15   16   17  18   19
 */
void main() {
  group('moveToFirstWeekday', () {
    test('2022.11.6(일) 인 경우 2022.11.6(일) 을 리턴 해야 한다.', () {
      final sampleDate = DateTime(2022, 11, 6);
      final expectedDate = DateTime(2022, 11, 6);
      expect(PlutoDateTimeHelper.moveToFirstWeekday(sampleDate), expectedDate);
    });

    test('2022.11.7(월) 인 경우 2022.11.6(일) 을 리턴 해야 한다.', () {
      final sampleDate = DateTime(2022, 11, 7);
      final expectedDate = DateTime(2022, 11, 6);
      expect(PlutoDateTimeHelper.moveToFirstWeekday(sampleDate), expectedDate);
    });

    test('2022.11.11(월) 인 경우 2022.11.6(일) 을 리턴 해야 한다.', () {
      final sampleDate = DateTime(2022, 11, 11);
      final expectedDate = DateTime(2022, 11, 6);
      expect(PlutoDateTimeHelper.moveToFirstWeekday(sampleDate), expectedDate);
    });
  });

  group('moveToLastWeekday', () {
    test('2022.11.6(일) 인 경우 2022.11.12(토) 을 리턴 해야 한다.', () {
      final sampleDate = DateTime(2022, 11, 6);
      final expectedDate = DateTime(2022, 11, 12);
      expect(PlutoDateTimeHelper.moveToLastWeekday(sampleDate), expectedDate);
    });

    test('2022.11.9(수) 인 경우 2022.11.12(토) 을 리턴 해야 한다.', () {
      final sampleDate = DateTime(2022, 11, 9);
      final expectedDate = DateTime(2022, 11, 12);
      expect(PlutoDateTimeHelper.moveToLastWeekday(sampleDate), expectedDate);
    });

    test('2022.11.12(토) 인 경우 2022.11.12(토) 을 리턴 해야 한다.', () {
      final sampleDate = DateTime(2022, 11, 12);
      final expectedDate = DateTime(2022, 11, 12);
      expect(PlutoDateTimeHelper.moveToLastWeekday(sampleDate), expectedDate);
    });
  });

  group('isValidRangeInMonth', () {
    test('start, end 가 null 인 경우 true 를 리턴해야 한다.', () {
      final date = DateTime(2022, 11, 12);
      expect(
        PlutoDateTimeHelper.isValidRangeInMonth(
          date: date,
          start: null,
          end: null,
        ),
        true,
      );
    });

    test(
      'start 가 2022.11.11 이고 date 가 2022.11.12 인 경우, '
      'true 를 리턴해야 한다.',
      () {
        final date = DateTime(2022, 11, 12);
        final start = DateTime(2022, 11, 11);
        expect(
          PlutoDateTimeHelper.isValidRangeInMonth(
            date: date,
            start: start,
            end: null,
          ),
          true,
        );
      },
    );

    test(
      'end 가 2022.11.12 이고 date 가 2022.11.12 인 경우, '
      'true 를 리턴해야 한다.',
      () {
        final date = DateTime(2022, 11, 12);
        final end = DateTime(2022, 11, 13);
        expect(
          PlutoDateTimeHelper.isValidRangeInMonth(
            date: date,
            start: null,
            end: end,
          ),
          true,
        );
      },
    );

    test(
      'start 가 2022.11.13 이고 date 가 2022.11.12 인 경우, '
      'true 를 리턴해야 한다.',
      () {
        final date = DateTime(2022, 11, 12);
        final start = DateTime(2022, 11, 13);
        expect(
          PlutoDateTimeHelper.isValidRangeInMonth(
            date: date,
            start: start,
            end: null,
          ),
          true,
        );
      },
    );

    test(
      'end 가 2022.11.11 이고 date 가 2022.11.12 인 경우, '
      'true 를 리턴해야 한다.',
      () {
        final date = DateTime(2022, 11, 12);
        final end = DateTime(2022, 11, 11);
        expect(
          PlutoDateTimeHelper.isValidRangeInMonth(
            date: date,
            start: null,
            end: end,
          ),
          true,
        );
      },
    );

    test(
      'start 가 2022.10.13 이고 date 가 2022.11.12 인 경우, '
      'true 를 리턴해야 한다.',
      () {
        final date = DateTime(2022, 11, 12);
        final start = DateTime(2022, 10, 13);
        expect(
          PlutoDateTimeHelper.isValidRangeInMonth(
            date: date,
            start: start,
            end: null,
          ),
          true,
        );
      },
    );

    test(
      'end 가 2022.12.13 이고 date 가 2022.11.12 인 경우, '
      'true 를 리턴해야 한다.',
      () {
        final date = DateTime(2022, 11, 12);
        final end = DateTime(2022, 12, 13);
        expect(
          PlutoDateTimeHelper.isValidRangeInMonth(
            date: date,
            start: null,
            end: end,
          ),
          true,
        );
      },
    );

    test(
      'start 가 2022.12.13 이고 date 가 2022.11.12 인 경우, '
      'false 를 리턴해야 한다.',
      () {
        final date = DateTime(2022, 11, 12);
        final start = DateTime(2022, 12, 13);
        expect(
          PlutoDateTimeHelper.isValidRangeInMonth(
            date: date,
            start: start,
            end: null,
          ),
          false,
        );
      },
    );

    test(
      'end 가 2022.10.13 이고 date 가 2022.11.12 인 경우, '
      'false 를 리턴해야 한다.',
      () {
        final date = DateTime(2022, 11, 12);
        final end = DateTime(2022, 10, 13);
        expect(
          PlutoDateTimeHelper.isValidRangeInMonth(
            date: date,
            start: null,
            end: end,
          ),
          false,
        );
      },
    );
  });
}
