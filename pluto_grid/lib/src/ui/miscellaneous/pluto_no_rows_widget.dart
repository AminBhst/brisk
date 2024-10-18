import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../ui.dart';

class PlutoNoRowsWidget extends PlutoStatefulWidget {
  const PlutoNoRowsWidget({
    required this.stateManager,
    required this.child,
    super.key,
  });

  final PlutoGridStateManager stateManager;

  final Widget child;

  @override
  PlutoStateWithChange<PlutoNoRowsWidget> createState() =>
      _PlutoNoRowsWidgetState();
}

class _PlutoNoRowsWidgetState extends PlutoStateWithChange<PlutoNoRowsWidget> {
  bool _show = false;

  @override
  PlutoGridStateManager get stateManager => widget.stateManager;

  @override
  void initState() {
    super.initState();

    updateState(PlutoNotifierEventForceUpdate.instance);
  }

  @override
  void updateState(PlutoNotifierEvent event) {
    _show = update<bool>(
      _show,
      !stateManager.showLoading && stateManager.refRows.isEmpty,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _show ? widget.child : const SizedBox.shrink(),
    );
  }
}
