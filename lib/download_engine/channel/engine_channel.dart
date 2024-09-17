import 'dart:collection';

import 'package:brisk/download_engine/channel/download_connection_channel.dart';
import 'package:brisk/download_engine/message/connection_handshake_message.dart';
import 'package:brisk/download_engine/segment/download_segment_tree.dart';
import 'package:brisk/download_engine/util/isolate_channel_wrapper.dart';

/// The download engine channel listened by [DownloadRequestProvider]
class EngineChannel extends IsolateChannelWrapper {
  DownloadSegmentTree? segmentTree;

  /// Connection channels listened by [DownloadConnectionInvoker]
  Map<int, DownloadConnectionChannel> connectionChannels = {};

  Queue<DownloadConnectionChannel> connectionReuseQueue = Queue();

  List<EngineConnectionHandshake> pendingHandshakes = [];

  // TODO actually it only counts the number of refresh requests
  int createdConnections = 1;

  bool pauseOnFinalHandshake = false;

  void setConnectionChannel(int connNum, DownloadConnectionChannel channel) {
    this.connectionChannels[connNum] = channel;
  }

  EngineChannel({required super.channel});
}
