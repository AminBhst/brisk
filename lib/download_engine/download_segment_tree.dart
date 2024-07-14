import 'package:brisk/download_engine/segment.dart';

/// A tree implementation of download segments. Used for dynamic segmentation
/// of the download byte ranges associated with their designated connections.
/// When a download initially begins, it is started with one root node with
/// startByte=0 and endByte=contentLength. As the engine adds new connections,
/// the tree is further broken down into smaller segments, each associated with
/// a download connection.
///
/// An example visual representation of the tree:
///               [0    -     1000] ===============> (initial)
///                /             \
///          [0-500]-------------[501-1000] ========> (First [split] call)
///         /      \            /        \
///     [0-250]--[251-500]---[501-750]--[751-1000] ==> (Second [split] call)
class DownloadSegmentTree {
  SegmentNode root;

  DownloadSegmentTree(this.root);

  factory DownloadSegmentTree.create(Segment segment) {
    return DownloadSegmentTree(SegmentNode(segment: segment));
  }

  /// In cases where the tree is built around a previously-
  /// existing download, due to the possibility of having multiple missing byte-ranges
  /// (e.g. [500-1000], [4000-7000], [9000-14000]) we may have multiple root-
  /// nodes (connected through [rightNeighbor]), each representing a missing byte range.
  factory DownloadSegmentTree.fromByteRanges(List<Segment> segments) {
    final tree = DownloadSegmentTree(
      SegmentNode(segment: segments.first),
    );
    if (segments.length <= 1) {
      return tree;
    }
    var node = tree.root;
    for (int i = 1; i < segments.length; i++) {
      final segment = segments[i];
      node.rightNeighbor = SegmentNode(segment: segment);
      node = node.rightNeighbor!;
    }
    return tree;
  }

  /// Splits and breaks down the lowest level nodes to new download segments
  void split() {
    SegmentNode node = lowestLevelLeftNode;
    splitSegmentNode(node, isLeftNode: true);
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

  SegmentNode get lowestLevelLeftNode {
    SegmentNode node = root;
    while (node.left != null) {
      node = node.left!;
    }
    return node;
  }

  List<SegmentNode> get lowestLevelNodes {
    var node = lowestLevelLeftNode;
    var nodes = [node];
    while (node.rightNeighbor != null) {
      nodes.add(node.rightNeighbor!);
      node = node.rightNeighbor!;
    }
    return nodes;
  }

  /// Returns the lowest level segments, i.e.
  List<Segment> get currentSegment =>
      lowestLevelNodes.map((e) => e.segment).toList();

  void splitSegmentNode(SegmentNode node, {isLeftNode = false}) {
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
    if (isLeftNode) {
      node.left!.connectionNumber = 0;
      node.right!.connectionNumber = 1;
    }
  }
}

/// [SegmentNode] Represents a segment node in the tree.
/// [segment] The segment containing startByte and endByte
/// [right] : The child node on the right-side
/// [left] : The child node on the left-side
/// [rightNeighbor] : The neighbor node residing on the same level as {this} node
/// [connectionNumber] : The connection number that this segment node is assigned to
class SegmentNode {
  Segment segment;
  SegmentNode? left;
  SegmentNode? right;
  SegmentNode? rightNeighbor;
  int connectionNumber;

  SegmentNode({required this.segment, this.connectionNumber = 0});
}
