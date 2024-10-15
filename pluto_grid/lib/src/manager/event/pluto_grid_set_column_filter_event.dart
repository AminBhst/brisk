import 'package:pluto_grid/pluto_grid.dart';

/// If the value of [PlutoGridStateManager.filterOnlyEvent] is true,
/// an event is issued.
/// [PlutoInfinityScrollRows] or [PlutoLazyPagination] Event
/// for delegating filtering processing to widgets.
class PlutoGridSetColumnFilterEvent extends PlutoGridEvent {
  PlutoGridSetColumnFilterEvent({required this.filterRows});

  final List<PlutoRow> filterRows;

  @override
  void handler(PlutoGridStateManager stateManager) {}
}
