import 'dart:io';

class Segment {
  final int startByte;
  final int endByte;
  final File? file;

  Segment(this.startByte, this.endByte, [this.file]);

  int get length => endByte - startByte + 1;

  @override
  String toString() {
    return "startByte: $startByte  endByte: $endByte";
  }

  bool isInRangeOfOther(Segment other) {
    return startByte >= other.startByte && endByte <= other.endByte;
  }

  bool overlapsWithOther(Segment other) {
    return startByte <= other.startByte && endByte >= other.startByte;
  }

  bool get isValid =>
      startByte != endByte && startByte < endByte && startByte + 1 < endByte;

  @override
  bool operator ==(Object other) {
    return (other is Segment) &&
        other.startByte == startByte &&
        other.endByte == endByte;
  }
}
