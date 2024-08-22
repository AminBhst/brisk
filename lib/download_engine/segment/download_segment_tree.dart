import 'package:brisk/download_engine/segment/segment.dart';
import 'package:brisk/download_engine/segment/segment_status.dart';
import 'package:dartx/dartx.dart';

/// A tree implementation of download segments. Used for dynamic segmentation
/// of the download byte ranges associated with their designated connections.
/// When a download initially begins, it is started with one root node with
/// startByte=0 and endByte=contentLength. As the engine adds new connections,
/// the tree is further broken down into smaller segments, each associated with
/// a download connection.
///
/// An example visual representation of the tree:
///
///               [0    -     1000] ===============> (initial)
///                /             \
///               /               \
///          [0-500]-------------[501-1000] ========> (First [split] call)
///         /      \            /        \
///        /        \          /          \
///     [0-250]--[251-500]---[501-750]--[751-1000] ==> (Second [split] call)
class DownloadSegmentTree {
  SegmentNode root;
  int maxConnectionNumber = 0;
  late final lowestLevelNodes = [root];

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
      node.rightNeighbor = SegmentNode(segment: segment, connectionNumber: i);
      node = node.rightNeighbor!;
      tree.maxConnectionNumber = i;
    }
    return tree;
  }

  /// Splits and breaks down the lowest level nodes to new download segments
  void split() {
    SegmentNode node = lowestLevelLeftNode;
    splitSegmentNode(node);
    if (node == root) {
      return;
    }
    SegmentNode? currentNeighbor = node.rightNeighbor!;
    while (currentNeighbor != null) {
      if (currentNeighbor.segmentStatus == SegmentStatus.COMPLETE) {
        currentNeighbor = currentNeighbor.rightNeighbor;
        continue;
      }
      splitSegmentNode(currentNeighbor);
      node.rightChild!.rightNeighbor = currentNeighbor.leftChild;
      node = currentNeighbor;
      currentNeighbor = currentNeighbor.rightNeighbor;
    }
  }

  SegmentNode get lowestLevelLeftNode {
    SegmentNode node = root;
    while (node.leftChild != null) {
      node = node.leftChild!;
    }
    return node;
  }

  SegmentNode? searchNode(Segment targetSegment) {
    return _searchNodeRecursive(targetSegment, root);
  }

  SegmentNode? _searchNodeRecursive(Segment target, SegmentNode? currentNode) {
    if (currentNode == null) {
      return null;
    }
    if (target == currentNode.segment) {
      return currentNode;
    }
    final rChild = currentNode.rightChild;
    final lChild = currentNode.leftChild;
    if (rChild == null || lChild == null) {
      return null;
    }
    if (target.isInRangeOfOther(lChild.segment)) {
      return _searchNodeRecursive(target, lChild);
    } else if (target.isInRangeOfOther(rChild.segment)) {
      return _searchNodeRecursive(target, rChild);
    }
    return null;
  }

  List<SegmentNode> getAllSameLevelNodes(SegmentNode node) {
    var currentNode = getSameLevelLeftNode(node);
    var nodes = [currentNode];
    while (currentNode.rightNeighbor != null) {
      currentNode = currentNode.rightNeighbor!;
      nodes.add(currentNode);
    }
    return nodes;
  }

  SegmentNode getSameLevelLeftNode(SegmentNode node) {
    var currentNode = node;
    while (node.leftNeighbor != null) {
      currentNode = node.leftNeighbor!;
    }
    return currentNode;
  }

  List<SegmentNode>? get inUseNodes => lowestLevelNodes
      .filter((node) => node.segmentStatus == SegmentStatus.IN_USE)
      .toList();

  /// Returns the lowest level segments, i.e.
  List<Segment> get currentSegment =>
      lowestLevelNodes.map((e) => e.segment).toList();

  bool splitSegmentNode(SegmentNode node, {setConnectionNumber = true}) {
    final nodeSegment = node.segment;
    final splitByte =
        ((nodeSegment.endByte - nodeSegment.startByte) / 2).floor();
    if (splitByte <= 0) {
      return false;
    }
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
    if (!segLeft.isValid || !segRight.isValid) {
      return false;
    }
    node.rightChild = SegmentNode(segment: segRight, parent: node);
    node.leftChild = SegmentNode(segment: segLeft, parent: node);
    node.leftChild!.rightNeighbor = node.rightChild;
    node.rightChild!.leftNeighbor = node.leftChild;
    node.leftChild!.connectionNumber = node.connectionNumber;
    if (setConnectionNumber) {
      this.maxConnectionNumber++;
      node.rightChild!.connectionNumber = maxConnectionNumber;
    }
    final nodeIndex = lowestLevelNodes.indexWhere(
      (s) => s.segment == node.segment,
    );
    node.setLastUpdateMillis();
    lowestLevelNodes.removeAt(nodeIndex);
    lowestLevelNodes.insert(nodeIndex, node.leftChild!);
    lowestLevelNodes.insert(nodeIndex + 1, node.rightChild!);
    return true;
  }
}

/// [SegmentNode] Represents a segment node in the tree.
/// [segment] The segment containing startByte and endByte
/// [rightChild] : The child node on the right-side
/// [leftChild] : The child node on the left-side
/// [rightNeighbor] : The neighbor node residing on the same level as {this} node
/// [connectionNumber] : The connection number that this segment node is assigned to
class SegmentNode {
  Segment segment;
  SegmentNode? rightChild;
  SegmentNode? leftChild;
  SegmentNode? rightNeighbor;
  SegmentNode? leftNeighbor;
  SegmentNode? parent;
  int connectionNumber;
  SegmentStatus segmentStatus;
  int lastUpdateMillis = DateTime.now().millisecondsSinceEpoch;

  void removeChildren() {
    this.rightChild = null;
    this.leftChild = null;
  }

  void setLastUpdateMillis() {
    this.lastUpdateMillis = DateTime.now().millisecondsSinceEpoch;
  }

  SegmentNode? getChildByDirection(NodeRelationDirection direction) {
    if (direction == NodeRelationDirection.RIGHT) {
      return this.rightChild;
    } else if (direction == NodeRelationDirection.LEFT) {
      return this.leftChild;
    }
    return null;
  }

  NodeRelationDirection? findChildDirection(SegmentNode child) {
    var nodeDirection;
    if (this.leftChild == child) {
      nodeDirection = NodeRelationDirection.LEFT;
    } else if (this.rightChild == child) {
      nodeDirection = NodeRelationDirection.RIGHT;
    } else {
      print("Target node not found based on parent node. FATAL!");
      return null;
    }
    return nodeDirection;
  }

  SegmentNode({
    required this.segment,
    this.connectionNumber = 0,
    this.parent,
    this.segmentStatus = SegmentStatus.INITIAL,
  });
}

enum NodeRelationDirection {
  RIGHT,
  LEFT,
}

extension NodeRelationDirectionExtension on NodeRelationDirection {
  NodeRelationDirection get opposite => this == NodeRelationDirection.LEFT
      ? NodeRelationDirection.RIGHT
      : NodeRelationDirection.LEFT;
}

enum NodeRelationshipType { CHILD, NEIGHBOR, PARENT }
