class AppAutoLauncher {
  AppAutoLauncher({
    required this.appName,
    required this.appPath,
    this.args = const [],
  });

  final String appName;
  final String appPath;
  final List<String> args;

  Future<bool> isEnabled() {
    throw UnimplementedError();
  }

  Future<bool> enable() {
    throw UnimplementedError();
  }

  Future<bool> disable() {
    throw UnimplementedError();
  }
}
