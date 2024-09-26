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
///               [     0-1000     ] ===============> (initial)
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

  /// Used to create the segment tree from multiple missing segments. This is used
  /// when the app was closed without the download being complete, leading to
  /// the loss of the initial segment tree. In order to resume the download,
  /// we need to build the tree again using the missing byte ranges.
  factory DownloadSegmentTree.buildFromMissingBytes(
    int contentLength,
    int maxNumberOfConnections,
    List<Segment> segments,
  ) {
    final tree = DownloadSegmentTree(
      SegmentNode(segment: Segment(0, contentLength)),
    );
    final first = segments[0];
    if (segments.length == 1 &&
        first.startByte == 0 &&
        (first.endByte == contentLength || first.endByte == contentLength - 1)) {
      return tree;
    }
    if (first.startByte != 0) {
      tree.root.createLeftChild(
        0,
        first.startByte - 1,
        segmentStatus: SegmentStatus.COMPLETE,
        connectionNumber: 0,
      );
    } else {
      tree.root.createLeftChild(0, first.endByte, connectionNumber: 0);
    }
    tree.root
      ..connectionNumber = 0
      ..createRightChild(
        tree.root.leftChild!.segment.endByte + 1,
        contentLength,
        segmentStatus: SegmentStatus.OUT_DATED,
        connectionNumber: 1,
      );
    tree.root
      ..rightChild?.leftNeighbor = tree.root.leftChild
      ..leftChild?.rightNeighbor = tree.root.rightChild;
    tree.maxConnectionNumber = 1;
    tree.lowestLevelNodes
      ..remove(tree.root)
      ..add(tree.root.leftChild!)
      ..add(tree.root.rightChild!);
    if (first.startByte == 0 && segments.length == 1) {
      tree.root.rightChild!.segmentStatus = SegmentStatus.COMPLETE;
      return tree;
    }

    var missingSegments = [...segments];
    if (first.startByte == 0) {
      /// because it has already been assigned to a SegmentNode
      missingSegments.removeAt(0);
    }
    var iterationRoot = tree.root.rightChild!;
    var currentMaxConnectionNumber = -1;
    while (missingSegments.isNotEmpty) {
      final currentMissing = missingSegments[0];
      var exceededMaxConnectionNumber = false;
      if (iterationRoot.segment.startByte == currentMissing.startByte) {
        if (currentMaxConnectionNumber + 1 > maxNumberOfConnections - 1) {
          exceededMaxConnectionNumber = true;
        } else {
          currentMaxConnectionNumber++;
        }
        iterationRoot.createLeftChild(
          currentMissing.startByte,
          currentMissing.endByte,
          connectionNumber: currentMaxConnectionNumber,
          segmentStatus: exceededMaxConnectionNumber
              ? SegmentStatus.IN_QUEUE
              : SegmentStatus.INITIAL,
        );
        missingSegments.remove(currentMissing);
      } else {
        iterationRoot.createLeftChild(
          iterationRoot.segment.startByte,
          currentMissing.startByte - 1,
          segmentStatus: SegmentStatus.COMPLETE,
        );
      }
      iterationRoot.createRightChild(
        iterationRoot.leftChild!.segment.endByte + 1,
        contentLength,
        segmentStatus: exceededMaxConnectionNumber
            ? SegmentStatus.IN_QUEUE
            : SegmentStatus.OUT_DATED,
      );
      iterationRoot
        ..rightChild?.leftNeighbor = iterationRoot.leftChild
        ..leftChild?.rightNeighbor = iterationRoot.rightChild;
      final index = tree.lowestLevelNodes.indexOf(iterationRoot);
      tree.lowestLevelNodes
        ..removeAt(index)
        ..insert(index, iterationRoot.leftChild!)
        ..insert(index + 1, iterationRoot.rightChild!);
      if (missingSegments.isEmpty) {
        iterationRoot.rightChild!.segmentStatus = SegmentStatus.COMPLETE;
      }
      iterationRoot = iterationRoot.rightChild!;
    }
    var initialNodes = tree.lowestLevelNodes
        .where((node) => node.segmentStatus == SegmentStatus.INITIAL)
        .toList();
    if (initialNodes.length == maxNumberOfConnections) {
      return tree;
    }

    int connectionNumber =
        initialNodes.maxBy((node) => node.connectionNumber)!.connectionNumber;
    loop:
    while (connectionNumber <= maxNumberOfConnections) {
      initialNodes = tree.lowestLevelNodes
          .where((node) => node.segmentStatus == SegmentStatus.INITIAL)
          .toList();
      for (final node in initialNodes) {
        if (connectionNumber + 1 >= maxNumberOfConnections) {
          break loop;
        }
        final success = tree.splitSegmentNode(node);
        if (!success) break loop;
        connectionNumber++;
        node.rightChild!.connectionNumber = connectionNumber;
      }
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

  List<SegmentNode>? get inUseNodes => lowestLevelNodes
      .where((node) => node.segmentStatus == SegmentStatus.IN_USE)
      .toList();

  List<SegmentNode>? get inQueueNodes => lowestLevelNodes
      .where((node) => node.segmentStatus == SegmentStatus.IN_QUEUE)
      .toList();

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
    if (!segLeft.isValid ||
        !segRight.isValid ||
        segLeft.length < 8192 ||
        segRight.length < 8192) {
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

  void createLeftChild(
    int startByte,
    int endByte, {
    SegmentStatus segmentStatus = SegmentStatus.INITIAL,
    int connectionNumber = 0,
  }) {
    this.leftChild = SegmentNode(
      segment: Segment(startByte, endByte),
      parent: this,
      segmentStatus: segmentStatus,
      connectionNumber: connectionNumber,
    );
  }

  void createRightChild(
    int startByte,
    int endByte, {
    SegmentStatus segmentStatus = SegmentStatus.INITIAL,
    int connectionNumber = 0,
  }) {
    this.rightChild = SegmentNode(
      segment: Segment(startByte, endByte),
      parent: this,
      segmentStatus: segmentStatus,
      connectionNumber: connectionNumber,
    );
  }

  void removeChildren() {
    this.rightChild = null;
    this.leftChild = null;
  }

  void setLastUpdateMillis() {
    this.lastUpdateMillis = DateTime.now().millisecondsSinceEpoch;
  }

  SegmentNode({
    required this.segment,
    this.connectionNumber = 0,
    this.parent,
    this.segmentStatus = SegmentStatus.INITIAL,
  });
}
