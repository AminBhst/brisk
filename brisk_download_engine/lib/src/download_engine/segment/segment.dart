class Segment {
  final int startByte;
  final int endByte;

  Segment(this.startByte, this.endByte);

  int get length => this.endByte - this.startByte + 1;

  @override
  String toString() {
    return "startByte: $startByte  endByte: $endByte";
  }

  bool isInRangeOfOther(Segment other) {
    return this.startByte >= other.startByte && this.endByte <= other.endByte;
  }

  bool overlapsWithOther(Segment other) {
    return this.startByte <= other.startByte && this.endByte >= other.startByte;
  }

  bool get isValid =>
      this.startByte != this.endByte &&
      this.startByte < this.endByte &&
      this.startByte + 1 < this.endByte;

  @override
  bool operator ==(Object other) {
    return (other is Segment) &&
        other.startByte == this.startByte &&
        other.endByte == this.endByte;
  }
}
