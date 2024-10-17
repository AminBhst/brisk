import 'package:pluto_grid/pluto_grid.dart';

class DoubleTapDetector {
  static PlutoCell? prevTappedCell;
  static int lastTap = DateTime.now().millisecondsSinceEpoch;
  static int consecutiveTaps = 1;

  static bool isDoubleTap(PlutoCell cell) {
    int now = DateTime.now().millisecondsSinceEpoch;
    bool doubleTap = false;
    if (now - lastTap < 300) {
      consecutiveTaps++;
      if (consecutiveTaps >= 2 && prevTappedCell == cell) {
        doubleTap = true;
      }
    } else {
      consecutiveTaps = 1;
      doubleTap = false;
    }
    lastTap = now;
    prevTappedCell = cell;
    return doubleTap;
  }
}
