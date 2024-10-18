/*
 * This widget modifies [CupertinoScrollbar] a little,
 * so that the horizontal and vertical scroll controllers work together.
*/

// All values eyeballed.
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

const double _kScrollbarMinLength = 36.0;
const double _kScrollbarMinOverscrollLength = 8.0;
const Duration _kScrollbarTimeToFade = Duration(milliseconds: 1200);
const Duration _kScrollbarFadeDuration = Duration(milliseconds: 250);
const Duration _kScrollbarResizeDuration = Duration(milliseconds: 100);
const Duration _kScrollbarLongPressDuration = Duration(milliseconds: 100);

// Extracted from iOS 13.1 beta using Debug View Hierarchy.
const Color _kScrollbarColor = CupertinoDynamicColor.withBrightness(
  color: Color(0x59000000),
  darkColor: Color(0x80FFFFFF),
);
const Color _kTrackColor = Color(0x00000000);
// This is the amount of space from the top of a vertical scrollbar to the
// top edge of the scrollable, measured when the vertical scrollbar overscrolls
// to the top.
// TODO(LongCatIsLooong): fix https://github.com/flutter/flutter/issues/32175
const double _kScrollbarMainAxisMargin = 3.0;
const double _kScrollbarCrossAxisMargin = 3.0;

class PlutoScrollbar extends StatefulWidget {
  const PlutoScrollbar({
    Key? key,
    this.horizontalController,
    this.verticalController,
    this.isAlwaysShown = false,
    this.onlyDraggingThumb = true,
    this.enableHover = true,
    this.enableScrollAfterDragEnd = true,
    this.thickness = defaultThickness,
    this.thicknessWhileDragging = defaultThicknessWhileDragging,
    this.hoverWidth = defaultScrollbarHoverWidth,
    double? mainAxisMargin,
    double? crossAxisMargin,
    Color? scrollBarColor,
    Color? scrollBarTrackColor,
    Duration? longPressDuration,
    this.radius = defaultRadius,
    this.radiusWhileDragging = defaultRadiusWhileDragging,
    required this.child,
  })  : assert(thickness < double.infinity),
        assert(thicknessWhileDragging < double.infinity),
        assert(!isAlwaysShown ||
            (horizontalController != null || verticalController != null)),
        mainAxisMargin = mainAxisMargin ?? _kScrollbarMainAxisMargin,
        crossAxisMargin = crossAxisMargin ?? _kScrollbarCrossAxisMargin,
        scrollBarColor = scrollBarColor ?? _kScrollbarColor,
        scrollBarTrackColor = scrollBarTrackColor ?? _kTrackColor,
        longPressDuration = longPressDuration ?? _kScrollbarLongPressDuration,
        super(key: key);
  final ScrollController? horizontalController;

  final ScrollController? verticalController;

  final bool isAlwaysShown;

  final bool onlyDraggingThumb;

  final bool enableHover;

  final bool enableScrollAfterDragEnd;

  final Duration longPressDuration;

  final double thickness;

  final double thicknessWhileDragging;

  final double hoverWidth;

  final double mainAxisMargin;

  final double crossAxisMargin;

  final Color scrollBarColor;

  final Color scrollBarTrackColor;

  final Radius radius;

  final Radius radiusWhileDragging;

  final Widget child;

  static const double defaultThickness = 3;

  static const double defaultThicknessWhileDragging = 8.0;

  static const double defaultScrollbarHoverWidth = 16.0;

  static const Radius defaultRadius = Radius.circular(1.5);

  static const Radius defaultRadiusWhileDragging = Radius.circular(4.0);

  @override
  PlutoGridCupertinoScrollbarState createState() =>
      PlutoGridCupertinoScrollbarState();
}

