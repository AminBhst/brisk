import 'package:brisk/download_engine/download_connection_channel.dart';
import 'package:brisk/download_engine/download_segment_tree.dart';
import 'package:brisk/download_engine/isolate_channel_wrapper.dart';

/// The download channel that is listened by [DownloadRequestProvider]
class MainDownloadChannel extends IsolateChannelWrapper {
  DownloadSegmentTree? segmentTree;

  /// Connection channels that are listened by [DownloadConnectionInvoker]
  Map<int, DownloadConnectionChannel> connectionChannels = {};

  int createdConnections = 1; // TODO actually it only counts the number of refresh requests

  void setConnectionChannel(int connNum, DownloadConnectionChannel channel) {
    this.connectionChannels[connNum] = channel;
  }

  MainDownloadChannel({required super.channel});
}
