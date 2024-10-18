import 'dart:math';

import 'package:collection/collection.dart';

/// This mode is for adjusting the size of columns, etc.
///
/// [none] blocks resizing.
///
/// [normal] only changes the size of the object to be resized
/// while maintaining the size of the other siblings.
/// Also, this increases or decreases the overall area.
///
/// [pushAndPull] pushes or pulls the size of other siblings.
/// Also, this keeps the overall width.
enum PlutoResizeMode {
  none,
  normal,
  pushAndPull;

  bool get isNone => this == PlutoResizeMode.none;
  bool get isNormal => this == PlutoResizeMode.normal;
  bool get isPushAndPull => this == PlutoResizeMode.pushAndPull;
}

/// This mode automatically changes the width of columns, etc.
///
/// [none] does not automatically change the width.
///
/// [equal] changes the width equally regardless of the current size.
///
/// [scale] scales the width proportionally according to the current size.
enum PlutoAutoSizeMode {
  none,
  equal,
  scale;

  bool get isNone => this == PlutoAutoSizeMode.none;
  bool get isEqual => this == PlutoAutoSizeMode.equal;
  bool get isScale => this == PlutoAutoSizeMode.scale;
}

/// Returns the auto-sizing class according to
/// [PlutoAutoSizeMode.equal] or [PlutoAutoSizeMode.scale].
class PlutoAutoSizeHelper {
  static PlutoAutoSize items<T>({
    required double maxSize,
    required Iterable<T> items,
    required bool Function(T) isSuppressed,
    required double Function(T) getItemSize,
    required double Function(T) getItemMinSize,
    required void Function(T, double) setItemSize,
    required PlutoAutoSizeMode mode,
  }) {
    switch (mode) {
      case PlutoAutoSizeMode.equal:
        return PlutoAutoSizeEqual<T>(
          maxSize: maxSize,
          items: items,
          isSuppressedItem: isSuppressed,
          getItemSize: getItemSize,
          getItemMinSize: getItemMinSize,
          setItemSize: setItemSize,
        );
      case PlutoAutoSizeMode.scale:
        return PlutoAutoSizeScale<T>(
          maxSize: maxSize,
          items: items,
          isSuppressedItem: isSuppressed,
          getItemSize: getItemSize,
          getItemMinSize: getItemMinSize,
          setItemSize: setItemSize,
        );
      case PlutoAutoSizeMode.none:
        throw Exception('Mode cannot be called with PlutoAutoSizeMode.none.');
    }
  }
}

abstract class PlutoAutoSize<T> {
  const PlutoAutoSize({
    required this.maxSize,
    required this.items,
    required this.isSuppressedItem,
    required this.getItemSize,
    required this.getItemMinSize,
    required this.setItemSize,
  });

  /// Total size the item will occupy.
  final double maxSize;

  /// List of items to set size for.
  final Iterable<T> items;

  /// A callback to override the auto size setting.
  final bool Function(T) isSuppressedItem;

  /// A callback that returns the original size of the item.
  final double Function(T) getItemSize;

  /// A callback that returns the minimum size of an item.
  final double Function(T) getItemMinSize;

  /// Callback for setting the size of the item.
  final void Function(T, double) setItemSize;

  /// Call the [setItemSize] callback while traversing the [items] list.
  void update();
}

/// Change the width of the items equally within the [maxSize] range.
class PlutoAutoSizeEqual<T> extends PlutoAutoSize<T> {
  const PlutoAutoSizeEqual({
    required super.maxSize,
    required super.items,
    required super.isSuppressedItem,
    required super.getItemSize,
    required super.getItemMinSize,
    required super.setItemSize,
  });

  @override
  void update() {
    final length = items.length;

    double eachSize = maxSize / length;

    bool isSuppressed(T e) {
      return isSuppressedItem(e) || eachSize < getItemMinSize(e);
    }

    final suppressedItems = items.where(isSuppressed);

    if (suppressedItems.isNotEmpty) {
      final totalSuppressedSize = suppressedItems.fold<double>(0, (p, e) {
        return p + (isSuppressedItem(e) ? getItemSize(e) : getItemMinSize(e));
      });

      eachSize =
          (maxSize - totalSuppressedSize) / (length - suppressedItems.length);
    }

    for (final item in items) {
      if (isSuppressedItem(item)) continue;

      setItemSize(item, max(eachSize, getItemMinSize(item)));
    }
  }
}

/// Change the size of items according to the ratio.
class PlutoAutoSizeScale<T> extends PlutoAutoSize<T> {
  const PlutoAutoSizeScale({
    required super.maxSize,
    required super.items,
    required super.isSuppressedItem,
    required super.getItemSize,
    required super.getItemMinSize,
    required super.setItemSize,
  });