class PlutoGridCupertinoScrollbarState extends State<PlutoScrollbar>
    with TickerProviderStateMixin {
  final GlobalKey _customPaintKey = GlobalKey();
  _ScrollbarPainter? _painter;

  late TextDirection _textDirection;
  late AnimationController _fadeoutAnimationController;
  late Animation<double> _fadeoutOpacityAnimation;
  late AnimationController _thicknessAnimationController;
  Timer? _fadeoutTimer;
  double? _dragScrollbarAxisPosition;
  Drag? _drag;

  double get _thickness {
    return widget.thickness +
        _thicknessAnimationController.value *
            (widget.thicknessWhileDragging - widget.thickness);
  }

  Radius? get _radius {
    return Radius.lerp(widget.radius, widget.radiusWhileDragging,
        _thicknessAnimationController.value);
  }

  ScrollController? _currentController;

  ScrollController? get _controller {
    if (_currentAxis == null) {
      return widget.verticalController ??
          widget.horizontalController ??
          PrimaryScrollController.of(context);
    }

    return _currentAxis == Axis.vertical
        ? widget.verticalController
        : widget.horizontalController;
  }

  Axis? _currentAxis;

  _HoverAxis _currentHoverAxis = _HoverAxis.none;

  @override
  void initState() {
    super.initState();
    _fadeoutAnimationController = AnimationController(
      vsync: this,
      duration: _kScrollbarFadeDuration,
    );
    _fadeoutOpacityAnimation = CurvedAnimation(
      parent: _fadeoutAnimationController,
      curve: Curves.fastOutSlowIn,
    );
    _thicknessAnimationController = AnimationController(
      vsync: this,
      duration: _kScrollbarResizeDuration,
    );
    _thicknessAnimationController.addListener(() {
      _painter!.updateThickness(_thickness, _radius!);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _textDirection = Directionality.of(context);
    if (_painter == null) {
      _painter = _buildCupertinoScrollbarPainter(context);
    } else {
      _painter!
        ..textDirection = _textDirection
        ..color = CupertinoDynamicColor.resolve(widget.scrollBarColor, context)
        ..padding = MediaQuery.of(context).padding;
    }
    _triggerScrollbar();
  }

  @override
  void didUpdateWidget(PlutoScrollbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    assert(_painter != null);
    _painter!.updateThickness(_thickness, _radius!);
    if (widget.isAlwaysShown != oldWidget.isAlwaysShown) {
      if (widget.isAlwaysShown == true) {
        _triggerScrollbar();
        _fadeoutAnimationController.animateTo(1.0);
      } else {
        _fadeoutAnimationController.reverse();
      }
    }
  }

  /// Returns a [ScrollbarPainter] visually styled like the iOS scrollbar.
  _ScrollbarPainter _buildCupertinoScrollbarPainter(BuildContext context) {
    return _ScrollbarPainter(
      trackColor:
          CupertinoDynamicColor.resolve(widget.scrollBarTrackColor, context),
      color: CupertinoDynamicColor.resolve(widget.scrollBarColor, context),
      textDirection: Directionality.of(context),
      thickness: _thickness,
      fadeoutOpacityAnimation: _fadeoutOpacityAnimation,
      mainAxisMargin: widget.mainAxisMargin,
      crossAxisMargin: widget.crossAxisMargin,
      radius: _radius,
      padding: MediaQuery.of(context).padding,
      minLength: _kScrollbarMinLength,
      minOverscrollLength: _kScrollbarMinOverscrollLength,
    );
  }

  // Wait one frame and cause an empty scroll event.  This allows the thumb to
  // show immediately when isAlwaysShown is true.  A scroll event is required in
  // order to paint the thumb.
  void _triggerScrollbar() {
    WidgetsBinding.instance.addPostFrameCallback((Duration duration) {
      if (widget.isAlwaysShown) {
        _fadeoutTimer?.cancel();
        if (widget.verticalController!.hasClients) {
          widget.verticalController!.position.didUpdateScrollPositionBy(0);
        }
      }
    });
  }

  // Handle a gesture that drags the scrollbar by the given amount.
  void _dragScrollbar(double primaryDelta) {
    assert(_currentController != null);

    // Convert primaryDelta, the amount that the scrollbar moved since the last
    // time _dragScrollbar was called, into the coordinate space of the scroll
    // position, and create/update the drag event with that position.
    final double scrollOffsetLocal = _painter!.getTrackToScroll(primaryDelta);
    final double scrollOffsetGlobal =
        scrollOffsetLocal + _currentController!.position.pixels;
    final Axis direction = _currentController!.position.axis;

    if (_drag == null) {
      _drag = _currentController!.position.drag(
        DragStartDetails(
          globalPosition: direction == Axis.vertical
              ? Offset(0.0, scrollOffsetGlobal)
              : Offset(scrollOffsetGlobal, 0.0),
        ),
        () {},
      );
    } else {
      _drag!.update(DragUpdateDetails(
        globalPosition: direction == Axis.vertical
            ? Offset(0.0, scrollOffsetGlobal)
            : Offset(scrollOffsetGlobal, 0.0),
        delta: direction == Axis.vertical
            ? Offset(0.0, -scrollOffsetLocal)
            : Offset(-scrollOffsetLocal, 0.0),
        primaryDelta: -scrollOffsetLocal,
      ));
    }
  }

  void _startFadeoutTimer() {
    if (!widget.isAlwaysShown) {
      _fadeoutTimer?.cancel();
      _fadeoutTimer = Timer(_kScrollbarTimeToFade, () {
        _fadeoutAnimationController.reverse();
        _fadeoutTimer = null;
      });
    }
  }

  Axis? _getDirection() {
    try {
      return _currentController!.position.axis;
    } catch (_) {
      // Ignore the gesture if we cannot determine the direction.
      return null;
    }
  }

  double _pressStartAxisPosition = 0.0;

  // Long press event callbacks handle the gesture where the user long presses
  // on the scrollbar thumb and then drags the scrollbar without releasing.
  void _handleLongPressStart(LongPressStartDetails details) {
    _currentController = _controller;
    final Axis? direction = _getDirection();
    if (direction == null) {
      return;
    }
    _fadeoutTimer?.cancel();
    _fadeoutAnimationController.forward();
    switch (direction) {
      case Axis.vertical:
        _pressStartAxisPosition = details.localPosition.dy;
        _dragScrollbar(details.localPosition.dy);
        _dragScrollbarAxisPosition = details.localPosition.dy;
        break;
      case Axis.horizontal:
        _pressStartAxisPosition = details.localPosition.dx;
        _dragScrollbar(details.localPosition.dx);
        _dragScrollbarAxisPosition = details.localPosition.dx;
        break;
    }
  }

  void _handleLongPress() {
    if (_getDirection() == null) {
      return;
    }
    _fadeoutTimer?.cancel();
    _thicknessAnimationController.forward().then<void>(
          (_) => HapticFeedback.mediumImpact(),
        );
  }

  void _handleLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    final Axis? direction = _getDirection();
    if (direction == null) {
      return;
    }
    switch (direction) {
      case Axis.vertical:
        _dragScrollbar(details.localPosition.dy - _dragScrollbarAxisPosition!);
        _dragScrollbarAxisPosition = details.localPosition.dy;
        break;
      case Axis.horizontal:
        _dragScrollbar(details.localPosition.dx - _dragScrollbarAxisPosition!);
        _dragScrollbarAxisPosition = details.localPosition.dx;
        break;
    }
  }

  void _handleLongPressEnd(LongPressEndDetails details) {
    final Axis? direction = _getDirection();
    if (direction == null) {
      return;
    }
    switch (direction) {
      case Axis.vertical:
        _handleDragScrollEnd(details.velocity.pixelsPerSecond.dy, direction);
        if (details.velocity.pixelsPerSecond.dy.abs() < 10 &&
            (details.localPosition.dy - _pressStartAxisPosition).abs() > 0) {
          HapticFeedback.mediumImpact();
        }
        break;
      case Axis.horizontal:
        _handleDragScrollEnd(details.velocity.pixelsPerSecond.dx, direction);
        if (details.velocity.pixelsPerSecond.dx.abs() < 10 &&
            (details.localPosition.dx - _pressStartAxisPosition).abs() > 0) {
          HapticFeedback.mediumImpact();
        }
        break;
    }
    _currentController = null;
  }

  void _handleDragScrollEnd(double trackVelocity, Axis direction) {
    _startFadeoutTimer();
    _thicknessAnimationController.reverse();
    _dragScrollbarAxisPosition = null;
    final double scrollVelocity = widget.enableScrollAfterDragEnd
        ? _painter!.getTrackToScroll(trackVelocity)
        : 0;
    _drag?.end(DragEndDetails(
      primaryVelocity: -scrollVelocity,
      velocity: Velocity(
        pixelsPerSecond: direction == Axis.vertical
            ? Offset(0.0, -scrollVelocity)
            : Offset(-scrollVelocity, 0.0),
      ),
    ));
    _drag = null;
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    final ScrollMetrics metrics = notification.metrics;
    if (metrics.maxScrollExtent <= metrics.minScrollExtent) {
      return false;
    }

    _currentAxis = axisDirectionToAxis(metrics.axisDirection);

    if (notification is ScrollUpdateNotification ||
        notification is OverscrollNotification ||
        notification is UserScrollNotification) {
      // Any movements always makes the scrollbar start showing up.
      if (_fadeoutAnimationController.status != AnimationStatus.forward) {
        _fadeoutAnimationController.forward();
      }

      _fadeoutTimer?.cancel();
      _painter!.update(metrics, metrics.axisDirection);

      // Call ScrollController.jumpTo on keyboard move.
      // An error where the Thumb does not disappear
      // because UserScrollNotification is called
      // after ScrollEndNotification when the horizontal axis is moved.
      if ((notification is UserScrollNotification) &&
          notification.direction == ScrollDirection.idle) {
        _callFadeoutTimer();
      }
    } else if (notification is ScrollEndNotification) {
      // On iOS, the scrollbar can only go away once the user lifted the finger.
      _callFadeoutTimer();
    }

    return false;
  }

  void _callFadeoutTimer() {
    if (_dragScrollbarAxisPosition == null) {
      _startFadeoutTimer();
    }
  }

  // Get the GestureRecognizerFactories used to detect gestures on the scrollbar
  // thumb.
  Map<Type, GestureRecognizerFactory> get _gestures {
    final Map<Type, GestureRecognizerFactory> gestures =
        <Type, GestureRecognizerFactory>{};

    gestures[_ThumbPressGestureRecognizer] =
        GestureRecognizerFactoryWithHandlers<_ThumbPressGestureRecognizer>(
      () => _ThumbPressGestureRecognizer(
        customPaintKey: _customPaintKey,
        debugOwner: this,
        duration: widget.longPressDuration,
        onlyDraggingThumb: widget.onlyDraggingThumb,
      ),
      (_ThumbPressGestureRecognizer instance) {
        instance
          ..onLongPressStart = _handleLongPressStart
          ..onLongPress = _handleLongPress
          ..onLongPressMoveUpdate = _handleLongPressMoveUpdate
          ..onLongPressEnd = _handleLongPressEnd;
      },
    );

    return gestures;
  }

  @override
  void dispose() {
    _fadeoutAnimationController.dispose();
    _thicknessAnimationController.dispose();
    _fadeoutTimer?.cancel();
    _painter!.dispose();
    super.dispose();
  }

  bool _needUpdatePainterByHover(Axis axis) {
    switch (_painter?._lastAxisDirection) {
      case AxisDirection.up:
      case AxisDirection.down:
        return axis != Axis.vertical;
      case AxisDirection.left:
      case AxisDirection.right:
        return axis != Axis.horizontal;
      default:
        return true;
    }
  }

  void _handleHoverExit(PointerExitEvent event) {
    _callFadeoutTimer();
  }

  void _handleHover(PointerHoverEvent event) {
    final hoverAxis = _getHoverAxis(event.position, event.kind, forHover: true);
    if (hoverAxis == _currentHoverAxis) return;
    _currentHoverAxis = hoverAxis;

    ScrollMetrics? metrics;
    bool needUpdate = false;

    switch (hoverAxis) {
      case _HoverAxis.vertical:
        _currentAxis = Axis.vertical;
        _currentController = widget.verticalController;
        needUpdate = _needUpdatePainterByHover(Axis.vertical);
        if (needUpdate) {
          metrics = FixedScrollMetrics(
            minScrollExtent:
                widget.verticalController?.position.minScrollExtent,
            maxScrollExtent:
                widget.verticalController?.position.maxScrollExtent,
            pixels: widget.verticalController?.position.pixels,
            viewportDimension:
                widget.verticalController?.position.viewportDimension,
            axisDirection: widget.verticalController?.position.axisDirection ??
                AxisDirection.down,
            devicePixelRatio: 1.0,
          );
        }
        break;
      case _HoverAxis.horizontal:
        _currentAxis = Axis.horizontal;
        _currentController = widget.horizontalController;
        needUpdate = _needUpdatePainterByHover(Axis.horizontal);
        if (needUpdate) {
          metrics = FixedScrollMetrics(
            minScrollExtent:
                widget.horizontalController?.position.minScrollExtent,
            maxScrollExtent:
                widget.horizontalController?.position.maxScrollExtent,
            pixels: widget.horizontalController?.position.pixels,
            viewportDimension:
                widget.horizontalController?.position.viewportDimension,
            axisDirection:
                widget.horizontalController?.position.axisDirection ??
                    AxisDirection.right,
            devicePixelRatio: 1.0,
          );
        }
        break;
      case _HoverAxis.none:
        _callFadeoutTimer();
        return;
    }

    if (_fadeoutAnimationController.status != AnimationStatus.forward) {
      _fadeoutAnimationController.forward();
    }

    _fadeoutTimer?.cancel();

    if (needUpdate) {
      _painter!.update(metrics!, metrics.axisDirection);
    }
  }

  _HoverAxis _getHoverAxis(
    Offset position,
    PointerDeviceKind kind, {
    bool forHover = false,
  }) {
    if (_customPaintKey.currentContext == null || _painter == null) {
      return _HoverAxis.none;
    }

    final RenderBox renderBox =
        _customPaintKey.currentContext!.findRenderObject()! as RenderBox;
    final localOffset = renderBox.globalToLocal(position);
    final trackSize = renderBox.size;
    final isRTL = _textDirection == TextDirection.rtl;
    final hoverWidth = widget.hoverWidth;

    if (Rect.fromLTRB(
      isRTL ? 0 : trackSize.width - hoverWidth,
      0,
      isRTL ? hoverWidth : trackSize.width,
      trackSize.height,
    ).contains(localOffset)) {
      return _HoverAxis.vertical;
    }

    if (Rect.fromLTRB(
      0,
      trackSize.height - hoverWidth,
      trackSize.width,
      trackSize.height,
    ).contains(localOffset)) {
      return _HoverAxis.horizontal;
    }

    return _HoverAxis.none;
  }

  @override
  Widget build(BuildContext context) {
    Widget child = CustomPaint(
      key: _customPaintKey,
      foregroundPainter: _painter,
      child: RepaintBoundary(child: widget.child),
    );

    if (widget.enableHover) {
      child = MouseRegion(
        onExit: (PointerExitEvent event) {
          switch (event.kind) {
            case PointerDeviceKind.mouse:
            case PointerDeviceKind.trackpad:
              _handleHoverExit(event);
              break;
            case PointerDeviceKind.stylus:
            case PointerDeviceKind.invertedStylus:
            case PointerDeviceKind.unknown:
            case PointerDeviceKind.touch:
              break;
          }
        },
        onHover: (PointerHoverEvent event) {
          switch (event.kind) {
            case PointerDeviceKind.mouse:
            case PointerDeviceKind.trackpad:
              _handleHover(event);
              break;
            case PointerDeviceKind.stylus:
            case PointerDeviceKind.invertedStylus:
            case PointerDeviceKind.unknown:
            case PointerDeviceKind.touch:
              break;
          }
        },
        child: child,
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: RepaintBoundary(
        child: RawGestureDetector(
          gestures: _gestures,
          child: child,
        ),
      ),
    );
  }
}

const double _kMinInteractiveSize = 48.0;
const double _kScrollbarThickness = 6.0;
const double _kMinThumbExtent = 18.0;

class _ScrollbarPainter extends ChangeNotifier implements CustomPainter {
  /// Creates a scrollbar with customizations given by construction arguments.
  _ScrollbarPainter({
    required Color color,
    required this.fadeoutOpacityAnimation,
    required Color trackColor,
    Color trackBorderColor = const Color(0x00000000),
    TextDirection? textDirection,
    double thickness = _kScrollbarThickness,
    EdgeInsets padding = EdgeInsets.zero,
    double mainAxisMargin = 0.0,
    double crossAxisMargin = 0.0,
    Radius? radius,
    Radius? trackRadius,
    OutlinedBorder? shape,
    double minLength = _kMinThumbExtent,
    double? minOverscrollLength,
    ScrollbarOrientation? scrollbarOrientation,
    bool ignorePointer = false,
  })  : assert(radius == null || shape == null),
        assert(minLength >= 0),
        assert(minOverscrollLength == null || minOverscrollLength <= minLength),
        assert(minOverscrollLength == null || minOverscrollLength >= 0),
        assert(padding.isNonNegative),
        _color = color,
        _textDirection = textDirection,
        _thickness = thickness,
        _radius = radius,
        _shape = shape,
        _padding = padding,
        _mainAxisMargin = mainAxisMargin,
        _crossAxisMargin = crossAxisMargin,
        _minLength = minLength,
        _trackColor = trackColor,
        _trackBorderColor = trackBorderColor,
        _trackRadius = trackRadius,
        _scrollbarOrientation = scrollbarOrientation,
        _minOverscrollLength = minOverscrollLength ?? minLength,
        _ignorePointer = ignorePointer {
    fadeoutOpacityAnimation.addListener(notifyListeners);
  }

  /// [Color] of the thumb. Mustn't be null.
  Color get color => _color;
  Color _color;
  set color(Color value) {
    if (color == value) return;

    _color = value;
    notifyListeners();
  }

  /// [Color] of the track. Mustn't be null.
  Color get trackColor => _trackColor;
  Color _trackColor;
  set trackColor(Color value) {
    if (trackColor == value) return;

    _trackColor = value;
    notifyListeners();
  }

  /// [Color] of the track border. Mustn't be null.
  Color get trackBorderColor => _trackBorderColor;
  Color _trackBorderColor;
  set trackBorderColor(Color value) {
    if (trackBorderColor == value) return;

    _trackBorderColor = value;
    notifyListeners();
  }

  /// [Radius] of corners of the Scrollbar's track.
  ///
  /// Scrollbar's track will be rectangular if [trackRadius] is null.
  Radius? get trackRadius => _trackRadius;
  Radius? _trackRadius;
  set trackRadius(Radius? value) {
    if (trackRadius == value) return;

    _trackRadius = value;
    notifyListeners();
  }

  /// [TextDirection] of the [BuildContext] which dictates the side of the
  /// screen the scrollbar appears in (the trailing side). Must be set prior to
  /// calling paint.
  TextDirection? get textDirection => _textDirection;
  TextDirection? _textDirection;
  set textDirection(TextDirection? value) {
    assert(value != null);
    if (textDirection == value) return;

    _textDirection = value;
    notifyListeners();
  }

  /// Thickness of the scrollbar in its cross-axis in logical pixels. Mustn't be null.
  double get thickness => _thickness;
  double _thickness;
  set thickness(double value) {
    if (thickness == value) return;

    _thickness = value;
    notifyListeners();
  }

  /// An opacity [Animation] that dictates the opacity of the thumb.
  /// Changes in value of this [Listenable] will automatically trigger repaints.
  /// Mustn't be null.
  final Animation<double> fadeoutOpacityAnimation;

  /// Distance from the scrollbar's start and end to the edge of the viewport
  /// in logical pixels. It affects the amount of available paint area.
  ///
  /// Mustn't be null and defaults to 0.
  double get mainAxisMargin => _mainAxisMargin;
  double _mainAxisMargin;
  set mainAxisMargin(double value) {
    if (mainAxisMargin == value) return;

    _mainAxisMargin = value;
    notifyListeners();
  }

  /// Distance from the scrollbar thumb to the nearest cross axis edge
  /// in logical pixels.
  ///
  /// Must not be null and defaults to 0.
  double get crossAxisMargin => _crossAxisMargin;
  double _crossAxisMargin;
  set crossAxisMargin(double value) {
    if (crossAxisMargin == value) return;

    _crossAxisMargin = value;
    notifyListeners();
  }

  /// [Radius] of corners if the scrollbar should have rounded corners.
  ///
  /// Scrollbar will be rectangular if [radius] is null.
  Radius? get radius => _radius;
  Radius? _radius;
  set radius(Radius? value) {
    assert(shape == null || value == null);
    if (radius == value) return;

    _radius = value;
    notifyListeners();
  }

  /// The [OutlinedBorder] of the scrollbar's thumb.
  ///
  /// Only one of [radius] and [shape] may be specified. For a rounded rectangle,
  /// it's simplest to just specify [radius]. By default, the scrollbar thumb's
  /// shape is a simple rectangle.
  ///
  /// If [shape] is specified, the thumb will take the shape of the passed
  /// [OutlinedBorder] and fill itself with [color] (or grey if it
  /// is unspecified).
  ///
  OutlinedBorder? get shape => _shape;
  OutlinedBorder? _shape;
  set shape(OutlinedBorder? value) {
    assert(radius == null || value == null);
    if (shape == value) return;

    _shape = value;
    notifyListeners();
  }

  /// The amount of space by which to inset the scrollbar's start and end, as
  /// well as its side to the nearest edge, in logical pixels.
  ///
  /// This is typically set to the current [MediaQueryData.padding] to avoid
  /// partial obstructions such as display notches. If you only want additional
  /// margins around the scrollbar, see [mainAxisMargin].
  ///
  /// Defaults to [EdgeInsets.zero]. Must not be null and offsets from all four
  /// directions must be greater than or equal to zero.
  EdgeInsets get padding => _padding;
  EdgeInsets _padding;
  set padding(EdgeInsets value) {
    if (padding == value) return;

    _padding = value;
    notifyListeners();
  }

  /// The preferred smallest size the scrollbar thumb can shrink to when the total
  /// scrollable extent is large, the current visible viewport is small, and the
  /// viewport is not overscrolled.
  ///
  /// The size of the scrollbar may shrink to a smaller size than [minLength] to
  /// fit in the available paint area. E.g., when [minLength] is
  /// `double.infinity`, it will not be respected if
  /// [ScrollMetrics.viewportDimension] and [mainAxisMargin] are finite.
  ///
  /// Mustn't be null and the value has to be greater or equal to
  /// [minOverscrollLength], which in turn is >= 0. Defaults to 18.0.
  double get minLength => _minLength;
  double _minLength;
  set minLength(double value) {
    if (minLength == value) return;

    _minLength = value;
    notifyListeners();
  }

  /// The preferred smallest size the scrollbar thumb can shrink to when viewport is
  /// overscrolled.
  ///
  /// When overscrolling, the size of the scrollbar may shrink to a smaller size
  /// than [minOverscrollLength] to fit in the available paint area. E.g., when
  /// [minOverscrollLength] is `double.infinity`, it will not be respected if
  /// the [ScrollMetrics.viewportDimension] and [mainAxisMargin] are finite.
  ///
  /// The value is less than or equal to [minLength] and greater than or equal to 0.
  /// When null, it will default to the value of [minLength].
  double get minOverscrollLength => _minOverscrollLength;
  double _minOverscrollLength;
  set minOverscrollLength(double value) {
    if (minOverscrollLength == value) return;

    _minOverscrollLength = value;
    notifyListeners();
  }

  /// {@template flutter.widgets.Scrollbar.scrollbarOrientation}
  /// Dictates the orientation of the scrollbar.
  ///
  /// [ScrollbarOrientation.top] places the scrollbar on top of the screen.
  /// [ScrollbarOrientation.bottom] places the scrollbar on the bottom of the screen.
  /// [ScrollbarOrientation.left] places the scrollbar on the left of the screen.
  /// [ScrollbarOrientation.right] places the scrollbar on the right of the screen.
  ///
  /// [ScrollbarOrientation.top] and [ScrollbarOrientation.bottom] can only be
  /// used with a vertical scroll.
  /// [ScrollbarOrientation.left] and [ScrollbarOrientation.right] can only be
  /// used with a horizontal scroll.
  ///
  /// For a vertical scroll the orientation defaults to
  /// [ScrollbarOrientation.right] for [TextDirection.ltr] and
  /// [ScrollbarOrientation.left] for [TextDirection.rtl].
  /// For a horizontal scroll the orientation defaults to [ScrollbarOrientation.bottom].
  /// {@endtemplate}
  ScrollbarOrientation? get scrollbarOrientation => _scrollbarOrientation;
  ScrollbarOrientation? _scrollbarOrientation;
  set scrollbarOrientation(ScrollbarOrientation? value) {
    if (scrollbarOrientation == value) return;

    _scrollbarOrientation = value;
    notifyListeners();
  }

  /// Whether the painter will be ignored during hit testing.
  bool get ignorePointer => _ignorePointer;
  bool _ignorePointer;
  set ignorePointer(bool value) {
    if (ignorePointer == value) return;

    _ignorePointer = value;
    notifyListeners();
  }

  void _debugAssertIsValidOrientation(ScrollbarOrientation orientation) {
    assert(
        (_isVertical && _isVerticalOrientation(orientation)) ||
            (!_isVertical && !_isVerticalOrientation(orientation)),
        'The given ScrollbarOrientation: $orientation is incompatible with the current AxisDirection: $_lastAxisDirection.');
  }

  /// Check whether given scrollbar orientation is vertical
  bool _isVerticalOrientation(ScrollbarOrientation orientation) =>
      orientation == ScrollbarOrientation.left ||
      orientation == ScrollbarOrientation.right;

  ScrollMetrics? _lastMetrics;
  AxisDirection? _lastAxisDirection;

  ScrollMetrics? _lastVerticalMetrics;
  AxisDirection? _lastVerticalAxisDirection;

  ScrollMetrics? _lastHorizontalMetrics;
  AxisDirection? _lastHorizontalAxisDirection;

  Rect? _thumbRect;
  Rect? _trackRect;
  late double _thumbOffset;

  /// Update with new [ScrollMetrics]. If the metrics change, the scrollbar will
  /// show and redraw itself based on these new metrics.
  ///
  /// The scrollbar will remain on screen.
  void update(
    ScrollMetrics metrics,
    AxisDirection axisDirection,
  ) {
    final bool vertical = axisDirection == AxisDirection.up ||
        axisDirection == AxisDirection.down;

    if (vertical) {
      if (_lastVerticalMetrics != null &&
          _lastVerticalMetrics!.extentBefore == metrics.extentBefore &&
          _lastVerticalMetrics!.extentInside == metrics.extentInside &&
          _lastVerticalMetrics!.extentAfter == metrics.extentAfter &&
          _lastVerticalAxisDirection == axisDirection &&
          _lastAxisDirection == axisDirection) {
        return;
      }

      _lastVerticalMetrics = metrics;
      _lastVerticalAxisDirection = axisDirection;
    } else {
      if (_lastHorizontalMetrics != null &&
          _lastHorizontalMetrics!.extentBefore == metrics.extentBefore &&
          _lastHorizontalMetrics!.extentInside == metrics.extentInside &&
          _lastHorizontalMetrics!.extentAfter == metrics.extentAfter &&
          _lastHorizontalAxisDirection == axisDirection &&
          _lastAxisDirection == axisDirection) {
        return;
      }

      _lastHorizontalMetrics = metrics;
      _lastHorizontalAxisDirection = axisDirection;
    }

    final ScrollMetrics? oldMetrics =
        vertical ? _lastVerticalMetrics : _lastHorizontalMetrics;

    _lastMetrics = vertical ? _lastVerticalMetrics : _lastHorizontalMetrics;
    _lastAxisDirection =
        vertical ? _lastVerticalAxisDirection : _lastHorizontalAxisDirection;

    bool needPaint(ScrollMetrics? metrics) =>
        metrics != null && metrics.maxScrollExtent > metrics.minScrollExtent;
    if (!needPaint(oldMetrics) && !needPaint(metrics)) return;

    notifyListeners();
  }

  /// Update and redraw with new scrollbar thickness and radius.
  void updateThickness(double nextThickness, Radius nextRadius) {
    thickness = nextThickness;
    radius = nextRadius;
  }

  Paint get _paintThumb {
    return Paint()
      ..color =
          color.withOpacity(color.opacity * fadeoutOpacityAnimation.value);
  }

  Paint _paintTrack({bool isBorder = false}) {
    if (isBorder) {
      return Paint()
        ..color = trackBorderColor.withOpacity(
            trackBorderColor.opacity * fadeoutOpacityAnimation.value)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
    }
    return Paint()
      ..color = trackColor
          .withOpacity(trackColor.opacity * fadeoutOpacityAnimation.value);
  }

  void _paintScrollbar(
      Canvas canvas, Size size, double thumbExtent, AxisDirection direction) {
    assert(
      textDirection != null,
      'A TextDirection must be provided before a Scrollbar can be painted.',
    );

    final ScrollbarOrientation resolvedOrientation;

    if (scrollbarOrientation == null) {
      if (_isVertical) {
        resolvedOrientation = textDirection == TextDirection.ltr
            ? ScrollbarOrientation.right
            : ScrollbarOrientation.left;
      } else {
        resolvedOrientation = ScrollbarOrientation.bottom;
      }
    } else {
      resolvedOrientation = scrollbarOrientation!;
    }

    final double x, y;
    final Size thumbSize, trackSize;
    final Offset trackOffset, borderStart, borderEnd;

    _debugAssertIsValidOrientation(resolvedOrientation);

    switch (resolvedOrientation) {
      case ScrollbarOrientation.left:
        thumbSize = Size(thickness, thumbExtent);
        trackSize = Size(thickness + 2 * crossAxisMargin, _trackExtent);
        x = crossAxisMargin + padding.left;
        y = _thumbOffset;
        trackOffset = Offset(x - crossAxisMargin, mainAxisMargin);
        borderStart = trackOffset + Offset(trackSize.width, 0.0);
        borderEnd = Offset(
            trackOffset.dx + trackSize.width, trackOffset.dy + _trackExtent);
        break;
      case ScrollbarOrientation.right:
        thumbSize = Size(thickness, thumbExtent);
        trackSize = Size(thickness + 2 * crossAxisMargin, _trackExtent);
        x = size.width - thickness - crossAxisMargin - padding.right;
        y = _thumbOffset;
        trackOffset = Offset(x - crossAxisMargin, mainAxisMargin);
        borderStart = trackOffset;
        borderEnd = Offset(trackOffset.dx, trackOffset.dy + _trackExtent);
        break;
      case ScrollbarOrientation.top:
        thumbSize = Size(thumbExtent, thickness);
        trackSize = Size(_trackExtent, thickness + 2 * crossAxisMargin);
        x = _thumbOffset;
        y = crossAxisMargin + padding.top;
        trackOffset = Offset(mainAxisMargin, y - crossAxisMargin);
        borderStart = trackOffset + Offset(0.0, trackSize.height);
        borderEnd = Offset(
            trackOffset.dx + _trackExtent, trackOffset.dy + trackSize.height);
        break;
      case ScrollbarOrientation.bottom:
        thumbSize = Size(thumbExtent, thickness);
        trackSize = Size(_trackExtent, thickness + 2 * crossAxisMargin);
        x = _thumbOffset;
        y = size.height - thickness - crossAxisMargin - padding.bottom;
        trackOffset = Offset(mainAxisMargin, y - crossAxisMargin);
        borderStart = trackOffset;
        borderEnd = Offset(trackOffset.dx + _trackExtent, trackOffset.dy);
        break;
    }

    // Whether we paint or not, calculating these rects allows us to hit test
    // when the scrollbar is transparent.
    _trackRect = trackOffset & trackSize;
    _thumbRect = Offset(x, y) & thumbSize;

    // Paint if the opacity dictates visibility
    if (fadeoutOpacityAnimation.value != 0.0) {
      // Track
      if (trackRadius == null) {
        canvas.drawRect(_trackRect!, _paintTrack());
      } else {
        canvas.drawRRect(
            RRect.fromRectAndRadius(_trackRect!, trackRadius!), _paintTrack());
      }
      // Track Border
      canvas.drawLine(borderStart, borderEnd, _paintTrack(isBorder: true));
      if (radius != null) {
        // Rounded rect thumb
        canvas.drawRRect(
            RRect.fromRectAndRadius(_thumbRect!, radius!), _paintThumb);
        return;
      }
      if (shape == null) {
        // Square thumb
        canvas.drawRect(_thumbRect!, _paintThumb);
        return;
      }
      // Custom-shaped thumb
      final Path outerPath = shape!.getOuterPath(_thumbRect!);
      canvas.drawPath(outerPath, _paintThumb);
      shape!.paint(canvas, _thumbRect!);
    }
  }

  double _thumbExtent() {
    // Thumb extent reflects fraction of content visible, as long as this
    // isn't less than the absolute minimum size.
    // _totalContentExtent >= viewportDimension, so (_totalContentExtent - _mainAxisPadding) > 0
    final double fractionVisible =
        ((_lastMetrics!.extentInside - _mainAxisPadding) /
                (_totalContentExtent - _mainAxisPadding))
            .clamp(0.0, 1.0);

    final double thumbExtent = math.max(
      math.min(_trackExtent, minOverscrollLength),
      _trackExtent * fractionVisible,
    );

    final double fractionOverscrolled =
        1.0 - _lastMetrics!.extentInside / _lastMetrics!.viewportDimension;
    final double safeMinLength = math.min(minLength, _trackExtent);
    final double newMinLength = (_beforeExtent > 0 && _afterExtent > 0)
        // Thumb extent is no smaller than minLength if scrolling normally.
        ? safeMinLength
        // User is overscrolling. Thumb extent can be less than minLength
        // but no smaller than minOverscrollLength. We can't use the
        // fractionVisible to produce intermediate values between minLength and
        // minOverscrollLength when the user is transitioning from regular
        // scrolling to overscrolling, so we instead use the percentage of the
        // content that is still in the viewport to determine the size of the
        // thumb. iOS behavior appears to have the thumb reach its minimum size
        // with ~20% of overscroll. We map the percentage of minLength from
        // [0.8, 1.0] to [0.0, 1.0], so 0% to 20% of overscroll will produce
        // values for the thumb that range between minLength and the smallest
        // possible value, minOverscrollLength.
        : safeMinLength * (1.0 - fractionOverscrolled.clamp(0.0, 0.2) / 0.2);

    // The `thumbExtent` should be no greater than `trackSize`, otherwise
    // the scrollbar may scroll towards the wrong direction.
    return thumbExtent.clamp(newMinLength, _trackExtent);
  }

  @override
  void dispose() {
    fadeoutOpacityAnimation.removeListener(notifyListeners);
    super.dispose();
  }

  bool get _isVertical =>
      _lastAxisDirection == AxisDirection.down ||
      _lastAxisDirection == AxisDirection.up;
  bool get _isReversed =>
      _lastAxisDirection == AxisDirection.up ||
      _lastAxisDirection == AxisDirection.left;
  // The amount of scroll distance before and after the current position.
  double get _beforeExtent =>
      _isReversed ? _lastMetrics!.extentAfter : _lastMetrics!.extentBefore;
  double get _afterExtent =>
      _isReversed ? _lastMetrics!.extentBefore : _lastMetrics!.extentAfter;
  // Padding of the thumb track.
  double get _mainAxisPadding =>
      _isVertical ? padding.vertical : padding.horizontal;
  // The size of the thumb track.
  double get _trackExtent =>
      _lastMetrics!.viewportDimension - 2 * mainAxisMargin - _mainAxisPadding;

  // The total size of the scrollable content.
  double get _totalContentExtent {
    return _lastMetrics!.maxScrollExtent -
        _lastMetrics!.minScrollExtent +
        _lastMetrics!.viewportDimension;
  }

  /// Convert between a thumb track position and the corresponding scroll
  /// position.
  ///
  /// thumbOffsetLocal is a position in the thumb track. Cannot be null.
  double getTrackToScroll(double thumbOffsetLocal) {
    final double scrollableExtent =
        _lastMetrics!.maxScrollExtent - _lastMetrics!.minScrollExtent;
    final double thumbMovableExtent = _trackExtent - _thumbExtent();

    return scrollableExtent * thumbOffsetLocal / thumbMovableExtent;
  }

  // Converts between a scroll position and the corresponding position in the
  // thumb track.
  double _getScrollToTrack(ScrollMetrics metrics, double thumbExtent) {
    final double scrollableExtent =
        metrics.maxScrollExtent - metrics.minScrollExtent;

    final double fractionPast = (scrollableExtent > 0)
        ? ((metrics.pixels - metrics.minScrollExtent) / scrollableExtent)
            .clamp(0.0, 1.0)
        : 0;

    return (_isReversed ? 1 - fractionPast : fractionPast) *
        (_trackExtent - thumbExtent);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (_lastAxisDirection == null ||
        _lastMetrics == null ||
        _lastMetrics!.maxScrollExtent <= _lastMetrics!.minScrollExtent) return;

    // Skip painting if there's not enough space.
    if (_lastMetrics!.viewportDimension <= _mainAxisPadding ||
        _trackExtent <= 0) {
      return;
    }

    final double beforePadding = _isVertical ? padding.top : padding.left;
    final double thumbExtent = _thumbExtent();
    final double thumbOffsetLocal =
        _getScrollToTrack(_lastMetrics!, thumbExtent);
    _thumbOffset = thumbOffsetLocal + mainAxisMargin + beforePadding;

    // Do not paint a scrollbar if the scroll view is infinitely long.
    // TODO(Piinks): Special handling for infinite scroll views, https://github.com/flutter/flutter/issues/41434
    if (_lastMetrics!.maxScrollExtent.isInfinite) return;

    return _paintScrollbar(canvas, size, thumbExtent, _lastAxisDirection!);
  }

  bool get _lastMetricsAreScrollable =>
      _lastMetrics!.minScrollExtent != _lastMetrics!.maxScrollExtent;

  /// Same as hitTest, but includes some padding when the [PointerEvent] is
  /// caused by [PointerDeviceKind.touch] to make sure that the region
  /// isn't too small to be interacted with by the user.
  ///
  /// The hit test area for hovering with [PointerDeviceKind.mouse] over the
  /// scrollbar also uses this extra padding. This is to make it easier to
  /// interact with the scrollbar by presenting it to the mouse for interaction
  /// based on proximity. When `forHover` is true, the larger hit test area will
  /// be used.
  bool hitTestInteractive(Offset position, PointerDeviceKind kind,
      {bool forHover = false}) {
    if (_trackRect == null) {
      // We have not computed the scrollbar position yet.
      return false;
    }
    if (ignorePointer) {
      return false;
    }

    if (!_lastMetricsAreScrollable) {
      return false;
    }

    final Rect interactiveRect = _trackRect!;
    final Rect paddedRect = interactiveRect.expandToInclude(
      Rect.fromCircle(
          center: _thumbRect!.center, radius: _kMinInteractiveSize / 2),
    );

    // The scrollbar is not able to be hit when transparent - except when
    // hovering with a mouse. This should bring the scrollbar into view so the
    // mouse can interact with it.
    if (fadeoutOpacityAnimation.value == 0.0) {
      if (forHover && kind == PointerDeviceKind.mouse) {
        return paddedRect.contains(position);
      }
      return false;
    }

    switch (kind) {
      case PointerDeviceKind.touch:
        return paddedRect.contains(position);
      case PointerDeviceKind.mouse:
      case PointerDeviceKind.stylus:
      case PointerDeviceKind.invertedStylus:
      case PointerDeviceKind.unknown:
      default: // ignore: no_default_cases, to allow adding new device types to [PointerDeviceKind]
        // TODO(moffatman): Remove after landing https://github.com/flutter/flutter/issues/23604
        return interactiveRect.contains(position);
    }
  }

  /// Same as hitTestInteractive, but excludes the track portion of the scrollbar.
  /// Used to evaluate interactions with only the scrollbar thumb.
  bool hitTestOnlyThumbInteractive(Offset position, PointerDeviceKind kind) {
    if (_thumbRect == null) {
      return false;
    }
    if (ignorePointer) {
      return false;
    }
    // The thumb is not able to be hit when transparent.
    if (fadeoutOpacityAnimation.value == 0.0) {
      return false;
    }

    if (!_lastMetricsAreScrollable) {
      return false;
    }

    switch (kind) {
      case PointerDeviceKind.touch:
        final Rect touchThumbRect = _thumbRect!.expandToInclude(
          Rect.fromCircle(
              center: _thumbRect!.center, radius: _kMinInteractiveSize / 2),
        );
        return touchThumbRect.contains(position);
      case PointerDeviceKind.mouse:
      case PointerDeviceKind.stylus:
      case PointerDeviceKind.invertedStylus:
      case PointerDeviceKind.unknown:
      default: // ignore: no_default_cases, to allow adding new device types to [PointerDeviceKind]
        // TODO(moffatman): Remove after landing https://github.com/flutter/flutter/issues/23604
        return _thumbRect!.contains(position);
    }
  }

  // Scrollbars are interactive.
  @override
  bool? hitTest(Offset? position) {
    if (_thumbRect == null) {
      return null;
    }
    if (ignorePointer) {
      return false;
    }

    // The thumb is not able to be hit when transparent.
    if (fadeoutOpacityAnimation.value == 0.0) {
      return false;
    }

    if (!_lastMetricsAreScrollable) {
      return false;
    }

    return _trackRect!.contains(position!);
  }

  @override
  bool shouldRepaint(_ScrollbarPainter oldDelegate) {
    // Should repaint if any properties changed.
    return color != oldDelegate.color ||
        trackColor != oldDelegate.trackColor ||
        trackBorderColor != oldDelegate.trackBorderColor ||
        textDirection != oldDelegate.textDirection ||
        thickness != oldDelegate.thickness ||
        fadeoutOpacityAnimation != oldDelegate.fadeoutOpacityAnimation ||
        mainAxisMargin != oldDelegate.mainAxisMargin ||
        crossAxisMargin != oldDelegate.crossAxisMargin ||
        radius != oldDelegate.radius ||
        trackRadius != oldDelegate.trackRadius ||
        shape != oldDelegate.shape ||
        padding != oldDelegate.padding ||
        minLength != oldDelegate.minLength ||
        minOverscrollLength != oldDelegate.minOverscrollLength ||
        scrollbarOrientation != oldDelegate.scrollbarOrientation ||
        ignorePointer != oldDelegate.ignorePointer;
  }

  @override
  bool shouldRebuildSemantics(CustomPainter oldDelegate) => false;

  @override
  SemanticsBuilderCallback? get semanticsBuilder => null;

  @override
  String toString() => describeIdentity(this);
}

String describeIdentity(Object? object) =>
    '${objectRuntimeType(object, '<optimized out>')}#${shortHash(object)}';

String objectRuntimeType(Object? object, String optimizedValue) {
  assert(() {
    optimizedValue = object.runtimeType.toString();
    return true;
  }());
  return optimizedValue;
}

String shortHash(Object? object) {
  return object.hashCode.toUnsigned(20).toRadixString(16).padLeft(5, '0');
}

// A longpress gesture detector that only responds to events on the scrollbar's
// thumb and ignores everything else.
class _ThumbPressGestureRecognizer extends LongPressGestureRecognizer {
  _ThumbPressGestureRecognizer({
    double? postAcceptSlopTolerance,
    Set<PointerDeviceKind>? supportedDevices,
    required GlobalKey customPaintKey,
    required Object debugOwner,
    required Duration duration,
    this.onlyDraggingThumb = false,
  })  : _customPaintKey = customPaintKey,
        super(
          postAcceptSlopTolerance: postAcceptSlopTolerance,
          supportedDevices: supportedDevices,
          debugOwner: debugOwner,
          duration: duration,
        );

  final GlobalKey _customPaintKey;
  final bool onlyDraggingThumb;

  @override
  bool isPointerAllowed(PointerDownEvent event) {
    if (!_hitTestInteractive(
        _customPaintKey, event.position, event.kind, onlyDraggingThumb)) {
      return false;
    }
    return super.isPointerAllowed(event);
  }
}

// foregroundPainter also hit tests its children by default, but the
// scrollbar should only respond to a gesture directly on its thumb, so
// manually check for a hit on the thumb here.
bool _hitTestInteractive(GlobalKey customPaintKey, Offset offset,
    PointerDeviceKind kind, bool onlyDraggingThumb) {
  if (customPaintKey.currentContext == null) {
    return false;
  }
  final CustomPaint customPaint =
      customPaintKey.currentContext!.widget as CustomPaint;
  final _ScrollbarPainter painter =
      customPaint.foregroundPainter! as _ScrollbarPainter;
  final Offset localOffset = _getLocalOffset(customPaintKey, offset);
  // We can only receive track taps that are on the thumb.
  return onlyDraggingThumb
      ? painter.hitTestOnlyThumbInteractive(localOffset, kind)
      : painter.hitTestInteractive(localOffset, kind);
}

Offset _getLocalOffset(GlobalKey scrollbarPainterKey, Offset position) {
  final RenderBox renderBox =
      scrollbarPainterKey.currentContext!.findRenderObject()! as RenderBox;
  return renderBox.globalToLocal(position);
}

enum _HoverAxis {
  vertical,
  horizontal,
  none;

  bool get isVertical => this == _HoverAxis.vertical;
  bool get isHorizontal => this == _HoverAxis.horizontal;
  bool get isNone => this == _HoverAxis.none;
}
