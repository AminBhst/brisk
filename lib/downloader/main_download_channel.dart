import 'package:brisk/downloader/download_connection_channel.dart';
import 'package:brisk/downloader/download_segments.dart';
import 'package:brisk/downloader/isolate_channel_proxy.dart';

class MainDownloadChannel extends IsolateChannelProxy {
  DownloadSegments? segments;

  Map<int, DownloadConnectionChannel> connectionChannels = {};

  void setConnectionChannel(int segmentNum, DownloadConnectionChannel channel) {
    this.connectionChannels[segmentNum] = channel;
  }

  MainDownloadChannel({required super.channel});
}