  @override
  void update() {
    final length = items.length;

    double effectiveMaxSize = maxSize;

    double totalWidth = items.fold<double>(0, (p, e) => p += getItemSize(e));

    double scale = maxSize / totalWidth;

    bool isSuppressed(T e) {
      return isSuppressedItem(e) || getItemSize(e) * scale < getItemMinSize(e);
    }

    final suppressedItems = items.where(isSuppressed);

    if (suppressedItems.isNotEmpty) {
      final totalSuppressedSize = suppressedItems.fold<double>(0, (p, e) {
        return p + (isSuppressedItem(e) ? getItemSize(e) : getItemMinSize(e));
      });

      effectiveMaxSize = maxSize - totalSuppressedSize;

      totalWidth = items.whereNot(isSuppressed).fold(0, (p, e) {
        return p + getItemSize(e);
      });

      scale = effectiveMaxSize / totalWidth;
    }

    for (int i = 0; i < length; i += 1) {
      final item = items.elementAt(i);

      if (isSuppressedItem(item)) continue;

      final minSize = getItemMinSize(item);

      final size = max(minSize, getItemSize(item) * scale);

      setItemSize(item, size);
    }
  }
}

/// Returns a class for changing the width of a column, etc.
///
/// Cannot be called with [PlutoResizeMode.none] or [PlutoResizeMode.normal] .
///
/// {@template resize_helper_params}
/// Change the width of the item corresponding to isMainItem by [offset].
/// Negative or positive.
///
/// [items] are all siblings that will be affected
/// when the size of the item corresponding to isMainItem is changed.
///
/// [isMainItem] is a callback
/// that should return whether or not the [item] is subject to resizing.
///
/// [getItemSize] is a callback
/// that should return the size of [item].
///
/// [getItemMinSize] is a callback
/// that should return the minimum width of [item].
///
/// [setItemSize] is a callback
/// that should change the size of [item] to [size].
/// {@endtemplate}
class PlutoResizeHelper {
  static PlutoResize items<T>({
    required double offset,
    required List<T> items,
    required bool Function(T item) isMainItem,
    required double Function(T item) getItemSize,
    required double Function(T item) getItemMinSize,
    required void Function(T item, double size) setItemSize,
    required PlutoResizeMode mode,
  }) {
    switch (mode) {
      case PlutoResizeMode.pushAndPull:
        return PlutoResizePushAndPull<T>(
          offset: offset,
          items: items,
          isMainItem: isMainItem,
          getItemSize: getItemSize,
          getItemMinSize: getItemMinSize,
          setItemSize: setItemSize,
        );
      case PlutoResizeMode.none:
      case PlutoResizeMode.normal:
        throw Exception('Cannot be called with Mode set to none, normal.');
    }
  }
}

/// This is the implementation
/// that must be inherited when implementing the class according to [PlutoResizeMode].
///
/// {@macro resize_helper_params}
abstract class PlutoResize<T> {
  PlutoResize({
    required this.offset,
    required this.items,
    required this.isMainItem,
    required this.getItemSize,
    required this.getItemMinSize,
    required this.setItemSize,
  }) {
    final index = items.indexWhere((e) => isMainItem(e));
    final positiveIndex = index + 1;
    final length = items.length;

    _mainItem = items[index];

    _positiveSiblings = positiveIndex == length
        ? const Iterable.empty()
        : items.getRange(positiveIndex, length);

    _negativeSiblings = items.getRange(0, index);
  }

  final double offset;

  final List<T> items;

  final bool Function(T item) isMainItem;

  final double Function(T item) getItemSize;

  final double Function(T item) getItemMinSize;

  final void Function(T item, double size) setItemSize;

  late final T _mainItem;

  late final Iterable<T> _positiveSiblings;

  late final Iterable<T> _negativeSiblings;

  bool get isFirstMain => isMainItem(items.first);

  bool get isLastMain => isMainItem(items.last);

  T? getFirstItemPositive() {
    return _positiveSiblings.isEmpty ? null : _positiveSiblings.first;
  }

  T? getFirstItemNegative() {
    return _negativeSiblings.isEmpty ? null : _negativeSiblings.last;
  }

  T? getFirstWideItemPositive() {
    final double absOffset = offset.abs();
    return _positiveSiblings.firstWhereOrNull(
      (e) => getItemSize(e) - absOffset > getItemMinSize(e),
    );
  }

