import 'package:stream_channel/isolate_channel.dart';
import 'package:uuid/uuid.dart';

enum DownloadCommand {
  start,
  pause,
  startInitial,
  refreshSegment,
  cancel,
  forceCancel,
  clearConnections
}

class TrackedDownloadCommand {
  DownloadCommand command;
  IsolateChannel<dynamic> channel;
  String? uid;

  TrackedDownloadCommand(this.command, this.uid, this.channel);

  factory TrackedDownloadCommand.create(
      DownloadCommand command, IsolateChannel channel) {
    return TrackedDownloadCommand(
      command,
      Uuid().v4(),
      channel,
    );
  }
}
