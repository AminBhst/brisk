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

  void listenToStream<T>(Function(T data) callback) async {
    if (_isListened) {
      return;
    }
    this._isListened = true;
    channel.stream.cast<T>().listen((event) async {
      onEventReceived(event);
      await callback.call(event);
    });
  }

  void onEventReceived(event) {}
}
