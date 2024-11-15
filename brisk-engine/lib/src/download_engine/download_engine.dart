import 'dart:isolate';

import 'package:brisk_engine/src/download_engine/util/isolate_args_pair.dart';
import 'package:stream_channel/isolate_channel.dart';
import 'package:stream_channel/stream_channel.dart';

import '../../brisk_engine.dart';
import 'constants/download_command.dart';

class DownloadEngine {
  static final Map<String, StreamChannel?> engineChannels = {};
  static final Map<String, Isolate?> engineIsolates = {};
  static final Map<String, DownloadItemModel> downloadItems = {};
  static DownloadSettings? _settings;

  static void pause(String uid) {
    _executeCommand(uid, DownloadCommand.pause);
  }

  static void resume(String uid) {
    _executeCommand(uid, DownloadCommand.start);
  }

  static void _executeCommand(String uid, DownloadCommand command) {
    final message = DownloadIsolateMessage(
      command: command,
      downloadItem: downloadItems[uid]!,
      settings: _settings!,
    );
    engineChannels[uid]!.sink.add(message);
  }

  static void start(
    DownloadItemModel downloadItem,
    DownloadSettings settings, {
    required Function(ButtonAvailabilityMessage) onButtonAvailability,
    required Function(DownloadProgressMessage) onDownloadProgress,
  }) async {
    if (engineChannels[downloadItem.uid] != null) {
      final message = DownloadIsolateMessage(
        command: DownloadCommand.start,
        downloadItem: downloadItem,
        settings: settings,
      );
      engineChannels[downloadItem.uid]!.sink.add(message);
      return;
    }
    final channel = await _spawnDownloadEngineIsolate(downloadItem);
    _settings = settings;
    downloadItems[downloadItem.uid] = downloadItem;
    channel.stream.listen(
      (message) {
        if (message is DownloadProgressMessage) {
          onDownloadProgress(message);
        }
        if (message is ButtonAvailabilityMessage) {
          onButtonAvailability(message);
        }
      },
    );
    final message = DownloadIsolateMessage(
      command: DownloadCommand.start,
      downloadItem: downloadItem,
      settings: settings,
    );
    channel.sink.add(message);
  }

  static Future<StreamChannel> _spawnDownloadEngineIsolate(
    DownloadItemModel downloadItem,
  ) async {
    final rPort = ReceivePort();
    final channel = IsolateChannel.connectReceive(rPort);
    final isolate = await Isolate.spawn(
      HttpDownloadEngine.start,
      IsolateArgsPair(rPort.sendPort, downloadItem.uid),
      errorsAreFatal: false,
    );
    engineIsolates[downloadItem.uid] = isolate;
    engineChannels[downloadItem.uid] = channel;
    return channel;
  }
}
