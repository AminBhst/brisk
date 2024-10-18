import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pluto_grid/pluto_grid.dart';

/// It is used to lay out the widgets
/// of [PlutoCell] or [PlutoColumn], [PlutoColumnGroup] of [PlutoRow]
/// or render only the widgets displayed according to the screen width.
class PlutoVisibilityLayout extends RenderObjectWidget
    implements MultiChildRenderObjectWidget {
  const PlutoVisibilityLayout({
    super.key,
    required this.children,
    required this.delegate,
    required this.scrollController,
    this.initialViewportDimension = 1920,
  });

  @override
  final List<PlutoVisibilityLayoutId> children;

  final MultiChildLayoutDelegate delegate;

  final ScrollController scrollController;

  /// When the viewportDimension of scrollPosition cannot be obtained in the first build stage,
  /// it is used instead of viewportDimension of scroll.
  final double initialViewportDimension;

  @override
  PlutoVisibilityLayoutRenderObjectElement createElement() =>
      PlutoVisibilityLayoutRenderObjectElement(
        widget: this,
        scrollController: scrollController,
        initialViewportDimension: initialViewportDimension,
      );

  @override
  RenderCustomMultiChildLayoutBox createRenderObject(BuildContext context) {
    return RenderCustomMultiChildLayoutBox(delegate: delegate);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderCustomMultiChildLayoutBox renderObject,
  ) {
    renderObject.delegate = delegate;
  }
}

