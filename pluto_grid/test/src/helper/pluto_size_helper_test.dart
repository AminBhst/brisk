import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';

class _ResizeItem {
  _ResizeItem({
    required this.index,
    required this.size,
    required this.minSize,
    this.suppressed = false,
  });

  final int index;

  double size;

  final double minSize;

  final bool suppressed;
}

void main() {
  group('PlutoAutoSizeHelper', () {
    group('PlutoAutoSizeMode.none.', () {
      const mode = PlutoAutoSizeMode.none;

      test('mode 를 none 으로 호출하면 예외가 발생 되어야 한다.', () {
        expect(() {
          PlutoAutoSizeHelper.items<_ResizeItem>(
            maxSize: 100,
            items: [],
            isSuppressed: (i) => false,
            getItemSize: (i) => i.size,
            getItemMinSize: (i) => i.minSize,
            setItemSize: (i, size) => i.size = size,
            mode: mode,
          );
        }, throwsException);
      });
    });

    group('PlutoAutoSizeMode.equal.', () {
      const mode = PlutoAutoSizeMode.equal;

      test('각 아이템의 사이즈가 동일하게 설정 되어야 한다.', () {
        final items = [
          _ResizeItem(index: 0, size: 100, minSize: 50),
          _ResizeItem(index: 1, size: 120, minSize: 50),
          _ResizeItem(index: 2, size: 130, minSize: 50),
          _ResizeItem(index: 3, size: 140, minSize: 50),
          _ResizeItem(index: 4, size: 150, minSize: 50),
        ];

        PlutoAutoSizeHelper.items<_ResizeItem>(
          maxSize: 500,
          items: items,
          isSuppressed: (i) => i.suppressed,
          getItemSize: (i) => i.size,
          getItemMinSize: (i) => i.minSize,
          setItemSize: (i, size) => i.size = size,
          mode: mode,
        ).update();

        expect(items[0].size, 100);
        expect(items[1].size, 100);
        expect(items[2].size, 100);
        expect(items[3].size, 100);
        expect(items[4].size, 100);
      });

      test(
          '각 아이템의 최소크기의 합계 보다 maxSize 가 작은 경우, '
          '각 아이템은 minSize 로 설정 되어야 한다.', () {
        final items = [
          _ResizeItem(index: 0, size: 100, minSize: 50),
          _ResizeItem(index: 1, size: 120, minSize: 50),
          _ResizeItem(index: 2, size: 130, minSize: 50),
          _ResizeItem(index: 3, size: 140, minSize: 50),
          _ResizeItem(index: 4, size: 150, minSize: 50),
        ];

        PlutoAutoSizeHelper.items<_ResizeItem>(
          maxSize: 200,
          items: items,
          isSuppressed: (i) => i.suppressed,
          getItemSize: (i) => i.size,
          getItemMinSize: (i) => i.minSize,
          setItemSize: (i, size) => i.size = size,
          mode: mode,
        ).update();

        expect(items[0].size, 50);
        expect(items[1].size, 50);
        expect(items[2].size, 50);
        expect(items[3].size, 50);
        expect(items[4].size, 50);
      });

      test('suppressed 인 아이템의 경우 사이즈가 변경되지 않아야 한다.', () {
        final items = [
          _ResizeItem(index: 0, size: 100, minSize: 50),
          _ResizeItem(index: 1, size: 120, minSize: 50, suppressed: true),
          _ResizeItem(index: 2, size: 130, minSize: 50),
          _ResizeItem(index: 3, size: 140, minSize: 50, suppressed: true),
          _ResizeItem(index: 4, size: 150, minSize: 50, suppressed: true),
        ];

        PlutoAutoSizeHelper.items<_ResizeItem>(
          maxSize: 200,
          items: items,
          isSuppressed: (i) => i.suppressed,
          getItemSize: (i) => i.size,
          getItemMinSize: (i) => i.minSize,
          setItemSize: (i, size) => i.size = size,
          mode: mode,
        ).update();

        expect(items[0].size, 50);
        expect(items[1].size, 120);
        expect(items[2].size, 50);
        expect(items[3].size, 140);
        expect(items[4].size, 150);
      });
    });

    group('PlutoAutoSizeMode.scale.', () {
      const mode = PlutoAutoSizeMode.scale;

      test('각 아이템의 사이즈가 비율에 맞게 설정 되어야 한다.', () {
        final items = [
          _ResizeItem(index: 0, size: 100, minSize: 50),
          _ResizeItem(index: 1, size: 200, minSize: 50),
          _ResizeItem(index: 2, size: 200, minSize: 50),
          _ResizeItem(index: 3, size: 100, minSize: 50),
          _ResizeItem(index: 4, size: 100, minSize: 50),
        ];

        final double scale = 500 / items.fold(0, (p, e) => p + e.size);

        PlutoAutoSizeHelper.items<_ResizeItem>(
          maxSize: 500,
          items: items,
          isSuppressed: (i) => i.suppressed,
          getItemSize: (i) => i.size,
          getItemMinSize: (i) => i.minSize,
          setItemSize: (i, size) => i.size = size,
          mode: mode,
        ).update();

        expect(items[0].size, 100 * scale);
        expect(items[1].size, 200 * scale);
        expect(items[2].size, 200 * scale);
        expect(items[3].size, 100 * scale);
        expect(items[4].size, 100 * scale);
      });

      test(
          '각 아이템의 최소크기의 합계 보다 maxSize 가 작은 경우, '
          '각 아이템은 minSize 로 설정 되어야 한다.', () {
        final items = [
          _ResizeItem(index: 0, size: 100, minSize: 50),
          _ResizeItem(index: 1, size: 200, minSize: 50),
          _ResizeItem(index: 2, size: 200, minSize: 50),
          _ResizeItem(index: 3, size: 100, minSize: 50),
          _ResizeItem(index: 4, size: 100, minSize: 50),
        ];

        PlutoAutoSizeHelper.items<_ResizeItem>(
          maxSize: 200,
          items: items,
          isSuppressed: (i) => i.suppressed,
          getItemSize: (i) => i.size,
          getItemMinSize: (i) => i.minSize,
          setItemSize: (i, size) => i.size = size,
          mode: mode,
        ).update();

        expect(items[0].size, 50);
        expect(items[1].size, 50);
        expect(items[2].size, 50);
        expect(items[3].size, 50);
        expect(items[4].size, 50);
      });

      test('suppressed 인 아이템의 경우 사이즈가 변경되지 않아야 한다.', () {
        final items = [
          _ResizeItem(index: 0, size: 100, minSize: 50),
          _ResizeItem(index: 1, size: 120, minSize: 50, suppressed: true),
          _ResizeItem(index: 2, size: 130, minSize: 50),
          _ResizeItem(index: 3, size: 140, minSize: 50, suppressed: true),
          _ResizeItem(index: 4, size: 150, minSize: 50, suppressed: true),
        ];

        // (전체 - suppressed 사이즈) / suppressed 가 아닌 아이템 사이즈
        const scale = (1000 - 410) / 230;

        PlutoAutoSizeHelper.items<_ResizeItem>(
          maxSize: 1000,
          items: items,
          isSuppressed: (i) => i.suppressed,
          getItemSize: (i) => i.size,
          getItemMinSize: (i) => i.minSize,
          setItemSize: (i, size) => i.size = size,
          mode: mode,
        ).update();

        expect(items[0].size, 100 * scale);
        expect(items[1].size, 120);
        expect(items[2].size, 130 * scale);
        expect(items[3].size, 140);
        expect(items[4].size, 150);
      });
    });
  });

  group('PlutoResizeHelper', () {
    group('PlutoResizeMode.none', () {
      const mode = PlutoResizeMode.none;

      test('mode 가 none 이면 exception 이 발생 되어야 한다.', () {
        final items = <_ResizeItem>[];
        expect(() {
          PlutoResizeHelper.items<_ResizeItem>(
            offset: 0,
            items: items,
            isMainItem: (i) => i.index == 0,
            getItemSize: (i) => i.size,
            getItemMinSize: (i) => i.minSize,
            setItemSize: (i, size) => i.size = size,
            mode: mode,
          );
        }, throwsException);
      });
    });

    group('PlutoResizeMode.normal', () {
      const mode = PlutoResizeMode.normal;

      test('mode 가 normal 이면 exception 이 발생 되어야 한다.', () {
        final items = <_ResizeItem>[];
        expect(() {
          PlutoResizeHelper.items<_ResizeItem>(
            offset: 0,
            items: items,
            isMainItem: (i) => i.index == 0,
            getItemSize: (i) => i.size,
            getItemMinSize: (i) => i.minSize,
            setItemSize: (i, size) => i.size = size,
            mode: mode,
          );
        }, throwsException);
      });
    });

    group('PlutoResizeMode.pushAndPull', () {
      const mode = PlutoResizeMode.pushAndPull;

      test('0번의 사이즈가 10 증가 하고 1번의 사이즈가 10 감소해야 한다.', () {
        final items = <_ResizeItem>[
          _ResizeItem(index: 0, size: 200, minSize: 80),
          _ResizeItem(index: 1, size: 200, minSize: 80),
          _ResizeItem(index: 2, size: 200, minSize: 80),
          _ResizeItem(index: 3, size: 200, minSize: 80),
          _ResizeItem(index: 4, size: 200, minSize: 80),
        ];

        final helper = PlutoResizeHelper.items<_ResizeItem>(
          offset: 10,
          items: items,
          isMainItem: (i) => i.index == 0,
          getItemSize: (i) => i.size,
          getItemMinSize: (i) => i.minSize,
          setItemSize: (i, size) => i.size = size,
          mode: mode,
        );

        expect(helper.update(), true);
        expect(items[0].size, 210);
        expect(items[1].size, 190);
        expect(items[2].size, 200);
        expect(items[3].size, 200);
        expect(items[4].size, 200);
      });

      test('1번의 사이즈가 10 증가 하고 2번의 사이즈가 10 감소해야 한다.', () {
        final items = <_ResizeItem>[
          _ResizeItem(index: 0, size: 200, minSize: 80),
          _ResizeItem(index: 1, size: 200, minSize: 80),
          _ResizeItem(index: 2, size: 200, minSize: 80),
          _ResizeItem(index: 3, size: 200, minSize: 80),
          _ResizeItem(index: 4, size: 200, minSize: 80),
        ];

        final helper = PlutoResizeHelper.items<_ResizeItem>(
          offset: 10,
          items: items,
          isMainItem: (i) => i.index == 1,
          getItemSize: (i) => i.size,
          getItemMinSize: (i) => i.minSize,
          setItemSize: (i, size) => i.size = size,
          mode: mode,
        );

        expect(helper.update(), true);
        expect(items[0].size, 200);
        expect(items[1].size, 210);
        expect(items[2].size, 190);
        expect(items[3].size, 200);
        expect(items[4].size, 200);
      });

      test('3번의 사이즈가 10 증가 하고 4번의 사이즈가 10 감소해야 한다.', () {
        final items = <_ResizeItem>[
          _ResizeItem(index: 0, size: 200, minSize: 80),
          _ResizeItem(index: 1, size: 200, minSize: 80),
          _ResizeItem(index: 2, size: 200, minSize: 80),
          _ResizeItem(index: 3, size: 200, minSize: 80),
          _ResizeItem(index: 4, size: 200, minSize: 80),
        ];

        final helper = PlutoResizeHelper.items<_ResizeItem>(
          offset: 10,
          items: items,
          isMainItem: (i) => i.index == 3,
          getItemSize: (i) => i.size,
          getItemMinSize: (i) => i.minSize,
          setItemSize: (i, size) => i.size = size,
          mode: mode,
        );

        expect(helper.update(), true);
        expect(items[0].size, 200);
        expect(items[1].size, 200);
        expect(items[2].size, 200);
        expect(items[3].size, 210);
        expect(items[4].size, 190);
      });

      test('4번의 사이즈가 10 증가 하고 3번의 사이즈가 10 감소해야 한다.', () {
        final items = <_ResizeItem>[
          _ResizeItem(index: 0, size: 200, minSize: 80),
          _ResizeItem(index: 1, size: 200, minSize: 80),
          _ResizeItem(index: 2, size: 200, minSize: 80),
          _ResizeItem(index: 3, size: 200, minSize: 80),
          _ResizeItem(index: 4, size: 200, minSize: 80),
        ];

        final helper = PlutoResizeHelper.items<_ResizeItem>(
          offset: 10,
          items: items,
          isMainItem: (i) => i.index == 4,
          getItemSize: (i) => i.size,
          getItemMinSize: (i) => i.minSize,
          setItemSize: (i, size) => i.size = size,
          mode: mode,
        );

        expect(helper.update(), true);
        expect(items[0].size, 200);
        expect(items[1].size, 200);
        expect(items[2].size, 200);
        expect(items[3].size, 190);
        expect(items[4].size, 210);
      });

      test('4번의 사이즈가 10 감소 하고 3번의 사이즈가 10 증가해야 한다.', () {
        final items = <_ResizeItem>[
          _ResizeItem(index: 0, size: 200, minSize: 80),
          _ResizeItem(index: 1, size: 200, minSize: 80),
          _ResizeItem(index: 2, size: 200, minSize: 80),
          _ResizeItem(index: 3, size: 200, minSize: 80),
          _ResizeItem(index: 4, size: 200, minSize: 80),
        ];

        final helper = PlutoResizeHelper.items<_ResizeItem>(
          offset: -10,
          items: items,
          isMainItem: (i) => i.index == 4,
          getItemSize: (i) => i.size,
          getItemMinSize: (i) => i.minSize,
          setItemSize: (i, size) => i.size = size,
          mode: mode,
        );

        expect(helper.update(), true);
        expect(items[0].size, 200);
        expect(items[1].size, 200);
        expect(items[2].size, 200);
        expect(items[3].size, 210);
        expect(items[4].size, 190);
      });

      test('1번의 사이즈가 10 감소 하고 2번의 사이즈가 10 증가해야 한다.', () {
        final items = <_ResizeItem>[
          _ResizeItem(index: 0, size: 200, minSize: 80),
          _ResizeItem(index: 1, size: 200, minSize: 80),
          _ResizeItem(index: 2, size: 200, minSize: 80),
          _ResizeItem(index: 3, size: 200, minSize: 80),
          _ResizeItem(index: 4, size: 200, minSize: 80),
        ];

        final helper = PlutoResizeHelper.items<_ResizeItem>(
          offset: -10,
          items: items,
          isMainItem: (i) => i.index == 1,
          getItemSize: (i) => i.size,
          getItemMinSize: (i) => i.minSize,
          setItemSize: (i, size) => i.size = size,
          mode: mode,
        );

        expect(helper.update(), true);
        expect(items[0].size, 200);
        expect(items[1].size, 190);
        expect(items[2].size, 210);
        expect(items[3].size, 200);
        expect(items[4].size, 200);
      });

      test('1번의 사이즈를 최소 크기로 줄였을 때, 0번의 크기가 줄고, 2번의 크기가 늘어나야 한다.', () {
        final items = <_ResizeItem>[
          _ResizeItem(index: 0, size: 200, minSize: 80),
          _ResizeItem(index: 1, size: 80, minSize: 80),
          _ResizeItem(index: 2, size: 200, minSize: 80),
          _ResizeItem(index: 3, size: 200, minSize: 80),
          _ResizeItem(index: 4, size: 200, minSize: 80),
        ];

        final helper = PlutoResizeHelper.items<_ResizeItem>(
          offset: -10,
          items: items,
          isMainItem: (i) => i.index == 1,
          getItemSize: (i) => i.size,
          getItemMinSize: (i) => i.minSize,
          setItemSize: (i, size) => i.size = size,
          mode: mode,
        );

        expect(helper.update(), true);
        expect(items[0].size, 190);
        expect(items[1].size, 80);
        expect(items[2].size, 210);
        expect(items[3].size, 200);
        expect(items[4].size, 200);
      });

      test('1번의 사이즈를 최소 크기로 줄였을 때, 좌측에 더이상 큰 사이즈가 없는 경우 사이즈 변동이 없어야 한다.', () {
        final items = <_ResizeItem>[
          _ResizeItem(index: 0, size: 80, minSize: 80),
          _ResizeItem(index: 1, size: 80, minSize: 80),
          _ResizeItem(index: 2, size: 200, minSize: 80),
          _ResizeItem(index: 3, size: 200, minSize: 80),
          _ResizeItem(index: 4, size: 200, minSize: 80),
        ];

        final helper = PlutoResizeHelper.items<_ResizeItem>(
          offset: -10,
          items: items,
          isMainItem: (i) => i.index == 1,
          getItemSize: (i) => i.size,
          getItemMinSize: (i) => i.minSize,
          setItemSize: (i, size) => i.size = size,
          mode: mode,
        );

        expect(helper.update(), false);
        expect(items[0].size, 80);
        expect(items[1].size, 80);
        expect(items[2].size, 200);
        expect(items[3].size, 200);
        expect(items[4].size, 200);
      });

      test('2번의 크기를 최대로 넓히면 좌우측 넓이가 최소로 줄어야 한다.', () {
        final items = <_ResizeItem>[
          _ResizeItem(index: 0, size: 200, minSize: 80),
          _ResizeItem(index: 1, size: 200, minSize: 80),
          _ResizeItem(index: 2, size: 200, minSize: 80),
          _ResizeItem(index: 3, size: 200, minSize: 80),
          _ResizeItem(index: 4, size: 200, minSize: 80),
        ];

        final helper = PlutoResizeHelper.items<_ResizeItem>(
          offset: 1000 - 320 - 200,
          items: items,
          isMainItem: (i) => i.index == 2,
          getItemSize: (i) => i.size,
          getItemMinSize: (i) => i.minSize,
          setItemSize: (i, size) => i.size = size,
          mode: mode,
        );

        expect(helper.update(), true);
        expect(items[0].size, 80);
        expect(items[1].size, 80);
        expect(items[2].size, 680);
        expect(items[3].size, 80);
        expect(items[4].size, 80);
      });

      test(
          '2번의 크기를 200 에서 최소크기보다 작게 40 으로 줄이면, '
          '2번의 크기가 80, 3번의 크기가 360, 1번의 크기가 160 으로 변경 되어야 한다.', () {
        final items = <_ResizeItem>[
          _ResizeItem(index: 0, size: 200, minSize: 80),
          _ResizeItem(index: 1, size: 200, minSize: 80),
          _ResizeItem(index: 2, size: 200, minSize: 80),
          _ResizeItem(index: 3, size: 200, minSize: 80),
          _ResizeItem(index: 4, size: 200, minSize: 80),
        ];

        final helper = PlutoResizeHelper.items<_ResizeItem>(
          offset: -160,
          items: items,
          isMainItem: (i) => i.index == 2,
          getItemSize: (i) => i.size,
          getItemMinSize: (i) => i.minSize,
          setItemSize: (i, size) => i.size = size,
          mode: mode,
        );

        expect(helper.update(), true);
        expect(items[0].size, 200);
        expect(items[1].size, 160);
        expect(items[2].size, 80);
        expect(items[3].size, 360);
        expect(items[4].size, 200);
      });

      test(
          '0번의 크기를 200 에서 최소크기보다 작게 40 으로 줄이면, '
          '0번의 크기가 80, 1번의 크기가 320 이어야 한다.', () {
        final items = <_ResizeItem>[
          _ResizeItem(index: 0, size: 200, minSize: 80),
          _ResizeItem(index: 1, size: 200, minSize: 80),
          _ResizeItem(index: 2, size: 200, minSize: 80),
          _ResizeItem(index: 3, size: 200, minSize: 80),
          _ResizeItem(index: 4, size: 200, minSize: 80),
        ];

        final helper = PlutoResizeHelper.items<_ResizeItem>(
          offset: -160,
          items: items,
          isMainItem: (i) => i.index == 0,
          getItemSize: (i) => i.size,
          getItemMinSize: (i) => i.minSize,
          setItemSize: (i, size) => i.size = size,
          mode: mode,
        );

        expect(helper.update(), true);
        expect(items[0].size, 80);
        expect(items[1].size, 320);
        expect(items[2].size, 200);
        expect(items[3].size, 200);
        expect(items[4].size, 200);
      });

      test(
          '4번의 크기를 200 에서 최소크기보다 작게 40 으로 줄이면, '
          '4번의 크기가 80, 3번의 크기가 320 이어야 한다.', () {
        final items = <_ResizeItem>[
          _ResizeItem(index: 0, size: 200, minSize: 80),
          _ResizeItem(index: 1, size: 200, minSize: 80),
          _ResizeItem(index: 2, size: 200, minSize: 80),
          _ResizeItem(index: 3, size: 200, minSize: 80),
          _ResizeItem(index: 4, size: 200, minSize: 80),
        ];

        final helper = PlutoResizeHelper.items<_ResizeItem>(
          offset: -160,
          items: items,
          isMainItem: (i) => i.index == 4,
          getItemSize: (i) => i.size,
          getItemMinSize: (i) => i.minSize,
          setItemSize: (i, size) => i.size = size,
          mode: mode,
        );

        expect(helper.update(), true);
        expect(items[0].size, 200);
        expect(items[1].size, 200);
        expect(items[2].size, 200);
        expect(items[3].size, 320);
        expect(items[4].size, 80);
      });

      test('0번의 크기를 최대로 넓히면 나머지 크기가 최소로 줄어야 한다.', () {
        final items = <_ResizeItem>[
          _ResizeItem(index: 0, size: 200, minSize: 80),
          _ResizeItem(index: 1, size: 200, minSize: 80),
          _ResizeItem(index: 2, size: 200, minSize: 80),
          _ResizeItem(index: 3, size: 200, minSize: 80),
          _ResizeItem(index: 4, size: 200, minSize: 80),
        ];

        final helper = PlutoResizeHelper.items<_ResizeItem>(
          offset: 1000,
          items: items,
          isMainItem: (i) => i.index == 0,
          getItemSize: (i) => i.size,
          getItemMinSize: (i) => i.minSize,
          setItemSize: (i, size) => i.size = size,
          mode: mode,
        );

        expect(helper.update(), true);
        expect(items[0].size, 680);
        expect(items[1].size, 80);
        expect(items[2].size, 80);
        expect(items[3].size, 80);
        expect(items[4].size, 80);
      });

      test('2번의 크기를 최대로 넓히면 나머지 크기가 최소로 줄어야 한다.', () {
        final items = <_ResizeItem>[
          _ResizeItem(index: 0, size: 200, minSize: 80),
          _ResizeItem(index: 1, size: 200, minSize: 80),
          _ResizeItem(index: 2, size: 200, minSize: 80),
          _ResizeItem(index: 3, size: 200, minSize: 80),
          _ResizeItem(index: 4, size: 200, minSize: 80),
        ];

        final helper = PlutoResizeHelper.items<_ResizeItem>(
          offset: 1000,
          items: items,
          isMainItem: (i) => i.index == 2,
          getItemSize: (i) => i.size,
          getItemMinSize: (i) => i.minSize,
          setItemSize: (i, size) => i.size = size,
          mode: mode,
        );

        expect(helper.update(), true);
        expect(items[0].size, 80);
        expect(items[1].size, 80);
        expect(items[2].size, 680);
        expect(items[3].size, 80);
        expect(items[4].size, 80);
      });

      test('4번의 크기를 최대로 넓히면 나머지 크기가 최소로 줄어야 한다.', () {
        final items = <_ResizeItem>[
          _ResizeItem(index: 0, size: 200, minSize: 80),
          _ResizeItem(index: 1, size: 200, minSize: 80),
          _ResizeItem(index: 2, size: 200, minSize: 80),
          _ResizeItem(index: 3, size: 200, minSize: 80),
          _ResizeItem(index: 4, size: 200, minSize: 80),
        ];

        final helper = PlutoResizeHelper.items<_ResizeItem>(
          offset: 1000,
          items: items,
          isMainItem: (i) => i.index == 4,
          getItemSize: (i) => i.size,
          getItemMinSize: (i) => i.minSize,
          setItemSize: (i, size) => i.size = size,
          mode: mode,
        );

        expect(helper.update(), true);
        expect(items[0].size, 80);
        expect(items[1].size, 80);
        expect(items[2].size, 80);
        expect(items[3].size, 80);
        expect(items[4].size, 680);
      });
    });
  });
}
