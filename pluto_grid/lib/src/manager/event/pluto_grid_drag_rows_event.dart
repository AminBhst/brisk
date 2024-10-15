import 'package:pluto_grid/pluto_grid.dart';

/// Event called when a row is dragged.
class PlutoGridDragRowsEvent extends PlutoGridEvent {
  final List<PlutoRow> rows;
  final int targetIdx;

  PlutoGridDragRowsEvent({
    required this.rows,
    required this.targetIdx,
  });

  @override
  void handler(PlutoGridStateManager stateManager) async {
    stateManager.moveRowsByIndex(
      rows,
      targetIdx,
    );
  }
}
