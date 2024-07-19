import 'package:brisk/download_engine/download_connection_channel.dart';
import 'package:brisk/download_engine/download_segment_tree.dart';
import 'package:brisk/download_engine/isolate_channel_wrapper.dart';

class MainDownloadChannel extends IsolateChannelWrapper {
  DownloadSegmentTree? segmentTree;

  Map<int, DownloadConnectionChannel> connectionChannels = {};

  int createdConnections = 1; // TODO actually it only counts the number of refresh requests

  void setConnectionChannel(int connNum, DownloadConnectionChannel channel) {
    this.connectionChannels[connNum] = channel;
  }

  MainDownloadChannel({required super.channel});
}