class PlutoVisibilityLayoutRenderObjectElement extends RenderObjectElement
    implements MultiChildRenderObjectElement {
  PlutoVisibilityLayoutRenderObjectElement({
    required PlutoVisibilityLayout widget,
    required this.scrollController,
    this.initialViewportDimension = 1920,
  })  : assert(!debugChildrenHaveDuplicateKeys(widget, widget.children)),
        super(widget);

  final ScrollController scrollController;

  final double initialViewportDimension;

  @override
  ContainerRenderObjectMixin<RenderObject,
      ContainerParentDataMixin<RenderObject>> get renderObject {
    return super.renderObject as ContainerRenderObjectMixin<RenderObject,
        ContainerParentDataMixin<RenderObject>>;
  }

  @override
  @protected
  @visibleForTesting
  Iterable<Element> get children => _children.where((Element child) {
        return !_forgottenChildren.contains(child);
      });

  late List<Element> _children;

  final Set<Element> _forgottenChildren = HashSet<Element>();

  Iterable<PlutoVisibilityLayoutId> get _widgetChildren {
    return (widget as PlutoVisibilityLayout).children;
  }

  double get _visibleFirst => scrollController.offset;

  double get _visibleLast => _visibleFirst + _contentSize;

  double get _contentSize {
    return scrollController.position.hasViewportDimension == true
        ? scrollController.position.viewportDimension
        : initialViewportDimension;
  }

  double get _maxScrollExtent {
    return _maxSize - _contentSize;
  }

  double get _maxSize => _widgetChildren.isNotEmpty
      ? (_widgetChildren.last.layoutChild.startPosition +
          _widgetChildren.last.layoutChild.width)
      : 0;

  double _previousMaxScroll = 0;

  double _previousVisibleFirstX1 = 0;

  double _previousVisibleFirstX2 = 0;

  double _previousVisibleLastX1 = 0;

  double _previousVisibleLastX2 = 0;

  bool _firstVisible = true;

  void scrollListener() {
    final bool sameBoundScroll = _previousVisibleFirstX1 <= _visibleFirst &&
        _visibleFirst <= _previousVisibleFirstX2 &&
        _previousVisibleLastX1 <= _visibleLast &&
        _visibleLast <= _previousVisibleLastX2;

    final bool sameMaxScrollExtent = _previousMaxScroll == _maxScrollExtent &&
        scrollController.position.maxScrollExtent == _maxScrollExtent;

    if (sameBoundScroll && sameMaxScrollExtent) {
      return;
    }

    _previousMaxScroll = _maxScrollExtent;

    markNeedsBuild();
  }

  bool visible({
    required double startOffset,
    required PlutoVisibilityLayoutChild layoutChild,
  }) {
    return layoutChild.keepAlive ||
        (startOffset <= _visibleLast &&
            startOffset + layoutChild.width >= _visibleFirst);
  }

  void updateLastVisible({
    required double startOffset,
    required double width,
  }) {
    if (_firstVisible) {
      _previousVisibleFirstX1 = startOffset;
      _previousVisibleFirstX2 = startOffset + width;
      _firstVisible = false;
    }

    _previousVisibleLastX1 = startOffset;
    _previousVisibleLastX2 = startOffset + width;
  }

  Element? findChildByLayoutId(Object layoutId) {
    return _children.firstWhereOrNull((element) {
      if (element.widget is PlutoVisibilityLayoutId) {
        return (element.widget as PlutoVisibilityLayoutId).id == layoutId;
      }
      return false;
    });
  }

  @override
  void performRebuild() {
    super.performRebuild();

    final visibleWidgets = <Widget>[];
    final slots = <IndexedSlot>[];

    Element? previousChild;
    double startOffset = 0;
    _firstVisible = true;

    for (int i = 0; i < _widgetChildren.length; i += 1) {
      final child = _widgetChildren.elementAt(i);
      final layoutChild = child.layoutChild;
      final width = layoutChild.width;

      if (visible(startOffset: startOffset, layoutChild: layoutChild)) {
        final foundElement = findChildByLayoutId(child.id);

        if (foundElement != null) {
          visibleWidgets.add(foundElement.widget);
          slots.add(IndexedSlot<Element?>(i, previousChild));
          previousChild = foundElement;
        } else {
          final element = child.createElement();
          visibleWidgets.add(element.widget);
          slots.add(IndexedSlot<Element?>(i, previousChild));
          previousChild = element;
        }

        updateLastVisible(startOffset: startOffset, width: width);
      }

      startOffset += width;
    }

    for (final child in _children) {
      if (child is _NullElement) {
        continue;
      }

      final layoutChild = (child.widget as PlutoVisibilityLayoutId).layoutChild;

      if (!visible(
        startOffset: layoutChild.startPosition,
        layoutChild: layoutChild,
      )) {
        deactivateChild(child);
        _forgottenChildren.add(child);
      }
    }

    _children = updateChildren(
      _children,
      visibleWidgets,
      forgottenChildren: _forgottenChildren,
      slots: slots,
    );

    _forgottenChildren.clear();
  }

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);

    scrollController.addListener(scrollListener);

    final List<Element> children = List<Element>.filled(
      _widgetChildren.length,
      _NullElement.instance,
    );

    Element? previousChild;
    double startOffset = 0;
    _firstVisible = true;

    for (int i = 0; i < children.length; i += 1) {
      final layoutChild = _widgetChildren.elementAt(i).layoutChild;
      final width = layoutChild.width;

      if (visible(startOffset: startOffset, layoutChild: layoutChild)) {
        final Element newChild = inflateWidget(
          _widgetChildren.elementAt(i),
          IndexedSlot<Element?>(i, previousChild),
        );
        children[i] = newChild;
        previousChild = newChild;

        updateLastVisible(startOffset: startOffset, width: width);
      } else {
        _forgottenChildren.add(children[i]);
      }

      startOffset += width;
    }

    _children = children;
  }

  @override
  void unmount() {
    super.unmount();

    scrollController.removeListener(scrollListener);
  }

  @override
  void update(PlutoVisibilityLayout newWidget) {
    super.update(newWidget);

    assert(widget == newWidget);

    assert(!debugChildrenHaveDuplicateKeys(
      widget,
      _widgetChildren,
    ));

    final List<Widget> visibleWidgets = [];
    double startOffset = 0;
    _firstVisible = true;

    for (int i = 0; i < _widgetChildren.length; i += 1) {
      final layoutChild = _widgetChildren.elementAt(i).layoutChild;
      final width = layoutChild.width;

      if (visible(startOffset: startOffset, layoutChild: layoutChild)) {
        visibleWidgets.add(_widgetChildren.elementAt(i));

        updateLastVisible(startOffset: startOffset, width: width);
      }

      startOffset += width;
    }

    _children = updateChildren(
      _children,
      visibleWidgets,
      forgottenChildren: _forgottenChildren,
    );

    _forgottenChildren.clear();
  }

  @override
  void insertRenderObjectChild(RenderObject child, IndexedSlot<Element?> slot) {
    final ContainerRenderObjectMixin<RenderObject,
            ContainerParentDataMixin<RenderObject>> renderObject =
        this.renderObject;
    assert(renderObject.debugValidateChild(child));
    renderObject.insert(child, after: slot.value?.renderObject);
    assert(renderObject == this.renderObject);
  }

  @override
  void moveRenderObjectChild(RenderObject child, IndexedSlot<Element?> oldSlot,
      IndexedSlot<Element?> newSlot) {
    final ContainerRenderObjectMixin<RenderObject,
            ContainerParentDataMixin<RenderObject>> renderObject =
        this.renderObject;
    assert(child.parent == renderObject);
    renderObject.move(child, after: newSlot.value?.renderObject);
    assert(renderObject == this.renderObject);
  }

  @override
  void removeRenderObjectChild(RenderObject child, Object? slot) {
    final ContainerRenderObjectMixin<RenderObject,
            ContainerParentDataMixin<RenderObject>> renderObject =
        this.renderObject;
    assert(child.parent == renderObject);
    renderObject.remove(child);
    assert(renderObject == this.renderObject);
  }

  @override
  void visitChildren(ElementVisitor visitor) {
    for (final Element child in _children) {
      if (!_forgottenChildren.contains(child)) visitor(child);
    }
  }

  @override
  void forgetChild(Element child) {
    assert(_children.contains(child));
    assert(!_forgottenChildren.contains(child));
    _forgottenChildren.add(child);
    super.forgetChild(child);
  }

  @override
  Element inflateWidget(Widget newWidget, Object? newSlot) {
    final Element newChild = super.inflateWidget(newWidget, newSlot);
    assert(_debugCheckHasAssociatedRenderObject(newChild));
    return newChild;
  }

  bool _debugCheckHasAssociatedRenderObject(Element newChild) {
    assert(() {
      if (newChild.renderObject == null) {
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: FlutterError.fromParts(<DiagnosticsNode>[
              ErrorSummary(
                  'The children of `MultiChildRenderObjectElement` must each has an associated render object.'),
              ErrorHint(
                'This typically means that the `${newChild.widget}` or its children\n'
                'are not a subtype of `RenderObjectWidget`.',
              ),
              newChild.describeElement(
                  'The following element does not have an associated render object'),
              DiagnosticsDebugCreator(DebugCreator(newChild)),
            ]),
          ),
        );
      }
      return true;
    }());
    return true;
  }
}

class PlutoVisibilityLayoutId extends LayoutId {
  PlutoVisibilityLayoutId({
    Key? key,
    required super.id,
    required PlutoVisibilityLayoutChild child,
  }) : super(key: key, child: child);

  PlutoVisibilityLayoutChild get layoutChild =>
      child as PlutoVisibilityLayoutChild;
}

abstract class PlutoVisibilityLayoutChild implements Widget {
  double get width;

  double get startPosition;

  bool get keepAlive => false;
}

class _NullElement extends Element {
  _NullElement() : super(const _NullWidget());

  static _NullElement instance = _NullElement();

  @override
  bool get debugDoingBuild => throw UnimplementedError();

  @override
  void performRebuild() {
    super.performRebuild();
    throw UnimplementedError();
  }
}

class _NullWidget extends Widget {
  const _NullWidget();

  @override
  Element createElement() => throw UnimplementedError();
}
