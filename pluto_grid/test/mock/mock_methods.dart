import 'package:mockito/mockito.dart';

class _Methods {
  void noParamReturnVoid() {}
  void oneParamReturnVoid<T>(T param) {}
  bool oneParamReturnBool<T>(T? param) => true;
}

class MockMethods extends Mock implements _Methods {
  @override
  bool oneParamReturnBool<T>(T? param) => super.noSuchMethod(
        Invocation.method(#onChangeOneParamReturnBoolListener, [param]),
        returnValue: true,
      );
}