  T? getFirstWideItemNegative() {
    final double absOffset = offset.abs();
    return _negativeSiblings.lastWhereOrNull(
      (e) => getItemSize(e) - absOffset > getItemMinSize(e),
    );
  }

  Iterable<T> iterateWideItemPositive() sync* {
    final iterator = _positiveSiblings.iterator;
    while (iterator.moveNext()) {
      final current = iterator.current;

      if (getItemSize(current) > getItemMinSize(current)) {
        yield current;
      }
    }
  }

  Iterable<T> iterateWideItemNegative() sync* {
    final iterator = _negativeSiblings.toList().reversed.iterator;
    while (iterator.moveNext()) {
      final current = iterator.current;

      if (getItemSize(current) > getItemMinSize(current)) {
        yield current;
      }
    }
  }

  bool update();
}

/// Changes the size of the object to be changed by [offset]
/// and pushes or pulls the size of the remaining items.
///
/// {@macro resize_helper_params}
///
/// [update] finishes resizing and returns whether or not to change.
class PlutoResizePushAndPull<T> extends PlutoResize<T> {
  PlutoResizePushAndPull({
    required super.offset,
    required super.items,
    required super.isMainItem,
    required super.getItemSize,
    required super.getItemMinSize,
    required super.setItemSize,
  });

  @override
  bool update() {
    if (offset == 0) {
      return false;
    }

    final mainSize = getItemSize(_mainItem);
    final mainMinSize = getItemMinSize(_mainItem);

    final setMainSize =
        mainSize + offset > mainMinSize ? mainSize + offset : mainMinSize;

    if (offset > 0) {
      double remaining = offset;

      final iterPositive = iterateWideItemPositive().iterator;
      while (iterPositive.moveNext()) {
        final siblingSize = getItemSize(iterPositive.current);
        final siblingMinSize = getItemMinSize(iterPositive.current);
        final enough = siblingSize - siblingMinSize;
        final siblingOffsetToSet = enough > remaining ? remaining : enough;
        setItemSize(iterPositive.current, siblingSize - siblingOffsetToSet);
        remaining -= siblingOffsetToSet;
        if (remaining <= 0) {
          setItemSize(_mainItem, mainSize + offset);
          return true;
        }
      }

      final iterNegative = iterateWideItemNegative().iterator;
      while (iterNegative.moveNext()) {
        final siblingSize = getItemSize(iterNegative.current);
        final siblingMinSize = getItemMinSize(iterNegative.current);
        final enough = siblingSize - siblingMinSize;
        final siblingOffsetToSet = enough > remaining ? remaining : enough;
        setItemSize(iterNegative.current, siblingSize - siblingOffsetToSet);
        remaining -= siblingOffsetToSet;
        if (remaining <= 0) {
          setItemSize(_mainItem, mainSize + offset);
          return true;
        }
      }

      if (offset == remaining) {
        return false;
      }

      setItemSize(_mainItem, mainSize + (offset - remaining));

      return true;
    } else {
      if (isFirstMain || isLastMain) {
        if (setMainSize == mainSize) {
          return false;
        }
        final firstSiblingItem =
            isFirstMain ? getFirstItemPositive() : getFirstItemNegative();
        if (firstSiblingItem == null) {
          return false;
        }
        setItemSize(_mainItem, setMainSize);
        final firstSiblingItemWidth = getItemSize(firstSiblingItem);
        setItemSize(
          firstSiblingItem,
          firstSiblingItemWidth + mainSize - setMainSize,
        );
        return true;
      }

      double remainingNegative = offset.abs() - (mainSize - setMainSize);
      if (remainingNegative > 0) {
        final iterNegative = iterateWideItemNegative().iterator;
        while (iterNegative.moveNext()) {
          final siblingSize = getItemSize(iterNegative.current);
          final siblingMinSize = getItemMinSize(iterNegative.current);
          final enough = siblingSize - siblingMinSize;
          final siblingOffsetToSet =
              enough > remainingNegative ? remainingNegative : enough;
          setItemSize(iterNegative.current, siblingSize - siblingOffsetToSet);
          remainingNegative -= siblingOffsetToSet;
          if (remainingNegative <= 0) {
            break;
          }
        }
      }

      if (mainSize == setMainSize &&
          remainingNegative == offset.abs() - (mainSize - setMainSize)) {
        return false;
      }

      setItemSize(_mainItem, setMainSize);

      final firstPositiveItem = getFirstItemPositive();
      assert(firstPositiveItem != null);
      final firstPositiveItemSize = getItemSize(firstPositiveItem as T);
      setItemSize(
        firstPositiveItem,
        firstPositiveItemSize + offset.abs() - remainingNegative,
      );
    }

    return true;
  }
}
