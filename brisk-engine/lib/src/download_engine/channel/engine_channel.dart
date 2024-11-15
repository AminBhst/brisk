import 'dart:collection';

import 'package:brisk_engine/src/download_engine/channel/download_connection_channel.dart';
import 'package:brisk_engine/src/download_engine/constants/download_command.dart';
import 'package:brisk_engine/src/download_engine/http_download_engine.dart';
import 'package:brisk_engine/src/download_engine/log/logger.dart';
import 'package:brisk_engine/src/download_engine/message/connection_handshake_message.dart';
import 'package:brisk_engine/src/download_engine/message/download_isolate_message.dart';
import 'package:brisk_engine/src/download_engine/model/download_item_model.dart';
import 'package:brisk_engine/src/download_engine/segment/download_segment_tree.dart';
import 'package:brisk_engine/src/download_engine/util/isolate_channel_wrapper.dart';

/// The download engine channel that is connected via [DownloadRequestProvider].
/// i.e. the messages sent via [sendMessage] will be received by [DownloadRequestProvider].
/// This class is meant to be used as both a means of communication between the engine
/// and the [DownloadRequestProvider] (which technically is the UI), and as a container
/// for all things related to each download request.
class EngineChannel extends IsolateChannelWrapper {
  Logger? logger;

  EngineChannel({required super.channel});

  DownloadItemModel? downloadItem;

  DownloadSegmentTree? segmentTree;

  /// Connection channels listened by [DownloadConnectionInvoker]
  Map<int, DownloadConnectionChannel> connectionChannels = {};

  Queue<DownloadConnectionChannel> connectionReuseQueue = Queue();

  List<EngineConnectionHandshake> pendingHandshakes = [];

  // TODO actually it only counts the number of refresh requests
  int createdConnections = 1;

  bool pauseOnFinalHandshake = false;

  bool assembleRequested = false;

  bool paused = false;

  int lastPauseTimeMillis = DateTime.now().millisecondsSinceEpoch;

  int lastStartTimeMillis = DateTime.now().millisecondsSinceEpoch;

  bool get awaitingConnectionResetResponse =>
      connectionChannels.values.any((conn) => conn.awaitingResetResponse);

  @override
  void onEventReceived(message) {
    if (message is! DownloadIsolateMessage) {
      return;
    }
    downloadItem = message.downloadItem;
    buildLogger(message);
    if (message.command == DownloadCommand.pause) {
      paused = true;
      lastPauseTimeMillis = DateTime.now().millisecondsSinceEpoch;
    }
    if (message.command == DownloadCommand.start) {
      paused = false;
      lastStartTimeMillis = DateTime.now().millisecondsSinceEpoch;
    }
  }

  void buildLogger(DownloadIsolateMessage message) {
    if (logger != null || !message.settings.loggerEnabled) return;
    logger = Logger(
      downloadUid: downloadItem!.uid,
      logBaseDir: message.settings.baseTempDir,
    )..enablePeriodicLogFlush();
  }

  bool get isPauseButtonWaitComplete =>
      lastStartTimeMillis +
          (HttpDownloadEngine.buttonAvailabilityWaitSec * 1000) <
      DateTime.now().millisecondsSinceEpoch;

  bool get isStartButtonWaitComplete =>
      lastPauseTimeMillis +
          (HttpDownloadEngine.buttonAvailabilityWaitSec * 1000) <
      DateTime.now().millisecondsSinceEpoch;
}
