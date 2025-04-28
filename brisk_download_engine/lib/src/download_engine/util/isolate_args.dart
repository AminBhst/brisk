import 'dart:isolate';

class IsolateSingleArg<T> {
  final SendPort sendPort;
  final T obj;

  IsolateSingleArg(this.sendPort, this.obj);
}

class IsolateArgsPair<T, U> {
  final SendPort sendPort;
  final T firstObject;
  final U secondObject;

  IsolateArgsPair(this.sendPort, this.firstObject, this.secondObject);
}
