import 'package:brisk/download_engine/segment.dart';

class DownloadSegments {
  int contentLength = 0;
  List<Segment> segments = [];
  List<Segment> tempSegments = [];

  DownloadSegments();

  factory DownloadSegments.init(int contentLength) {
    final segmentList = DownloadSegments();
    segmentList.contentLength = contentLength;
    final initialSegment = Segment(0, contentLength);
    segmentList.segments.add(initialSegment);
    return segmentList;
  }

  factory DownloadSegments.fromByteRanges(List<Segment> ranges) {
    final segmentList = DownloadSegments();
    segmentList.segments = ranges;
    return segmentList;
  }

  void tempSplit() {
    List<Segment> newSegments = [];
    for (var segment in segments) {
      final splitByte = ((segment.endByte - segment.startByte) / 2).floor();
      Segment segOne;
      Segment segTwo;
      if (segment.startByte > splitByte) {
        final endByte = splitByte + segment.startByte;
        segOne = Segment(segment.startByte, endByte);
        segTwo = Segment(endByte + 1, segment.endByte);
      } else {
        segOne = Segment(segment.startByte, splitByte);
        segTwo = Segment(splitByte + 1, segment.endByte);
      }
      newSegments.add(segOne);
      newSegments.add(segTwo);
    }
    this.tempSegments = newSegments;
  }
}
