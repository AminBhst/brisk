import 'dart:io';

import 'package:brisk/download_engine/channel/engine_channel.dart';
import 'package:brisk/download_engine/download_settings.dart';
import 'package:brisk/download_engine/message/download_isolate_message.dart';
import 'package:brisk/download_engine/model/m3u8.dart';
import 'package:stream_channel/isolate_channel.dart';

import 'package:brisk/model/isolate/isolate_args_pair.dart';

class M3U8DownloadEngine {
  static final Map<int, EngineChannel> _engineChannels = {};

  static late DownloadSettings downloadSettings;

  static void start(IsolateArgsPair<int> args) async {
    final providerChannel = IsolateChannel.connectSend(args.sendPort);
    final engineChannel = EngineChannel(channel: providerChannel);
    _engineChannels[args.obj] = engineChannel;
    // _startEngineTimers();
    engineChannel.listenToStream<DownloadIsolateMessage>((data) async {
      downloadSettings = data.settings;
      final downloadItem = data.downloadItem;
      final id = downloadItem.id;
      final engineChannel = _engineChannels[id]!;
      final m3u8 = M3U8.fromFile(File(downloadItem.m3u8FilePath!));
      // if (isAssembledFileInvalid(downloadItem)) {
      //   final progress = reassembleFile(downloadItem);
      //   engineChannel.sendMessage(progress);
      //   return;
      // }
      // await sendToDownloadIsolates(data, providerChannel);
      // for (final channel in _engineChannels[id]!.connectionChannels.values) {
      //   channel.listenToStream(_handleConnectionMessages);
      // }
    });
  }
}
