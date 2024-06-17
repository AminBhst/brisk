import 'package:stream_channel/isolate_channel.dart';

class IsolateChannelWrapper {
  final IsolateChannel channel;
  bool _isListened = false;

  IsolateChannelWrapper({
    required this.channel,
  });

  void listenToStream<T>(Function(T data) callback) {
    if (_isListened) {
      return;
    }
    channel.stream.cast<T>().listen((event) {
      this._isListened = true;
      callback.call(event);
      onEventReceived(event);
    });
  }

  void onEventReceived(event) {}
}
