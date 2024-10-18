import 'dart:async';

class PlutoDebounce {
  final Duration duration;

  PlutoDebounce({
    this.duration = const Duration(milliseconds: 1),
  });

  Timer? _debounce;

  void dispose() {
    _debounce?.cancel();
  }

  void debounce({
    required void Function() callback,
  }) {
    if (_debounce?.isActive ?? false) {
      _debounce?.cancel();
    }

    _debounce = Timer(duration, callback);
  }
}

class PlutoDebounceByHashCode {
  final Duration duration;

  PlutoDebounceByHashCode({
    this.duration = const Duration(milliseconds: 1),
  });

  Timer? _debounce;

  int? _previousHashCode;

  void dispose() {
    _debounce?.cancel();
  }

  bool isDebounced({
    required int hashCode,
    bool ignore = false,
  }) {
    if (ignore) {
      return false;
    }

    if (_previousHashCode == hashCode) {
      return true;
    }

    if (_debounce?.isActive ?? false) {
      _debounce?.cancel();
    }

    _debounce = Timer(duration, () {
      _previousHashCode = null;
    });

    _previousHashCode = hashCode;

    return false;
  }
}
