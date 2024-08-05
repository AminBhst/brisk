class Segment {
  final startByte;
  final endByte;

  Segment(this.startByte, this.endByte);

  get length => this.endByte - this.startByte + 1;

  @override
  String toString() {
    return "startByte: $startByte  endByte: $endByte";
  }

  @override
  bool operator ==(Object other) {
    return (other is Segment) &&
        other.startByte == this.startByte &&
        other.endByte == this.endByte;
  }
}
