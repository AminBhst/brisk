import 'package:brisk/downloader/isolate_channel_wrapper.dart';

class DownloadChannel extends IsolateChannelWrapper {
  final segmentNumber;
  int startByte;
  int endByte;
  DownloadChannel({
    required super.channel,
    required this.segmentNumber,
    required this.startByte,
    required this.endByte,
  });
}
