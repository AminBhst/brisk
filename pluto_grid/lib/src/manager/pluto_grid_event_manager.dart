import 'dart:async';

import 'package:pluto_grid/pluto_grid.dart';
import 'package:rxdart/rxdart.dart';

class PlutoGridEventManager {
  final PlutoGridStateManager stateManager;

  PlutoGridEventManager({
    required this.stateManager,
  });

  final PublishSubject<PlutoGridEvent> _subject =
      PublishSubject<PlutoGridEvent>();

  PublishSubject<PlutoGridEvent> get subject => _subject;

  late final StreamSubscription _subscription;

  StreamSubscription get subscription => _subscription;

  void dispose() {
    _subscription.cancel();

    _subject.close();
  }

  void init() {
    final normalStream = _subject.stream.where((event) => event.type.isNormal);

    final throttleLeadingStream = _subject.stream
        .where((event) => event.type.isThrottleLeading)
        .transform(
          ThrottleStreamTransformer(
            (_) => TimerStream<PlutoGridEvent>(_, _.duration as Duration),
            trailing: false,
            leading: true,
          ),
        );

    final throttleTrailingStream = _subject.stream
        .where((event) => event.type.isThrottleTrailing)
        .transform(
          ThrottleStreamTransformer(
            (_) => TimerStream<PlutoGridEvent>(_, _.duration as Duration),
            trailing: true,
            leading: false,
          ),
        );

    final debounceStream =
        _subject.stream.where((event) => event.type.isDebounce).transform(
              DebounceStreamTransformer(
                (_) => TimerStream<PlutoGridEvent>(_, _.duration as Duration),
              ),
            );

    _subscription = MergeStream([
      normalStream,
      throttleLeadingStream,
      throttleTrailingStream,
      debounceStream,
    ]).listen(_handler);
  }

  void addEvent(PlutoGridEvent event) {
    _subject.add(event);
  }

  StreamSubscription<PlutoGridEvent> listener(
    void Function(PlutoGridEvent event) onData,
  ) {
    return _subject.stream.listen(onData);
  }

  void _handler(PlutoGridEvent event) {
    event.handler(stateManager);
  }
}
