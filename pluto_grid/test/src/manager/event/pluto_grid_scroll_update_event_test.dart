import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../mock/shared_mocks.mocks.dart';

void main() {
  late MockPlutoGridStateManager stateManager;
  late PlutoGridScrollController scrollController;
  late MockLinkedScrollControllerGroup vertical;
  late MockLinkedScrollControllerGroup horizontal;
  late MockScrollController verticalController;
  late MockScrollController horizontalController;
  late MockScrollPosition scrollPosition;

  eventBuilder({
    required Offset offset,
  }) =>
      PlutoGridScrollUpdateEvent(
        offset: offset,
      );

  setUp(() {
    stateManager = MockPlutoGridStateManager();
    vertical = MockLinkedScrollControllerGroup();
    horizontal = MockLinkedScrollControllerGroup();
    verticalController = MockScrollController();
    horizontalController = MockScrollController();
    scrollController = PlutoGridScrollController(
      vertical: vertical,
      horizontal: horizontal,
    );
    scrollController.setBodyRowsVertical(verticalController);
    scrollController.setBodyRowsHorizontal(horizontalController);
    scrollPosition = MockScrollPosition();

    when(stateManager.scroll).thenReturn(scrollController);
    when(stateManager.directionalScrollEdgeOffset).thenReturn(Offset.zero);
    when(stateManager.maxWidth).thenReturn(800);
    when(verticalController.offset).thenReturn(0);
    when(horizontalController.offset).thenReturn(0);
    when(verticalController.position).thenReturn(scrollPosition);
    when(horizontalController.position).thenReturn(scrollPosition);
    when(scrollPosition.isScrollingNotifier).thenReturn(ValueNotifier(false));
  });

  group('인수 값 테스트', () {
    test(
      'offset 이 null 이 아니면 needMovingScroll 이 호출 되어야 한다.',
      () {
        const offset = Offset(0, 0);
        when(stateManager.needMovingScroll(any, any)).thenReturn(false);
        when(stateManager.toDirectionalOffset(any)).thenReturn(offset);

        var event = eventBuilder(offset: offset);
        event.handler(stateManager);

        verify(stateManager.needMovingScroll(any, any)).called(4);
      },
    );

    test(
      'needMovingScroll(offset, PlutoMoveDirection.left) 가 true 면, '
      'horizontal scroll 의 animateTo 의 offset 이 0 으로 호출 되어야 한다.',
      () {
        const offset = Offset(0, 0);
        const scrollOffset = 10.0;

        when(horizontalController.offset).thenReturn(scrollOffset);
        when(stateManager.toDirectionalOffset(any)).thenReturn(offset);

        when(stateManager.needMovingScroll(offset, PlutoMoveDirection.left))
            .thenReturn(true);
        when(stateManager.needMovingScroll(offset, PlutoMoveDirection.right))
            .thenReturn(false);
        when(stateManager.needMovingScroll(offset, PlutoMoveDirection.up))
            .thenReturn(false);
        when(stateManager.needMovingScroll(offset, PlutoMoveDirection.down))
            .thenReturn(false);

        var event = eventBuilder(offset: offset);
        event.handler(stateManager);

        verify(horizontalController.animateTo(
          0.0,
          curve: anyNamed('curve'),
          duration: anyNamed('duration'),
        ));
      },
    );

    test(
      'needMovingScroll(offset, PlutoMoveDirection.right) 가 true 면, '
      'horizontal scroll 의 animateTo 가 maxScrollExtent 으로 호출 되어야 한다.',
      () {
        const offset = Offset(10, 10);
        const scrollOffset = 0.0;

        when(horizontalController.offset).thenReturn(scrollOffset);
        when(scrollPosition.maxScrollExtent).thenReturn(100);
        when(stateManager.toDirectionalOffset(any)).thenReturn(offset);

        when(stateManager.needMovingScroll(offset, PlutoMoveDirection.left))
            .thenReturn(false);
        when(stateManager.needMovingScroll(offset, PlutoMoveDirection.right))
            .thenReturn(true);
        when(stateManager.needMovingScroll(offset, PlutoMoveDirection.up))
            .thenReturn(false);
        when(stateManager.needMovingScroll(offset, PlutoMoveDirection.down))
            .thenReturn(false);

        var event = eventBuilder(offset: offset);
        event.handler(stateManager);

        verify(horizontalController.animateTo(
          100,
          curve: anyNamed('curve'),
          duration: anyNamed('duration'),
        ));
      },
    );

    test(
      'needMovingScroll(offset, PlutoMoveDirection.up) 가 true 면, '
      'vertical scroll 의 animateTo 가 offset 이 0 으로 호출 되어야 한다.',
      () {
        const offset = Offset(0, 0);
        const scrollOffset = 10.0;

        when(verticalController.offset).thenReturn(scrollOffset);
        when(stateManager.toDirectionalOffset(any)).thenReturn(offset);

        when(stateManager.needMovingScroll(offset, PlutoMoveDirection.left))
            .thenReturn(false);
        when(stateManager.needMovingScroll(offset, PlutoMoveDirection.right))
            .thenReturn(false);
        when(stateManager.needMovingScroll(offset, PlutoMoveDirection.up))
            .thenReturn(true);
        when(stateManager.needMovingScroll(offset, PlutoMoveDirection.down))
            .thenReturn(false);

        var event = eventBuilder(offset: offset);
        event.handler(stateManager);

        verify(verticalController.animateTo(
          0,
          curve: anyNamed('curve'),
          duration: anyNamed('duration'),
        ));
      },
    );

    test(
      'needMovingScroll(offset, PlutoMoveDirection.down) 가 true 면, '
      'vertical scroll 의 animateTo offset 이 maxScrollExtent 으로 호출 되어야 한다.',
      () {
        const offset = Offset(0, 0);
        const scrollOffset = 10.0;

        when(verticalController.offset).thenReturn(scrollOffset);
        when(scrollPosition.maxScrollExtent).thenReturn(200);
        when(stateManager.toDirectionalOffset(any)).thenReturn(offset);

        when(stateManager.needMovingScroll(offset, PlutoMoveDirection.left))
            .thenReturn(false);
        when(stateManager.needMovingScroll(offset, PlutoMoveDirection.right))
            .thenReturn(false);
        when(stateManager.needMovingScroll(offset, PlutoMoveDirection.up))
            .thenReturn(false);
        when(stateManager.needMovingScroll(offset, PlutoMoveDirection.down))
            .thenReturn(true);

        var event = eventBuilder(offset: offset);
        event.handler(stateManager);

        verify(verticalController.animateTo(
          200,
          curve: anyNamed('curve'),
          duration: anyNamed('duration'),
        ));
      },
    );
  });
}
