import 'dart:io';

class DownloadSettings extends ConnectionSettings {
  final Directory baseSaveDir;
  int totalConnections;

  DownloadSettings({
    required this.baseSaveDir,
    required this.totalConnections,
    required super.loggerEnabled,
    required super.baseTempDir,
    required super.connectionRetryTimeout,
    required super.maxConnectionRetryCount,
  });
}

class ConnectionSettings {
  final Directory baseTempDir;
  final int connectionRetryTimeout;
  final int maxConnectionRetryCount;
  final bool loggerEnabled;

  ConnectionSettings({
    required this.baseTempDir,
    required this.connectionRetryTimeout,
    required this.maxConnectionRetryCount,
    required this.loggerEnabled,
  });
}
