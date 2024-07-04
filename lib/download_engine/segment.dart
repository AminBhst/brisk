import 'package:brisk/download_engine/segment_status.dart';

class Segment {
  final startByte;
  final endByte;
  SegmentStatus status = SegmentStatus.INITIAL;

  Segment(this.startByte, this.endByte);

  @override
  String toString() {
    return "startByte: $startByte  endByte: $endByte";
  }
}
