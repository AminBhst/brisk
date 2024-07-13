import 'package:brisk/download_engine/segment.dart';

/// A tree implementation of download segments. Used for dynamic segmentation
/// of the download byte ranges associated with their designated connections
class DownloadSegmentTree {
  SegmentNode root;

  DownloadSegmentTree(this.root);

  factory DownloadSegmentTree.create(Segment segment) {
    return DownloadSegmentTree(SegmentNode(segment: segment));
  }

  void split() {
    SegmentNode node = root;
    while (node.left != null) {
      node = node.left!;
    }
    splitSegmentNode(node, isLeftLeaf: true);
    if (node == root) return;

    int nodeConnNumber = 2;
    SegmentNode? currentNeighbor = node.rightNeighbor!;
    while (currentNeighbor != null) {
      splitSegmentNode(currentNeighbor);
      node.right!.rightNeighbor = currentNeighbor.left;
      currentNeighbor.left!.connectionNumber = nodeConnNumber;
      ++nodeConnNumber;
      currentNeighbor.right!.connectionNumber = nodeConnNumber;
      node = currentNeighbor;
      currentNeighbor = currentNeighbor.rightNeighbor;
    }
  }

  void splitSegmentNode(SegmentNode node, {isLeftLeaf = false}) {
    final nodeSegment = node.segment;
    final splitByte =
        ((nodeSegment.endByte - nodeSegment.startByte) / 2).floor();
    Segment segLeft;
    Segment segRight;
    if (nodeSegment.startByte > splitByte) {
      final endByte = splitByte + nodeSegment.startByte;
      segLeft = Segment(nodeSegment.startByte, endByte);
      segRight = Segment(endByte + 1, nodeSegment.endByte);
    } else {
      segLeft = Segment(nodeSegment.startByte, splitByte);
      segRight = Segment(splitByte + 1, nodeSegment.endByte);
    }
    node.right = SegmentNode(segment: segRight);
    node.left = SegmentNode(segment: segLeft);
    node.left!.rightNeighbor = node.right;
    if (isLeftLeaf) {
      node.left!.connectionNumber = 0;
      node.right!.connectionNumber = 1;
    }
  }
}

class SegmentNode {
  Segment segment;
  SegmentNode? left;
  SegmentNode? right;
  SegmentNode? rightNeighbor;
  int connectionNumber = 0;

  SegmentNode({required this.segment});
}
