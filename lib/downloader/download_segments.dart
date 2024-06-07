import 'package:brisk/downloader/segment.dart';

class DownloadSegments {
  int contentLength = 0;
  List<Segment> segments = [];

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

  void updateSegment() {
    List<Segment> newSegments = [];
    for (var segment in segments) {
      final splitByte = ((segment.endByte - segment.startByte) / 2).floor();
      final segOne = Segment(segment.startByte, splitByte);
      final segTwo = Segment(splitByte + 1, segment.endByte);
      newSegments.add(segOne);
      newSegments.add(segTwo);
    }
    this.segments = newSegments;
  }
}
