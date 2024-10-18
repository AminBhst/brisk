import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pluto_grid/src/ui/miscellaneous/pluto_visibility_layout.dart';

import '../../../mock/shared_mocks.mocks.dart';

const double childHeight = 50;
const double defaultChildWidth = 200;

class _TestWidgetWrapper extends StatefulWidget {
  const _TestWidgetWrapper({
    required this.child,
    Key? key,
  }) : super(key: key);

  final Widget child;

  @override
  State<_TestWidgetWrapper> createState() => _TestWidgetWrapperState();
}

class _TestWidgetWrapperState extends State<_TestWidgetWrapper> {
  bool visible = true;

  void setVisible(bool flag) {
    setState(() {
      visible = flag;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: visible,
      child: widget.child,
    );
  }
}

class _TestLayoutChild extends Container implements PlutoVisibilityLayoutChild {
  _TestLayoutChild({
    this.width = defaultChildWidth,
    // ignore: unused_element
    this.startPosition = 0,
    // ignore: unused_element
    this.keepAlive = false,
  }) : super(width: width, height: childHeight);

  @override
  final double width;

  @override
  final double startPosition;

  @override
  final bool keepAlive;
}

class _TestDelegate extends MultiChildLayoutDelegate {
  _TestDelegate(this.children);

  final List<PlutoVisibilityLayoutId> children;

  @override
  Size getSize(BoxConstraints constraints) {
    return Size(
      children.fold(0, (pre, element) => pre + element.layoutChild.width),
      children.length * childHeight,
    );
  }

  @override
  void performLayout(Size size) {
    double x = 0;

    for (final child in children) {
      final childId = child.id;
      final childWidget = child.layoutChild;
      if (hasChild(childId)) {
        layoutChild(
          childId,
          BoxConstraints.tightFor(
            width: childWidget.width,
            height: childHeight,
          ),
        );

        positionChild(childId, Offset(x, 0));
      }

      x += childWidget.width;
    }
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) {
    return true;
  }
}

void main() {
  late MultiChildLayoutDelegate delegate;

  late MockScrollController scrollController;

  late MockScrollPosition scrollPosition;

  PlutoVisibilityLayoutChild createChildren() {
    return _TestLayoutChild();
  }

  Widget buildWidget({
    required ScrollController scrollController,
    Axis scrollDirection = Axis.horizontal,
    List<PlutoVisibilityLayoutId> children = const [],
  }) {
    delegate = _TestDelegate(children);

    return MaterialApp(
      home: Material(
        child: SingleChildScrollView(
          scrollDirection: scrollDirection,
          child: _TestWidgetWrapper(
            child: PlutoVisibilityLayout(
              delegate: delegate,
              scrollController: scrollController,
              children: children,
            ),
          ),
        ),
      ),
    );
  }

  setUp(() {
    scrollController = MockScrollController();
    scrollPosition = MockScrollPosition();
    when(scrollController.offset).thenReturn(0);
    when(scrollController.position).thenReturn(scrollPosition);
    when(scrollPosition.hasViewportDimension).thenReturn(true);
  });

  group('horizontal', () {
    testWidgets(
      'scrollController.addListener 가 호출 되어야 한다.',
      (tester) async {
        when(scrollPosition.viewportDimension).thenReturn(
          tester.view.physicalSize.width,
        );

        final children = <PlutoVisibilityLayoutId>[
          PlutoVisibilityLayoutId(id: 'id', child: createChildren()),
        ];

        await tester.pumpWidget(buildWidget(
          scrollController: scrollController,
          children: children,
        ));

        verify(scrollController.addListener(argThat(isA<Function>())));
      },
    );

    testWidgets(
      '위젯이 사라지면 scrollController.removeListener 가 호출 되어야 한다.',
      (tester) async {
        when(scrollPosition.viewportDimension).thenReturn(
          tester.view.physicalSize.width,
        );

        final children = <PlutoVisibilityLayoutId>[
          PlutoVisibilityLayoutId(id: 'id', child: createChildren()),
        ];

        await tester.pumpWidget(buildWidget(
          scrollController: scrollController,
          children: children,
        ));

        final wrapperState = tester.state(find.byType(_TestWidgetWrapper))
            as _TestWidgetWrapperState;

        wrapperState.setVisible(false);

        await tester.pumpAndSettle();

        verify(scrollController.removeListener(argThat(isA<Function>())));
      },
    );

    testWidgets(
      '_TestLayoutChild 가 노출 되어야 한다.',
      (tester) async {
        when(scrollPosition.viewportDimension).thenReturn(
          tester.view.physicalSize.width,
        );

        final children = <PlutoVisibilityLayoutId>[
          PlutoVisibilityLayoutId(id: 'id', child: createChildren()),
        ];

        await tester.pumpWidget(buildWidget(
          scrollController: scrollController,
          children: children,
        ));

        final found = find.byType(_TestLayoutChild);

        final Size size = tester.getSize(found);

        final Offset position = tester.getTopLeft(found);

        expect(found, findsOneWidget);

        expect(size, const Size(defaultChildWidth, childHeight));

        expect(position, const Offset(0, 0));
      },
    );

    testWidgets(
      '_TestLayoutChild 3개, 순서대로 노출 되어야 한다.',
      (tester) async {
        when(scrollPosition.viewportDimension).thenReturn(
          tester.view.physicalSize.width,
        );

        final children = <PlutoVisibilityLayoutId>[
          PlutoVisibilityLayoutId(id: 'id1', child: createChildren()),
          PlutoVisibilityLayoutId(id: 'id2', child: createChildren()),
          PlutoVisibilityLayoutId(id: 'id3', child: createChildren()),
        ];

        await tester.pumpWidget(buildWidget(
          scrollController: scrollController,
          children: children,
        ));

        final found = find.byType(_TestLayoutChild);

        expect(found.at(0), findsOneWidget);
        expect(
          tester.getSize(found.at(0)),
          const Size(defaultChildWidth, childHeight),
        );
        expect(tester.getTopLeft(found.at(0)), const Offset(0, 0));

        expect(found.at(1), findsOneWidget);
        expect(
          tester.getSize(found.at(1)),
          const Size(defaultChildWidth, childHeight),
        );
        expect(
          tester.getTopLeft(found.at(1)),
          const Offset(defaultChildWidth * 1, 0),
        );

        expect(found.at(2), findsOneWidget);
        expect(
          tester.getSize(found.at(2)),
          const Size(defaultChildWidth, childHeight),
        );
        expect(
          tester.getTopLeft(found.at(2)),
          const Offset(defaultChildWidth * 2, 0),
        );
      },
    );
  });
}
