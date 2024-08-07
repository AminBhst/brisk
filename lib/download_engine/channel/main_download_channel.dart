import 'dart:collection';

import 'package:brisk/download_engine/channel/download_connection_channel.dart';
import 'package:brisk/download_engine/segment/download_segment_tree.dart';
import 'package:brisk/download_engine/util/isolate_channel_wrapper.dart';

/// The download channel listened by [DownloadRequestProvider]
class MainDownloadChannel extends IsolateChannelWrapper {
  DownloadSegmentTree? segmentTree;

  /// Connection channels listened by [DownloadConnectionInvoker]
  Map<int, DownloadConnectionChannel> connectionChannels = {};

  Queue<DownloadConnectionChannel> connectionReuseQueue = Queue();

  int createdConnections = 1; // TODO actually it only counts the number of refresh requests

  void setConnectionChannel(int connNum, DownloadConnectionChannel channel) {
    this.connectionChannels[connNum] = channel;
  }

  MainDownloadChannel({required super.channel});
}
