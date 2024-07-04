import 'package:brisk/download_engine/download_connection_channel.dart';
import 'package:brisk/download_engine/download_segments.dart';
import 'package:brisk/download_engine/isolate_channel_wrapper.dart';

class MainDownloadChannel extends IsolateChannelWrapper {
  DownloadSegments? downloadSegments;

  Map<int, DownloadConnectionChannel> connectionChannels = {};

  void setConnectionChannel(int segmentNum, DownloadConnectionChannel channel) {
    this.connectionChannels[segmentNum] = channel;
  }

  MainDownloadChannel({required super.channel});
}
