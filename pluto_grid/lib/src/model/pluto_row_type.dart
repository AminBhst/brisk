import 'package:pluto_grid/pluto_grid.dart';

abstract class PlutoRowType {
  factory PlutoRowType.normal() {
    return PlutoRowTypeNormal.instance;
  }

  factory PlutoRowType.group({
    required FilteredList<PlutoRow> children,
    bool expanded = false,
  }) {
    return PlutoRowTypeGroup(
      children: children,
      expanded: expanded,
    );
  }
}

extension PlutoRowTypeExtension on PlutoRowType {
  bool get isNormal => this is PlutoRowTypeNormal;

  bool get isGroup => this is PlutoRowTypeGroup;

  PlutoRowTypeNormal get normal {
    if (this is! PlutoRowTypeNormal) {
      throw TypeError();
    }

    return this as PlutoRowTypeNormal;
  }

  PlutoRowTypeGroup get group {
    if (this is! PlutoRowTypeGroup) {
      throw TypeError();
    }

    return this as PlutoRowTypeGroup;
  }
}

class PlutoRowTypeNormal implements PlutoRowType {
  const PlutoRowTypeNormal();

  static PlutoRowTypeNormal instance = const PlutoRowTypeNormal();
}

class PlutoRowTypeGroup implements PlutoRowType {
  PlutoRowTypeGroup({
    required this.children,
    bool expanded = false,
  }) : _expanded = expanded;

  final FilteredList<PlutoRow> children;

  bool get expanded => _expanded;

  bool _expanded;

  void setExpanded(bool flag) {
    _expanded = flag;
  }
}
