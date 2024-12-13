import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:brisk/download_engine/channel/engine_channel.dart';
import 'package:brisk/download_engine/connection/download_connection_invoker.dart';
import 'package:brisk/download_engine/download_settings.dart';
import 'package:brisk/download_engine/message/download_isolate_message.dart';
import 'package:brisk/download_engine/model/m3u8.dart';
import 'package:stream_channel/isolate_channel.dart';

import 'package:brisk/model/isolate/isolate_args_pair.dart';

/// The Download Engine responsible for downloading video streams based on the m3u8
/// file format.
class M3U8DownloadEngine {
  static final Map<int, EngineChannel> _engineChannels = {};
  static final Map<int, M3U8> m3u8Map = {};

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
      M3U8? m3u8 = m3u8Map[id];
      if (m3u8 == null) {
        m3u8 = M3U8.fromFile(File(downloadItem.m3u8FilePath!));
        m3u8Map[id] = m3u8!;
      }
      // if (isAssembledFileInvalid(downloadItem)) {
      //   final progress = reassembleFile(downloadItem);
      //   engineChannel.sendMessage(progress);
      //   return;
      // }
      await sendToDownloadIsolates(data, providerChannel, m3u8);
      // for (final channel in _engineChannels[id]!.connectionChannels.values) {
      //   channel.listenToStream(_handleConnectionMessages);
      // }
    });
  }

  static Future<void> sendToDownloadIsolates(
    DownloadIsolateMessage data,
    IsolateChannel handlerChannel,
    M3U8 m3u8,
  ) async {
    final int id = data.downloadItem.id;
    Completer<void> completer = Completer();
    final engineChannel = _engineChannels[id];
    final logger = engineChannel?.logger;
    if (engineChannel!.connectionChannels.isEmpty) {
      await _spawnDownloadIsolates(data);
    } else {
      _engineChannels[id]?.connectionChannels.forEach((connNum, connection) {
        final newData = data.clone()..connectionNumber = connNum;
        logger?.info(
          "Sent Command ${data.command} with segment ${data.segment} to connection $connNum",
        );
        connection.sendMessage(newData);
      });
    }
    return completer.complete();
  }

  static _spawnDownloadIsolates(DownloadIsolateMessage data) async {
    final m3u8 = m3u8Map[data.downloadItem.id]!;
    final segments =
        m3u8.segments.sublist(0, downloadSettings.totalConnections);
    for (final segment in segments) {
      _spawnSingleDownloadIsolate(data, connNum)
    }
  }

  static _spawnSingleDownloadIsolate(
    DownloadIsolateMessage data,
    int connNum,
  ) async {
    final rPort = ReceivePort();
    final channel = IsolateChannel.connectReceive(rPort);
    final id = data.downloadItem.id;
    final logger = _engineChannels[id]?.logger;
    data.connectionNumber = connNum;
    logger?.info(
      "Spawning download connection isolate with connection number ${data.connectionNumber}...",
    );
    final isolate = await Isolate.spawn(
      DownloadConnectionInvoker.invokeConnection,
      rPort.sendPort,
      errorsAreFatal: false,
    );
    logger?.info(
      "Spawned connection $connNum with segment ${data.segment}",
    );
    channel.sink.add(data);
    _connectionIsolates[id] ??= {};
    _connectionIsolates[id]![connNum] = isolate;
    final connectionChannel = DownloadConnectionChannel(
      channel: channel,
      connectionNumber: connNum,
      segment: data.segment!,
    );
    _engineChannels[id]!.connectionChannels[connNum] = connectionChannel;
    connectionChannel.listenToStream(_handleConnectionMessages);
  }
}
