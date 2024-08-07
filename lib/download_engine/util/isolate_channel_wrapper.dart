import 'package:stream_channel/isolate_channel.dart';

class IsolateChannelWrapper {
  final IsolateChannel channel;
  bool _isListened = false;

  IsolateChannelWrapper({
    required this.channel,
  });

  void sendMessage(message) {
    this.channel.sink.add(message);
  }

  void listenToStream<T>(Function(T data) callback) {
    if (_isListened) {
      return;
    }
    this._isListened = true;
    channel.stream.cast<T>().listen((event) {
      callback.call(event);
      onEventReceived(event);
    });
  }

  void onEventReceived(event) {}
}
