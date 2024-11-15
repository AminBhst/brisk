import 'dart:io';

class DownloadSettings extends ConnectionSettings {
  final Directory baseSaveDir;
  int totalConnections;

  DownloadSettings({
    required this.baseSaveDir,
    required this.totalConnections,
    required super.loggerEnabled,
    required super.baseTempDir,
    required super.connectionRetryTimeoutMillis,
    required super.maxConnectionRetryCount,
  });
}

class ConnectionSettings {
  final Directory baseTempDir;
  final int connectionRetryTimeoutMillis;
  final int maxConnectionRetryCount;
  final bool loggerEnabled;

  ConnectionSettings({
    required this.baseTempDir,
    required this.connectionRetryTimeoutMillis,
    required this.maxConnectionRetryCount,
    required this.loggerEnabled,
  });
}
