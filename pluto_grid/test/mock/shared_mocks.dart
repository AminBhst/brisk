import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:mockito/annotations.dart';
import 'package:pluto_grid/pluto_grid.dart';

@GenerateNiceMocks([
  MockSpec<PlutoGridStateManager>(),
  MockSpec<PlutoGridEventManager>(),
  MockSpec<PlutoGridScrollController>(),
  MockSpec<PlutoGridKeyPressed>(),
  MockSpec<LinkedScrollControllerGroup>(),
  MockSpec<ScrollController>(),
  MockSpec<ScrollPosition>(),
  MockSpec<StreamSubscription>(),
  MockSpec<FocusNode>(),
])
void main() {}
