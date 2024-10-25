import 'dart:isolate';

class IsolateArgsPair<T> {
  final SendPort sendPort;
  final T obj;
  IsolateArgsPair(this.sendPort, this.obj);
}